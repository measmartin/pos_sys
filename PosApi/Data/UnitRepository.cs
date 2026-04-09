using Dapper;
using PosApi.Models;

namespace PosApi.Data;

public class UnitRepository : IUnitRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public UnitRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<Unit>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Unit WHERE is_active = 1 ORDER BY unit_name";
        return await connection.QueryAsync<Unit>(sql);
    }

    public async Task<Unit?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Unit WHERE unit_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<Unit>(sql, new { Id = id });
    }

    public async Task<int> CreateAsync(Unit unit)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            INSERT INTO Unit (unit_name, unit_code, description, is_active, created_at)
            VALUES (@UnitName, @UnitCode, @Description, @IsActive, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        return await connection.ExecuteScalarAsync<int>(sql, unit);
    }

    public async Task<bool> UpdateAsync(Unit unit)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE Unit
            SET unit_name = @UnitName,
                unit_code = @UnitCode,
                description = @Description,
                is_active = @IsActive
            WHERE unit_id = @UnitId";
        var rowsAffected = await connection.ExecuteAsync(sql, unit);
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "UPDATE Unit SET is_active = 0 WHERE unit_id = @Id";
        var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
        return rowsAffected > 0;
    }
}
