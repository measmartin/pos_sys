import apiClient from './client';
import type { AuthResponseDto, LoginDto, RegisterDto } from '@PosApi/types';
import { setAuthToken, setRefreshToken, clearAuthToken } from './client';

export const authApi = {
  login: async (dto: LoginDto) => {
    const { data } = await apiClient.post<AuthResponseDto>('/auth/login', dto);
    if (data.token) {
      setAuthToken(data.token);
      setRefreshToken(data.refreshToken);
    }
    return data;
  },

  register: async (dto: RegisterDto) => {
    const { data } = await apiClient.post<AuthResponseDto>('/auth/register', dto);
    if (data.token) {
      setAuthToken(data.token);
      setRefreshToken(data.refreshToken);
    }
    return data;
  },

  logout: () => {
    clearAuthToken();
  },

  getToken: () => {
    return localStorage.getItem('pos_auth_token');
  },
};
