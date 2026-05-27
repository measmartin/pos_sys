import { useState } from 'react';
import { useCreateCustomer, useUpdateCustomer } from '../../hooks';
import { Button } from '@/components/ui/button';
import { TextInput } from '../forms/TextInput';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import type { CustomerDetailsDto } from '@PosApi/types';

interface CustomerFormData {
  customerName: string;
  phoneNumber: string;
  email: string;
  location: string;
  city: string;
  country: string;
  notes: string;
}

const emptyForm = (customer?: CustomerDetailsDto | null): CustomerFormData => ({
  customerName: customer?.customerName ?? '',
  phoneNumber: customer?.phoneNumber ?? '',
  email: customer?.email ?? '',
  location: customer?.location ?? '',
  city: customer?.city ?? '',
  country: customer?.country ?? '',
  notes: customer?.notes ?? '',
});

interface CustomerFormDialogProps {
  isOpen: boolean;
  onClose: () => void;
  customer?: CustomerDetailsDto | null;
}

export function CustomerFormDialog({ isOpen, onClose, customer }: CustomerFormDialogProps) {
  const createMutation = useCreateCustomer();
  const updateMutation = useUpdateCustomer();
  const isEdit = !!customer;
  const [form, setForm] = useState<CustomerFormData>(emptyForm(customer));

  const update = (field: keyof CustomerFormData, value: string) =>
    setForm((prev) => ({ ...prev, [field]: value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const dto = {
      customerName: form.customerName || null,
      phoneNumber: form.phoneNumber || null,
      email: form.email || null,
      location: form.location || null,
      city: form.city || null,
      country: form.country || null,
      notes: form.notes || null,
    };

    if (isEdit && customer) {
      await updateMutation.mutateAsync({ id: customer.customerId, dto });
    } else {
      await createMutation.mutateAsync(dto);
    }
    onClose();
  };

  const isPending = createMutation.isPending || updateMutation.isPending;

  return (
    <Dialog open={isOpen} onOpenChange={(open) => { if (!open) onClose(); }}>
      <DialogContent key={customer?.customerId ?? 'new'} className="sm:max-w-lg" showCloseButton>
        <DialogHeader>
          <DialogTitle>{isEdit ? 'Edit Customer' : 'Create Customer'}</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <TextInput
              label="Customer Name"
              value={form.customerName}
              onChange={(e) => update('customerName', e.target.value)}
              required
            />
            <TextInput
              label="Phone Number"
              value={form.phoneNumber}
              onChange={(e) => update('phoneNumber', e.target.value)}
            />
            <TextInput
              label="Email"
              type="email"
              value={form.email}
              onChange={(e) => update('email', e.target.value)}
            />
            <TextInput
              label="City"
              value={form.city}
              onChange={(e) => update('city', e.target.value)}
            />
            <TextInput
              label="Location"
              value={form.location}
              onChange={(e) => update('location', e.target.value)}
            />
            <TextInput
              label="Country"
              value={form.country}
              onChange={(e) => update('country', e.target.value)}
            />
          </div>
          <TextInput
            label="Notes"
            value={form.notes}
            onChange={(e) => update('notes', e.target.value)}
          />
          <div className="flex justify-end gap-3 pt-2">
            <Button type="button" variant="outline" onClick={onClose}>Cancel</Button>
            <Button type="submit" disabled={isPending}>
              {isPending ? 'Saving...' : isEdit ? 'Update Customer' : 'Create Customer'}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
  );
}
