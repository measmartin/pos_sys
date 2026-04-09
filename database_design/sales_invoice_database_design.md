# Sales and Invoice Database Design

## Overview

This database schema is designed for a Point of Sale (POS) system that tracks sales transactions and generates invoices. The system supports multi-currency operations, flexible discount mechanisms, optional customer information, and product management with multiple units of measurement.

## Key Features

- **Year-based Sale Numbering**: Automatic sale number generation in format `YYYY-NNNN` (e.g., 2026-0001, 2026-0002)
- **Multi-currency Support**: Each sale can be conducted in different currencies
- **Flexible Discount System**: 
  - Item-level discounts (per product)
  - Total sale discounts (percentage or fixed amount)
  - Automatic percentage calculation from amount
- **Optional Customer**: Sales can be made with or without customer information
- **Multi-unit Products**: Products can be sold in different units (e.g., kg, piece, box)
- **Payment Tracking**: Payment status, method, and date tracked in sales table

---

## Database Schema

### 1. Category Table

Stores product categories for organization and reporting.

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| category_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique category identifier |
| category_name | NVARCHAR(100) | NOT NULL, UNIQUE | Category name |
| description | NVARCHAR(500) | NULL | Category description |
| is_active | BIT | NOT NULL, DEFAULT 1 | Active status |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |
| updated_at | DATETIME2 | NULL | Last update timestamp |

---

### 2. Unit Table

Defines measurement units (piece, kg, liter, box, etc.).

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| unit_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique unit identifier |
| unit_name | NVARCHAR(50) | NOT NULL, UNIQUE | Unit name (e.g., Piece, Kg, Liter) |
| unit_code | NVARCHAR(10) | NOT NULL, UNIQUE | Short code (e.g., PCS, KG, L) |
| description | NVARCHAR(200) | NULL | Unit description |
| is_active | BIT | NOT NULL, DEFAULT 1 | Active status |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |

---

### 3. Product Table

Master product information.

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| product_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique product identifier |
| product_code | NVARCHAR(50) | NOT NULL, UNIQUE | Product SKU/code |
| product_name | NVARCHAR(200) | NOT NULL | Product name |
| category_id | INT | FOREIGN KEY → Category(category_id) | Product category |
| base_unit_id | INT | FOREIGN KEY → Unit(unit_id) | Default/base unit of measurement |
| description | NVARCHAR(1000) | NULL | Product description |
| is_active | BIT | NOT NULL, DEFAULT 1 | Active status |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |
| updated_at | DATETIME2 | NULL | Last update timestamp |

**Indexes:**
- `IX_Product_CategoryId` on `category_id`
- `IX_Product_ProductCode` on `product_code`

---

### 4. ProductUnit Table

Defines multiple units for a product with conversion rates (e.g., 1 box = 12 pieces).

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| product_unit_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique identifier |
| product_id | INT | FOREIGN KEY → Product(product_id) | Product reference |
| unit_id | INT | FOREIGN KEY → Unit(unit_id) | Unit reference |
| conversion_rate | DECIMAL(18,4) | NOT NULL | Conversion to base unit (e.g., 1 box = 12 pieces) |
| price | DECIMAL(18,2) | NOT NULL | Selling price in this unit |
| is_default | BIT | NOT NULL, DEFAULT 0 | Is this the default selling unit |
| is_active | BIT | NOT NULL, DEFAULT 1 | Active status |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |
| updated_at | DATETIME2 | NULL | Last update timestamp |

**Unique Constraint:**
- `UQ_ProductUnit_ProductId_UnitId` on `(product_id, unit_id)`

**Indexes:**
- `IX_ProductUnit_ProductId` on `product_id`

---

### 5. Customer Table

Stores customer information (optional for sales).

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| customer_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique customer identifier |
| customer_name | NVARCHAR(200) | NULL | Customer name (optional) |
| phone_number | NVARCHAR(20) | NULL | Customer phone number |
| email | NVARCHAR(100) | NULL | Customer email |
| location | NVARCHAR(200) | NULL | Customer address/location |
| city | NVARCHAR(100) | NULL | City |
| country | NVARCHAR(100) | NULL | Country |
| notes | NVARCHAR(1000) | NULL | Additional notes |
| is_active | BIT | NOT NULL, DEFAULT 1 | Active status |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |
| updated_at | DATETIME2 | NULL | Last update timestamp |

