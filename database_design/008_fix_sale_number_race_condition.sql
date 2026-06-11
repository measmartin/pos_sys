-- =============================================
-- Migration: Fix Sale Number Race Condition
-- =============================================
-- Creates a counter table for atomic sale number generation
-- Replaces the non-atomic MAX() approach with an atomic UPDATE

-- Create the sequence counter table
IF OBJECT_ID('SaleNumberSequence', 'U') IS NULL
BEGIN
    CREATE TABLE SaleNumberSequence (
        year INT PRIMARY KEY,
        last_sequence INT NOT NULL DEFAULT 0
    );
END
GO

-- Seed existing years from current Sales data
INSERT INTO SaleNumberSequence (year, last_sequence)
SELECT sale_year, ISNULL(MAX(sale_sequence), 0)
FROM Sales
GROUP BY sale_year
HAVING sale_year NOT IN (SELECT year FROM SaleNumberSequence);
GO

-- Create or update the stored procedure to use atomic increment
IF OBJECT_ID('sp_GetNextSaleNumber', 'P') IS NOT NULL
    DROP PROCEDURE sp_GetNextSaleNumber;
GO

CREATE PROCEDURE sp_GetNextSaleNumber
    @Year INT,
    @SaleNumber NVARCHAR(20) OUTPUT,
    @Sequence INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Ensure the year exists in the counter table
        IF NOT EXISTS (SELECT 1 FROM SaleNumberSequence WITH (UPDLOCK, HOLDLOCK) WHERE year = @Year)
        BEGIN
            INSERT INTO SaleNumberSequence (year, last_sequence)
            VALUES (@Year, 0);
        END
        
        -- Atomically increment the sequence
        UPDATE SaleNumberSequence
        SET @Sequence = last_sequence = last_sequence + 1
        WHERE year = @Year;
        
        COMMIT TRANSACTION;
        
        -- Format: YYYY-NNNN (e.g., 2026-0001)
        SET @SaleNumber = CAST(@Year AS NVARCHAR(4)) + '-' + RIGHT('0000' + CAST(@Sequence AS NVARCHAR(4)), 4);
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        THROW;
    END CATCH
END;
GO

-- =============================================
-- Alternative: Add rowversion to Sales for optimistic concurrency
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'row_version' AND object_id = OBJECT_ID('Sales'))
BEGIN
    ALTER TABLE Sales ADD row_version ROWVERSION;
END
GO

-- Add rowversion to RefreshToken for cleanup tracking
IF NOT EXISTS (SELECT * FROM sys.columns WHERE name = 'row_version' AND object_id = OBJECT_ID('RefreshToken'))
BEGIN
    ALTER TABLE RefreshToken ADD row_version ROWVERSION;
END
GO
