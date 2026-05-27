using PosApi.Models;

namespace PosApi.Data;

public interface ICategoryRepository
{
    Task<IEnumerable<Category>> GetAllAsync();
    Task<(IEnumerable<Category> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive);
    Task<Category?> GetByIdAsync(int id);
    Task<int> CreateAsync(Category category);
    Task<bool> UpdateAsync(Category category);
    Task<bool> DeleteAsync(int id);
}

public interface IUnitRepository
{
    Task<IEnumerable<Unit>> GetAllAsync();
    Task<(IEnumerable<Unit> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive);
    Task<Unit?> GetByIdAsync(int id);
    Task<int> CreateAsync(Unit unit);
    Task<bool> UpdateAsync(Unit unit);
    Task<bool> DeleteAsync(int id);
}

public interface IProductRepository
{
    Task<IEnumerable<Product>> GetAllAsync();
    Task<(IEnumerable<Product> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        int? categoryId,
        bool? isActive);
    Task<Product?> GetByIdAsync(int id);
    Task<IEnumerable<Product>> GetByCategoryIdAsync(int categoryId);
    Task<int> CreateAsync(Product product);
    Task<bool> UpdateAsync(Product product);
    Task<bool> DeleteAsync(int id);
}

public interface IProductUnitRepository
{
    Task<IEnumerable<ProductUnit>> GetAllAsync();
    Task<(IEnumerable<ProductUnit> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        int? productId,
        bool? isActive);
    Task<ProductUnit?> GetByIdAsync(int id);
    Task<IEnumerable<ProductUnit>> GetByProductIdAsync(int productId);
    Task<int> CreateAsync(ProductUnit productUnit);
    Task<bool> UpdateAsync(ProductUnit productUnit);
    Task<bool> DeleteAsync(int id);
    Task<bool> UpdateImagePathAsync(int productUnitId, string imagePath);
}

public interface ICustomerRepository
{
    Task<IEnumerable<Customer>> GetAllAsync();
    Task<(IEnumerable<Customer> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive);
    Task<Customer?> GetByIdAsync(int id);
    Task<Customer?> GetByPhoneAsync(string phone);
    Task<int> CreateAsync(Customer customer);
    Task<bool> UpdateAsync(Customer customer);
    Task<bool> DeleteAsync(int id);
}

public interface ICurrencyRepository
{
    Task<IEnumerable<Currency>> GetAllAsync();
    Task<(IEnumerable<Currency> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive);
    Task<Currency?> GetByIdAsync(int id);
    Task<Currency?> GetByCodeAsync(string code);
    Task<Currency?> GetBaseCurrencyAsync();
    Task<int> CreateAsync(Currency currency);
    Task<bool> UpdateAsync(Currency currency);
    Task<bool> DeleteAsync(int id);
}

public interface ISalesRepository
{
    Task<IEnumerable<Sales>> GetAllAsync();
    Task<(IEnumerable<Sales> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        string? status);
    Task<Sales?> GetByIdAsync(int id);
    Task<Sales?> GetBySaleNumberAsync(string saleNumber);
    Task<IEnumerable<Sales>> GetByDateRangeAsync(DateTime startDate, DateTime endDate);
    Task<IEnumerable<Sales>> GetByCustomerIdAsync(int customerId);
    Task<string> GetNextSaleNumberAsync();
    Task<int> CreateAsync(Sales sales);
    Task<bool> UpdateAsync(Sales sales);
    Task<bool> DeleteAsync(int id);
}

public interface ISalesItemRepository
{
    Task<IEnumerable<SalesItem>> GetAllAsync();
    Task<SalesItem?> GetByIdAsync(int id);
    Task<IEnumerable<SalesItem>> GetBySaleIdAsync(int saleId);
    Task<int> CreateAsync(SalesItem salesItem);
    Task<bool> UpdateAsync(SalesItem salesItem);
    Task<bool> DeleteAsync(int id);
}
