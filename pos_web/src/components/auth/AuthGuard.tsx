import { Navigate, useLocation } from 'react-router-dom';
import { isAuthenticated } from '@/api';

interface AuthGuardProps {
  children: React.ReactNode;
}

export function AuthGuard({ children }: AuthGuardProps) {
  const location = useLocation();
  const authenticated = isAuthenticated();

  if (!authenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
}
