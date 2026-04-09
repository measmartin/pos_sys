# POS API - Model Specification for UI/Frontend

## Overview

This document provides a comprehensive specification of all API models (DTOs) that the UI/Frontend should use when communicating with the POS API. It includes request/response structures, validation rules, and example payloads.

---

## Table of Contents

1. [Sales Models](#sales-models)
2. [Sales Item Models](#sales-item-models)
3. [Product Models](#product-models)
4. [Customer Models](#customer-models)
5. [Category Models](#category-models)
6. [Unit Models](#unit-models)
7. [ProductUnit Models](#productunit-models)
8. [Currency Models](#currency-models)
9. [API Endpoints Overview](#api-endpoints-overview)
10. [Error Handling](#error-handling)

---

## Sales Models

### CreateSalesDto
**Purpose**: Used when creating a new sales transaction

**Request Body**:
```json
{
  "saleDate": "2026-04-06T10:30:00Z",
  "customerId": 1,
  "currencyId": 1,
  "amountPaid": 500.00,
  "notes": "Cash sale",
  "discountAmount": 25.00,
  "discountPercentage": 5.00,
  "items": [
    {
      "productId": 1,
      "productUnitId": 1,
      "quantity": 2,
      "unitPrice": 250.00,
      "discountPercentage": 10,
      "discountAmount": 50.00,
      "notes": "Item notes"
    }
  ]
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| saleDate | DateTime | No | Date of sale (defaults to current date/time) |
| customerId | int? | No | Customer ID (null for walk-in customers) |
| currencyId | int | Yes | Currency ID for the transaction |
| amountPaid | decimal | Yes | Amount paid by customer |
| notes | string? | No | Additional notes for the sale |
| discountAmount | decimal? | No | Total discount amount for entire sale |
| discountPercentage | decimal? | No | Total discount percentage for entire sale |
| items | List<CreateSalesItemDto> | Yes | Line items for the sale (at least 1 required) |

**Validation Rules**:
- `currencyId`: Must be a valid active currency
- `amountPaid`: Must be >= 0
- `discountAmount`: Must be >= 0, must not exceed subtotal
- `discountPercentage`: Must be between 0 and 100
- `items`: Must contain at least 1 item
- Each item must have `productId`, `productUnitId`, `quantity`, and `unitPrice`

---

### UpdateSalesDto
**Purpose**: Used when updating an existing sales transaction

**Request Body**:
```json
{
  "saleDate": "2026-04-06T10:30:00Z",
  "customerId": 1,
  "currencyId": 1,
  "subtotal": 500.00,
  "totalDiscount": 25.00,
  "discountPercentage": 5.00,
  "totalAmount": 475.00,
  "amountPaid": 475.00,
  "paymentStatus": "PAID",
  "saleStatus": "COMPLETED",
  "notes": "Updated sale"
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| saleDate | DateTime | Yes | Date of sale |
| customerId | int? | No | Customer ID (null for walk-in) |
| currencyId | int | Yes | Currency ID |
| subtotal | decimal | Yes | Sum of all items before discount |
| totalDiscount | decimal | Yes | Total discount amount |
| discountPercentage | decimal? | No | Total discount percentage |
| totalAmount | decimal | Yes | Final amount after discount |
| amountPaid | decimal | Yes | Amount paid |
| paymentStatus | string | Yes | PAID, UNPAID, or PARTIAL |
| saleStatus | string | Yes | DRAFT, COMPLETED, VOID, REFUNDED, or RETURNED |
| notes | string? | No | Additional notes |

**Validation Rules**:
- `paymentStatus`: Must be one of: PAID, UNPAID, PARTIAL
- `saleStatus`: Must be one of: DRAFT, COMPLETED, VOID, REFUNDED, RETURNED
- `totalAmount`: Must equal subtotal - totalDiscount
- `amountPaid`: Must be >= 0

---

### SalesDetailsDto
**Purpose**: Response model when retrieving a sale

**Response Example**:
```json
{
  "saleId": 1,
  "saleNumber": "2026-0001",
  "saleDate": "2026-04-06T10:30:00Z",
  "customerId": 1,
  "customerName": "John Doe",
  "currencyId": 1,
  "currencyCode": "USD",
  "subtotal": 500.00,
  "totalDiscount": 25.00,
  "discountPercentage": 5.00,
  "totalAmount": 475.00,
  "amountPaid": 475.00,
  "changeAmount": 0.00,
  "paymentStatus": "PAID",
  "saleStatus": "COMPLETED",
  "notes": "Cash sale",
  "createdAt": "2026-04-06T10:30:00Z",
  "updatedAt": null,
  "items": [
    {
      "salesItemId": 1,
      "saleId": 1,
      "lineNumber": 1,
      "productId": 1,
      "productName": "Smartphone X",
      "productUnitId": 1,
      "unitName": "Piece",
      "quantity": 2,
      "unitPrice": 250.00,
      "lineSubtotal": 500.00,
      "discountAmount": 50.00,
      "discountPercentage": 10,
      "lineTotal": 450.00,
      "notes": null,
      "createdAt": "2026-04-06T10:30:00Z"
    }
  ]
}
```

**Field Descriptions**:
| Field | Type | Description |
|-------|------|-------------|
| saleId | int | Unique sale identifier |
| saleNumber | string | Auto-generated sale number (YYYY-NNNN format) |
| saleDate | DateTime | Sale transaction date |
| customerId | int? | Customer ID (null for walk-in) |
| customerName | string? | Customer name (if customer exists) |
| currencyId | int | Currency ID |
| currencyCode | string? | ISO currency code (USD, EUR, etc.) |
| subtotal | decimal | Sum before discount |
| totalDiscount | decimal | Total discount applied |
| discountPercentage | decimal? | Discount percentage |
| totalAmount | decimal | Final amount after discount |
| amountPaid | decimal | Amount paid by customer |
| changeAmount | decimal | Change returned to customer |
| paymentStatus | string | PAID, UNPAID, or PARTIAL |
| saleStatus | string | DRAFT, COMPLETED, VOID, REFUNDED, or RETURNED |
| notes | string? | Additional notes |
| createdAt | DateTime | Record creation timestamp |
| updatedAt | DateTime? | Last update timestamp |
| items | List<SalesItemDetailsDto> | Line items for this sale |

---

### ProcessPaymentDto
**Purpose**: Used when processing payment for a sale

**Request Body**:
```json
{
  "paymentStatus": "PAID",
  "paymentMethod": "CASH",
  "amountPaid": 475.00,
  "changeAmount": 0.00
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| paymentStatus | string | Yes | PAID, UNPAID, or PARTIAL |
| paymentMethod | string? | No | CASH, CARD, TRANSFER, CHECK, etc. |
| amountPaid | decimal | Yes | Amount paid |
| changeAmount | decimal | No | Change returned (defaults to 0) |

---

## Sales Item Models

### CreateSalesItemDto
**Purpose**: Used when adding a line item to a sale

**Request Body**:
```json
{
  "productId": 1,
  "productUnitId": 1,
  "quantity": 2,
  "unitPrice": 250.00,
  "discountPercentage": 10,
  "discountAmount": null,
  "notes": "Item-specific note"
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| productId | int | Yes | Product ID to add |
| productUnitId | int | Yes | Unit variant of the product |
| quantity | decimal | Yes | Quantity to purchase |
| unitPrice | decimal | Yes | Price per unit |
| discountPercentage | decimal? | No | Item-level discount percentage (0-100) |
| discountAmount | decimal? | No | Item-level discount amount |
| notes | string? | No | Item-specific notes |

**Validation Rules**:
- `productId`: Must be a valid active product
- `productUnitId`: Must be valid and belong to the product
- `quantity`: Must be > 0
- `unitPrice`: Must be >= 0
- `discountPercentage`: Must be between 0 and 100 (if provided)
- `discountAmount`: Must be >= 0 (if provided)

**Calculation Rules**:
- If both `discountPercentage` and `discountAmount` provided, `discountAmount` takes precedence
- `lineSubtotal` = quantity × unitPrice
- `lineTotal` = lineSubtotal - discountAmount

---

### UpdateSalesItemDto
**Purpose**: Used when updating an existing line item

**Request Body**:
```json
{
  "quantity": 3,
  "unitPrice": 250.00,
  "discountPercentage": 15,
  "discountAmount": null,
  "isActive": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| quantity | decimal | Yes | Updated quantity |
| unitPrice | decimal | Yes | Updated unit price |
| discountPercentage | decimal? | No | Updated discount percentage |
| discountAmount | decimal? | No | Updated discount amount |
| isActive | bool | Yes | Whether item is active |

---

### SalesItemDetailsDto
**Purpose**: Response model for a line item

**Response Example**:
```json
{
  "salesItemId": 1,
  "saleId": 1,
  "lineNumber": 1,
  "productId": 1,
  "productName": "Smartphone X",
  "productUnitId": 1,
  "unitName": "Piece",
  "quantity": 2,
  "unitPrice": 250.00,
  "lineSubtotal": 500.00,
  "discountAmount": 50.00,
  "discountPercentage": 10,
  "lineTotal": 450.00,
  "notes": "First item",
  "createdAt": "2026-04-06T10:30:00Z"
}
```

---

## Product Models

### CreateProductDto
**Purpose**: Used when creating a new product

**Request Body**:
```json
{
  "productCode": "ELEC001",
  "productName": "Smartphone X",
  "categoryId": 1,
  "baseUnitId": 1,
  "description": "Latest smartphone model"
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| productCode | string | Yes | Unique product SKU/code |
| productName | string | Yes | Product name |
| categoryId | int | Yes | Product category |
| baseUnitId | int | Yes | Default unit of measurement |
| description | string? | No | Product description |

**Validation Rules**:
- `productCode`: Must be unique, max 50 characters
- `productName`: Must not be empty, max 200 characters
- `categoryId`: Must be valid active category
- `baseUnitId`: Must be valid active unit

---

### UpdateProductDto
**Purpose**: Used when updating a product

**Request Body**:
```json
{
  "productCode": "ELEC001",
  "productName": "Smartphone X Pro",
  "categoryId": 1,
  "baseUnitId": 1,
  "description": "Updated description",
  "isActive": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| productCode | string? | No | Product SKU/code |
| productName | string? | No | Product name |
| categoryId | int? | No | Product category |
| baseUnitId | int? | No | Base unit |
| description | string? | No | Product description |
| isActive | bool? | No | Active status |

---

### ProductDetailsDto
**Purpose**: Response model for a product

**Response Example**:
```json
{
  "productId": 1,
  "productCode": "ELEC001",
  "productName": "Smartphone X",
  "categoryId": 1,
  "categoryName": "Electronics",
  "baseUnitId": 1,
  "baseUnitName": "Piece",
  "description": "Latest smartphone model",
  "isActive": true,
  "createdAt": "2026-04-05T08:00:00Z",
  "updatedAt": null
}
```

---

## Customer Models

### CreateCustomerDto
**Purpose**: Used when creating a new customer

**Request Body**:
```json
{
  "customerName": "John Doe",
  "phoneNumber": "+1234567890",
  "email": "john@example.com",
  "location": "123 Main Street",
  "city": "New York",
  "country": "USA",
  "notes": "Preferred customer"
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| customerName | string? | No | Customer name |
| phoneNumber | string? | No | Phone number |
| email | string? | No | Email address |
| location | string? | No | Street address |
| city | string? | No | City |
| country | string? | No | Country |
| notes | string? | No | Additional notes |

**Validation Rules**:
- `phoneNumber`: If provided, should be valid format (10-20 characters)
- `email`: If provided, should be valid email format

---

### UpdateCustomerDto
**Purpose**: Used when updating a customer

**Request Body**:
```json
{
  "customerName": "John Doe Updated",
  "phoneNumber": "+1234567890",
  "email": "john.updated@example.com",
  "location": "456 Oak Avenue",
  "city": "Los Angeles",
  "country": "USA",
  "notes": "VIP customer",
  "isActive": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| customerName | string? | No | Customer name |
| phoneNumber | string? | No | Phone number |
| email | string? | No | Email address |
| location | string? | No | Street address |
| city | string? | No | City |
| country | string? | No | Country |
| notes | string? | No | Additional notes |
| isActive | bool? | No | Active status |

---

### CustomerDetailsDto
**Purpose**: Response model for a customer

**Response Example**:
```json
{
  "customerId": 1,
  "customerName": "John Doe",
  "phoneNumber": "+1234567890",
  "email": "john@example.com",
  "location": "123 Main Street",
  "city": "New York",
  "country": "USA",
  "notes": "Preferred customer",
  "isActive": true,
  "createdAt": "2026-04-05T08:00:00Z",
  "updatedAt": null
}
```

---

## Category Models

### CreateCategoryDto
**Purpose**: Used when creating a product category

**Request Body**:
```json
{
  "categoryName": "Electronics",
  "description": "Electronic devices and accessories"
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| categoryName | string | Yes | Category name (unique) |
| description | string? | No | Category description |

---

### UpdateCategoryDto
**Purpose**: Used when updating a category

**Request Body**:
```json
{
  "categoryName": "Electronics & Gadgets",
  "description": "Electronic devices and tech accessories",
  "isActive": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| categoryName | string? | No | Category name |
| description | string? | No | Category description |
| isActive | bool? | No | Active status |

---

### CategoryDetailsDto
**Purpose**: Response model for a category

**Response Example**:
```json
{
  "categoryId": 1,
  "categoryName": "Electronics",
  "description": "Electronic devices and accessories",
  "isActive": true,
  "createdAt": "2026-04-05T08:00:00Z",
  "updatedAt": null
}
```

---

## Unit Models

### CreateUnitDto
**Purpose**: Used when creating a unit of measurement

**Request Body**:
```json
{
  "unitName": "Kilogram",
  "unitCode": "KG",
  "description": "Weight measurement"
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| unitName | string | Yes | Full unit name (unique) |
| unitCode | string | Yes | Short code (unique), max 10 chars |
| description | string? | No | Unit description |

---

### UpdateUnitDto
**Purpose**: Used when updating a unit

**Request Body**:
```json
{
  "unitName": "Kilogram",
  "unitCode": "KG",
  "description": "Weight measurement unit",
  "isActive": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| unitName | string? | No | Unit name |
| unitCode | string? | No | Unit code |
| description | string? | No | Unit description |
| isActive | bool? | No | Active status |

---

### UnitDetailsDto
**Purpose**: Response model for a unit

**Response Example**:
```json
{
  "unitId": 1,
  "unitName": "Kilogram",
  "unitCode": "KG",
  "description": "Weight measurement",
  "isActive": true,
  "createdAt": "2026-04-05T08:00:00Z"
}
```

---

## ProductUnit Models

### CreateProductUnitDto
**Purpose**: Used when adding a unit variant to a product

**Request Body**:
```json
{
  "productId": 1,
  "unitId": 2,
  "conversionRate": 12,
  "price": 250.00,
  "isDefault": false
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| productId | int | Yes | Product ID |
| unitId | int | Yes | Unit ID |
| conversionRate | decimal | Yes | Conversion to base unit (e.g., 1 box = 12 pieces) |
| price | decimal | Yes | Selling price in this unit |
| isDefault | bool | No | Is this the default selling unit? |

**Validation Rules**:
- `productId`: Must be valid
- `unitId`: Must be valid
- Combination of (productId, unitId) must be unique
- `conversionRate`: Must be > 0
- `price`: Must be >= 0

---

### UpdateProductUnitDto
**Purpose**: Used when updating a product unit

**Request Body**:
```json
{
  "conversionRate": 12,
  "price": 260.00,
  "isDefault": true,
  "isActive": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| conversionRate | decimal? | No | Conversion rate |
| price | decimal? | No | Selling price |
| isDefault | bool? | No | Is default unit |
| isActive | bool? | No | Active status |

---

### ProductUnitDetailsDto
**Purpose**: Response model for a product unit

**Response Example**:
```json
{
  "productUnitId": 1,
  "productId": 1,
  "productName": "Smartphone X",
  "unitId": 1,
  "unitName": "Piece",
  "unitCode": "PCS",
  "conversionRate": 1,
  "price": 250.00,
  "isDefault": true,
  "isActive": true,
  "imagePath": "images/products/1_20260406143000123.webp",
  "imageUrl": "https://localhost:7070/images/products/1_20260406143000123.webp",
  "createdAt": "2026-04-05T08:00:00Z",
  "updatedAt": null
}
```

**Field Descriptions**:
| Field | Type | Description |
|-------|------|-------------|
| productUnitId | int | Unique product unit identifier |
| productId | int | Product ID |
| productName | string? | Product name |
| unitId | int | Unit ID |
| unitName | string? | Unit name |
| unitCode | string? | Unit code |
| conversionRate | decimal | Conversion to base unit |
| price | decimal | Selling price |
| isDefault | bool | Is default selling unit |
| isActive | bool | Active status |
| imagePath | string? | Relative path to image file (null if no image) |
| imageUrl | string? | Full URL to access the image (null if no image) |
| createdAt | DateTime | Record creation timestamp |
| updatedAt | DateTime? | Last update timestamp |

---

### Image Upload/Download Endpoints

#### Upload Image
**Endpoint**: `POST /api/productunits/{id}/image`

**Request**: Multipart form data with file field

**Response**:
```json
{
  "imagePath": "images/products/1_20260406143000123.webp",
  "imageUrl": "https://localhost:7070/images/products/1_20260406143000123.webp",
  "fileSize": 245678,
  "contentType": "image/webp"
}
```

**Validation Rules**:
- File must be JPG, JPEG, PNG, or WebP format
- Maximum file size: 1 MB (before compression)
- Images are automatically compressed and converted to WebP
- Replaces existing image if one exists

#### Get Image
**Endpoint**: `GET /api/productunits/{id}/image`

**Response**: Binary image file (image/webp)

**Status Codes**:
- 200: Image found and returned
- 404: No image found for this ProductUnit

#### Delete Image
**Endpoint**: `DELETE /api/productunits/{id}/image`

**Response**:
```json
{
  "success": true,
  "message": "Image deleted successfully"
}
```

**Status Codes**:
- 200: Image deleted successfully
- 404: ProductUnit not found or no image exists

---

### Image Configuration

| Setting | Value | Description |
|---------|-------|-------------|
| Max File Size | 1 MB | Maximum upload size before compression |
| Allowed Formats | JPG, JPEG, PNG, WebP | Supported image formats |
| Output Format | WebP | All images converted to WebP for optimal compression |
| Max Dimensions | 1920x1920 | Images resized if larger |
| Quality | 80% | WebP compression quality |
| Storage Location | `wwwroot/images/products/` | Local file storage |
| URL Pattern | `https://localhost:7070/images/products/{filename}` | Static file access |

---

### Flutter Integration Examples

**Upload Image**:
```dart
var request = http.MultipartRequest(
  'POST',
  Uri.parse('$baseUrl/api/productunits/$productUnitId/image'),
);
request.files.add(await http.MultipartFile.fromPath('file', imagePath));
request.headers['X-API-Key'] = apiKey;

var response = await request.send();
if (response.statusCode == 200) {
  var responseData = jsonDecode(await response.stream.bytesToString());
  print('Image URL: ${responseData['imageUrl']}');
}
```

**Display Image**:
```dart
// Option 1: Using imageUrl from ProductUnitDetailsDto
Image.network(
  productUnit.imageUrl ?? '',
  headers: {'X-API-Key': apiKey},
  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
)

// Option 2: Direct API endpoint
Image.network(
  '$baseUrl/api/productunits/${productUnit.productUnitId}/image',
  headers: {'X-API-Key': apiKey},
  errorBuilder: (context, error, stackTrace) => Icon(Icons.image_not_supported),
)
```

**Delete Image**:
```dart
var response = await http.delete(
  Uri.parse('$baseUrl/api/productunits/$productUnitId/image'),
  headers: {'X-API-Key': apiKey},
);
```

---

## Currency Models

### CreateCurrencyDto
**Purpose**: Used when adding a currency

**Request Body**:
```json
{
  "currencyCode": "USD",
  "currencyName": "US Dollar",
  "currencySymbol": "$",
  "exchangeRate": 1.00,
  "isBaseCurrency": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| currencyCode | string | Yes | ISO currency code (3 chars, unique) |
| currencyName | string | Yes | Full currency name |
| currencySymbol | string? | No | Currency symbol |
| exchangeRate | decimal | No | Exchange rate to base currency (defaults to 1.00) |
| isBaseCurrency | bool | No | Is this the base currency? |

---

### UpdateCurrencyDto
**Purpose**: Used when updating a currency

**Request Body**:
```json
{
  "currencyCode": "USD",
  "currencyName": "United States Dollar",
  "currencySymbol": "$",
  "exchangeRate": 1.00,
  "isBaseCurrency": true,
  "isActive": true
}
```

**Field Descriptions**:
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| currencyCode | string? | No | Currency code |
| currencyName | string? | No | Currency name |
| currencySymbol | string? | No | Currency symbol |
| exchangeRate | decimal? | No | Exchange rate |
| isBaseCurrency | bool? | No | Is base currency |
| isActive | bool? | No | Active status |

---

### CurrencyDetailsDto
**Purpose**: Response model for a currency

**Response Example**:
```json
{
  "currencyId": 1,
  "currencyCode": "USD",
  "currencyName": "US Dollar",
  "currencySymbol": "$",
  "exchangeRate": 1.00,
  "isBaseCurrency": true,
  "isActive": true,
  "createdAt": "2026-04-05T08:00:00Z",
  "updatedAt": null
}
```

---

## API Endpoints Overview

### Sales Endpoints

| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/sales` | Get all sales | → SalesDetailsDto[] |
| GET | `/api/sales/{id}` | Get sale by ID | → SalesDetailsDto |
| GET | `/api/sales/number/{saleNumber}` | Get sale by number | → SalesDetailsDto |
| GET | `/api/sales/date-range?startDate=...&endDate=...` | Get sales by date range | → SalesDetailsDto[] |
| GET | `/api/sales/customer/{customerId}` | Get sales by customer | → SalesDetailsDto[] |
| POST | `/api/sales` | Create new sale | ← CreateSalesDto → int (saleId) |
| PUT | `/api/sales/{id}` | Update sale | ← UpdateSalesDto → 204 No Content |
| DELETE | `/api/sales/{id}` | Delete sale | → 204 No Content |
| POST | `/api/sales/{saleId}/items` | Add item to sale | ← CreateSalesItemDto → int (itemId) |
| PUT | `/api/sales/{saleId}/items/{itemId}` | Update sale item | ← UpdateSalesItemDto → 204 No Content |
| DELETE | `/api/sales/{saleId}/items/{itemId}` | Remove sale item | → 204 No Content |

### Product Endpoints

| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/products` | Get all products | → ProductDetailsDto[] |
| GET | `/api/products/{id}` | Get product by ID | → ProductDetailsDto |
| GET | `/api/products/category/{categoryId}` | Get products by category | → ProductDetailsDto[] |
| POST | `/api/products` | Create product | ← CreateProductDto → int |
| PUT | `/api/products/{id}` | Update product | ← UpdateProductDto → 204 No Content |
| DELETE | `/api/products/{id}` | Delete product | → 204 No Content |

### Customer Endpoints

| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/customers` | Get all customers | → CustomerDetailsDto[] |
| GET | `/api/customers/{id}` | Get customer by ID | → CustomerDetailsDto |
| GET | `/api/customers/phone/{phone}` | Get customer by phone | → CustomerDetailsDto |
| POST | `/api/customers` | Create customer | ← CreateCustomerDto → int |
| PUT | `/api/customers/{id}` | Update customer | ← UpdateCustomerDto → 204 No Content |
| DELETE | `/api/customers/{id}` | Delete customer | → 204 No Content |

### Category Endpoints

| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/categories` | Get all categories | → CategoryDetailsDto[] |
| GET | `/api/categories/{id}` | Get category by ID | → CategoryDetailsDto |
| POST | `/api/categories` | Create category | ← CreateCategoryDto → int |
| PUT | `/api/categories/{id}` | Update category | ← UpdateCategoryDto → 204 No Content |
| DELETE | `/api/categories/{id}` | Delete category | → 204 No Content |

### Unit Endpoints

| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/units` | Get all units | → UnitDetailsDto[] |
| GET | `/api/units/{id}` | Get unit by ID | → UnitDetailsDto |
| POST | `/api/units` | Create unit | ← CreateUnitDto → int |
| PUT | `/api/units/{id}` | Update unit | ← UpdateUnitDto → 204 No Content |
| DELETE | `/api/units/{id}` | Delete unit | → 204 No Content |

### ProductUnit Endpoints

| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/productunits` | Get all product units | → ProductUnitDetailsDto[] |
| GET | `/api/productunits/{id}` | Get product unit by ID | → ProductUnitDetailsDto |
| GET | `/api/productunits/product/{productId}` | Get units for product | → ProductUnitDetailsDto[] |
| POST | `/api/productunits` | Create product unit | ← CreateProductUnitDto → int |
| PUT | `/api/productunits/{id}` | Update product unit | ← UpdateProductUnitDto → 204 No Content |
| DELETE | `/api/productunits/{id}` | Delete product unit | → 204 No Content |
| POST | `/api/productunits/{id}/image` | Upload/replace image | ← IFormFile → ImageUploadResponse |
| GET | `/api/productunits/{id}/image` | Get image file | → Binary image (image/webp) |
| DELETE | `/api/productunits/{id}/image` | Delete image | → ImageDeleteResponse |

### Currency Endpoints

| Method | Endpoint | Purpose | DTO |
|--------|----------|---------|-----|
| GET | `/api/currencies` | Get all currencies | → CurrencyDetailsDto[] |
| GET | `/api/currencies/{id}` | Get currency by ID | → CurrencyDetailsDto |
| GET | `/api/currencies/code/{code}` | Get currency by code | → CurrencyDetailsDto |
| POST | `/api/currencies` | Create currency | ← CreateCurrencyDto → int |
| PUT | `/api/currencies/{id}` | Update currency | ← UpdateCurrencyDto → 204 No Content |
| DELETE | `/api/currencies/{id}` | Delete currency | → 204 No Content |

---

## Error Handling

### Standard HTTP Status Codes

| Status | Meaning | Example |
|--------|---------|---------|
| 200 | OK | GET request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Update/Delete successful, no response body |
| 400 | Bad Request | Invalid input data |
| 401 | Unauthorized | Missing/invalid API key |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | Duplicate unique field (e.g., productCode) |
| 500 | Internal Server Error | Server error |

### Error Response Format

**On Error**:
```json
{
  "error": "Product with code 'ELEC001' already exists",
  "statusCode": 409,
  "timestamp": "2026-04-06T10:30:00Z"
}
```

### Common Validation Errors

1. **Missing Required Fields**
   - Status: 400
   - Message: "Field '{fieldName}' is required"

2. **Invalid Field Values**
   - Status: 400
   - Message: "Field '{fieldName}' must be {constraint}"

3. **Duplicate Unique Constraints**
   - Status: 409
   - Message: "Record with '{fieldName}' '{value}' already exists"

4. **Invalid Foreign Key Reference**
   - Status: 404
   - Message: "Referenced {entityType} with ID {id} does not exist"

5. **Invalid Sale Status Transition**
   - Status: 400
   - Message: "Cannot transition from {currentStatus} to {newStatus}"

---

## Authentication

All API requests require an API Key header:

```
X-API-Key: your-api-key-here
```

### Example Request Headers

```
GET /api/sales HTTP/1.1
Host: localhost:7070
X-API-Key: your-api-key-here
Content-Type: application/json
Accept: application/json
```

---

## Discount Calculation Rules

### Item-Level Discount (SalesItem)
1. If `discountPercentage` is provided:
   - `discountAmount` = (lineSubtotal × discountPercentage) / 100
2. If `discountAmount` is provided:
   - `discountPercentage` = (discountAmount / lineSubtotal) × 100
3. If both provided:
   - `discountAmount` takes precedence
4. `lineTotal` = lineSubtotal - discountAmount

### Sale-Level Discount (Sales)
1. Sale discount is applied AFTER all item discounts
2. If `discountPercentage` is provided:
   - `discountAmount` = (subtotal × discountPercentage) / 100
3. If `discountAmount` is provided:
   - `discountPercentage` = (discountAmount / subtotal) × 100
4. `totalAmount` = subtotal - totalDiscount

### Payment Status Auto-Calculation
- If `amountPaid >= totalAmount`: `paymentStatus` = PAID
- If `amountPaid = 0`: `paymentStatus` = UNPAID
- If `0 < amountPaid < totalAmount`: `paymentStatus` = PARTIAL

---

## Sale Status Lifecycle

| Status | Description | Valid Transitions |
|--------|-------------|------------------|
| DRAFT | Sale created but not finalized | COMPLETED, VOID |
| COMPLETED | Sale is finalized and paid/unpaid | VOID, REFUNDED, RETURNED |
| VOID | Sale is cancelled | COMPLETED (re-activate) |
| REFUNDED | Sale refunded to customer | RETURNED |
| RETURNED | Products returned by customer | REFUNDED |

---

## Common Workflows

### Workflow 1: Create a Simple Sale (Walk-in Customer)

1. **Create Sale** (POST `/api/sales`)
   - `customerId`: null
   - `currencyId`: 1 (USD)
   - `items`: [ { productId: 1, productUnitId: 1, quantity: 2, unitPrice: 250 } ]

2. **Receive Response**: Sale created with `saleId` = 1

3. **Retrieve Sale** (GET `/api/sales/1`)
   - View complete sale details including items and calculations

4. **Payment Processing**: `amountPaid` automatically updates payment status

### Workflow 2: Create Sale with Item Discounts

1. **Create Sale** with items containing `discountPercentage` or `discountAmount`
2. System automatically calculates:
   - Each item's discount amount
   - Each item's line total
   - Sale subtotal and totals

### Workflow 3: Add Product Unit Variant

1. **Create ProductUnit** (POST `/api/productunits`)
   - `productId`: 1
   - `unitId`: 2 (different unit)
   - `conversionRate`: 12 (12 pieces = 1 box)
   - `price`: 2800 (box price)

2. **Use in Sales**: Customers can now buy the product by box or piece

### Workflow 4: Search Customer and Create Sale

1. **Get Customer by Phone** (GET `/api/customers/phone/{phone}`)
2. **Use customerId in Sale Creation** (POST `/api/sales`)
3. Sale is now linked to customer for reporting

---

## Tips for Frontend Implementation

1. **Dropdown Data Loading**:
   - Load categories, units, currencies on app startup
   - Cache these read-only lists to reduce API calls

2. **Real-time Calculations**:
   - Calculate line totals on client side for instant feedback
   - Server validates and recalculates on POST/PUT

3. **Sale Number Display**:
   - Format is auto-generated, display as read-only
   - Use for receipt/invoice printing

4. **Currency Display**:
   - Always show currency symbol with amounts
   - Format decimals to 2 places

5. **Date/Time Handling**:
   - Send dates in ISO 8601 format (YYYY-MM-DDTHH:mm:ssZ)
   - Handle timezone considerations

6. **Discount Entry**:
   - Allow entry of either percentage OR amount
   - Show both calculated values to user
   - If percentage entered, auto-calculate amount
   - If amount entered, auto-calculate percentage

7. **Error Messages**:
   - Display user-friendly error messages from API
   - Log full error responses for debugging

8. **Validation**:
   - Validate on client before sending to server
   - Server-side validation is the source of truth

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-04-06 | Initial specification with simplified discount model |

