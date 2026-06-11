import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from '@/components/ui/sonner';
import { TooltipProvider } from '@/components/ui/tooltip';
import { ThemeProvider } from '@/components/ui/theme-provider';
import { AuthGuard } from '@/components/auth/AuthGuard';
import { MainLayout } from './layouts/MainLayout';
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/dashboard/Dashboard'));
const SalesPage = lazy(() => import('./pages/sales/SalesPage'));
const SaleDetail = lazy(() => import('./pages/sales/SaleDetail'));
const EditSale = lazy(() => import('./pages/sales/EditSale'));
const Products = lazy(() => import('./pages/products/Products'));
const ProductDetail = lazy(() => import('./pages/products/ProductDetail'));
const ProductForm = lazy(() => import('./pages/products/ProductForm'));
const Customers = lazy(() => import('./pages/customers/Customers'));
const CustomerDetail = lazy(() => import('./pages/customers/CustomerDetail'));
const CategoriesPage = lazy(() => import('./pages/admin/CategoriesPage'));
const UnitsPage = lazy(() => import('./pages/admin/UnitsPage'));
const CurrenciesPage = lazy(() => import('./pages/admin/CurrenciesPage'));
const DiagnosticsPage = lazy(() => import('./pages/admin/DiagnosticsPage'));
const Reports = lazy(() => import('./pages/reports/Reports'));
const Login = lazy(() => import('./pages/auth/Login'));

const LoadingFallback = () => (
  <div className="flex items-center justify-center h-screen">
    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
  </div>
);

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      refetchOnWindowFocus: false,
    },
  },
});

function App() {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
      <QueryClientProvider client={queryClient}>
        <TooltipProvider>
          <BrowserRouter>
            <Suspense fallback={<LoadingFallback />}>
              <Routes>
                <Route path="/login" element={<Login />} />
                <Route element={<AuthGuard><MainLayout /></AuthGuard>}>
                  <Route path="/" element={<Dashboard />} />
                  <Route path="/sales" element={<SalesPage />} />
                  <Route path="/reports" element={<Reports />} />
                  <Route path="/sales/:id" element={<SaleDetail />} />
                  <Route path="/sales/:id/edit" element={<EditSale />} />
                  <Route path="/products" element={<Products />} />
                  <Route path="/products/new" element={<ProductForm />} />
                  <Route path="/products/:id" element={<ProductDetail />} />
                  <Route path="/products/:id/edit" element={<ProductForm />} />
                  <Route path="/customers" element={<Customers />} />
                  <Route path="/customers/:id" element={<CustomerDetail />} />
                  <Route path="/admin/categories" element={<CategoriesPage />} />
                  <Route path="/admin/units" element={<UnitsPage />} />
                  <Route path="/admin/currencies" element={<CurrenciesPage />} />
                  <Route path="/admin/diagnostics" element={<DiagnosticsPage />} />
                </Route>
              </Routes>
            </Suspense>
          </BrowserRouter>
          <Toaster />
        </TooltipProvider>
      </QueryClientProvider>
    </ThemeProvider>
  );
}

export default App;
