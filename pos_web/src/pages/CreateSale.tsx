import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCreateSale } from '../hooks';
import { useCurrenciesList } from '../hooks';
import { useCustomerByPhone } from '../hooks';
import { Button } from '@/components/ui/button';
import { TextInput } from '../components/forms/TextInput';
import { SelectInput } from '../components/forms/SelectInput';
import { ProductSelector } from '../components/products/ProductSelector';
import type { CreateSalesDto, CreateSalesItemDto } from '@PosApi/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Trash2, ArrowLeft, PackageSearch, UserCheck } from 'lucide-react';
import { toast } from 'sonner';

interface LineItemDisplay {
  id: string;
  productId: number;
  productUnitId: number;
  productName: string;
  unitName: string;
  quantity: string;
  unitPrice: string;
}

export function CreateSale() {
  const navigate = useNavigate();
  const createMutation = useCreateSale();
  const { data: currenciesData } = useCurrenciesList();

  const [phoneNumber, setPhoneNumber] = useState('');
  const [currencyId, setCurrencyId] = useState('');
  const [amountPaid, setAmountPaid] = useState('0');
  const [items, setItems] = useState<LineItemDisplay[]>([]);
  const [selectorOpen, setSelectorOpen] = useState(false);

  const { data: customerData } = useCustomerByPhone(phoneNumber);
  const currencies = currenciesData?.data ?? [];

  const addItem = (productId: number, productUnitId: number, unitPrice: number) => {
    setItems((prev) => [
      ...prev,
      {
        id: `${productId}-${productUnitId}-${Date.now()}`,
        productId,
        productUnitId,
        productName: '',
        unitName: '',
        quantity: '1',
        unitPrice: String(unitPrice),
      },
    ]);
    setSelectorOpen(false);
    toast.success('Item added to sale');
  };

  const removeItem = (idx: number) =>
    setItems((prev) => prev.filter((_, i) => i !== idx));

  const updateItem = (idx: number, field: keyof LineItemDisplay, value: string) =>
    setItems((prev) =>
      prev.map((item, i) => (i === idx ? { ...item, [field]: value } : item)),
    );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const salesItems: CreateSalesItemDto[] = items
      .filter((it) => it.quantity && it.unitPrice)
      .map((it) => ({
        productId: it.productId,
        productUnitId: it.productUnitId,
        quantity: Number(it.quantity),
        unitPrice: Number(it.unitPrice),
      }));

    if (salesItems.length === 0) {
      toast.error('Please add at least one item');
      return;
    }

    const dto: CreateSalesDto = {
      phoneNumber,
      currencyId: Number(currencyId) || 1,
      amountPaid: Number(amountPaid),
      items: salesItems,
    };

    try {
      const id = await createMutation.mutateAsync(dto);
      toast.success('Sale created successfully');
      navigate(`/sales/${id}`);
    } catch {
      toast.error('Failed to create sale');
    }
  };

  const subtotal = items.reduce((sum, it) => sum + (Number(it.quantity) || 0) * (Number(it.unitPrice) || 0), 0);
  const paid = Number(amountPaid) || 0;
  const change = paid - subtotal;

  return (
    <div className="space-y-6">
      <div>
        <Button variant="link" size="sm" onClick={() => navigate('/sales')} className="px-0">
          <ArrowLeft className="size-3.5" />
          Back to Sales
        </Button>
        <h1 className="text-2xl font-bold tracking-tight">Create Sale</h1>
      </div>

      <form onSubmit={handleSubmit}>
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Sale Details</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4 md:grid-cols-3">
            <div className="space-y-1">
              <TextInput
                label="Phone Number"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
              />
              {customerData && (
                <p className="flex items-center gap-1 text-xs text-green-600">
                  <UserCheck className="size-3" />
                  {customerData.customerName}
                </p>
              )}
            </div>
            <SelectInput
              label="Currency"
              value={currencyId}
              onChange={(value) => setCurrencyId(value ?? '')}
              options={currencies.map((c) => ({
                value: c.currencyId,
                label: `${c.currencyCode} (${c.currencySymbol ?? ''})`,
              }))}
              placeholder="Select currency"
            />
            <TextInput
              label="Amount Paid"
              type="number"
              step="0.01"
              value={amountPaid}
              onChange={(e) => setAmountPaid(e.target.value)}
            />
          </CardContent>
        </Card>

        <Card className="mb-6">
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Items ({items.length})</CardTitle>
            <Button type="button" variant="outline" size="sm" onClick={() => setSelectorOpen(true)}>
              <PackageSearch className="size-3.5" />
              Browse Products
            </Button>
          </CardHeader>
          <CardContent className="space-y-4">
            {items.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">
                <p className="text-sm">No items added yet</p>
                <p className="text-xs mt-1">Click "Browse Products" to add items</p>
              </div>
            ) : (
              items.map((item, idx) => (
                <div key={item.id} className="grid gap-3 md:grid-cols-12 items-end rounded-lg border p-3">
                  <div className="md:col-span-3">
                    <label className="text-xs text-muted-foreground block mb-1">Product</label>
                    <p className="text-sm font-medium">{item.productName || `Product #${item.productId}`}</p>
                  </div>
                  <div className="md:col-span-2">
                    <label className="text-xs text-muted-foreground block mb-1">Unit</label>
                    <p className="text-sm">{item.unitName || `Unit #${item.productUnitId}`}</p>
                  </div>
                  <div className="md:col-span-2">
                    <TextInput
                      label="Qty"
                      type="number"
                      step="0.01"
                      value={item.quantity}
                      onChange={(e) => updateItem(idx, 'quantity', e.target.value)}
                    />
                  </div>
                  <div className="md:col-span-2">
                    <TextInput
                      label="Price"
                      type="number"
                      step="0.01"
                      value={item.unitPrice}
                      onChange={(e) => updateItem(idx, 'unitPrice', e.target.value)}
                    />
                  </div>
                  <div className="md:col-span-2">
                    <label className="text-xs text-muted-foreground block mb-1">Total</label>
                    <p className="text-sm font-medium">
                      {(Number(item.quantity) * Number(item.unitPrice)).toFixed(2)}
                    </p>
                  </div>
                  <div className="md:col-span-1 flex items-end pb-1">
                    <Button
                      type="button"
                      variant="ghost"
                      size="sm"
                      onClick={() => removeItem(idx)}
                      className="text-destructive"
                    >
                      <Trash2 className="size-3.5" />
                    </Button>
                  </div>
                </div>
              ))
            )}
          </CardContent>
        </Card>

        <div className="grid gap-4 md:grid-cols-2 mb-6">
          <Card>
            <CardHeader>
              <CardTitle>Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Subtotal</span>
                <span className="font-medium">{subtotal.toFixed(2)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Amount Paid</span>
                <span className="font-medium">{paid.toFixed(2)}</span>
              </div>
              <div className="flex justify-between text-sm border-t pt-2">
                <span className="font-semibold">Change</span>
                <span className={`font-bold ${change >= 0 ? 'text-green-600' : 'text-destructive'}`}>
                  {change.toFixed(2)}
                </span>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="flex justify-end gap-3">
          <Button variant="outline" onClick={() => navigate('/sales')}>Cancel</Button>
          <Button type="submit" disabled={createMutation.isPending || items.length === 0}>
            {createMutation.isPending ? 'Creating...' : 'Create Sale'}
          </Button>
        </div>
      </form>

      <ProductSelector
        isOpen={selectorOpen}
        onClose={() => setSelectorOpen(false)}
        onSelect={addItem}
      />
    </div>
  );
}
