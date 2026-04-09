# Quick Start Guide

## 1. Setup Database

Update your connection string in `appsettings.Development.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=localhost;Database=PosDb;User Id=sa;Password=YOUR_PASSWORD;TrustServerCertificate=True;"
}
```

Run the database setup script:
```bash
sqlcmd -S localhost -U sa -P YOUR_PASSWORD -i database_setup.sql
```

## 2. Configure API Keys

API keys are already set up in `appsettings.Development.json`:
- `dev-api-key-12345`
- `test-key-67890`

**Remember:** Change these before using in production!

## 3. Run the API

```bash
dotnet run
```

The API will start at:
- `https://localhost:5001`
- `http://localhost:5000`

## 4. Test the API

### Using Scalar UI (Recommended)
Open your browser and navigate to:
```
https://localhost:5001/scalar/v1
```

This provides an interactive API documentation where you can:
- See all endpoints
- Test API calls directly
- View request/response examples

**Don't forget to add the API key header:**
- Header Name: `X-API-Key`
- Header Value: `dev-api-key-12345`

### Using cURL

**Get all products:**
```bash
curl -k -X GET "https://localhost:5001/api/products" -H "X-API-Key: dev-api-key-12345"
```

**Get product by ID:**
```bash
curl -k -X GET "https://localhost:5001/api/products/1" -H "X-API-Key: dev-api-key-12345"
```

**Create a new product:**
```bash
curl -k -X POST "https://localhost:5001/api/products" \
  -H "X-API-Key: dev-api-key-12345" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"New Product\",\"description\":\"Test product\",\"price\":49.99,\"sku\":\"TEST-001\",\"stockQuantity\":10,\"category\":\"Test\"}"
```

**Update a product:**
```bash
curl -k -X PUT "https://localhost:5001/api/products/1" \
  -H "X-API-Key: dev-api-key-12345" \
  -H "Content-Type: application/json" \
  -d "{\"price\":79.99,\"stockQuantity\":20}"
```

**Delete a product:**
```bash
curl -k -X DELETE "https://localhost:5001/api/products/1" \
  -H "X-API-Key: dev-api-key-12345"
```

## 5. Connect Your Frontend

Update your frontend to include the API key in all requests:

**JavaScript/Fetch:**
```javascript
fetch('https://localhost:5001/api/products', {
  headers: {
    'X-API-Key': 'dev-api-key-12345',
    'Content-Type': 'application/json'
  }
})
.then(response => response.json())
.then(data => console.log(data));
```

**Axios:**
```javascript
axios.get('https://localhost:5001/api/products', {
  headers: {
    'X-API-Key': 'dev-api-key-12345'
  }
});
```

## 6. CORS Configuration

If your frontend runs on a different port, add it to `appsettings.Development.json`:

```json
"Cors": {
  "AllowedOrigins": [
    "http://localhost:3000",
    "http://localhost:5173",
    "http://localhost:8080"  // Add your frontend port
  ]
}
```

## Common Issues

### Database Connection Failed
- Verify SQL Server is running
- Check connection string credentials
- Ensure the database exists (run `database_setup.sql`)

### API Key Invalid
- Ensure header name is exactly `X-API-Key`
- Verify the API key matches one in `appsettings.Development.json`

### CORS Error
- Add your frontend URL to `Cors:AllowedOrigins` in appsettings
- Restart the API after configuration changes

## Next Steps

1. Customize the Product model for your needs
2. Add more controllers (Sales, Customers, etc.)
3. Implement additional business logic in services
4. Add validation attributes to DTOs
5. Set up logging (Serilog, etc.)

Happy coding!