**Indexes:**
- `IX_Customer_PhoneNumber` on `phone_number`
- `IX_Customer_Email` on `email`

---

### 6. Currency Table

Defines supported currencies.

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| currency_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique currency identifier |
| currency_code | NVARCHAR(3) | NOT NULL, UNIQUE | ISO currency code (USD, EUR, KHR, etc.) |
| currency_name | NVARCHAR(50) | NOT NULL | Currency name |
| currency_symbol | NVARCHAR(10) | NULL | Currency symbol ($, €, ៛, etc.) |
| exchange_rate | DECIMAL(18,6) | NOT NULL, DEFAULT 1 | Exchange rate to base currency |
| is_base_currency | BIT | NOT NULL, DEFAULT 0 | Is this the base currency |
| is_active | BIT | NOT NULL, DEFAULT 1 | Active status |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |
| updated_at | DATETIME2 | NULL | Last update timestamp |

---

### 7. Sales Table

Main sales/invoice header table with payment tracking.

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| sale_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique sale identifier |
| sale_number | NVARCHAR(20) | NOT NULL, UNIQUE | Sale number (YYYY-NNNN format) |
| sale_year | INT | NOT NULL | Year extracted from sale date |
| sale_sequence | INT | NOT NULL | Sequence number within year |
| sale_date | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Sale transaction date |
| customer_id | INT | NULL, FOREIGN KEY → Customer(customer_id) | Customer reference (optional) |
| currency_id | INT | NOT NULL, FOREIGN KEY → Currency(currency_id) | Currency used for this sale |
| subtotal_amount | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Sum of all items before discount |
| discount_amount | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Total discount amount |
| discount_percentage | DECIMAL(5,2) | NULL | Discount percentage if applicable |
| total_amount | DECIMAL(18,2) | NOT NULL | Final amount after discount |
| amount_paid | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Amount paid by customer |
| change_amount | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Change returned to customer |
| payment_status | NVARCHAR(20) | NOT NULL, DEFAULT 'UNPAID' | PAID, UNPAID, PARTIAL |
| payment_method | NVARCHAR(50) | NULL | CASH, CARD, TRANSFER, CHECK, etc. |
| payment_date | DATETIME2 | NULL | Date payment was received |
| notes | NVARCHAR(1000) | NULL | Additional notes |
| created_by | NVARCHAR(100) | NULL | User who created the sale |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |
| updated_at | DATETIME2 | NULL | Last update timestamp |

**Unique Constraint:**
- `UQ_Sales_YearSequence` on `(sale_year, sale_sequence)`

**Indexes:**
- `IX_Sales_SaleNumber` on `sale_number`
- `IX_Sales_SaleDate` on `sale_date`
- `IX_Sales_CustomerId` on `customer_id`
- `IX_Sales_PaymentStatus` on `payment_status`

---

### 8. SalesItem Table

Individual line items for each sale with item-level discounts.

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| sales_item_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique sales item identifier |
| sale_id | INT | NOT NULL, FOREIGN KEY → Sales(sale_id) ON DELETE CASCADE | Sale reference |
| line_number | INT | NOT NULL | Line item sequence number |
| product_id | INT | NOT NULL, FOREIGN KEY → Product(product_id) | Product reference |
| product_unit_id | INT | NOT NULL, FOREIGN KEY → ProductUnit(product_unit_id) | Product unit used |
| quantity | DECIMAL(18,4) | NOT NULL | Quantity sold |
| unit_price | DECIMAL(18,2) | NOT NULL | Price per unit |
| line_subtotal | DECIMAL(18,2) | NOT NULL | quantity × unit_price |
| discount_amount | DECIMAL(18,2) | NOT NULL, DEFAULT 0 | Item-level discount amount |
| discount_percentage | DECIMAL(5,2) | NULL | Item-level discount percentage |
| line_total | DECIMAL(18,2) | NOT NULL | Subtotal after discount |
| notes | NVARCHAR(500) | NULL | Item notes |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |

