import { useState } from 'react';
import { useCategoriesList, useCreateCategory, useUpdateCategory, useDeleteCategory } from '@/hooks';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '@/components/ui/DataTable';
import { Pagination } from '@/components/ui/Pagination';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { TextInput } from '@/components/forms/TextInput';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import type { CategoryDetailsDto } from '@PosApi/types';
import { Plus, Trash2, Pencil, Tags } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';

interface CategoryForm {
  categoryName: string;
  description: string;
}

interface FormState {
  open: boolean;
  editing: CategoryDetailsDto | null;
  data: CategoryForm;
}

const emptyForm: CategoryForm = { categoryName: '', description: '' };

export function CategoriesPage() {
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [form, setForm] = useState<FormState>({ open: false, editing: null, data: emptyForm });
  const { data, isLoading } = useCategoriesList({ page, pageSize: 20 });
  const createMutation = useCreateCategory();
  const updateMutation = useUpdateCategory();
  const deleteMutation = useDeleteCategory();

  const openCreate = () => setForm({ open: true, editing: null, data: emptyForm });
  const openEdit = (cat: CategoryDetailsDto) => setForm({
    open: true, editing: cat,
    data: { categoryName: cat.categoryName, description: cat.description ?? '' },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (form.editing) {
      await updateMutation.mutateAsync({ id: form.editing.categoryId, dto: { categoryName: form.data.categoryName, description: form.data.description || null } });
    } else {
      await createMutation.mutateAsync({ categoryName: form.data.categoryName, description: form.data.description || null });
    }
    setForm((prev) => ({ ...prev, open: false }));
  };

  const columns: Column<CategoryDetailsDto>[] = [
    { key: 'categoryName', header: 'Name' },
    { key: 'description', header: 'Description', render: (c) => c.description ?? '-' },
    { key: 'isActive', header: 'Status', render: (c) => <StatusBadge status={c.isActive ? 'active' : 'inactive'} label={c.isActive ? 'Active' : 'Inactive'} /> },
    {
      key: 'actions', header: '',
      render: (c) => (
        <div className="flex gap-1">
          <Button variant="ghost" size="sm" onClick={() => openEdit(c)}><Pencil className="size-3.5" /></Button>
          <Button variant="ghost" size="sm" onClick={() => setDeleteId(c.categoryId)} className="text-destructive hover:text-destructive"><Trash2 className="size-3.5" /></Button>
        </div>
      ),
    },
  ];

  return (
    <PageLayout
      icon={Tags}
      title="Categories"
      subtitle={data ? `${data.totalCount} categor${data.totalCount !== 1 ? 'ies' : 'y'}` : undefined}
      action={<Button onClick={openCreate}><Plus className="size-4" />New Category</Button>}
    >
      <div className="rounded-xl border bg-card p-1">
        <DataTable columns={columns} data={data?.data ?? []} keyExtractor={(c) => c.categoryId} isLoading={isLoading} emptyMessage="No categories found" />
        {data && <Pagination page={data.page} pageSize={data.pageSize} totalCount={data.totalCount} onPageChange={setPage} />}
      </div>

      <Dialog open={form.open} onOpenChange={(open) => setForm((prev) => ({ ...prev, open }))}>
        <DialogContent showCloseButton>
          <DialogHeader><DialogTitle>{form.editing ? 'Edit Category' : 'Create Category'}</DialogTitle></DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4">
            <TextInput label="Category Name" value={form.data.categoryName} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, categoryName: e.target.value } }))} required />
            <TextInput label="Description" value={form.data.description} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, description: e.target.value } }))} />
            <div className="flex justify-end gap-3">
              <Button type="button" variant="outline" onClick={() => setForm((prev) => ({ ...prev, open: false }))}>Cancel</Button>
              <Button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>{createMutation.isPending || updateMutation.isPending ? 'Saving...' : form.editing ? 'Update' : 'Create'}</Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog isOpen={deleteId != null} onClose={() => setDeleteId(null)} onConfirm={async () => { if (deleteId) { await deleteMutation.mutateAsync(deleteId); setDeleteId(null); } }} title="Delete Category" message="Are you sure you want to delete this category?" isLoading={deleteMutation.isPending} />
    </PageLayout>
  );
}

export default CategoriesPage;
