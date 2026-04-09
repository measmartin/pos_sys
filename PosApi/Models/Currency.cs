namespace PosApi.Models;

public class Currency
{
    public int CurrencyId { get; set; }
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencyName { get; set; } = string.Empty;
    public string? CurrencySymbol { get; set; }
    public decimal ExchangeRate { get; set; } = 1.0M;
    public bool IsBaseCurrency { get; set; } = false;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
