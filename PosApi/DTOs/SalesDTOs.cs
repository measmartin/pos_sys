namespace PosApi.DTOs;

using System.ComponentModel.DataAnnotations;

public class CreateSalesDto
{
    public DateTime SaleDate { get; set; } = DateTime.Now;
    public int? CustomerId { get; set; }
    [Required]
    [StringLength(20, MinimumLength = 7)]
    public string PhoneNumber { get; set; } = string.Empty;
    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "CurrencyId is required and must be a valid currency.")]
    public int CurrencyId { get; set; }
    [Range(0, 999999999.99)]
    public decimal AmountPaid { get; set; }
    [Required]
    [RegularExpression(@"^(PAID|UNPAID|PARTIAL)$", ErrorMessage = "PaymentStatus must be PAID, UNPAID, or PARTIAL.")]
    public string PaymentStatus { get; set; } = "PAID";
    [Required]
    [RegularExpression(@"^(COMPLETED|PENDING|CANCELLED)$", ErrorMessage = "SaleStatus must be COMPLETED, PENDING, or CANCELLED.")]
    public string SaleStatus { get; set; } = "COMPLETED";
    [StringLength(500)]
    public string? Notes { get; set; }
    [Range(0, 999999999.99)]
    public decimal? DiscountAmount { get; set; }
    [Range(0, 100)]
    public decimal? DiscountPercentage { get; set; }
    [Required]
    [MinLength(1, ErrorMessage = "At least one item is required.")]
    public List<CreateSalesItemDto> Items { get; set; } = new();
}

public class UpdateSalesDto
{
    public DateTime SaleDate { get; set; }
    public int? CustomerId { get; set; }
    [Required]
    [StringLength(20, MinimumLength = 7)]
    public string PhoneNumber { get; set; } = string.Empty;
    [Required]
    [Range(1, int.MaxValue, ErrorMessage = "CurrencyId is required and must be a valid currency.")]
    public int CurrencyId { get; set; }
    [Range(0, 999999999.99)]
    public decimal Subtotal { get; set; }
    [Range(0, 999999999.99)]
    public decimal TotalDiscount { get; set; }
    [Range(0, 100)]
    public decimal? DiscountPercentage { get; set; }
    [Range(0, 999999999.99)]
    public decimal TotalAmount { get; set; }
    [Range(0, 999999999.99)]
    public decimal AmountPaid { get; set; }
    [Required]
    [RegularExpression(@"^(PAID|UNPAID|PARTIAL)$", ErrorMessage = "PaymentStatus must be PAID, UNPAID, or PARTIAL.")]
    public string PaymentStatus { get; set; } = "UNPAID";
    [Required]
    [RegularExpression(@"^(COMPLETED|PENDING|CANCELLED)$", ErrorMessage = "SaleStatus must be COMPLETED, PENDING, or CANCELLED.")]
    public string SaleStatus { get; set; } = "COMPLETED";
    [StringLength(500)]
    public string? Notes { get; set; }
}

public class ProcessPaymentDto
{
    [Required]
    [RegularExpression(@"^(PAID|UNPAID|PARTIAL)$", ErrorMessage = "PaymentStatus must be PAID, UNPAID, or PARTIAL.")]
    public string PaymentStatus { get; set; } = "PAID";
    
    [StringLength(50)]
    public string? PaymentMethod { get; set; }
    
    [Range(0, 999999999.99)]
    public decimal AmountPaid { get; set; }
    
    [Range(0, 999999999.99)]
    public decimal ChangeAmount { get; set; } = 0;
}

public class SalesDetailsDto
{
    public int SaleId { get; set; }
    public string SaleNumber { get; set; } = string.Empty;
    public DateTime SaleDate { get; set; }
    public int? CustomerId { get; set; }
    public string? CustomerName { get; set; }
    public string PhoneNumber { get; set; } = string.Empty;
    public int CurrencyId { get; set; }
    public string? CurrencyCode { get; set; }
    public string? CurrencySymbol { get; set; }
    public decimal Subtotal { get; set; }
    public decimal TotalDiscount { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal AmountPaid { get; set; }
    public decimal ChangeAmount { get; set; }
    public string PaymentStatus { get; set; } = string.Empty;
    public string SaleStatus { get; set; } = "COMPLETED";
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public List<SalesItemDetailsDto> Items { get; set; } = new();
}

public class SalesPagedResponseDto
{
    public IEnumerable<SalesDetailsDto> Data { get; set; } = Enumerable.Empty<SalesDetailsDto>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalCount { get; set; }
}
