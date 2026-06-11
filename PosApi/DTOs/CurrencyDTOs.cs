using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

// Currency DTOs
public class CreateCurrencyDto
{
    [Required]
    [StringLength(3, MinimumLength = 1, ErrorMessage = "Currency code must be 1-3 characters.")]
    public string CurrencyCode { get; set; } = string.Empty;

    [Required]
    [StringLength(100, MinimumLength = 1, ErrorMessage = "Currency name must be 1-100 characters.")]
    public string CurrencyName { get; set; } = string.Empty;

    [StringLength(10, ErrorMessage = "Currency symbol must be at most 10 characters.")]
    public string? CurrencySymbol { get; set; }

    [Range(0.000001, double.MaxValue, ErrorMessage = "Exchange rate must be greater than 0.")]
    public decimal ExchangeRate { get; set; } = 1.0M;

    public bool IsBaseCurrency { get; set; } = false;
}

public class UpdateCurrencyDto
{
    [StringLength(3, MinimumLength = 1, ErrorMessage = "Currency code must be 1-3 characters.")]
    public string? CurrencyCode { get; set; }

    [StringLength(100, MinimumLength = 1, ErrorMessage = "Currency name must be 1-100 characters.")]
    public string? CurrencyName { get; set; }

    [StringLength(10, ErrorMessage = "Currency symbol must be at most 10 characters.")]
    public string? CurrencySymbol { get; set; }

    [Range(0.000001, double.MaxValue, ErrorMessage = "Exchange rate must be greater than 0.")]
    public decimal? ExchangeRate { get; set; }

    public bool? IsBaseCurrency { get; set; }

    public bool? IsActive { get; set; }
}

public class CurrencyDetailsDto
{
    public int CurrencyId { get; set; }
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencyName { get; set; } = string.Empty;
    public string? CurrencySymbol { get; set; }
    public decimal ExchangeRate { get; set; }
    public bool IsBaseCurrency { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public class CurrencyPagedResponseDto
{
    public IEnumerable<CurrencyDetailsDto> Data { get; set; } = Enumerable.Empty<CurrencyDetailsDto>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
}