**Unique Constraint:**
- `UQ_SalesItem_SaleId_LineNumber` on `(sale_id, line_number)`

**Indexes:**
- `IX_SalesItem_SaleId` on `sale_id`
- `IX_SalesItem_ProductId` on `product_id`

---

### 9. SalesDiscount Table

Tracks overall sale discounts (separate from item-level discounts).

| Column Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| sales_discount_id | INT | PRIMARY KEY, IDENTITY(1,1) | Unique discount identifier |
| sale_id | INT | NOT NULL, FOREIGN KEY → Sales(sale_id) ON DELETE CASCADE | Sale reference |
| discount_type | NVARCHAR(20) | NOT NULL | PERCENTAGE, AMOUNT, CALCULATED |
| discount_value | DECIMAL(18,2) | NOT NULL | Percentage value or amount value |
| discount_amount | DECIMAL(18,2) | NOT NULL | Final discount amount applied |
| discount_percentage | DECIMAL(5,2) | NOT NULL | Final discount percentage |
| reason | NVARCHAR(200) | NULL | Reason for discount |
| applied_by | NVARCHAR(100) | NULL | User who applied discount |
| created_at | DATETIME2 | NOT NULL, DEFAULT GETDATE() | Record creation timestamp |

**Discount Types:**
- `PERCENTAGE`: User specifies percentage (e.g., 10%), amount is calculated
- `AMOUNT`: User specifies fixed amount (e.g., $50), percentage is calculated
- `CALCULATED`: User specifies amount to discount, system calculates percentage

**Indexes:**
- `IX_SalesDiscount_SaleId` on `sale_id`

---

## Entity Relationship Diagram (ERD)

```
Category
   |
   | 1:N
   |
Product ──────┐
   |          │
   | 1:N      │ 1:N
   |          │
ProductUnit   │
   |          │
   | 1:N      │
   |          │
SalesItem ────┘
   |
   | N:1
   |
Sales ────────────┐
   |              │
   | 1:N          │ N:1
   |              │
SalesDiscount  Customer


Unit ──> ProductUnit
         (N:1)

Currency ──> Sales
           (N:1)
```

---

## SQL Server Table Creation Scripts

