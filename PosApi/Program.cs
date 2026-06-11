using PosApi.Data;
using PosApi.Middleware;
using PosApi.Services;
using Scalar.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.Threading.RateLimiting;

var builder = WebApplication.CreateBuilder(args);

// Validate required secrets are present (not empty)
var jwtKey = builder.Configuration["Jwt:Key"];
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
    throw new InvalidOperationException("Jwt:Key is missing or too short. Set it via environment variable (Jwt__Key) or user secrets.");

if (string.IsNullOrWhiteSpace(connectionString))
    throw new InvalidOperationException("ConnectionStrings:DefaultConnection is missing. Set it via environment variable (ConnectionStrings__DefaultConnection) or user secrets.");

// Add services to the container.
builder.Services.AddControllers();

// Configure OpenAPI/Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Configure CORS
var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? Array.Empty<string>();
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        if (builder.Environment.IsDevelopment())
        {
            // Allow Flutter web/dev clients running on dynamic localhost ports.
            policy.SetIsOriginAllowed(origin =>
            {
                if (!Uri.TryCreate(origin, UriKind.Absolute, out var uri)) return false;
                return uri.Host.Equals("localhost", StringComparison.OrdinalIgnoreCase) ||
                       uri.Host.Equals("127.0.0.1");
            })
            .AllowAnyMethod()
            .AllowAnyHeader();
        }
        else
        {
            if (allowedOrigins.Length == 0)
            {
                throw new InvalidOperationException("Cors:AllowedOrigins is empty. Set it via environment variable (Cors__AllowedOrigins) or user secrets for production.");
            }
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        }
    });
});

// Configure rate limiting
builder.Services.AddRateLimiter(options =>
{
    options.AddFixedWindowLimiter("Api", config =>
    {
        config.PermitLimit = 60;
        config.Window = TimeSpan.FromMinutes(1);
        config.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        config.QueueLimit = 10;
    });
    options.AddFixedWindowLimiter("Auth", config =>
    {
        config.PermitLimit = 10;
        config.Window = TimeSpan.FromMinutes(1);
        config.QueueProcessingOrder = QueueProcessingOrder.OldestFirst;
        config.QueueLimit = 0;
    });
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;
});

// Register database connection factory
builder.Services.AddSingleton<IDatabaseConnectionFactory>(new SqlConnectionFactory(connectionString));

// Configure Dapper
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

// Register repositories
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
builder.Services.AddScoped<IUnitRepository, UnitRepository>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<IProductUnitRepository, ProductUnitRepository>();
builder.Services.AddScoped<ICustomerRepository, CustomerRepository>();
builder.Services.AddScoped<ICurrencyRepository, CurrencyRepository>();
builder.Services.AddScoped<ISalesRepository, SalesRepository>();
builder.Services.AddScoped<ISalesItemRepository, SalesItemRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IReportRepository, ReportRepository>();

// Register services
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IUnitService, UnitService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<IProductUnitService, ProductUnitService>();
builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<ICurrencyService, CurrencyService>();
builder.Services.AddScoped<ISalesService, SalesService>();
builder.Services.AddScoped<IImageService, ImageService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IAuthService, AuthService>();

// Register hosted services
builder.Services.AddHostedService<RefreshTokenCleanupService>();

// Configure standard JWT Authentication for [Authorize] attributes
var jwtIssuer = builder.Configuration["Jwt:Issuer"]!;
var jwtAudience = builder.Configuration["Jwt:Audience"]!;

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorization();

// Add health checks with SQL Server connectivity check
builder.Services.AddHealthChecks()
    .AddSqlServer(connectionString, name: "sql-server", timeout: TimeSpan.FromSeconds(5));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.MapScalarApiReference(options =>
    {
        options.WithTitle("POS API")
               .WithTheme(ScalarTheme.Mars)
               .WithDefaultHttpClient(ScalarTarget.CSharp, ScalarClient.HttpClient);
    });
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// Use exception handling middleware first
app.UseExceptionHandling();

// Use request logging middleware
app.UseRequestLogging();

// Use CORS
app.UseCors();

// Enable static file serving for images
app.UseStaticFiles();

// Use standard ASP.NET Core auth pipeline for [Authorize] attributes
app.UseAuthentication();
app.UseAuthorization();

// Apply rate limiting to auth endpoints
app.UseRateLimiter();

// Add security headers
app.Use(async (context, next) =>
{
    context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Append("X-Frame-Options", "DENY");
    context.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");
    context.Response.Headers.Append("X-XSS-Protection", "0");
    context.Response.Headers.Append("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
    await next();
});

app.MapHealthChecks("/health");

app.MapControllers();

app.Run();

public partial class Program { }
