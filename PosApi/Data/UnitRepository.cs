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

    public async Task<(IEnumerable<Unit> Items, int TotalCount)> GetPagedAsync(
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
                    OR unit_name LIKE '%' + @Search + '%'
                    OR unit_code LIKE '%' + @Search + '%'
                  )";

        var itemsSql = $@"
            SELECT *
            FROM Unit
            {whereClause}
            ORDER BY unit_name
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

        var countSql = $@"
            SELECT COUNT(1)
            FROM Unit
            {whereClause};";

        var items = await connection.QueryAsync<Unit>(itemsSql, parameters);
        var totalCount = await connection.ExecuteScalarAsync<int>(countSql, parameters);
        return (items, totalCount);
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
