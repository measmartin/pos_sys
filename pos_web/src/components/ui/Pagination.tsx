import { Button } from '@/components/ui/button';

interface PaginationProps {
  page: number;
  pageSize: number;
  totalCount: number;
  onPageChange: (page: number) => void;
}

export function Pagination({
  page,
  pageSize,
  totalCount,
  onPageChange,
}: PaginationProps) {
  const totalPages = Math.ceil(totalCount / pageSize);

  if (totalPages <= 1) return null;

  return (
    <div className="flex items-center justify-between px-6 py-3 border-t">
      <div className="text-sm text-muted-foreground">
        Showing{' '}
        <span className="font-medium">{Math.min((page - 1) * pageSize + 1, totalCount)}</span>
        {' - '}
        <span className="font-medium">{Math.min(page * pageSize, totalCount)}</span>
        {' of '}
        <span className="font-medium">{totalCount}</span>
      </div>
      <div className="flex gap-2">
        <Button
          variant="outline"
          size="sm"
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
        >
          Previous
        </Button>
        <Button
          variant="outline"
          size="sm"
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages}
        >
          Next
        </Button>
      </div>
    </div>
  );
}
