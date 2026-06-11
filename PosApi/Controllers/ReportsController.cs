using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class ReportsController : ControllerBase
{
    private readonly IReportService _service;

    public ReportsController(IReportService service)
    {
        _service = service;
    }

    [HttpGet("sales/summary")]
    public async Task<ActionResult<SalesSummaryDto>> GetSalesSummary([FromQuery] ReportQueryParams queryParams)
    {
        var result = await _service.GetSalesSummaryAsync(queryParams);
        return Ok(result);
    }

    [HttpGet("sales/daily")]
    public async Task<ActionResult<IEnumerable<DailySalesDto>>> GetDailySales([FromQuery] ReportQueryParams queryParams)
    {
        var result = await _service.GetDailySalesAsync(queryParams);
        return Ok(result);
    }

    [HttpGet("sales/monthly")]
    public async Task<ActionResult<IEnumerable<MonthlySalesDto>>> GetMonthlySales([FromQuery] ReportQueryParams queryParams)
    {
        var result = await _service.GetMonthlySalesAsync(queryParams);
        return Ok(result);
    }

    [HttpGet("sales/hourly")]
    public async Task<ActionResult<IEnumerable<HourlySalesDto>>> GetHourlySales([FromQuery] ReportQueryParams queryParams)
    {
        var result = await _service.GetHourlySalesAsync(queryParams);
        return Ok(result);
    }

    [HttpGet("products/top")]
    public async Task<ActionResult<IEnumerable<TopProductDto>>> GetTopProducts(
        [FromQuery] ReportQueryParams queryParams,
        [FromQuery] int topN = 20)
    {
        var result = await _service.GetTopProductsAsync(queryParams, topN);
        return Ok(result);
    }

    [HttpGet("products/category")]
    public async Task<ActionResult<IEnumerable<CategorySalesDto>>> GetCategorySales([FromQuery] ReportQueryParams queryParams)
    {
        var result = await _service.GetCategorySalesAsync(queryParams);
        return Ok(result);
    }

    [HttpGet("customers/top")]
    public async Task<ActionResult<IEnumerable<TopCustomerDto>>> GetTopCustomers(
        [FromQuery] ReportQueryParams queryParams,
        [FromQuery] int topN = 20)
    {
        var result = await _service.GetTopCustomersAsync(queryParams, topN);
        return Ok(result);
    }

    [HttpGet("payments/breakdown")]
    public async Task<ActionResult<IEnumerable<PaymentBreakdownDto>>> GetPaymentBreakdown([FromQuery] ReportQueryParams queryParams)
    {
        var result = await _service.GetPaymentBreakdownAsync(queryParams);
        return Ok(result);
    }

    [HttpGet("sales/export")]
    public async Task<ActionResult<IEnumerable<SalesDetailsExportDto>>> GetSalesForExport([FromQuery] ReportQueryParams queryParams)
    {
        var result = await _service.GetSalesDetailsAsync(queryParams);
        return Ok(result);
    }

    [HttpGet("currencies")]
    public async Task<ActionResult<IEnumerable<CurrencyInfoDto>>> GetCurrencies()
    {
        var result = await _service.GetAllCurrenciesAsync();
        return Ok(result);
    }
}
