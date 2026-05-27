import apiClient from './client';
import type {
  CreateCategoryDto,
  UpdateCategoryDto,
  CategoryDetailsDto,
  CategoryPagedResponseDto,
} from '@PosApi/types';
import type { CategoryQueryParams } from '@PosApi/types';

export const categoriesApi = {
  getAll: async (params?: CategoryQueryParams) => {
    const { data } = await apiClient.get<CategoryPagedResponseDto>('/categories', { params });
    return data;
  },

  getById: async (id: number) => {
    const { data } = await apiClient.get<CategoryDetailsDto>(`/categories/${id}`);
    return data;
  },

  create: async (dto: CreateCategoryDto) => {
    const { data } = await apiClient.post<number>('/categories', dto);
    return data;
  },

  update: async (id: number, dto: UpdateCategoryDto) => {
    await apiClient.put(`/categories/${id}`, dto);
  },

  delete: async (id: number) => {
    await apiClient.delete(`/categories/${id}`);
  },
};
