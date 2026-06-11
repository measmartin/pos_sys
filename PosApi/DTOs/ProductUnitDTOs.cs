using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

// ProductUnit DTOs
public class CreateProductUnitDto
{
    [Range(1, int.MaxValue, ErrorMessage = "Product ID must be a positive integer.")]
    public int ProductId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Unit ID must be a positive integer.")]
    public int UnitId { get; set; }

    [Range(0.0001, double.MaxValue, ErrorMessage = "Conversion rate must be greater than 0.")]
    public decimal ConversionRate { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Price must be non-negative.")]
    public decimal Price { get; set; }

    public bool IsDefault { get; set; } = false;
}

public class UpdateProductUnitDto
{
    [Range(0.0001, double.MaxValue, ErrorMessage = "Conversion rate must be greater than 0.")]
    public decimal? ConversionRate { get; set; }

    [Range(0, double.MaxValue, ErrorMessage = "Price must be non-negative.")]
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

public class ProductUnitPagedResponseDto
{
    public IEnumerable<ProductUnitDetailsDto> Data { get; set; } = Enumerable.Empty<ProductUnitDetailsDto>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
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
