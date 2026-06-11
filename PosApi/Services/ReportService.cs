using PosApi.Data;
using PosApi.DTOs;

namespace PosApi.Services;

public class ReportService : IReportService
{
    private readonly IReportRepository _repository;

    public ReportService(IReportRepository repository)
    {
        _repository = repository;
    }

    public Task<SalesSummaryDto> GetSalesSummaryAsync(ReportQueryParams queryParams) =>
        _repository.GetSalesSummaryAsync(queryParams);

    public Task<IEnumerable<DailySalesDto>> GetDailySalesAsync(ReportQueryParams queryParams) =>
        _repository.GetDailySalesAsync(queryParams);

    public Task<IEnumerable<MonthlySalesDto>> GetMonthlySalesAsync(ReportQueryParams queryParams) =>
        _repository.GetMonthlySalesAsync(queryParams);

    public Task<IEnumerable<HourlySalesDto>> GetHourlySalesAsync(ReportQueryParams queryParams) =>
        _repository.GetHourlySalesAsync(queryParams);

    public Task<IEnumerable<TopProductDto>> GetTopProductsAsync(ReportQueryParams queryParams, int topN = 20) =>
        _repository.GetTopProductsAsync(queryParams, topN);

    public Task<IEnumerable<CategorySalesDto>> GetCategorySalesAsync(ReportQueryParams queryParams) =>
        _repository.GetCategorySalesAsync(queryParams);

    public Task<IEnumerable<TopCustomerDto>> GetTopCustomersAsync(ReportQueryParams queryParams, int topN = 20) =>
        _repository.GetTopCustomersAsync(queryParams, topN);

    public Task<IEnumerable<PaymentBreakdownDto>> GetPaymentBreakdownAsync(ReportQueryParams queryParams) =>
        _repository.GetPaymentBreakdownAsync(queryParams);

    public Task<IEnumerable<SalesDetailsExportDto>> GetSalesDetailsAsync(ReportQueryParams queryParams) =>
        _repository.GetSalesDetailsAsync(queryParams);

    public Task<IEnumerable<CurrencyInfoDto>> GetAllCurrenciesAsync() =>
        _repository.GetAllCurrenciesAsync();
}
