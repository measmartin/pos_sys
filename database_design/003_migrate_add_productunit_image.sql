USE SalesInvoiceDB;
GO

-- =============================================
-- Migration: Add image_path to ProductUnit
-- Purpose: Allow product units to have associated images
-- Date: 2026-04-06
-- =============================================

-- Add image_path column
IF NOT EXISTS (
    SELECT 1 FROM sys.columns 
    WHERE object_id = OBJECT_ID('ProductUnit') 
    AND name = 'image_path'
)
BEGIN
    ALTER TABLE ProductUnit
    ADD image_path NVARCHAR(500) NULL;
    
    PRINT 'Added image_path column to ProductUnit table';
END
ELSE
BEGIN
    PRINT 'image_path column already exists in ProductUnit table';
END
GO

-- Create index for faster lookups
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes 
    WHERE name = 'IX_ProductUnit_ImagePath'
)
BEGIN
    CREATE INDEX IX_ProductUnit_ImagePath ON ProductUnit(image_path);
    PRINT 'Created index IX_ProductUnit_ImagePath';
END
ELSE
BEGIN
    PRINT 'Index IX_ProductUnit_ImagePath already exists';
END
GO

PRINT 'Migration complete: ProductUnit image support added';
GO
