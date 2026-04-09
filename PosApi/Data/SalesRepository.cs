using Dapper;
using PosApi.Models;

namespace PosApi.Data;

public class SalesRepository : ISalesRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public SalesRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<Sales>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT s.*, cu.customer_name AS CustomerName, cr.currency_code AS CurrencyCode, cr.currency_symbol AS CurrencySymbol
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            ORDER BY s.sale_date DESC, s.sale_number DESC";
        return await connection.QueryAsync<Sales>(sql);
    }

    public async Task<(IEnumerable<Sales> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        string? status)
    {
        using var connection = _connectionFactory.CreateConnection();
        var offset = (page - 1) * pageSize;

        var parameters = new
        {
            Search = string.IsNullOrWhiteSpace(search) ? null : search.Trim(),
            Status = string.IsNullOrWhiteSpace(status) ? null : status.Trim(),
            Offset = offset,
            PageSize = pageSize
        };

        const string whereClause = @"
            WHERE (@Status IS NULL OR s.payment_status = @Status)
              AND (
                    @Search IS NULL
                    OR s.sale_number LIKE '%' + @Search + '%'
                    OR cu.customer_name LIKE '%' + @Search + '%'
                                        OR s.phone_number LIKE '%' + @Search + '%'
                  )";

        var itemsSql = $@"
            SELECT s.*, cu.customer_name AS CustomerName, cr.currency_code AS CurrencyCode, cr.currency_symbol AS CurrencySymbol
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            {whereClause}
            ORDER BY s.sale_date DESC, s.sale_number DESC
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

        var countSql = $@"
            SELECT COUNT(1)
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            {whereClause};";

        var items = await connection.QueryAsync<Sales>(itemsSql, parameters);
        var totalCount = await connection.ExecuteScalarAsync<int>(countSql, parameters);

        return (items, totalCount);
    }

    public async Task<Sales?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT s.*, cu.customer_name AS CustomerName, cr.currency_code AS CurrencyCode, cr.currency_symbol AS CurrencySymbol
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            WHERE s.sale_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<Sales>(sql, new { Id = id });
    }

    public async Task<Sales?> GetBySaleNumberAsync(string saleNumber)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT s.*, cu.customer_name AS CustomerName, cr.currency_code AS CurrencyCode, cr.currency_symbol AS CurrencySymbol
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            WHERE s.sale_number = @SaleNumber";
        return await connection.QueryFirstOrDefaultAsync<Sales>(sql, new { SaleNumber = saleNumber });
    }

    public async Task<IEnumerable<Sales>> GetByDateRangeAsync(DateTime startDate, DateTime endDate)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT s.*, cu.customer_name AS CustomerName, cr.currency_code AS CurrencyCode, cr.currency_symbol AS CurrencySymbol
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            WHERE s.sale_date >= @StartDate AND s.sale_date <= @EndDate
            ORDER BY s.sale_date DESC, s.sale_number DESC";
        return await connection.QueryAsync<Sales>(sql, new { StartDate = startDate, EndDate = endDate });
    }

    public async Task<IEnumerable<Sales>> GetByCustomerIdAsync(int customerId)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT s.*, cu.customer_name AS CustomerName, cr.currency_code AS CurrencyCode, cr.currency_symbol AS CurrencySymbol
            FROM Sales s
            LEFT JOIN Customer cu ON s.customer_id = cu.customer_id
            LEFT JOIN Currency cr ON s.currency_id = cr.currency_id
            WHERE s.customer_id = @CustomerId
            ORDER BY s.sale_date DESC, s.sale_number DESC";
        return await connection.QueryAsync<Sales>(sql, new { CustomerId = customerId });
    }

    public async Task<string> GetNextSaleNumberAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        int currentYear = DateTime.Now.Year;
        
        var parameters = new Dapper.DynamicParameters();
        parameters.Add("@Year", currentYear, System.Data.DbType.Int32);
        parameters.Add("@SaleNumber", dbType: System.Data.DbType.String, direction: System.Data.ParameterDirection.Output, size: 20);
        parameters.Add("@Sequence", dbType: System.Data.DbType.Int32, direction: System.Data.ParameterDirection.Output);
        
        await connection.ExecuteAsync(
            "sp_GetNextSaleNumber",
            parameters,
            commandType: System.Data.CommandType.StoredProcedure
        );
        
        var saleNumber = parameters.Get<string>("@SaleNumber");
        return saleNumber ?? $"{currentYear}-0001";
    }

    public async Task<int> CreateAsync(Sales sales)
    {
        using var connection = _connectionFactory.CreateConnection();
        
        // Generate sale number if not provided
        if (string.IsNullOrEmpty(sales.SaleNumber))
        {
            sales.SaleNumber = await GetNextSaleNumberAsync();
        }
        
        // Extract year and sequence from sale number (format: YYYY-NNNN)
        var parts = sales.SaleNumber.Split('-');
        sales.SaleYear = int.Parse(parts[0]);
        sales.SaleSequence = int.Parse(parts[1]);
        
        const string sql = @"
            INSERT INTO Sales (sale_number, sale_year, sale_sequence, sale_date, customer_id, phone_number, currency_id, 
                             subtotal_amount, discount_amount, total_amount, amount_paid, change_amount,
                             payment_status, payment_method, payment_date, notes, created_by, created_at)
            VALUES (@SaleNumber, @SaleYear, @SaleSequence, @SaleDate, @CustomerId, @PhoneNumber, @CurrencyId, 
                    @Subtotal, @TotalDiscount, @TotalAmount, @AmountPaid, @ChangeAmount,
                    @PaymentStatus, @PaymentMethod, @PaymentDate, @Notes, @CreatedBy, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        return await connection.ExecuteScalarAsync<int>(sql, sales);
    }

    public async Task<bool> UpdateAsync(Sales sales)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE Sales
            SET sale_date = @SaleDate,
                customer_id = @CustomerId,
                phone_number = @PhoneNumber,
                currency_id = @CurrencyId,
                subtotal_amount = @Subtotal,
                discount_amount = @TotalDiscount,
                total_amount = @TotalAmount,
                amount_paid = @AmountPaid,
                change_amount = @ChangeAmount,
                payment_status = @PaymentStatus,
                payment_method = @PaymentMethod,
                payment_date = @PaymentDate,
                notes = @Notes,
                updated_at = @UpdatedAt
            WHERE sale_id = @SaleId";
        var rowsAffected = await connection.ExecuteAsync(sql, sales);
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "DELETE FROM Sales WHERE sale_id = @Id";
        var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
        return rowsAffected > 0;
    }
}
