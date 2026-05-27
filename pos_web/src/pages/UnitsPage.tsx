import { useState } from 'react';
import { useUnitsList, useCreateUnit, useUpdateUnit, useDeleteUnit } from '../hooks';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '../components/ui/DataTable';
import { Pagination } from '../components/ui/Pagination';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import { TextInput } from '../components/forms/TextInput';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import type { UnitDetailsDto } from '@PosApi/types';
import { Plus, Trash2, Pencil } from 'lucide-react';
import { Card } from '@/components/ui/card';

interface UnitForm {
  unitName: string;
  unitCode: string;
  description: string;
}

interface FormState {
  open: boolean;
  editing: UnitDetailsDto | null;
  data: UnitForm;
}

const emptyForm: UnitForm = { unitName: '', unitCode: '', description: '' };

export function UnitsPage() {
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [form, setForm] = useState<FormState>({ open: false, editing: null, data: emptyForm });
  const { data, isLoading } = useUnitsList({ page, pageSize: 20 });
  const createMutation = useCreateUnit();
  const updateMutation = useUpdateUnit();
  const deleteMutation = useDeleteUnit();

  const openCreate = () => setForm({ open: true, editing: null, data: emptyForm });
  const openEdit = (u: UnitDetailsDto) => setForm({
    open: true, editing: u,
    data: { unitName: u.unitName, unitCode: u.unitCode, description: u.description ?? '' },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.editing) {
      await updateMutation.mutateAsync({ id: form.editing.unitId, dto: { unitName: form.data.unitName, unitCode: form.data.unitCode, description: form.data.description || null } });
    } else {
      await createMutation.mutateAsync({ unitName: form.data.unitName, unitCode: form.data.unitCode, description: form.data.description || null });
    }
    setForm((prev) => ({ ...prev, open: false }));
  };

  const columns: Column<UnitDetailsDto>[] = [
    { key: 'unitName', header: 'Name' },
    { key: 'unitCode', header: 'Code' },
    { key: 'description', header: 'Description', render: (u) => u.description ?? '-' },
    { key: 'isActive', header: 'Status', render: (u) => <StatusBadge status={u.isActive ? 'active' : 'inactive'} label={u.isActive ? 'Active' : 'Inactive'} /> },
    {
      key: 'actions', header: 'Actions',
      render: (u) => (
        <div className="flex gap-1">
          <Button variant="ghost" size="sm" onClick={() => openEdit(u)}><Pencil className="size-3.5" /></Button>
          <Button variant="ghost" size="sm" onClick={() => setDeleteId(u.unitId)} className="text-destructive hover:text-destructive"><Trash2 className="size-3.5" /></Button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold tracking-tight">Units</h1>
        <Button onClick={openCreate}><Plus className="size-4" />New Unit</Button>
      </div>
      <Card className="overflow-hidden">
        <DataTable columns={columns} data={data?.data ?? []} keyExtractor={(u) => u.unitId} isLoading={isLoading} emptyMessage="No units found" />
        {data && <Pagination page={data.page} pageSize={data.pageSize} totalCount={data.totalCount} onPageChange={setPage} />}
      </Card>

      <Dialog open={form.open} onOpenChange={(open) => setForm((prev) => ({ ...prev, open }))}>
        <DialogContent showCloseButton>
          <DialogHeader><DialogTitle>{form.editing ? 'Edit Unit' : 'Create Unit'}</DialogTitle></DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <TextInput label="Unit Name" value={form.data.unitName} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, unitName: e.target.value } }))} required />
              <TextInput label="Unit Code" value={form.data.unitCode} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, unitCode: e.target.value } }))} required />
            </div>
            <TextInput label="Description" value={form.data.description} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, description: e.target.value } }))} />
            <div className="flex justify-end gap-3">
              <Button type="button" variant="outline" onClick={() => setForm((prev) => ({ ...prev, open: false }))}>Cancel</Button>
              <Button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>{createMutation.isPending || updateMutation.isPending ? 'Saving...' : form.editing ? 'Update' : 'Create'}</Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog isOpen={deleteId != null} onClose={() => setDeleteId(null)} onConfirm={async () => { if (deleteId) { await deleteMutation.mutateAsync(deleteId); setDeleteId(null); } }} title="Delete Unit" message="Are you sure you want to delete this unit?" isLoading={deleteMutation.isPending} />
    </div>
  );
}
