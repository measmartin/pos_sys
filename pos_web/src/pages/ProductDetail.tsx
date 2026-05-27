import { useParams, useNavigate } from 'react-router-dom';
import { useProduct, useDeleteProduct } from '../hooks';
import { useUploadProductUnitImage, useDeleteProductUnit } from '../hooks';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '../components/ui/StatusBadge';
import { ConfirmDialog } from '../components/ui/ConfirmDialog';
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { formatCurrency } from '../utils/formatting';
import { useState, useRef } from 'react';
import { ArrowLeft, Trash2, Upload, ImageIcon } from 'lucide-react';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5010';

function getImageUrl(productUnitId: number): string {
  return `${API_BASE_URL}/api/productunits/${productUnitId}/image`;
}

export function ProductDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const { data: product, isLoading } = useProduct(Number(id));
  const deleteMutation = useDeleteProduct();
  const uploadImage = useUploadProductUnitImage();
  const deleteProductUnit = useDeleteProductUnit();
  const [showDelete, setShowDelete] = useState(false);
  const [uploadingFor, setUploadingFor] = useState<number | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleDelete = async () => {
    if (!product) return;
    await deleteMutation.mutateAsync(product.productId);
    navigate('/products');
  };

  const handleImageUpload = async (productUnitId: number, file: File) => {
    setUploadingFor(productUnitId);
    await uploadImage.mutateAsync({ id: productUnitId, file });
    setUploadingFor(null);
  };

  const handleDeleteImage = async (productUnitId: number) => {
    await deleteProductUnit.mutateAsync(productUnitId);
  };

  if (isLoading) {
    return (
      <div className="flex justify-center py-12">
        <div className="animate-spin rounded-full size-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (!product) {
    return (
      <div className="text-center py-12">
        <p className="text-muted-foreground">Product not found</p>
        <Button variant="link" onClick={() => navigate('/products')} className="mt-4">
          Back to Products
        </Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <Button variant="link" size="sm" onClick={() => navigate('/products')} className="px-0">
            <ArrowLeft className="size-3.5" />
            Back to Products
          </Button>
          <h1 className="text-2xl font-bold tracking-tight">{product.productName}</h1>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => navigate(`/products/${product.productId}/edit`)}>
            Edit
          </Button>
          <Button variant="destructive" onClick={() => setShowDelete(true)}>
            <Trash2 className="size-4" />
            Delete
          </Button>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Product Details</CardTitle>
          </CardHeader>
          <CardContent>
            <dl className="grid grid-cols-2 gap-4">
              <div>
                <dt className="text-sm text-muted-foreground">Code</dt>
                <dd className="text-sm font-medium">{product.productCode}</dd>
              </div>
              <div>
                <dt className="text-sm text-muted-foreground">Category</dt>
                <dd className="text-sm font-medium">{product.categoryName ?? '-'}</dd>
              </div>
              <div>
                <dt className="text-sm text-muted-foreground">Base Unit</dt>
                <dd className="text-sm font-medium">{product.baseUnitName ?? '-'}</dd>
              </div>
              <div>
                <dt className="text-sm text-muted-foreground">Status</dt>
                <dd>
                  <StatusBadge
                    status={product.isActive ? 'active' : 'inactive'}
                    label={product.isActive ? 'Active' : 'Inactive'}
                  />
                </dd>
              </div>
              {product.description && (
                <div className="col-span-2">
                  <dt className="text-sm text-muted-foreground">Description</dt>
                  <dd className="text-sm">{product.description}</dd>
                </div>
              )}
            </dl>
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Units & Pricing ({product.units.length})</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Image</TableHead>
                <TableHead>Unit</TableHead>
                <TableHead>Price</TableHead>
                <TableHead>Conversion Rate</TableHead>
                <TableHead>Default</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {product.units.map((unit) => (
                <TableRow key={unit.productUnitId}>
                  <TableCell>
                    <div className="relative size-10 rounded-md border overflow-hidden bg-muted">
                      {unit.imageUrl ? (
                        <img
                          src={getImageUrl(unit.productUnitId)}
                          alt={unit.unitName ?? ''}
                          className="size-full object-cover"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                        />
                      ) : (
                        <div className="flex size-full items-center justify-center">
                          <ImageIcon className="size-4 text-muted-foreground" />
                        </div>
                      )}
                    </div>
                  </TableCell>
                  <TableCell className="font-medium">{unit.unitName}</TableCell>
                  <TableCell>{formatCurrency(unit.price, unit.currencySymbol)}</TableCell>
                  <TableCell>{unit.conversionRate}</TableCell>
                  <TableCell>{unit.isDefault ? 'Yes' : '-'}</TableCell>
                  <TableCell>
                    <StatusBadge
                      status={unit.isActive ? 'active' : 'inactive'}
                      label={unit.isActive ? 'Active' : 'Inactive'}
                    />
                  </TableCell>
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      <Dialog>
                        <DialogTrigger>
                          <Button variant="outline" size="sm" type="button">
                            <Upload className="size-3.5" />
                            Image
                          </Button>
                        </DialogTrigger>
                        <DialogContent>
                          <DialogHeader>
                            <DialogTitle>Manage Image - {unit.unitName}</DialogTitle>
                          </DialogHeader>
                          <div className="space-y-4">
                            {unit.imageUrl && (
                              <div className="flex flex-col items-center gap-2">
                                <img
                                  src={getImageUrl(unit.productUnitId)}
                                  alt={unit.unitName ?? ''}
                                  className="max-h-48 rounded-md object-cover"
                                />
                                <Button
                                  variant="destructive"
                                  size="sm"
                                  onClick={() => handleDeleteImage(unit.productUnitId)}
                                >
                                  <Trash2 className="size-3.5" />
                                  Remove Image
                                </Button>
                              </div>
                            )}
                            <div className="flex flex-col items-center gap-2">
                              <input
                                ref={fileInputRef}
                                type="file"
                                accept="image/*"
                                className="hidden"
                                onChange={(e) => {
                                  const file = e.target.files?.[0];
                                  if (file) handleImageUpload(unit.productUnitId, file);
                                }}
                              />
                              <Button
                                variant="outline"
                                onClick={() => fileInputRef.current?.click()}
                                disabled={uploadingFor === unit.productUnitId}
                              >
                                {uploadingFor === unit.productUnitId ? 'Uploading...' : 'Upload New Image'}
                              </Button>
                            </div>
                          </div>
                        </DialogContent>
                      </Dialog>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>

      <ConfirmDialog
        isOpen={showDelete}
        onClose={() => setShowDelete(false)}
        onConfirm={handleDelete}
        title="Delete Product"
        message="Are you sure you want to delete this product?"
        isLoading={deleteMutation.isPending}
      />
    </div>
  );
}
