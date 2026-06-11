export interface ReportQueryParams {
  startDate: string;
  endDate: string;
  currencyId?: number | null;
  customerId?: number | null;
  categoryId?: number | null;
  saleStatus?: string | null;
}

export interface SalesSummaryDto {
  periodStart: string;
  periodEnd: string;
  totalRevenue: number;
  totalDiscount: number;
  totalAmountPaid: number;
  totalChange: number;
  transactionCount: number;
  avgOrderValue: number;
  currencyCode?: string | null;
  currencySymbol?: string | null;
}

export interface DailySalesDto {
  date: string;
  revenue: number;
  discount: number;
  transactionCount: number;
  avgOrderValue: number;
}

export interface MonthlySalesDto {
  year: number;
  month: number;
  monthLabel: string;
  revenue: number;
  discount: number;
  transactionCount: number;
  avgOrderValue: number;
}

export interface HourlySalesDto {
  hour: number;
  hourLabel: string;
  revenue: number;
  transactionCount: number;
}

export interface TopProductDto {
  productId: number;
  productName: string;
  categoryName?: string | null;
  totalQuantity: number;
  totalRevenue: number;
  saleCount: number;
}

export interface CategorySalesDto {
  categoryId?: number | null;
  categoryName: string;
  totalRevenue: number;
  transactionCount: number;
  percentage: number;
}

export interface TopCustomerDto {
  customerId?: number | null;
  customerName: string;
  phoneNumber?: string | null;
  totalSpent: number;
  visitCount: number;
  avgOrderValue: number;
}

export interface PaymentBreakdownDto {
  paymentStatus: string;
  count: number;
  totalAmount: number;
  percentage: number;
}

export interface SalesDetailsExportDto {
  saleNumber: string;
  saleDate: string;
  customerName?: string | null;
  phoneNumber: string;
  currencyCode: string;
  currencySymbol?: string | null;
  subtotal: number;
  totalDiscount: number;
  totalAmount: number;
  amountPaid: number;
  changeAmount: number;
  paymentStatus: string;
  saleStatus: string;
  notes?: string | null;
}

export interface CurrencyInfoDto {
  currencyId: number;
  currencyCode: string;
  currencySymbol: string;
  exchangeRate: number;
  isBaseCurrency: boolean;
}
