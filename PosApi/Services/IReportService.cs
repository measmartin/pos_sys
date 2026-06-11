using PosApi.DTOs;

namespace PosApi.Services;

public interface IReportService
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
