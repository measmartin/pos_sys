import { useState, Suspense, lazy } from 'react';
import { BarChart3 } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';

const SalesReport = lazy(() => import('./SalesReport'));
const ProductReport = lazy(() => import('./ProductReport'));
const CustomerReport = lazy(() => import('./CustomerReport'));
const PaymentReport = lazy(() => import('./PaymentReport'));

const REPORT_TABS = [
  { id: 'sales', label: 'Sales' },
  { id: 'products', label: 'Products' },
  { id: 'customers', label: 'Customers' },
  { id: 'payments', label: 'Payments' },
];

export function Reports() {
  const [activeTab, setActiveTab] = useState('sales');

  return (
    <PageLayout icon={BarChart3} title="Reports">
      <div className="flex gap-1 bg-muted p-1 rounded-lg w-fit mb-4">
        {REPORT_TABS.map((tab) => (
          <button
            key={tab.id}
            className={`px-4 py-2 text-sm font-medium rounded-md transition-colors ${
              activeTab === tab.id
                ? 'bg-background text-foreground shadow-sm'
                : 'text-muted-foreground hover:text-foreground'
            }`}
            onClick={() => setActiveTab(tab.id)}
          >
            {tab.label}
          </button>
        ))}
      </div>

      <Suspense
        fallback={
          <div className="flex justify-center py-12">
            <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
          </div>
        }
      >
        {activeTab === 'sales' && <SalesReport />}
        {activeTab === 'products' && <ProductReport />}
        {activeTab === 'customers' && <CustomerReport />}
        {activeTab === 'payments' && <PaymentReport />}
      </Suspense>
    </PageLayout>
  );
}

export default Reports;
