namespace PosApi.Middleware;

public class ApiKeyAuthenticationMiddleware
{
    private const string ApiKeyHeaderName = "X-API-Key";
    private readonly RequestDelegate _next;
    private readonly IConfiguration _configuration;
    private readonly ILogger<ApiKeyAuthenticationMiddleware> _logger;

    public ApiKeyAuthenticationMiddleware(
        RequestDelegate next,
        IConfiguration configuration,
        ILogger<ApiKeyAuthenticationMiddleware> logger)
    {
        _next = next;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Skip authentication for Scalar/OpenAPI endpoints
        if (context.Request.Path.StartsWithSegments("/scalar") || 
            context.Request.Path.StartsWithSegments("/openapi"))
        {
            await _next(context);
            return;
        }

        _logger.LogDebug(
            "API key auth checking {Method} {Path} from {RemoteIp}",
            context.Request.Method,
            context.Request.Path,
            context.Connection.RemoteIpAddress?.ToString() ?? "unknown");

        if (!context.Request.Headers.TryGetValue(ApiKeyHeaderName, out var extractedApiKey))
        {
            _logger.LogWarning(
                "Missing API key header for {Method} {Path}",
                context.Request.Method,
                context.Request.Path);
            context.Response.StatusCode = 401;
            await context.Response.WriteAsync("API Key is missing");
            return;
        }

        var validApiKeys = _configuration.GetSection("ApiKeys:ValidKeys").Get<string[]>() ?? Array.Empty<string>();
        var apiKeyValue = extractedApiKey.ToString();

        if (!validApiKeys.Contains(apiKeyValue))
        {
            _logger.LogWarning(
                "Invalid API key for {Method} {Path}. Present={HasKey}, Preview={Preview}",
                context.Request.Method,
                context.Request.Path,
                !string.IsNullOrWhiteSpace(apiKeyValue),
                apiKeyValue.Length > 4 ? apiKeyValue[..4] + "..." : apiKeyValue);
            context.Response.StatusCode = 401;
            await context.Response.WriteAsync("Invalid API Key");
            return;
        }

        _logger.LogDebug(
            "API key accepted for {Method} {Path}",
            context.Request.Method,
            context.Request.Path);

        await _next(context);
    }
}

public static class ApiKeyAuthenticationMiddlewareExtensions
{
    public static IApplicationBuilder UseApiKeyAuthentication(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<ApiKeyAuthenticationMiddleware>();
    }
}
