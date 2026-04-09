namespace PosApi.Models;

public class ProductUnit
{
    public int ProductUnitId { get; set; }
    public int ProductId { get; set; }
    public int UnitId { get; set; }
    public decimal ConversionRate { get; set; }
    public decimal Price { get; set; }
    public bool IsDefault { get; set; } = false;
    public bool IsActive { get; set; } = true;
    public string? ImagePath { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    
    // Navigation properties (populated by queries when needed)
    public string? ProductName { get; set; }
    public string? UnitName { get; set; }
    public string? UnitCode { get; set; }
}
