# Quick Start Guide

## 1. Setup Database

Update your connection string in `appsettings.Development.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=PosDb;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
}
```

Run the database migration scripts in order:
```bash
sqlcmd -S localhost -U sa -P YOUR_PASSWORD -i database_design/001_create_schema.sql
sqlcmd -S localhost -U sa -P YOUR_PASSWORD -i database_design/005_add_user_table.sql
```

## 2. Configure Authentication

JWT settings are pre-configured in `appsettings.Development.json`:
```json
"Jwt": {
  "Key": "dev-jwt-secret-key-change-in-production-min-32-chars",
  "Issuer": "PosApi",
  "Audience": "PosClients",
  "ExpiresInMinutes": 60
}
```

API keys (fallback) are also configured:
```json
"ApiKeys": {
  "ValidKeys": ["dev-api-key-12345"]
}
```

**Remember:** Change these before using in production!

## 3. Run the API

```bash
dotnet run
```

The API will start at:
- `http://localhost:5010`

## 4. Test the API

### Using Scalar UI (Recommended)
Open your browser and navigate to:
```
http://localhost:5010/scalar/v1
```

This provides an interactive API documentation where you can:
- See all endpoints
- Test API calls directly
- View request/response examples

### Authentication

**Login to get a JWT token:**
```bash
curl -X POST "http://localhost:5010/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password123"}'
```

**Use the token in requests:**
```bash
curl -X GET "http://localhost:5010/api/products" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Or use API key (fallback):**
```bash
curl -X GET "http://localhost:5010/api/products" \
  -H "X-API-Key: dev-api-key-12345"
```

### Using cURL

**Get all products:**
```bash
curl -X GET "http://localhost:5010/api/products" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Get product by ID:**
```bash
curl -X GET "http://localhost:5010/api/products/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Create a new product:**
```bash
curl -X POST "http://localhost:5010/api/products" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"New Product","description":"Test product","price":49.99,"sku":"TEST-001","categoryId":1}'
```

**Update a product:**
```bash
curl -X PUT "http://localhost:5010/api/products/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"price":79.99}'
```

**Delete a product:**
```bash
curl -X DELETE "http://localhost:5010/api/products/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 5. Connect Your Frontend

### Web Frontend (pos_web)

```bash
cd pos_web
npm install
npm run dev
```

The web app will be at `http://localhost:5173`.

### Flutter App (pos_app)

```bash
cd pos_app
flutter pub get
flutter run
```

## 6. CORS Configuration

If your frontend runs on a different port, add it to `appsettings.Development.json`:

```json
"Cors": {
  "AllowedOrigins": [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:8080"
  ]
}
```

## Common Issues

### Database Connection Failed
- Verify SQL Server is running
- Check connection string credentials
- Ensure the database exists (run migration scripts)

### Authentication Failed
- Ensure JWT token is valid and not expired
- Check that `Authorization: Bearer TOKEN` header is correct
- For API key fallback, ensure `X-API-Key` header is correct

### CORS Error
- Add your frontend URL to `Cors:AllowedOrigins` in appsettings
- Restart the API after configuration changes

## Next Steps

1. Create your first user via `/api/auth/register`
2. Explore the API via Scalar UI
3. Connect the web or mobile frontend
4. Customize the business logic in services

Happy coding!
