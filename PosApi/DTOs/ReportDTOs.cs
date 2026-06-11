namespace PosApi.DTOs;

public class ReportQueryParams
{
    public DateTime StartDate { get; set; } = DateTime.Today.AddDays(-30);
    public DateTime EndDate { get; set; } = DateTime.Today.AddDays(1).AddTicks(-1);
    public int? CurrencyId { get; set; }
    public int? CustomerId { get; set; }
    public int? CategoryId { get; set; }
    public string? SaleStatus { get; set; }
    public string? GroupBy { get; set; } // day, week, month, hour
}

public class SalesSummaryDto
{
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public decimal TotalRevenue { get; set; }
    public decimal TotalDiscount { get; set; }
    public decimal TotalAmountPaid { get; set; }
    public decimal TotalChange { get; set; }
    public int TransactionCount { get; set; }
    public decimal AvgOrderValue { get; set; }
    public string? CurrencyCode { get; set; }
    public string? CurrencySymbol { get; set; }
}

public class DailySalesDto
{
    public DateTime Date { get; set; }
    public decimal Revenue { get; set; }
    public decimal Discount { get; set; }
    public int TransactionCount { get; set; }
    public decimal AvgOrderValue { get; set; }
}

public class MonthlySalesDto
{
    public int Year { get; set; }
    public int Month { get; set; }
    public string MonthLabel { get; set; } = string.Empty;
    public decimal Revenue { get; set; }
    public decimal Discount { get; set; }
    public int TransactionCount { get; set; }
    public decimal AvgOrderValue { get; set; }
}

public class HourlySalesDto
{
    public int Hour { get; set; }
    public string HourLabel { get; set; } = string.Empty;
    public decimal Revenue { get; set; }
    public int TransactionCount { get; set; }
}

public class TopProductDto
{
    public int ProductId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string? CategoryName { get; set; }
    public decimal TotalQuantity { get; set; }
    public decimal TotalRevenue { get; set; }
    public int SaleCount { get; set; }
}

public class CategorySalesDto
{
    public int? CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public decimal TotalRevenue { get; set; }
    public int TransactionCount { get; set; }
    public decimal Percentage { get; set; }
}

public class TopCustomerDto
{
    public int? CustomerId { get; set; }
    public string CustomerName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public decimal TotalSpent { get; set; }
    public int VisitCount { get; set; }
    public decimal AvgOrderValue { get; set; }
}

public class PaymentBreakdownDto
{
    public string PaymentStatus { get; set; } = string.Empty;
    public int Count { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal Percentage { get; set; }
}

public class SalesDetailsExportDto
{
    public string SaleNumber { get; set; } = string.Empty;
    public DateTime SaleDate { get; set; }
    public string? CustomerName { get; set; }
    public string PhoneNumber { get; set; } = string.Empty;
    public string CurrencyCode { get; set; } = string.Empty;
    public decimal Subtotal { get; set; }
    public decimal TotalDiscount { get; set; }
    public decimal TotalAmount { get; set; }
    public decimal AmountPaid { get; set; }
    public decimal ChangeAmount { get; set; }
    public string PaymentStatus { get; set; } = string.Empty;
    public string SaleStatus { get; set; } = string.Empty;
    public string? Notes { get; set; }
}

public class CurrencyInfoDto
{
    public int CurrencyId { get; set; }
    public string CurrencyCode { get; set; } = string.Empty;
    public string CurrencySymbol { get; set; } = string.Empty;
    public decimal ExchangeRate { get; set; }
    public bool IsBaseCurrency { get; set; }
}

public class ScheduledReportDto
{
    public int Id { get; set; }
    public string ReportType { get; set; } = string.Empty;
    public string Frequency { get; set; } = string.Empty; // daily, weekly, monthly
    public string? EmailRecipients { get; set; }
    public DateTime? LastGenerated { get; set; }
    public bool IsActive { get; set; }
}
