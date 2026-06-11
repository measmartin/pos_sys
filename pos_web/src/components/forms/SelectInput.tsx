import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

interface SelectOption {
  value: string | number;
  label: string;
}

interface SelectInputProps {
  label: string;
  value: string | number;
  onChange: (value: string | null) => void;
  options: SelectOption[];
  error?: string;
  placeholder?: string;
  required?: boolean;
}

export function SelectInput({
  label,
  value,
  onChange,
  options,
  error,
  placeholder = 'Select...',
  required,
}: SelectInputProps) {
  return (
    <div className="space-y-1">
      <label className="text-sm font-medium text-foreground">
        {label}{required && <span className="text-destructive ml-0.5">*</span>}
      </label>
      <Select
        value={String(value)}
        onValueChange={onChange}
        items={options.map((opt) => ({ value: String(opt.value), label: opt.label }))}
      >
        <SelectTrigger className={error ? 'border-destructive' : ''}>
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent>
          {options.map((opt) => (
            <SelectItem key={opt.value} value={String(opt.value)}>
              {opt.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      {error && <p className="text-sm text-destructive">{error}</p>}
    </div>
  );
}
