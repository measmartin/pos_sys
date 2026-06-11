# POS API - .NET 8 Web API

A RESTful API for a Point of Sale (POS) system built with .NET 8, using Dapper for data access and JWT authentication.

## Features

- **.NET 8 Web API** with Controllers
- **Dapper** ORM for fast and efficient database access
- **SQL Server** database support
- **JWT Authentication** with secure password hashing (PBKDF2-SHA256)
- **API Key Fallback** for backward compatibility and internal tools
- **Database Transactions** for data integrity on sales operations
- **Exception Handling Middleware** with structured JSON responses
- **Request Logging Middleware** with duration and user tracking
- **Health Checks** endpoint for monitoring
- **CORS Configuration** for frontend integration
- **Scalar API Documentation** - Modern, interactive API documentation UI
- **Repository Pattern** for clean data access layer
- **Service Layer** for business logic separation

## Project Structure

```
PosApi/
├── Controllers/          # API controllers
├── Models/              # Data models
├── DTOs/                # Data transfer objects
├── Services/            # Business logic layer
├── Data/                # Dapper repositories and connection factory
├── Middleware/          # Custom middleware (auth, exception handling, logging)
├── appsettings.json     # Production configuration
├── appsettings.Development.json  # Development configuration
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

2. Run the database migration scripts in order:
   ```bash
   # Using SQL Server Management Studio or Azure Data Studio
   # Execute scripts in database_design/ folder in order:
   # 001_create_schema.sql, 002_simplify_discounts.sql, 003_add_product_unit_image.sql,
   # 004_add_sales_phone_number.sql, 005_add_user_table.sql
   
   # Or using sqlcmd:
   sqlcmd -S localhost -U sa -P YourPassword123 -i database_design/001_create_schema.sql
   sqlcmd -S localhost -U sa -P YourPassword123 -i database_design/005_add_user_table.sql
   ```

### Authentication Configuration

JWT settings are configured in `appsettings.json`:

```json
"Jwt": {
  "Key": "your-super-secret-key-min-32-chars-long",
  "Issuer": "PosApi",
  "Audience": "PosClients",
  "ExpiresInMinutes": 60
}
```

API keys (fallback) are configured in `appsettings.json`:

```json
"ApiKeys": {
  "ValidKeys": [
    "dev-api-key-12345"
  ]
}
```

**IMPORTANT:** Change these keys before deploying to production!

### Running the Application

```bash
cd PosApi
dotnet restore
dotnet build
dotnet run
```

The API will be available at:
- HTTP: `http://localhost:5010`

### API Documentation

When running in Development mode, access the Scalar API documentation at:
- **Scalar UI**: `http://localhost:5010/scalar/v1`

## Authentication

### JWT Authentication (Primary)

1. Login to obtain a token:
   ```bash
   curl -X POST "http://localhost:5010/api/auth/login" \
     -H "Content-Type: application/json" \
     -d '{"username": "admin", "password": "password123"}'
   ```

2. Use the token in subsequent requests:
   ```bash
   curl -X GET "http://localhost:5010/api/products" \
     -H "Authorization: Bearer eyJhbG..."
   ```

### API Key Authentication (Fallback)

For backward compatibility or internal tools:

```bash
curl -X GET "http://localhost:5010/api/products" \
  -H "X-API-Key: dev-api-key-12345"
```

## API Endpoints

### Auth

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login with username/password |
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/change-password` | Change password (authenticated) |
| GET | `/api/auth/me` | Get current user info |

### Products

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/products` | Get all products |
| GET | `/api/products/{id}` | Get product by ID |
| POST | `/api/products` | Create a new product |
| PUT | `/api/products/{id}` | Update a product |
| DELETE | `/api/products/{id}` | Delete a product |

### Sales

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/sales` | Get all sales |
| GET | `/api/sales/{id}` | Get sale by ID |
| POST | `/api/sales` | Create a new sale |
| POST | `/api/sales/{id}/payment` | Process payment |
| POST | `/api/sales/{id}/void` | Void a sale |

### Reports

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/reports/sales/summary` | Sales summary |
| GET | `/api/reports/sales/daily` | Daily sales |
| GET | `/api/reports/products/top` | Top products |
| GET | `/api/reports/customers/top` | Top customers |
| GET | `/api/reports/payments/breakdown` | Payment breakdown |

### Health

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/api/diagnostics/connection` | Connection diagnostics |

## CORS Configuration

Update allowed origins in `appsettings.json` to match your frontend:

```json
"Cors": {
  "AllowedOrigins": [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:5010"
  ]
}
```

## NuGet Packages

- **Dapper** (2.1.72) - Micro ORM for .NET
- **Microsoft.Data.SqlClient** (7.0.0) - SQL Server data provider
- **Scalar.AspNetCore** (2.13.20) - API documentation UI
- **Swashbuckle.AspNetCore** (6.6.2) - OpenAPI/Swagger support
- **SixLabors.ImageSharp** (3.1.12) - Image processing

## Architecture

### Repository Pattern
- Repositories handle all database operations using Dapper
- Clean separation between data access and business logic

### Service Layer
- Services contain business logic
- Controllers remain thin and focused on HTTP concerns

### Authentication
- Custom JWT middleware validates tokens and API keys
- API key fallback for backward compatibility
- Passwords hashed with PBKDF2-SHA256

### Middleware
- **ExceptionHandlingMiddleware**: Catches exceptions and returns structured JSON responses
- **RequestLoggingMiddleware**: Logs request duration, status, user, and client IP
- **JwtAuthenticationMiddleware**: Validates JWT tokens and API keys

### Data Integrity
- `ExecuteWithTransactionAsync` in `SqlConnectionFactory` for database transactions
- Sales operations use transactions to ensure consistency

## Security Notes

- Change default JWT key and API keys before production
- Use HTTPS in production
- Consider implementing rate limiting
- Store sensitive configuration in environment variables or secrets management

## License

This project is created for internal use. Modify as needed for your requirements.
