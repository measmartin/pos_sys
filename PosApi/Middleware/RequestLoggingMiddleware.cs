namespace PosApi.Middleware;

public class RequestLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestLoggingMiddleware> _logger;

    public RequestLoggingMiddleware(RequestDelegate next, ILogger<RequestLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var startTime = DateTime.UtcNow;
        var method = context.Request.Method;
        var path = context.Request.Path.Value;
        var queryString = context.Request.QueryString.HasValue ? context.Request.QueryString.Value : null;
        var clientIp = context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
        var userAgent = context.Request.Headers.UserAgent.ToString();
        var userId = context.User?.Identity?.IsAuthenticated == true
            ? context.User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value
            : "anonymous";

        _logger.LogInformation(
            "Request {Method} {Path}{QueryString} started by user {UserId} from {ClientIp}",
            method,
            path,
            queryString,
            userId,
            clientIp);

        try
        {
            await _next(context);
        }
        finally
        {
            var duration = DateTime.UtcNow - startTime;
            var statusCode = context.Response.StatusCode;

            if (statusCode >= 500)
            {
                _logger.LogError(
                    "Request {Method} {Path} completed in {DurationMs}ms with status {StatusCode}",
                    method,
                    path,
                    duration.TotalMilliseconds,
                    statusCode);
            }
            else if (statusCode >= 400)
            {
                _logger.LogWarning(
                    "Request {Method} {Path} completed in {DurationMs}ms with status {StatusCode}",
                    method,
                    path,
                    duration.TotalMilliseconds,
                    statusCode);
            }
            else
            {
                _logger.LogInformation(
                    "Request {Method} {Path} completed in {DurationMs}ms with status {StatusCode}",
                    method,
                    path,
                    duration.TotalMilliseconds,
                    statusCode);
            }
        }
    }
}

public static class RequestLoggingMiddlewareExtensions
{
    public static IApplicationBuilder UseRequestLogging(this IApplicationBuilder builder)
    {
        return builder.UseMiddleware<RequestLoggingMiddleware>();
    }
}
