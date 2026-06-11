import { useQuery } from '@tanstack/react-query';
import { reportsApi } from '../api';
import type { ReportQueryParams } from '@PosApi/types';

const REPORTS_KEY = 'reports';

export function useSalesSummary(params: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'sales-summary', params],
    queryFn: () => reportsApi.getSalesSummary(params),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useDailySales(params: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'daily-sales', params],
    queryFn: () => reportsApi.getDailySales(params),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useMonthlySales(params: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'monthly-sales', params],
    queryFn: () => reportsApi.getMonthlySales(params),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useHourlySales(params: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'hourly-sales', params],
    queryFn: () => reportsApi.getHourlySales(params),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useTopProducts(params: ReportQueryParams, topN = 20) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'top-products', params, topN],
    queryFn: () => reportsApi.getTopProducts(params, topN),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useCategorySales(params: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'category-sales', params],
    queryFn: () => reportsApi.getCategorySales(params),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useTopCustomers(params: ReportQueryParams, topN = 20) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'top-customers', params, topN],
    queryFn: () => reportsApi.getTopCustomers(params, topN),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function usePaymentBreakdown(params: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'payment-breakdown', params],
    queryFn: () => reportsApi.getPaymentBreakdown(params),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useSalesForExport(params: ReportQueryParams) {
  return useQuery({
    queryKey: [REPORTS_KEY, 'sales-export', params],
    queryFn: () => reportsApi.getSalesForExport(params),
    enabled: !!params.startDate && !!params.endDate,
  });
}

export function useReportCurrencies() {
  return useQuery({
    queryKey: [REPORTS_KEY, 'currencies'],
    queryFn: () => reportsApi.getCurrencies(),
  });
}
