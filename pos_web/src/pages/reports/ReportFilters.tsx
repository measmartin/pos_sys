import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { useReportCurrencies } from '../../hooks/useReports';
import { FileSpreadsheet, FileText, Calendar } from 'lucide-react';

const DATE_PRESETS = [
  { label: 'Today', value: 'today' },
  { label: 'Yesterday', value: 'yesterday' },
  { label: 'This Week', value: 'this-week' },
  { label: 'Last Week', value: 'last-week' },
  { label: 'This Month', value: 'this-month' },
  { label: 'Last Month', value: 'last-month' },
  { label: 'Last 30 Days', value: 'last-30' },
  { label: 'This Year', value: 'this-year' },
  { label: 'Custom', value: 'custom' },
];

function getDateRange(preset: string): { startDate: string; endDate: string } {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  let startDate: Date;
  let endDate: Date = new Date(today);

  switch (preset) {
    case 'today':
      startDate = today;
      break;
    case 'yesterday':
      startDate = new Date(today);
      startDate.setDate(startDate.getDate() - 1);
      endDate = new Date(startDate);
      endDate.setHours(23, 59, 59, 999);
      break;
    case 'this-week': {
      const day = today.getDay();
      startDate = new Date(today);
      startDate.setDate(today.getDate() - (day === 0 ? 6 : day - 1));
      break;
    }
    case 'last-week': {
      const day2 = today.getDay();
      startDate = new Date(today);
      startDate.setDate(today.getDate() - (day2 === 0 ? 6 : day2 - 1) - 7);
      endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 6);
      endDate.setHours(23, 59, 59, 999);
      break;
    }
    case 'this-month':
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
      break;
    case 'last-month':
      startDate = new Date(now.getFullYear(), now.getMonth() - 1, 1);
      endDate = new Date(now.getFullYear(), now.getMonth(), 0);
      break;
    case 'last-30':
      startDate = new Date(today);
      startDate.setDate(today.getDate() - 30);
      break;
    case 'this-year':
      startDate = new Date(now.getFullYear(), 0, 1);
      break;
    default:
      startDate = new Date(today);
      startDate.setDate(today.getDate() - 30);
  }

  return {
    startDate: startDate.toISOString().split('T')[0],
    endDate: endDate.toISOString().split('T')[0],
  };
}

interface DateRangeFilterProps {
  startDate: string;
  endDate: string;
  currencyId: string;
  onDateChange: (start: string, end: string) => void;
  onCurrencyChange: (currencyId: string) => void;
}

export function DateRangeFilter({ startDate, endDate, currencyId, onDateChange, onCurrencyChange }: DateRangeFilterProps) {
  const [preset, setPreset] = useState('last-30');
  const { data: currencies } = useReportCurrencies();

  const handlePresetChange = (value: string) => {
    setPreset(value);
    if (value !== 'custom') {
      const range = getDateRange(value);
      onDateChange(range.startDate, range.endDate);
    }
  };

  return (
    <Card>
      <CardHeader className="pb-3">
        <CardTitle className="text-base flex items-center gap-2">
          <Calendar className="size-4" />
          Report Filters
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="flex items-end gap-3 flex-wrap">
          <div className="space-y-1">
            <label className="text-sm font-medium">Quick Range</label>
            <Select
              value={preset}
              onValueChange={(v) => handlePresetChange(v ?? 'last-30')}
              items={DATE_PRESETS.map((p) => ({ value: p.value, label: p.label }))}
            >
              <SelectTrigger className="w-40">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                {DATE_PRESETS.map((p) => (
                  <SelectItem key={p.value} value={p.value}>{p.label}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="space-y-1">
            <label className="text-sm font-medium">Start Date</label>
            <input
              type="date"
              value={startDate}
              onChange={(e) => {
                setPreset('custom');
                onDateChange(e.target.value, endDate);
              }}
              className="flex h-10 w-40 rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
            />
          </div>
          <div className="space-y-1">
            <label className="text-sm font-medium">End Date</label>
            <input
              type="date"
              value={endDate}
              onChange={(e) => {
                setPreset('custom');
                onDateChange(startDate, e.target.value);
              }}
              className="flex h-10 w-40 rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
            />
          </div>
          <div className="space-y-1">
            <label className="text-sm font-medium">Currency</label>
            <Select
              value={currencyId}
              onValueChange={(v) => onCurrencyChange(v ?? 'all')}
              items={[
                { value: 'all', label: 'All Currencies' },
                ...(currencies?.map((c: { currencyId: number; currencyCode: string; currencySymbol: string }) => ({
                  value: String(c.currencyId),
                  label: `${c.currencyCode} (${c.currencySymbol})`,
                })) ?? []),
              ]}
            >
              <SelectTrigger className="w-40">
                <SelectValue placeholder="All currencies" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Currencies</SelectItem>
                {currencies?.map((c: { currencyId: number; currencyCode: string; currencySymbol: string }) => (
                  <SelectItem key={c.currencyId} value={String(c.currencyId)}>
                    {c.currencyCode} ({c.currencySymbol})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}

interface ExportButtonsProps {
  onExportExcel: () => void;
  onExportPdf: () => void;
}

export function ExportButtons({ onExportExcel, onExportPdf }: ExportButtonsProps) {
  return (
    <div className="flex gap-2">
      <Button variant="outline" size="sm" onClick={onExportExcel}>
        <FileSpreadsheet className="size-4 mr-1" />
        Excel
      </Button>
      <Button variant="outline" size="sm" onClick={onExportPdf}>
        <FileText className="size-4 mr-1" />
        PDF
      </Button>
    </div>
  );
}

export { DATE_PRESETS, getDateRange };
