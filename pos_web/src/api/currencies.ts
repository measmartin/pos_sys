import apiClient from './client';
import type {
  CreateCurrencyDto,
  UpdateCurrencyDto,
  CurrencyDetailsDto,
  CurrencyPagedResponseDto,
} from '@PosApi/types';
import type { CurrencyQueryParams } from '@PosApi/types';

export const currenciesApi = {
  getAll: async (params?: CurrencyQueryParams) => {
    const { data } = await apiClient.get<CurrencyPagedResponseDto>('/currencies', { params });
    return data;
  },

  getById: async (id: number) => {
    const { data } = await apiClient.get<CurrencyDetailsDto>(`/currencies/${id}`);
    return data;
  },

  getByCode: async (code: string) => {
    const { data } = await apiClient.get<CurrencyDetailsDto>(`/currencies/code/${code}`);
    return data;
  },

  create: async (dto: CreateCurrencyDto) => {
    const { data } = await apiClient.post<number>('/currencies', dto);
    return data;
  },

  update: async (id: number, dto: UpdateCurrencyDto) => {
    await apiClient.put(`/currencies/${id}`, dto);
  },

  delete: async (id: number) => {
    await apiClient.delete(`/currencies/${id}`);
  },
};
