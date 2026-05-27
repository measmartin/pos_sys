import { useState } from 'react';
import { useProductsList } from '../../hooks';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { formatCurrency } from '../../utils/formatting';
import { Search, ImageIcon } from 'lucide-react';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5010';

interface ProductSelectorProps {
  isOpen: boolean;
  onClose: () => void;
  onSelect: (productId: number, productUnitId: number, unitPrice: number) => void;
}

export function ProductSelector({ isOpen, onClose, onSelect }: ProductSelectorProps) {
  const [search, setSearch] = useState('');
  const { data, isLoading } = useProductsList({ search, pageSize: 50 });

  const products = data?.data ?? [];

  return (
    <Dialog open={isOpen} onOpenChange={(open) => { if (!open) onClose(); }}>
      <DialogContent className="sm:max-w-2xl max-h-[80vh] overflow-y-auto" showCloseButton>
        <DialogHeader>
          <DialogTitle>Select Product</DialogTitle>
        </DialogHeader>
        <div className="relative mb-4">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-muted-foreground" />
          <Input
            className="pl-9"
            placeholder="Search products..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            autoFocus
          />
        </div>
        {isLoading ? (
          <div className="flex justify-center py-8">
            <div className="animate-spin rounded-full size-6 border-b-2 border-primary" />
          </div>
        ) : products.length === 0 ? (
          <p className="text-center text-sm text-muted-foreground py-8">No products found</p>
        ) : (
          <div className="grid gap-3 sm:grid-cols-2">
            {products.map((product) => {
              const defaultUnit = product.units?.find((u) => u.isDefault) ?? product.units?.[0];
              return (
                <div key={product.productId} className="rounded-lg border p-3 space-y-2">
                  <div className="flex items-start gap-3">
                    <div className="size-12 shrink-0 rounded-md border overflow-hidden bg-muted flex items-center justify-center">
                      {defaultUnit?.imageUrl ? (
                        <img
                          src={`${API_BASE_URL}/api/productunits/${defaultUnit.productUnitId}/image`}
                          alt={product.productName}
                          className="size-full object-cover"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                        />
                      ) : (
                        <ImageIcon className="size-5 text-muted-foreground" />
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">{product.productName}</p>
                      <p className="text-xs text-muted-foreground">{product.productCode}</p>
                      {product.categoryName && (
                        <p className="text-xs text-muted-foreground">{product.categoryName}</p>
                      )}
                    </div>
                  </div>
                  {product.units && product.units.length > 0 ? (
                    <div className="space-y-1.5 pt-1">
                      {product.units.map((unit) => (
                        <Button
                          key={unit.productUnitId}
                          variant="outline"
                          size="sm"
                          className="w-full justify-between text-xs h-auto py-1.5"
                          onClick={() => onSelect(product.productId, unit.productUnitId, unit.price)}
                        >
                          <span>{unit.unitName}</span>
                          <span className="font-medium">{formatCurrency(unit.price, unit.currencySymbol)}</span>
                        </Button>
                      ))}
                    </div>
                  ) : (
                    <p className="text-xs text-muted-foreground">No units configured</p>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
