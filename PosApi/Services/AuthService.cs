using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using Microsoft.IdentityModel.Tokens;
using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Services;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        IUserRepository userRepository,
        IConfiguration configuration,
        ILogger<AuthService> logger)
    {
        _userRepository = userRepository;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<AuthResponseDto> LoginAsync(LoginDto dto)
    {
        var user = await _userRepository.GetByUsernameAsync(dto.Username);
        if (user == null || !user.IsActive)
        {
            _logger.LogWarning("Login failed for user {Username}: user not found or inactive", dto.Username);
            throw new UnauthorizedAccessException("Invalid username or password");
        }

        if (!VerifyPassword(dto.Password, user.PasswordHash))
        {
            _logger.LogWarning("Login failed for user {Username}: invalid password", dto.Username);
            throw new UnauthorizedAccessException("Invalid username or password");
        }

        await _userRepository.UpdateLastLoginAsync(user.UserId);

        var token = GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();
        var expiresIn = _configuration.GetValue<int>("Jwt:ExpiresInMinutes", 60);
        var refreshTokenExpiryDays = _configuration.GetValue<int>("Jwt:RefreshTokenExpiryDays", 7);

        await _userRepository.CreateRefreshTokenAsync(user.UserId, refreshToken, DateTime.UtcNow.AddDays(refreshTokenExpiryDays));

        return new AuthResponseDto
        {
            Token = token,
            RefreshToken = refreshToken,
            TokenType = "Bearer",
            ExpiresIn = expiresIn * 60,
            User = MapToUserDto(user)
        };
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterDto dto)
    {
        ValidatePasswordStrength(dto.Password);

        if (await _userRepository.ExistsAsync(dto.Username))
        {
            throw new InvalidOperationException($"Username '{dto.Username}' is already taken");
        }

        if (!string.IsNullOrEmpty(dto.Email))
        {
            var existing = await _userRepository.GetByEmailAsync(dto.Email);
            if (existing != null)
            {
                throw new InvalidOperationException($"Email '{dto.Email}' is already registered");
            }
        }

        var user = new User
        {
            Username = dto.Username,
            PasswordHash = HashPassword(dto.Password),
            Email = dto.Email,
            DisplayName = dto.DisplayName,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var userId = await _userRepository.CreateAsync(user);
        user.UserId = userId;

        var token = GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();
        var expiresIn = _configuration.GetValue<int>("Jwt:ExpiresInMinutes", 60);
        var refreshTokenExpiryDays = _configuration.GetValue<int>("Jwt:RefreshTokenExpiryDays", 7);

        await _userRepository.CreateRefreshTokenAsync(user.UserId, refreshToken, DateTime.UtcNow.AddDays(refreshTokenExpiryDays));

        _logger.LogInformation("User registered successfully: {Username}", dto.Username);

        return new AuthResponseDto
        {
            Token = token,
            RefreshToken = refreshToken,
            TokenType = "Bearer",
            ExpiresIn = expiresIn * 60,
            User = MapToUserDto(user)
        };
    }

    public async Task<AuthResponseDto?> RefreshTokenAsync(string refreshToken)
    {
        var token = await _userRepository.GetRefreshTokenAsync(refreshToken);
        if (token == null || token.RevokedAt != null || token.ExpiresAt < DateTime.UtcNow)
        {
            _logger.LogWarning("Invalid or expired refresh token attempted");
            return null;
        }

        var user = await _userRepository.GetByIdAsync(token.UserId);
        if (user == null || !user.IsActive)
        {
            _logger.LogWarning("Refresh token user not found or inactive: {UserId}", token.UserId);
            return null;
        }

        // Revoke old token and generate new one
        var newRefreshToken = GenerateRefreshToken();
        var expiresIn = _configuration.GetValue<int>("Jwt:ExpiresInMinutes", 60);
        var refreshTokenExpiryDays = _configuration.GetValue<int>("Jwt:RefreshTokenExpiryDays", 7);

        await _userRepository.RevokeRefreshTokenAsync(refreshToken, newRefreshToken);
        await _userRepository.CreateRefreshTokenAsync(user.UserId, newRefreshToken, DateTime.UtcNow.AddDays(refreshTokenExpiryDays));

        var newToken = GenerateJwtToken(user);

        return new AuthResponseDto
        {
            Token = newToken,
            RefreshToken = newRefreshToken,
            TokenType = "Bearer",
            ExpiresIn = expiresIn * 60,
            User = MapToUserDto(user)
        };
    }

    public async Task<bool> ChangePasswordAsync(int userId, ChangePasswordDto dto)
    {
        ValidatePasswordStrength(dto.NewPassword);

        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null)
        {
            return false;
        }

        if (!VerifyPassword(dto.CurrentPassword, user.PasswordHash))
        {
            throw new UnauthorizedAccessException("Current password is incorrect");
        }

        var newHash = HashPassword(dto.NewPassword);
        var result = await _userRepository.ChangePasswordAsync(userId, newHash);

        if (result)
        {
            // Revoke all refresh tokens for this user after password change
            await _userRepository.RevokeAllUserRefreshTokensAsync(userId);
        }

        return result;
    }

    public async Task<UserDto?> GetCurrentUserAsync(int userId)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        return user == null ? null : MapToUserDto(user);
    }

    private string GenerateJwtToken(User user)
    {
        var key = Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!);
        var expiresIn = _configuration.GetValue<int>("Jwt:ExpiresInMinutes", 60);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Email, user.Email ?? string.Empty),
            new Claim("display_name", user.DisplayName ?? string.Empty)
        };

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.UtcNow.AddMinutes(expiresIn),
            Issuer = _configuration["Jwt:Issuer"],
            Audience = _configuration["Jwt:Audience"],
            SigningCredentials = new SigningCredentials(
                new SymmetricSecurityKey(key),
                SecurityAlgorithms.HmacSha256Signature)
        };

        var tokenHandler = new JwtSecurityTokenHandler();
        var token = tokenHandler.CreateToken(tokenDescriptor);
        return tokenHandler.WriteToken(token);
    }

    private static string GenerateRefreshToken()
    {
        var randomBytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomBytes);
        return Convert.ToBase64String(randomBytes);
    }

    private static void ValidatePasswordStrength(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
            throw new InvalidOperationException("Password is required.");

        if (password.Length < 8)
            throw new InvalidOperationException("Password must be at least 8 characters long.");

        if (!Regex.IsMatch(password, @"[a-zA-Z]"))
            throw new InvalidOperationException("Password must contain at least one letter.");

        if (!Regex.IsMatch(password, @"[0-9]"))
            throw new InvalidOperationException("Password must contain at least one number.");
    }

    private static UserDto MapToUserDto(User user)
    {
        return new UserDto
        {
            UserId = user.UserId,
            Username = user.Username,
            Email = user.Email,
            DisplayName = user.DisplayName,
            IsActive = user.IsActive,
            LastLoginAt = user.LastLoginAt
        };
    }

    private static string HashPassword(string password)
    {
        byte[] salt = new byte[16];
        RandomNumberGenerator.Fill(salt);

        var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
        byte[] hash = pbkdf2.GetBytes(32);

        byte[] hashBytes = new byte[48];
        Array.Copy(salt, 0, hashBytes, 0, 16);
        Array.Copy(hash, 0, hashBytes, 16, 32);

        return Convert.ToBase64String(hashBytes);
    }

    private static bool VerifyPassword(string password, string storedHash)
    {
        byte[] hashBytes = Convert.FromBase64String(storedHash);
        byte[] salt = new byte[16];
        Array.Copy(hashBytes, 0, salt, 0, 16);

        var pbkdf2 = new Rfc2898DeriveBytes(password, salt, 100000, HashAlgorithmName.SHA256);
        byte[] hash = pbkdf2.GetBytes(32);

        for (int i = 0; i < 32; i++)
        {
            if (hashBytes[i + 16] != hash[i])
                return false;
        }
        return true;
    }
}
