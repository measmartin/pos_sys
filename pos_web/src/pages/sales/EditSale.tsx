import { useState, useMemo } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useSale, useUpdateSale, useCurrenciesList, useCustomerByPhone } from '@/hooks';
import { Button } from '@/components/ui/button';
import { TextInput } from '@/components/forms/TextInput';
import { SelectInput } from '@/components/forms/SelectInput';
import { TextareaInput } from '@/components/forms/TextareaInput';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import type { UpdateSalesDto } from '@PosApi/types';
import { ArrowLeft, UserCheck, Loader2, ShoppingCart } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';
import { toast } from 'sonner';

export function EditSale() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const saleId = Number(id);
  const { data: sale, isLoading: saleLoading } = useSale(saleId);
  const updateMutation = useUpdateSale();
  const { data: currenciesData } = useCurrenciesList();

  const initial = useMemo(() => ({
    phoneNumber: sale?.phoneNumber ?? '',
    currencyId: sale ? String(sale.currencyId) : '',
    amountPaid: sale ? String(sale.amountPaid) : '0',
    saleStatus: sale?.saleStatus ?? 'COMPLETED',
    paymentStatus: sale?.paymentStatus ?? 'UNPAID',
    notes: sale?.notes ?? '',
    saleDate: sale ? sale.saleDate.split('T')[0] : '',
  }), [sale]);

  const [phoneNumber, setPhoneNumber] = useState(initial.phoneNumber);
  const [currencyId, setCurrencyId] = useState(initial.currencyId);
  const [amountPaid, setAmountPaid] = useState(initial.amountPaid);
  const [saleStatus, setSaleStatus] = useState(initial.saleStatus);
  const [paymentStatus, setPaymentStatus] = useState(initial.paymentStatus);
  const [notes, setNotes] = useState(initial.notes);
  const [saleDate, setSaleDate] = useState(initial.saleDate);

  const { data: customerData } = useCustomerByPhone(phoneNumber);
  const currencies = currenciesData?.data ?? [];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!sale) return;

    const dto: UpdateSalesDto = {
      saleDate: saleDate || new Date().toISOString(),
      customerId: sale.customerId,
      phoneNumber,
      currencyId: Number(currencyId) || 1,
      subtotal: sale.subtotal,
      totalDiscount: sale.totalDiscount,
      discountPercentage: sale.discountPercentage,
      totalAmount: sale.totalAmount,
      amountPaid: Number(amountPaid),
      paymentStatus,
      saleStatus,
      notes: notes || null,
    };

    try {
      await updateMutation.mutateAsync({ id: saleId, dto });
      toast.success('Sale updated successfully');
      navigate(`/sales/${saleId}`);
    } catch {
      toast.error('Failed to update sale');
    }
  };

  if (saleLoading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (!sale) {
    return (
      <div className="text-center py-12">
        <p className="text-muted-foreground">Sale not found</p>
        <Button variant="link" onClick={() => navigate('/sales')} className="mt-4">
          Back to Sales
        </Button>
      </div>
    );
  }

  const paid = Number(amountPaid) || 0;
  const change = paid - sale.totalAmount;

  return (
    <PageLayout
      icon={ShoppingCart}
      title={`Edit Sale ${sale.saleNumber}`}
      action={
        <Button variant="link" size="sm" onClick={() => navigate(`/sales/${saleId}`)} className="px-0">
          <ArrowLeft className="size-3.5" />
          Back to Sale Details
        </Button>
      }
    >

      <form onSubmit={handleSubmit}>
        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Sale Details</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4 md:grid-cols-3">
            <div className="space-y-1">
              <label className="text-sm text-muted-foreground block">Date</label>
              <input
                type="date"
                value={saleDate}
                onChange={(e) => setSaleDate(e.target.value)}
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
              />
            </div>
            <div className="space-y-1">
              <TextInput
                label="Phone Number"
                value={phoneNumber}
                onChange={(e) => setPhoneNumber(e.target.value)}
              />
              {customerData && (
                <p className="flex items-center gap-1 text-xs text-success">
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
            <SelectInput
              label="Sale Status"
              value={saleStatus}
              onChange={(value) => setSaleStatus(value ?? 'COMPLETED')}
              options={[
                { value: 'COMPLETED', label: 'Completed' },
                { value: 'PENDING', label: 'Pending' },
                { value: 'CANCELLED', label: 'Cancelled' },
              ]}
            />
            <SelectInput
              label="Payment Status"
              value={paymentStatus}
              onChange={(value) => setPaymentStatus(value ?? 'UNPAID')}
              options={[
                { value: 'PAID', label: 'Paid' },
                { value: 'UNPAID', label: 'Unpaid' },
                { value: 'PARTIAL', label: 'Partial' },
              ]}
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
          <CardHeader>
            <CardTitle>Notes</CardTitle>
          </CardHeader>
          <CardContent>
            <TextareaInput
              label="Notes (optional)"
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              rows={3}
            />
          </CardContent>
        </Card>

        <Card className="mb-6">
          <CardHeader>
            <CardTitle>Summary</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2">
            <div className="flex justify-between text-sm">
              <span className="text-muted-foreground">Total Amount</span>
              <span className="font-medium">{sale.totalAmount.toFixed(2)}</span>
            </div>
            <div className="flex justify-between text-sm">
              <span className="text-muted-foreground">Amount Paid</span>
              <span className="font-medium">{paid.toFixed(2)}</span>
            </div>
            <div className="flex justify-between text-sm border-t pt-2">
              <span className="font-semibold">Change</span>
              <span className={`font-bold ${change >= 0 ? 'text-success' : 'text-destructive'}`}>
                {change.toFixed(2)}
              </span>
            </div>
            <div className="flex gap-4 pt-2">
              <span className="text-xs text-muted-foreground">Sale Status:</span>
              <StatusBadge status={saleStatus} />
              <span className="text-xs text-muted-foreground ml-4">Payment:</span>
              <StatusBadge status={paymentStatus} />
            </div>
          </CardContent>
        </Card>

        <div className="flex justify-end gap-3">
          <Button type="button" variant="outline" onClick={() => navigate(`/sales/${saleId}`)}>
            Cancel
          </Button>
          <Button type="submit" disabled={updateMutation.isPending}>
            {updateMutation.isPending ? (
              <>
                <Loader2 className="size-4 animate-spin mr-2" />
                Updating...
              </>
            ) : (
              'Update Sale'
            )}
          </Button>
        </div>
      </form>
    </PageLayout>
  );
}

export default EditSale;
