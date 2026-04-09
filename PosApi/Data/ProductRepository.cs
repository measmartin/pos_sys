using Dapper;
using PosApi.Models;

namespace PosApi.Data;

public class ProductRepository : IProductRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public ProductRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<Product>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT p.*, c.category_name AS CategoryName, u.unit_name AS BaseUnitName
            FROM Product p
            LEFT JOIN Category c ON p.category_id = c.category_id
            LEFT JOIN Unit u ON p.base_unit_id = u.unit_id
            WHERE p.is_active = 1
            ORDER BY p.product_name";
        return await connection.QueryAsync<Product>(sql);
    }

    public async Task<(IEnumerable<Product> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        int? categoryId,
        bool? isActive)
    {
        using var connection = _connectionFactory.CreateConnection();
        var offset = (page - 1) * pageSize;

        var parameters = new
        {
            Search = string.IsNullOrWhiteSpace(search) ? null : search.Trim(),
            CategoryId = categoryId,
            IsActive = isActive,
            Offset = offset,
            PageSize = pageSize
        };

        const string whereClause = @"
            WHERE (@IsActive IS NULL OR p.is_active = @IsActive)
              AND (@CategoryId IS NULL OR p.category_id = @CategoryId)
              AND (
                    @Search IS NULL
                    OR p.product_name LIKE '%' + @Search + '%'
                    OR p.product_code LIKE '%' + @Search + '%'
                    OR c.category_name LIKE '%' + @Search + '%'
                  )";

        var itemsSql = $@"
            SELECT p.*, c.category_name AS CategoryName, u.unit_name AS BaseUnitName
            FROM Product p
            LEFT JOIN Category c ON p.category_id = c.category_id
            LEFT JOIN Unit u ON p.base_unit_id = u.unit_id
            {whereClause}
            ORDER BY p.product_name
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

        var countSql = $@"
            SELECT COUNT(1)
            FROM Product p
            LEFT JOIN Category c ON p.category_id = c.category_id
            {whereClause};";

        var items = await connection.QueryAsync<Product>(itemsSql, parameters);
        var totalCount = await connection.ExecuteScalarAsync<int>(countSql, parameters);

        return (items, totalCount);
    }

    public async Task<Product?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT p.*, c.category_name AS CategoryName, u.unit_name AS BaseUnitName
            FROM Product p
            LEFT JOIN Category c ON p.category_id = c.category_id
            LEFT JOIN Unit u ON p.base_unit_id = u.unit_id
            WHERE p.product_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<Product>(sql, new { Id = id });
    }

    public async Task<IEnumerable<Product>> GetByCategoryIdAsync(int categoryId)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT p.*, c.category_name AS CategoryName, u.unit_name AS BaseUnitName
            FROM Product p
            LEFT JOIN Category c ON p.category_id = c.category_id
            LEFT JOIN Unit u ON p.base_unit_id = u.unit_id
            WHERE p.category_id = @CategoryId AND p.is_active = 1
            ORDER BY p.product_name";
        return await connection.QueryAsync<Product>(sql, new { CategoryId = categoryId });
    }

    public async Task<int> CreateAsync(Product product)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            INSERT INTO Product (product_code, product_name, category_id, base_unit_id, description, is_active, created_at)
            VALUES (@ProductCode, @ProductName, @CategoryId, @BaseUnitId, @Description, @IsActive, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        return await connection.ExecuteScalarAsync<int>(sql, product);
    }

    public async Task<bool> UpdateAsync(Product product)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE Product
            SET product_code = @ProductCode,
                product_name = @ProductName,
                category_id = @CategoryId,
                base_unit_id = @BaseUnitId,
                description = @Description,
                is_active = @IsActive,
                updated_at = @UpdatedAt
            WHERE product_id = @ProductId";
        var rowsAffected = await connection.ExecuteAsync(sql, product);
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "UPDATE Product SET is_active = 0, updated_at = GETDATE() WHERE product_id = @Id";
        var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
        return rowsAffected > 0;
    }
}
