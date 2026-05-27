export function formatCurrency(value: number, symbol?: string | null): string {
  const formatted = value.toLocaleString(undefined, {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
  return symbol ? `${symbol} ${formatted}` : formatted;
}

export function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

export function formatDateTime(dateStr: string): string {
  return new Date(dateStr).toLocaleString(undefined, {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function formatSaleStatus(status: string): string {
  const labels: Record<string, string> = {
    DRAFT: 'Draft',
    COMPLETED: 'Completed',
    VOID: 'Void',
    REFUNDED: 'Refunded',
    RETURNED: 'Returned',
  };
  return labels[status] ?? status;
}

export function formatPaymentStatus(status: string): string {
  const labels: Record<string, string> = {
    PAID: 'Paid',
    UNPAID: 'Unpaid',
    PARTIAL: 'Partial',
  };
  return labels[status] ?? status;
}
