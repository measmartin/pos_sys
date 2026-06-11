import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
  Tooltip,
} from 'recharts';
import { usePaymentBreakdown } from '../../hooks/useReports';
import { DateRangeFilter } from './ReportFilters';
import { formatCurrency } from '../../utils/formatting';
import { StatusBadge } from '../../components/ui/StatusBadge';

const COLORS = ['#10b981', '#f59e0b', '#ef4444'];

export function PaymentReport() {
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

  const { data, isLoading } = usePaymentBreakdown(params);

  const chartData = data?.map((d) => ({
    name: d.paymentStatus,
    value: d.totalAmount,
    count: d.count,
    percentage: d.percentage,
  })) ?? [];

  const totalAmount = data?.reduce((sum, d) => sum + d.totalAmount, 0) ?? 0;
  const totalCount = data?.reduce((sum, d) => sum + d.count, 0) ?? 0;

  return (
    <div className="space-y-6">
      <DateRangeFilter
        startDate={startDate}
        endDate={endDate}
        currencyId={currencyId}
        onDateChange={(s, e) => { setStartDate(s); setEndDate(e); }}
        onCurrencyChange={setCurrencyId}
      />

      <div className="grid gap-4 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Payment Distribution</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="h-64 flex items-center justify-center">
                <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
              </div>
            ) : chartData.length > 0 ? (
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="value"
                    label={({ name, percent }) => `${name} (${((percent ?? 0) * 100).toFixed(0)}%)`}
                  >
                    {chartData.map((_entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
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

        <Card>
          <CardHeader>
            <CardTitle>Summary</CardTitle>
          </CardHeader>
          <CardContent>
            {isLoading ? (
              <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="animate-pulse h-12 bg-muted rounded" />
                ))}
              </div>
            ) : (
              <div className="space-y-4">
                <div className="flex justify-between items-center p-3 bg-muted/50 rounded-lg">
                  <span className="text-sm font-medium">Total Transactions</span>
                  <span className="text-lg font-bold">{totalCount}</span>
                </div>
                <div className="flex justify-between items-center p-3 bg-muted/50 rounded-lg">
                  <span className="text-sm font-medium">Total Revenue</span>
                  <span className="text-lg font-bold">{formatCurrency(totalAmount)}</span>
                </div>
                {data?.map((d) => (
                  <div key={d.paymentStatus} className="flex justify-between items-center p-3 border rounded-lg">
                    <div className="flex items-center gap-2">
                      <StatusBadge status={d.paymentStatus} label={d.paymentStatus} />
                      <span className="text-xs text-muted-foreground">({d.count})</span>
                    </div>
                    <div className="text-right">
                      <span className="font-medium">{formatCurrency(d.totalAmount)}</span>
                      <span className="text-xs text-muted-foreground ml-2">{d.percentage}%</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

export default PaymentReport;
