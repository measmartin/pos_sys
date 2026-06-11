using FluentAssertions;
using Microsoft.Extensions.DependencyInjection;
using PosApi.Data;
using PosApi.DTOs;
using System.Net;
using System.Net.Http.Json;

namespace PosApi.Tests;

public class SalesConcurrencyTests : IntegrationTestBase
{
    [Fact]
    public async Task Void_Sale_Works()
    {
        var client = await GetAuthenticatedClientAsync();
        var categoryId = await SeedCategoryAsync("Void Cat " + Guid.NewGuid().ToString("N")[..4]);
        var unitId = await SeedUnitAsync("Void Unit " + Guid.NewGuid().ToString("N")[..4], "VU" + Guid.NewGuid().ToString("N")[..2]);
        var productId = await SeedProductAsync("VP-" + Guid.NewGuid().ToString("N")[..8], "Void Product", categoryId, unitId);
        var productUnitId = await SeedProductUnitAsync(productId, unitId, 1, 50);
        var currencyId = await SeedCurrencyAsync("VV" + Guid.NewGuid().ToString("N")[..1].ToUpper(), "V$");

        var createDto = new CreateSalesDto
        {
            SaleDate = DateTime.Now,
            PhoneNumber = "1112223333",
            CurrencyId = currencyId,
            AmountPaid = 50,
            PaymentStatus = "PAID",
            SaleStatus = "COMPLETED",
            Items = new List<CreateSalesItemDto>
            {
                new() { ProductId = productId, ProductUnitId = productUnitId, Quantity = 1, UnitPrice = 50 }
            }
        };

        var createResponse = await client.PostAsJsonAsync("/api/sales", createDto);
        createResponse.EnsureSuccessStatusCode();
        var saleId = await createResponse.Content.ReadFromJsonAsync<int>();

        var voidResponse = await client.PostAsJsonAsync($"/api/sales/{saleId}/void", new { });
        voidResponse.StatusCode.Should().Be(HttpStatusCode.NoContent);

        var getResponse = await client.GetAsync($"/api/sales/{saleId}");
        var sale = await getResponse.Content.ReadFromJsonAsync<SalesDetailsDto>();
        sale!.SaleStatus.Should().Be("VOIDED");
        sale.AmountPaid.Should().Be(0);
    }

    [Fact]
    public async Task Process_Payment_Rejects_Underpayment_For_Paid_Status()
    {
        var client = await GetAuthenticatedClientAsync();
        var categoryId = await SeedCategoryAsync("Pay Cat " + Guid.NewGuid().ToString("N")[..4]);
        var unitId = await SeedUnitAsync("Pay Unit " + Guid.NewGuid().ToString("N")[..4], "PU" + Guid.NewGuid().ToString("N")[..2]);
        var productId = await SeedProductAsync("PP-" + Guid.NewGuid().ToString("N")[..8], "Pay Product", categoryId, unitId);
        var productUnitId = await SeedProductUnitAsync(productId, unitId, 1, 100);
        var currencyId = await SeedCurrencyAsync("PY" + Guid.NewGuid().ToString("N")[..1].ToUpper(), "P$");

        var createDto = new CreateSalesDto
        {
            SaleDate = DateTime.Now,
            PhoneNumber = "4445556666",
            CurrencyId = currencyId,
            AmountPaid = 0,
            PaymentStatus = "UNPAID",
            SaleStatus = "COMPLETED",
            Items = new List<CreateSalesItemDto>
            {
                new() { ProductId = productId, ProductUnitId = productUnitId, Quantity = 1, UnitPrice = 100 }
            }
        };

        var createResponse = await client.PostAsJsonAsync("/api/sales", createDto);
        createResponse.EnsureSuccessStatusCode();
        var saleId = await createResponse.Content.ReadFromJsonAsync<int>();

        var paymentDto = new ProcessPaymentDto
        {
            PaymentStatus = "PAID",
            AmountPaid = 50,
            ChangeAmount = 0
        };

        var payResponse = await client.PostAsJsonAsync($"/api/sales/{saleId}/payment", paymentDto);
        payResponse.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }

    [Fact]
    public async Task Sale_Numbers_Are_Unique_Concurrently()
    {
        var client = await GetAuthenticatedClientAsync();
        var categoryId = await SeedCategoryAsync("Conc Cat " + Guid.NewGuid().ToString("N")[..4]);
        var unitId = await SeedUnitAsync("Conc Unit " + Guid.NewGuid().ToString("N")[..4], "CU" + Guid.NewGuid().ToString("N")[..2]);
        var productId = await SeedProductAsync("CP-" + Guid.NewGuid().ToString("N")[..8], "Conc Product", categoryId, unitId);
        var productUnitId = await SeedProductUnitAsync(productId, unitId, 1, 25);
        var currencyId = await SeedCurrencyAsync("CN" + Guid.NewGuid().ToString("N")[..1].ToUpper(), "C$");

        var tasks = Enumerable.Range(0, 5).Select(i =>
        {
            var c = Factory.CreateClient();
            c.DefaultRequestHeaders.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer",
                    client.DefaultRequestHeaders.Authorization?.Parameter);

            var dto = new CreateSalesDto
            {
                SaleDate = DateTime.Now,
                PhoneNumber = $"555{i}000000",
                CurrencyId = currencyId,
                AmountPaid = 25,
                PaymentStatus = "PAID",
                SaleStatus = "COMPLETED",
                Items = new List<CreateSalesItemDto>
                {
                    new() { ProductId = productId, ProductUnitId = productUnitId, Quantity = 1, UnitPrice = 25 }
                }
            };
            return c.PostAsJsonAsync("/api/sales", dto);
        });

        var responses = await Task.WhenAll(tasks);

        foreach (var response in responses)
        {
            response.StatusCode.Should().Be(HttpStatusCode.Created);
        }

        var saleNumbers = new HashSet<string>();
        foreach (var response in responses)
        {
            var id = await response.Content.ReadFromJsonAsync<int>();
            var getResp = await client.GetAsync($"/api/sales/{id}");
            var sale = await getResp.Content.ReadFromJsonAsync<SalesDetailsDto>();
            saleNumbers.Add(sale!.SaleNumber);
        }

        saleNumbers.Should().HaveCount(5, "all sale numbers must be unique");
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
            ProductCode = code, ProductName = name,
            CategoryId = categoryId, BaseUnitId = baseUnitId, IsActive = true
        });
    }

    private async Task<int> SeedProductUnitAsync(int productId, int unitId, decimal conversionRate, decimal price)
    {
        using var scope = Factory.Services.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<IProductUnitRepository>();
        return await repo.CreateAsync(new PosApi.Models.ProductUnit
        {
            ProductId = productId, UnitId = unitId,
            ConversionRate = conversionRate, Price = price, IsActive = true, IsDefault = true
        });
    }

    private async Task<int> SeedCurrencyAsync(string code, string symbol)
    {
        using var scope = Factory.Services.CreateScope();
        var repo = scope.ServiceProvider.GetRequiredService<ICurrencyRepository>();
        return await repo.CreateAsync(new PosApi.Models.Currency
        {
            CurrencyCode = code, CurrencySymbol = symbol, CurrencyName = code, IsActive = true
        });
    }
}
