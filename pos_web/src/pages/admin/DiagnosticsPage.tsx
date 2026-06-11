import { useDiagnostics } from '@/hooks';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { Badge } from '@/components/ui/badge';
import { RefreshCw, Database, Table, AlertTriangle, CheckCircle, XCircle, Activity } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';

export function DiagnosticsPage() {
  const { data, isLoading, error, refetch } = useDiagnostics();

  return (
    <PageLayout
      icon={Activity}
      title="Diagnostics"
      action={
        <Button variant="outline" onClick={() => refetch()} disabled={isLoading}>
          <RefreshCw className={`size-4 mr-2 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      }
    >
      {error && (
        <Card className="border-destructive">
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-destructive">
              <XCircle className="size-5" />
              Connection Failed
            </CardTitle>
          </CardHeader>
          <CardContent>
            <p className="text-sm text-muted-foreground">
              {(error as Error)?.message ?? 'Unknown error occurred'}
            </p>
          </CardContent>
        </Card>
      )}

      {isLoading && (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
        </div>
      )}

      {data && (
        <>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                {data.ok ? <CheckCircle className="size-5 text-success" /> : <AlertTriangle className="size-5 text-destructive" />}
                Database Status
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex items-center gap-3 mb-4">
                <StatusBadge status={data.ok ? 'active' : 'inactive'} label={data.ok ? 'Healthy' : 'Error'} />
                <span className="text-sm text-muted-foreground">{data.message}</span>
              </div>
              {data.database && (
                <dl className="grid grid-cols-2 gap-4">
                  <div>
                    <dt className="text-sm text-muted-foreground flex items-center gap-1"><Database className="size-3.5" />Database</dt>
                    <dd className="text-sm font-medium">{data.database}</dd>
                  </div>
                  <div>
                    <dt className="text-sm text-muted-foreground">Provider</dt>
                    <dd className="text-sm font-medium">{data.provider ?? '-'}</dd>
                  </div>
                </dl>
              )}
            </CardContent>
          </Card>

          {data.existingTables && (
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2"><Table className="size-4" />Tables ({data.existingTables.length})</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="flex flex-wrap gap-2">
                  {data.existingTables.map((table) => <Badge key={table} variant="outline" className="text-xs">{table}</Badge>)}
                </div>
              </CardContent>
            </Card>
          )}

          {data.missingTables && data.missingTables.length > 0 && (
            <Card className="border-destructive">
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-destructive"><AlertTriangle className="size-4" />Missing Required Tables</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {data.missingTables.map((table) => (
                    <div key={table} className="flex items-center gap-2 text-sm text-destructive">
                      <XCircle className="size-3.5" /><span>{table}</span>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}
        </>
      )}
    </PageLayout>
  );
}

export default DiagnosticsPage;
