using FluentAssertions;
using PosApi.DTOs;
using System.Net;
using System.Net.Http.Json;

namespace PosApi.Tests;

public class AuthTests : IntegrationTestBase
{
    [Fact]
    public async Task Register_Returns_Token_And_User()
    {
        var client = Factory.CreateClient();
        var dto = new RegisterDto
        {
            Username = "auth_user_" + Guid.NewGuid().ToString("N").Substring(0, 8),
            Password = "StrongPass1!",
            DisplayName = "Auth Test User"
        };

        var response = await client.PostAsJsonAsync("/api/auth/register", dto);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var auth = await response.Content.ReadFromJsonAsync<AuthResponseDto>();
        auth.Should().NotBeNull();
        auth!.Token.Should().NotBeNullOrEmpty();
        auth.RefreshToken.Should().NotBeNullOrEmpty();
        auth.User.Username.Should().Be(dto.Username);
    }

    [Fact]
    public async Task Register_Rejects_Duplicate_Username()
    {
        var client = Factory.CreateClient();
        var username = "dup_user_" + Guid.NewGuid().ToString("N").Substring(0, 8);
        var dto = new RegisterDto { Username = username, Password = "StrongPass1!" };

        var first = await client.PostAsJsonAsync("/api/auth/register", dto);
        first.EnsureSuccessStatusCode();

        var second = await client.PostAsJsonAsync("/api/auth/register", dto);
        second.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Register_Rejects_Weak_Password()
    {
        var client = Factory.CreateClient();
        var dto = new RegisterDto
        {
            Username = "weak_" + Guid.NewGuid().ToString("N").Substring(0, 8),
            Password = "short"
        };

        var response = await client.PostAsJsonAsync("/api/auth/register", dto);
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Register_Rejects_Short_Password()
    {
        var client = Factory.CreateClient();
        var dto = new RegisterDto
        {
            Username = "short_" + Guid.NewGuid().ToString("N").Substring(0, 8),
            Password = "Ab1"
        };

        var response = await client.PostAsJsonAsync("/api/auth/register", dto);
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Login_With_Valid_Credentials_Returns_Token()
    {
        var client = Factory.CreateClient();
        var username = "login_user_" + Guid.NewGuid().ToString("N").Substring(0, 8);
        var password = "TestPass123!";

        var registerDto = new RegisterDto { Username = username, Password = password };
        var regResponse = await client.PostAsJsonAsync("/api/auth/register", registerDto);
        regResponse.EnsureSuccessStatusCode();

        var loginDto = new LoginDto { Username = username, Password = password };
        var loginResponse = await client.PostAsJsonAsync("/api/auth/login", loginDto);

        loginResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var auth = await loginResponse.Content.ReadFromJsonAsync<AuthResponseDto>();
        auth!.Token.Should().NotBeNullOrEmpty();
        auth.User.Username.Should().Be(username);
    }

    [Fact]
    public async Task Login_With_Invalid_Password_Returns_401()
    {
        var client = Factory.CreateClient();
        var username = "badpw_" + Guid.NewGuid().ToString("N").Substring(0, 8);

        var registerDto = new RegisterDto { Username = username, Password = "CorrectPass1!" };
        await client.PostAsJsonAsync("/api/auth/register", registerDto);

        var loginDto = new LoginDto { Username = username, Password = "WrongPass999!" };
        var response = await client.PostAsJsonAsync("/api/auth/login", loginDto);

        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Login_With_Nonexistent_User_Returns_401()
    {
        var client = Factory.CreateClient();
        var loginDto = new LoginDto { Username = "nonexistent_" + Guid.NewGuid(), Password = "TestPass1!" };

        var response = await client.PostAsJsonAsync("/api/auth/login", loginDto);
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task Refresh_Token_Returns_New_Tokens()
    {
        var client = Factory.CreateClient();
        var username = "refresh_" + Guid.NewGuid().ToString("N").Substring(0, 8);

        var registerDto = new RegisterDto { Username = username, Password = "TestPass123!" };
        var regResponse = await client.PostAsJsonAsync("/api/auth/register", registerDto);
        var auth = await regResponse.Content.ReadFromJsonAsync<AuthResponseDto>();

        var refreshDto = new RefreshTokenDto { RefreshToken = auth!.RefreshToken };
        var refreshResponse = await client.PostAsJsonAsync("/api/auth/refresh", refreshDto);

        refreshResponse.StatusCode.Should().Be(HttpStatusCode.OK);
        var newAuth = await refreshResponse.Content.ReadFromJsonAsync<AuthResponseDto>();
        newAuth!.Token.Should().NotBeNullOrEmpty();
        newAuth.RefreshToken.Should().NotBeNullOrEmpty();
        newAuth.Token.Should().NotBe(auth.Token);
    }

    [Fact]
    public async Task Refresh_Token_Rejects_Invalid_Token()
    {
        var client = Factory.CreateClient();
        var refreshDto = new RefreshTokenDto { RefreshToken = "invalid-token-value" };

        var response = await client.PostAsJsonAsync("/api/auth/refresh", refreshDto);
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task GetMe_Returns_Current_User()
    {
        var client = await GetAuthenticatedClientAsync();

        var response = await client.GetAsync("/api/auth/me");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var user = await response.Content.ReadFromJsonAsync<UserDto>();
        user.Should().NotBeNull();
        user!.Username.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task GetMe_Returns_401_Without_Token()
    {
        var client = Factory.CreateClient();

        var response = await client.GetAsync("/api/auth/me");
        response.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ChangePassword_Works()
    {
        var client = await GetAuthenticatedClientAsync();
        var changeDto = new ChangePasswordDto
        {
            CurrentPassword = "Password123!",
            NewPassword = "NewPass456!"
        };

        var response = await client.PostAsJsonAsync("/api/auth/change-password", changeDto);
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);

        // Old password should no longer work
        var me = await client.GetAsync("/api/auth/me");
        me.EnsureSuccessStatusCode();

        // Create a new client and try logging in with old password
        var newClient = Factory.CreateClient();
        var loginDto = new LoginDto
        {
            Username = (await me.Content.ReadFromJsonAsync<UserDto>())!.Username,
            Password = "Password123!"
        };
        var oldLogin = await newClient.PostAsJsonAsync("/api/auth/login", loginDto);
        oldLogin.StatusCode.Should().Be(HttpStatusCode.Unauthorized);
    }

    [Fact]
    public async Task ChangePassword_Rejects_Wrong_Current_Password()
    {
        var client = await GetAuthenticatedClientAsync();
        var changeDto = new ChangePasswordDto
        {
            CurrentPassword = "WrongCurrent1!",
            NewPassword = "NewPass456!"
        };

        var response = await client.PostAsJsonAsync("/api/auth/change-password", changeDto);
        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
}
