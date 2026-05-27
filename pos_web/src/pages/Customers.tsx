import { useState } from 'react';
import { useCustomersList, useDeleteCustomer } from '../hooks';
import { DataTable, type Column } from '../components/ui/DataTable';
import { Pagination } from '../components/ui/Pagination';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import type { CustomerDetailsDto } from '@PosApi/types';

const columns: Column<CustomerDetailsDto>[] = [
  { key: 'customerName', header: 'Name', render: (c) => c.customerName ?? '-' },
  { key: 'phoneNumber', header: 'Phone', render: (c) => c.phoneNumber ?? '-' },
  { key: 'email', header: 'Email', render: (c) => c.email ?? '-' },
  { key: 'city', header: 'City', render: (c) => c.city ?? '-' },
  {
    key: 'isActive',
    header: 'Status',
    render: (c) => (
      <StatusBadge
        status={c.isActive ? 'active' : 'inactive'}
        label={c.isActive ? 'Active' : 'Inactive'}
      />
    ),
  },
];

export function Customers() {
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const { data, isLoading } = useCustomersList({ page, pageSize: 20 });
  const deleteMutation = useDeleteCustomer();

  const handleDelete = async () => {
    if (deleteId == null) return;
    await deleteMutation.mutateAsync(deleteId);
    setDeleteId(null);
  };

  const actionColumn: Column<CustomerDetailsDto> = {
    key: 'actions',
    header: 'Actions',
    render: (c) => (
      <button
        onClick={() => setDeleteId(c.customerId)}
        className="text-red-600 hover:text-red-800 text-sm font-medium"
      >
        Delete
      </button>
    ),
  };

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Customers</h1>
      </div>
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <DataTable
          columns={[...columns, actionColumn]}
          data={data?.data ?? []}
          keyExtractor={(c) => c.customerId}
          isLoading={isLoading}
          emptyMessage="No customers found"
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
        title="Delete Customer"
        message="Are you sure you want to delete this customer?"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
