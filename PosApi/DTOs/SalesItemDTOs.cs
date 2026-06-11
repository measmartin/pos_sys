using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

// SalesItem DTOs
public class CreateSalesItemDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Product ID must be a positive integer.")]
    public int ProductId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Product unit ID must be a positive integer.")]
    public int ProductUnitId { get; set; }

    [Range(0.0001, double.MaxValue, ErrorMessage = "Quantity must be greater than 0.")]
    public decimal Quantity { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Unit price must be non-negative.")]
    public decimal UnitPrice { get; set; }

    [Range(0, 100, ErrorMessage = "Discount percentage must be between 0 and 100.")]
    public decimal? DiscountPercentage { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Discount amount must be non-negative.")]
    public decimal? DiscountAmount { get; set; }

    [StringLength(500, ErrorMessage = "Notes must be at most 500 characters.")]
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
    [Range(0.0001, double.MaxValue, ErrorMessage = "Quantity must be greater than 0.")]
    public decimal Quantity { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Unit price must be non-negative.")]
    public decimal UnitPrice { get; set; }

    [Range(0, 100, ErrorMessage = "Discount percentage must be between 0 and 100.")]
    public decimal? DiscountPercentage { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Discount amount must be non-negative.")]
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
