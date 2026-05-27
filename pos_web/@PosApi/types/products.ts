export interface CreateProductDto {
  productCode: string;
  productName: string;
  categoryId: number;
  baseUnitId: number;
  description?: string | null;
}

export interface UpdateProductDto {
  productCode?: string | null;
  productName?: string | null;
  categoryId?: number | null;
  baseUnitId?: number | null;
  description?: string | null;
  isActive?: boolean | null;
}

import type { ProductUnitDetailsDto } from './productUnits';

export interface ProductWithDetailsDto {
  productId: number;
  productCode: string;
  productName: string;
  categoryId: number;
  categoryName?: string | null;
  baseUnitId: number;
  baseUnitName?: string | null;
  description?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt?: string | null;
}

export interface ProductDetailsDto {
  productId: number;
  productCode: string;
  productName: string;
  categoryId: number;
  categoryName?: string | null;
  baseUnitId: number;
  baseUnitName?: string | null;
  description?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt?: string | null;
  units: ProductUnitDetailsDto[];
}

export interface ProductPagedResponseDto {
  data: ProductDetailsDto[];
  page: number;
  pageSize: number;
  totalCount: number;
}
