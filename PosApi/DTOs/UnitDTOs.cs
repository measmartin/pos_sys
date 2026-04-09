namespace PosApi.DTOs;

// Unit DTOs
public class CreateUnitDto
{
    public string UnitName { get; set; } = string.Empty;
    public string UnitCode { get; set; } = string.Empty;
    public string? Description { get; set; }
}

public class UpdateUnitDto
{
    public string? UnitName { get; set; }
    public string? UnitCode { get; set; }
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
