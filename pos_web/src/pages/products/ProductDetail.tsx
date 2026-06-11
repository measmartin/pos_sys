import { useParams, useNavigate } from 'react-router-dom';
import { useProduct, useDeleteProduct, useUnitsList } from '@/hooks';
import { useUploadProductUnitImage, useDeleteProductUnit, useCreateProductUnit, useUpdateProductUnit, useDeleteProductUnitImage } from '@/hooks';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/ui/StatusBadge';
import { ConfirmDialog } from '@/components/ui/ConfirmDialog';
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
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { formatCurrency } from '@/utils/formatting';
import { useState, useRef } from 'react';
import { ArrowLeft, Trash2, Upload, ImageIcon, Plus, Pencil, Save, X, Loader2, Package } from 'lucide-react';
import { PageLayout } from '@/components/layout/PageLayout';
import { toast } from 'sonner';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:5010';

function getImageUrl(productUnitId: number): string {
  return `${API_BASE_URL}/api/productunits/${productUnitId}/image`;
}

interface EditingUnit {
  productUnitId: number;
  price: string;
  conversionRate: string;
  isDefault: boolean;
  isActive: boolean;
}

export function ProductDetail() {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const productId = Number(id);
  const { data: product, isLoading } = useProduct(productId);
  const deleteMutation = useDeleteProduct();
  const uploadImage = useUploadProductUnitImage();
  const deleteProductUnit = useDeleteProductUnit();
  const deleteUnitImage = useDeleteProductUnitImage();
  const createUnitMutation = useCreateProductUnit();
  const updateUnitMutation = useUpdateProductUnit();
  const { data: unitsData } = useUnitsList({ pageSize: 100 });

  const [showDelete, setShowDelete] = useState(false);
  const [uploadingFor, setUploadingFor] = useState<number | null>(null);
  const [editingUnit, setEditingUnit] = useState<EditingUnit | null>(null);
  const [addDialogOpen, setAddDialogOpen] = useState(false);

  const fileInputRef = useRef<HTMLInputElement>(null);
  const [targetUnitId, setTargetUnitId] = useState<number | null>(null);
  const [pendingUpload, setPendingUpload] = useState<{
    productUnitId: number;
    file: File;
    preview: string;
  } | null>(null);

  const [newUnitId, setNewUnitId] = useState('');
  const [newConversionRate, setNewConversionRate] = useState('1');
  const [newPrice, setNewPrice] = useState('');
  const [newIsDefault, setNewIsDefault] = useState(false);

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
    await deleteUnitImage.mutateAsync(productUnitId);
  };

  const triggerFileSelect = (productUnitId: number) => {
    setTargetUnitId(productUnitId);
    fileInputRef.current?.click();
  };

  const handleFileSelected = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || targetUnitId === null) return;
    const preview = URL.createObjectURL(file);
    setPendingUpload({ productUnitId: targetUnitId, file, preview });
    setTargetUnitId(null);
    e.target.value = '';
  };

  const handleConfirmUpload = async () => {
    if (!pendingUpload) return;
    await handleImageUpload(pendingUpload.productUnitId, pendingUpload.file);
    URL.revokeObjectURL(pendingUpload.preview);
    setPendingUpload(null);
  };

  const handleCancelUpload = () => {
    if (pendingUpload) {
      URL.revokeObjectURL(pendingUpload.preview);
    }
    setPendingUpload(null);
  };

  const handleAddUnit = async () => {
    if (!newUnitId || !newPrice) {
      toast.error('Please select a unit and enter a price');
      return;
    }
    try {
      await createUnitMutation.mutateAsync({
        productId,
        unitId: Number(newUnitId),
        conversionRate: Number(newConversionRate) || 1,
        price: Number(newPrice),
        isDefault: newIsDefault,
      });
      toast.success('Unit added');
      setAddDialogOpen(false);
      setNewUnitId('');
      setNewConversionRate('1');
      setNewPrice('');
      setNewIsDefault(false);
    } catch {
      toast.error('Failed to add unit');
    }
  };

  const startEditing = (unit: { productUnitId: number; price: number; conversionRate: number; isDefault: boolean; isActive: boolean }) => {
    setEditingUnit({
      productUnitId: unit.productUnitId,
      price: String(unit.price),
      conversionRate: String(unit.conversionRate),
      isDefault: unit.isDefault,
      isActive: unit.isActive,
    });
  };

  const cancelEditing = () => {
    setEditingUnit(null);
  };

  const saveEditing = async () => {
    if (!editingUnit) return;
    try {
      await updateUnitMutation.mutateAsync({
        id: editingUnit.productUnitId,
        dto: {
          price: Number(editingUnit.price),
          conversionRate: Number(editingUnit.conversionRate),
          isDefault: editingUnit.isDefault,
          isActive: editingUnit.isActive,
        },
      });
      toast.success('Unit updated');
      setEditingUnit(null);
    } catch {
      toast.error('Failed to update unit');
    }
  };

  const handleDeleteUnit = async (productUnitId: number) => {
    try {
      await deleteProductUnit.mutateAsync(productUnitId);
      toast.success('Unit deleted');
    } catch {
      toast.error('Failed to delete unit');
    }
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

  const availableUnits = unitsData?.data ?? [];
  const existingUnitIds = product.units.map((u) => u.unitId);
  const availableForSelection = availableUnits.filter((u) => !existingUnitIds.includes(u.unitId));

  const isSaving = createUnitMutation.isPending || updateUnitMutation.isPending;

  return (
    <PageLayout
      icon={Package}
      title={product.productName || 'Product Detail'}
      action={
        <div className="flex gap-2">
          <Button variant="link" size="sm" onClick={() => navigate('/products')} className="px-0">
            <ArrowLeft className="size-3.5" />
            Back to Products
          </Button>
          <Button variant="outline" onClick={() => navigate(`/products/${product.productId}/edit`)}>
            Edit
          </Button>
          <Button variant="destructive" onClick={() => setShowDelete(true)}>
            <Trash2 className="size-4" />
            Delete
          </Button>
        </div>
      }
    >

      <div className="space-y-6">
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
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>Units & Pricing ({product.units.length})</CardTitle>
          <Dialog open={addDialogOpen} onOpenChange={setAddDialogOpen}>
            <DialogTrigger render={
              <Button variant="outline" size="sm">
                <Plus className="size-3.5" />
                Add Unit
              </Button>
            } />
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Add Unit</DialogTitle>
              </DialogHeader>
              <div className="space-y-4">
                <div className="space-y-1">
                  <label className="text-sm font-medium">Unit</label>
                  <Select
                    value={newUnitId}
                    onValueChange={(v) => setNewUnitId(v ?? '')}
                    items={availableForSelection.map((u) => ({
                      value: String(u.unitId),
                      label: `${u.unitName} (${u.unitCode})`,
                    }))}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select unit" />
                    </SelectTrigger>
                    <SelectContent>
                      {availableForSelection.map((u) => (
                        <SelectItem key={u.unitId} value={String(u.unitId)}>
                          {u.unitName} ({u.unitCode})
                        </SelectItem>
                      ))}
                      {availableForSelection.length === 0 && (
                        <p className="text-sm text-muted-foreground px-4 py-2">All units added</p>
                      )}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-1">
                  <label className="text-sm font-medium">Price</label>
                  <Input
                    type="number"
                    step="0.01"
                    value={newPrice}
                    onChange={(e) => setNewPrice(e.target.value)}
                    placeholder="0.00"
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-sm font-medium">Conversion Rate</label>
                  <Input
                    type="number"
                    step="0.01"
                    value={newConversionRate}
                    onChange={(e) => setNewConversionRate(e.target.value)}
                    placeholder="1"
                  />
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="newIsDefault"
                    checked={newIsDefault}
                    onChange={(e) => setNewIsDefault(e.target.checked)}
                    className="rounded border-gray-300"
                  />
                  <label htmlFor="newIsDefault" className="text-sm">Set as default unit</label>
                </div>
                <div className="flex justify-end gap-2">
                  <Button variant="outline" onClick={() => setAddDialogOpen(false)}>Cancel</Button>
                  <Button onClick={handleAddUnit} disabled={isSaving || !newUnitId || !newPrice}>
                    {createUnitMutation.isPending ? (
                      <><Loader2 className="size-4 animate-spin mr-2" /> Adding...</>
                    ) : 'Add Unit'}
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
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
              {product.units.map((unit) => {
                const isEditing = editingUnit?.productUnitId === unit.productUnitId;
                return (
                  <TableRow key={unit.productUnitId}>
                    <TableCell>
                      <div className="relative size-10 rounded-md border overflow-hidden bg-muted group">
                        {unit.imageUrl ? (
                          <>
                            <img
                              src={getImageUrl(unit.productUnitId)}
                              alt={unit.unitName ?? ''}
                              className="size-full object-cover cursor-pointer"
                              onClick={() => triggerFileSelect(unit.productUnitId)}
                              onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                            />
                            <button
                              type="button"
                              onClick={() => handleDeleteImage(unit.productUnitId)}
                              className="absolute top-0 right-0 bg-destructive text-white rounded-bl size-4 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity text-[10px] leading-none cursor-pointer"
                              title="Remove image"
                            >
                              ×
                            </button>
                          </>
                        ) : (
                          <button
                            type="button"
                            className="flex size-full items-center justify-center cursor-pointer"
                            onClick={() => triggerFileSelect(unit.productUnitId)}
                          >
                            <ImageIcon className="size-4 text-muted-foreground" />
                          </button>
                        )}
                      </div>
                    </TableCell>
                    <TableCell className="font-medium">{unit.unitName}</TableCell>
                    {isEditing ? (
                      <>
                        <TableCell>
                          <Input
                            type="number"
                            step="0.01"
                            value={editingUnit.price}
                            onChange={(e) => setEditingUnit({ ...editingUnit, price: e.target.value })}
                            className="w-24"
                          />
                        </TableCell>
                        <TableCell>
                          <Input
                            type="number"
                            step="0.01"
                            value={editingUnit.conversionRate}
                            onChange={(e) => setEditingUnit({ ...editingUnit, conversionRate: e.target.value })}
                            className="w-20"
                          />
                        </TableCell>
                        <TableCell>
                          <input
                            type="checkbox"
                            checked={editingUnit.isDefault}
                            onChange={(e) => setEditingUnit({ ...editingUnit, isDefault: e.target.checked })}
                            className="rounded border-gray-300"
                          />
                        </TableCell>
                        <TableCell>
                          <StatusBadge
                            status={editingUnit.isActive ? 'active' : 'inactive'}
                            label={editingUnit.isActive ? 'Active' : 'Inactive'}
                          />
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1 justify-end">
                            <Button variant="ghost" size="sm" onClick={saveEditing} disabled={updateUnitMutation.isPending}>
                              <Save className="size-3.5" />
                            </Button>
                            <Button variant="ghost" size="sm" onClick={cancelEditing}>
                              <X className="size-3.5" />
                            </Button>
                          </div>
                        </TableCell>
                      </>
                    ) : (
                      <>
                        <TableCell>{formatCurrency(unit.price, unit.currencySymbol)}</TableCell>
                        <TableCell>{unit.conversionRate}</TableCell>
                        <TableCell>{unit.isDefault ? 'Yes' : '-'}</TableCell>
                        <TableCell>
                          <StatusBadge
                            status={unit.isActive ? 'active' : 'inactive'}
                            label={unit.isActive ? 'Active' : 'Inactive'}
                          />
                        </TableCell>
                        <TableCell>
                          <div className="flex justify-end gap-2">
                            <Button
                              variant="outline"
                              size="sm"
                              type="button"
                              onClick={() => triggerFileSelect(unit.productUnitId)}
                              disabled={uploadingFor === unit.productUnitId}
                            >
                              {uploadingFor === unit.productUnitId ? (
                                <Loader2 className="size-3.5 animate-spin" />
                              ) : (
                                <Upload className="size-3.5" />
                              )}
                              Image
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => startEditing(unit)}
                            >
                              <Pencil className="size-3.5" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleDeleteUnit(unit.productUnitId)}
                              className="text-destructive"
                            >
                              <Trash2 className="size-3.5" />
                            </Button>
                          </div>
                        </TableCell>
                      </>
                    )}
                  </TableRow>
                );
              })}
              {product.units.length === 0 && (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-muted-foreground">
                    No units configured. Click "Add Unit" to get started.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
      </div>

      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={handleFileSelected}
      />

      <Dialog open={!!pendingUpload} onOpenChange={(open) => { if (!open) handleCancelUpload(); }}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Confirm Image Upload</DialogTitle>
          </DialogHeader>
          {pendingUpload && (
            <div className="space-y-4">
              <img
                src={pendingUpload.preview}
                alt="Preview"
                className="max-h-48 rounded-md object-cover mx-auto"
              />
              <div className="flex justify-end gap-2">
                <Button variant="outline" onClick={handleCancelUpload}>Cancel</Button>
                <Button
                  onClick={handleConfirmUpload}
                  disabled={uploadingFor === pendingUpload.productUnitId}
                >
                  {uploadingFor === pendingUpload.productUnitId ? 'Uploading...' : 'Upload'}
                </Button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        isOpen={showDelete}
        onClose={() => setShowDelete(false)}
        onConfirm={handleDelete}
        title="Delete Product"
        message="Are you sure you want to delete this product?"
        isLoading={deleteMutation.isPending}
      />
    </PageLayout>
  );
}

export default ProductDetail;
