import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Toaster } from '@/components/ui/sonner';
import { TooltipProvider } from '@/components/ui/tooltip';
import { MainLayout } from './layouts/MainLayout';
import {
  Dashboard,
  SalesList,
  SaleDetail,
  CreateSale,
  Products,
  ProductDetail,
  ProductForm,
  Customers,
  CategoriesPage,
  UnitsPage,
  CurrenciesPage,
} from './pages';

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
    <QueryClientProvider client={queryClient}>
      <TooltipProvider>
        <BrowserRouter>
          <Routes>
            <Route element={<MainLayout />}>
              <Route path="/" element={<Dashboard />} />
              <Route path="/sales" element={<SalesList />} />
              <Route path="/sales/new" element={<CreateSale />} />
              <Route path="/sales/:id" element={<SaleDetail />} />
              <Route path="/products" element={<Products />} />
              <Route path="/products/new" element={<ProductForm />} />
              <Route path="/products/:id" element={<ProductDetail />} />
              <Route path="/products/:id/edit" element={<ProductForm />} />
              <Route path="/customers" element={<Customers />} />
              <Route path="/admin/categories" element={<CategoriesPage />} />
              <Route path="/admin/units" element={<UnitsPage />} />
              <Route path="/admin/currencies" element={<CurrenciesPage />} />
            </Route>
          </Routes>
        </BrowserRouter>
        <Toaster />
      </TooltipProvider>
    </QueryClientProvider>
  );
}

export default App;
