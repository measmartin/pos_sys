import { useSalesList, useProductsList, useCustomersList } from '../hooks';

export function Dashboard() {
  const { data: salesData } = useSalesList({ page: 1, pageSize: 5 });
  const { data: productsData } = useProductsList({ page: 1, pageSize: 1 });
  const { data: customersData } = useCustomersList({ page: 1, pageSize: 1 });

  const totalSales = salesData?.totalCount ?? 0;
  const totalProducts = productsData?.totalCount ?? 0;
  const totalCustomers = customersData?.totalCount ?? 0;

  const stats = [
    { label: 'Total Sales', value: totalSales, color: 'bg-blue-500' },
    { label: 'Products', value: totalProducts, color: 'bg-green-500' },
    { label: 'Customers', value: totalCustomers, color: 'bg-purple-500' },
  ];

  return (
    <div>
      <h1 className="text-2xl font-bold text-gray-900 mb-6">Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {stats.map((stat) => (
          <div key={stat.label} className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
            <div className="flex items-center gap-4">
              <div className={`w-12 h-12 ${stat.color} rounded-lg flex items-center justify-center`}>
                <span className="text-white text-xl font-bold">
                  {stat.value}
                </span>
              </div>
              <div>
                <p className="text-sm text-gray-500">{stat.label}</p>
                <p className="text-2xl font-semibold text-gray-900">{stat.value}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
      <div className="bg-white rounded-lg shadow-sm border border-gray-200 p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Recent Sales</h2>
        {salesData && salesData.data.length > 0 ? (
          <div className="space-y-3">
            {salesData.data.slice(0, 5).map((sale) => (
              <div key={sale.saleId} className="flex items-center justify-between py-2 border-b last:border-b-0">
                <div>
                  <p className="text-sm font-medium text-gray-900">{sale.saleNumber}</p>
                  <p className="text-xs text-gray-500">
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
          <p className="text-gray-500 text-sm">No recent sales</p>
        )}
      </div>
    </div>
  );
}
