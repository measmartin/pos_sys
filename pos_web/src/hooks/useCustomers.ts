import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { customersApi } from '../api';
import type { CreateCustomerDto, UpdateCustomerDto, CustomerQueryParams } from '@PosApi/types';

const CUSTOMERS_KEY = 'customers';

export function useCustomersList(params?: CustomerQueryParams) {
  return useQuery({
    queryKey: [CUSTOMERS_KEY, params],
    queryFn: () => customersApi.getAll(params),
  });
}

export function useCustomer(id: number) {
  return useQuery({
    queryKey: [CUSTOMERS_KEY, id],
    queryFn: () => customersApi.getById(id),
    enabled: !!id,
  });
}

export function useCustomerByPhone(phone: string) {
  return useQuery({
    queryKey: [CUSTOMERS_KEY, 'phone', phone],
    queryFn: () => customersApi.getByPhone(phone),
    enabled: !!phone,
  });
}

export function useCreateCustomer() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (dto: CreateCustomerDto) => customersApi.create(dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CUSTOMERS_KEY] }),
  });
}

export function useUpdateCustomer() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: number; dto: UpdateCustomerDto }) => customersApi.update(id, dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CUSTOMERS_KEY] }),
  });
}

export function useDeleteCustomer() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => customersApi.delete(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [CUSTOMERS_KEY] }),
  });
}
