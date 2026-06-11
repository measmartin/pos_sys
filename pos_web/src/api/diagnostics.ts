import apiClient from './client';

export interface DiagnosticsResult {
  ok: boolean;
  message: string;
  database?: string;
  provider?: string;
  tables?: string[];
  missingTables?: string[];
  existingTables?: string[];
  exception?: string;
}

export const diagnosticsApi = {
  getConnection: async (): Promise<DiagnosticsResult> => {
    const { data } = await apiClient.get<DiagnosticsResult>('/diagnostics/connection');
    return data;
  },
};
