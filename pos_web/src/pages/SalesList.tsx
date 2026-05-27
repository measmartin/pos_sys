import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSalesList, useDeleteSale } from '../hooks';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '../components/ui/DataTable';
import { Pagination } from '../components/ui/Pagination';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import { formatCurrency, formatDate } from '../utils/formatting';
import type { SalesDetailsDto } from '@PosApi/types';
import { Plus, Eye, Trash2 } from 'lucide-react';
import { Card } from '@/components/ui/card';

const columns: Column<SalesDetailsDto>[] = [
  { key: 'saleNumber', header: 'Sale #' },
  {
    key: 'saleDate',
    header: 'Date',
    render: (s) => formatDate(s.saleDate),
  },
  {
    key: 'customerName',
    header: 'Customer',
    render: (s) => s.customerName ?? 'Walk-in',
  },
  {
    key: 'totalAmount',
    header: 'Total',
    render: (s) => formatCurrency(s.totalAmount, s.currencySymbol),
  },
  {
    key: 'paymentStatus',
    header: 'Payment',
    render: (s) => <StatusBadge status={s.paymentStatus} label={s.paymentStatus} />,
  },
  {
    key: 'saleStatus',
    header: 'Status',
    render: (s) => <StatusBadge status={s.saleStatus} label={s.saleStatus} />,
  },
];

export function SalesList() {
  const navigate = useNavigate();
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const { data, isLoading } = useSalesList({ page, pageSize: 20 });
  const deleteMutation = useDeleteSale();

  const handleDelete = async () => {
    if (deleteId == null) return;
    await deleteMutation.mutateAsync(deleteId);
    setDeleteId(null);
  };

  const actionColumn: Column<SalesDetailsDto> = {
    key: 'actions',
    header: 'Actions',
    render: (s) => (
      <div className="flex gap-2">
        <Button variant="ghost" size="sm" onClick={() => navigate(`/sales/${s.saleId}`)}>
          <Eye className="size-3.5" />
          View
        </Button>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setDeleteId(s.saleId)}
          className="text-destructive hover:text-destructive"
        >
          <Trash2 className="size-3.5" />
          Delete
        </Button>
      </div>
    ),
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Sales</h1>
        <Button onClick={() => navigate('/sales/new')}>
          <Plus className="size-4" />
          New Sale
        </Button>
      </div>

      <Card className="overflow-hidden">
        <DataTable
          columns={[...columns, actionColumn]}
          data={data?.data ?? []}
          keyExtractor={(s) => s.saleId}
          isLoading={isLoading}
          emptyMessage="No sales found"
        />
        {data && (
          <Pagination
            page={data.page}
            pageSize={data.pageSize}
            totalCount={data.totalCount}
            onPageChange={setPage}
          />
        )}
      </Card>

      <ConfirmDialog
        isOpen={deleteId != null}
        onClose={() => setDeleteId(null)}
        onConfirm={handleDelete}
        title="Delete Sale"
        message="Are you sure you want to delete this sale? This action cannot be undone."
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
