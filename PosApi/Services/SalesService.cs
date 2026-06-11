using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;
using System.Data;

namespace PosApi.Services;

public class SalesService : ISalesService
{
    private readonly ISalesRepository _repository;
    private readonly ISalesItemRepository _itemRepository;
    private readonly ICustomerRepository _customerRepository;
    private readonly IProductRepository _productRepository;
    private readonly IProductUnitRepository _productUnitRepository;
    private readonly ICurrencyRepository _currencyRepository;
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public SalesService(
        ISalesRepository repository,
        ISalesItemRepository itemRepository,
        ICustomerRepository customerRepository,
        IProductRepository productRepository,
        IProductUnitRepository productUnitRepository,
        ICurrencyRepository currencyRepository,
        IDatabaseConnectionFactory connectionFactory)
    {
        _repository = repository;
        _itemRepository = itemRepository;
        _customerRepository = customerRepository;
        _productRepository = productRepository;
        _productUnitRepository = productUnitRepository;
        _currencyRepository = currencyRepository;
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<SalesDetailsDto>> GetAllAsync()
    {
        var sales = await _repository.GetAllAsync();
        return await LoadSalesWithItemsAsync(sales);
    }

    public async Task<SalesPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        string? status)
    {
        var (sales, totalCount) = await _repository.GetPagedAsync(page, pageSize, search, status);
        var dtos = await LoadSalesWithItemsAsync(sales);

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
        return await LoadSalesWithItemsAsync(sales);
    }

    public async Task<IEnumerable<SalesDetailsDto>> GetByCustomerIdAsync(int customerId)
    {
        var sales = await _repository.GetByCustomerIdAsync(customerId);
        return await LoadSalesWithItemsAsync(sales);
    }

    public async Task<(decimal TotalAmount, int Count)> GetSalesSummaryAsync(DateTime startDate, DateTime endDate)
    {
        return await _repository.GetSalesSummaryAsync(startDate, endDate);
    }

    private async Task<List<SalesDetailsDto>> LoadSalesWithItemsAsync(IEnumerable<Sales> sales)
    {
        var salesList = sales.ToList();
        if (salesList.Count == 0) return new List<SalesDetailsDto>();

        var saleIds = salesList.Select(s => s.SaleId).ToList();
        var allItems = await _itemRepository.GetBySaleIdsAsync(saleIds);
        var itemsBySaleId = allItems.GroupBy(i => i.SaleId).ToDictionary(g => g.Key, g => g.AsEnumerable());

        return salesList.Select(s => MapToDetailsDto(s, itemsBySaleId.GetValueOrDefault(s.SaleId, Enumerable.Empty<SalesItem>()))).ToList();
    }

    public async Task<int> CreateAsync(CreateSalesDto dto)
    {
        var phoneNumber = dto.PhoneNumber?.Trim();
        if (string.IsNullOrWhiteSpace(phoneNumber))
        {
            throw new ArgumentException("Phone number is required for all sales.");
        }

        // Validate foreign keys
        if (dto.CustomerId.HasValue)
        {
            var customer = await _customerRepository.GetByIdAsync(dto.CustomerId.Value);
            if (customer == null) throw new ArgumentException($"Customer ID {dto.CustomerId.Value} not found.");
        }

        var currency = await _currencyRepository.GetByIdAsync(dto.CurrencyId);
        if (currency == null) throw new ArgumentException($"Currency ID {dto.CurrencyId} not found.");

        foreach (var item in dto.Items)
        {
            var product = await _productRepository.GetByIdAsync(item.ProductId);
            if (product == null) throw new ArgumentException($"Product ID {item.ProductId} not found.");

            var productUnit = await _productUnitRepository.GetByIdAsync(item.ProductUnitId);
            if (productUnit == null) throw new ArgumentException($"Product Unit ID {item.ProductUnitId} not found.");
        }

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

        // Execute within a transaction to ensure data integrity
        var saleId = await _connectionFactory.ExecuteWithTransactionAsync<int>(async (conn, trans) =>
        {
            var id = await _repository.CreateAsync(sale, conn, trans);

            // Create items
            foreach (var item in items)
            {
                item.SaleId = id;
                await _itemRepository.CreateAsync(item, conn, trans);
            }

            return id;
        });

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
        existing.PaymentStatus = dto.PaymentStatus;
        existing.SaleStatus = dto.SaleStatus;
        if (dto.Notes != null) existing.Notes = dto.Notes;
        existing.UpdatedAt = DateTime.Now;

        // Recalculate totals server-side instead of trusting client values
        var items = await _itemRepository.GetBySaleIdAsync(id);
        decimal subtotal = items.Sum(i => i.LineSubtotal);
        decimal itemDiscounts = items.Sum(i => i.DiscountAmount);
        
        // Calculate sale-level discount from percentage if set
        decimal saleLevelDiscount = 0;
        if (dto.DiscountPercentage.HasValue && dto.DiscountPercentage.Value > 0)
        {
            saleLevelDiscount = (subtotal * dto.DiscountPercentage.Value) / 100;
        }
        else if (dto.TotalDiscount > itemDiscounts)
        {
            saleLevelDiscount = dto.TotalDiscount - itemDiscounts;
        }

        decimal totalDiscount = itemDiscounts + saleLevelDiscount;
        decimal totalAmount = subtotal - totalDiscount;

        existing.Subtotal = subtotal;
        existing.TotalDiscount = totalDiscount;
        existing.DiscountPercentage = dto.DiscountPercentage;
        existing.TotalAmount = totalAmount;
        existing.AmountPaid = dto.AmountPaid;
        existing.ChangeAmount = dto.AmountPaid >= totalAmount ? dto.AmountPaid - totalAmount : 0;

        return await _repository.UpdateAsync(existing);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }

