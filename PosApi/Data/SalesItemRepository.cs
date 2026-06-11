using Dapper;
using PosApi.Models;
using System.Data;

namespace PosApi.Data;

public class SalesItemRepository : ISalesItemRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public SalesItemRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IEnumerable<SalesItem>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT si.*, p.product_name AS ProductName, u.unit_name AS UnitName
            FROM SalesItem si
            INNER JOIN Product p ON si.product_id = p.product_id
            INNER JOIN ProductUnit pu ON si.product_unit_id = pu.product_unit_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            ORDER BY si.sales_item_id";
        return await connection.QueryAsync<SalesItem>(sql);
    }

    public async Task<SalesItem?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT si.*, p.product_name AS ProductName, u.unit_name AS UnitName
            FROM SalesItem si
            INNER JOIN Product p ON si.product_id = p.product_id
            INNER JOIN ProductUnit pu ON si.product_unit_id = pu.product_unit_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            WHERE si.sales_item_id = @Id";
        return await connection.QueryFirstOrDefaultAsync<SalesItem>(sql, new { Id = id });
    }

    public async Task<IEnumerable<SalesItem>> GetBySaleIdAsync(int saleId)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT si.*, p.product_name AS ProductName, u.unit_name AS UnitName
            FROM SalesItem si
            INNER JOIN Product p ON si.product_id = p.product_id
            INNER JOIN ProductUnit pu ON si.product_unit_id = pu.product_unit_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            WHERE si.sale_id = @SaleId
            ORDER BY si.line_number";
        return await connection.QueryAsync<SalesItem>(sql, new { SaleId = saleId });
    }

    public async Task<IEnumerable<SalesItem>> GetBySaleIdsAsync(IEnumerable<int> saleIds)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT si.*, p.product_name AS ProductName, u.unit_name AS UnitName
            FROM SalesItem si
            INNER JOIN Product p ON si.product_id = p.product_id
            INNER JOIN ProductUnit pu ON si.product_unit_id = pu.product_unit_id
            INNER JOIN Unit u ON pu.unit_id = u.unit_id
            WHERE si.sale_id IN @SaleIds
            ORDER BY si.sale_id, si.line_number";
        return await connection.QueryAsync<SalesItem>(sql, new { SaleIds = saleIds });
    }

    public async Task<int> CreateAsync(SalesItem salesItem, IDbConnection? connection = null, IDbTransaction? transaction = null)
    {
        var conn = connection ?? _connectionFactory.CreateConnection();
        var shouldDispose = connection == null;
        if (shouldDispose) conn.Open();
        
        const string sql = @"
            INSERT INTO SalesItem (sale_id, line_number, product_id, product_unit_id, 
                                 quantity, unit_price, line_subtotal, discount_amount, 
                                 discount_percentage, line_total, notes, created_at)
            VALUES (@SaleId, @LineNumber, @ProductId, @ProductUnitId, 
                    @Quantity, @UnitPrice, @LineSubtotal, @DiscountAmount, 
                    @DiscountPercentage, @LineTotal, @Notes, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() as int);";
        var result = await conn.ExecuteScalarAsync<int>(sql, salesItem, transaction);
        
        if (shouldDispose) conn.Dispose();
        return result;
    }

    public async Task<bool> UpdateAsync(SalesItem salesItem, IDbConnection? connection = null, IDbTransaction? transaction = null)
    {
        var conn = connection ?? _connectionFactory.CreateConnection();
        var shouldDispose = connection == null;
        if (shouldDispose) conn.Open();
        
        const string sql = @"
            UPDATE SalesItem
            SET quantity = @Quantity,
                unit_price = @UnitPrice,
                line_subtotal = @LineSubtotal,
                discount_percentage = @DiscountPercentage,
                discount_amount = @DiscountAmount,
                line_total = @LineTotal,
                notes = @Notes
            WHERE sales_item_id = @SalesItemId";
        var rowsAffected = await conn.ExecuteAsync(sql, salesItem, transaction);
        
        if (shouldDispose) conn.Dispose();
        return rowsAffected > 0;
    }

    public async Task<bool> DeleteAsync(int id, IDbConnection? connection = null, IDbTransaction? transaction = null)
    {
        var conn = connection ?? _connectionFactory.CreateConnection();
        var shouldDispose = connection == null;
        if (shouldDispose) conn.Open();
        
        const string sql = "DELETE FROM SalesItem WHERE sales_item_id = @Id";
        var rowsAffected = await conn.ExecuteAsync(sql, new { Id = id }, transaction);
        
        if (shouldDispose) conn.Dispose();
        return rowsAffected > 0;
    }
}
