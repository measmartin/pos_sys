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
