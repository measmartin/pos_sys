import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { currenciesApi } from '../api';
import type { CreateCurrencyDto, UpdateCurrencyDto, CurrencyQueryParams } from '@PosApi/types';

const CURRENCIES_KEY = 'currencies';

export function useCurrenciesList(params?: CurrencyQueryParams) {
  return useQuery({
    queryKey: [CURRENCIES_KEY, params],
    queryFn: () => currenciesApi.getAll(params),
  });
}

export function useCurrency(id: number) {
  return useQuery({
    queryKey: [CURRENCIES_KEY, id],
    queryFn: () => currenciesApi.getById(id),
    enabled: !!id,
  });
}

export function useCreateCurrency() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (dto: CreateCurrencyDto) => currenciesApi.create(dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CURRENCIES_KEY] }),
  });
}

export function useUpdateCurrency() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: number; dto: UpdateCurrencyDto }) => currenciesApi.update(id, dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CURRENCIES_KEY] }),
  });
}

export function useDeleteCurrency() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => currenciesApi.delete(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CURRENCIES_KEY] }),
  });
}
