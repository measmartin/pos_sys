import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

interface PdfColumn<T> {
  header: string;
  dataKey: keyof T;
}

export function exportToPdf<T extends Record<string, unknown>>(
  data: T[],
  columns: PdfColumn<T>[],
  title: string,
  subtitle?: string
) {
  const doc = new jsPDF();

  doc.setFontSize(18);
  doc.setTextColor(40);
  doc.text(title, 14, 22);

  if (subtitle) {
    doc.setFontSize(11);
    doc.setTextColor(100);
    doc.text(subtitle, 14, 30);
  }

  const startY = subtitle ? 36 : 28;

  autoTable(doc, {
    startY,
    head: [columns.map((c) => c.header)],
    body: data.map((item) =>
      columns.map((col) => {
        const val = item[col.dataKey];
        if (val === null || val === undefined) return '-';
        if (typeof val === 'number') {
          return Number.isInteger(val) ? String(val) : val.toFixed(2);
        }
        return String(val);
      })
    ),
    styles: { fontSize: 8, cellPadding: 3 },
    headStyles: { fillColor: [59, 130, 246], textColor: 255, fontStyle: 'bold' },
    alternateRowStyles: { fillColor: [245, 247, 250] },
    margin: { top: startY },
  });

  doc.save(`${title.toLowerCase().replace(/\s+/g, '-')}-${new Date().toISOString().split('T')[0]}.pdf`);
}

export function exportSalesToPdf(data: Record<string, unknown>[], subtitle?: string) {
  exportToPdf(
    data,
    [
      { header: 'Sale #', dataKey: 'saleNumber' },
      { header: 'Date', dataKey: 'saleDate' },
      { header: 'Customer', dataKey: 'customerName' },
      { header: 'Total', dataKey: 'totalAmount' },
      { header: 'Paid', dataKey: 'amountPaid' },
      { header: 'Status', dataKey: 'paymentStatus' },
    ],
    'Sales Report',
    subtitle
  );
}

export function exportProductsToPdf(data: Record<string, unknown>[], subtitle?: string) {
  exportToPdf(
    data,
    [
      { header: 'Product', dataKey: 'productName' },
      { header: 'Category', dataKey: 'categoryName' },
      { header: 'Qty Sold', dataKey: 'totalQuantity' },
      { header: 'Revenue', dataKey: 'totalRevenue' },
      { header: 'Sales', dataKey: 'saleCount' },
    ],
    'Top Products Report',
    subtitle
  );
}

export function exportCustomersToPdf(data: Record<string, unknown>[], subtitle?: string) {
  exportToPdf(
    data,
    [
      { header: 'Customer', dataKey: 'customerName' },
      { header: 'Phone', dataKey: 'phoneNumber' },
      { header: 'Total Spent', dataKey: 'totalSpent' },
      { header: 'Visits', dataKey: 'visitCount' },
      { header: 'Avg Order', dataKey: 'avgOrderValue' },
    ],
    'Top Customers Report',
    subtitle
  );
}
