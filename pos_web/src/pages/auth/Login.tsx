import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { authApi } from '@/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';
import { Receipt } from 'lucide-react';

export function Login() {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [isRegister, setIsRegister] = useState(false);
  const [formData, setFormData] = useState({
    username: '',
    password: '',
    displayName: '',
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);

    try {
      if (isRegister) {
        await authApi.register({
          username: formData.username,
          password: formData.password,
          displayName: formData.displayName || undefined,
        });
        toast.success('Account created successfully!');
      } else {
        await authApi.login({
          username: formData.username,
          password: formData.password,
        });
        toast.success('Logged in successfully!');
      }
      navigate('/');
    } catch (error: any) {
      toast.error(error?.message || 'Authentication failed');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <div className="w-full max-w-sm p-4">
        <div className="flex justify-center mb-8">
          <div className="flex items-center gap-2">
            <Receipt className="size-8 text-primary" />
            <span className="text-2xl font-bold">POS System</span>
          </div>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>{isRegister ? 'Create Account' : 'Sign In'}</CardTitle>
            <CardDescription>
              {isRegister
                ? 'Enter your details to create an account'
                : 'Enter your credentials to access the system'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="username">Username</Label>
                <Input
                  id="username"
                  value={formData.username}
                  onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                  placeholder="Enter username"
                  required
                />
              </div>

              {isRegister && (
                <div className="space-y-2">
                  <Label htmlFor="displayName">Display Name</Label>
                  <Input
                    id="displayName"
                    value={formData.displayName}
                    onChange={(e) => setFormData({ ...formData, displayName: e.target.value })}
                    placeholder="Enter display name"
                  />
                </div>
              )}

              <div className="space-y-2">
                <Label htmlFor="password">Password</Label>
                <Input
                  id="password"
                  type="password"
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  placeholder="Enter password"
                  required
                />
              </div>

              <Button type="submit" className="w-full" disabled={isLoading}>
                {isLoading ? 'Loading...' : isRegister ? 'Create Account' : 'Sign In'}
              </Button>
            </form>

            <div className="mt-4 text-center">
              <button
                type="button"
                onClick={() => setIsRegister(!isRegister)}
                className="text-sm text-muted-foreground hover:text-primary"
              >
                {isRegister ? 'Already have an account? Sign in' : "Don't have an account? Register"}
              </button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

export default Login;
