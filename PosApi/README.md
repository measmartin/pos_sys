# POS API - .NET 8 Web API Project

A RESTful API for a Point of Sale (POS) system built with .NET 8, using Dapper for data access and API key authentication.

## Features

- **.NET 8 Web API** with Controllers
- **Dapper** ORM for fast and efficient database access
- **SQL Server** database support
- **API Key Authentication** for secure access (no user authentication needed for internal use)
- **CORS Configuration** for frontend integration
- **Scalar API Documentation** - Modern, interactive API documentation UI
- **Repository Pattern** for clean data access layer
- **Service Layer** for business logic separation
- **Dependency Injection** throughout

## Project Structure

```
PosApi/
├── Controllers/          # API controllers (ProductsController)
├── Models/              # Data models and DTOs (Product, DTOs)
├── Services/            # Business logic layer (IProductService, ProductService)
├── Data/                # Dapper repositories (IProductRepository, ProductRepository)
├── Middleware/          # Custom middleware (ApiKeyAuthenticationMiddleware)
├── appsettings.json     # Production configuration
├── appsettings.Development.json  # Development configuration
├── database_setup.sql   # Database creation and seed script
└── Program.cs           # Application entry point
```

## Getting Started

### Prerequisites

- .NET 8 SDK
- SQL Server (Express, LocalDB, or full version)

### Database Setup

1. Update the connection string in `appsettings.json` and `appsettings.Development.json`:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Server=localhost;Database=PosDb;User Id=sa;Password=YourPassword123;TrustServerCertificate=True;"
   }
   ```

2. Run the database setup script:
   ```bash
   # Using SQL Server Management Studio or Azure Data Studio
   # Open and execute: database_setup.sql
   
   # Or using sqlcmd:
   sqlcmd -S localhost -U sa -P YourPassword123 -i database_setup.sql
   ```

### API Key Configuration

API keys are configured in `appsettings.json`:

```json
"ApiKeys": {
  "ValidKeys": [
    "dev-api-key-12345"
  ]
}
```

**IMPORTANT:** Change these API keys before deploying to production!

### Running the Application

```bash
cd PosApi
dotnet restore
dotnet build
dotnet run
```

The API will be available at:
- HTTPS: `https://localhost:5001`
- HTTP: `http://localhost:5000`

### API Documentation

When running in Development mode, access the Scalar API documentation at:
- **Scalar UI**: `https://localhost:5001/scalar/v1`

## API Endpoints

All endpoints require the `X-API-Key` header with a valid API key.

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | Get all products |
| GET | `/api/products/{id}` | Get product by ID |
| POST | `/api/products` | Create a new product |
| PUT | `/api/products/{id}` | Update a product |
| DELETE | `/api/products/{id}` | Delete a product (soft delete) |

### Example Requests

**Get All Products:**
```bash
curl -X GET "https://localhost:5001/api/products" \
  -H "X-API-Key: dev-api-key-12345"
```

**Create Product:**
```bash
curl -X POST "https://localhost:5001/api/products" \
  -H "X-API-Key: dev-api-key-12345" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Product",
    "description": "Product description",
    "price": 99.99,
    "sku": "PRD-001",
    "stockQuantity": 10,
    "category": "Electronics"
  }'
```

**Update Product:**
```bash
curl -X PUT "https://localhost:5001/api/products/1" \
  -H "X-API-Key: dev-api-key-12345" \
  -H "Content-Type: application/json" \
  -d '{
    "price": 89.99,
    "stockQuantity": 15
  }'
```

## CORS Configuration

Update allowed origins in `appsettings.json` to match your frontend:

```json
"Cors": {
  "AllowedOrigins": [
    "http://localhost:3000",
    "http://localhost:5173"
  ]
}
```

## NuGet Packages Used

- **Dapper** (2.1.72) - Micro ORM for .NET
- **Microsoft.Data.SqlClient** (7.0.0) - SQL Server data provider
- **Scalar.AspNetCore** (2.13.20) - API documentation UI
- **Swashbuckle.AspNetCore** (6.6.2) - OpenAPI/Swagger support

## Architecture

### Repository Pattern
- `IProductRepository` and `ProductRepository` handle all database operations using Dapper
- Clean separation between data access and business logic

### Service Layer
- `IProductService` and `ProductService` contain business logic
- Controllers remain thin and focused on HTTP concerns

### API Key Authentication
- Custom middleware validates API keys from `X-API-Key` header
- API documentation endpoints (`/scalar`) are exempt from authentication

## Development Tips

1. **Adding New Endpoints**: Follow the pattern in `ProductsController`
2. **Database Changes**: Update models, DTOs, repository, and service accordingly
3. **Adding New API Keys**: Update `appsettings.Development.json` for local testing
4. **Testing**: Use Scalar UI at `/scalar/v1` for interactive API testing

## Security Notes

- This API uses simple API key authentication suitable for internal/home use
- For production use, consider:
  - Using environment variables for API keys
  - Implementing rate limiting
  - Adding request validation
  - Using HTTPS only
  - Storing API keys securely (Azure Key Vault, etc.)

## Next Steps

Consider adding:
- Sales/Transactions endpoints
- Customers management
- Inventory tracking
- Reports and analytics
- Background jobs for periodic tasks

## License

This project is created for internal use. Modify as needed for your requirements.
