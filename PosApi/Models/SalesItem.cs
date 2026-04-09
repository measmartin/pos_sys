namespace PosApi.Models;

public class SalesItem
{
    public int SalesItemId { get; set; }
    public int SaleId { get; set; }
    public int LineNumber { get; set; }
    public int ProductId { get; set; }
    public int ProductUnitId { get; set; }
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineSubtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public decimal LineTotal { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties (populated by queries when needed)
    public string? ProductName { get; set; }
    public string? UnitName { get; set; }
}
