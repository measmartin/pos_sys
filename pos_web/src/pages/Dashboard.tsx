import { useSalesList, useProductsList, useCustomersList } from '../hooks';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { ShoppingCart, Package, Users } from 'lucide-react';

const iconMap = {
  'Total Sales': ShoppingCart,
  'Products': Package,
  'Customers': Users,
} as const;

export function Dashboard() {
  const { data: salesData } = useSalesList({ page: 1, pageSize: 5 });
  const { data: productsData } = useProductsList({ page: 1, pageSize: 1 });
  const { data: customersData } = useCustomersList({ page: 1, pageSize: 1 });

  const totalSales = salesData?.totalCount ?? 0;
  const totalProducts = productsData?.totalCount ?? 0;
  const totalCustomers = customersData?.totalCount ?? 0;

  const stats = [
    { label: 'Total Sales', value: totalSales },
    { label: 'Products', value: totalProducts },
    { label: 'Customers', value: totalCustomers },
  ] as const;

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold tracking-tight">Dashboard</h1>
      <div className="grid gap-4 md:grid-cols-3">
        {stats.map((stat) => {
          const Icon = iconMap[stat.label];
          return (
            <Card key={stat.label}>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">{stat.label}</CardTitle>
                <Icon className="size-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
              </CardContent>
            </Card>
          );
        })}
      </div>
      <Card>
        <CardHeader>
          <CardTitle className="text-lg">Recent Sales</CardTitle>
        </CardHeader>
        <CardContent>
          {salesData && salesData.data.length > 0 ? (
            <div className="space-y-3">
              {salesData.data.slice(0, 5).map((sale) => (
                <div key={sale.saleId} className="flex items-center justify-between py-2 border-b last:border-b-0">
                  <div>
                    <p className="text-sm font-medium">{sale.saleNumber}</p>
                    <p className="text-xs text-muted-foreground">
                      {new Date(sale.saleDate).toLocaleDateString()} - {sale.customerName ?? 'Walk-in'}
                    </p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-semibold">
                      {sale.currencySymbol ?? '$'}{sale.totalAmount.toFixed(2)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-sm text-muted-foreground">No recent sales</p>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
