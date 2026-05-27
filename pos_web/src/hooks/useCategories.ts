import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { categoriesApi } from '../api';
import type { CreateCategoryDto, UpdateCategoryDto, CategoryQueryParams } from '@PosApi/types';

const CATEGORIES_KEY = 'categories';

export function useCategoriesList(params?: CategoryQueryParams) {
  return useQuery({
    queryKey: [CATEGORIES_KEY, params],
    queryFn: () => categoriesApi.getAll(params),
  });
}

export function useCategory(id: number) {
  return useQuery({
    queryKey: [CATEGORIES_KEY, id],
    queryFn: () => categoriesApi.getById(id),
    enabled: !!id,
  });
}

export function useCreateCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (dto: CreateCategoryDto) => categoriesApi.create(dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CATEGORIES_KEY] }),
  });
}

export function useUpdateCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: number; dto: UpdateCategoryDto }) => categoriesApi.update(id, dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CATEGORIES_KEY] }),
  });
}

export function useDeleteCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => categoriesApi.delete(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CATEGORIES_KEY] }),
  });
}
