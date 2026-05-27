import { useParams, useNavigate } from 'react-router-dom';
import { useSale, useDeleteSale } from '../hooks';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { formatCurrency, formatDate } from '../utils/formatting';
import { useState } from 'react';
import { ArrowLeft, Trash2 } from 'lucide-react';

export function SaleDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const { data: sale, isLoading } = useSale(Number(id));
  const deleteMutation = useDeleteSale();
  const [showDelete, setShowDelete] = useState(false);

  const handleDelete = async () => {
    if (!sale) return;
    await deleteMutation.mutateAsync(sale.saleId);
    navigate('/sales');
  };

  if (isLoading) {
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

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Button variant="link" size="sm" onClick={() => navigate('/sales')} className="px-0">
            <ArrowLeft className="size-3.5" />
            Back to Sales
          </Button>
          <h1 className="text-2xl font-bold tracking-tight">Sale {sale.saleNumber}</h1>
        </div>
        <Button variant="destructive" onClick={() => setShowDelete(true)}>
          <Trash2 className="size-4" />
          Delete
        </Button>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Sale Details</CardTitle>
          </CardHeader>
          <CardContent>
            <dl className="grid grid-cols-2 gap-4">
              <div>
                <dt className="text-sm text-muted-foreground">Date</dt>
                <dd className="text-sm font-medium">{formatDate(sale.saleDate)}</dd>
              </div>
              <div>
                <dt className="text-sm text-muted-foreground">Status</dt>
                <dd><StatusBadge status={sale.saleStatus} /></dd>
              </div>
              <div>
                <dt className="text-sm text-muted-foreground">Payment</dt>
                <dd><StatusBadge status={sale.paymentStatus} /></dd>
              </div>
              <div>
                <dt className="text-sm text-muted-foreground">Customer</dt>
                <dd className="text-sm font-medium">{sale.customerName ?? 'Walk-in'}</dd>
              </div>
              <div>
                <dt className="text-sm text-muted-foreground">Currency</dt>
                <dd className="text-sm font-medium">{sale.currencyCode}</dd>
              </div>
            </dl>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Totals</CardTitle>
          </CardHeader>
          <CardContent>
            <dl className="space-y-3">
              <div className="flex justify-between">
                <dt className="text-sm text-muted-foreground">Subtotal</dt>
                <dd className="text-sm font-medium">{formatCurrency(sale.subtotal, sale.currencySymbol)}</dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-sm text-muted-foreground">Discount</dt>
                <dd className="text-sm font-medium text-destructive">
                  -{formatCurrency(sale.totalDiscount, sale.currencySymbol)}
                </dd>
              </div>
              <div className="flex justify-between border-t pt-2">
                <dt className="text-sm font-semibold">Total</dt>
                <dd className="text-sm font-bold">
                  {formatCurrency(sale.totalAmount, sale.currencySymbol)}
                </dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-sm text-muted-foreground">Paid</dt>
                <dd className="text-sm font-medium">
                  {formatCurrency(sale.amountPaid, sale.currencySymbol)}
                </dd>
              </div>
              <div className="flex justify-between">
                <dt className="text-sm text-muted-foreground">Change</dt>
                <dd className="text-sm font-medium text-green-600">
                  {formatCurrency(sale.changeAmount, sale.currencySymbol)}
                </dd>
              </div>
            </dl>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Items</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>#</TableHead>
                <TableHead>Product</TableHead>
                <TableHead>Unit</TableHead>
                <TableHead className="text-right">Qty</TableHead>
                <TableHead className="text-right">Price</TableHead>
                <TableHead className="text-right">Subtotal</TableHead>
                <TableHead className="text-right">Discount</TableHead>
                <TableHead className="text-right">Total</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {sale.items.map((item) => (
                <TableRow key={item.salesItemId}>
                  <TableCell className="text-muted-foreground">{item.lineNumber}</TableCell>
                  <TableCell className="font-medium">{item.productName}</TableCell>
                  <TableCell className="text-muted-foreground">{item.unitName}</TableCell>
                  <TableCell className="text-right">{item.quantity}</TableCell>
                  <TableCell className="text-right">{formatCurrency(item.unitPrice)}</TableCell>
                  <TableCell className="text-right">{formatCurrency(item.lineSubtotal)}</TableCell>
                  <TableCell className="text-right text-destructive">
                    {item.discountAmount > 0 ? `-${formatCurrency(item.discountAmount)}` : '-'}
                  </TableCell>
                  <TableCell className="text-right font-medium">{formatCurrency(item.lineTotal)}</TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <ConfirmDialog
        isOpen={showDelete}
        onClose={() => setShowDelete(false)}
        onConfirm={handleDelete}
        title="Delete Sale"
        message="Are you sure you want to delete this sale?"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
