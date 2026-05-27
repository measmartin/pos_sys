import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useCreateProduct, useUpdateProduct, useProduct, useCategoriesList, useUnitsList } from '../hooks';
import { Button } from '@/components/ui/button';
import { TextInput } from '../components/forms/TextInput';
import { SelectInput } from '../components/forms/SelectInput';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowLeft } from 'lucide-react';
import type { ProductDetailsDto } from '@PosApi/types';

interface ProductFormData {
  productCode: string;
  productName: string;
  description: string;
  categoryId: string;
  baseUnitId: string;
}

function ProductFormInner({ product, onCancel }: { product?: ProductDetailsDto; onCancel: () => void }) {
  const navigate = useNavigate();
  const { data: categoriesData } = useCategoriesList();
  const { data: unitsData } = useUnitsList();
  const createMutation = useCreateProduct();
  const updateMutation = useUpdateProduct();
  const isEdit = !!product;

  const [form, setForm] = useState<ProductFormData>({
    productCode: product?.productCode ?? '',
    productName: product?.productName ?? '',
    description: product?.description ?? '',
    categoryId: product ? String(product.categoryId) : '',
    baseUnitId: product ? String(product.baseUnitId) : '',
  });

  const update = (field: keyof ProductFormData, value: string) =>
    setForm((prev) => ({ ...prev, [field]: value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const dto = {
      productCode: form.productCode,
      productName: form.productName,
      categoryId: Number(form.categoryId),
      baseUnitId: Number(form.baseUnitId),
      description: form.description || null,
    };

    if (isEdit) {
      await updateMutation.mutateAsync({ id: product.productId, dto });
    } else {
      await createMutation.mutateAsync(dto);
    }
    navigate('/products');
  };

  const isPending = createMutation.isPending || updateMutation.isPending;
  const categories = categoriesData?.data ?? [];
  const units = unitsData?.data ?? [];

  return (
    <form onSubmit={handleSubmit}>
      <Card>
        <CardHeader>
          <CardTitle>Product Information</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-2">
          <TextInput
            label="Product Code"
            value={form.productCode}
            onChange={(e) => update('productCode', e.target.value)}
            required
          />
          <TextInput
            label="Product Name"
            value={form.productName}
            onChange={(e) => update('productName', e.target.value)}
            required
          />
          <SelectInput
            label="Category"
            value={form.categoryId}
            onChange={(value) => update('categoryId', value ?? '')}
            options={categories.map((c) => ({ value: c.categoryId, label: c.categoryName }))}
            placeholder="Select category"
            required
          />
          <SelectInput
            label="Base Unit"
            value={form.baseUnitId}
            onChange={(value) => update('baseUnitId', value ?? '')}
            options={units.map((u) => ({ value: u.unitId, label: `${u.unitName} (${u.unitCode})` }))}
            placeholder="Select unit"
            required
          />
          <div className="md:col-span-2">
            <TextInput
              label="Description"
              value={form.description}
              onChange={(e) => update('description', e.target.value)}
            />
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-end gap-3 mt-6">
        <Button variant="outline" onClick={onCancel}>Cancel</Button>
        <Button type="submit" disabled={isPending}>
          {isPending ? 'Saving...' : isEdit ? 'Update Product' : 'Create Product'}
        </Button>
      </div>
    </form>
  );
}

export function ProductForm() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const isEdit = !!id;
  const { data: existingProduct, isLoading } = useProduct(Number(id));

  if (isEdit && isLoading) {
    return (
      <div className="space-y-6">
        <Skeleton className="h-8 w-48" />
        <Card>
          <CardContent className="p-6 space-y-4">
            <Skeleton className="h-10 w-full" />
            <Skeleton className="h-10 w-full" />
            <Skeleton className="h-10 w-full" />
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="space-y-6" key={id ?? 'new'}>
      <div>
        <Button variant="link" size="sm" onClick={() => navigate('/products')} className="px-0">
          <ArrowLeft className="size-3.5" />
          Back to Products
        </Button>
        <h1 className="text-2xl font-bold tracking-tight">
          {isEdit ? 'Edit Product' : 'Create Product'}
        </h1>
      </div>
      <ProductFormInner product={existingProduct} onCancel={() => navigate('/products')} />
    </div>
  );
}
