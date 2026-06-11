import { useParams, useNavigate } from 'react-router-dom';
import { useSale, useDeleteSale, useAddSaleItem, useUpdateSaleItem, useRemoveSaleItem } from '@/hooks';
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
import { Input } from '@/components/ui/input';
import { formatCurrency, formatDate } from '@/utils/formatting';
import { useState } from 'react';
import { ArrowLeft, Trash2, Pencil, Plus, Save, X, ShoppingCart, Printer } from 'lucide-react';
import { useThermalPrint } from '@/components/printing/useThermalPrint';
import { PageLayout } from '@/components/layout/PageLayout';
import { ProductSelector } from '@/components/products/ProductSelector';
import { toast } from 'sonner';

interface EditingItem {
  salesItemId: number;
  quantity: string;
  unitPrice: string;
}

export function SaleDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const saleId = Number(id);
  const { data: sale, isLoading } = useSale(saleId);
  const deleteMutation = useDeleteSale();
  const addItemMutation = useAddSaleItem();
  const updateItemMutation = useUpdateSaleItem();
  const removeItemMutation = useRemoveSaleItem();

  const [showDelete, setShowDelete] = useState(false);
  const [showItemDelete, setShowItemDelete] = useState<number | null>(null);
  const [editingItem, setEditingItem] = useState<EditingItem | null>(null);
  const [selectorOpen, setSelectorOpen] = useState(false);
  const { print } = useThermalPrint();

  const handleDelete = async () => {
    if (!sale) return;
    await deleteMutation.mutateAsync(sale.saleId);
    toast.success('Sale deleted');
    navigate('/sales');
  };

  const handleAddItem = async (productId: number, productUnitId: number, unitPrice: number) => {
    try {
      await addItemMutation.mutateAsync({
        saleId,
        dto: { productId, productUnitId, quantity: 1, unitPrice },
      });
      toast.success('Item added to sale');
    } catch {
      toast.error('Failed to add item');
    }
    setSelectorOpen(false);
  };

  const handleRemoveItem = async (itemId: number) => {
    try {
      await removeItemMutation.mutateAsync({ saleId, itemId });
      toast.success('Item removed');
    } catch {
      toast.error('Failed to remove item');
    }
    setShowItemDelete(null);
  };

  const startEditing = (itemId: number, quantity: number, unitPrice: number) => {
    setEditingItem({ salesItemId: itemId, quantity: String(quantity), unitPrice: String(unitPrice) });
  };

  const cancelEditing = () => {
    setEditingItem(null);
  };

  const saveEditing = async () => {
    if (!editingItem || !sale) return;
    const item = sale.items.find((i) => i.salesItemId === editingItem.salesItemId);
    if (!item) return;

    try {
      await updateItemMutation.mutateAsync({
        saleId,
        itemId: editingItem.salesItemId,
        dto: {
          quantity: Number(editingItem.quantity),
          unitPrice: Number(editingItem.unitPrice),
          isActive: true,
        },
      });
      toast.success('Item updated');
      setEditingItem(null);
    } catch {
      toast.error('Failed to update item');
    }
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

  const isSaving = addItemMutation.isPending || updateItemMutation.isPending || removeItemMutation.isPending;

  return (
    <PageLayout
      icon={ShoppingCart}
      title={`Sale ${sale.saleNumber}`}
      action={
        <div className="flex gap-2">
          <Button variant="link" size="sm" onClick={() => navigate('/sales')} className="px-0">
            <ArrowLeft className="size-3.5" />
            Back to Sales
          </Button>
          <Button variant="outline" onClick={() => print(sale)}>
            <Printer className="size-4" />
            Print
          </Button>
          <Button variant="outline" onClick={() => navigate(`/sales/${sale.saleId}/edit`)}>
            <Pencil className="size-4" />
            Edit
          </Button>
          <Button variant="destructive" onClick={() => setShowDelete(true)}>
            <Trash2 className="size-4" />
            Delete
          </Button>
        </div>
      }
    >

      <div className="space-y-6">
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
                <dd className="text-sm font-medium text-success">
                  {formatCurrency(sale.changeAmount, sale.currencySymbol)}
                </dd>
              </div>
            </dl>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Items ({sale.items.length})</CardTitle>
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => setSelectorOpen(true)}
            disabled={isSaving}
          >
            <Plus className="size-3.5" />
            Add Item
          </Button>
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
                <TableHead className="w-24">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {sale.items.map((item) => {
                const isEditing = editingItem?.salesItemId === item.salesItemId;
                return (
                  <TableRow key={item.salesItemId}>
                    <TableCell className="text-muted-foreground">{item.lineNumber}</TableCell>
                    <TableCell className="font-medium">{item.productName}</TableCell>
                    <TableCell className="text-muted-foreground">{item.unitName}</TableCell>
                    {isEditing ? (
                      <>
                        <TableCell className="text-right">
                          <Input
                            type="number"
                            step="0.01"
                            value={editingItem.quantity}
                            onChange={(e) => setEditingItem({ ...editingItem, quantity: e.target.value })}
                            className="w-20 ml-auto"
                          />
                        </TableCell>
                        <TableCell className="text-right">
                          <Input
                            type="number"
                            step="0.01"
                            value={editingItem.unitPrice}
                            onChange={(e) => setEditingItem({ ...editingItem, unitPrice: e.target.value })}
                            className="w-24 ml-auto"
                          />
                        </TableCell>
                        <TableCell className="text-right text-muted-foreground">-</TableCell>
                        <TableCell className="text-right text-muted-foreground">-</TableCell>
                        <TableCell className="text-right text-muted-foreground">-</TableCell>
                        <TableCell>
                          <div className="flex gap-1 justify-end">
                            <Button variant="ghost" size="sm" onClick={saveEditing} disabled={updateItemMutation.isPending}>
                              <Save className="size-3.5" />
                            </Button>
                            <Button variant="ghost" size="sm" onClick={cancelEditing}>
                              <X className="size-3.5" />
                            </Button>
                          </div>
                        </TableCell>
                      </>
                    ) : (
                      <>
                        <TableCell className="text-right">{item.quantity}</TableCell>
                        <TableCell className="text-right">{formatCurrency(item.unitPrice)}</TableCell>
                        <TableCell className="text-right">{formatCurrency(item.lineSubtotal)}</TableCell>
                        <TableCell className="text-right text-destructive">
                          {item.discountAmount > 0 ? `-${formatCurrency(item.discountAmount)}` : '-'}
                        </TableCell>
                        <TableCell className="text-right font-medium">{formatCurrency(item.lineTotal)}</TableCell>
                        <TableCell>
                          <div className="flex gap-1">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => startEditing(item.salesItemId, item.quantity, item.unitPrice)}
                            >
                              <Pencil className="size-3.5" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => setShowItemDelete(item.salesItemId)}
                              className="text-destructive"
                            >
                              <Trash2 className="size-3.5" />
                            </Button>
                          </div>
                        </TableCell>
                      </>
                    )}
                  </TableRow>
                );
              })}
              {sale.items.length === 0 && (
                <TableRow>
                  <TableCell colSpan={9} className="text-center py-8 text-muted-foreground">
                    No items in this sale
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
        title="Delete Sale"
        message="Are you sure you want to delete this sale?"
        isLoading={deleteMutation.isPending}
      />

      <ConfirmDialog
        isOpen={showItemDelete !== null}
        onClose={() => setShowItemDelete(null)}
        onConfirm={() => showItemDelete && handleRemoveItem(showItemDelete)}
        title="Remove Item"
        message="Are you sure you want to remove this item from the sale?"
        isLoading={removeItemMutation.isPending}
      />

      <ProductSelector
        isOpen={selectorOpen}
        onClose={() => setSelectorOpen(false)}
        onSelect={handleAddItem}
      />
    </PageLayout>
  );
}

export default SaleDetail;
