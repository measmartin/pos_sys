namespace PosApi.DTOs;

// ProductUnit DTOs
public class CreateProductUnitDto
{
    public int ProductId { get; set; }
    public int UnitId { get; set; }
    public decimal ConversionRate { get; set; }
    public decimal Price { get; set; }
    public bool IsDefault { get; set; } = false;
}

public class UpdateProductUnitDto
{
    public decimal? ConversionRate { get; set; }
    public decimal? Price { get; set; }
    public bool? IsDefault { get; set; }
    public bool? IsActive { get; set; }
}

public class ProductUnitWithDetailsDto
{
    public int ProductUnitId { get; set; }
    public int ProductId { get; set; }
    public string? ProductName { get; set; }
    public int UnitId { get; set; }
    public string? UnitName { get; set; }
    public string? UnitCode { get; set; }
    public int? CurrencyId { get; set; }
    public string? CurrencyCode { get; set; }
    public string? CurrencySymbol { get; set; }
    public bool IsBaseCurrency { get; set; }
    public decimal ConversionRate { get; set; }
    public decimal Price { get; set; }
    public bool IsDefault { get; set; }
    public bool IsActive { get; set; }
    public string? ImagePath { get; set; }
    public string? ImageUrl { get; set; }
}

public class ProductUnitDetailsDto
{
    public int ProductUnitId { get; set; }
    public int ProductId { get; set; }
    public string? ProductName { get; set; }
    public int UnitId { get; set; }
    public string? UnitName { get; set; }
    public string? UnitCode { get; set; }
    public int? CurrencyId { get; set; }
    public string? CurrencyCode { get; set; }
    public string? CurrencySymbol { get; set; }
    public bool IsBaseCurrency { get; set; }
    public decimal ConversionRate { get; set; }
    public decimal Price { get; set; }
    public bool IsDefault { get; set; }
    public bool IsActive { get; set; }
    public string? ImagePath { get; set; }
    public string? ImageUrl { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}
