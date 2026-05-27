import axios, { AxiosError, type InternalAxiosRequestConfig } from 'axios';
import type { ApiError } from '@PosApi/types';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'https://localhost:7070';
const API_KEY = import.meta.env.VITE_API_KEY ?? 'dev-api-key-12345';

const apiClient = axios.create({
  baseURL: `${API_BASE_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
});

apiClient.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  config.headers.set('X-API-Key', API_KEY);
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiError>) => {
    const apiError = error.response?.data;
    if (apiError) {
      console.error(`API Error [${apiError.statusCode}]: ${apiError.error}`);
    }
    return Promise.reject(apiError ?? error);
  },
);

export default apiClient;