```sql
-- 1. Create Category Table
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE,
    description NVARCHAR(500) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME2 NULL
);

-- 2. Create Unit Table
CREATE TABLE Unit (
    unit_id INT IDENTITY(1,1) PRIMARY KEY,
    unit_name NVARCHAR(50) NOT NULL UNIQUE,
    unit_code NVARCHAR(10) NOT NULL UNIQUE,
    description NVARCHAR(200) NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- 3. Create Product Table
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
    CONSTRAINT FK_Product_Category FOREIGN KEY (category_id) REFERENCES Category(category_id),
    CONSTRAINT FK_Product_BaseUnit FOREIGN KEY (base_unit_id) REFERENCES Unit(unit_id)
);

CREATE INDEX IX_Product_CategoryId ON Product(category_id);
CREATE INDEX IX_Product_ProductCode ON Product(product_code);

-- 4. Create ProductUnit Table
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
    CONSTRAINT FK_ProductUnit_Product FOREIGN KEY (product_id) REFERENCES Product(product_id),
    CONSTRAINT FK_ProductUnit_Unit FOREIGN KEY (unit_id) REFERENCES Unit(unit_id),
    CONSTRAINT UQ_ProductUnit_ProductId_UnitId UNIQUE (product_id, unit_id)
);

CREATE INDEX IX_ProductUnit_ProductId ON ProductUnit(product_id);

-- 5. Create Customer Table
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

CREATE INDEX IX_Customer_PhoneNumber ON Customer(phone_number);
CREATE INDEX IX_Customer_Email ON Customer(email);

-- 6. Create Currency Table
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

-- 7. Create Sales Table
CREATE TABLE Sales (
    sale_id INT IDENTITY(1,1) PRIMARY KEY,
    sale_number NVARCHAR(20) NOT NULL UNIQUE,
    sale_year INT NOT NULL,
    sale_sequence INT NOT NULL,
    sale_date DATETIME2 NOT NULL DEFAULT GETDATE(),
    customer_id INT NULL,
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
    CONSTRAINT FK_Sales_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
    CONSTRAINT FK_Sales_Currency FOREIGN KEY (currency_id) REFERENCES Currency(currency_id),
    CONSTRAINT UQ_Sales_YearSequence UNIQUE (sale_year, sale_sequence),
    CONSTRAINT CK_Sales_PaymentStatus CHECK (payment_status IN ('PAID', 'UNPAID', 'PARTIAL'))
);

CREATE INDEX IX_Sales_SaleNumber ON Sales(sale_number);
CREATE INDEX IX_Sales_SaleDate ON Sales(sale_date);
CREATE INDEX IX_Sales_CustomerId ON Sales(customer_id);
CREATE INDEX IX_Sales_PaymentStatus ON Sales(payment_status);

-- 8. Create SalesItem Table
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
    CONSTRAINT FK_SalesItem_Sales FOREIGN KEY (sale_id) REFERENCES Sales(sale_id) ON DELETE CASCADE,
    CONSTRAINT FK_SalesItem_Product FOREIGN KEY (product_id) REFERENCES Product(product_id),
    CONSTRAINT FK_SalesItem_ProductUnit FOREIGN KEY (product_unit_id) REFERENCES ProductUnit(product_unit_id),
    CONSTRAINT UQ_SalesItem_SaleId_LineNumber UNIQUE (sale_id, line_number)
);

CREATE INDEX IX_SalesItem_SaleId ON SalesItem(sale_id);
CREATE INDEX IX_SalesItem_ProductId ON SalesItem(product_id);

-- 9. Create SalesDiscount Table
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
    CONSTRAINT FK_SalesDiscount_Sales FOREIGN KEY (sale_id) REFERENCES Sales(sale_id) ON DELETE CASCADE,
    CONSTRAINT CK_SalesDiscount_Type CHECK (discount_type IN ('PERCENTAGE', 'AMOUNT', 'CALCULATED'))
);

CREATE INDEX IX_SalesDiscount_SaleId ON SalesDiscount(sale_id);
```

---

## Stored Procedures and Functions

### Generate Next Sale Number

```sql
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

-- Usage Example:
-- DECLARE @SaleNum NVARCHAR(20), @Seq INT;
-- EXEC sp_GetNextSaleNumber @Year = 2026, @SaleNumber = @SaleNum OUTPUT, @Sequence = @Seq OUTPUT;
-- SELECT @SaleNum AS NextSaleNumber, @Seq AS NextSequence;
```

### Calculate Sale Totals

```sql
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
```

### Apply Discount (with auto-calculation)

```sql
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
```

---

## Sample Data Insertion

```sql
-- Insert Units
INSERT INTO Unit (unit_name, unit_code) VALUES 
('Piece', 'PCS'),
('Kilogram', 'KG'),
('Liter', 'L'),
('Box', 'BOX'),
('Dozen', 'DOZ');

-- Insert Categories
INSERT INTO Category (category_name, description) VALUES 
('Electronics', 'Electronic devices and accessories'),
('Beverages', 'Drinks and liquids'),
('Groceries', 'Food and household items');

-- Insert Currencies
INSERT INTO Currency (currency_code, currency_name, currency_symbol, is_base_currency) VALUES 
('USD', 'US Dollar', '$', 1),
('EUR', 'Euro', '€', 0),
('KHR', 'Cambodian Riel', '៛', 0);

-- Insert Products
INSERT INTO Product (product_code, product_name, category_id, base_unit_id) VALUES 
('ELEC001', 'Smartphone X', 1, 1), -- Electronics, Piece
('BEV001', 'Orange Juice', 2, 3),  -- Beverages, Liter
('GROC001', 'Rice', 3, 2);         -- Groceries, Kilogram

-- Insert ProductUnit (multiple units per product)
-- Rice can be sold by KG or by 5KG bag
INSERT INTO ProductUnit (product_id, unit_id, conversion_rate, price, is_default) VALUES 
(3, 2, 1, 2.50, 1),    -- Rice, KG, 1:1 conversion, $2.50/kg, default
(3, 4, 5, 11.00, 0);   -- Rice, Box (5kg bag), 5:1 conversion, $11.00/box

-- Insert Customers
INSERT INTO Customer (customer_name, phone_number, location, city, country) VALUES 
('John Doe', '+1234567890', '123 Main St', 'New York', 'USA'),
('Jane Smith', '+0987654321', '456 Oak Ave', 'Los Angeles', 'USA');
```

