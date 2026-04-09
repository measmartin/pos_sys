namespace PosApi.DTOs;

// SalesItem DTOs
public class CreateSalesItemDto
{
    public int ProductId { get; set; }
    public int ProductUnitId { get; set; }
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public decimal? DiscountAmount { get; set; }
    public string? Notes { get; set; }
}

public class SalesItemDto
{
    public int SalesItemId { get; set; }
    public int LineNumber { get; set; }
    public int ProductId { get; set; }
    public string? ProductName { get; set; }
    public int ProductUnitId { get; set; }
    public string? UnitName { get; set; }
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineSubtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public decimal LineTotal { get; set; }
    public string? Notes { get; set; }
}

public class UpdateSalesItemDto
{
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public decimal? DiscountAmount { get; set; }
    public bool IsActive { get; set; }
}

public class SalesItemDetailsDto
{
    public int SalesItemId { get; set; }
    public int SaleId { get; set; }
    public int LineNumber { get; set; }
    public int ProductId { get; set; }
    public string? ProductName { get; set; }
    public int ProductUnitId { get; set; }
    public string? UnitName { get; set; }
    public decimal Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineSubtotal { get; set; }
    public decimal DiscountAmount { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public decimal LineTotal { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
}
