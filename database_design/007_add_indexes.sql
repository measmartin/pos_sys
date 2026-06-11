-- =============================================
-- Migration: Add Critical Database Indexes
-- =============================================

-- Index for date-range + status filtering in reports and dashboard
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_SaleDate_Status')
    CREATE INDEX IX_Sales_SaleDate_Status ON Sales(sale_date, sale_status) WHERE sale_status != 'VOIDED';

-- Index for product name search (LIKE queries)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Product_IsActive_ProductName')
    CREATE INDEX IX_Product_IsActive_ProductName ON Product(is_active, product_name) WHERE is_active = 1;

-- Index for product unit lookups by product
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_ProductUnit_ProductId_IsActive')
    CREATE INDEX IX_ProductUnit_ProductId_IsActive ON ProductUnit(product_id, is_active) WHERE is_active = 1;

-- Index for sales item lookups by sale
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesItem_SaleId')
    CREATE INDEX IX_SalesItem_SaleId ON SalesItem(sale_id);

-- Index for sales item lookups by product unit (used in joins)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_SalesItem_ProductUnitId')
    CREATE INDEX IX_SalesItem_ProductUnitId ON SalesItem(product_unit_id);

-- Index for refresh token cleanup and validity checks
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_RefreshToken_ExpiresAt_RevokedAt')
    CREATE INDEX IX_RefreshToken_ExpiresAt_RevokedAt ON RefreshToken(expires_at, revoked_at) WHERE revoked_at IS NULL;

-- Index for customer phone lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Customer_PhoneNumber')
    CREATE INDEX IX_Customer_PhoneNumber ON Customer(phone_number) WHERE is_active = 1;

-- Index for sale number lookups
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_SaleNumber')
    CREATE INDEX IX_Sales_SaleNumber ON Sales(sale_number);

-- Index for created_at ordering (recent sales)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Sales_CreatedAt')
    CREATE INDEX IX_Sales_CreatedAt ON Sales(created_at DESC);