---

## Example Usage Scenarios

### Scenario 1: Create a Sale with Item-level Discounts

```sql
-- Step 1: Get next sale number
DECLARE @SaleNum NVARCHAR(20), @Seq INT, @SaleId INT;
EXEC sp_GetNextSaleNumber @Year = 2026, @SaleNumber = @SaleNum OUTPUT, @Sequence = @Seq OUTPUT;

-- Step 2: Create sale header
INSERT INTO Sales (sale_number, sale_year, sale_sequence, sale_date, customer_id, currency_id, subtotal_amount, total_amount, payment_status)
VALUES (@SaleNum, 2026, @Seq, GETDATE(), 1, 1, 0, 0, 'UNPAID');

SET @SaleId = SCOPE_IDENTITY();

-- Step 3: Add sale items with item-level discounts
-- Item 1: Smartphone - $500, 10% discount
INSERT INTO SalesItem (sale_id, line_number, product_id, product_unit_id, quantity, unit_price, line_subtotal, discount_percentage, discount_amount, line_total)
VALUES (@SaleId, 1, 1, 1, 1, 500.00, 500.00, 10.00, 50.00, 450.00);

-- Item 2: Rice 5kg bag - $11, no discount
INSERT INTO SalesItem (sale_id, line_number, product_id, product_unit_id, quantity, unit_price, line_subtotal, discount_amount, line_total)
VALUES (@SaleId, 2, 3, 2, 2, 11.00, 22.00, 0, 22.00);

-- Step 4: Calculate totals
EXEC sp_CalculateSaleTotals @SaleId;

-- Step 5: Process payment
UPDATE Sales 
SET payment_status = 'PAID',
    payment_method = 'CASH',
    payment_date = GETDATE(),
    amount_paid = 472.00,
    change_amount = 0
WHERE sale_id = @SaleId;
```

### Scenario 2: Create a Sale with Total Discount (by percentage)

```sql
DECLARE @SaleNum NVARCHAR(20), @Seq INT, @SaleId INT;
EXEC sp_GetNextSaleNumber @Year = 2026, @SaleNumber = @SaleNum OUTPUT, @Sequence = @Seq OUTPUT;

-- Create sale
INSERT INTO Sales (sale_number, sale_year, sale_sequence, sale_date, currency_id, subtotal_amount, total_amount, payment_status)
VALUES (@SaleNum, 2026, @Seq, GETDATE(), 1, 0, 0, 'UNPAID');

SET @SaleId = SCOPE_IDENTITY();

-- Add items (no item-level discounts)
INSERT INTO SalesItem (sale_id, line_number, product_id, product_unit_id, quantity, unit_price, line_subtotal, line_total)
VALUES 
(@SaleId, 1, 1, 1, 2, 500.00, 1000.00, 1000.00),
(@SaleId, 2, 3, 1, 10, 2.50, 25.00, 25.00);

-- Apply 15% total discount
EXEC sp_ApplySaleDiscount @SaleId = @SaleId, @DiscountType = 'PERCENTAGE', @DiscountValue = 15.00, @Reason = 'Bulk purchase discount';

-- Payment
UPDATE Sales 
SET payment_status = 'PAID',
    payment_method = 'CARD',
    payment_date = GETDATE(),
    amount_paid = 871.25
WHERE sale_id = @SaleId;
```

