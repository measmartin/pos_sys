using Dapper;
using PosApi.Models;

namespace PosApi.Data;

public class ProductUnitRepository : IProductUnitRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public ProductUnitRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<ProductUnit>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT pu.*, p.product_name AS ProductName, u.unit_name AS UnitName, u.unit_code AS UnitCode
            FROM ProductUnit pu
            INNER JOIN Product p ON pu.product_id = p.product_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            WHERE pu.is_active = 1
            ORDER BY p.product_name, u.unit_name";
        return await connection.QueryAsync<ProductUnit>(sql);
    }

    public async Task<(IEnumerable<ProductUnit> Items, int TotalCount)> GetPagedAsync(
        int page,
        int pageSize,
        string? search,
        int? productId,
        bool? isActive)
    {
        using var connection = _connectionFactory.CreateConnection();
        var offset = (page - 1) * pageSize;

        var parameters = new
        {
            Search = string.IsNullOrWhiteSpace(search) ? null : search.Trim(),
            ProductId = productId,
            IsActive = isActive,
            Offset = offset,
            PageSize = pageSize
        };

        const string whereClause = @"
            WHERE (@IsActive IS NULL OR pu.is_active = @IsActive)
              AND (@ProductId IS NULL OR pu.product_id = @ProductId)
              AND (
                    @Search IS NULL
                    OR p.product_name LIKE '%' + @Search + '%'
                    OR u.unit_name LIKE '%' + @Search + '%'
                    OR u.unit_code LIKE '%' + @Search + '%'
                  )";

        var itemsSql = $@"
            SELECT pu.*, p.product_name AS ProductName, u.unit_name AS UnitName, u.unit_code AS UnitCode
            FROM ProductUnit pu
            INNER JOIN Product p ON pu.product_id = p.product_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            {whereClause}
            ORDER BY p.product_name, u.unit_name
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;";

        var countSql = $@"
            SELECT COUNT(1)
            FROM ProductUnit pu
            INNER JOIN Product p ON pu.product_id = p.product_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            {whereClause};";

        var items = await connection.QueryAsync<ProductUnit>(itemsSql, parameters);
        var totalCount = await connection.ExecuteScalarAsync<int>(countSql, parameters);
        return (items, totalCount);
    }

    public async Task<ProductUnit?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT pu.*, p.product_name AS ProductName, u.unit_name AS UnitName, u.unit_code AS UnitCode
            FROM ProductUnit pu
            INNER JOIN Product p ON pu.product_id = p.product_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            WHERE pu.product_unit_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<ProductUnit>(sql, new { Id = id });
    }

    public async Task<IEnumerable<ProductUnit>> GetByProductIdAsync(int productId)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT pu.*, p.product_name AS ProductName, u.unit_name AS UnitName, u.unit_code AS UnitCode
            FROM ProductUnit pu
            INNER JOIN Product p ON pu.product_id = p.product_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            WHERE pu.product_id = @ProductId AND pu.is_active = 1
            ORDER BY pu.is_default DESC, u.unit_name";
        return await connection.QueryAsync<ProductUnit>(sql, new { ProductId = productId });
    }

    public async Task<int> CreateAsync(ProductUnit productUnit)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            INSERT INTO ProductUnit (product_id, unit_id, conversion_rate, price, is_default, is_active, image_path, created_at)
            VALUES (@ProductId, @UnitId, @ConversionRate, @Price, @IsDefault, @IsActive, @ImagePath, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        return await connection.ExecuteScalarAsync<int>(sql, productUnit);
    }

    public async Task<bool> UpdateAsync(ProductUnit productUnit)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE ProductUnit
            SET conversion_rate = @ConversionRate,
                price = @Price,
                is_default = @IsDefault,
                is_active = @IsActive,
                image_path = @ImagePath,
                updated_at = @UpdatedAt
            WHERE product_unit_id = @ProductUnitId";
        var rowsAffected = await connection.ExecuteAsync(sql, productUnit);
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "UPDATE ProductUnit SET is_active = 0, updated_at = GETDATE() WHERE product_unit_id = @Id";
        var rowsAffected = await connection.ExecuteAsync(sql, new { Id = id });
        return rowsAffected > 0;
    }

    public async Task<bool> UpdateImagePathAsync(int productUnitId, string imagePath)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE ProductUnit
            SET image_path = @ImagePath,
                updated_at = GETDATE()
            WHERE product_unit_id = @ProductUnitId";
        var rowsAffected = await connection.ExecuteAsync(sql, new { ProductUnitId = productUnitId, ImagePath = imagePath });
        return rowsAffected > 0;
    }
}
