import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productUnitsApi } from '../api';
import type { CreateProductUnitDto, UpdateProductUnitDto, ProductUnitQueryParams } from '@PosApi/types';

const PRODUCT_UNITS_KEY = 'productUnits';

export function useProductUnitsList(params?: ProductUnitQueryParams) {
  return useQuery({
    queryKey: [PRODUCT_UNITS_KEY, params],
    queryFn: () => productUnitsApi.getAll(params),
  });
}

export function useProductUnit(id: number) {
  return useQuery({
    queryKey: [PRODUCT_UNITS_KEY, id],
    queryFn: () => productUnitsApi.getById(id),
    enabled: !!id,
  });
}

export function useProductUnitsByProduct(productId: number) {
  return useQuery({
    queryKey: [PRODUCT_UNITS_KEY, 'product', productId],
    queryFn: () => productUnitsApi.getByProductId(productId),
    enabled: !!productId,
  });
}

export function useCreateProductUnit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (dto: CreateProductUnitDto) => productUnitsApi.create(dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [PRODUCT_UNITS_KEY] }),
  });
}

export function useUpdateProductUnit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, dto }: { id: number; dto: UpdateProductUnitDto }) =>
      productUnitsApi.update(id, dto),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [PRODUCT_UNITS_KEY] }),
  });
}

export function useDeleteProductUnit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: number) => productUnitsApi.delete(id),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [PRODUCT_UNITS_KEY] }),
  });
}

export function useUploadProductUnitImage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, file }: { id: number; file: File }) =>
      productUnitsApi.uploadImage(id, file),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: [PRODUCT_UNITS_KEY] }),
  });
}
