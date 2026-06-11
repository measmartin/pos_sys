import type { ReactNode } from 'react';
import {
  useReactTable,
  getCoreRowModel,
  getSortedRowModel,
  flexRender,
  type ColumnDef,
  type SortingState,
} from '@tanstack/react-table';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Skeleton } from '@/components/ui/skeleton';
import { useState } from 'react';
import { ArrowUpDown, ArrowUp, ArrowDown } from 'lucide-react';

export interface Column<T> {
  key: string;
  header: string;
  render?: (item: T) => ReactNode;
  className?: string;
  enableSorting?: boolean;
}

interface DataTableProps<T> {
  columns: Column<T>[];
  data: T[];
  keyExtractor: (item: T) => string | number;
  isLoading?: boolean;
  emptyMessage?: string;
}

function buildTanstackColumns<T>(columns: Column<T>[]): ColumnDef<T>[] {
  return columns.map((col) => ({
    id: col.key,
    header: ({ column }) => {
      const isSorted = column.getIsSorted();
      return (
        <div className="flex items-center gap-1 cursor-pointer select-none" onClick={col.enableSorting !== false ? column.getToggleSortingHandler() : undefined}>
          <span>{col.header}</span>
          {col.enableSorting !== false && (
            <span className="text-muted-foreground">
              {isSorted === 'asc' && <ArrowUp className="size-3" />}
              {isSorted === 'desc' && <ArrowDown className="size-3" />}
              {!isSorted && <ArrowUpDown className="size-3" />}
            </span>
          )}
        </div>
      );
    },
    cell: ({ row }) => {
      if (col.render) {
        return col.render(row.original);
      }
      return (row.original as Record<string, unknown>)[col.key] as ReactNode;
    },
    enableSorting: col.enableSorting !== false,
  }));
}

export function DataTable<T>({
  columns,
  data,
  keyExtractor,
  isLoading,
  emptyMessage = 'No data found',
}: DataTableProps<T>) {
  const [sorting, setSorting] = useState<SortingState>([]);

  const tanstackColumns = buildTanstackColumns(columns);

  const table = useReactTable({
    data,
    columns: tanstackColumns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getRowId: (row) => String(keyExtractor(row)),
    onSortingChange: setSorting,
    state: {
      sorting,
    },
  });

  if (isLoading) {
    return (
      <div className="space-y-3 p-4">
        {Array.from({ length: 5 }).map((_, i) => (
          <div key={i} className="flex gap-4">
            {columns.map((col) => (
              <Skeleton key={col.key} className="h-6 flex-1" />
            ))}
          </div>
        ))}
      </div>
    );
  }

  if (data.length === 0) {
    return (
      <div className="text-center py-8 text-muted-foreground">{emptyMessage}</div>
    );
  }

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader className="bg-muted/50">
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <TableHead key={header.id} className={columns.find(c => c.key === header.column.id)?.className}>
                  {header.isPlaceholder
                    ? null
                    : flexRender(header.column.columnDef.header, header.getContext())}
                </TableHead>
              ))}
            </TableRow>
          ))}
        </TableHeader>
        <TableBody>
          {table.getRowModel().rows.map((row) => (
            <TableRow key={row.id} className="even:bg-muted/20">
              {row.getVisibleCells().map((cell) => (
                <TableCell key={cell.id} className={columns.find(c => c.key === cell.column.id)?.className}>
                  {flexRender(cell.column.columnDef.cell, cell.getContext())}
                </TableCell>
              ))}
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );
}
