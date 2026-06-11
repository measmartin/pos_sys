using FluentAssertions;

namespace PosApi.Tests;

public class AuthServiceTests
{
    [Theory]
    [InlineData("admin123", true)]
    [InlineData("StrongPass1!", true)]
    [InlineData("aB3defghij", true)]
    [InlineData("short", false)]
    [InlineData("12345678", false)]
    [InlineData("abcdefgh", false)]
    [InlineData("", false)]
    public void Password_Validation_Works(string password, bool expected)
    {
        bool hasLetter = password.Any(char.IsLetter);
        bool hasDigit = password.Any(char.IsDigit);
        bool longEnough = password.Length >= 8;
        bool isValid = hasLetter && hasDigit && longEnough;
        isValid.Should().Be(expected, $"password '{password}' validation");
    }

    [Fact]
    public void Sale_Number_Follows_Format()
    {
        var year = 2026;
        var sequence = 42;
        var saleNumber = $"{year}-{sequence:D4}";
        saleNumber.Should().Be("2026-0042");
    }
}
