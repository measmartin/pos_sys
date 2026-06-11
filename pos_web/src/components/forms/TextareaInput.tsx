import type { TextareaHTMLAttributes } from 'react';
import { Textarea } from '@/components/ui/textarea';

interface TextareaInputProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  label: string;
  error?: string;
}

export function TextareaInput({ label, error, id, ...props }: TextareaInputProps) {
  const inputId = id ?? label.toLowerCase().replace(/\s+/g, '-');
  return (
    <div className="space-y-1">
      <label htmlFor={inputId} className="text-sm font-medium text-foreground">
        {label}
      </label>
      <Textarea id={inputId} className={error ? 'border-destructive' : ''} {...props} />
      {error && <p className="text-sm text-destructive">{error}</p>}
    </div>
  );
}
