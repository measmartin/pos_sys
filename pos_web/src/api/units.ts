import apiClient from './client';
import type {
  CreateUnitDto,
  UpdateUnitDto,
  UnitDetailsDto,
  UnitPagedResponseDto,
} from '@PosApi/types';
import type { UnitQueryParams } from '@PosApi/types';

export const unitsApi = {
  getAll: async (params?: UnitQueryParams) => {
    const { data } = await apiClient.get<UnitPagedResponseDto>('/units', { params });
    return data;
  },

  getById: async (id: number) => {
    const { data } = await apiClient.get<UnitDetailsDto>(`/units/${id}`);
    return data;
  },

  create: async (dto: CreateUnitDto) => {
    const { data } = await apiClient.post<number>('/units', dto);
    return data;
  },

  update: async (id: number, dto: UpdateUnitDto) => {
    await apiClient.put(`/units/${id}`, dto);
  },

  delete: async (id: number) => {
    await apiClient.delete(`/units/${id}`);
  },
};
