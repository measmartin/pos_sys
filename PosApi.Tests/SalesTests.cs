using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using PosApi.Data;
using PosApi.DTOs;
using System.Net;
using System.Net.Http.Json;

namespace PosApi.Tests;

public class SalesTests : IntegrationTestBase
{
    [Fact]
    public async Task Can_Create_Sale_Successfully()
    {
        // Arrange
        var client = await GetAuthenticatedClientAsync();

        // Seed data with unique names to avoid conflicts with sample data
        var categoryId = await SeedCategoryAsync("Test Electronics " + Guid.NewGuid().ToString("N").Substring(0, 4));
        var unitId = await SeedUnitAsync("Test Piece " + Guid.NewGuid().ToString("N").Substring(0, 4), "TPC" + Guid.NewGuid().ToString("N").Substring(0, 2));
        var productId = await SeedProductAsync("TPROD-" + Guid.NewGuid().ToString("N").Substring(0, 8), "Test Smartphone", categoryId, unitId);
        var productUnitId = await SeedProductUnitAsync(productId, unitId, 1, 1000);
        var currencyId = await SeedCurrencyAsync(Guid.NewGuid().ToString("N").Substring(0, 3).ToUpper(), "T$");

        var createSaleDto = new CreateSalesDto
        {
            SaleDate = DateTime.Now,
            PhoneNumber = "1234567890",
            CurrencyId = currencyId,
            AmountPaid = 1000,
            PaymentStatus = "PAID",
            SaleStatus = "COMPLETED",
            Items = new List<CreateSalesItemDto>
            {
                new CreateSalesItemDto
                {
                    ProductId = productId,
                    ProductUnitId = productUnitId,
                    Quantity = 1,
                    UnitPrice = 1000
                }
            }
        };

        // Act
        var response = await client.PostAsJsonAsync("/api/sales", createSaleDto);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var id = await response.Content.ReadFromJsonAsync<int>();
        id.Should().BeGreaterThan(0);

        // Verify sale was created by fetching it
        var getResponse = await client.GetAsync($"/api/sales/{id}");
        getResponse.EnsureSuccessStatusCode();
        var sale = await getResponse.Content.ReadFromJsonAsync<SalesDetailsDto>();
        
        sale.Should().NotBeNull();
        sale!.TotalAmount.Should().Be(1000);
        sale.Items.Should().HaveCount(1);
        sale.Items[0].ProductId.Should().Be(productId);
        sale.SaleNumber.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public async Task Can_Process_Payment_Successfully()
    {
        // Arrange
        var client = await GetAuthenticatedClientAsync();

        // Seed data with unique names
        var categoryId = await SeedCategoryAsync("Test Food " + Guid.NewGuid().ToString("N").Substring(0, 4));
        var unitId = await SeedUnitAsync("Test Box " + Guid.NewGuid().ToString("N").Substring(0, 4), "TBX" + Guid.NewGuid().ToString("N").Substring(0, 2));
        var productId = await SeedProductAsync("TPROD-" + Guid.NewGuid().ToString("N").Substring(0, 8), "Test Pizza", categoryId, unitId);
        var productUnitId = await SeedProductUnitAsync(productId, unitId, 1, 15);
        var currencyId = await SeedCurrencyAsync(Guid.NewGuid().ToString("N").Substring(0, 3).ToUpper(), "T$");

        var createSaleDto = new CreateSalesDto
        {
            SaleDate = DateTime.Now,
            PhoneNumber = "9876543210",
            CurrencyId = currencyId,
            AmountPaid = 0,
            PaymentStatus = "UNPAID",
            SaleStatus = "COMPLETED",
            Items = new List<CreateSalesItemDto>
            {
                new CreateSalesItemDto
                {
                    ProductId = productId,
                    ProductUnitId = productUnitId,
                    Quantity = 2,
                    UnitPrice = 15
                }
            }
        };

        var createResponse = await client.PostAsJsonAsync("/api/sales", createSaleDto);
        createResponse.EnsureSuccessStatusCode();
        var saleId = await createResponse.Content.ReadFromJsonAsync<int>();

        var processPaymentDto = new ProcessPaymentDto
        {
            PaymentStatus = "PAID",
            PaymentMethod = "Cash",
            AmountPaid = 30,
            ChangeAmount = 0
        };

        // Act
        var response = await client.PostAsJsonAsync($"/api/sales/{saleId}/payment", processPaymentDto);

        // Assert
        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
        
        // Verify payment status
        var getResponse = await client.GetAsync($"/api/sales/{saleId}");
        getResponse.EnsureSuccessStatusCode();
        var updatedSale = await getResponse.Content.ReadFromJsonAsync<SalesDetailsDto>();
        updatedSale!.PaymentStatus.Should().Be("PAID");
        updatedSale.AmountPaid.Should().Be(30);
    }

    private async Task<int> SeedCategoryAsync(string name)
    {
        using var scope = Factory.Services.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<ICategoryRepository>();
        return await repo.CreateAsync(new PosApi.Models.Category { CategoryName = name, IsActive = true });
    }

    private async Task<int> SeedUnitAsync(string name, string code)
    {
        using var scope = Factory.Services.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IUnitRepository>();
        return await repo.CreateAsync(new PosApi.Models.Unit { UnitName = name, UnitCode = code, IsActive = true });
    }

    private async Task<int> SeedProductAsync(string code, string name, int categoryId, int baseUnitId)
    {
        using var scope = Factory.Services.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IProductRepository>();
        return await repo.CreateAsync(new PosApi.Models.Product 
        { 
            ProductCode = code, 
            ProductName = name, 
            CategoryId = categoryId, 
            BaseUnitId = baseUnitId, 
            IsActive = true 
        });
    }

    private async Task<int> SeedProductUnitAsync(int productId, int unitId, decimal conversionRate, decimal price)
    {
        using var scope = Factory.Services.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IProductUnitRepository>();
        return await repo.CreateAsync(new PosApi.Models.ProductUnit 
        { 
            ProductId = productId, 
            UnitId = unitId, 
            ConversionRate = conversionRate, 
            Price = price, 
            IsActive = true,
            IsDefault = true
        });
    }

    private async Task<int> SeedCurrencyAsync(string code, string symbol)
    {
        using var scope = Factory.Services.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<ICurrencyRepository>();
        return await repo.CreateAsync(new PosApi.Models.Currency 
        { 
            CurrencyCode = code, 
            CurrencySymbol = symbol, 
            CurrencyName = code,
            IsActive = true 
        });
    }
}
