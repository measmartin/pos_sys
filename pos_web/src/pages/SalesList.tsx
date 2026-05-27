import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useSalesList, useDeleteSale } from '../hooks';
import { DataTable, type Column } from '../components/ui/DataTable';
import { Pagination } from '../components/ui/Pagination';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import { formatCurrency, formatDate } from '../utils/formatting';
import type { SalesDetailsDto } from '@PosApi/types';

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
        <Link
          to={`/sales/${s.saleId}`}
          className="text-blue-600 hover:text-blue-800 text-sm font-medium"
        >
          View
        </Link>
        <button
          onClick={() => setDeleteId(s.saleId)}
          className="text-red-600 hover:text-red-800 text-sm font-medium"
        >
          Delete
        </button>
      </div>
    ),
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Sales</h1>
        <Link
          to="/sales/new"
          className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700"
        >
          New Sale
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
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
      </div>

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
