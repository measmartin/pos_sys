using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Services;

public class SalesService : ISalesService
{
    private readonly ISalesRepository _repository;
    private readonly ISalesItemRepository _itemRepository;

    public SalesService(
        ISalesRepository repository,
        ISalesItemRepository itemRepository)
    {
        _repository = repository;
        _itemRepository = itemRepository;
    }

    public async Task<IEnumerable<SalesDetailsDto>> GetAllAsync()
    {
        var sales = await _repository.GetAllAsync();
        var dtos = new List<SalesDetailsDto>();

        foreach (var sale in sales)
        {
            var items = await _itemRepository.GetBySaleIdAsync(sale.SaleId);
            dtos.Add(MapToDetailsDto(sale, items));
        }

        return dtos;
    }

    public async Task<SalesPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        string? status)
    {
        var (sales, totalCount) = await _repository.GetPagedAsync(page, pageSize, search, status);
        var dtos = new List<SalesDetailsDto>();

        foreach (var sale in sales)
        {
            var items = await _itemRepository.GetBySaleIdAsync(sale.SaleId);
            dtos.Add(MapToDetailsDto(sale, items));
        }

        return new SalesPagedResponseDto
        {
            Data = dtos,
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount
        };
    }

    public async Task<SalesDetailsDto?> GetByIdAsync(int id)
    {
        var sale = await _repository.GetByIdAsync(id);
        if (sale == null) return null;

        var items = await _itemRepository.GetBySaleIdAsync(id);
        return MapToDetailsDto(sale, items);
    }

    public async Task<SalesDetailsDto?> GetBySaleNumberAsync(string saleNumber)
    {
        var sale = await _repository.GetBySaleNumberAsync(saleNumber);
        if (sale == null) return null;

        var items = await _itemRepository.GetBySaleIdAsync(sale.SaleId);
        return MapToDetailsDto(sale, items);
    }

    public async Task<IEnumerable<SalesDetailsDto>> GetByDateRangeAsync(DateTime startDate, DateTime endDate)
    {
        var sales = await _repository.GetByDateRangeAsync(startDate, endDate);
        var dtos = new List<SalesDetailsDto>();

        foreach (var sale in sales)
        {
            var items = await _itemRepository.GetBySaleIdAsync(sale.SaleId);
            dtos.Add(MapToDetailsDto(sale, items));
        }

        return dtos;
    }

    public async Task<IEnumerable<SalesDetailsDto>> GetByCustomerIdAsync(int customerId)
    {
        var sales = await _repository.GetByCustomerIdAsync(customerId);
        var dtos = new List<SalesDetailsDto>();

        foreach (var sale in sales)
        {
            var items = await _itemRepository.GetBySaleIdAsync(sale.SaleId);
            dtos.Add(MapToDetailsDto(sale, items));
        }

        return dtos;
    }

    public async Task<int> CreateAsync(CreateSalesDto dto)
    {
        var phoneNumber = dto.PhoneNumber?.Trim();
        if (string.IsNullOrWhiteSpace(phoneNumber))
        {
            throw new ArgumentException("Phone number is required for all sales.");
        }

        // Get next sale number
        var saleNumber = await _repository.GetNextSaleNumberAsync();

        // Calculate totals from items
        int lineNumber = 1;
        decimal subtotal = 0;
        var items = new List<SalesItem>();
        
        foreach (var itemDto in dto.Items)
        {
            decimal lineSubtotal = itemDto.Quantity * itemDto.UnitPrice;
            decimal discountAmt = itemDto.DiscountAmount ?? 0;
            decimal lineTotal = lineSubtotal - discountAmt;
            subtotal += lineSubtotal;
            
            items.Add(new SalesItem
            {
                LineNumber = lineNumber++,
                ProductId = itemDto.ProductId,
                ProductUnitId = itemDto.ProductUnitId,
                Quantity = itemDto.Quantity,
                UnitPrice = itemDto.UnitPrice,
                LineSubtotal = lineSubtotal,
                DiscountAmount = discountAmt,
                DiscountPercentage = itemDto.DiscountPercentage,
                LineTotal = lineTotal,
                Notes = itemDto.Notes,
                CreatedAt = DateTime.Now
            });
        }

        // Calculate sale-level discount
        decimal saleDiscountAmount = dto.DiscountAmount ?? 0;
        decimal saleDiscountPercentage = dto.DiscountPercentage ?? 0;

        // If discount percentage is provided, calculate amount
        if (dto.DiscountPercentage.HasValue && dto.DiscountPercentage > 0)
        {
            saleDiscountPercentage = dto.DiscountPercentage.Value;
            saleDiscountAmount = (subtotal * saleDiscountPercentage) / 100;
        }
        // If discount amount is provided, calculate percentage
        else if (dto.DiscountAmount.HasValue && dto.DiscountAmount > 0)
        {
            saleDiscountAmount = dto.DiscountAmount.Value;
            saleDiscountPercentage = subtotal > 0 ? (saleDiscountAmount / subtotal) * 100 : 0;
        }

        decimal totalItemDiscount = items.Sum(i => i.DiscountAmount);
        decimal totalDiscount = totalItemDiscount + saleDiscountAmount;
        decimal totalAmount = subtotal - totalDiscount;

        // Determine payment status and change
        var requestedPaymentStatus = dto.PaymentStatus?.Trim().ToUpperInvariant();
        string paymentStatus;
        decimal changeAmount = 0;
        decimal amountPaid = dto.AmountPaid;

        if (requestedPaymentStatus is "PAID" or "PARTIAL" or "UNPAID")
        {
            paymentStatus = requestedPaymentStatus;
            if (paymentStatus == "UNPAID")
            {
                amountPaid = 0;
            }
            if (paymentStatus == "PAID" && amountPaid <= 0)
            {
                amountPaid = totalAmount;
            }
            if (amountPaid >= totalAmount)
            {
                changeAmount = amountPaid - totalAmount;
            }
        }
        else
        {
            paymentStatus = "UNPAID";
            if (dto.AmountPaid >= totalAmount)
            {
                paymentStatus = "PAID";
                changeAmount = dto.AmountPaid - totalAmount;
            }
            else if (dto.AmountPaid > 0)
            {
                paymentStatus = "PARTIAL";
            }
        }

        var sale = new Sales
        {
            SaleNumber = saleNumber,
            SaleDate = dto.SaleDate,
            CustomerId = dto.CustomerId,
            PhoneNumber = phoneNumber,
            CurrencyId = dto.CurrencyId,
            Subtotal = subtotal,
            TotalDiscount = totalDiscount,
            DiscountPercentage = saleDiscountPercentage > 0 ? saleDiscountPercentage : null,
            TotalAmount = totalAmount,
            AmountPaid = amountPaid,
            ChangeAmount = changeAmount,
            PaymentStatus = paymentStatus,
            PaymentMethod = amountPaid > 0 ? "CASH" : null,
            PaymentDate = amountPaid > 0 ? DateTime.Now : null,
            SaleStatus = string.IsNullOrWhiteSpace(dto.SaleStatus) ? "COMPLETED" : dto.SaleStatus.Trim().ToUpperInvariant(),
            Notes = dto.Notes,
            CreatedAt = DateTime.Now
        };

        var saleId = await _repository.CreateAsync(sale);

        // Create items
        foreach (var item in items)
        {
            item.SaleId = saleId;
            await _itemRepository.CreateAsync(item);
        }

        return saleId;
    }

    public async Task<bool> UpdateAsync(int id, UpdateSalesDto dto)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return false;

        if (string.IsNullOrWhiteSpace(dto.PhoneNumber))
        {
            throw new ArgumentException("Phone number is required for all sales.");
        }

        existing.SaleDate = dto.SaleDate;
        existing.CustomerId = dto.CustomerId;
        existing.PhoneNumber = dto.PhoneNumber.Trim();
        existing.CurrencyId = dto.CurrencyId;
        existing.Subtotal = dto.Subtotal;
        existing.TotalDiscount = dto.TotalDiscount;
        existing.DiscountPercentage = dto.DiscountPercentage;
        existing.TotalAmount = dto.TotalAmount;
        existing.AmountPaid = dto.AmountPaid;
        existing.PaymentStatus = dto.PaymentStatus;
        existing.SaleStatus = dto.SaleStatus;
        if (dto.Notes != null) existing.Notes = dto.Notes;
        existing.UpdatedAt = DateTime.Now;

        return await _repository.UpdateAsync(existing);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }

    public async Task<int> AddItemAsync(int saleId, CreateSalesItemDto dto)
    {
        // Get the next line number for this sale
        var existingItems = await _itemRepository.GetBySaleIdAsync(saleId);
        int nextLineNumber = existingItems.Any() ? existingItems.Max(i => i.LineNumber) + 1 : 1;

        decimal lineSubtotal = dto.Quantity * dto.UnitPrice;
        decimal discountAmt = dto.DiscountAmount ?? 0;
        decimal lineTotal = lineSubtotal - discountAmt;

        var item = new SalesItem
        {
            SaleId = saleId,
            LineNumber = nextLineNumber,
            ProductId = dto.ProductId,
            ProductUnitId = dto.ProductUnitId,
            Quantity = dto.Quantity,
            UnitPrice = dto.UnitPrice,
            LineSubtotal = lineSubtotal,
            DiscountAmount = discountAmt,
            DiscountPercentage = dto.DiscountPercentage,
            LineTotal = lineTotal,
            Notes = dto.Notes,
            CreatedAt = DateTime.Now
        };
        
        var itemId = await _itemRepository.CreateAsync(item);
        await RecalculateTotalsAsync(saleId);
        return itemId;
    }

    public async Task<bool> UpdateItemAsync(int saleId, int itemId, UpdateSalesItemDto dto)
    {
        var existing = await _itemRepository.GetByIdAsync(itemId);
        if (existing == null || existing.SaleId != saleId) return false;

        decimal lineSubtotal = dto.Quantity * dto.UnitPrice;
        decimal discountAmt = dto.DiscountAmount ?? 0;
        decimal lineTotal = lineSubtotal - discountAmt;

        existing.Quantity = dto.Quantity;
        existing.UnitPrice = dto.UnitPrice;
        existing.LineSubtotal = lineSubtotal;
        existing.DiscountPercentage = dto.DiscountPercentage;
        existing.DiscountAmount = discountAmt;
        existing.LineTotal = lineTotal;

        var result = await _itemRepository.UpdateAsync(existing);
        if (result)
        {
            await RecalculateTotalsAsync(saleId);
        }
        return result;
    }

    public async Task<bool> RemoveItemAsync(int saleId, int itemId)
    {
        var existing = await _itemRepository.GetByIdAsync(itemId);
        if (existing == null || existing.SaleId != saleId) return false;

        var result = await _itemRepository.DeleteAsync(itemId);
        if (result)
        {
            await RecalculateTotalsAsync(saleId);
        }
        return result;
    }

    private async Task RecalculateTotalsAsync(int saleId)
    {
        var sale = await _repository.GetByIdAsync(saleId);
        if (sale == null) return;

        var items = await _itemRepository.GetBySaleIdAsync(saleId);

        decimal subtotal = items.Sum(i => i.LineSubtotal);
        decimal itemDiscounts = items.Sum(i => i.DiscountAmount);
        decimal totalDiscount = itemDiscounts + (sale.TotalDiscount - items.Sum(i => i.DiscountAmount));
        decimal totalAmount = subtotal - totalDiscount;

        sale.Subtotal = subtotal;
        sale.TotalDiscount = totalDiscount;
        sale.TotalAmount = totalAmount;
        sale.UpdatedAt = DateTime.Now;

        await _repository.UpdateAsync(sale);
    }

    private static SalesDetailsDto MapToDetailsDto(Sales sale, IEnumerable<SalesItem> items)
    {
        return new SalesDetailsDto
        {
            SaleId = sale.SaleId,
            SaleNumber = sale.SaleNumber,
            SaleDate = sale.SaleDate,
            CustomerId = sale.CustomerId,
            CustomerName = sale.CustomerName,
            PhoneNumber = sale.PhoneNumber,
            CurrencyId = sale.CurrencyId,
            CurrencyCode = sale.CurrencyCode,
            CurrencySymbol = sale.CurrencySymbol,
            Subtotal = sale.Subtotal,
            TotalDiscount = sale.TotalDiscount,
            DiscountPercentage = sale.DiscountPercentage,
            TotalAmount = sale.TotalAmount,
            AmountPaid = sale.AmountPaid,
            ChangeAmount = sale.ChangeAmount,
            PaymentStatus = sale.PaymentStatus,
            SaleStatus = sale.SaleStatus,
            Notes = sale.Notes,
            CreatedAt = sale.CreatedAt,
            UpdatedAt = sale.UpdatedAt,
            Items = items.Select(MapItemToDto).ToList()
        };
    }

    private static SalesItemDetailsDto MapItemToDto(SalesItem item)
    {
        return new SalesItemDetailsDto
        {
            SalesItemId = item.SalesItemId,
            SaleId = item.SaleId,
            LineNumber = item.LineNumber,
            ProductId = item.ProductId,
            ProductName = item.ProductName,
            ProductUnitId = item.ProductUnitId,
            UnitName = item.UnitName,
            Quantity = item.Quantity,
            UnitPrice = item.UnitPrice,
            LineSubtotal = item.LineSubtotal,
            DiscountAmount = item.DiscountAmount,
            DiscountPercentage = item.DiscountPercentage,
            LineTotal = item.LineTotal,
            Notes = item.Notes,
            CreatedAt = item.CreatedAt
        };
    }
}