### Scenario 3: Create a Sale with Amount-based Discount (calculate percentage)

```sql
DECLARE @SaleNum NVARCHAR(20), @Seq INT, @SaleId INT;
EXEC sp_GetNextSaleNumber @Year = 2026, @SaleNumber = @SaleNum OUTPUT, @Sequence = @Seq OUTPUT;

-- Create sale
INSERT INTO Sales (sale_number, sale_year, sale_sequence, sale_date, currency_id, subtotal_amount, total_amount, payment_status)
VALUES (@SaleNum, 2026, @Seq, GETDATE(), 1, 0, 0, 'UNPAID');

SET @SaleId = SCOPE_IDENTITY();

-- Add items
INSERT INTO SalesItem (sale_id, line_number, product_id, product_unit_id, quantity, unit_price, line_subtotal, line_total)
VALUES (@SaleId, 1, 1, 1, 1, 500.00, 500.00, 500.00);

-- Customer wants $75 off - system will calculate percentage (15%)
EXEC sp_ApplySaleDiscount @SaleId = @SaleId, @DiscountType = 'CALCULATED', @DiscountValue = 75.00, @Reason = 'Customer negotiation';

-- Check discount percentage calculated
SELECT sale_id, discount_amount, discount_percentage FROM SalesDiscount WHERE sale_id = @SaleId;
-- Result: discount_amount = 75.00, discount_percentage = 15.00
```

---

## Query Examples

### Get Invoice Details

```sql
SELECT 
    s.sale_number,
    s.sale_date,
    c.customer_name,
    c.phone_number,
    cur.currency_code,
    cur.currency_symbol,
    p.product_name,
    si.quantity,
    u.unit_code,
    si.unit_price,
    si.line_subtotal,
    si.discount_amount AS item_discount,
    si.line_total,
    s.subtotal_amount,
    s.discount_amount AS total_discount,
    s.total_amount,
    s.payment_status,
    s.payment_method
FROM Sales s
LEFT JOIN Customer c ON s.customer_id = c.customer_id
INNER JOIN Currency cur ON s.currency_id = cur.currency_id
INNER JOIN SalesItem si ON s.sale_id = si.sale_id
INNER JOIN Product p ON si.product_id = p.product_id
INNER JOIN ProductUnit pu ON si.product_unit_id = pu.product_unit_id
INNER JOIN Unit u ON pu.unit_id = u.unit_id
WHERE s.sale_number = '2026-0001'
ORDER BY si.line_number;
```

### Sales Report by Date Range

```sql
SELECT 
    s.sale_date,
    s.sale_number,
    c.customer_name,
    cur.currency_code,
    s.subtotal_amount,
    s.discount_amount,
    s.total_amount,
    s.payment_status
FROM Sales s
LEFT JOIN Customer c ON s.customer_id = c.customer_id
INNER JOIN Currency cur ON s.currency_id = cur.currency_id
WHERE s.sale_date BETWEEN '2026-01-01' AND '2026-12-31'
ORDER BY s.sale_date DESC;
```

### Top Selling Products

```sql
SELECT 
    p.product_code,
    p.product_name,
    cat.category_name,
    SUM(si.quantity) AS total_quantity_sold,
    SUM(si.line_total) AS total_revenue
FROM SalesItem si
INNER JOIN Product p ON si.product_id = p.product_id
INNER JOIN Category cat ON p.category_id = cat.category_id
INNER JOIN Sales s ON si.sale_id = s.sale_id
WHERE s.sale_date BETWEEN '2026-01-01' AND '2026-12-31'
GROUP BY p.product_code, p.product_name, cat.category_name
ORDER BY total_revenue DESC;
```

### Customer Purchase History

```sql
SELECT 
    c.customer_name,
    COUNT(DISTINCT s.sale_id) AS total_purchases,
    SUM(s.total_amount) AS total_spent,
    AVG(s.total_amount) AS average_purchase,
    MAX(s.sale_date) AS last_purchase_date
FROM Customer c
INNER JOIN Sales s ON c.customer_id = s.customer_id
WHERE c.customer_id = 1
GROUP BY c.customer_name;
```

