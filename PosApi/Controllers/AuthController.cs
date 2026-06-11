using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Authorize]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, IConfiguration configuration, ILogger<AuthController> logger)
    {
        _authService = authService;
        _configuration = configuration;
        _logger = logger;
    }

    [HttpPost("login")]
    [AllowAnonymous]
    [EnableRateLimiting("Auth")]
    public async Task<ActionResult<AuthResponseDto>> Login([FromBody] LoginDto dto)
    {
        try
        {
            var result = await _authService.LoginAsync(dto);
            return Ok(result);
        }
        catch (UnauthorizedAccessException)
        {
            return Unauthorized(new { message = "Invalid username or password" });
        }
    }

    [HttpPost("register")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponseDto>> Register([FromBody] RegisterDto dto)
    {
        var enableRegistration = _configuration.GetValue<bool>("Auth:EnableRegistration", true);
        if (!enableRegistration)
        {
            _logger.LogWarning("Registration attempt blocked: registration is disabled.");
            return StatusCode(StatusCodes.Status403Forbidden, new { message = "Registration is disabled." });
        }

        if (!ModelState.IsValid)
        {
            return BadRequest(new { message = "Invalid input.", errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage) });
        }

        try
        {
            var result = await _authService.RegisterAsync(dto);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPost("refresh")]
    [AllowAnonymous]
    public async Task<ActionResult<AuthResponseDto>> RefreshToken([FromBody] RefreshTokenDto dto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new { message = "Invalid input.", errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage) });
        }

        var result = await _authService.RefreshTokenAsync(dto.RefreshToken);
        if (result == null)
        {
            return Unauthorized(new { message = "Invalid or expired refresh token." });
        }

        return Ok(result);
    }

    [HttpPost("change-password")]
    public async Task<ActionResult> ChangePassword([FromBody] ChangePasswordDto dto)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(new { message = "Invalid input.", errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage) });
        }

        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized();

        try
        {
            var result = await _authService.ChangePasswordAsync(int.Parse(userId), dto);
            if (!result)
                return NotFound(new { message = "User not found" });

            return NoContent();
        }
        catch (UnauthorizedAccessException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("me")]
    public async Task<ActionResult<UserDto>> GetCurrentUser()
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
            return Unauthorized();

        var user = await _authService.GetCurrentUserAsync(int.Parse(userId));
        if (user == null)
            return NotFound();

        return Ok(user);
    }
}
