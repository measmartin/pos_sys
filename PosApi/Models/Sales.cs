namespace PosApi.Models;

public class Sales
{
    public int SaleId { get; set; }
    public string SaleNumber { get; set; } = string.Empty;
    public int SaleYear { get; set; }
    public int SaleSequence { get; set; }
    public DateTime SaleDate { get; set; } = DateTime.UtcNow;
    public int? CustomerId { get; set; }
    public string PhoneNumber { get; set; } = string.Empty;
    public int CurrencyId { get; set; }
    public decimal Subtotal { get; set; } = 0;
    public decimal TotalDiscount { get; set; } = 0;
    public decimal? DiscountPercentage { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal AmountPaid { get; set; } = 0;
    public decimal ChangeAmount { get; set; } = 0;
    public string PaymentStatus { get; set; } = "UNPAID";
    public string? PaymentMethod { get; set; }
    public DateTime? PaymentDate { get; set; }
    public string SaleStatus { get; set; } = "COMPLETED"; // DRAFT, COMPLETED, VOID, REFUNDED, RETURNED
    public string? Notes { get; set; }
    public string? CreatedBy { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
    public byte[]? RowVersion { get; set; }
    
    // Navigation properties (populated by queries when needed)
    public string? CustomerName { get; set; }
    public string? CurrencyCode { get; set; }
    public string? CurrencySymbol { get; set; }
}