---

## Design Considerations and Best Practices

### 1. Sale Number Generation
- Use stored procedure `sp_GetNextSaleNumber` to ensure unique sequential numbers per year
- The format `YYYY-NNNN` is human-readable and sortable
- Consider wrapping the procedure in a transaction to prevent race conditions

### 2. Discount Handling
- **Item-level discounts**: Stored directly in `SalesItem` table
- **Total discounts**: Stored in `SalesDiscount` table with full tracking
- Three discount modes:
  - `PERCENTAGE`: User enters %, amount is calculated
  - `AMOUNT`: User enters fixed amount, % is calculated
  - `CALCULATED`: User negotiates amount, % is auto-calculated
- The `discount_amount` in `Sales` table is the sum of all discounts

### 3. Multi-currency Support
- Each sale stores its currency
- Exchange rates stored in `Currency` table for reporting
- Consider updating exchange rates regularly
- Reports can convert to base currency using stored rates

### 4. Optional Customer
- `customer_id` in `Sales` is NULL for walk-in customers
- Can still capture customer info after sale if needed
- Allows quick sales without customer lookup

### 5. Product Multi-unit Support
- Products can be sold in different units (kg, box, piece)
- `conversion_rate` allows inventory tracking in base unit
- Each unit can have different pricing
- Example: Rice sold by kg ($2.50/kg) or 5kg bag ($11.00/bag)

### 6. Payment Tracking
- Simple status tracking: PAID, UNPAID, PARTIAL
- Tracks payment method and date
- Supports change calculation
- For complex payment scenarios (installments), consider separate `Payment` table

### 7. Performance Optimization
- Indexes on frequently queried columns (sale_number, sale_date, customer_id)
- Cascading deletes on `SalesItem` and `SalesDiscount` when sale is deleted
- Consider partitioning `Sales` table by year for large datasets

### 8. Data Integrity
- Foreign key constraints ensure referential integrity
- Check constraints for payment_status and discount_type
- Unique constraints prevent duplicate sale numbers
- NOT NULL constraints on critical fields

### 9. Audit Trail
- `created_at` and `updated_at` timestamps on all tables
- `created_by` and `applied_by` fields track user actions
- Consider adding `updated_by` if needed

### 10. Extensibility
- Easy to add tax columns to `SalesItem` or `Sales`
- Can add `Payment` table for complex payment scenarios
- Can add `SalesReturn` table for returns/refunds
- Can add `Inventory` tables for stock management

---

## Future Enhancements

1. **Tax Management**: Add tax calculation support with tax rates
2. **Return/Refund**: Track product returns and refunds
3. **Inventory Management**: Stock levels, reorder points, stock movements
4. **Employee Tracking**: Link sales to specific employees/cashiers
5. **Payment Installments**: Support for partial payments over time
6. **Promotions**: Buy-one-get-one, bundle discounts
7. **Loyalty Program**: Customer points and rewards
8. **Barcode Support**: Add barcode fields to products
9. **Digital Receipts**: Email/SMS receipt delivery
10. **Multi-location**: Support for multiple stores/warehouses

---

## Database Naming Conventions

- **Tables**: PascalCase singular nouns (e.g., `Product`, `SalesItem`)
- **Columns**: snake_case (e.g., `product_id`, `sale_date`)
- **Primary Keys**: `table_name_id` (e.g., `product_id`, `sale_id`)
- **Foreign Keys**: Same as referenced primary key
- **Indexes**: `IX_TableName_ColumnName`
- **Constraints**: `FK_/UQ_/CK_TableName_Description`
- **Stored Procedures**: `sp_VerbNoun` (e.g., `sp_GetNextSaleNumber`)

---

## Conclusion

This database design provides a robust foundation for a sales and invoicing system with:

- Flexible product management with multiple units
- Comprehensive discount system (item and total level)
- Multi-currency support
- Year-based sale numbering
- Optional customer tracking
- Payment status tracking
- Scalability for future enhancements

The schema is normalized to 3NF, ensuring data integrity while maintaining query performance through strategic indexing.
