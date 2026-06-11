import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { DataTable, type Column } from '@/components/ui/DataTable';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { useTopCustomers } from '../../hooks/useReports';
import { DateRangeFilter, ExportButtons } from './ReportFilters';
import { formatCurrency } from '../../utils/formatting';
import type { TopCustomerDto } from '@PosApi/types';

export function CustomerReport() {
  const [startDate, setStartDate] = useState(() => {
    const d = new Date();
    d.setDate(d.getDate() - 30);
    return d.toISOString().split('T')[0];
  });
  const [endDate, setEndDate] = useState(() => new Date().toISOString().split('T')[0]);
  const [currencyId, setCurrencyId] = useState('all');

  const params = {
    startDate,
    endDate,
    currencyId: currencyId === 'all' ? undefined : Number(currencyId),
  };

  const { data: topCustomers, isLoading } = useTopCustomers(params, 20);

  const handleExportExcel = async () => {
    if (!topCustomers) return;
    const { exportCustomersToExcel } = await import('../../utils/exportExcel');
    exportCustomersToExcel(
      topCustomers.map((c) => ({
        customerName: c.customerName,
        phoneNumber: c.phoneNumber ?? '-',
        totalSpent: c.totalSpent,
        visitCount: c.visitCount,
        avgOrderValue: c.avgOrderValue,
      }))
    );
  };

  const handleExportPdf = async () => {
    if (!topCustomers) return;
    const { exportCustomersToPdf } = await import('../../utils/exportPdf');
    exportCustomersToPdf(
      topCustomers.map((c) => ({
        customerName: c.customerName,
        phoneNumber: c.phoneNumber ?? '-',
        totalSpent: c.totalSpent,
        visitCount: c.visitCount,
        avgOrderValue: c.avgOrderValue,
      })),
      `${startDate} - ${endDate}`
    );
  };

  const customerColumns: Column<TopCustomerDto>[] = [
    { key: 'customerName', header: 'Customer', render: (c) => <span className="font-medium">{c.customerName}</span> },
    { key: 'phoneNumber', header: 'Phone', render: (c) => c.phoneNumber ?? '-' },
    { key: 'totalSpent', header: 'Total Spent', className: 'text-right', render: (c) => <span className="font-medium">{formatCurrency(c.totalSpent)}</span> },
    { key: 'visitCount', header: 'Visits', className: 'text-right' },
    { key: 'avgOrderValue', header: 'Avg Order', className: 'text-right', render: (c) => formatCurrency(c.avgOrderValue) },
  ];

  const chartData = topCustomers?.slice(0, 10).map((c) => ({
    name: c.customerName.length > 15 ? c.customerName.slice(0, 15) + '...' : c.customerName,
    spent: c.totalSpent,
    visits: c.visitCount,
  })) ?? [];

  return (
    <div className="space-y-6">
      <DateRangeFilter
        startDate={startDate}
        endDate={endDate}
        currencyId={currencyId}
        onDateChange={(s, e) => { setStartDate(s); setEndDate(e); }}
        onCurrencyChange={setCurrencyId}
      />

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Top Customers by Spend</CardTitle>
          <ExportButtons onExportExcel={handleExportExcel} onExportPdf={handleExportPdf} />
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="h-64 flex items-center justify-center">
              <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
            </div>
          ) : chartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={chartData} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" tick={{ fontSize: 10 }} />
                <YAxis type="category" dataKey="name" tick={{ fontSize: 10 }} width={120} />
                <Tooltip formatter={(value: unknown) => typeof value === 'number' ? formatCurrency(value) : String(value)} />
                <Bar dataKey="spent" fill="hsl(var(--primary))" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-64 flex items-center justify-center text-muted-foreground">
              No data
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Customer Details</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <DataTable columns={customerColumns} data={topCustomers ?? []} keyExtractor={(c) => c.customerId ?? 0} isLoading={isLoading} emptyMessage="No data" />
        </CardContent>
      </Card>
    </div>
  );
}

export default CustomerReport;
