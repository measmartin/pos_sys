import * as XLSX from 'xlsx';

function formatSheetData<T extends Record<string, unknown>>(data: T[], columns: { key: string; header: string }[]) {
  const headerRow = columns.reduce((acc, col) => {
    acc[col.key] = col.header;
    return acc;
  }, {} as Record<string, string>);

  const rows = data.map((item) =>
    columns.reduce((acc, col) => {
      const val = item[col.key];
      acc[col.key] = val instanceof Date ? val.toISOString().split('T')[0] : val;
      return acc;
    }, {} as Record<string, unknown>)
  );

  return [headerRow, ...rows];
}

export function exportToExcel<T extends Record<string, unknown>>(
  data: T[],
  columns: { key: string; header: string }[],
  filename = 'report',
  sheetName = 'Report'
) {
  const sheetData = formatSheetData(data, columns);
  const ws = XLSX.utils.json_to_sheet(sheetData, { skipHeader: true });

  const colWidths = columns.map((col) => ({
    wch: Math.max(col.header.length, 12),
  }));
  ws['!cols'] = colWidths;

  const wb = XLSX.utils.book_new();
  XLSX.utils.book_append_sheet(wb, ws, sheetName);
  XLSX.writeFile(wb, `${filename}.xlsx`);
}

export function exportSalesToExcel(data: Record<string, unknown>[]) {
  exportToExcel(
    data,
    [
      { key: 'saleNumber', header: 'Sale #' },
      { key: 'saleDate', header: 'Date' },
      { key: 'customerName', header: 'Customer' },
      { key: 'phoneNumber', header: 'Phone' },
      { key: 'currencyCode', header: 'Currency' },
      { key: 'subtotal', header: 'Subtotal' },
      { key: 'totalDiscount', header: 'Discount' },
      { key: 'totalAmount', header: 'Total' },
      { key: 'amountPaid', header: 'Amount Paid' },
      { key: 'changeAmount', header: 'Change' },
      { key: 'paymentStatus', header: 'Payment Status' },
      { key: 'saleStatus', header: 'Sale Status' },
      { key: 'notes', header: 'Notes' },
    ],
    `sales-report-${new Date().toISOString().split('T')[0]}`,
    'Sales Report'
  );
}

export function exportProductsToExcel(data: Record<string, unknown>[]) {
  exportToExcel(
    data,
    [
      { key: 'productName', header: 'Product' },
      { key: 'categoryName', header: 'Category' },
      { key: 'totalQuantity', header: 'Total Qty' },
      { key: 'totalRevenue', header: 'Revenue' },
      { key: 'saleCount', header: 'Sale Count' },
    ],
    `products-report-${new Date().toISOString().split('T')[0]}`,
    'Top Products'
  );
}

export function exportCustomersToExcel(data: Record<string, unknown>[]) {
  exportToExcel(
    data,
    [
      { key: 'customerName', header: 'Customer' },
      { key: 'phoneNumber', header: 'Phone' },
      { key: 'totalSpent', header: 'Total Spent' },
      { key: 'visitCount', header: 'Visits' },
      { key: 'avgOrderValue', header: 'Avg Order' },
    ],
    `customers-report-${new Date().toISOString().split('T')[0]}`,
    'Top Customers'
  );
}
