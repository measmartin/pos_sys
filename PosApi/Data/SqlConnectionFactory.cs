using Microsoft.Data.SqlClient;
using System.Data;

namespace PosApi.Data;

public class SqlConnectionFactory : IDatabaseConnectionFactory
{
    private readonly string _connectionString;
    private readonly SqlRetryLogicBaseProvider _retryProvider;

    public SqlConnectionFactory(string connectionString)
    {
        _connectionString = connectionString;
        
        // Configure retry logic for transient errors
        var options = new SqlRetryLogicOption()
        {
            NumberOfTries = 3,
            DeltaTime = TimeSpan.FromSeconds(1),
            MaxTimeInterval = TimeSpan.FromSeconds(10),
            TransientErrors = new int[] { 40613, 40197, 40501, 49918, 49919, 49920, 11001, -2, 121 }
        };
        _retryProvider = SqlConfigurableRetryFactory.CreateExponentialRetryProvider(options);
    }

    public IDbConnection CreateConnection()
    {
        var connection = new SqlConnection(_connectionString);
        connection.RetryLogicProvider = _retryProvider;
        return connection;
    }

    public IDbConnection CreateConnection(string connectionString)
    {
        var connection = new SqlConnection(connectionString);
        connection.RetryLogicProvider = _retryProvider;
        return connection;
    }

    public async Task<T> ExecuteWithTransactionAsync<T>(Func<IDbConnection, IDbTransaction, Task<T>> action)
    {
        using var connection = CreateConnection();
        connection.Open();
        using var transaction = connection.BeginTransaction();
        try
        {
            var result = await action(connection, transaction);
            transaction.Commit();
            return result;
        }
        catch
        {
            transaction.Rollback();
            throw;
        }
    }

    public async Task ExecuteWithTransactionAsync(Func<IDbConnection, IDbTransaction, Task> action)
    {
        using var connection = CreateConnection();
        connection.Open();
        using var transaction = connection.BeginTransaction();
        try
        {
            await action(connection, transaction);
            transaction.Commit();
        }
        catch
        {
            transaction.Rollback();
            throw;
        }
    }
}
