const statusColors: Record<string, string> = {
  COMPLETED: 'bg-green-100 text-green-800',
  DRAFT: 'bg-yellow-100 text-yellow-800',
  VOID: 'bg-red-100 text-red-800',
  REFUNDED: 'bg-orange-100 text-orange-800',
  RETURNED: 'bg-purple-100 text-purple-800',
  PAID: 'bg-green-100 text-green-800',
  UNPAID: 'bg-red-100 text-red-800',
  PARTIAL: 'bg-yellow-100 text-yellow-800',
  active: 'bg-green-100 text-green-800',
  inactive: 'bg-gray-100 text-gray-800',
};

export function StatusBadge({
  status,
  label,
}: {
  status: string;
  label?: string;
}) {
  const color = statusColors[status] ?? 'bg-gray-100 text-gray-800';
  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${color}`}>
      {label ?? status}
    </span>
  );
}
