import apiClient from './client';
import type {
  CreateSalesDto,
  SalesDetailsDto,
  SalesPagedResponseDto,
  CreateSalesItemDto,
  UpdateSalesDto,
  UpdateSalesItemDto,
} from '@PosApi/types';
import type { SaleQueryParams } from '@PosApi/types';

export const salesApi = {
  getAll: async (params?: SaleQueryParams) => {
    const { data } = await apiClient.get<SalesPagedResponseDto>('/sales', { params });
    return data;
  },

  getById: async (id: number) => {
    const { data } = await apiClient.get<SalesDetailsDto>(`/sales/${id}`);
    return data;
  },

  getBySaleNumber: async (saleNumber: string) => {
    const { data } = await apiClient.get<SalesDetailsDto>(`/sales/number/${saleNumber}`);
    return data;
  },

  getByDateRange: async (startDate: string, endDate: string) => {
    const { data } = await apiClient.get<SalesDetailsDto[]>('/sales/date-range', {
      params: { startDate, endDate },
    });
    return data;
  },

  getByCustomerId: async (customerId: number) => {
    const { data } = await apiClient.get<SalesDetailsDto[]>(`/sales/customer/${customerId}`);
    return data;
  },

  create: async (dto: CreateSalesDto) => {
    const { data } = await apiClient.post<number>('/sales', dto);
    return data;
  },

  update: async (id: number, dto: UpdateSalesDto) => {
    await apiClient.put(`/sales/${id}`, dto);
  },

  delete: async (id: number) => {
    await apiClient.delete(`/sales/${id}`);
  },

  addItem: async (saleId: number, dto: CreateSalesItemDto) => {
    const { data } = await apiClient.post<number>(`/sales/${saleId}/items`, dto);
    return data;
  },

  updateItem: async (saleId: number, itemId: number, dto: UpdateSalesItemDto) => {
    await apiClient.put(`/sales/${saleId}/items/${itemId}`, dto);
  },

  removeItem: async (saleId: number, itemId: number) => {
    await apiClient.delete(`/sales/${saleId}/items/${itemId}`);
  },
};
