namespace PosApi.DTOs;

// Category DTOs
public class CreateCategoryDto
{
    public string CategoryName { get; set; } = string.Empty;
    public string? Description { get; set; }
}

public class UpdateCategoryDto
{
    public string? CategoryName { get; set; }
    public string? Description { get; set; }
    public bool? IsActive { get; set; }
}

public class CategoryDetailsDto
{
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class CategoryPagedResponseDto
{
    public IEnumerable<CategoryDetailsDto> Data { get; set; } = Enumerable.Empty<CategoryDetailsDto>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
}
