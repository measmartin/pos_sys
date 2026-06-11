import { useQuery } from '@tanstack/react-query';
import { diagnosticsApi } from '../api';
import type { DiagnosticsResult } from '../api/diagnostics';

const DIAGNOSTICS_KEY = 'diagnostics';

export function useDiagnostics() {
  return useQuery<DiagnosticsResult>({
    queryKey: [DIAGNOSTICS_KEY],
    queryFn: () => diagnosticsApi.getConnection(),
    retry: false,
    refetchOnWindowFocus: false,
  });
}
