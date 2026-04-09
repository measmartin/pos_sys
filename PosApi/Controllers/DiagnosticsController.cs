using Dapper;
using Microsoft.AspNetCore.Mvc;
using PosApi.Data;

namespace PosApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DiagnosticsController : ControllerBase
{
    private static readonly string[] RequiredTables =
    [
        "Category",
        "Unit",
        "Product",
        "ProductUnit",
        "Customer",
        "Currency",
        "Sales",
        "SalesItem"
    ];

    private readonly IDatabaseConnectionFactory _connectionFactory;

    public DiagnosticsController(IDatabaseConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    [HttpGet("connection")]
    public async Task<IActionResult> GetConnection()
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            connection.Open();

            var tableRows = await connection.QueryAsync<string>(
                "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'");
            var existingTables = tableRows.ToHashSet(StringComparer.OrdinalIgnoreCase);
            var missingTables = RequiredTables.Where(table => !existingTables.Contains(table)).ToArray();

            if (missingTables.Length > 0)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new
                {
                    ok = false,
                    message = "Database connection works, but required tables are missing.",
                    missingTables,
                    existingTables = existingTables.OrderBy(x => x).ToArray()
                });
            }

            return Ok(new
            {
                ok = true,
                message = "Database connection and schema look healthy.",
                database = connection.Database,
                provider = connection.GetType().FullName,
                tables = existingTables.OrderBy(x => x).ToArray()
            });
        }
        catch (Exception ex)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new
            {
                ok = false,
                message = ex.Message,
                exception = ex.GetType().Name
            });
        }
    }
}