    public async Task<int> AddItemAsync(int saleId, CreateSalesItemDto dto)
    {
        return await _connectionFactory.ExecuteWithTransactionAsync<int>(async (conn, trans) =>
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
            
            var itemId = await _itemRepository.CreateAsync(item, conn, trans);
            await RecalculateTotalsAsync(saleId, conn, trans);
            return itemId;
        });
    }

    public async Task<bool> UpdateItemAsync(int saleId, int itemId, UpdateSalesItemDto dto)
    {
        return await _connectionFactory.ExecuteWithTransactionAsync(async (conn, trans) =>
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

            var result = await _itemRepository.UpdateAsync(existing, conn, trans);
            if (result)
            {
                await RecalculateTotalsAsync(saleId, conn, trans);
            }
            return result;
        });
    }

    public async Task<bool> RemoveItemAsync(int saleId, int itemId)
    {
        return await _connectionFactory.ExecuteWithTransactionAsync(async (conn, trans) =>
        {
            var existing = await _itemRepository.GetByIdAsync(itemId);
            if (existing == null || existing.SaleId != saleId) return false;

            var result = await _itemRepository.DeleteAsync(itemId, conn, trans);
            if (result)
            {
                await RecalculateTotalsAsync(saleId, conn, trans);
            }
            return result;
        });
    }

    public async Task<bool> ProcessPaymentAsync(int saleId, ProcessPaymentDto dto)
    {
        var sale = await _repository.GetByIdAsync(saleId);
        if (sale == null) return false;
        if (sale.SaleStatus == "VOIDED") return false;

        // Validate payment amount
        if (dto.PaymentStatus.ToUpperInvariant() == "PAID" && dto.AmountPaid < sale.TotalAmount)
        {
            throw new InvalidOperationException("Amount paid must be greater than or equal to total amount for PAID status.");
        }

        // Calculate change server-side
        var changeAmount = dto.AmountPaid >= sale.TotalAmount ? dto.AmountPaid - sale.TotalAmount : 0;

        sale.PaymentStatus = dto.PaymentStatus.ToUpperInvariant();
        sale.PaymentMethod = dto.PaymentMethod;
        sale.AmountPaid = dto.AmountPaid;
        sale.ChangeAmount = changeAmount;
        sale.PaymentDate = DateTime.Now;
        sale.UpdatedAt = DateTime.Now;

        var result = await _repository.UpdateAsync(sale);
        if (!result)
        {
            throw new InvalidOperationException("Sale was modified by another user. Please refresh and try again.");
        }

        return true;
    }

    public async Task<bool> VoidSaleAsync(int saleId)
    {
        var sale = await _repository.GetByIdAsync(saleId);
        if (sale == null) return false;
        if (sale.SaleStatus == "VOIDED") return false;

        sale.SaleStatus = "VOIDED";
        sale.PaymentStatus = "UNPAID";
        sale.AmountPaid = 0;
        sale.ChangeAmount = 0;
        sale.UpdatedAt = DateTime.Now;

        var result = await _repository.UpdateAsync(sale);
        if (!result)
        {
            throw new InvalidOperationException("Sale was modified by another user. Please refresh and try again.");
        }

        return true;
    }

    private async Task RecalculateTotalsAsync(int saleId, IDbConnection? connection = null, IDbTransaction? transaction = null)
    {
        var conn = connection ?? _connectionFactory.CreateConnection();
        var shouldDispose = connection == null;
        if (shouldDispose) conn.Open();
        
        var sale = await _repository.GetByIdAsync(saleId);
        if (sale == null) return;

        var items = await _itemRepository.GetBySaleIdAsync(saleId);

        decimal subtotal = items.Sum(i => i.LineSubtotal);
        decimal itemDiscounts = items.Sum(i => i.DiscountAmount);
        
        // Calculate sale-level discount from percentage if set
        decimal saleLevelDiscount = 0;
        if (sale.DiscountPercentage.HasValue && sale.DiscountPercentage.Value > 0)
        {
            saleLevelDiscount = (subtotal * sale.DiscountPercentage.Value) / 100;
        }
        else if (sale.TotalDiscount > itemDiscounts)
        {
            // Preserve fixed sale-level discount amount
            saleLevelDiscount = sale.TotalDiscount - itemDiscounts;
        }

        decimal totalDiscount = itemDiscounts + saleLevelDiscount;
        decimal totalAmount = subtotal - totalDiscount;

        sale.Subtotal = subtotal;
        sale.TotalDiscount = totalDiscount;
        sale.TotalAmount = totalAmount;
        sale.UpdatedAt = DateTime.Now;

        await _repository.UpdateAsync(sale, conn, transaction);
        
        if (shouldDispose) conn.Dispose();
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
