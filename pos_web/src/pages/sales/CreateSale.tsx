import { useState, useMemo, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCreateSale, useProductsList } from '@/hooks';
import { useCurrenciesList } from '@/hooks';
import { useCustomersList, useCreateCustomer } from '@/hooks';
import { Button } from '@/components/ui/button';
import { TextInput } from '@/components/forms/TextInput';
import { SelectInput } from '@/components/forms/SelectInput';
import type { CreateSalesDto, CreateSalesItemDto, CreateCustomerDto } from '@PosApi/types';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger } from '@/components/ui/select';
import { Trash2, UserPlus, Search, ImageIcon, Check, Percent } from 'lucide-react';
import { formatCurrency, roundForCurrency } from '@/utils/formatting';
import { toast } from 'sonner';


const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5010';

interface LineItemDisplay {
  id: string;
  productId: number;
  productUnitId: number;
  productName: string;
  unitName: string;
  quantity: string;
  unitPrice: string;
  originalUnitPrice: number;
  discountAmount: string;
  discountPercentage: string;
  units: { productUnitId: number; unitName: string; price: number; currencySymbol?: string | null }[];
}

export function CreateSale({ onSaleCreated }: { onSaleCreated?: () => void }) {
  const navigate = useNavigate();
  const createMutation = useCreateSale();
  const createCustomerMutation = useCreateCustomer();
  const { data: currenciesData } = useCurrenciesList();
  const { data: customersData } = useCustomersList({ pageSize: 200 });

  const [selectedCustomerId, setSelectedCustomerId] = useState<string>('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [newCustomerName, setNewCustomerName] = useState('');
  const [currencyId, setCurrencyId] = useState('');
  const [amountPaid, setAmountPaid] = useState('0');
  const [paymentStatus, setPaymentStatus] = useState('PAID');
  const [items, setItems] = useState<LineItemDisplay[]>([]);
  const [productSearch, setProductSearch] = useState('');
  const [discountAmount, setDiscountAmount] = useState('0');
  const [discountPercentage, setDiscountPercentage] = useState('0');

  const { data: productsData, isLoading: productsLoading } = useProductsList({ search: productSearch, pageSize: 50 });
  const currencies = currenciesData?.data ?? [];
  const products = productsData?.data ?? [];
  const customers = customersData?.data ?? [];

  const baseCurrency = currencies.find((c) => c.isBaseCurrency);
  const selectedCurrency = currencies.find((c) => String(c.currencyId) === currencyId) ?? baseCurrency;
  const exchangeRate = selectedCurrency && !selectedCurrency.isBaseCurrency ? selectedCurrency.exchangeRate : 1;
  const currencyCode = selectedCurrency?.currencyCode;
  const currencySymbol = selectedCurrency?.currencySymbol ?? selectedCurrency?.currencyCode ?? '$';

  const inCartKeys = new Set(
    items.map((it) => `${it.productId}-${it.productUnitId}`)
  );

  const addItem = (
    productId: number,
    productUnitId: number,
    unitPrice: number,
    productName: string,
    unitName: string,
    units: { productUnitId: number; unitName: string; price: number; currencySymbol?: string | null }[],
  ) => {
    const key = `${productId}-${productUnitId}`;
    if (inCartKeys.has(key)) {
      setItems((prev) =>
        prev.map((it) =>
          it.productId === productId && it.productUnitId === productUnitId
            ? { ...it, quantity: String(Number(it.quantity) + 1) }
            : it
        )
      );
      toast.success('Increased quantity');
      return;
    }
    const convertedPrice = roundForCurrency(unitPrice * exchangeRate, currencyCode);
    setItems((prev) => [
      ...prev,
      {
        id: `${productId}-${productUnitId}-${Date.now()}`,
        productId,
        productUnitId,
        productName,
        unitName,
        quantity: '1',
        unitPrice: String(convertedPrice),
        originalUnitPrice: unitPrice,
        discountAmount: '0',
        discountPercentage: '0',
        units,
      },
    ]);
    toast.success('Item added to sale');
  };

  const removeItem = (idx: number) =>
    setItems((prev) => prev.filter((_, i) => i !== idx));

  const updateItem = (idx: number, field: keyof LineItemDisplay, value: string) =>
    setItems((prev) =>
      prev.map((item, i) => {
        if (i !== idx) return item;

        let safeValue = value;
        if (field === 'discountAmount') {
          const num = Number(value);
          safeValue = value === '' ? '' : num < 0 ? '0' : value;
        } else if (field === 'discountPercentage') {
          const num = Number(value);
          safeValue = value === '' ? '' : num < 0 ? '0' : num > 100 ? '100' : value;
        }

        const updated = { ...item, [field]: safeValue };

        if (field === 'unitPrice') {
          const num = Number(safeValue);
          updated.originalUnitPrice = num > 0 ? num / exchangeRate : item.originalUnitPrice;
        }

        const qty = Number(updated.quantity) || 0;
        const price = Number(updated.unitPrice) || 0;
        const lineSubtotal = qty * price;
        if (lineSubtotal > 0) {
          if (field === 'discountAmount') {
            const amt = roundForCurrency(Number(safeValue) || 0, currencyCode);
            updated.discountAmount = String(amt);
            updated.discountPercentage = amt > 0 ? String((amt / lineSubtotal * 100).toFixed(2)) : '0';
          } else if (field === 'discountPercentage') {
            const pct = Number(safeValue) || 0;
            const amount = roundForCurrency(lineSubtotal * pct / 100, currencyCode);
            updated.discountAmount = String(amount);
            updated.discountPercentage = pct > 0 ? String(pct) : '0';
          }
        }
        return updated;
      }),
    );

  const changeUnit = (idx: number, newProductUnitId: string) => {
    const unitId = Number(newProductUnitId);
    setItems((prev) =>
      prev.map((item, i) => {
        if (i !== idx) return item;
        const unit = item.units.find((u) => u.productUnitId === unitId);
        if (!unit) return item;
        return {
          ...item,
          productUnitId: unit.productUnitId,
          unitName: unit.unitName,
          unitPrice: String(unit.price),
        };
      }),
    );
  };

  const calcItemLineTotal = useCallback((item: LineItemDisplay) => {
    const qty = Number(item.quantity) || 0;
    const price = Number(item.unitPrice) || 0;
    const lineSubtotal = qty * price;
    const amtDisc = Number(item.discountAmount) || 0;
    const pctDisc = Number(item.discountPercentage) || 0;
    const effective = amtDisc > 0 ? amtDisc : lineSubtotal * pctDisc / 100;
    return roundForCurrency(lineSubtotal - effective, currencyCode);
  }, [currencyCode]);

  const subtotal = items.reduce((sum, it) => {
    const qty = Number(it.quantity) || 0;
    const price = Number(it.unitPrice) || 0;
    return sum + roundForCurrency(qty * price, currencyCode);
  }, 0);

  const itemDiscountTotal = items.reduce((sum, it) => {
    const qty = Number(it.quantity) || 0;
    const price = Number(it.unitPrice) || 0;
    const lineSubtotal = qty * price;
    const amtDisc = Number(it.discountAmount) || 0;
    const pctDisc = Number(it.discountPercentage) || 0;
    return sum + roundForCurrency(amtDisc > 0 ? amtDisc : lineSubtotal * pctDisc / 100, currencyCode);
  }, 0);

  const saleDiscountAmt = Number(discountAmount) || 0;
  const saleDiscountPct = Number(discountPercentage) || 0;
  const saleDiscountFromPct = roundForCurrency((subtotal - itemDiscountTotal) * saleDiscountPct / 100, currencyCode);
  const effectiveSaleDiscount = saleDiscountAmt > 0 ? roundForCurrency(saleDiscountAmt, currencyCode) : saleDiscountFromPct;

  const totalDiscount = roundForCurrency(itemDiscountTotal + effectiveSaleDiscount, currencyCode);
  const total = roundForCurrency(subtotal - totalDiscount, currencyCode);
  const paid = roundForCurrency(Number(amountPaid) || 0, currencyCode);
  const change = Math.max(0, roundForCurrency(paid - total, currencyCode));

  const [amountPaidManuallyEdited, setAmountPaidManuallyEdited] = useState(false);
  const suggestedAmountPaid = useMemo(() => {
    if (paymentStatus === 'UNPAID') return '0';
    if (paymentStatus === 'PAID') return total.toFixed(2);
    return amountPaid;
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [paymentStatus, total]);

  // Sync when payment status changes if user hasn't manually edited
  if (!amountPaidManuallyEdited && suggestedAmountPaid !== amountPaid) {
    setAmountPaid(suggestedAmountPaid);
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const salesItems: CreateSalesItemDto[] = items
      .filter((it) => it.quantity && it.unitPrice)
      .map((it) => {
        const amtDisc = Number(it.discountAmount) || 0;
        const pctDisc = Number(it.discountPercentage) || 0;
        return {
          productId: it.productId,
          productUnitId: it.productUnitId,
          quantity: Number(it.quantity),
          unitPrice: Number(it.unitPrice),
          discountAmount: amtDisc > 0 ? amtDisc : undefined,
          discountPercentage: pctDisc > 0 ? pctDisc : undefined,
        };
      });

    if (salesItems.length === 0) {
      toast.error('Please add at least one item');
      return;
    }

    if (!phoneNumber.trim()) {
      toast.error('Phone number is required');
      return;
    }

    let customerId: number | undefined;

    if (selectedCustomerId === 'new' && newCustomerName.trim()) {
      try {
        const newCustomer: CreateCustomerDto = {
          customerName: newCustomerName.trim(),
          phoneNumber: phoneNumber.trim(),
        };
        customerId = await createCustomerMutation.mutateAsync(newCustomer);
        toast.success('Customer created');
      } catch {
        toast.error('Failed to create customer');
      }
    } else if (selectedCustomerId && selectedCustomerId !== 'new') {
      customerId = Number(selectedCustomerId);
    }

    const dto: CreateSalesDto = {
      customerId,
      phoneNumber: phoneNumber.trim(),
      currencyId: Number(currencyId) || 1,
      amountPaid: paid,
      paymentStatus,
      saleStatus: 'COMPLETED',
      discountAmount: saleDiscountAmt > 0 ? saleDiscountAmt : undefined,
      discountPercentage: saleDiscountPct > 0 ? saleDiscountPct : undefined,
      items: salesItems,
    };

    try {
      const id = await createMutation.mutateAsync(dto);
      toast.success('Sale created successfully', {
        action: {
          label: 'Print Receipt',
          onClick: () => {
            // Navigate to sale detail for printing, or print from here if data is available
            navigate(`/sales/${id}`);
          },
        },
      });
      setItems([]);
      setPhoneNumber('');
      setNewCustomerName('');
      setSelectedCustomerId('');
      setAmountPaid('0');
      setPaymentStatus('PAID');
      setCurrencyId('');
      setDiscountAmount('0');
      setDiscountPercentage('0');
      if (onSaleCreated) {
        onSaleCreated();
      }
    } catch {
      toast.error('Failed to create sale');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base">Sale Details</CardTitle>
        </CardHeader>
        <CardContent className="grid gap-4 md:grid-cols-3">
          <div className="space-y-1">
            <label className="text-sm font-medium">Customer</label>
            <Select
              value={selectedCustomerId}
              onValueChange={(v) => {
                if (!v) return;
                setSelectedCustomerId(v);
                if (v !== 'new') {
                  const customer = customers.find((c) => String(c.customerId) === v);
                  if (customer?.phoneNumber) {
                    setPhoneNumber(customer.phoneNumber);
                  }
                } else {
                  setPhoneNumber('');
                }
              }}
            >
              <SelectTrigger className="h-9">
                <span className="truncate">
                  {selectedCustomerId === 'new'
                    ? 'New Customer'
                    : selectedCustomerId
                      ? customers.find((c) => String(c.customerId) === selectedCustomerId)?.customerName ?? 'Select customer'
                      : 'Walk-in Customer'
                  }
                </span>
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="walkin">Walk-in Customer</SelectItem>
                <SelectItem value="new">
                  <span className="flex items-center gap-2">
                    <UserPlus className="size-3.5" />
                    New Customer
                  </span>
                </SelectItem>
                {customers.map((c) => (
                  <SelectItem key={c.customerId} value={String(c.customerId)}>
                    {c.customerName}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1">
            <TextInput
              label="Phone Number *"
              value={phoneNumber}
              onChange={(e) => setPhoneNumber(e.target.value)}
            />
          </div>
          {selectedCustomerId === 'new' && (
            <div className="space-y-1">
              <TextInput
                label="Customer Name"
                value={newCustomerName}
                onChange={(e) => setNewCustomerName(e.target.value)}
              />
            </div>
          )}
          <SelectInput
            label="Currency"
            value={currencyId}
            onChange={(value) => {
              setCurrencyId(value ?? '');
              setDiscountAmount('0');
              setDiscountPercentage('0');
              setAmountPaid('0');
              const newCurrency = currencies.find((c) => String(c.currencyId) === value);
              const newRate = newCurrency && !newCurrency.isBaseCurrency ? newCurrency.exchangeRate : 1;
              setItems((prev) => prev.map((item) => ({
                ...item,
                unitPrice: String((item.originalUnitPrice * newRate).toFixed(2)),
              })));
            }}
            options={currencies.map((c) => ({
              value: c.currencyId,
              label: `${c.currencyCode} (${c.currencySymbol ?? ''})`,
            }))}
            placeholder="Select currency"
          />
          <SelectInput
            label="Payment Status"
            value={paymentStatus}
            onChange={(value) => {
              setPaymentStatus(value ?? 'PAID');
              setAmountPaidManuallyEdited(false);
            }}
            options={[
              { value: 'PAID', label: 'Completed' },
              { value: 'PARTIAL', label: 'Partial' },
              { value: 'UNPAID', label: 'Unpaid' },
            ]}
          />
        </CardContent>
      </Card>

      <div className="grid gap-4 lg:grid-cols-5">
        <Card className="lg:col-span-3">
          <CardHeader className="pb-3">
            <CardTitle className="text-base">Cart ({items.length})</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {items.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">
                <p className="text-sm">No items yet</p>
                <p className="text-xs mt-1">Click a product on the right to add it</p>
              </div>
            ) : (
              items.map((item, idx) => {
                const lineTotal = calcItemLineTotal(item);
                return (
                  <div key={item.id} className="rounded-lg border p-3 space-y-3">
                    <div className="grid gap-3 md:grid-cols-12 items-end">
                      <div className="md:col-span-3">
                        <label className="text-xs text-muted-foreground block mb-1">Product</label>
                        <p className="text-sm font-medium truncate">{item.productName}</p>
                      </div>
                      <div className="md:col-span-2">
                        <label className="text-xs text-muted-foreground block mb-1">Unit</label>
                        <Select
                          value={String(item.productUnitId)}
                          onValueChange={(v) => { if (v) changeUnit(idx, v); }}
                        >
                          <SelectTrigger className={`h-8 text-xs ${item.units.length <= 1 ? '[&>svg]:hidden' : ''}`}>
                            <span className="truncate">{item.unitName}</span>
                          </SelectTrigger>
                          <SelectContent>
                            {item.units.map((u) => (
                              <SelectItem key={u.productUnitId} value={String(u.productUnitId)}>
                                {u.unitName} - {formatCurrency(u.price * exchangeRate, currencySymbol, currencyCode)}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
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
                        <p className="text-sm font-medium">{formatCurrency(lineTotal, currencySymbol, currencyCode)}</p>
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
                    <div className="grid gap-3 md:grid-cols-2">
                      <div className="relative">
                        <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-xs text-muted-foreground font-medium">{currencySymbol}</span>
                        <Input
                          className="pl-8 h-8 text-xs"
                          placeholder="Discount amount"
                          type="text"
                          inputMode="decimal"
                          value={item.discountAmount}
                          onChange={(e) => updateItem(idx, 'discountAmount', e.target.value)}
                        />
                      </div>
                      <div className="relative">
                        <Percent className="absolute left-2.5 top-1/2 -translate-y-1/2 size-3.5 text-muted-foreground" />
                        <Input
                          className="pl-8 h-8 text-xs"
                          placeholder="Discount %"
                          type="text"
                          inputMode="decimal"
                          value={item.discountPercentage}
                          onChange={(e) => updateItem(idx, 'discountPercentage', e.target.value)}
                        />
                      </div>
                    </div>
                  </div>
                );
              })
            )}
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader className="pb-3">
            <CardTitle className="text-base">Products</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
              <Input
                className="pl-9"
                placeholder="Search products..."
                value={productSearch}
                onChange={(e) => setProductSearch(e.target.value)}
              />
            </div>
            <div className="max-h-[480px] overflow-y-auto -mx-1 px-1">
              {productsLoading ? (
                <div className="flex justify-center py-8">
                  <div className="animate-spin rounded-full size-6 border-b-2 border-primary" />
                </div>
              ) : products.length === 0 ? (
                <p className="text-center text-sm text-muted-foreground py-8">No products found</p>
              ) : (
                <div className="grid grid-cols-2 gap-2">
                  {products.map((product) => {
                    const defaultUnit = product.units?.find((u) => u.isDefault) ?? product.units?.[0];
                    if (!defaultUnit) return null;
                    const inCart = inCartKeys.has(`${product.productId}-${defaultUnit.productUnitId}`);
                    return (
                      <button
                        key={product.productId}
                        type="button"
                        onClick={() =>
                          addItem(
                            product.productId,
                            defaultUnit.productUnitId,
                            defaultUnit.price,
                            product.productName,
                            defaultUnit.unitName ?? '',
                            (product.units ?? []).map((u) => ({
                              productUnitId: u.productUnitId,
                              unitName: u.unitName ?? '',
                              price: u.price,
                              currencySymbol: u.currencySymbol,
                            })),
                          )
                        }
                        className={`relative flex flex-col items-center gap-2 rounded-lg border p-3 text-left transition-colors ${
                          inCart
                            ? 'border-primary bg-primary/5 ring-1 ring-primary'
                            : 'hover:border-primary/50 hover:bg-accent'
                        }`}
                      >
                        {inCart && (
                          <span className="absolute top-1.5 right-1.5 flex size-5 items-center justify-center rounded-full bg-primary text-primary-foreground">
                            <Check className="size-3" />
                          </span>
                        )}
                        <div className="size-12 shrink-0 rounded-md border overflow-hidden bg-muted flex items-center justify-center">
                          {defaultUnit.imageUrl ? (
                            <img
                              src={`${API_BASE_URL}/api/productunits/${defaultUnit.productUnitId}/image`}
                              alt={product.productName}
                              className="size-full object-cover"
                              onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                            />
                          ) : (
                            <ImageIcon className="size-5 text-muted-foreground" />
                          )}
                        </div>
                        <div className="w-full min-w-0 text-center">
                          <p className="text-xs font-medium truncate">{product.productName}</p>
                          <p className="text-xs text-muted-foreground">
                            {formatCurrency(defaultUnit.price * exchangeRate, currencySymbol, currencyCode)}
                          </p>
                        </div>
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base">Summary</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {items.length > 0 && (
            <div className="space-y-2">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Discounts</p>
              <div className="grid grid-cols-2 gap-3">
                <div className="relative">
                  <span className="absolute left-2.5 top-1/2 -translate-y-1/2 text-xs text-muted-foreground font-medium">{currencySymbol}</span>
                  <Input
                    className="pl-8 h-8 text-xs"
                    placeholder="Discount amount"
                    type="text"
                    inputMode="decimal"
                    value={discountAmount}
                    onChange={(e) => {
                      const raw = e.target.value;
                      const num = Number(raw);
                      const safe = raw === '' ? '' : num < 0 ? '0' : raw;
                      setDiscountAmount(safe);
                      const amt = roundForCurrency(Number(safe) || 0, currencyCode);
                      setDiscountAmount(String(amt));
                      const netAmount = subtotal - itemDiscountTotal;
                      if (netAmount > 0) {
                        setDiscountPercentage(amt > 0 ? String((amt / netAmount * 100).toFixed(2)) : '0');
                      }
                    }}
                  />
                </div>
                <div className="relative">
                  <Percent className="absolute left-2.5 top-1/2 -translate-y-1/2 size-3.5 text-muted-foreground" />
                  <Input
                    className="pl-8 h-8 text-xs"
                    placeholder="Discount %"
                    type="text"
                    inputMode="decimal"
                    value={discountPercentage}
                    onChange={(e) => {
                      const raw = e.target.value;
                      const num = Number(raw);
                      const safe = raw === '' ? '' : num < 0 ? '0' : num > 100 ? '100' : raw;
                      setDiscountPercentage(safe);
                      const pct = Number(safe) || 0;
                      const netAmount = subtotal - itemDiscountTotal;
                      if (netAmount > 0) {
                        setDiscountAmount(pct > 0 ? String((netAmount * pct / 100).toFixed(2)) : '0');
                      }
                    }}
                  />
                </div>
              </div>
            </div>
          )}

          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-muted-foreground">Subtotal</span>
              <span className="font-medium">{formatCurrency(subtotal, currencySymbol, currencyCode)}</span>
            </div>
            {itemDiscountTotal > 0 && (
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Item Discounts</span>
                <span className="font-medium text-success">-{formatCurrency(itemDiscountTotal, currencySymbol, currencyCode)}</span>
              </div>
            )}
            {effectiveSaleDiscount > 0 && (
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Sale Discount</span>
                <span className="font-medium text-success">-{formatCurrency(effectiveSaleDiscount, currencySymbol, currencyCode)}</span>
              </div>
            )}
            {totalDiscount > 0 && (
              <div className="flex justify-between text-sm border-t pt-2">
                <span className="text-muted-foreground">Total Discount</span>
                <span className="font-medium text-success">-{formatCurrency(totalDiscount, currencySymbol, currencyCode)}</span>
              </div>
            )}
            <div className="flex justify-between text-sm border-t pt-2">
              <span className="font-semibold">Total</span>
              <span className="font-bold text-lg">{formatCurrency(total, currencySymbol, currencyCode)}</span>
            </div>
          </div>

          <div className="space-y-2 border-t pt-4">
            <TextInput
              label="Amount Paid"
              type="number"
              step="0.01"
              min="0"
              value={amountPaid}
              onChange={(e) => {
                setAmountPaidManuallyEdited(true);
                setAmountPaid(e.target.value);
              }}
            />
            {change > 0 && (
              <div className="flex justify-between text-sm">
                <span className="text-muted-foreground">Change</span>
                <span className="font-bold text-success">{formatCurrency(change, currencySymbol, currencyCode)}</span>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      <div className="flex justify-end">
        <Button type="submit" disabled={createMutation.isPending || items.length === 0}>
          {createMutation.isPending ? 'Creating...' : 'Create Sale'}
        </Button>
      </div>
    </form>
  );
}

export default CreateSale;
