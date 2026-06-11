import { useCallback } from 'react';
import type { SalesDetailsDto } from '@PosApi/types';
import { formatCurrency, formatDate } from '@/utils/formatting';

export function useThermalPrint() {
  const print = useCallback((sale: SalesDetailsDto, storeName?: string, storeAddress?: string, storePhone?: string) => {
    const printWindow = window.open('', '_blank');
    if (!printWindow) {
      console.error('Failed to open print window');
      return;
    }

    const sym = sale.currencySymbol ?? sale.currencyCode ?? '$';

    const receiptHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Receipt ${sale.saleNumber}</title>
  <style>
    @page { size: 80mm auto; margin: 0; }
    body { margin: 0; padding: 2mm; font-family: 'Courier New', Courier, monospace; font-size: 12px; line-height: 1.3; color: #000; background: #fff; }
    .thermal-receipt { width: 76mm; max-width: 76mm; margin: 0 auto; }
    .tr-header { text-align: center; margin-bottom: 4px; }
    .tr-store-name { font-size: 16px; font-weight: bold; margin: 0 0 2px; }
    .tr-store-info { font-size: 11px; margin: 0; color: #333; }
    .tr-divider { border-top: 1px dashed #000; margin: 6px 0; }
    .tr-meta p { margin: 1px 0; font-size: 11px; }
    .tr-items { width: 100%; border-collapse: collapse; font-size: 11px; }
    .tr-items th { text-align: left; border-bottom: 1px dashed #000; padding-bottom: 2px; }
    .tr-items td { padding: 1px 0; vertical-align: top; }
    .tr-item-name { width: 45%; word-break: break-word; }
    .tr-item-qty { width: 15%; text-align: right; }
    .tr-item-price { width: 20%; text-align: right; }
    .tr-item-total { width: 20%; text-align: right; }
    .tr-totals { font-size: 12px; }
    .tr-row { display: flex; justify-content: space-between; margin: 2px 0; }
    .tr-total { font-size: 14px; font-weight: bold; }
    .tr-status { font-weight: bold; }
    .tr-footer { text-align: center; margin-top: 8px; font-size: 12px; font-weight: bold; }
  </style>
</head>
<body>
  <div class="thermal-receipt">
    <div class="tr-header">
      <h2 class="tr-store-name">${escapeHtml(storeName ?? 'Amrit POS')}</h2>
      ${storeAddress ? `<p class="tr-store-info">${escapeHtml(storeAddress)}</p>` : ''}
      ${storePhone ? `<p class="tr-store-info">${escapeHtml(storePhone)}</p>` : ''}
    </div>
    <div class="tr-divider"></div>
    <div class="tr-meta">
      <p><strong>${escapeHtml(sale.saleNumber)}</strong></p>
      <p>${escapeHtml(formatDate(sale.saleDate))}</p>
      ${sale.customerName ? `<p>Customer: ${escapeHtml(sale.customerName)}</p>` : ''}
      <p>Phone: ${escapeHtml(sale.phoneNumber)}</p>
    </div>
    <div class="tr-divider"></div>
    <table class="tr-items">
      <thead>
        <tr>
          <th class="tr-item-name">Item</th>
          <th class="tr-item-qty">Qty</th>
          <th class="tr-item-price">Price</th>
          <th class="tr-item-total">Total</th>
        </tr>
      </thead>
      <tbody>
        ${sale.items.map(item => `
        <tr>
          <td class="tr-item-name">${escapeHtml(item.productName ?? 'Item')}</td>
          <td class="tr-item-qty">${item.quantity}</td>
          <td class="tr-item-price">${formatCurrency(item.unitPrice, sym)}</td>
          <td class="tr-item-total">${formatCurrency(item.lineTotal, sym)}</td>
        </tr>
        `).join('')}
      </tbody>
    </table>
    <div class="tr-divider"></div>
    <div class="tr-totals">
      <div class="tr-row"><span>Subtotal</span><span>${formatCurrency(sale.subtotal, sym)}</span></div>
      ${sale.totalDiscount > 0 ? `<div class="tr-row"><span>Discount</span><span>-${formatCurrency(sale.totalDiscount, sym)}</span></div>` : ''}
      <div class="tr-divider"></div>
      <div class="tr-row tr-total"><span>TOTAL</span><span>${formatCurrency(sale.totalAmount, sym)}</span></div>
      <div class="tr-divider"></div>
      <div class="tr-row"><span>Paid</span><span>${formatCurrency(sale.amountPaid, sym)}</span></div>
      ${sale.changeAmount > 0 ? `<div class="tr-row"><span>Change</span><span>${formatCurrency(sale.changeAmount, sym)}</span></div>` : ''}
      <div class="tr-row"><span>Status</span><span class="tr-status">${escapeHtml(sale.paymentStatus)}</span></div>
    </div>
    <div class="tr-divider"></div>
    <div class="tr-footer"><p>Thank you!</p></div>
  </div>
  <script>
    window.onload = function() {
      setTimeout(function() {
        window.print();
      }, 300);
    };
  </script>
</body>
</html>
    `;

    printWindow.document.open();
    printWindow.document.write(receiptHtml);
    printWindow.document.close();
  }, []);

  return { print };
}

function escapeHtml(text: string | null | undefined): string {
  if (!text) return '';
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}
