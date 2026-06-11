using System.Data;

namespace PosApi.Data;

public interface IDatabaseConnectionFactory
{
    IDbConnection CreateConnection();
    IDbConnection CreateConnection(string connectionString);
    Task<T> ExecuteWithTransactionAsync<T>(Func<IDbConnection, IDbTransaction, Task<T>> action);
    Task ExecuteWithTransactionAsync(Func<IDbConnection, IDbTransaction, Task> action);
}
