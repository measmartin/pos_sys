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
  LineChart,
  Line,
} from 'recharts';
import { useSalesSummary, useDailySales, useSalesForExport } from '../../hooks/useReports';
import { DateRangeFilter, ExportButtons } from './ReportFilters';
import { formatCurrency, formatDate } from '../../utils/formatting';
import type { SalesDetailsExportDto } from '@PosApi/types';
import { TrendingUp, ShoppingCart, DollarSign, Percent } from 'lucide-react';

export function SalesReport() {
  const [startDate, setStartDate] = useState(() => {
    const d = new Date();
    d.setDate(d.getDate() - 30);
    return d.toISOString().split('T')[0];
  });
  const [endDate, setEndDate] = useState(() => new Date().toISOString().split('T')[0]);
  const [currencyId, setCurrencyId] = useState('all');
  const [chartType, setChartType] = useState<'bar' | 'line'>('bar');

  const params = {
    startDate,
    endDate,
    currencyId: currencyId === 'all' ? undefined : Number(currencyId),
  };

  const { data: summary, isLoading: summaryLoading } = useSalesSummary(params);
  const { data: dailySales, isLoading: dailyLoading } = useDailySales(params);
  const { data: exportData } = useSalesForExport(params);

  const handleExportExcel = async () => {
    if (!exportData) return;
    const { exportSalesToExcel } = await import('../../utils/exportExcel');
    exportSalesToExcel(
      exportData.map((s) => ({
        saleNumber: s.saleNumber,
        saleDate: formatDate(s.saleDate),
        customerName: s.customerName ?? 'Walk-in',
        phoneNumber: s.phoneNumber,
        currencyCode: s.currencyCode,
        subtotal: s.subtotal,
        totalDiscount: s.totalDiscount,
        totalAmount: s.totalAmount,
        amountPaid: s.amountPaid,
        changeAmount: s.changeAmount,
        paymentStatus: s.paymentStatus,
        saleStatus: s.saleStatus,
        notes: s.notes ?? '-',
      }))
    );
  };

  const handleExportPdf = async () => {
    if (!exportData) return;
    const { exportSalesToPdf } = await import('../../utils/exportPdf');
    exportSalesToPdf(
      exportData.map((s) => ({
        saleNumber: s.saleNumber,
        saleDate: formatDate(s.saleDate),
        customerName: s.customerName ?? 'Walk-in',
        totalAmount: s.totalAmount,
        amountPaid: s.amountPaid,
        paymentStatus: s.paymentStatus,
      })),
      `${formatDate(startDate)} - ${formatDate(endDate)}`
    );
  };

  const salesColumns: Column<SalesDetailsExportDto>[] = [
    { key: 'saleNumber', header: 'Sale #', render: (s) => <span className="font-medium">{s.saleNumber}</span> },
    { key: 'saleDate', header: 'Date', render: (s) => formatDate(s.saleDate) },
    { key: 'customerName', header: 'Customer', render: (s) => s.customerName ?? 'Walk-in' },
    { key: 'totalAmount', header: 'Total', className: 'text-right', render: (s) => formatCurrency(s.totalAmount, s.currencySymbol) },
    { key: 'amountPaid', header: 'Paid', className: 'text-right', render: (s) => formatCurrency(s.amountPaid, s.currencySymbol) },
    { key: 'paymentStatus', header: 'Payment' },
    { key: 'saleStatus', header: 'Status' },
  ];

  const chartData = dailySales?.map((d) => ({
    date: formatDate(d.date),
    revenue: d.revenue,
    transactions: d.transactionCount,
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

      {summaryLoading ? (
        <div className="grid gap-4 md:grid-cols-4">
          {[1, 2, 3, 4].map((i) => (
            <Card key={i}>
              <CardContent className="p-6">
                <div className="animate-pulse h-8 bg-muted rounded w-24" />
              </CardContent>
            </Card>
          ))}
        </div>
      ) : summary ? (
        <div className="grid gap-4 md:grid-cols-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
              <DollarSign className="size-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {formatCurrency(summary.totalRevenue, summary.currencySymbol)}
              </div>
              <p className="text-xs text-muted-foreground">
                {summary.transactionCount} transactions
              </p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Transactions</CardTitle>
              <ShoppingCart className="size-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">{summary.transactionCount}</div>
              <p className="text-xs text-muted-foreground">in period</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Avg Order</CardTitle>
              <TrendingUp className="size-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold">
                {formatCurrency(summary.avgOrderValue, summary.currencySymbol)}
              </div>
              <p className="text-xs text-muted-foreground">per transaction</p>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium">Total Discount</CardTitle>
              <Percent className="size-4 text-muted-foreground" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl font-bold text-destructive">
                {formatCurrency(summary.totalDiscount, summary.currencySymbol)}
              </div>
              <p className="text-xs text-muted-foreground">given away</p>
            </CardContent>
          </Card>
        </div>
      ) : null}

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Revenue Trend</CardTitle>
          <div className="flex gap-2">
            <button
              className={`text-xs px-2 py-1 rounded ${chartType === 'bar' ? 'bg-primary text-primary-foreground' : 'bg-muted'}`}
              onClick={() => setChartType('bar')}
            >
              Bar
            </button>
            <button
              className={`text-xs px-2 py-1 rounded ${chartType === 'line' ? 'bg-primary text-primary-foreground' : 'bg-muted'}`}
              onClick={() => setChartType('line')}
            >
              Line
            </button>
          </div>
        </CardHeader>
        <CardContent>
          {dailyLoading ? (
            <div className="h-64 flex items-center justify-center">
              <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
            </div>
          ) : chartData.length > 0 ? (
            <ResponsiveContainer width="100%" height={300}>
              {chartType === 'bar' ? (
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" tick={{ fontSize: 10 }} interval="preserveStartEnd" />
                  <YAxis tick={{ fontSize: 10 }} />
                  <Tooltip formatter={(value: unknown) => typeof value === 'number' ? formatCurrency(value) : String(value)} />
                  <Bar dataKey="revenue" fill="hsl(var(--primary))" radius={[4, 4, 0, 0]} />
                </BarChart>
              ) : (
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="date" tick={{ fontSize: 10 }} interval="preserveStartEnd" />
                  <YAxis tick={{ fontSize: 10 }} />
                  <Tooltip formatter={(value: unknown) => typeof value === 'number' ? formatCurrency(value) : String(value)} />
                  <Line type="monotone" dataKey="revenue" stroke="hsl(var(--primary))" strokeWidth={2} dot={false} />
                </LineChart>
              )}
            </ResponsiveContainer>
          ) : (
            <div className="h-64 flex items-center justify-center text-muted-foreground">
              No data for selected range
            </div>
          )}
        </CardContent>
      </Card>

      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Sales Details</CardTitle>
          <ExportButtons onExportExcel={handleExportExcel} onExportPdf={handleExportPdf} />
        </CardHeader>
        <CardContent className="p-0">
          <DataTable columns={salesColumns} data={exportData?.slice(0, 50) ?? []} keyExtractor={(s) => s.saleNumber} emptyMessage="No sales found" />
          {exportData && exportData.length > 50 && (
            <div className="text-center py-2 text-xs text-muted-foreground">
              Showing 50 of {exportData.length} sales. Export to see all.
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}

export default SalesReport;
