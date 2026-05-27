import { useState } from 'react';
import { useCustomersList, useDeleteCustomer } from '../hooks';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '../components/ui/DataTable';
import { Pagination } from '../components/ui/Pagination';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import { CustomerFormDialog } from '../components/customers/CustomerFormDialog';
import type { CustomerDetailsDto } from '@PosApi/types';
import { Plus, Trash2, Pencil } from 'lucide-react';
import { Card } from '@/components/ui/card';

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
  const [formOpen, setFormOpen] = useState(false);
  const [editCustomer, setEditCustomer] = useState<CustomerDetailsDto | null>(null);
  const { data, isLoading } = useCustomersList({ page, pageSize: 20 });
  const deleteMutation = useDeleteCustomer();

  const handleDelete = async () => {
    if (deleteId == null) return;
    await deleteMutation.mutateAsync(deleteId);
    setDeleteId(null);
  };

  const openCreate = () => {
    setEditCustomer(null);
    setFormOpen(true);
  };

  const openEdit = (customer: CustomerDetailsDto) => {
    setEditCustomer(customer);
    setFormOpen(true);
  };

  const actionColumn: Column<CustomerDetailsDto> = {
    key: 'actions',
    header: 'Actions',
    render: (c) => (
      <div className="flex gap-1">
        <Button variant="ghost" size="sm" onClick={() => openEdit(c)}>
          <Pencil className="size-3.5" />
        </Button>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setDeleteId(c.customerId)}
          className="text-destructive hover:text-destructive"
        >
          <Trash2 className="size-3.5" />
        </Button>
      </div>
    ),
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Customers</h1>
        <Button onClick={openCreate}>
          <Plus className="size-4" />
          New Customer
        </Button>
      </div>
      <Card className="overflow-hidden">
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
      </Card>
      <ConfirmDialog
        isOpen={deleteId != null}
        onClose={() => setDeleteId(null)}
        onConfirm={handleDelete}
        title="Delete Customer"
        message="Are you sure you want to delete this customer?"
        isLoading={deleteMutation.isPending}
      />
      <CustomerFormDialog
        isOpen={formOpen}
        onClose={() => setFormOpen(false)}
        customer={editCustomer}
      />
    </div>
  );
}
