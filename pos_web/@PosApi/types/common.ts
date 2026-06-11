export interface ApiError {
  message: string;
  statusCode: number;
  timestamp: string;
  path?: string;
  traceId?: string;
}

export interface PaginationParams {
  page?: number;
  pageSize?: number;
  search?: string;
}

export interface SaleQueryParams extends PaginationParams {
  status?: string;
}

export interface ProductQueryParams extends PaginationParams {
  categoryId?: number;
  isActive?: boolean;
}

export interface CustomerQueryParams extends PaginationParams {
  isActive?: boolean;
}

export interface CategoryQueryParams extends PaginationParams {
  isActive?: boolean;
}

export interface CurrencyQueryParams extends PaginationParams {
  isActive?: boolean;
}

export interface UnitQueryParams extends PaginationParams {
  isActive?: boolean;
}

export interface ProductUnitQueryParams extends PaginationParams {
  productId?: number;
  isActive?: boolean;
}
