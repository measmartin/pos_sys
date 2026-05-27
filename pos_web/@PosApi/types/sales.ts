import type { CreateSalesItemDto, SalesItemDetailsDto } from './salesItems';

export interface CreateSalesDto {
  saleDate?: string;
  customerId?: number | null;
  phoneNumber: string;
  currencyId: number;
  amountPaid: number;
  paymentStatus?: string;
  saleStatus?: string;
  notes?: string | null;
  discountAmount?: number | null;
  discountPercentage?: number | null;
  items: CreateSalesItemDto[];
}

export interface UpdateSalesDto {
  saleDate: string;
  customerId?: number | null;
  phoneNumber: string;
  currencyId: number;
  subtotal: number;
  totalDiscount: number;
  discountPercentage?: number | null;
  totalAmount: number;
  amountPaid: number;
  paymentStatus: string;
  saleStatus: string;
  notes?: string | null;
}

export interface ProcessPaymentDto {
  paymentStatus: string;
  paymentMethod?: string | null;
  amountPaid: number;
  changeAmount?: number;
}

export interface SalesDetailsDto {
  saleId: number;
  saleNumber: string;
  saleDate: string;
  customerId?: number | null;
  customerName?: string | null;
  phoneNumber: string;
  currencyId: number;
  currencyCode?: string | null;
  currencySymbol?: string | null;
  subtotal: number;
  totalDiscount: number;
  discountPercentage?: number | null;
  totalAmount: number;
  amountPaid: number;
  changeAmount: number;
  paymentStatus: string;
  saleStatus: string;
  notes?: string | null;
  createdAt: string;
  updatedAt?: string | null;
  items: SalesItemDetailsDto[];
}

export interface SalesPagedResponseDto {
  data: SalesDetailsDto[];
  page: number;
  pageSize: number;
  totalCount: number;
}
