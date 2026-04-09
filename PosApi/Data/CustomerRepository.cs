using Dapper;
using PosApi.Models;

namespace PosApi.Data;

public class CustomerRepository : ICustomerRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public CustomerRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<Customer>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Customer WHERE is_active = 1 ORDER BY customer_name";
        return await connection.QueryAsync<Customer>(sql);
    }

    public async Task<(IEnumerable<Customer> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        bool? isActive)
    {
        using var connection = _connectionFactory.CreateConnection();
        var offset = (page - 1) * pageSize;

        var parameters = new
        {
            Search = string.IsNullOrWhiteSpace(search) ? null : search.Trim(),
            IsActive = isActive,
            Offset = offset,
            PageSize = pageSize
        };

        const string whereClause = @"
            WHERE (@IsActive IS NULL OR is_active = @IsActive)
              AND (
                    @Search IS NULL
                    OR customer_name LIKE '%' + @Search + '%'
                    OR phone_number LIKE '%' + @Search + '%'
                    OR email LIKE '%' + @Search + '%'
                    OR city LIKE '%' + @Search + '%'
                    OR country LIKE '%' + @Search + '%'
                  )";

        var itemsSql = $@"
            SELECT *
            FROM Customer
            {whereClause}
            ORDER BY customer_name
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

        var countSql = $@"
            SELECT COUNT(1)
            FROM Customer
            {whereClause};";

        var items = await connection.QueryAsync<Customer>(itemsSql, parameters);
        var totalCount = await connection.ExecuteScalarAsync<int>(countSql, parameters);
        return (items, totalCount);
    }

    public async Task<Customer?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Customer WHERE customer_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<Customer>(sql, new { Id = id });
    }

    public async Task<Customer?> GetByPhoneAsync(string phone)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Customer WHERE phone_number = @Phone AND is_active = 1";
        return await connection.QueryFirstOrDefaultAsync<Customer>(sql, new { Phone = phone });
    }

    public async Task<int> CreateAsync(Customer customer)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            INSERT INTO Customer (customer_name, phone_number, email, location, city, country, notes, is_active, created_at)
            VALUES (@CustomerName, @PhoneNumber, @Email, @Location, @City, @Country, @Notes, @IsActive, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        return await connection.ExecuteScalarAsync<int>(sql, customer);
    }

    public async Task<bool> UpdateAsync(Customer customer)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE Customer
            SET customer_name = @CustomerName,
                phone_number = @PhoneNumber,
                email = @Email,
                location = @Location,
                city = @City,
                country = @Country,
                notes = @Notes,
                is_active = @IsActive,
                updated_at = @UpdatedAt
            WHERE customer_id = @CustomerId";
        var rowsAffected = await connection.ExecuteAsync(sql, customer);
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "UPDATE Customer SET is_active = 0, updated_at = GETDATE() WHERE customer_id = @Id";
        var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
        return rowsAffected > 0;
    }
}
