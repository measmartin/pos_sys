import type { SalesDetailsDto } from '@PosApi/types';
import { formatCurrency, formatDate } from '@/utils/formatting';
import './thermal-receipt.css';

interface ThermalReceiptProps {
  sale: SalesDetailsDto;
  storeName?: string;
  storeAddress?: string;
  storePhone?: string;
}

export function ThermalReceipt({ sale, storeName = 'Amrit POS', storeAddress = '', storePhone = '' }: ThermalReceiptProps) {
  const sym = sale.currencySymbol ?? sale.currencyCode ?? '$';
  const date = formatDate(sale.saleDate);

  return (
    <div className="thermal-receipt">
      <div className="tr-header">
        <h2 className="tr-store-name">{storeName}</h2>
        {storeAddress && <p className="tr-store-info">{storeAddress}</p>}
        {storePhone && <p className="tr-store-info">{storePhone}</p>}
      </div>

      <div className="tr-divider" />

      <div className="tr-meta">
        <p><strong>{sale.saleNumber}</strong></p>
        <p>{date}</p>
        {sale.customerName && <p>Customer: {sale.customerName}</p>}
        <p>Phone: {sale.phoneNumber}</p>
      </div>

      <div className="tr-divider" />

      <table className="tr-items">
        <thead>
          <tr>
            <th className="tr-item-name">Item</th>
            <th className="tr-item-qty">Qty</th>
            <th className="tr-item-price">Price</th>
            <th className="tr-item-total">Total</th>
          </tr>
        </thead>
        <tbody>
          {sale.items.map((item) => (
            <tr key={item.salesItemId}>
              <td className="tr-item-name">{item.productName}</td>
              <td className="tr-item-qty">{item.quantity}</td>
              <td className="tr-item-price">{formatCurrency(item.unitPrice, sym)}</td>
              <td className="tr-item-total">{formatCurrency(item.lineTotal, sym)}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <div className="tr-divider" />

      <div className="tr-totals">
        <div className="tr-row">
          <span>Subtotal</span>
          <span>{formatCurrency(sale.subtotal, sym)}</span>
        </div>
        {sale.totalDiscount > 0 && (
          <div className="tr-row">
            <span>Discount</span>
            <span>-{formatCurrency(sale.totalDiscount, sym)}</span>
          </div>
        )}
        <div className="tr-divider" />
        <div className="tr-row tr-total">
          <span>TOTAL</span>
          <span>{formatCurrency(sale.totalAmount, sym)}</span>
        </div>
        <div className="tr-divider" />
        <div className="tr-row">
          <span>Paid</span>
          <span>{formatCurrency(sale.amountPaid, sym)}</span>
        </div>
        {sale.changeAmount > 0 && (
          <div className="tr-row">
            <span>Change</span>
            <span>{formatCurrency(sale.changeAmount, sym)}</span>
          </div>
        )}
        <div className="tr-row">
          <span>Status</span>
          <span className="tr-status">{sale.paymentStatus}</span>
        </div>
      </div>

      <div className="tr-divider" />

      <div className="tr-footer">
        <p>Thank you!</p>
      </div>
    </div>
  );
}

export default ThermalReceipt;
