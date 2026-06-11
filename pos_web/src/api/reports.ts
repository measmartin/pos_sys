import apiClient from './client';
import type {
  ReportQueryParams,
  SalesSummaryDto,
  DailySalesDto,
  MonthlySalesDto,
  HourlySalesDto,
  TopProductDto,
  CategorySalesDto,
  TopCustomerDto,
  PaymentBreakdownDto,
  SalesDetailsExportDto,
  CurrencyInfoDto,
} from '@PosApi/types';

export const reportsApi = {
  getSalesSummary: async (params: ReportQueryParams) => {
    const { data } = await apiClient.get<SalesSummaryDto>('/reports/sales/summary', { params });
    return data;
  },

  getDailySales: async (params: ReportQueryParams) => {
    const { data } = await apiClient.get<DailySalesDto[]>('/reports/sales/daily', { params });
    return data;
  },

  getMonthlySales: async (params: ReportQueryParams) => {
    const { data } = await apiClient.get<MonthlySalesDto[]>('/reports/sales/monthly', { params });
    return data;
  },

  getHourlySales: async (params: ReportQueryParams) => {
    const { data } = await apiClient.get<HourlySalesDto[]>('/reports/sales/hourly', { params });
    return data;
  },

  getTopProducts: async (params: ReportQueryParams, topN = 20) => {
    const { data } = await apiClient.get<TopProductDto[]>('/reports/products/top', {
      params: { ...params, topN },
    });
    return data;
  },

  getCategorySales: async (params: ReportQueryParams) => {
    const { data } = await apiClient.get<CategorySalesDto[]>('/reports/products/category', { params });
    return data;
  },

  getTopCustomers: async (params: ReportQueryParams, topN = 20) => {
    const { data } = await apiClient.get<TopCustomerDto[]>('/reports/customers/top', {
      params: { ...params, topN },
    });
    return data;
  },

  getPaymentBreakdown: async (params: ReportQueryParams) => {
    const { data } = await apiClient.get<PaymentBreakdownDto[]>('/reports/payments/breakdown', { params });
    return data;
  },

  getSalesForExport: async (params: ReportQueryParams) => {
    const { data } = await apiClient.get<SalesDetailsExportDto[]>('/reports/sales/export', { params });
    return data;
  },

  getCurrencies: async () => {
    const { data } = await apiClient.get<CurrencyInfoDto[]>('/reports/currencies');
    return data;
  },
};
