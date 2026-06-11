using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

// Unit DTOs
public class CreateUnitDto
{
    [Required]
    [StringLength(100, MinimumLength = 1, ErrorMessage = "Unit name must be 1-100 characters.")]
    public string UnitName { get; set; } = string.Empty;

    [Required]
    [StringLength(20, MinimumLength = 1, ErrorMessage = "Unit code must be 1-20 characters.")]
    public string UnitCode { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "Description must be at most 500 characters.")]
    public string? Description { get; set; }
}

public class UpdateUnitDto
{
    [StringLength(100, MinimumLength = 1, ErrorMessage = "Unit name must be 1-100 characters.")]
    public string? UnitName { get; set; }

    [StringLength(20, MinimumLength = 1, ErrorMessage = "Unit code must be 1-20 characters.")]
    public string? UnitCode { get; set; }

    [StringLength(500, ErrorMessage = "Description must be at most 500 characters.")]
    public string? Description { get; set; }

    public bool? IsActive { get; set; }
}

public class UnitDetailsDto
{
    public int UnitId { get; set; }
    public string UnitName { get; set; } = string.Empty;
    public string UnitCode { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class UnitPagedResponseDto
{
    public IEnumerable<UnitDetailsDto> Data { get; set; } = Enumerable.Empty<UnitDetailsDto>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
}
