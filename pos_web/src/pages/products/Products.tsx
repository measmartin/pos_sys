import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useProductsList } from '@/hooks';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { Card, CardContent } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import type { ProductDetailsDto } from '@PosApi/types';
import { Plus, Package, ArrowRight } from 'lucide-react';
import { formatCurrency } from '@/utils/formatting';
import { PageLayout } from '@/components/layout/PageLayout';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5010';

function getUnitImageUrl(productUnitId: number): string {
  return `${API_BASE_URL}/api/productunits/${productUnitId}/image`;
}

function ProductImage({ src, alt }: { src: string; alt: string }) {
  const [failed, setFailed] = useState(false);

  if (failed) {
    return (
      <div className="flex size-full items-center justify-center">
        <Package className="size-10 text-muted-foreground/50" />
      </div>
    );
  }

  return (
    <img
      src={src}
      alt={alt}
      className="size-full object-cover transition-transform group-hover:scale-105"
      onError={() => setFailed(true)}
    />
  );
}

function ProductCard({ product, onDetails }: {
  product: ProductDetailsDto;
  onDetails: (id: number) => void;
}) {
  const defaultUnit = product.units?.find((u) => u.isDefault) ?? product.units?.[0];

  return (
    <Card className="overflow-hidden group flex flex-col h-full py-(-4)">
      <div className="relative aspect-[4/3] bg-muted overflow-hidden">
        {defaultUnit?.imageUrl ? (
          <ProductImage src={getUnitImageUrl(defaultUnit.productUnitId)} alt={product.productName} />
        ) : (
          <div className="flex size-full items-center justify-center">
            <Package className="size-10 text-muted-foreground/50" />
          </div>
        )}
        <div className="absolute top-2 right-2">
          <StatusBadge
            status={product.isActive ? 'active' : 'inactive'}
            label={product.isActive ? 'Active' : 'Inactive'}
          />
        </div>
      </div>

      <CardContent className="p-4 flex flex-col flex-1">
        <div className="flex-1 space-y-3">
          <div>
            <p className="text-sm font-medium leading-tight">{product.productName}</p>
            <div className="flex items-center gap-2 text-xs text-muted-foreground mt-0.5">
              <span>{product.productCode}</span>
              {product.categoryName && (
                <>
                  <span>·</span>
                  <span>{product.categoryName}</span>
                </>
              )}
            </div>
          </div>

          {product.units && product.units.length > 0 ? (
            <div className="space-y-2 py-2">
              <p className="text-[10px] font-bold tracking-wider uppercase text-muted-foreground">Variants</p>
              <div className="flex flex-wrap gap-1.5">
                {product.units.map((unit) => (
                  <div
                    key={unit.productUnitId}
                    className={`flex flex-col items-center rounded px-2 py-1 ${
                      unit.isDefault
                        ? 'bg-primary/10 border border-primary'
                        : 'bg-muted border border-border/30'
                    }`}
                  >
                    <span className="text-[10px] font-semibold text-muted-foreground leading-tight">
                      {unit.unitName}
                    </span>
                    <span className={`text-[11px] font-semibold text-muted-foreground leading-tight ${
                      unit.isDefault ? 'text-primary' : 'text-foreground'
                    }`}>
                      {formatCurrency(unit.price, unit.currencySymbol)}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          ) : (
            <p className="text-xs text-muted-foreground">No units configured</p>
          )}
        </div>

        <div className="pt-3 mt-auto border-t">
          <Button
            variant="ghost"
            size="sm"
            className="h-7 text-xs w-full"
            onClick={() => onDetails(product.productId)}
          >
            <ArrowRight className="size-3 mr-1" />
            Details
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

export function Products() {
  const navigate = useNavigate();
  const [page, setPage] = useState(1);
  const { data, isLoading } = useProductsList({ page, pageSize: 20 });

  const totalPages = data ? Math.ceil(data.totalCount / data.pageSize) : 1;

  return (
    <PageLayout
      icon={Package}
      title="Products"
      subtitle={data ? `${data.totalCount} product${data.totalCount !== 1 ? 's' : ''}` : undefined}
      action={<Button onClick={() => navigate('/products/new')}><Plus className="size-4" />New Product</Button>}
    >

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Card key={i} className="overflow-hidden flex flex-col h-full">
              <Skeleton className="aspect-[4/3] rounded-none" />
      <CardContent className="px-4 py-3 flex flex-col flex-1">
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-4 w-3/4" />
                  <Skeleton className="h-3 w-1/2" />
                  <Skeleton className="h-3 w-full mt-3" />
                  <Skeleton className="h-3 w-2/3" />
                </div>
                <Skeleton className="h-8 w-full mt-3 pt-3 border-t" />
              </CardContent>
            </Card>
          ))}
        </div>
      ) : data?.data.length === 0 ? (
        <div className="text-center py-16">
          <Package className="size-12 mx-auto text-muted-foreground/30 mb-4" />
          <p className="text-muted-foreground">No products found</p>
          <Button variant="outline" className="mt-4" onClick={() => navigate('/products/new')}>
            <Plus className="size-4" />
            Create your first product
          </Button>
        </div>
      ) : (
        <>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 items-stretch">
            {data?.data.map((product) => (
              <ProductCard
                key={product.productId}
                product={product}
                onDetails={(id) => navigate(`/products/${id}`)}
              />
            ))}
          </div>

          {totalPages > 1 && data && (
            <div className="flex items-center justify-between pt-2">
              <p className="text-sm text-muted-foreground">
                Showing {(data.page - 1) * data.pageSize + 1}–{Math.min(data.page * data.pageSize, data.totalCount)} of {data.totalCount}
              </p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage((p) => p - 1)}
                  disabled={page <= 1}
                >
                  Previous
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPage((p) => p + 1)}
                  disabled={page >= totalPages}
                >
                  Next
                </Button>
              </div>
            </div>
          )}
        </>
      )}
    </PageLayout>
  );
}

export default Products;
