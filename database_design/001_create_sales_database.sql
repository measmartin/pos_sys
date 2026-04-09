-- =============================================
-- Sales and Invoice Database - Table Creation Script
-- Database: SQL Server
-- Version: 1.0
-- Created: 2026-04-05
-- =============================================
-- Description: This script creates all tables, indexes, and constraints
-- for a comprehensive sales and invoicing system with multi-currency
-- support, flexible discounts, and year-based sale numbering.
-- =============================================

-- Use this if you want to create a new database
-- CREATE DATABASE SalesInvoiceDB;
-- GO
-- USE SalesInvoiceDB;
-- GO

-- =============================================
-- Drop existing tables (in reverse order of dependencies)
-- Uncomment these lines if you need to recreate the database
-- =============================================
IF OBJECT_ID('SalesDiscount', 'U') IS NOT NULL DROP TABLE SalesDiscount;
IF OBJECT_ID('SalesItem', 'U') IS NOT NULL DROP TABLE SalesItem;
IF OBJECT_ID('Sales', 'U') IS NOT NULL DROP TABLE Sales;
IF OBJECT_ID('ProductUnit', 'U') IS NOT NULL DROP TABLE ProductUnit;
IF OBJECT_ID('Product', 'U') IS NOT NULL DROP TABLE Product;
IF OBJECT_ID('Customer', 'U') IS NOT NULL DROP TABLE Customer;
IF OBJECT_ID('Currency', 'U') IS NOT NULL DROP TABLE Currency;
IF OBJECT_ID('Category', 'U') IS NOT NULL DROP TABLE Category;
IF OBJECT_ID('Unit', 'U') IS NOT NULL DROP TABLE Unit;

-- =============================================
-- TABLE 1: Category
-- Purpose: Product categorization for organization and reporting
-- =============================================
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL
);

