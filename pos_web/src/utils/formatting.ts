export function roundForCurrency(amount: number, currencyCode?: string | null): number {
  if (currencyCode === 'KHR') {
    return Math.round(amount / 100) * 100;
  }
  return Math.round(amount * 100) / 100;
}

export function formatCurrency(value: number, symbol?: string | null, currencyCode?: string | null): string {
  const isKHR = currencyCode === 'KHR';
  const rounded = isKHR ? Math.round(value / 100) * 100 : value;
  const formatted = rounded.toLocaleString(undefined, {
    minimumFractionDigits: isKHR ? 0 : 2,
    maximumFractionDigits: isKHR ? 0 : 2,
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
