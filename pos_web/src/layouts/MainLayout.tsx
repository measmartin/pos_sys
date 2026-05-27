import { useState } from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { Separator } from '@/components/ui/separator';
import {
  Sheet,
  SheetContent,
  SheetTrigger,
} from '@/components/ui/sheet';
import {
  LayoutDashboard,
  ShoppingCart,
  Package,
  Users,
  Menu,
  Receipt,
  Tags,
  Ruler,
  DollarSign,
} from 'lucide-react';

const navItems = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/sales', label: 'Sales', icon: ShoppingCart },
  { to: '/products', label: 'Products', icon: Package },
  { to: '/customers', label: 'Customers', icon: Users },
];

const adminItems = [
  { to: '/admin/categories', label: 'Categories', icon: Tags },
  { to: '/admin/units', label: 'Units', icon: Ruler },
  { to: '/admin/currencies', label: 'Currencies', icon: DollarSign },
];

export function MainLayout() {
  const [mobileOpen, setMobileOpen] = useState(false);

  const renderNav = (items: typeof navItems) => (
    <nav className="flex flex-col gap-1 p-3">
      {items.map((item) => (
        <NavLink
          key={item.to}
          to={item.to}
          end={item.to === '/'}
          onClick={() => setMobileOpen(false)}
          className={({ isActive }) =>
            `flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
              isActive
                ? 'bg-accent text-accent-foreground'
                : 'text-muted-foreground hover:bg-accent hover:text-accent-foreground'
            }`
          }
        >
          <item.icon className="size-4" />
          {item.label}
        </NavLink>
      ))}
    </nav>
  );

  return (
    <div className="flex min-h-screen bg-background">
      <aside className="hidden w-60 flex-col border-r bg-sidebar-background lg:flex">
        <div className="flex h-14 items-center gap-2 border-b px-4">
          <Receipt className="size-5 text-sidebar-primary" />
          <span className="text-base font-semibold text-sidebar-foreground">POS System</span>
        </div>
        <div className="flex-1 overflow-y-auto py-2">
          {renderNav(navItems)}
          <Separator className="my-2" />
          <div className="px-4 py-1">
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Administration</p>
          </div>
          {renderNav(adminItems)}
        </div>
      </aside>

      <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
        <SheetTrigger className="lg:hidden fixed top-3 left-3 z-40 inline-flex items-center justify-center rounded-lg size-8 hover:bg-accent">
          <Menu className="size-5" />
        </SheetTrigger>
        <SheetContent side="left" className="w-60 p-0">
          <div className="flex h-14 items-center gap-2 border-b px-4">
            <Receipt className="size-5" />
            <span className="text-base font-semibold">POS System</span>
          </div>
          <div className="overflow-y-auto">
            {renderNav(navItems)}
            <Separator className="my-2" />
            <div className="px-4 py-1">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Administration</p>
            </div>
            {renderNav(adminItems)}
          </div>
        </SheetContent>
      </Sheet>

      <main className="flex flex-1 flex-col">
        <header className="flex h-14 items-center border-b bg-background px-4 lg:px-8">
          <h2 className="text-sm font-semibold text-foreground lg:ml-0 ml-10">Point of Sale</h2>
        </header>
        <Separator />
        <div className="flex-1 p-4 lg:p-8">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
