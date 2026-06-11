import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useCreateProduct, useUpdateProduct, useProduct, useCategoriesList, useUnitsList } from '@/hooks';
import { productUnitsApi } from '@/api';
import { Button } from '@/components/ui/button';
import { TextInput } from '@/components/forms/TextInput';
import { SelectInput } from '@/components/forms/SelectInput';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Input } from '@/components/ui/input';
import { ArrowLeft, Plus, Trash2, Package } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';
import { toast } from 'sonner';
import type { ProductDetailsDto } from '@PosApi/types';

interface ProductFormData {
  productCode: string;
  productName: string;
  description: string;
  categoryId: string;
  baseUnitId: string;
}

interface AdditionalUnit {
  unitId: string;
  unitName: string;
  price: string;
  conversionRate: string;
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

  const [baseUnitPrice, setBaseUnitPrice] = useState('');
  const [additionalUnits, setAdditionalUnits] = useState<AdditionalUnit[]>([]);
  const [newUnitId, setNewUnitId] = useState('');
  const [newUnitPrice, setNewUnitPrice] = useState('');
  const [newUnitConversion, setNewUnitConversion] = useState('1');

  const update = (field: keyof ProductFormData, value: string) =>
    setForm((prev) => ({ ...prev, [field]: value }));

  const handleAddUnit = () => {
    if (!newUnitId || !newUnitPrice) {
      toast.error('Please select a unit and enter a price');
      return;
    }
    const unit = units.find((u) => String(u.unitId) === newUnitId);
    if (!unit) return;
    setAdditionalUnits((prev) => [
      ...prev,
      {
        unitId: newUnitId,
        unitName: `${unit.unitName} (${unit.unitCode})`,
        price: newUnitPrice,
        conversionRate: newUnitConversion || '1',
      },
    ]);
    setNewUnitId('');
    setNewUnitPrice('');
    setNewUnitConversion('1');
  };

  const handleRemoveUnit = (index: number) => {
    setAdditionalUnits((prev) => prev.filter((_, i) => i !== index));
  };

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
      navigate('/products');
    } else {
      const newProductId = await createMutation.mutateAsync(dto);

      if (baseUnitPrice) {
        try {
          await productUnitsApi.create({
            productId: newProductId,
            unitId: Number(form.baseUnitId),
            conversionRate: 1,
            price: Number(baseUnitPrice),
            isDefault: true,
          });
        } catch {
          toast.error('Failed to create base unit. You can add it from the product details page.');
        }
      }

      for (const unit of additionalUnits) {
        try {
          await productUnitsApi.create({
            productId: newProductId,
            unitId: Number(unit.unitId),
            conversionRate: Number(unit.conversionRate) || 1,
            price: Number(unit.price),
            isDefault: false,
          });
        } catch {
          toast.error(`Failed to add unit ${unit.unitName}. You can add it from the product details page.`);
        }
      }

      navigate(`/products/${newProductId}`);
    }
  };

  const isPending = createMutation.isPending || updateMutation.isPending;
  const categories = categoriesData?.data ?? [];
  const units = unitsData?.data ?? [];

  const baseUnitName = units.find((u) => String(u.unitId) === form.baseUnitId)
    ? `${units.find((u) => String(u.unitId) === form.baseUnitId)!.unitName} (${units.find((u) => String(u.unitId) === form.baseUnitId)!.unitCode})`
    : null;

  const usedUnitIds = new Set([
    form.baseUnitId,
    ...additionalUnits.map((u) => u.unitId),
  ]);
  const availableUnitsForAdditional = units.filter(
    (u) => !usedUnitIds.has(String(u.unitId))
  );

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
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
            onChange={(value) => {
              update('baseUnitId', value ?? '');
              setBaseUnitPrice('');
              setAdditionalUnits([]);
            }}
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

      {!isEdit && (
        <Card>
          <CardHeader>
            <CardTitle>Units & Pricing</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-1">
                <label className="text-sm font-medium">
                  Base Unit Price {baseUnitName && <span className="text-muted-foreground">({baseUnitName})</span>}
                </label>
                <Input
                  type="number"
                  step="0.01"
                  value={baseUnitPrice}
                  onChange={(e) => setBaseUnitPrice(e.target.value)}
                  placeholder="0.00"
                  disabled={!form.baseUnitId}
                />
              </div>
            </div>

            <div className="space-y-3 border rounded-lg p-4">
              <h4 className="text-sm font-medium">Additional Units</h4>
              <div className="grid gap-3 md:grid-cols-4 items-end">
                <div className="space-y-1">
                  <label className="text-sm font-medium">Unit</label>
                  <SelectInput
                    value={newUnitId}
                    onChange={(value) => setNewUnitId(value ?? '')}
                    options={availableUnitsForAdditional.map((u) => ({
                      value: u.unitId,
                      label: `${u.unitName} (${u.unitCode})`,
                    }))}
                    placeholder="Select unit"
                    label=""
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-sm font-medium">Price</label>
                  <Input
                    type="number"
                    step="0.01"
                    value={newUnitPrice}
                    onChange={(e) => setNewUnitPrice(e.target.value)}
                    placeholder="0.00"
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-sm font-medium">Conversion Rate</label>
                  <Input
                    type="number"
                    step="0.01"
                    value={newUnitConversion}
                    onChange={(e) => setNewUnitConversion(e.target.value)}
                    placeholder="1"
                  />
                </div>
                <Button
                  type="button"
                  variant="outline"
                  onClick={handleAddUnit}
                  disabled={!newUnitId || !newUnitPrice}
                >
                  <Plus className="size-4 mr-1" />
                  Add Unit
                </Button>
              </div>

              {additionalUnits.length > 0 && (
                <div className="border rounded-md overflow-hidden">
                  <table className="w-full text-sm">
                    <thead className="bg-muted">
                      <tr>
                        <th className="text-left px-3 py-2 font-medium">Unit</th>
                        <th className="text-left px-3 py-2 font-medium">Price</th>
                        <th className="text-left px-3 py-2 font-medium">Conversion</th>
                        <th className="px-3 py-2 w-10"></th>
                      </tr>
                    </thead>
                    <tbody>
                      {additionalUnits.map((unit, index) => (
                        <tr key={index} className="border-t">
                          <td className="px-3 py-2">{unit.unitName}</td>
                          <td className="px-3 py-2">{unit.price}</td>
                          <td className="px-3 py-2">{unit.conversionRate}</td>
                          <td className="px-3 py-2">
                            <Button
                              type="button"
                              variant="ghost"
                              size="sm"
                              className="h-6 w-6 p-0 text-destructive"
                              onClick={() => handleRemoveUnit(index)}
                            >
                              <Trash2 className="size-3.5" />
                            </Button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      )}

      <div className="flex justify-end gap-3">
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
    <PageLayout
      icon={Package}
      title={isEdit ? 'Edit Product' : 'Create Product'}
      action={
        <Button variant="link" size="sm" onClick={() => navigate('/products')} className="px-0">
          <ArrowLeft className="size-3.5" />
          Back to Products
        </Button>
      }
      key={id ?? 'new'}
    >
      <ProductFormInner product={existingProduct} onCancel={() => navigate('/products')} />
    </PageLayout>
  );
}

export default ProductForm;
