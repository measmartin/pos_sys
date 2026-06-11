import { useState } from 'react';
import { useCurrenciesList, useCreateCurrency, useUpdateCurrency, useDeleteCurrency } from '@/hooks';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '@/components/ui/DataTable';
import { Pagination } from '@/components/ui/Pagination';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { TextInput } from '@/components/forms/TextInput';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import type { CurrencyDetailsDto } from '@PosApi/types';
import { Plus, Trash2, Pencil, DollarSign } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';

interface CurrencyForm {
  currencyCode: string;
  currencyName: string;
  currencySymbol: string;
  exchangeRate: string;
  isBaseCurrency: boolean;
}

interface FormState {
  open: boolean;
  editing: CurrencyDetailsDto | null;
  data: CurrencyForm;
}

const emptyForm: CurrencyForm = {
  currencyCode: '', currencyName: '', currencySymbol: '',
  exchangeRate: '1', isBaseCurrency: false,
};

export function CurrenciesPage() {
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [form, setForm] = useState<FormState>({ open: false, editing: null, data: emptyForm });
  const { data, isLoading } = useCurrenciesList({ page, pageSize: 20 });
  const createMutation = useCreateCurrency();
  const updateMutation = useUpdateCurrency();
  const deleteMutation = useDeleteCurrency();

  const openCreate = () => setForm({ open: true, editing: null, data: emptyForm });
  const openEdit = (c: CurrencyDetailsDto) => setForm({
    open: true, editing: c,
    data: {
      currencyCode: c.currencyCode, currencyName: c.currencyName,
      currencySymbol: c.currencySymbol ?? '', exchangeRate: String(c.exchangeRate),
      isBaseCurrency: c.isBaseCurrency,
    },
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const dto = {
      currencyCode: form.data.currencyCode,
      currencyName: form.data.currencyName,
      currencySymbol: form.data.currencySymbol || null,
      exchangeRate: Number(form.data.exchangeRate),
      isBaseCurrency: form.data.isBaseCurrency,
    };
    if (form.editing) {
      await updateMutation.mutateAsync({ id: form.editing.currencyId, dto });
    } else {
      await createMutation.mutateAsync(dto);
    }
    setForm((prev) => ({ ...prev, open: false }));
  };

  const columns: Column<CurrencyDetailsDto>[] = [
    { key: 'currencyCode', header: 'Code' },
    { key: 'currencyName', header: 'Name' },
    { key: 'currencySymbol', header: 'Symbol', render: (c) => c.currencySymbol ?? '-' },
    { key: 'exchangeRate', header: 'Rate' },
    { key: 'isBaseCurrency', header: 'Base', render: (c) => c.isBaseCurrency ? 'Yes' : '-' },
    { key: 'isActive', header: 'Status', render: (c) => <StatusBadge status={c.isActive ? 'active' : 'inactive'} label={c.isActive ? 'Active' : 'Inactive'} /> },
    {
      key: 'actions', header: '',
      render: (c) => (
        <div className="flex gap-1">
          <Button variant="ghost" size="sm" onClick={() => openEdit(c)}><Pencil className="size-3.5" /></Button>
          <Button variant="ghost" size="sm" onClick={() => setDeleteId(c.currencyId)} className="text-destructive hover:text-destructive"><Trash2 className="size-3.5" /></Button>
        </div>
      ),
    },
  ];

  return (
    <PageLayout
      icon={DollarSign}
      title="Currencies"
      subtitle={data ? `${data.totalCount} currency${data.totalCount !== 1 ? 'ies' : ''}` : undefined}
      action={<Button onClick={openCreate}><Plus className="size-4" />New Currency</Button>}
    >
      <div className="rounded-xl border bg-card p-1">
        <DataTable columns={columns} data={data?.data ?? []} keyExtractor={(c) => c.currencyId} isLoading={isLoading} emptyMessage="No currencies found" />
        {data && <Pagination page={data.page} pageSize={data.pageSize} totalCount={data.totalCount} onPageChange={setPage} />}
      </div>

      <Dialog open={form.open} onOpenChange={(open) => setForm((prev) => ({ ...prev, open }))}>
        <DialogContent showCloseButton>
          <DialogHeader><DialogTitle>{form.editing ? 'Edit Currency' : 'Create Currency'}</DialogTitle></DialogHeader>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <TextInput label="Currency Code" value={form.data.currencyCode} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, currencyCode: e.target.value } }))} required />
              <TextInput label="Currency Name" value={form.data.currencyName} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, currencyName: e.target.value } }))} required />
              <TextInput label="Symbol" value={form.data.currencySymbol} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, currencySymbol: e.target.value } }))} />
              <TextInput label="Exchange Rate" type="number" step="0.0001" value={form.data.exchangeRate} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, exchangeRate: e.target.value } }))} />
            </div>
            <label className="flex items-center gap-2 text-sm">
              <input type="checkbox" checked={form.data.isBaseCurrency} onChange={(e) => setForm((prev) => ({ ...prev, data: { ...prev.data, isBaseCurrency: e.target.checked } }))} className="rounded border-gray-300" />
              Base Currency
            </label>
            <div className="flex justify-end gap-3">
              <Button type="button" variant="outline" onClick={() => setForm((prev) => ({ ...prev, open: false }))}>Cancel</Button>
              <Button type="submit" disabled={createMutation.isPending || updateMutation.isPending}>
                {createMutation.isPending || updateMutation.isPending ? 'Saving...' : form.editing ? 'Update' : 'Create'}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>

      <ConfirmDialog isOpen={deleteId != null} onClose={() => setDeleteId(null)} onConfirm={async () => { if (deleteId) { await deleteMutation.mutateAsync(deleteId); setDeleteId(null); } }} title="Delete Currency" message="Are you sure you want to delete this currency?" isLoading={deleteMutation.isPending} />
    </PageLayout>
  );
}

export default CurrenciesPage;
