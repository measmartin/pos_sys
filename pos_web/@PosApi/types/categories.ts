export interface CreateCategoryDto {
  categoryName: string;
  description?: string | null;
}

export interface UpdateCategoryDto {
  categoryName?: string | null;
  description?: string | null;
  isActive?: boolean | null;
}

export interface CategoryDetailsDto {
  categoryId: number;
  categoryName: string;
  description?: string | null;
  isActive: boolean;
  createdAt: string;
  updatedAt?: string | null;
}

export interface CategoryPagedResponseDto {
  data: CategoryDetailsDto[];
  page: number;
  pageSize: number;
  totalCount: number;
}
