export interface CreateProductUnitDto {
  productId: number;
  unitId: number;
  conversionRate: number;
  price: number;
  isDefault?: boolean;
}

export interface UpdateProductUnitDto {
  conversionRate?: number | null;
  price?: number | null;
  isDefault?: boolean | null;
  isActive?: boolean | null;
}

export interface ProductUnitPagedResponseDto {
  data: ProductUnitDetailsDto[];
  page: number;
  pageSize: number;
  totalCount: number;
}

export interface ProductUnitWithDetailsDto {
  productUnitId: number;
  productId: number;
  productName?: string | null;
  unitId: number;
  unitName?: string | null;
  unitCode?: string | null;
  currencyId?: number | null;
  currencyCode?: string | null;
  currencySymbol?: string | null;
  isBaseCurrency: boolean;
  conversionRate: number;
  price: number;
  isDefault: boolean;
  isActive: boolean;
  imagePath?: string | null;
  imageUrl?: string | null;
}

export interface ProductUnitDetailsDto {
  productUnitId: number;
  productId: number;
  productName?: string | null;
  unitId: number;
  unitName?: string | null;
  unitCode?: string | null;
  currencyId?: number | null;
  currencyCode?: string | null;
  currencySymbol?: string | null;
  isBaseCurrency: boolean;
  conversionRate: number;
  price: number;
  isDefault: boolean;
  isActive: boolean;
  imagePath?: string | null;
  imageUrl?: string | null;
  createdAt: string;
  updatedAt?: string | null;
}
