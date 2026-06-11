using Dapper;
using PosApi.DTOs;

namespace PosApi.Data;

public class ReportRepository : IReportRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public ReportRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<SalesSummaryDto> GetSalesSummaryAsync(ReportQueryParams queryParams)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);

        var sql = @"
            SELECT 
                ISNULL(SUM(s.total_amount), 0) AS TotalRevenue,
                ISNULL(SUM(s.discount_amount), 0) AS TotalDiscount,
                ISNULL(SUM(s.amount_paid), 0) AS TotalAmountPaid,
                ISNULL(SUM(s.change_amount), 0) AS TotalChange,
                COUNT(1) AS TransactionCount,
                CASE WHEN COUNT(1) > 0 THEN ISNULL(SUM(s.total_amount), 0) / COUNT(1) ELSE 0 END AS AvgOrderValue,
                @StartDate AS PeriodStart,
                @EndDate AS PeriodEnd,
                @CurrencyCode AS CurrencyCode,
                @CurrencySymbol AS CurrencySymbol
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause;

        parameters.Add("@StartDate", queryParams.StartDate);
        parameters.Add("@EndDate", queryParams.EndDate);
        parameters.Add("@CurrencyCode", queryParams.CurrencyId.HasValue ? "Filtered" : "All");
        parameters.Add("@CurrencySymbol", "");

        return await connection.QueryFirstOrDefaultAsync<SalesSummaryDto>(sql, parameters)
               ?? new SalesSummaryDto { PeriodStart = queryParams.StartDate, PeriodEnd = queryParams.EndDate };
    }

    public async Task<IEnumerable<DailySalesDto>> GetDailySalesAsync(ReportQueryParams queryParams)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);

        var sql = @"
            SELECT 
                CAST(s.sale_date AS DATE) AS Date,
                ISNULL(SUM(s.total_amount), 0) AS Revenue,
                ISNULL(SUM(s.discount_amount), 0) AS Discount,
                COUNT(1) AS TransactionCount,
                CASE WHEN COUNT(1) > 0 THEN ISNULL(SUM(s.total_amount), 0) / COUNT(1) ELSE 0 END AS AvgOrderValue
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            GROUP BY CAST(s.sale_date AS DATE)
            ORDER BY Date";

        return await connection.QueryAsync<DailySalesDto>(sql, parameters);
    }

    public async Task<IEnumerable<MonthlySalesDto>> GetMonthlySalesAsync(ReportQueryParams queryParams)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);

        var sql = @"
            SELECT 
                YEAR(s.sale_date) AS Year,
                MONTH(s.sale_date) AS Month,
                FORMAT(MONTH(s.sale_date), '00') + '-' + DATENAME(MONTH, DATEADD(MONTH, MONTH(s.sale_date) - 1, 0)) AS MonthLabel,
                ISNULL(SUM(s.total_amount), 0) AS Revenue,
                ISNULL(SUM(s.discount_amount), 0) AS Discount,
                COUNT(1) AS TransactionCount,
                CASE WHEN COUNT(1) > 0 THEN ISNULL(SUM(s.total_amount), 0) / COUNT(1) ELSE 0 END AS AvgOrderValue
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            GROUP BY YEAR(s.sale_date), MONTH(s.sale_date)
            ORDER BY Year, Month";

        return await connection.QueryAsync<MonthlySalesDto>(sql, parameters);
    }

    public async Task<IEnumerable<HourlySalesDto>> GetHourlySalesAsync(ReportQueryParams queryParams)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);

        var sql = @"
            SELECT 
                DATEPART(HOUR, s.sale_date) AS Hour,
                RIGHT('0' + CAST(DATEPART(HOUR, s.sale_date) AS VARCHAR(2)), 2) + ':00' AS HourLabel,
                ISNULL(SUM(s.total_amount), 0) AS Revenue,
                COUNT(1) AS TransactionCount
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            GROUP BY DATEPART(HOUR, s.sale_date)
            ORDER BY Hour";

        return await connection.QueryAsync<HourlySalesDto>(sql, parameters);
    }

    public async Task<IEnumerable<TopProductDto>> GetTopProductsAsync(ReportQueryParams queryParams, int topN = 20)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);
        parameters.Add("@TopN", topN);

        var sql = @"
            SELECT TOP (@TopN)
                p.product_id AS ProductId,
                p.product_name AS ProductName,
                c.category_name AS CategoryName,
                ISNULL(SUM(si.quantity), 0) AS TotalQuantity,
                ISNULL(SUM(si.line_total), 0) AS TotalRevenue,
                COUNT(DISTINCT si.sale_id) AS SaleCount
            FROM SalesItem si
            INNER JOIN Sales s ON si.sale_id = s.sale_id
            INNER JOIN Product p ON si.product_id = p.product_id
            LEFT JOIN Category c ON p.category_id = c.category_id
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            GROUP BY p.product_id, p.product_name, c.category_name
            ORDER BY TotalRevenue DESC";

        return await connection.QueryAsync<TopProductDto>(sql, parameters);
    }

    public async Task<IEnumerable<CategorySalesDto>> GetCategorySalesAsync(ReportQueryParams queryParams)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);

        var sql = @"
            SELECT 
                c.category_id AS CategoryId,
                ISNULL(c.category_name, 'Uncategorized') AS CategoryName,
                ISNULL(SUM(si.line_total), 0) AS TotalRevenue,
                COUNT(DISTINCT s.sale_id) AS TransactionCount,
                0 AS Percentage
            FROM SalesItem si
            INNER JOIN Sales s ON si.sale_id = s.sale_id
            INNER JOIN Product p ON si.product_id = p.product_id
            LEFT JOIN Category c ON p.category_id = c.category_id
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            GROUP BY c.category_id, c.category_name
            ORDER BY TotalRevenue DESC";

        var results = (await connection.QueryAsync<CategorySalesDto>(sql, parameters)).ToList();
        var total = results.Sum(r => r.TotalRevenue);
        if (total > 0)
        {
            foreach (var r in results)
                r.Percentage = Math.Round((r.TotalRevenue / total) * 100, 2);
        }
        return results;
    }

    public async Task<IEnumerable<TopCustomerDto>> GetTopCustomersAsync(ReportQueryParams queryParams, int topN = 20)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);
        parameters.Add("@TopN", topN);

        var sql = @"
            SELECT TOP (@TopN)
                s.customer_id AS CustomerId,
                ISNULL(cu.customer_name, 'Walk-in') AS CustomerName,
                MAX(s.phone_number) AS PhoneNumber,
                ISNULL(SUM(s.total_amount), 0) AS TotalSpent,
                COUNT(1) AS VisitCount,
                CASE WHEN COUNT(1) > 0 THEN ISNULL(SUM(s.total_amount), 0) / COUNT(1) ELSE 0 END AS AvgOrderValue
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            GROUP BY s.customer_id, cu.customer_name
            ORDER BY TotalSpent DESC";

        return await connection.QueryAsync<TopCustomerDto>(sql, parameters);
    }

    public async Task<IEnumerable<PaymentBreakdownDto>> GetPaymentBreakdownAsync(ReportQueryParams queryParams)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);

        var sql = @"
            SELECT 
                s.payment_status AS PaymentStatus,
                COUNT(1) AS Count,
                ISNULL(SUM(s.total_amount), 0) AS TotalAmount,
                0 AS Percentage
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            GROUP BY s.payment_status
            ORDER BY TotalAmount DESC";

        var results = (await connection.QueryAsync<PaymentBreakdownDto>(sql, parameters)).ToList();
        var total = results.Sum(r => r.TotalAmount);
        if (total > 0)
        {
            foreach (var r in results)
                r.Percentage = Math.Round((r.TotalAmount / total) * 100, 2);
        }
        return results;
    }

    public async Task<IEnumerable<SalesDetailsExportDto>> GetSalesDetailsAsync(ReportQueryParams queryParams)
    {
        using var connection = _connectionFactory.CreateConnection();
        var (whereClause, parameters) = BuildBaseQuery(queryParams);

        var sql = @"
            SELECT 
                s.sale_number AS SaleNumber,
                s.sale_date AS SaleDate,
                cu.customer_name AS CustomerName,
                s.phone_number AS PhoneNumber,
                cr.currency_code AS CurrencyCode,
                s.subtotal_amount AS Subtotal,
                s.discount_amount AS TotalDiscount,
                s.total_amount AS TotalAmount,
                s.amount_paid AS AmountPaid,
                s.change_amount AS ChangeAmount,
                s.payment_status AS PaymentStatus,
                s.sale_status AS SaleStatus,
                s.notes AS Notes
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            " + whereClause + @"
            ORDER BY s.sale_date DESC, s.sale_number DESC";

        return await connection.QueryAsync<SalesDetailsExportDto>(sql, parameters);
    }

    public async Task<IEnumerable<CurrencyInfoDto>> GetAllCurrenciesAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT currency_id AS CurrencyId, currency_code AS CurrencyCode, 
                   currency_symbol AS CurrencySymbol, exchange_rate AS ExchangeRate,
                   is_base_currency AS IsBaseCurrency
            FROM Currency WHERE is_active = 1 ORDER BY is_base_currency DESC, currency_code";
        return await connection.QueryAsync<CurrencyInfoDto>(sql);
    }

    private (string WhereClause, DynamicParameters Parameters) BuildBaseQuery(ReportQueryParams queryParams)
    {
        var conditions = new List<string> { "s.sale_date >= @StartDate AND s.sale_date <= @EndDate" };
        var parameters = new DynamicParameters();
        parameters.Add("@StartDate", queryParams.StartDate);
        parameters.Add("@EndDate", queryParams.EndDate);

        if (queryParams.CurrencyId.HasValue)
        {
            conditions.Add("s.currency_id = @CurrencyId");
            parameters.Add("@CurrencyId", queryParams.CurrencyId.Value);
        }

        if (queryParams.CustomerId.HasValue)
        {
            conditions.Add("s.customer_id = @CustomerId");
            parameters.Add("@CustomerId", queryParams.CustomerId.Value);
        }

        if (queryParams.CategoryId.HasValue)
        {
            conditions.Add("si.product_id IN (SELECT product_id FROM Product WHERE category_id = @CategoryId)");
            parameters.Add("@CategoryId", queryParams.CategoryId.Value);
        }

        if (!string.IsNullOrWhiteSpace(queryParams.SaleStatus))
        {
            conditions.Add("s.sale_status = @SaleStatus");
            parameters.Add("@SaleStatus", queryParams.SaleStatus.Trim());
        }

        var whereClause = "WHERE " + string.Join(" AND ", conditions);
        return (whereClause, parameters);
    }
}
