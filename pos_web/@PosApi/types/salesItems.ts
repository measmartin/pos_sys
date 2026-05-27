export interface CreateSalesItemDto {
  productId: number;
  productUnitId: number;
  quantity: number;
  unitPrice: number;
  discountPercentage?: number | null;
  discountAmount?: number | null;
  notes?: string | null;
}

export interface SalesItemDto {
  salesItemId: number;
  lineNumber: number;
  productId: number;
  productName?: string | null;
  productUnitId: number;
  unitName?: string | null;
  quantity: number;
  unitPrice: number;
  lineSubtotal: number;
  discountAmount: number;
  discountPercentage?: number | null;
  lineTotal: number;
  notes?: string | null;
}

export interface UpdateSalesItemDto {
  quantity: number;
  unitPrice: number;
  discountPercentage?: number | null;
  discountAmount?: number | null;
  isActive: boolean;
}

export interface SalesItemDetailsDto {
  salesItemId: number;
  saleId: number;
  lineNumber: number;
  productId: number;
  productName?: string | null;
  productUnitId: number;
  unitName?: string | null;
  quantity: number;
  unitPrice: number;
  lineSubtotal: number;
  discountAmount: number;
  discountPercentage?: number | null;
  lineTotal: number;
  notes?: string | null;
  createdAt: string;
}
