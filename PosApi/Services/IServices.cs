using PosApi.DTOs;

namespace PosApi.Services;

public interface ICategoryService
{
    Task<IEnumerable<CategoryDetailsDto>> GetAllAsync();
    Task<CategoryDetailsDto?> GetByIdAsync(int id);
    Task<int> CreateAsync(CreateCategoryDto dto);
    Task<bool> UpdateAsync(int id, UpdateCategoryDto dto);
    Task<bool> DeleteAsync(int id);
}

public interface IUnitService
{
    Task<IEnumerable<UnitDetailsDto>> GetAllAsync();
    Task<UnitDetailsDto?> GetByIdAsync(int id);
    Task<int> CreateAsync(CreateUnitDto dto);
    Task<bool> UpdateAsync(int id, UpdateUnitDto dto);
    Task<bool> DeleteAsync(int id);
}

public interface IProductService
{
    Task<IEnumerable<ProductDetailsDto>> GetAllAsync();
    Task<ProductPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        int? categoryId,
        bool? isActive);
    Task<ProductDetailsDto?> GetByIdAsync(int id);
    Task<IEnumerable<ProductDetailsDto>> GetByCategoryIdAsync(int categoryId);
    Task<int> CreateAsync(CreateProductDto dto);
    Task<bool> UpdateAsync(int id, UpdateProductDto dto);
    Task<bool> DeleteAsync(int id);
}

public interface IProductUnitService
{
    Task<IEnumerable<ProductUnitDetailsDto>> GetAllAsync();
    Task<ProductUnitDetailsDto?> GetByIdAsync(int id);
    Task<IEnumerable<ProductUnitDetailsDto>> GetByProductIdAsync(int productId);
    Task<int> CreateAsync(CreateProductUnitDto dto);
    Task<bool> UpdateAsync(int id, UpdateProductUnitDto dto);
    Task<bool> DeleteAsync(int id);
    Task<ImageUploadResponse> UploadImageAsync(int productUnitId, IFormFile file);
    Task<ImageDeleteResponse> DeleteImageAsync(int productUnitId);
    Task<byte[]?> GetImageBytesAsync(int productUnitId);
}

public interface ICustomerService
{
    Task<IEnumerable<CustomerDetailsDto>> GetAllAsync();
    Task<CustomerPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive);
    Task<CustomerDetailsDto?> GetByIdAsync(int id);
    Task<CustomerDetailsDto?> GetByPhoneAsync(string phone);
    Task<int> CreateAsync(CreateCustomerDto dto);
    Task<bool> UpdateAsync(int id, UpdateCustomerDto dto);
    Task<bool> DeleteAsync(int id);
}

public interface ICurrencyService
{
    Task<IEnumerable<CurrencyDetailsDto>> GetAllAsync();
    Task<CurrencyDetailsDto?> GetByIdAsync(int id);
    Task<CurrencyDetailsDto?> GetByCodeAsync(string code);
    Task<CurrencyDetailsDto?> GetBaseCurrencyAsync();
    Task<int> CreateAsync(CreateCurrencyDto dto);
    Task<bool> UpdateAsync(int id, UpdateCurrencyDto dto);
    Task<bool> DeleteAsync(int id);
}

public interface ISalesService
{
    Task<IEnumerable<SalesDetailsDto>> GetAllAsync();
    Task<SalesPagedResponseDto> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        string? status);
    Task<SalesDetailsDto?> GetByIdAsync(int id);
    Task<SalesDetailsDto?> GetBySaleNumberAsync(string saleNumber);
    Task<IEnumerable<SalesDetailsDto>> GetByDateRangeAsync(DateTime startDate, DateTime endDate);
    Task<IEnumerable<SalesDetailsDto>> GetByCustomerIdAsync(int customerId);
    Task<int> CreateAsync(CreateSalesDto dto);
    Task<bool> UpdateAsync(int id, UpdateSalesDto dto);
    Task<bool> DeleteAsync(int id);
    
    // Aggregation root methods
    Task<int> AddItemAsync(int saleId, CreateSalesItemDto dto);
    Task<bool> UpdateItemAsync(int saleId, int itemId, UpdateSalesItemDto dto);
    Task<bool> RemoveItemAsync(int saleId, int itemId);
}
