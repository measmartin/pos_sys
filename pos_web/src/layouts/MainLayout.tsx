import { useState } from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { Separator } from '@/components/ui/separator';
import { Button } from '@/components/ui/button';
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
  Activity,
  BarChart3,
  LogOut,
} from 'lucide-react';
import { authApi } from '@/api';
import { ModeToggle } from '@/components/ui/mode-toggle';

const navItems = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard },
  { to: '/sales', label: 'Sales', icon: ShoppingCart },
  { to: '/reports', label: 'Reports', icon: BarChart3 },
  { to: '/products', label: 'Products', icon: Package },
  { to: '/customers', label: 'Customers', icon: Users },
];

const adminItems = [
  { to: '/admin/categories', label: 'Categories', icon: Tags },
  { to: '/admin/units', label: 'Units', icon: Ruler },
  { to: '/admin/currencies', label: 'Currencies', icon: DollarSign },
  { to: '/admin/diagnostics', label: 'Diagnostics', icon: Activity },
];

export function MainLayout() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const navigate = useNavigate();

  const handleLogout = () => {
    authApi.logout();
    navigate('/login');
  };

  const renderNav = (items: typeof navItems) => (
    <nav className="flex flex-col gap-0.5 p-2">
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
                : 'text-muted-foreground hover:bg-accent/50 hover:text-foreground'
            }`
          }
        >
          <item.icon className="size-4 shrink-0" />
          {item.label}
        </NavLink>
      ))}
    </nav>
  );

  return (
    <div className="flex min-h-screen bg-background">
      <aside className="hidden w-60 flex-col border-r bg-sidebar-background fixed top-0 left-0 h-screen z-30 lg:flex">
        <div className="flex h-14 items-center justify-between border-b px-4">
          <div className="flex items-center gap-2">
            <Receipt className="size-5 text-sidebar-primary" />
            <span className="text-base font-semibold text-sidebar-foreground">POS System</span>
          </div>
          <ModeToggle />
        </div>
        <div className="flex-1 overflow-y-auto py-2">
          {renderNav(navItems)}
          <Separator className="my-2" />
          <div className="px-4 py-1">
            <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Administration</p>
          </div>
          {renderNav(adminItems)}
        </div>
        <div className="p-3 border-t">
          <Button variant="ghost" size="sm" onClick={handleLogout} className="w-full justify-start gap-2">
            <LogOut className="size-4" />
            Logout
          </Button>
        </div>
      </aside>

      <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
        <SheetTrigger className="lg:hidden fixed top-3 left-3 z-40 inline-flex items-center justify-center rounded-lg size-8 hover:bg-accent">
          <Menu className="size-5" />
        </SheetTrigger>
        <SheetContent side="left" className="w-60 p-0">
          <div className="flex h-14 items-center justify-between border-b px-4">
            <div className="flex items-center gap-2">
              <Receipt className="size-5" />
              <span className="text-base font-semibold">POS System</span>
            </div>
            <ModeToggle />
          </div>
          <div className="overflow-y-auto">
            {renderNav(navItems)}
            <Separator className="my-2" />
            <div className="px-4 py-1">
              <p className="text-xs font-medium text-muted-foreground uppercase tracking-wider">Administration</p>
            </div>
            {renderNav(adminItems)}
          </div>
          <div className="p-3 border-t">
            <Button variant="ghost" size="sm" onClick={handleLogout} className="w-full justify-start gap-2">
              <LogOut className="size-4" />
              Logout
            </Button>
          </div>
        </SheetContent>
      </Sheet>

      <main className="flex flex-1 flex-col lg:ml-60">
        <div className="flex-1 p-4 lg:p-8">
          <Outlet />
        </div>
      </main>
    </div>
  );
}
