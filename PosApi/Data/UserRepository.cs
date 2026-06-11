using Dapper;
using PosApi.Models;
using System.Data;

namespace PosApi.Data;

public class UserRepository : IUserRepository
{
    private readonly IDatabaseConnectionFactory _connectionFactory;

    public UserRepository(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT 
                user_id AS UserId,
                username AS Username,
                email AS Email,
                display_name AS DisplayName,
                is_active AS IsActive,
                created_at AS CreatedAt,
                updated_at AS UpdatedAt,
                last_login_at AS LastLoginAt
            FROM [User] WHERE user_id = @Id";
        return await connection.QuerySingleOrDefaultAsync<User>(sql, new { Id = id });
    }

    public async Task<User?> GetByUsernameAsync(string username)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT 
                user_id AS UserId,
                username AS Username,
                password_hash AS PasswordHash,
                email AS Email,
                display_name AS DisplayName,
                is_active AS IsActive,
                created_at AS CreatedAt,
                updated_at AS UpdatedAt,
                last_login_at AS LastLoginAt
            FROM [User] WHERE username = @Username";
        return await connection.QuerySingleOrDefaultAsync<User>(sql, new { Username = username });
    }

    public async Task<User?> GetByEmailAsync(string email)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT 
                user_id AS UserId,
                username AS Username,
                email AS Email,
                display_name AS DisplayName,
                is_active AS IsActive,
                created_at AS CreatedAt,
                updated_at AS UpdatedAt,
                last_login_at AS LastLoginAt
            FROM [User] WHERE email = @Email";
        return await connection.QuerySingleOrDefaultAsync<User>(sql, new { Email = email });
    }

    public async Task<bool> ExistsAsync(string username)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "SELECT COUNT(1) FROM [User] WHERE username = @Username";
        var count = await connection.ExecuteScalarAsync<int>(sql, new { Username = username });
        return count > 0;
    }

    public async Task<int> CreateAsync(User user, IDbConnection? connection = null, IDbTransaction? transaction = null)
    {
        var conn = connection ?? _connectionFactory.CreateConnection();
        var shouldDispose = connection == null;
        
        if (shouldDispose) conn.Open();
        
        const string sql = @"
            INSERT INTO [User] (username, password_hash, email, display_name, is_active, created_at)
            VALUES (@Username, @PasswordHash, @Email, @DisplayName, @IsActive, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() AS INT);";
        
        var id = await conn.ExecuteScalarAsync<int>(sql, user, transaction);
        
        if (shouldDispose) conn.Dispose();
        
        return id;
    }

    public async Task<bool> UpdateAsync(User user)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            UPDATE [User] 
            SET username = @Username, email = @Email, display_name = @DisplayName, 
                is_active = @IsActive, updated_at = @UpdatedAt
            WHERE user_id = @UserId";
        var rows = await connection.ExecuteAsync(sql, user);
        return rows > 0;
    }

    public async Task<bool> UpdateLastLoginAsync(int userId)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = "UPDATE [User] SET last_login_at = @LastLoginAt WHERE user_id = @UserId";
        var rows = await connection.ExecuteAsync(sql, new { UserId = userId, LastLoginAt = DateTime.UtcNow });
        return rows > 0;
    }

    public async Task<bool> ChangePasswordAsync(int userId, string newPasswordHash)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"UPDATE [User] SET password_hash = @PasswordHash, updated_at = @UpdatedAt WHERE user_id = @UserId";
        var rows = await connection.ExecuteAsync(sql, new { UserId = userId, PasswordHash = newPasswordHash, UpdatedAt = DateTime.UtcNow });
        return rows > 0;
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT 
                user_id AS UserId,
                username AS Username,
                email AS Email,
                display_name AS DisplayName,
                is_active AS IsActive,
                created_at AS CreatedAt,
                updated_at AS UpdatedAt,
                last_login_at AS LastLoginAt
            FROM [User]";
        return await connection.QueryAsync<User>(sql);
    }

    public async Task<int> CreateRefreshTokenAsync(int userId, string token, DateTime expiresAt)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            INSERT INTO RefreshToken (user_id, token, expires_at, created_at)
            VALUES (@UserId, @Token, @ExpiresAt, @CreatedAt);
            SELECT CAST(SCOPE_IDENTITY() AS INT);";
        return await connection.ExecuteScalarAsync<int>(sql, new { UserId = userId, Token = token, ExpiresAt = expiresAt, CreatedAt = DateTime.UtcNow });
    }

    public async Task<RefreshToken?> GetRefreshTokenAsync(string token)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"
            SELECT id AS Id, user_id AS UserId, token AS Token, expires_at AS ExpiresAt,
                   created_at AS CreatedAt, revoked_at AS RevokedAt, replaced_by_token AS ReplacedByToken
            FROM RefreshToken WHERE token = @Token";
        return await connection.QuerySingleOrDefaultAsync<RefreshToken>(sql, new { Token = token });
    }

    public async Task<bool> RevokeRefreshTokenAsync(string token, string? replacedByToken = null)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"UPDATE RefreshToken SET revoked_at = @RevokedAt, replaced_by_token = @ReplacedByToken WHERE token = @Token";
        var rows = await connection.ExecuteAsync(sql, new { Token = token, RevokedAt = DateTime.UtcNow, ReplacedByToken = replacedByToken });
        return rows > 0;
    }

    public async Task<bool> RevokeAllUserRefreshTokensAsync(int userId)
    {
        using var connection = _connectionFactory.CreateConnection();
        const string sql = @"UPDATE RefreshToken SET revoked_at = @RevokedAt WHERE user_id = @UserId AND revoked_at IS NULL";
        var rows = await connection.ExecuteAsync(sql, new { UserId = userId, RevokedAt = DateTime.UtcNow });
        return rows > 0;
    }
}
