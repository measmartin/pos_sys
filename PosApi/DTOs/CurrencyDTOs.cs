namespace PosApi.DTOs;

// Currency DTOs
public class CreateCurrencyDto
{
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencyName { get; set; } = string.Empty;
    public string? CurrencySymbol { get; set; }
    public decimal ExchangeRate { get; set; } = 1.0M;
    public bool IsBaseCurrency { get; set; } = false;
}

public class UpdateCurrencyDto
{
    public string? CurrencyCode { get; set; }
    public string? CurrencyName { get; set; }
    public string? CurrencySymbol { get; set; }
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
