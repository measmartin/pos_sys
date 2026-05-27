import { Badge } from '@/components/ui/badge';

const statusVariants: Record<string, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  COMPLETED: 'default',
  DRAFT: 'secondary',
  VOID: 'destructive',
  REFUNDED: 'outline',
  RETURNED: 'default',
  PAID: 'default',
  UNPAID: 'destructive',
  PARTIAL: 'secondary',
  active: 'default',
  inactive: 'secondary',
};

export function StatusBadge({ status, label }: { status: string; label?: string }) {
  const variant = statusVariants[status] ?? 'secondary';
  return <Badge variant={variant}>{label ?? status}</Badge>;
}
