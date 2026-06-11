using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using PosApi.Data;
using PosApi.DTOs;
using PosApi.Services;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.RegularExpressions;

namespace PosApi.Tests;

public class IntegrationTestBase : IDisposable
{
    protected readonly WebApplicationFactory<Program> Factory;
    protected readonly HttpClient Client;
    private readonly string _dbName;
    private readonly string _masterConnectionString = "Server=(localdb)\\MSSQLLocalDB;Integrated Security=true;TrustServerCertificate=True";
    private readonly string _connectionString;

    public IntegrationTestBase()
    {
        _dbName = $"TestDb_{Guid.NewGuid():N}";
        _connectionString = $"Server=(localdb)\\MSSQLLocalDB;Database={_dbName};Integrated Security=true;TrustServerCertificate=True";

        // Set environment variables to satisfy Program.cs validation
        Environment.SetEnvironmentVariable("ConnectionStrings__DefaultConnection", _connectionString);
        Environment.SetEnvironmentVariable("Jwt__Key", "ThisIsAVeryLongSecretKeyForTestingPurposesOnly123!");

        CreateDatabase();
        InitializeSchema();

        Factory = new WebApplicationFactory<Program>().WithWebHostBuilder(builder =>
        {
            builder.ConfigureAppConfiguration((context, config) =>
            {
                config.AddInMemoryCollection(new Dictionary<string, string?>
                {
                    ["ConnectionStrings:DefaultConnection"] = _connectionString,
                    ["Jwt:Key"] = "ThisIsAVeryLongSecretKeyForTestingPurposesOnly123!",
                    ["Jwt:Issuer"] = "PosApiTest",
                    ["Jwt:Audience"] = "PosApiTest",
                    ["Jwt:ExpiresInMinutes"] = "60"
                });
            });

            builder.ConfigureServices(services =>
            {
                // Replace the database connection factory
                services.RemoveAll<IDatabaseConnectionFactory>();
                services.AddSingleton<IDatabaseConnectionFactory>(new SqlConnectionFactory(_connectionString));
            });
        });

        Client = Factory.CreateClient();
    }

    protected async Task<HttpClient> GetAuthenticatedClientAsync()
    {
        var client = Factory.CreateClient();
        
        // Register a test user
        var registerDto = new RegisterDto
        {
            Username = "testuser_" + Guid.NewGuid().ToString("N").Substring(0, 8),
            Password = "Password123!",
            Email = "test@example.com",
            DisplayName = "Test User"
        };

        var response = await client.PostAsJsonAsync("/api/auth/register", registerDto);
        response.EnsureSuccessStatusCode();
        
        var authResponse = await response.Content.ReadFromJsonAsync<AuthResponseDto>();
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", authResponse!.Token);
        
        return client;
    }

    private void CreateDatabase()
    {
        using var connection = new SqlConnection(_masterConnectionString);
        connection.Open();
        using var command = new SqlCommand($"CREATE DATABASE [{_dbName}]", connection);
        command.ExecuteNonQuery();
    }

    private void InitializeSchema()
    {
        // Try to find database_design by walking up from AppContext.BaseDirectory
        var currentDir = new DirectoryInfo(AppContext.BaseDirectory);
        string? scriptsDir = null;

        while (currentDir != null)
        {
            var potentialPath = Path.Combine(currentDir.FullName, "database_design");
            if (Directory.Exists(potentialPath))
            {
                scriptsDir = potentialPath;
                break;
            }
            currentDir = currentDir.Parent;
        }

        if (scriptsDir == null)
        {
            // Fallback to CurrentDirectory
            var potentialPath = Path.Combine(Directory.GetCurrentDirectory(), "database_design");
            if (Directory.Exists(potentialPath))
            {
                scriptsDir = potentialPath;
            }
        }

        if (scriptsDir == null)
        {
            throw new DirectoryNotFoundException("Could not find 'database_design' directory.");
        }

        var scripts = Directory.GetFiles(scriptsDir, "*.sql").OrderBy(f => f);

        using var connection = new SqlConnection(_connectionString);
        connection.Open();

        foreach (var scriptPath in scripts)
        {
            var script = File.ReadAllText(scriptPath);
            ExecuteSqlScript(connection, script);
        }
    }

    private void ExecuteSqlScript(SqlConnection connection, string script)
    {
        // Strip USE statements
        script = Regex.Replace(script, @"^\s*USE\s+\[?\w+\]?;?\s*$", "", RegexOptions.Multiline | RegexOptions.IgnoreCase);

        // Split by GO if necessary, though SqlCommand doesn't support GO
        // Simple split by GO at start of line
        var commands = Regex.Split(script, @"^\s*GO\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase);
        foreach (var commandText in commands)
        {
            if (string.IsNullOrWhiteSpace(commandText)) continue;
            using var command = new SqlCommand(commandText, connection);
            command.ExecuteNonQuery();
        }
    }

    public void Dispose()
    {
        Client.Dispose();
        Factory.Dispose();
        DropDatabase();
    }

    private void DropDatabase()
    {
        try
        {
            using var connection = new SqlConnection(_masterConnectionString);
            connection.Open();
            // Kick off users and drop
            var sql = $@"
                ALTER DATABASE [{_dbName}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
                DROP DATABASE [{_dbName}];";
            using var command = new SqlCommand(sql, connection);
            command.ExecuteNonQuery();
        }
        catch
        {
            // Ignore errors during cleanup
        }
    }
}
