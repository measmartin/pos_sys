import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useCreateSale } from '../hooks';
import { TextInput } from '../components/forms/TextInput';
import { SelectInput } from '../components/forms/SelectInput';
import type { CreateSalesDto, CreateSalesItemDto } from '@PosApi/types';

interface LineItemForm {
  productId: string;
  productUnitId: string;
  quantity: string;
  unitPrice: string;
}

const emptyItem: LineItemForm = {
  productId: '',
  productUnitId: '',
  quantity: '',
  unitPrice: '',
};

export function CreateSale() {
  const navigate = useNavigate();
  const createMutation = useCreateSale();

  const [phoneNumber, setPhoneNumber] = useState('');
  const [currencyId, setCurrencyId] = useState('1');
  const [amountPaid, setAmountPaid] = useState('0');
  const [items, setItems] = useState<LineItemForm[]>([{ ...emptyItem }]);

  const addItem = () => setItems((prev) => [...prev, { ...emptyItem }]);
  const removeItem = (idx: number) =>
    setItems((prev) => prev.filter((_, i) => i !== idx));
  const updateItem = (idx: number, field: keyof LineItemForm, value: string) =>
    setItems((prev) =>
      prev.map((item, i) => (i === idx ? { ...item, [field]: value } : item)),
    );

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const salesItems: CreateSalesItemDto[] = items
      .filter((it) => it.productId && it.quantity && it.unitPrice)
      .map((it) => ({
        productId: Number(it.productId),
        productUnitId: Number(it.productUnitId || it.productId),
        quantity: Number(it.quantity),
        unitPrice: Number(it.unitPrice),
      }));

    const dto: CreateSalesDto = {
      phoneNumber,
      currencyId: Number(currencyId),
      amountPaid: Number(amountPaid),
      items: salesItems,
    };

    const id = await createMutation.mutateAsync(dto);
    navigate(`/sales/${id}`);
  };

  return (
    <div>
      <div className="mb-6">
        <Link to="/sales" className="text-sm text-blue-600 hover:text-blue-800 mb-1 inline-block">
          &larr; Back to Sales
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Create Sale</h1>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <TextInput
            label="Phone Number"
            value={phoneNumber}
            onChange={(e) => setPhoneNumber(e.target.value)}
            required
          />
          <SelectInput
            label="Currency"
            value={currencyId}
            onChange={(e) => setCurrencyId(e.target.value)}
            options={[
              { value: 1, label: 'USD ($)' },
            ]}
          />
          <TextInput
            label="Amount Paid"
            type="number"
            step="0.01"
            value={amountPaid}
            onChange={(e) => setAmountPaid(e.target.value)}
          />
        </div>

        <h3 className="text-lg font-semibold text-gray-900 mb-4">Items</h3>
        {items.map((item, idx) => (
          <div key={idx} className="grid grid-cols-1 md:grid-cols-5 gap-3 mb-3 items-end">
            <TextInput
              label="Product ID"
              value={item.productId}
              onChange={(e) => updateItem(idx, 'productId', e.target.value)}
              required
            />
            <TextInput
              label="Unit ID"
              value={item.productUnitId}
              onChange={(e) => updateItem(idx, 'productUnitId', e.target.value)}
            />
            <TextInput
              label="Quantity"
              type="number"
              step="0.01"
              value={item.quantity}
              onChange={(e) => updateItem(idx, 'quantity', e.target.value)}
              required
            />
            <TextInput
              label="Unit Price"
              type="number"
              step="0.01"
              value={item.unitPrice}
              onChange={(e) => updateItem(idx, 'unitPrice', e.target.value)}
              required
            />
            <div className="flex gap-2 pb-1">
              {items.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeItem(idx)}
                  className="px-3 py-2 text-sm border border-red-300 text-red-600 rounded hover:bg-red-50"
                >
                  Remove
                </button>
              )}
              {idx === items.length - 1 && (
                <button
                  type="button"
                  onClick={addItem}
                  className="px-3 py-2 text-sm border border-blue-300 text-blue-600 rounded hover:bg-blue-50"
                >
                  + Add
                </button>
              )}
            </div>
          </div>
        ))}

        <div className="flex justify-end gap-3 mt-6 pt-4 border-t">
          <Link
            to="/sales"
            className="px-4 py-2 text-sm border rounded hover:bg-gray-50"
          >
            Cancel
          </Link>
          <button
            type="submit"
            disabled={createMutation.isPending}
            className="px-4 py-2 bg-blue-600 text-white text-sm font-medium rounded-md hover:bg-blue-700 disabled:opacity-50"
          >
            {createMutation.isPending ? 'Creating...' : 'Create Sale'}
          </button>
        </div>
      </form>
    </div>
  );
}
