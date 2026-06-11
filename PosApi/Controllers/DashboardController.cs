using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Authorize]
[Route("api/dashboard")]
public class DashboardController : ControllerBase
{
    private readonly IReportService _reportService;
    private readonly ISalesService _salesService;
    private readonly IProductService _productService;
    private readonly ICustomerService _customerService;

    public DashboardController(
        IReportService reportService,
        ISalesService salesService,
        IProductService productService,
        ICustomerService customerService)
    {
        _reportService = reportService;
        _salesService = salesService;
        _productService = productService;
        _customerService = customerService;
    }

    [HttpGet("stats")]
    public async Task<ActionResult<object>> GetStats()
    {
        var today = DateTime.Today;
        var yesterday = today.AddDays(-1);
        var startOfMonth = new DateTime(today.Year, today.Month, 1);
        var endOfMonth = startOfMonth.AddMonths(1).AddDays(-1);

        // Use aggregate queries instead of loading entire tables
        var (todayTotal, todayCount) = await _salesService.GetSalesSummaryAsync(today, today.AddDays(1));
        var (yesterdayTotal, _) = await _salesService.GetSalesSummaryAsync(yesterday, yesterday.AddDays(1));
        var (monthlyTotal, monthlyCount) = await _salesService.GetSalesSummaryAsync(startOfMonth, endOfMonth.AddDays(1));

        var productCount = await _productService.GetCountAsync();
        var customerCount = await _customerService.GetCountAsync();

        // Recent sales (last 5) - still need to load for display
        var recentSales = await _salesService.GetByDateRangeAsync(today, today.AddDays(1));
        var recentSalesDtos = recentSales
            .OrderByDescending(s => s.CreatedAt)
            .Take(5)
            .Select(s => new
            {
                s.SaleId,
                s.SaleNumber,
                s.TotalAmount,
                s.PaymentStatus,
                s.SaleStatus,
                s.CreatedAt
            });

        return Ok(new
        {
            today = new
            {
                totalSales = todayTotal,
                transactionCount = todayCount,
                vsYesterday = yesterdayTotal > 0 ? ((todayTotal - yesterdayTotal) / yesterdayTotal) * 100 : 0
            },
            month = new
            {
                totalSales = monthlyTotal,
                transactionCount = monthlyCount
            },
            products = new
            {
                total = productCount
            },
            customers = new
            {
                total = customerCount
            },
            recentSales = recentSalesDtos
        });
    }
}
