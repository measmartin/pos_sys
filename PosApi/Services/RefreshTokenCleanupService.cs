using Dapper;
using PosApi.Data;

namespace PosApi.Services;

public class RefreshTokenCleanupService : BackgroundService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<RefreshTokenCleanupService> _logger;
    private readonly TimeSpan _cleanupInterval = TimeSpan.FromHours(24);
    private readonly int _maxAgeDays = 30;

    public RefreshTokenCleanupService(
        IServiceProvider serviceProvider,
        ILogger<RefreshTokenCleanupService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Refresh token cleanup service started.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await CleanupExpiredTokensAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during refresh token cleanup.");
            }

            await Task.Delay(_cleanupInterval, stoppingToken);
        }
    }

    private async Task CleanupExpiredTokensAsync(CancellationToken cancellationToken)
    {
        using var scope = _serviceProvider.CreateScope();
        var connectionFactory = scope.ServiceProvider.GetRequiredService<IDatabaseConnectionFactory>();

        using var connection = connectionFactory.CreateConnection();
        const string sql = @"
            DELETE FROM RefreshToken
            WHERE revoked_at IS NOT NULL
               OR expires_at < DATEADD(day, -@MaxAgeDays, GETUTCDATE())";

        var rowsAffected = await connection.ExecuteAsync(sql, new { MaxAgeDays = _maxAgeDays });
        _logger.LogInformation("Cleaned up {Count} expired refresh tokens.", rowsAffected);
    }
}
