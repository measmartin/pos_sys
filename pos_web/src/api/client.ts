import axios, { AxiosError, type InternalAxiosRequestConfig } from 'axios';
import type { ApiError, AuthResponseDto } from '@PosApi/types';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5010';

const apiClient = axios.create({
  baseURL: `${API_BASE_URL}/api`,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
});

// --- Auth helpers ---
const TOKEN_KEY = 'pos_auth_token';
const REFRESH_TOKEN_KEY = 'pos_refresh_token';

export function getAuthToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setAuthToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token);
}

export function getRefreshToken(): string | null {
  return localStorage.getItem(REFRESH_TOKEN_KEY);
}

export function setRefreshToken(token: string): void {
  localStorage.setItem(REFRESH_TOKEN_KEY, token);
}

export function clearAuthToken(): void {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(REFRESH_TOKEN_KEY);
}

export function isAuthenticated(): boolean {
  return !!getAuthToken();
}

apiClient.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const token = getAuthToken();
  if (token) {
    config.headers.set('Authorization', `Bearer ${token}`);
  }
  return config;
});

apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError<ApiError>) => {
    const apiError = error.response?.data;
    const status = error.response?.status;
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };

    if (apiError) {
      console.error(`API Error [${apiError.statusCode}]: ${apiError.message}`);
    }

    // Try to refresh token on 401
    if (status === 401 && originalRequest && !originalRequest._retry) {
      originalRequest._retry = true;
      const refreshToken = getRefreshToken();

      if (refreshToken) {
        try {
          const { data } = await apiClient.post<AuthResponseDto>('/auth/refresh', { refreshToken });
          setAuthToken(data.token);
          setRefreshToken(data.refreshToken);
          if (originalRequest.headers) {
            originalRequest.headers.set('Authorization', `Bearer ${data.token}`);
          }
          return apiClient(originalRequest);
        } catch (refreshError) {
          clearAuthToken();
          window.location.href = '/login';
        }
      } else {
        clearAuthToken();
        window.location.href = '/login';
      }
    }

    return Promise.reject(apiError ?? error);
  },
);

export default apiClient;
