using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Services;

public class ProductService : IProductService
{
    private readonly IProductRepository _repository;
    private readonly IProductUnitRepository _productUnitRepository;
    private readonly ICurrencyService _currencyService;
    private readonly IConfiguration _configuration;

    public ProductService(
        IProductRepository repository,
        IProductUnitRepository productUnitRepository,
        ICurrencyService currencyService,
        IConfiguration configuration)
    {
        _repository = repository;
        _productUnitRepository = productUnitRepository;
        _currencyService = currencyService;
        _configuration = configuration;
    }

    public async Task<IEnumerable<ProductDetailsDto>> GetAllAsync()
    {
        var products = await _repository.GetAllAsync();
        var baseCurrency = await _currencyService.GetBaseCurrencyAsync();
        
        var productDtos = new List<ProductDetailsDto>();
        foreach (var product in products)
        {
            var productUnits = await _productUnitRepository.GetByProductIdAsync(product.ProductId);
            productDtos.Add(MapToDetailsDto(product, productUnits, baseCurrency));
        }
        
        return productDtos;
    }

    public async Task<ProductPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        int? categoryId,
        bool? isActive)
    {
        var (items, totalCount) = await _repository.GetPagedAsync(page, pageSize, search, categoryId, isActive);
        var baseCurrency = await _currencyService.GetBaseCurrencyAsync();
        
        var productDtos = new List<ProductDetailsDto>();
        foreach (var product in items)
        {
            var productUnits = await _productUnitRepository.GetByProductIdAsync(product.ProductId);
            productDtos.Add(MapToDetailsDto(product, productUnits, baseCurrency));
        }
        
        return new ProductPagedResponseDto
        {
            Data = productDtos,
            Page = page,
            PageSize = pageSize,
            TotalCount = totalCount
        };
    }

    public async Task<ProductDetailsDto?> GetByIdAsync(int id)
    {
        var product = await _repository.GetByIdAsync(id);
        if (product == null) return null;

        var productUnits = await _productUnitRepository.GetByProductIdAsync(id);
        var baseCurrency = await _currencyService.GetBaseCurrencyAsync();
        return MapToDetailsDto(product, productUnits, baseCurrency);
    }

    public async Task<IEnumerable<ProductDetailsDto>> GetByCategoryIdAsync(int categoryId)
    {
        var products = await _repository.GetByCategoryIdAsync(categoryId);
        var baseCurrency = await _currencyService.GetBaseCurrencyAsync();
        
        var productDtos = new List<ProductDetailsDto>();
        foreach (var product in products)
        {
            var productUnits = await _productUnitRepository.GetByProductIdAsync(product.ProductId);
            productDtos.Add(MapToDetailsDto(product, productUnits, baseCurrency));
        }
        
        return productDtos;
    }

    public async Task<int> CreateAsync(CreateProductDto dto)
    {
        var product = new Product
        {
            ProductCode = dto.ProductCode,
            ProductName = dto.ProductName,
            CategoryId = dto.CategoryId,
            BaseUnitId = dto.BaseUnitId,
            Description = dto.Description,
            IsActive = true,
            CreatedAt = DateTime.Now
        };
        return await _repository.CreateAsync(product);
    }

    public async Task<bool> UpdateAsync(int id, UpdateProductDto dto)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return false;

        if (dto.ProductCode != null) existing.ProductCode = dto.ProductCode;
        if (dto.ProductName != null) existing.ProductName = dto.ProductName;
        if (dto.CategoryId.HasValue) existing.CategoryId = dto.CategoryId.Value;
        if (dto.BaseUnitId.HasValue) existing.BaseUnitId = dto.BaseUnitId.Value;
        if (dto.Description != null) existing.Description = dto.Description;
        if (dto.IsActive.HasValue) existing.IsActive = dto.IsActive.Value;
        existing.UpdatedAt = DateTime.Now;

        return await _repository.UpdateAsync(existing);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        return await _repository.DeleteAsync(id);
    }

    private ProductDetailsDto MapToDetailsDto(
        Product product,
        IEnumerable<ProductUnit>? units = null,
        CurrencyDetailsDto? baseCurrency = null)
    {
        var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:7070";

        return new ProductDetailsDto
        {
            ProductId = product.ProductId,
            ProductCode = product.ProductCode,
            ProductName = product.ProductName,
            CategoryId = product.CategoryId,
            CategoryName = product.CategoryName,
            BaseUnitId = product.BaseUnitId,
            BaseUnitName = product.BaseUnitName,
            Description = product.Description,
            IsActive = product.IsActive,
            CreatedAt = product.CreatedAt,
            UpdatedAt = product.UpdatedAt,
            Units = (units ?? Enumerable.Empty<ProductUnit>())
                .Select(unit => new ProductUnitDetailsDto
                {
                    ProductUnitId = unit.ProductUnitId,
                    ProductId = unit.ProductId,
                    ProductName = unit.ProductName,
                    UnitId = unit.UnitId,
                    UnitName = unit.UnitName,
                    UnitCode = unit.UnitCode,
                    CurrencyId = baseCurrency?.CurrencyId,
                    CurrencyCode = baseCurrency?.CurrencyCode,
                    CurrencySymbol = baseCurrency?.CurrencySymbol,
                    IsBaseCurrency = baseCurrency?.IsBaseCurrency ?? false,
                    ConversionRate = unit.ConversionRate,
                    Price = unit.Price,
                    IsDefault = unit.IsDefault,
                    IsActive = unit.IsActive,
                    ImagePath = unit.ImagePath,
                    ImageUrl = !string.IsNullOrEmpty(unit.ImagePath)
                        ? $"{baseUrl}/{unit.ImagePath}"
                        : null,
                    CreatedAt = unit.CreatedAt,
                    UpdatedAt = unit.UpdatedAt
                })
                .ToList()
        };
    }
}
