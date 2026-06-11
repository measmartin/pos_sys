using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

// Category DTOs
public class CreateCategoryDto
{
    [Required]
    [StringLength(100, MinimumLength = 1, ErrorMessage = "Category name must be 1-100 characters.")]
    public string CategoryName { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Description must be at most 500 characters.")]
    public string? Description { get; set; }
}

public class UpdateCategoryDto
{
    [StringLength(100, MinimumLength = 1, ErrorMessage = "Category name must be 1-100 characters.")]
    public string? CategoryName { get; set; }

    [StringLength(500, ErrorMessage = "Description must be at most 500 characters.")]
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
