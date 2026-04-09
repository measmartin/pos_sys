-- =============================================
-- Migration Script: Simplify Discount Design
-- Purpose: 
--   1. Remove SalesDiscount table (not needed for simple discount model)
--   2. Add discount_percentage to Sales table
--   3. Add sale_status to Sales table (replaces is_active concept)
-- =============================================

USE SalesInvoiceDB;
GO

-- Step 1: Drop SalesDiscount table (cascade will handle foreign key)
IF OBJECT_ID('SalesDiscount', 'U') IS NOT NULL 
BEGIN
    PRINT 'Dropping SalesDiscount table...';
    DROP TABLE SalesDiscount;
END
GO

-- Step 2: Add discount_percentage to Sales table
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales') AND name = 'discount_percentage')
BEGIN
    PRINT 'Adding discount_percentage to Sales table...';
    ALTER TABLE Sales ADD discount_percentage DECIMAL(5,2) NULL;
END
GO

-- Step 3: Add sale_status to Sales table
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales') AND name = 'sale_status')
BEGIN
    PRINT 'Adding sale_status to Sales table...';
    ALTER TABLE Sales ADD sale_status VARCHAR(20) NOT NULL DEFAULT 'COMPLETED'
        CONSTRAINT CK_Sales_Status CHECK (sale_status IN ('DRAFT', 'COMPLETED', 'VOID', 'REFUNDED', 'RETURNED'));
END
GO

-- Step 4: Update existing sales to have COMPLETED status
UPDATE Sales SET sale_status = 'COMPLETED' WHERE sale_status IS NULL;
GO

-- Step 5: Drop the old sp_ApplySaleDiscount stored procedure (no longer needed)
IF OBJECT_ID('sp_ApplySaleDiscount', 'P') IS NOT NULL
BEGIN
    PRINT 'Dropping sp_ApplySaleDiscount stored procedure...';
    DROP PROCEDURE sp_ApplySaleDiscount;
END
GO

-- Step 6: Update sp_CalculateSaleTotals to work without SalesDiscount table
IF OBJECT_ID('sp_CalculateSaleTotals', 'P') IS NOT NULL
BEGIN
    DROP PROCEDURE sp_CalculateSaleTotals;
END
GO

CREATE PROCEDURE sp_CalculateSaleTotals
    @SaleId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Subtotal DECIMAL(18,2);
    DECLARE @ItemDiscount DECIMAL(18,2);
    DECLARE @TotalDiscount DECIMAL(18,2);
    DECLARE @FinalTotal DECIMAL(18,2);
    DECLARE @SaleDiscount DECIMAL(18,2);
    
    -- Calculate subtotal from items (before item-level discounts)
    SELECT @Subtotal = ISNULL(SUM(line_subtotal), 0)
    FROM SalesItem
    WHERE sale_id = @SaleId;
    
    -- Calculate total item-level discounts
    SELECT @ItemDiscount = ISNULL(SUM(discount_amount), 0)
    FROM SalesItem
    WHERE sale_id = @SaleId;
    
    -- Get sale-level discount (now stored directly in Sales table)
    SELECT @SaleDiscount = ISNULL(discount_amount, 0)
    FROM Sales
    WHERE sale_id = @SaleId;
    
    -- Total discount is sum of item discounts and sale discount
    SET @TotalDiscount = @ItemDiscount + @SaleDiscount;
    
    -- Calculate final total
    SET @FinalTotal = @Subtotal - @TotalDiscount;
    
    -- Update Sales table
    UPDATE Sales
    SET subtotal_amount = @Subtotal,
        discount_amount = @TotalDiscount,
        total_amount = @FinalTotal,
        updated_at = GETDATE()
    WHERE sale_id = @SaleId;
END;
GO

PRINT '==============================================';
PRINT 'Migration completed successfully!';
PRINT '==============================================';
PRINT '';
PRINT 'Changes applied:';
PRINT '  - Dropped SalesDiscount table';
PRINT '  - Added discount_percentage to Sales table';
PRINT '  - Added sale_status to Sales table';
PRINT '  - Updated sp_CalculateSaleTotals procedure';
PRINT '  - Dropped sp_ApplySaleDiscount procedure';
PRINT '';
PRINT 'Sale discount is now stored directly in Sales table.';
PRINT 'Sale status values: DRAFT, COMPLETED, VOID, REFUNDED, RETURNED';
PRINT '==============================================';
