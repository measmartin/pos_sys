using PosApi.DTOs;
using PosApi.Models;
using System.Data;

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
    Task<int> GetCountAsync();
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
    Task<IEnumerable<ProductUnit>> GetByProductIdsAsync(IEnumerable<int> productIds);
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
    Task<int> GetCountAsync();
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
    Task<(decimal TotalAmount, int Count)> GetSalesSummaryAsync(DateTime startDate, DateTime endDate);
    Task<string> GetNextSaleNumberAsync(IDbConnection? connection = null, IDbTransaction? transaction = null);
    Task<int> CreateAsync(Sales sales, IDbConnection? connection = null, IDbTransaction? transaction = null);
    Task<bool> UpdateAsync(Sales sales, IDbConnection? connection = null, IDbTransaction? transaction = null);
    Task<bool> DeleteAsync(int id);
}

public interface ISalesItemRepository
{
    Task<IEnumerable<SalesItem>> GetAllAsync();
    Task<SalesItem?> GetByIdAsync(int id);
    Task<IEnumerable<SalesItem>> GetBySaleIdAsync(int saleId);
    Task<IEnumerable<SalesItem>> GetBySaleIdsAsync(IEnumerable<int> saleIds);
    Task<int> CreateAsync(SalesItem salesItem, IDbConnection? connection = null, IDbTransaction? transaction = null);
    Task<bool> UpdateAsync(SalesItem salesItem, IDbConnection? connection = null, IDbTransaction? transaction = null);
    Task<bool> DeleteAsync(int id, IDbConnection? connection = null, IDbTransaction? transaction = null);
}

public interface IReportRepository
{
    Task<SalesSummaryDto> GetSalesSummaryAsync(ReportQueryParams queryParams);
    Task<IEnumerable<DailySalesDto>> GetDailySalesAsync(ReportQueryParams queryParams);
    Task<IEnumerable<MonthlySalesDto>> GetMonthlySalesAsync(ReportQueryParams queryParams);
    Task<IEnumerable<HourlySalesDto>> GetHourlySalesAsync(ReportQueryParams queryParams);
    Task<IEnumerable<TopProductDto>> GetTopProductsAsync(ReportQueryParams queryParams, int topN = 20);
    Task<IEnumerable<CategorySalesDto>> GetCategorySalesAsync(ReportQueryParams queryParams);
    Task<IEnumerable<TopCustomerDto>> GetTopCustomersAsync(ReportQueryParams queryParams, int topN = 20);
    Task<IEnumerable<PaymentBreakdownDto>> GetPaymentBreakdownAsync(ReportQueryParams queryParams);
    Task<IEnumerable<SalesDetailsExportDto>> GetSalesDetailsAsync(ReportQueryParams queryParams);
    Task<IEnumerable<CurrencyInfoDto>> GetAllCurrenciesAsync();
}

public interface IUserRepository
{
    Task<PosApi.Models.User?> GetByIdAsync(int id);
    Task<PosApi.Models.User?> GetByUsernameAsync(string username);
    Task<PosApi.Models.User?> GetByEmailAsync(string email);
    Task<bool> ExistsAsync(string username);
    Task<int> CreateAsync(PosApi.Models.User user, System.Data.IDbConnection? connection = null, System.Data.IDbTransaction? transaction = null);
    Task<bool> UpdateAsync(PosApi.Models.User user);
    Task<bool> UpdateLastLoginAsync(int userId);
    Task<bool> ChangePasswordAsync(int userId, string newPasswordHash);
    Task<IEnumerable<PosApi.Models.User>> GetAllAsync();
    Task<int> CreateRefreshTokenAsync(int userId, string token, DateTime expiresAt);
    Task<RefreshToken?> GetRefreshTokenAsync(string token);
    Task<bool> RevokeRefreshTokenAsync(string token, string? replacedByToken = null);
    Task<bool> RevokeAllUserRefreshTokensAsync(int userId);
}

public class RefreshToken
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? RevokedAt { get; set; }
    public string? ReplacedByToken { get; set; }
}
