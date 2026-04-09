USE SalesInvoiceDB;
GO

-- =============================================
-- Migration: Add phone_number to Sales table
-- Purpose: Require phone number for all sales transactions
-- Date: 2026-04-07
-- =============================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('Sales')
      AND name = 'phone_number'
)
BEGIN
    ALTER TABLE Sales
    ADD phone_number NVARCHAR(20) NOT NULL CONSTRAINT DF_Sales_PhoneNumber DEFAULT '';

    PRINT 'Added phone_number column to Sales table';
END
ELSE
BEGIN
    PRINT 'phone_number column already exists in Sales table';
END
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Sales_PhoneNumber'
      AND object_id = OBJECT_ID('Sales')
)
BEGIN
    CREATE INDEX IX_Sales_PhoneNumber ON Sales(phone_number);
    PRINT 'Created index IX_Sales_PhoneNumber';
END
ELSE
BEGIN
    PRINT 'Index IX_Sales_PhoneNumber already exists';
END
GO

PRINT 'Migration complete: Sales phone number requirement added';
GO
