import type { ReactNode } from 'react';
import type { LucideIcon } from 'lucide-react';

interface PageLayoutProps {
  icon: LucideIcon;
  title: string;
  subtitle?: string;
  action?: ReactNode;
  children: ReactNode;
}

export function PageLayout({ icon: Icon, title, subtitle, action, children }: PageLayoutProps) {
  return (
    <div className="min-h-full rounded-xl bg-muted/40 p-6">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <div className="flex size-9 items-center justify-center rounded-lg bg-primary/10">
            <Icon className="size-5 text-primary" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-tight">{title}</h1>
            {subtitle && (
              <p className="text-sm text-muted-foreground">{subtitle}</p>
            )}
          </div>
        </div>
        {action}
      </div>
      {children}
    </div>
  );
}
