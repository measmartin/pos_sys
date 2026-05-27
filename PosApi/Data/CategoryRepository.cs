using Dapper;
using PosApi.Models;

namespace PosApi.Data;

public class CategoryRepository : ICategoryRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public CategoryRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<Category>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Category WHERE is_active = 1 ORDER BY category_name";
        return await connection.QueryAsync<Category>(sql);
    }

    public async Task<(IEnumerable<Category> Items, int TotalCount)> GetPagedAsync(
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
                    OR category_name LIKE '%' + @Search + '%'
                    OR description LIKE '%' + @Search + '%'
                  )";

        var itemsSql = $@"
            SELECT *
            FROM Category
            {whereClause}
            ORDER BY category_name
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

        var countSql = $@"
            SELECT COUNT(1)
            FROM Category
            {whereClause};";

        var items = await connection.QueryAsync<Category>(itemsSql, parameters);
        var totalCount = await connection.ExecuteScalarAsync<int>(countSql, parameters);
        return (items, totalCount);
    }

    public async Task<Category?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT * FROM Category WHERE category_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<Category>(sql, new { Id = id });
    }

    public async Task<int> CreateAsync(Category category)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            INSERT INTO Category (category_name, description, is_active, created_at)
            VALUES (@CategoryName, @Description, @IsActive, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        return await connection.ExecuteScalarAsync<int>(sql, category);
    }

    public async Task<bool> UpdateAsync(Category category)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE Category
            SET category_name = @CategoryName,
                description = @Description,
                is_active = @IsActive,
                updated_at = @UpdatedAt
            WHERE category_id = @CategoryId";
        var rowsAffected = await connection.ExecuteAsync(sql, category);
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "UPDATE Category SET is_active = 0, updated_at = GETDATE() WHERE category_id = @Id";
        var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
        return rowsAffected > 0;
    }
}
