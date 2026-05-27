import { useState } from 'react';
import { useProductsList, useDeleteProduct } from '../hooks';
import { DataTable, type Column } from '../components/ui/DataTable';
import { Pagination } from '../components/ui/Pagination';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import type { ProductDetailsDto } from '@PosApi/types';

const columns: Column<ProductDetailsDto>[] = [
  { key: 'productCode', header: 'Code' },
  { key: 'productName', header: 'Name' },
  { key: 'categoryName', header: 'Category', render: (p) => p.categoryName ?? '-' },
  {
    key: 'isActive',
    header: 'Status',
    render: (p) => (
      <StatusBadge
        status={p.isActive ? 'active' : 'inactive'}
        label={p.isActive ? 'Active' : 'Inactive'}
      />
    ),
  },
];

export function Products() {
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const { data, isLoading } = useProductsList({ page, pageSize: 20 });
  const deleteMutation = useDeleteProduct();

  const handleDelete = async () => {
    if (deleteId == null) return;
    await deleteMutation.mutateAsync(deleteId);
    setDeleteId(null);
  };

  const actionColumn: Column<ProductDetailsDto> = {
    key: 'actions',
    header: 'Actions',
    render: (p) => (
      <button
        onClick={() => setDeleteId(p.productId)}
        className="text-red-600 hover:text-red-800 text-sm font-medium"
      >
        Delete
      </button>
    ),
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Products</h1>
      </div>
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <DataTable
          columns={[...columns, actionColumn]}
          data={data?.data ?? []}
          keyExtractor={(p) => p.productId}
          isLoading={isLoading}
          emptyMessage="No products found"
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
        title="Delete Product"
        message="Are you sure you want to delete this product?"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
