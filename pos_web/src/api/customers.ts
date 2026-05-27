import apiClient from './client';
import type {
  CreateCustomerDto,
  UpdateCustomerDto,
  CustomerDetailsDto,
  CustomerPagedResponseDto,
} from '@PosApi/types';
import type { CustomerQueryParams } from '@PosApi/types';

export const customersApi = {
  getAll: async (params?: CustomerQueryParams) => {
    const { data } = await apiClient.get<CustomerPagedResponseDto>('/customers', { params });
    return data;
  },

  getById: async (id: number) => {
    const { data } = await apiClient.get<CustomerDetailsDto>(`/customers/${id}`);
    return data;
  },

  getByPhone: async (phone: string) => {
    const { data } = await apiClient.get<CustomerDetailsDto>(`/customers/phone/${phone}`);
    return data;
  },

  create: async (dto: CreateCustomerDto) => {
    const { data } = await apiClient.post<number>('/customers', dto);
    return data;
  },

  update: async (id: number, dto: UpdateCustomerDto) => {
    await apiClient.put(`/customers/${id}`, dto);
  },

  delete: async (id: number) => {
    await apiClient.delete(`/customers/${id}`);
  },
};
