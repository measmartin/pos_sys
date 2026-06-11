import { useState, useEffect, useRef, startTransition } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSalesList, useDeleteSale, useSalesByDateRange, useSaleByNumber } from '@/hooks';
import { Button } from '@/components/ui/button';
import { DataTable, type Column } from '@/components/ui/DataTable';
import { Pagination } from '@/components/ui/Pagination';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { formatCurrency, formatDate } from '@/utils/formatting';
import type { SalesDetailsDto } from '@PosApi/types';
import { Plus, Eye, Trash2, Calendar, Search, Loader2 } from 'lucide-react';
import { toast } from 'sonner';

const columns: Column<SalesDetailsDto>[] = [
  { key: 'saleNumber', header: 'Sale #' },
  {
    key: 'saleDate',
    header: 'Date',
    render: (s) => formatDate(s.saleDate),
  },
  {
    key: 'customerName',
    header: 'Customer',
    render: (s) => s.customerName ?? 'Walk-in',
  },
  {
    key: 'totalAmount',
    header: 'Total',
    render: (s) => formatCurrency(s.totalAmount, s.currencySymbol),
  },
  {
    key: 'paymentStatus',
    header: 'Payment',
    render: (s) => <StatusBadge status={s.paymentStatus} label={s.paymentStatus} />,
  },
  {
    key: 'saleStatus',
    header: 'Status',
    render: (s) => <StatusBadge status={s.saleStatus} label={s.saleStatus} />,
  },
];

export function SalesList() {
  const navigate = useNavigate();
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [saleNumberSearch, setSaleNumberSearch] = useState('');
  const [searchQuery, setSearchQuery] = useState('');
  const { data, isLoading } = useSalesList({ page, pageSize: 20 });
  const { data: dateRangeSales } = useSalesByDateRange(startDate, endDate);
  const { data: foundSale, isLoading: isSaleLookupLoading } = useSaleByNumber(searchQuery);
  const deleteMutation = useDeleteSale();
  const notifiedRef = useRef<string | null>(null);

  useEffect(() => {
    if (!searchQuery) return;
    if (foundSale) {
      startTransition(() => {
        setSaleNumberSearch('');
      });
      navigate(`/sales/${foundSale.saleId}`);
      return;
    }
    if (!isSaleLookupLoading && !foundSale && notifiedRef.current !== searchQuery) {
      notifiedRef.current = searchQuery;
      startTransition(() => {
        toast.error(`Sale "${searchQuery}" not found`);
      });
    }
  }, [foundSale, isSaleLookupLoading, navigate, searchQuery]);

  const handleSearchSaleNumber = () => {
    if (!saleNumberSearch.trim()) {
      toast.error('Please enter a sale number');
      return;
    }
    setSearchQuery(saleNumberSearch.trim());
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSearchSaleNumber();
    }
  };

  const handleDelete = async () => {
    if (deleteId == null) return;
    await deleteMutation.mutateAsync(deleteId);
    setDeleteId(null);
  };

  const handleClearDateRange = () => {
    setStartDate('');
    setEndDate('');
  };

  const actionColumn: Column<SalesDetailsDto> = {
    key: 'actions',
    header: 'Actions',
    render: (s) => (
      <div className="flex gap-2">
        <Button variant="ghost" size="sm" onClick={() => navigate(`/sales/${s.saleId}`)}>
          <Eye className="size-3.5" />
          View
        </Button>
        <Button
          variant="ghost"
          size="sm"
          onClick={() => setDeleteId(s.saleId)}
          className="text-destructive hover:text-destructive"
        >
          <Trash2 className="size-3.5" />
          Delete
        </Button>
      </div>
    ),
  };

  const dateRangeTotal = dateRangeSales?.reduce((sum, s) => sum + s.totalAmount, 0) ?? 0;
  const dateRangeCount = dateRangeSales?.length ?? 0;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-4">
        <h1 className="text-2xl font-bold tracking-tight">Sales</h1>
        <div className="flex items-center gap-2">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
            <Input
              className="pl-9 w-52"
              placeholder="Search sale #"
              value={saleNumberSearch}
              onChange={(e) => setSaleNumberSearch(e.target.value)}
              onKeyDown={handleKeyDown}
            />
          </div>
          <Button variant="outline" size="sm" onClick={handleSearchSaleNumber} disabled={isSaleLookupLoading}>
            {isSaleLookupLoading ? <Loader2 className="size-4 animate-spin" /> : 'Lookup'}
          </Button>
          <Button onClick={() => navigate('/sales/new')}>
            <Plus className="size-4" />
            New Sale
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-base flex items-center gap-2">
            <Calendar className="size-4" />
            Filter by Date Range
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex items-end gap-3 flex-wrap">
            <div className="space-y-1">
              <label className="text-sm font-medium">Start Date</label>
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="flex h-10 w-44 rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              />
            </div>
            <div className="space-y-1">
              <label className="text-sm font-medium">End Date</label>
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="flex h-10 w-44 rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              />
            </div>
            {startDate && endDate && (
              <>
                <div className="flex gap-4 ml-2">
                  <div>
                    <p className="text-xs text-muted-foreground">Sales Count</p>
                    <p className="text-lg font-bold">{dateRangeCount}</p>
                  </div>
                  <div>
                    <p className="text-xs text-muted-foreground">Total Revenue</p>
                    <p className="text-lg font-bold">{formatCurrency(dateRangeTotal)}</p>
                  </div>
                </div>
                <Button variant="ghost" size="sm" onClick={handleClearDateRange}>
                  Clear
                </Button>
              </>
            )}
          </div>
        </CardContent>
      </Card>

      <Card className="overflow-hidden">
        <DataTable
          columns={[...columns, actionColumn]}
          data={data?.data ?? []}
          keyExtractor={(s) => s.saleId}
          isLoading={isLoading}
          emptyMessage="No sales found"
        />
        {data && (
          <Pagination
            page={data.page}
            pageSize={data.pageSize}
            totalCount={data.totalCount}
            onPageChange={setPage}
          />
        )}
      </Card>

      <ConfirmDialog
        isOpen={deleteId != null}
        onClose={() => setDeleteId(null)}
        onConfirm={handleDelete}
        title="Delete Sale"
        message="Are you sure you want to delete this sale? This action cannot be undone."
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}

export default SalesList;
