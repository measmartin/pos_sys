using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

// Product DTOs
public class CreateProductDto
{
    [Required]
    [StringLength(50, MinimumLength = 1, ErrorMessage = "Product code must be 1-50 characters.")]
    public string ProductCode { get; set; } = string.Empty;

    [Required]
    [StringLength(200, MinimumLength = 1, ErrorMessage = "Product name must be 1-200 characters.")]
    public string ProductName { get; set; } = string.Empty;

    [Range(1, int.MaxValue, ErrorMessage = "Category ID must be a positive integer.")]
    public int CategoryId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Base unit ID must be a positive integer.")]
    public int BaseUnitId { get; set; }

    [StringLength(500, ErrorMessage = "Description must be at most 500 characters.")]
    public string? Description { get; set; }
}

public class UpdateProductDto
{
    [StringLength(50, MinimumLength = 1, ErrorMessage = "Product code must be 1-50 characters.")]
    public string? ProductCode { get; set; }

    [StringLength(200, MinimumLength = 1, ErrorMessage = "Product name must be 1-200 characters.")]
    public string? ProductName { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Category ID must be a positive integer.")]
    public int? CategoryId { get; set; }

    [Range(1, int.MaxValue, ErrorMessage = "Base unit ID must be a positive integer.")]
    public int? BaseUnitId { get; set; }

    [StringLength(500, ErrorMessage = "Description must be at most 500 characters.")]
    public string? Description { get; set; }

    public bool? IsActive { get; set; }
}

public class ProductWithDetailsDto
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public int BaseUnitId { get; set; }
    public string? BaseUnitName { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class ProductDetailsDto
{
    public int ProductId { get; set; }
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public string? CategoryName { get; set; }
    public int BaseUnitId { get; set; }
    public string? BaseUnitName { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public IEnumerable<ProductUnitDetailsDto> Units { get; set; } = Enumerable.Empty<ProductUnitDetailsDto>();
}

public class ProductPagedResponseDto
{
    public IEnumerable<ProductDetailsDto> Data { get; set; } = Enumerable.Empty<ProductDetailsDto>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
}
