import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { salesApi } from '../api';
import type { CreateSalesDto, UpdateSalesDto, SaleQueryParams } from '@PosApi/types';

const SALES_KEY = 'sales';

export function useSalesList(params?: SaleQueryParams) {
  return useQuery({
    queryKey: [SALES_KEY, params],
    queryFn: () => salesApi.getAll(params),
  });
}

export function useSale(id: number) {
  return useQuery({
    queryKey: [SALES_KEY, id],
    queryFn: () => salesApi.getById(id),
    enabled: !!id,
  });
}

export function useSaleByNumber(saleNumber: string) {
  return useQuery({
    queryKey: [SALES_KEY, 'number', saleNumber],
    queryFn: () => salesApi.getBySaleNumber(saleNumber),
    enabled: !!saleNumber,
  });
}

export function useSalesByDateRange(startDate: string, endDate: string) {
  return useQuery({
    queryKey: [SALES_KEY, 'date-range', startDate, endDate],
    queryFn: () => salesApi.getByDateRange(startDate, endDate),
    enabled: !!startDate && !!endDate,
  });
}

export function useCreateSale() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (dto: CreateSalesDto) => salesApi.create(dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [SALES_KEY] }),
  });
}

export function useUpdateSale() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: number; dto: UpdateSalesDto }) => salesApi.update(id, dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [SALES_KEY] }),
  });
}

export function useDeleteSale() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => salesApi.delete(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [SALES_KEY] }),
  });
}
