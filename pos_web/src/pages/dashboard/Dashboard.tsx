import { useMemo } from 'react';
import { useSalesList, useProductsList, useCustomersList, useSalesByDateRange } from '@/hooks';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { ShoppingCart, Package, Users, LayoutDashboard, TrendingUp } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';
import { formatCurrency } from '@/utils/formatting';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';

const statConfig = [
  { label: 'Total Sales', key: 'sales', icon: ShoppingCart, color: 'bg-primary/10 text-primary' },
  { label: 'Products', key: 'products', icon: Package, color: 'bg-blue-500/10 text-blue-600' },
  { label: 'Customers', key: 'customers', icon: Users, color: 'bg-purple-500/10 text-purple-600' },
] as const;

export function Dashboard() {
  const { data: salesData } = useSalesList({ page: 1, pageSize: 5 });
  const { data: productsData } = useProductsList({ page: 1, pageSize: 1 });
  const { data: customersData } = useCustomersList({ page: 1, pageSize: 1 });

  const { startDate, endDate, chartDates } = useMemo(() => {
    const now = new Date();
    const end = now.toISOString().split('T')[0];
    const start = new Date(now.getTime() - 6 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
    const dates: string[] = [];
    for (let i = 6; i >= 0; i--) {
      dates.push(new Date(now.getTime() - i * 24 * 60 * 60 * 1000).toISOString().split('T')[0]);
    }
    return { startDate: start, endDate: end, chartDates: dates };
  }, []);

  const { data: rangeSales } = useSalesByDateRange(startDate, endDate);

  const chartData = useMemo(() => {
    if (!rangeSales) return [];
    const grouped = new Map<string, number>();
    rangeSales.forEach((sale) => {
      const date = sale.saleDate.split('T')[0];
      grouped.set(date, (grouped.get(date) ?? 0) + sale.totalAmount);
    });
    return chartDates.map((date) => ({
      date: new Date(date).toLocaleDateString(undefined, { month: 'short', day: 'numeric' }),
      total: grouped.get(date) ?? 0,
    }));
  }, [rangeSales, chartDates]);

  const values = {
    sales: salesData?.totalCount ?? 0,
    products: productsData?.totalCount ?? 0,
    customers: customersData?.totalCount ?? 0,
  };

  return (
    <PageLayout icon={LayoutDashboard} title="Dashboard">
      <div className="grid gap-4 md:grid-cols-3">
        {statConfig.map((stat) => {
          const Icon = stat.icon;
          return (
            <Card key={stat.key} className="transition-shadow hover:shadow-md">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">{stat.label}</CardTitle>
                <div className={`flex size-8 items-center justify-center rounded-lg ${stat.color}`}>
                  <Icon className="size-4" />
                </div>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold tracking-tight">{values[stat.key]}</div>
              </CardContent>
            </Card>
          );
        })}
      </div>

      <div className="grid gap-4 md:grid-cols-2 mt-4">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-lg flex items-center gap-2">
              <TrendingUp className="size-4" />
              Sales Trend (Last 7 Days)
            </CardTitle>
          </CardHeader>
          <CardContent>
            {chartData.length > 0 ? (
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={chartData} margin={{ top: 5, right: 5, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                    <XAxis dataKey="date" tick={{ fontSize: 12 }} />
                    <YAxis tick={{ fontSize: 12 }} tickFormatter={(v) => formatCurrency(Number(v))} />
                    <Tooltip
                      formatter={(value: number) => formatCurrency(value)}
                      contentStyle={{ borderRadius: '8px', border: '1px solid hsl(var(--border))' }}
                    />
                    <Area
                      type="monotone"
                      dataKey="total"
                      stroke="hsl(var(--primary))"
                      fill="hsl(var(--primary))"
                      fillOpacity={0.1}
                      strokeWidth={2}
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            ) : (
              <div className="h-64 flex items-center justify-center text-muted-foreground text-sm">
                No sales data available
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">Recent Sales</CardTitle>
          </CardHeader>
          <CardContent>
            {salesData && salesData.data.length > 0 ? (
              <div className="flex flex-col gap-0">
                {salesData.data.slice(0, 5).map((sale, idx) => (
                  <div
                    key={sale.saleId}
                    className={`flex items-center justify-between py-3 ${
                      idx < Math.min(salesData.data.length, 5) - 1 ? 'border-b' : ''
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <div className="flex size-8 items-center justify-center rounded-full bg-muted text-xs font-medium text-muted-foreground">
                        {sale.saleNumber.slice(-2)}
                      </div>
                      <div>
                        <p className="text-sm font-medium">{sale.saleNumber}</p>
                        <p className="text-xs text-muted-foreground">
                          {new Date(sale.saleDate).toLocaleDateString()} · {sale.customerName ?? 'Walk-in'}
                        </p>
                      </div>
                    </div>
                    <p className="text-sm font-semibold tabular-nums">
                      {sale.currencySymbol ?? '$'}{sale.totalAmount.toFixed(2)}
                    </p>
                  </div>
                ))}
              </div>
            ) : (
              <div className="py-8 text-center text-muted-foreground">
                <p className="text-sm">No recent sales</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>
    </PageLayout>
  );
}

export default Dashboard;