-- =============================================
-- TABLE 2: Unit
-- Purpose: Measurement units (piece, kg, liter, box, etc.)
-- =============================================
CREATE TABLE Unit (
    unit_id INT IDENTITY(1,1) PRIMARY KEY,
    unit_name NVARCHAR(50) NOT NULL UNIQUE,
    unit_code NVARCHAR(10) NOT NULL UNIQUE,
    description NVARCHAR(200) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- =============================================
-- TABLE 3: Product
-- Purpose: Master product information
-- =============================================
CREATE TABLE Product (
    product_id INT IDENTITY(1,1) PRIMARY KEY,
    product_code NVARCHAR(50) NOT NULL UNIQUE,
    product_name NVARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    base_unit_id INT NOT NULL,
    description NVARCHAR(1000) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (category_id) 
        REFERENCES Category(category_id),
    CONSTRAINT FK_Product_BaseUnit FOREIGN KEY (base_unit_id) 
        REFERENCES Unit(unit_id)
);

-- Create indexes for Product table
CREATE INDEX IX_Product_CategoryId ON Product(category_id);
CREATE INDEX IX_Product_ProductCode ON Product(product_code);

-- =============================================
-- TABLE 4: ProductUnit
-- Purpose: Multiple units per product with conversion rates
-- Example: 1 box = 12 pieces, sell by box or piece
-- =============================================
CREATE TABLE ProductUnit (
    product_unit_id INT IDENTITY(1,1) PRIMARY KEY,
    product_id INT NOT NULL,
    unit_id INT NOT NULL,
    conversion_rate DECIMAL(18,4) NOT NULL,
    price DECIMAL(18,2) NOT NULL,
    is_default BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_ProductUnit_Product FOREIGN KEY (product_id) 
        REFERENCES Product(product_id),
    CONSTRAINT FK_ProductUnit_Unit FOREIGN KEY (unit_id) 
        REFERENCES Unit(unit_id),
    CONSTRAINT UQ_ProductUnit_ProductId_UnitId UNIQUE (product_id, unit_id)
);

-- Create indexes for ProductUnit table
CREATE INDEX IX_ProductUnit_ProductId ON ProductUnit(product_id);

-- =============================================
-- TABLE 5: Customer
-- Purpose: Customer information (optional for sales)
-- =============================================
CREATE TABLE Customer (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    customer_name NVARCHAR(200) NULL,
    phone_number NVARCHAR(20) NULL,
    email NVARCHAR(100) NULL,
    location NVARCHAR(200) NULL,
    city NVARCHAR(100) NULL,
    country NVARCHAR(100) NULL,
    notes NVARCHAR(1000) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL
);

-- Create indexes for Customer table
CREATE INDEX IX_Customer_PhoneNumber ON Customer(phone_number);
CREATE INDEX IX_Customer_Email ON Customer(email);

-- =============================================
-- TABLE 6: Currency
-- Purpose: Supported currencies with exchange rates
-- =============================================
CREATE TABLE Currency (
    currency_id INT IDENTITY(1,1) PRIMARY KEY,
    currency_code NVARCHAR(3) NOT NULL UNIQUE,
    currency_name NVARCHAR(50) NOT NULL,
    currency_symbol NVARCHAR(10) NULL,
    exchange_rate DECIMAL(18,6) NOT NULL DEFAULT 1,
    is_base_currency BIT NOT NULL DEFAULT 0,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL
);

-- =============================================
-- TABLE 7: Sales
-- Purpose: Main sales/invoice header with payment tracking
-- Sale Number Format: YYYY-NNNN (e.g., 2026-0001)
-- =============================================
CREATE TABLE Sales (
    sale_id INT IDENTITY(1,1) PRIMARY KEY,
    sale_number NVARCHAR(20) NOT NULL UNIQUE,
    sale_year INT NOT NULL,
    sale_sequence INT NOT NULL,
    sale_date DATETIME2 NOT NULL DEFAULT GETDATE(),
    customer_id INT NULL,
    phone_number NVARCHAR(20) NOT NULL,
    currency_id INT NOT NULL,
    subtotal_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_percentage DECIMAL(5,2) NULL,
    total_amount DECIMAL(18,2) NOT NULL,
    amount_paid DECIMAL(18,2) NOT NULL DEFAULT 0,
    change_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    payment_status NVARCHAR(20) NOT NULL DEFAULT 'UNPAID',
    payment_method NVARCHAR(50) NULL,
    payment_date DATETIME2 NULL,
    notes NVARCHAR(1000) NULL,
    created_by NVARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL,
    CONSTRAINT FK_Sales_Customer FOREIGN KEY (customer_id) 
        REFERENCES Customer(customer_id),
    CONSTRAINT FK_Sales_Currency FOREIGN KEY (currency_id) 
        REFERENCES Currency(currency_id),
    CONSTRAINT UQ_Sales_YearSequence UNIQUE (sale_year, sale_sequence),
    CONSTRAINT CK_Sales_PaymentStatus CHECK (payment_status IN ('PAID', 'UNPAID', 'PARTIAL'))
);

-- Create indexes for Sales table
CREATE INDEX IX_Sales_SaleNumber ON Sales(sale_number);
CREATE INDEX IX_Sales_SaleDate ON Sales(sale_date);
CREATE INDEX IX_Sales_CustomerId ON Sales(customer_id);
CREATE INDEX IX_Sales_PhoneNumber ON Sales(phone_number);
CREATE INDEX IX_Sales_PaymentStatus ON Sales(payment_status);

-- =============================================
-- TABLE 8: SalesItem
-- Purpose: Individual line items for each sale
-- Supports item-level discounts
-- =============================================
CREATE TABLE SalesItem (
    sales_item_id INT IDENTITY(1,1) PRIMARY KEY,
    sale_id INT NOT NULL,
    line_number INT NOT NULL,
    product_id INT NOT NULL,
    product_unit_id INT NOT NULL,
    quantity DECIMAL(18,4) NOT NULL,
    unit_price DECIMAL(18,2) NOT NULL,
    line_subtotal DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL DEFAULT 0,
    discount_percentage DECIMAL(5,2) NULL,
    line_total DECIMAL(18,2) NOT NULL,
    notes NVARCHAR(500) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_SalesItem_Sales FOREIGN KEY (sale_id) 
        REFERENCES Sales(sale_id) ON DELETE CASCADE,
    CONSTRAINT FK_SalesItem_Product FOREIGN KEY (product_id) 
        REFERENCES Product(product_id),
    CONSTRAINT FK_SalesItem_ProductUnit FOREIGN KEY (product_unit_id) 
        REFERENCES ProductUnit(product_unit_id),
    CONSTRAINT UQ_SalesItem_SaleId_LineNumber UNIQUE (sale_id, line_number)
);

-- Create indexes for SalesItem table
CREATE INDEX IX_SalesItem_SaleId ON SalesItem(sale_id);
CREATE INDEX IX_SalesItem_ProductId ON SalesItem(product_id);

-- =============================================
-- TABLE 9: SalesDiscount
-- Purpose: Overall sale discounts (separate from item-level)
-- Discount Types: PERCENTAGE, AMOUNT, CALCULATED
-- =============================================
CREATE TABLE SalesDiscount (
    sales_discount_id INT IDENTITY(1,1) PRIMARY KEY,
    sale_id INT NOT NULL,
    discount_type NVARCHAR(20) NOT NULL,
    discount_value DECIMAL(18,2) NOT NULL,
    discount_amount DECIMAL(18,2) NOT NULL,
    discount_percentage DECIMAL(5,2) NOT NULL,
    reason NVARCHAR(200) NULL,
    applied_by NVARCHAR(100) NULL,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_SalesDiscount_Sales FOREIGN KEY (sale_id) 
        REFERENCES Sales(sale_id) ON DELETE CASCADE,
    CONSTRAINT CK_SalesDiscount_Type CHECK (discount_type IN ('PERCENTAGE', 'AMOUNT', 'CALCULATED'))
);

-- Create indexes for SalesDiscount table
CREATE INDEX IX_SalesDiscount_SaleId ON SalesDiscount(sale_id);

-- =============================================
-- STORED PROCEDURE: Generate Next Sale Number
-- Purpose: Generates sequential sale numbers by year (YYYY-NNNN)
-- =============================================
GO
CREATE PROCEDURE sp_GetNextSaleNumber
    @Year INT,
    @SaleNumber NVARCHAR(20) OUTPUT,
    @Sequence INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get the next sequence for the year
    SELECT @Sequence = ISNULL(MAX(sale_sequence), 0) + 1
    FROM Sales
    WHERE sale_year = @Year;
    
    -- Format: YYYY-NNNN (e.g., 2026-0001)
    SET @SaleNumber = CAST(@Year AS NVARCHAR(4)) + '-' + RIGHT('0000' + CAST(@Sequence AS NVARCHAR(4)), 4);
END;
GO

-- =============================================
-- STORED PROCEDURE: Calculate Sale Totals
-- Purpose: Recalculates subtotal, discounts, and total for a sale
-- =============================================
CREATE PROCEDURE sp_CalculateSaleTotals
    @SaleId INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Subtotal DECIMAL(18,2);
    DECLARE @ItemDiscount DECIMAL(18,2);
    DECLARE @TotalDiscount DECIMAL(18,2);
    DECLARE @FinalTotal DECIMAL(18,2);
    
    -- Calculate subtotal from items (before item-level discounts)
    SELECT @Subtotal = SUM(line_subtotal)
    FROM SalesItem
    WHERE sale_id = @SaleId;
    
    -- Calculate total item-level discounts
    SELECT @ItemDiscount = SUM(discount_amount)
    FROM SalesItem
    WHERE sale_id = @SaleId;
    
    -- Get total-level discount
    SELECT @TotalDiscount = ISNULL(SUM(discount_amount), 0)
    FROM SalesDiscount
    WHERE sale_id = @SaleId;
    
    -- Calculate final total
    SET @FinalTotal = @Subtotal - @ItemDiscount - @TotalDiscount;
    
    -- Update Sales table
    UPDATE Sales
    SET subtotal_amount = @Subtotal,
        discount_amount = @ItemDiscount + @TotalDiscount,
        total_amount = @FinalTotal,
        updated_at = GETDATE()
    WHERE sale_id = @SaleId;
END;
GO

-- =============================================
-- STORED PROCEDURE: Apply Sale Discount
-- Purpose: Applies discount to a sale with auto-calculation
-- Discount Types:
--   - PERCENTAGE: User enters %, amount is calculated
--   - AMOUNT: User enters amount, % is calculated
--   - CALCULATED: User specifies amount, % is auto-calculated
-- =============================================
CREATE PROCEDURE sp_ApplySaleDiscount
    @SaleId INT,
    @DiscountType NVARCHAR(20), -- 'PERCENTAGE', 'AMOUNT', 'CALCULATED'
    @DiscountValue DECIMAL(18,2),
    @Reason NVARCHAR(200) = NULL,
    @AppliedBy NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Subtotal DECIMAL(18,2);
    DECLARE @DiscountAmount DECIMAL(18,2);
    DECLARE @DiscountPercentage DECIMAL(5,2);
    
    -- Get current subtotal (after item discounts)
    SELECT @Subtotal = subtotal_amount - 
                      (SELECT ISNULL(SUM(discount_amount), 0) FROM SalesItem WHERE sale_id = @SaleId)
    FROM Sales
    WHERE sale_id = @SaleId;
    
    IF @Subtotal IS NULL OR @Subtotal <= 0
    BEGIN
        RAISERROR('Invalid sale or subtotal', 16, 1);
        RETURN;
    END
    
    -- Calculate discount amount and percentage based on type
    IF @DiscountType = 'PERCENTAGE'
    BEGIN
        SET @DiscountPercentage = @DiscountValue;
        SET @DiscountAmount = (@Subtotal * @DiscountValue) / 100;
    END
    ELSE IF @DiscountType = 'AMOUNT' OR @DiscountType = 'CALCULATED'
    BEGIN
        SET @DiscountAmount = @DiscountValue;
        SET @DiscountPercentage = (@DiscountValue / @Subtotal) * 100;
    END
    
    -- Insert discount record
    INSERT INTO SalesDiscount (sale_id, discount_type, discount_value, discount_amount, discount_percentage, reason, applied_by)
    VALUES (@SaleId, @DiscountType, @DiscountValue, @DiscountAmount, @DiscountPercentage, @Reason, @AppliedBy);
    
    -- Recalculate sale totals
    EXEC sp_CalculateSaleTotals @SaleId;
END;
GO

-- =============================================
-- SAMPLE DATA: Insert initial reference data
-- =============================================

-- Insert Units
INSERT INTO Unit (unit_name, unit_code, description) VALUES 
('Piece', 'PCS', 'Individual pieces or units'),
('Kilogram', 'KG', 'Weight in kilograms'),
('Liter', 'L', 'Volume in liters'),
('Box', 'BOX', 'Boxed items'),
('Dozen', 'DOZ', '12 pieces'),
('Gram', 'G', 'Weight in grams'),
('Meter', 'M', 'Length in meters'),
('Pack', 'PACK', 'Packaged items');

-- Insert Categories
INSERT INTO Category (category_name, description) VALUES 
('Electronics', 'Electronic devices and accessories'),
('Beverages', 'Drinks and liquid refreshments'),
('Groceries', 'Food and household items'),
('Clothing', 'Apparel and accessories'),
('Office Supplies', 'Office equipment and stationery');

-- Insert Currencies
INSERT INTO Currency (currency_code, currency_name, currency_symbol, exchange_rate, is_base_currency) VALUES 
('USD', 'US Dollar', '$', 1.000000, 1),
('EUR', 'Euro', '€', 0.920000, 0),
('KHR', 'Cambodian Riel', '៛', 4100.000000, 0),
('THB', 'Thai Baht', '฿', 35.000000, 0),
('VND', 'Vietnamese Dong', '₫', 24000.000000, 0);

-- Insert Sample Products
INSERT INTO Product (product_code, product_name, category_id, base_unit_id, description) VALUES 
('ELEC001', 'Smartphone X Pro', 1, 1, 'Latest smartphone with advanced features'),
('ELEC002', 'Wireless Headphones', 1, 1, 'Noise-cancelling bluetooth headphones'),
('BEV001', 'Orange Juice', 2, 3, 'Fresh orange juice 100% natural'),
('BEV002', 'Mineral Water', 2, 3, 'Pure mineral water'),
('GROC001', 'Premium Rice', 3, 2, 'High-quality jasmine rice'),
('GROC002', 'Cooking Oil', 3, 3, 'Vegetable cooking oil'),
('CLOTH001', 'Cotton T-Shirt', 4, 1, 'Comfortable cotton t-shirt'),
('OFF001', 'Printer Paper A4', 5, 4, 'White printer paper A4 size');

-- Insert ProductUnit entries (multiple units per product with pricing)
-- Rice can be sold by KG or by 5KG bag
INSERT INTO ProductUnit (product_id, unit_id, conversion_rate, price, is_default) VALUES 
-- Premium Rice (product_id = 5)
(5, 2, 1.0, 2.50, 1),      -- Per Kilogram, $2.50/kg, default
(5, 4, 5.0, 11.00, 0),     -- Per Box (5kg), $11.00/box

-- Orange Juice (product_id = 3)
(3, 3, 1.0, 3.50, 1),      -- Per Liter, $3.50/L, default
(3, 4, 12.0, 38.00, 0),    -- Per Box (12L), $38.00/box

-- Mineral Water (product_id = 4)
(4, 3, 1.0, 1.00, 1),      -- Per Liter, $1.00/L, default
(4, 4, 24.0, 20.00, 0),    -- Per Box (24L), $20.00/box

-- Smartphone (product_id = 1)
(1, 1, 1.0, 599.00, 1),    -- Per Piece, $599.00, default

-- Wireless Headphones (product_id = 2)
(2, 1, 1.0, 149.00, 1),    -- Per Piece, $149.00, default

-- Cooking Oil (product_id = 6)
(6, 3, 1.0, 4.50, 1),      -- Per Liter, $4.50/L, default

-- Cotton T-Shirt (product_id = 7)
(7, 1, 1.0, 15.00, 1),     -- Per Piece, $15.00, default

-- Printer Paper (product_id = 8)
(8, 4, 1.0, 5.00, 1);      -- Per Box (500 sheets), $5.00/box

-- Insert Sample Customers
INSERT INTO Customer (customer_name, phone_number, email, location, city, country) VALUES 
('John Doe', '+1-555-0101', 'john.doe@email.com', '123 Main Street', 'New York', 'USA'),
('Jane Smith', '+1-555-0102', 'jane.smith@email.com', '456 Oak Avenue', 'Los Angeles', 'USA'),
('Robert Johnson', '+1-555-0103', 'robert.j@email.com', '789 Pine Road', 'Chicago', 'USA'),
('Maria Garcia', '+1-555-0104', 'maria.garcia@email.com', '321 Elm Street', 'Houston', 'USA'),
('David Lee', '+1-555-0105', 'david.lee@email.com', '654 Maple Drive', 'Phoenix', 'USA');

GO

-- =============================================
-- Database creation completed successfully
-- =============================================
PRINT '==============================================';
PRINT 'Sales and Invoice Database Created Successfully';
PRINT '==============================================';
PRINT '';
PRINT 'Tables created: 9';
PRINT '  - Category';
PRINT '  - Unit';
PRINT '  - Product';
PRINT '  - ProductUnit';
PRINT '  - Customer';
PRINT '  - Currency';
PRINT '  - Sales';
PRINT '  - SalesItem';
PRINT '  - SalesDiscount';
PRINT '';
PRINT 'Stored Procedures created: 3';
PRINT '  - sp_GetNextSaleNumber';
PRINT '  - sp_CalculateSaleTotals';
PRINT '  - sp_ApplySaleDiscount';
PRINT '';
PRINT 'Sample data inserted:';
PRINT '  - 8 Units';
PRINT '  - 5 Categories';
PRINT '  - 5 Currencies';
PRINT '  - 8 Products';
PRINT '  - 9 ProductUnit entries';
PRINT '  - 5 Customers';
PRINT '';
PRINT 'Ready to start creating sales!';
PRINT '==============================================';
