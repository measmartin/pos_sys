namespace PosApi.DTOs;

using System.ComponentModel.DataAnnotations;

public class CreateSalesDto
{
    public DateTime SaleDate { get; set; } = DateTime.Now;
    public int? CustomerId { get; set; }
    [Required]
    [StringLength(20, MinimumLength = 7)]
    public string PhoneNumber { get; set; } = string.Empty;
    public int CurrencyId { get; set; }
    public decimal AmountPaid { get; set; }
    public string? PaymentStatus { get; set; }
    public string SaleStatus { get; set; } = "COMPLETED";
    public string? Notes { get; set; }
    public decimal? DiscountAmount { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public List<CreateSalesItemDto> Items { get; set; } = new();
}

public class UpdateSalesDto
{
    public DateTime SaleDate { get; set; }
    public int? CustomerId { get; set; }
    [Required]
    [StringLength(20, MinimumLength = 7)]
    public string PhoneNumber { get; set; } = string.Empty;
    public int CurrencyId { get; set; }
    public decimal Subtotal { get; set; }
    public decimal TotalDiscount { get; set; }
    public decimal? DiscountPercentage { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal AmountPaid { get; set; }
    public string PaymentStatus { get; set; } = string.Empty;
    public string SaleStatus { get; set; } = "COMPLETED";
    public string? Notes { get; set; }
}

public class ProcessPaymentDto
{
    public string PaymentStatus { get; set; } = "PAID"; // PAID, UNPAID, PARTIAL
    public string? PaymentMethod { get; set; }
    public decimal AmountPaid { get; set; }
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
