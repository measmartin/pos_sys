import { useParams, useNavigate } from 'react-router-dom';
import { useCustomer, useDeleteCustomer, useSalesByCustomerId } from '@/hooks';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { formatCurrency, formatDate } from '@/utils/formatting';
import { useState } from 'react';
import { ArrowLeft, Trash2, Eye, ShoppingCart, Phone, Mail, MapPin, DollarSign, Calendar } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';
import { toast } from 'sonner';

export function CustomerDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const customerId = Number(id);
  const { data: customer, isLoading: customerLoading } = useCustomer(customerId);
  const { data: sales, isLoading: salesLoading } = useSalesByCustomerId(customerId);
  const deleteMutation = useDeleteCustomer();
  const [showDelete, setShowDelete] = useState(false);

  const handleDelete = async () => {
    if (!customer) return;
    await deleteMutation.mutateAsync(customer.customerId);
    toast.success('Customer deleted');
    navigate('/customers');
  };

  if (customerLoading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (!customer) {
    return (
      <div className="text-center py-12">
        <p className="text-muted-foreground">Customer not found</p>
        <Button variant="link" onClick={() => navigate('/customers')} className="mt-4">
          Back to Customers
        </Button>
      </div>
    );
  }

  const totalSpent = sales?.reduce((sum, s) => sum + s.totalAmount, 0) ?? 0;
  const saleCount = sales?.length ?? 0;
  const initials = (customer.customerName ?? 'W')
    .split(' ')
    .map((w) => w[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);

  return (
    <PageLayout
      icon={ShoppingCart}
      title={customer.customerName || 'Customer Detail'}
      action={
        <div className="flex items-center gap-2">
          <Button variant="ghost" size="sm" onClick={() => navigate('/customers')}>
            <ArrowLeft className="size-4" />
            Back
          </Button>
          <Button variant="destructive" size="sm" onClick={() => setShowDelete(true)}>
            <Trash2 className="size-4" />
            Delete
          </Button>
        </div>
      }
    >
      <div className="flex flex-col gap-4">
        <div className="grid gap-4 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardContent className="pt-6">
            <div className="flex items-start gap-4 mb-6">
              <div className="flex size-14 items-center justify-center rounded-full bg-primary/10 text-lg font-bold text-primary">
                {initials}
              </div>
              <div className="flex-1 min-w-0">
                <h2 className="text-lg font-semibold truncate">{customer.customerName}</h2>
                <p className="text-sm text-muted-foreground">{customer.phoneNumber ?? 'No phone number'}</p>
                <div className="mt-2">
                  <StatusBadge
                    status={customer.isActive ? 'active' : 'inactive'}
                    label={customer.isActive ? 'Active' : 'Inactive'}
                  />
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 pt-4 border-t">
              <div className="flex items-center gap-3">
                <div className="flex size-8 items-center justify-center rounded-lg bg-muted">
                  <Phone className="size-4 text-muted-foreground" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Phone</p>
                  <p className="text-sm font-medium">{customer.phoneNumber ?? '-'}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex size-8 items-center justify-center rounded-lg bg-muted">
                  <Mail className="size-4 text-muted-foreground" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Email</p>
                  <p className="text-sm font-medium">{customer.email ?? '-'}</p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex size-8 items-center justify-center rounded-lg bg-muted">
                  <MapPin className="size-4 text-muted-foreground" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Location</p>
                  <p className="text-sm font-medium">
                    {customer.city && customer.country
                      ? `${customer.city}, ${customer.country}`
                      : customer.location ?? customer.city ?? customer.country ?? '-'}
                  </p>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="flex size-8 items-center justify-center rounded-lg bg-muted">
                  <Calendar className="size-4 text-muted-foreground" />
                </div>
                <div>
                  <p className="text-xs text-muted-foreground">Member Since</p>
                  <p className="text-sm font-medium">{formatDate(customer.createdAt)}</p>
                </div>
              </div>
            </div>

            {customer.notes && (
              <div className="mt-4 pt-4 border-t">
                <p className="text-xs text-muted-foreground mb-1">Notes</p>
                <p className="text-sm text-muted-foreground">{customer.notes}</p>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-base">Summary</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-3">
              <div className="flex size-10 items-center justify-center rounded-lg bg-primary/10">
                <ShoppingCart className="size-5 text-primary" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Total Orders</p>
                <p className="text-2xl font-bold">{saleCount}</p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <div className="flex size-10 items-center justify-center rounded-lg bg-success/10">
                <DollarSign className="size-5 text-success" />
              </div>
              <div>
                <p className="text-xs text-muted-foreground">Total Spent</p>
                <p className="text-2xl font-bold">{formatCurrency(totalSpent)}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <ShoppingCart className="size-4" />
            Sales History
          </CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Sale #</TableHead>
                <TableHead>Date</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Payment</TableHead>
                <TableHead className="text-right">Total</TableHead>
                <TableHead className="w-16"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {salesLoading ? (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8">
                    <div className="flex justify-center">
                      <div className="animate-spin rounded-full size-6 border-b-2 border-primary" />
                    </div>
                  </TableCell>
                </TableRow>
              ) : sales && sales.length > 0 ? (
                sales.map((sale) => (
                  <TableRow key={sale.saleId}>
                    <TableCell className="font-medium">{sale.saleNumber}</TableCell>
                    <TableCell className="text-muted-foreground">{formatDate(sale.saleDate)}</TableCell>
                    <TableCell><StatusBadge status={sale.saleStatus} label={sale.saleStatus} /></TableCell>
                    <TableCell><StatusBadge status={sale.paymentStatus} label={sale.paymentStatus} /></TableCell>
                    <TableCell className="text-right font-semibold tabular-nums">
                      {formatCurrency(sale.totalAmount, sale.currencySymbol)}
                    </TableCell>
                    <TableCell>
                      <Button variant="ghost" size="sm" onClick={() => navigate(`/sales/${sale.saleId}`)}>
                        <Eye className="size-3.5" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              ) : (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-12 text-muted-foreground">
                    <ShoppingCart className="size-8 mx-auto mb-2 opacity-50" />
                    <p className="text-sm">No sales history</p>
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
      </div>

      <ConfirmDialog
        isOpen={showDelete}
        onClose={() => setShowDelete(false)}
        onConfirm={handleDelete}
        title="Delete Customer"
        message={`Are you sure you want to delete ${customer.customerName}? This will not delete their sales history.`}
        isLoading={deleteMutation.isPending}
      />
    </PageLayout>
  );
}

export default CustomerDetail;
