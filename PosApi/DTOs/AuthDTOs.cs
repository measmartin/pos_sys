using System.ComponentModel.DataAnnotations;

namespace PosApi.DTOs;

public class RegisterDto
{
    [Required]
    [MinLength(3, ErrorMessage = "Username must be at least 3 characters.")]
    [MaxLength(50, ErrorMessage = "Username must be at most 50 characters.")]
    public string Username { get; set; } = string.Empty;

    [Required]
    [MinLength(8, ErrorMessage = "Password must be at least 8 characters.")]
    [MaxLength(100, ErrorMessage = "Password must be at most 100 characters.")]
    public string Password { get; set; } = string.Empty;

    [EmailAddress(ErrorMessage = "Invalid email address.")]
    [MaxLength(100, ErrorMessage = "Email must be at most 100 characters.")]
    public string? Email { get; set; }

    [MaxLength(100, ErrorMessage = "Display name must be at most 100 characters.")]
    public string? DisplayName { get; set; }
}

public class LoginDto
{
    [Required]
    [MinLength(3, ErrorMessage = "Username must be at least 3 characters.")]
    [MaxLength(50, ErrorMessage = "Username must be at most 50 characters.")]
    public string Username { get; set; } = string.Empty;

    [Required]
    [MinLength(8, ErrorMessage = "Password must be at least 8 characters.")]
    public string Password { get; set; } = string.Empty;
}

public class AuthResponseDto
{
    public string Token { get; set; } = string.Empty;
    public string RefreshToken { get; set; } = string.Empty;
    public string TokenType { get; set; } = "Bearer";
    public int ExpiresIn { get; set; }
    public UserDto User { get; set; } = new();
}

public class UserDto
{
    public int UserId { get; set; }
    public string Username { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? DisplayName { get; set; }
    public bool IsActive { get; set; }
    public DateTime? LastLoginAt { get; set; }
}

public class ChangePasswordDto
{
    [Required]
    public string CurrentPassword { get; set; } = string.Empty;

    [Required]
    [MinLength(8, ErrorMessage = "New password must be at least 8 characters.")]
    [MaxLength(100, ErrorMessage = "New password must be at most 100 characters.")]
    public string NewPassword { get; set; } = string.Empty;
}

public class RefreshTokenDto
{
    [Required]
    public string RefreshToken { get; set; } = string.Empty;
}
