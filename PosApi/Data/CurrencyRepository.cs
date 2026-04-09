using Dapper;
using PosApi.Models;

namespace PosApi.Data;

public class CurrencyRepository : ICurrencyRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public CurrencyRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<Currency>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Currency WHERE is_active = 1 ORDER BY currency_name";
        return await connection.QueryAsync<Currency>(sql);
    }

    public async Task<Currency?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Currency WHERE currency_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<Currency>(sql, new { Id = id });
    }

    public async Task<Currency?> GetByCodeAsync(string code)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Currency WHERE currency_code = @Code AND is_active = 1";
        return await connection.QueryFirstOrDefaultAsync<Currency>(sql, new { Code = code });
    }

    public async Task<Currency?> GetBaseCurrencyAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT TOP 1 *
            FROM Currency
            WHERE is_base_currency = 1 AND is_active = 1
            ORDER BY currency_id";
        return await connection.QueryFirstOrDefaultAsync<Currency>(sql);
    }

    public async Task<int> CreateAsync(Currency currency)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            INSERT INTO Currency (currency_code, currency_name, currency_symbol, exchange_rate, is_base_currency, is_active, created_at)
            VALUES (@CurrencyCode, @CurrencyName, @CurrencySymbol, @ExchangeRate, @IsBaseCurrency, @IsActive, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        return await connection.ExecuteScalarAsync<int>(sql, currency);
    }

    public async Task<bool> UpdateAsync(Currency currency)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE Currency
            SET currency_code = @CurrencyCode,
                currency_name = @CurrencyName,
                currency_symbol = @CurrencySymbol,
                exchange_rate = @ExchangeRate,
                is_base_currency = @IsBaseCurrency,
                is_active = @IsActive,
                updated_at = @UpdatedAt
            WHERE currency_id = @CurrencyId";
        var rowsAffected = await connection.ExecuteAsync(sql, currency);
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "UPDATE Currency SET is_active = 0, updated_at = GETDATE() WHERE currency_id = @Id";
        var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
        return rowsAffected > 0;
    }
}
