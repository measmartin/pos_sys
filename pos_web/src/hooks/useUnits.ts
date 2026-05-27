import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { unitsApi } from '../api';
import type { CreateUnitDto, UpdateUnitDto, UnitQueryParams } from '@PosApi/types';

const UNITS_KEY = 'units';

export function useUnitsList(params?: UnitQueryParams) {
  return useQuery({
    queryKey: [UNITS_KEY, params],
    queryFn: () => unitsApi.getAll(params),
  });
}

export function useUnit(id: number) {
  return useQuery({
    queryKey: [UNITS_KEY, id],
    queryFn: () => unitsApi.getById(id),
    enabled: !!id,
  });
}

export function useCreateUnit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (dto: CreateUnitDto) => unitsApi.create(dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [UNITS_KEY] }),
  });
}

export function useUpdateUnit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: number; dto: UpdateUnitDto }) => unitsApi.update(id, dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [UNITS_KEY] }),
  });
}

export function useDeleteUnit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => unitsApi.delete(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [UNITS_KEY] }),
  });
}
