using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Services;

public class ProductUnitService : IProductUnitService
{
    private readonly IProductUnitRepository _repository;
    private readonly ICurrencyService _currencyService;
    private readonly IImageService _imageService;
    private readonly IConfiguration _configuration;

    public ProductUnitService(
        IProductUnitRepository repository,
        ICurrencyService currencyService,
        IImageService imageService,
        IConfiguration configuration)
    {
        _repository = repository;
        _currencyService = currencyService;
        _imageService = imageService;
        _configuration = configuration;
    }

    public async Task<IEnumerable<ProductUnitDetailsDto>> GetAllAsync()
    {
        var productUnits = await _repository.GetAllAsync();
        var baseCurrency = await _currencyService.GetBaseCurrencyAsync();
        return productUnits.Select(productUnit => MapToDetailsDto(productUnit, baseCurrency));
    }

    public async Task<ProductUnitDetailsDto?> GetByIdAsync(int id)
    {
        var productUnit = await _repository.GetByIdAsync(id);
        if (productUnit == null) return null;

        var baseCurrency = await _currencyService.GetBaseCurrencyAsync();
        return MapToDetailsDto(productUnit, baseCurrency);
    }

    public async Task<IEnumerable<ProductUnitDetailsDto>> GetByProductIdAsync(int productId)
    {
        var productUnits = await _repository.GetByProductIdAsync(productId);
        var baseCurrency = await _currencyService.GetBaseCurrencyAsync();
        return productUnits.Select(productUnit => MapToDetailsDto(productUnit, baseCurrency));
    }

    public async Task<int> CreateAsync(CreateProductUnitDto dto)
    {
        var productUnit = new ProductUnit
        {
            ProductId = dto.ProductId,
            UnitId = dto.UnitId,
            ConversionRate = dto.ConversionRate,
            Price = dto.Price,
            IsDefault = dto.IsDefault,
            IsActive = true,
            CreatedAt = DateTime.Now
        };
        return await _repository.CreateAsync(productUnit);
    }

    public async Task<bool> UpdateAsync(int id, UpdateProductUnitDto dto)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return false;

        if (dto.ConversionRate.HasValue) existing.ConversionRate = dto.ConversionRate.Value;
        if (dto.Price.HasValue) existing.Price = dto.Price.Value;
        if (dto.IsDefault.HasValue) existing.IsDefault = dto.IsDefault.Value;
        if (dto.IsActive.HasValue) existing.IsActive = dto.IsActive.Value;
        existing.UpdatedAt = DateTime.Now;

        return await _repository.UpdateAsync(existing);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await _repository.GetByIdAsync(id);
        if (existing == null) return false;

        if (!string.IsNullOrEmpty(existing.ImagePath))
        {
            await _imageService.DeleteImageAsync(existing.ImagePath);
        }

        return await _repository.DeleteAsync(id);
    }

    public async Task<ImageUploadResponse> UploadImageAsync(int productUnitId, IFormFile file)
    {
        var existing = await _repository.GetByIdAsync(productUnitId);
        if (existing == null)
        {
            throw new KeyNotFoundException($"ProductUnit with ID {productUnitId} not found");
        }

        if (!string.IsNullOrEmpty(existing.ImagePath))
        {
            await _imageService.DeleteImageAsync(existing.ImagePath);
        }

        var response = await _imageService.UploadImageAsync(file, productUnitId);
        await _repository.UpdateImagePathAsync(productUnitId, response.ImagePath);

        return response;
    }

    public async Task<ImageDeleteResponse> DeleteImageAsync(int productUnitId)
    {
        var existing = await _repository.GetByIdAsync(productUnitId);
        if (existing == null)
        {
            return new ImageDeleteResponse { Success = false, Message = $"ProductUnit with ID {productUnitId} not found" };
        }

        if (string.IsNullOrEmpty(existing.ImagePath))
        {
            return new ImageDeleteResponse { Success = false, Message = "No image found for this ProductUnit" };
        }

        var deleteResponse = await _imageService.DeleteImageAsync(existing.ImagePath);
        if (deleteResponse.Success)
        {
            await _repository.UpdateImagePathAsync(productUnitId, string.Empty);
        }

        return deleteResponse;
    }

    public async Task<byte[]?> GetImageBytesAsync(int productUnitId)
    {
        var existing = await _repository.GetByIdAsync(productUnitId);
        if (existing == null || string.IsNullOrEmpty(existing.ImagePath))
        {
            return null;
        }

        return await _imageService.GetImageBytesAsync(existing.ImagePath);
    }

    private ProductUnitDetailsDto MapToDetailsDto(ProductUnit productUnit, CurrencyDetailsDto? baseCurrency)
    {
        var baseUrl = _configuration["BaseUrl"] ?? "https://localhost:7070";
        
        return new ProductUnitDetailsDto
        {
            ProductUnitId = productUnit.ProductUnitId,
            ProductId = productUnit.ProductId,
            ProductName = productUnit.ProductName,
            UnitId = productUnit.UnitId,
            UnitName = productUnit.UnitName,
            UnitCode = productUnit.UnitCode,
            CurrencyId = baseCurrency?.CurrencyId,
            CurrencyCode = baseCurrency?.CurrencyCode,
            CurrencySymbol = baseCurrency?.CurrencySymbol,
            IsBaseCurrency = baseCurrency?.IsBaseCurrency ?? false,
            ConversionRate = productUnit.ConversionRate,
            Price = productUnit.Price,
            IsDefault = productUnit.IsDefault,
            IsActive = productUnit.IsActive,
            ImagePath = productUnit.ImagePath,
            ImageUrl = !string.IsNullOrEmpty(productUnit.ImagePath) ? $"{baseUrl}/{productUnit.ImagePath}" : null,
            CreatedAt = productUnit.CreatedAt,
            UpdatedAt = productUnit.UpdatedAt
        };
    }
}
