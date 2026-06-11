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
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';
import { useTopProducts, useCategorySales } from '../../hooks/useReports';
import { DateRangeFilter, ExportButtons } from './ReportFilters';
import { formatCurrency } from '../../utils/formatting';
import type { TopProductDto } from '@PosApi/types';

const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#06b6d4', '#f97316', '#6366f1', '#14b8a6'];

export function ProductReport() {
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

  const { data: topProducts, isLoading: productsLoading } = useTopProducts(params, 15);
  const { data: categorySales, isLoading: categoryLoading } = useCategorySales(params);

  const handleExportExcel = async () => {
    if (!topProducts) return;
    const { exportProductsToExcel } = await import('../../utils/exportExcel');
    exportProductsToExcel(
      topProducts.map((p) => ({
        productName: p.productName,
        categoryName: p.categoryName ?? '-',
        totalQuantity: p.totalQuantity,
        totalRevenue: p.totalRevenue,
        saleCount: p.saleCount,
      }))
    );
  };

  const handleExportPdf = async () => {
    if (!topProducts) return;
    const { exportProductsToPdf } = await import('../../utils/exportPdf');
    exportProductsToPdf(
      topProducts.map((p) => ({
        productName: p.productName,
        categoryName: p.categoryName ?? '-',
        totalQuantity: p.totalQuantity,
        totalRevenue: p.totalRevenue,
        saleCount: p.saleCount,
      })),
      `${startDate} - ${endDate}`
    );
  };

  const productColumns: Column<TopProductDto>[] = [
    { key: 'productName', header: 'Product', render: (p) => <span className="font-medium">{p.productName}</span> },
    { key: 'categoryName', header: 'Category', render: (p) => p.categoryName ?? '-' },
    { key: 'totalQuantity', header: 'Qty Sold', className: 'text-right' },
    { key: 'totalRevenue', header: 'Revenue', className: 'text-right', render: (p) => <span className="font-medium">{formatCurrency(p.totalRevenue)}</span> },
    { key: 'saleCount', header: 'Sales', className: 'text-right' },
  ];

  const productChartData = topProducts?.slice(0, 10).map((p) => ({
    name: p.productName.length > 20 ? p.productName.slice(0, 20) + '...' : p.productName,
    revenue: p.totalRevenue,
    quantity: p.totalQuantity,
  })) ?? [];

  const categoryChartData = categorySales?.map((c) => ({
    name: c.categoryName,
    value: c.totalRevenue,
    percentage: c.percentage,
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

      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>Top Products by Revenue</CardTitle>
            <ExportButtons onExportExcel={handleExportExcel} onExportPdf={handleExportPdf} />
          </CardHeader>
          <CardContent>
            {productsLoading ? (
              <div className="h-64 flex items-center justify-center">
                <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
              </div>
            ) : productChartData.length > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={productChartData} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" tick={{ fontSize: 10 }} />
                  <YAxis type="category" dataKey="name" tick={{ fontSize: 10 }} width={120} />
                  <Tooltip formatter={(value: unknown) => typeof value === 'number' ? formatCurrency(value) : String(value)} />
                  <Bar dataKey="revenue" fill="hsl(var(--primary))" radius={[0, 4, 4, 0]} />
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
            <CardTitle>Sales by Category</CardTitle>
          </CardHeader>
          <CardContent>
            {categoryLoading ? (
              <div className="h-64 flex items-center justify-center">
                <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
              </div>
            ) : categoryChartData.length > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={categoryChartData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) => `${name} (${((percent ?? 0) * 100).toFixed(0)}%)`}
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {categoryChartData.map((_entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Legend />
                  <Tooltip formatter={(value: unknown) => typeof value === 'number' ? formatCurrency(value) : String(value)} />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="h-64 flex items-center justify-center text-muted-foreground">
                No data
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Product Performance</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <DataTable columns={productColumns} data={topProducts ?? []} keyExtractor={(p) => p.productId} isLoading={productsLoading} emptyMessage="No data" />
        </CardContent>
      </Card>
    </div>
  );
}

export default ProductReport;
