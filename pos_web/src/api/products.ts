import apiClient from './client';
import type {
  CreateProductDto,
  UpdateProductDto,
  ProductDetailsDto,
  ProductPagedResponseDto,
} from '@PosApi/types';
import type { ProductQueryParams } from '@PosApi/types';

export const productsApi = {
  getAll: async (params?: ProductQueryParams) => {
    const { data } = await apiClient.get<ProductPagedResponseDto>('/products', { params });
    return data;
  },

  getById: async (id: number) => {
    const { data } = await apiClient.get<ProductDetailsDto>(`/products/${id}`);
    return data;
  },

  getByCategoryId: async (categoryId: number) => {
    const { data } = await apiClient.get<ProductDetailsDto[]>(`/products/category/${categoryId}`);
    return data;
  },

  create: async (dto: CreateProductDto) => {
    const { data } = await apiClient.post<number>('/products', dto);
    return data;
  },

  update: async (id: number, dto: UpdateProductDto) => {
    await apiClient.put(`/products/${id}`, dto);
  },

  delete: async (id: number) => {
    await apiClient.delete(`/products/${id}`);
  },
};
