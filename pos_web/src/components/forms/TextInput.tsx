import type { InputHTMLAttributes } from 'react';
import { Input } from '@/components/ui/input';

interface TextInputProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

export function TextInput({ label, error, id, ...props }: TextInputProps) {
  const inputId = id ?? label.toLowerCase().replace(/\s+/g, '-');
  return (
    <div className="space-y-1">
      <label htmlFor={inputId} className="text-sm font-medium text-foreground">
        {label}
      </label>
      <Input id={inputId} className={error ? 'border-destructive' : ''} {...props} />
      {error && <p className="text-sm text-destructive">{error}</p>}
    </div>
  );
}
