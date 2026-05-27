import apiClient from './client';
import type {
  CreateProductUnitDto,
  UpdateProductUnitDto,
  ProductUnitDetailsDto,
  ProductUnitPagedResponseDto,
  ImageUploadResponse,
  ImageDeleteResponse,
} from '@PosApi/types';
import type { ProductUnitQueryParams } from '@PosApi/types';

export const productUnitsApi = {
  getAll: async (params?: ProductUnitQueryParams) => {
    const { data } = await apiClient.get<ProductUnitPagedResponseDto>('/productunits', { params });
    return data;
  },

  getById: async (id: number) => {
    const { data } = await apiClient.get<ProductUnitDetailsDto>(`/productunits/${id}`);
    return data;
  },

  getByProductId: async (productId: number) => {
    const { data } = await apiClient.get<ProductUnitDetailsDto[]>(`/productunits/product/${productId}`);
    return data;
  },

  create: async (dto: CreateProductUnitDto) => {
    const { data } = await apiClient.post<number>('/productunits', dto);
    return data;
  },

  update: async (id: number, dto: UpdateProductUnitDto) => {
    await apiClient.put(`/productunits/${id}`, dto);
  },

  delete: async (id: number) => {
    await apiClient.delete(`/productunits/${id}`);
  },

  uploadImage: async (id: number, file: File) => {
    const formData = new FormData();
    formData.append('file', file);
    const { data } = await apiClient.post<ImageUploadResponse>(
      `/productunits/${id}/image`,
      formData,
      { headers: { 'Content-Type': 'multipart/form-data' } },
    );
    return data;
  },

  getImageUrl: (id: number) => {
    const baseURL = import.meta.env.VITE_API_BASE_URL ?? 'https://localhost:7070';
    return `${baseURL}/api/productunits/${id}/image`;
  },

  deleteImage: async (id: number) => {
    const { data } = await apiClient.delete<ImageDeleteResponse>(`/productunits/${id}/image`);
    return data;
  },
};
