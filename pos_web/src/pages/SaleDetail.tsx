import { useParams, Link } from 'react-router-dom';
import { useSale, useDeleteSale } from '../hooks';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import { formatCurrency, formatDate } from '../utils/formatting';
import { useState } from 'react';

export function SaleDetail() {
  const { id } = useParams<{ id: string }>();
  const { data: sale, isLoading } = useSale(Number(id));
  const deleteMutation = useDeleteSale();
  const [showDelete, setShowDelete] = useState(false);

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600" />
      </div>
    );
  }

  if (!sale) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Sale not found</p>
        <Link to="/sales" className="text-blue-600 hover:text-blue-800 mt-4 inline-block">
          Back to Sales
        </Link>
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <Link to="/sales" className="text-sm text-blue-600 hover:text-blue-800 mb-1 inline-block">
            &larr; Back to Sales
          </Link>
          <h1 className="text-2xl font-bold text-gray-900">Sale {sale.saleNumber}</h1>
        </div>
        <button
          onClick={() => setShowDelete(true)}
          className="px-4 py-2 bg-red-600 text-white text-sm font-medium rounded-md hover:bg-red-700"
        >
          Delete
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-6">
        <div className="lg:col-span-2 bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Sale Details</h2>
          <dl className="grid grid-cols-2 gap-4">
            <div>
              <dt className="text-sm text-gray-500">Date</dt>
              <dd className="text-sm font-medium">{formatDate(sale.saleDate)}</dd>
            </div>
            <div>
              <dt className="text-sm text-gray-500">Status</dt>
              <dd><StatusBadge status={sale.saleStatus} /></dd>
            </div>
            <div>
              <dt className="text-sm text-gray-500">Payment</dt>
              <dd><StatusBadge status={sale.paymentStatus} /></dd>
            </div>
            <div>
              <dt className="text-sm text-gray-500">Customer</dt>
              <dd className="text-sm font-medium">{sale.customerName ?? 'Walk-in'}</dd>
            </div>
            <div>
              <dt className="text-sm text-gray-500">Currency</dt>
              <dd className="text-sm font-medium">{sale.currencyCode}</dd>
            </div>
          </dl>
        </div>

        <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Totals</h2>
          <dl className="space-y-3">
            <div className="flex justify-between">
              <dt className="text-sm text-gray-500">Subtotal</dt>
              <dd className="text-sm font-medium">{formatCurrency(sale.subtotal, sale.currencySymbol)}</dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-sm text-gray-500">Discount</dt>
              <dd className="text-sm font-medium text-red-600">
                -{formatCurrency(sale.totalDiscount, sale.currencySymbol)}
              </dd>
            </div>
            <div className="flex justify-between border-t pt-2">
              <dt className="text-sm font-semibold">Total</dt>
              <dd className="text-sm font-bold">
                {formatCurrency(sale.totalAmount, sale.currencySymbol)}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-sm text-gray-500">Paid</dt>
              <dd className="text-sm font-medium">
                {formatCurrency(sale.amountPaid, sale.currencySymbol)}
              </dd>
            </div>
            <div className="flex justify-between">
              <dt className="text-sm text-gray-500">Change</dt>
              <dd className="text-sm font-medium text-green-600">
                {formatCurrency(sale.changeAmount, sale.currencySymbol)}
              </dd>
            </div>
          </dl>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="px-6 py-4 border-b">
          <h2 className="text-lg font-semibold text-gray-900">Items</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">#</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Product</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Unit</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Qty</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Price</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Subtotal</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Discount</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Total</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {sale.items.map((item) => (
                <tr key={item.salesItemId}>
                  <td className="px-6 py-4 text-sm text-gray-500">{item.lineNumber}</td>
                  <td className="px-6 py-4 text-sm font-medium">{item.productName}</td>
                  <td className="px-6 py-4 text-sm text-gray-500">{item.unitName}</td>
                  <td className="px-6 py-4 text-sm text-right">{item.quantity}</td>
                  <td className="px-6 py-4 text-sm text-right">{formatCurrency(item.unitPrice)}</td>
                  <td className="px-6 py-4 text-sm text-right">{formatCurrency(item.lineSubtotal)}</td>
                  <td className="px-6 py-4 text-sm text-right text-red-600">
                    {item.discountAmount > 0 ? `-${formatCurrency(item.discountAmount)}` : '-'}
                  </td>
                  <td className="px-6 py-4 text-sm text-right font-medium">{formatCurrency(item.lineTotal)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      <ConfirmDialog
        isOpen={showDelete}
        onClose={() => setShowDelete(false)}
        onConfirm={async () => {
          await deleteMutation.mutateAsync(sale.saleId);
        }}
        title="Delete Sale"
        message="Are you sure you want to delete this sale?"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
