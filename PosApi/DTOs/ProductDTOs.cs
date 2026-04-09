namespace PosApi.DTOs;

// Product DTOs
public class CreateProductDto
{
    public string ProductCode { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public int CategoryId { get; set; }
    public int BaseUnitId { get; set; }
    public string? Description { get; set; }
}

public class UpdateProductDto
{
    public string? ProductCode { get; set; }
    public string? ProductName { get; set; }
    public int? CategoryId { get; set; }
    public int? BaseUnitId { get; set; }
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
