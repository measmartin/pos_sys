import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useProductsList, useDeleteProduct } from '../hooks';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import type { ProductDetailsDto } from '@PosApi/types';
import { Plus, Trash2, Eye, Pencil, Package } from 'lucide-react';
import { formatCurrency } from '../utils/formatting';

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

function UnitImage({ src }: { src: string }) {
  const [failed, setFailed] = useState(false);
  if (failed) return null;
  return (
    <img
      src={src}
      alt=""
      className="size-4 rounded object-cover"
      onError={() => setFailed(true)}
    />
  );
}

function ProductCard({ product, onView, onEdit, onDelete }: {
  product: ProductDetailsDto;
  onView: (id: number) => void;
  onEdit: (id: number) => void;
  onDelete: (id: number) => void;
}) {
  const defaultUnit = product.units?.find((u) => u.isDefault) ?? product.units?.[0];

  return (
    <Card className="overflow-hidden group">
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

      <CardHeader className="p-4 pb-0">
        <CardTitle className="text-sm leading-tight">{product.productName}</CardTitle>
        <div className="flex items-center gap-2 text-xs text-muted-foreground">
          <span>{product.productCode}</span>
          {product.categoryName && (
            <>
              <span>·</span>
              <span>{product.categoryName}</span>
            </>
          )}
        </div>
      </CardHeader>

      <CardContent className="p-4 pt-3 space-y-3">
        {product.units && product.units.length > 0 ? (
          <div className="space-y-1.5">
            {product.units.slice(0, 3).map((unit) => (
              <div key={unit.productUnitId} className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  {unit.imageUrl && <UnitImage src={getUnitImageUrl(unit.productUnitId)} />}
                  <span className="text-muted-foreground">{unit.unitName}</span>
                  {unit.isDefault && (
                    <span className="text-[10px] text-muted-foreground/60">(default)</span>
                  )}
                </div>
                <span className="font-medium">{formatCurrency(unit.price, unit.currencySymbol)}</span>
              </div>
            ))}
            {product.units.length > 3 && (
              <p className="text-[10px] text-muted-foreground">
                +{product.units.length - 3} more units
              </p>
            )}
          </div>
        ) : (
          <p className="text-xs text-muted-foreground">No units configured</p>
        )}

        <div className="flex gap-1 pt-1 border-t">
          <Button variant="ghost" size="sm" className="h-7 text-xs flex-1" onClick={() => onView(product.productId)}>
            <Eye className="size-3 mr-1" />
            View
          </Button>
          <Button variant="ghost" size="sm" className="h-7 text-xs flex-1" onClick={() => onEdit(product.productId)}>
            <Pencil className="size-3 mr-1" />
            Edit
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className="h-7 text-xs flex-1 text-destructive hover:text-destructive"
            onClick={() => onDelete(product.productId)}
          >
            <Trash2 className="size-3 mr-1" />
            Delete
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

export function Products() {
  const navigate = useNavigate();
  const [page, setPage] = useState(1);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const { data, isLoading } = useProductsList({ page, pageSize: 20 });
  const deleteMutation = useDeleteProduct();

  const handleDelete = async () => {
    if (deleteId == null) return;
    await deleteMutation.mutateAsync(deleteId);
    setDeleteId(null);
  };

  const totalPages = data ? Math.ceil(data.totalCount / data.pageSize) : 1;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold tracking-tight">Products</h1>
          {data && (
            <p className="text-sm text-muted-foreground mt-1">{data.totalCount} product{data.totalCount !== 1 ? 's' : ''}</p>
          )}
        </div>
        <Button onClick={() => navigate('/products/new')}>
          <Plus className="size-4" />
          New Product
        </Button>
      </div>

      {isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Card key={i} className="overflow-hidden">
              <Skeleton className="aspect-[4/3] rounded-none" />
              <CardHeader className="p-4 pb-2 space-y-2">
                <Skeleton className="h-4 w-3/4" />
                <Skeleton className="h-3 w-1/2" />
              </CardHeader>
              <CardContent className="p-4 pt-2 space-y-2">
                <Skeleton className="h-3 w-full" />
                <Skeleton className="h-3 w-2/3" />
                <Skeleton className="h-8 w-full mt-2" />
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
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {data?.data.map((product) => (
              <ProductCard
                key={product.productId}
                product={product}
                onView={(id) => navigate(`/products/${id}`)}
                onEdit={(id) => navigate(`/products/${id}/edit`)}
                onDelete={(id) => setDeleteId(id)}
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

      <ConfirmDialog
        isOpen={deleteId != null}
        onClose={() => setDeleteId(null)}
        onConfirm={handleDelete}
        title="Delete Product"
        message="Are you sure you want to delete this product?"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
