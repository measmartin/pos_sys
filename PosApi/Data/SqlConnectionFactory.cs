using Microsoft.Data.SqlClient;
using System.Data;

namespace PosApi.Data;

public class SqlConnectionFactory : IDatabaseConnectionFactory
{
    private readonly string _connectionString;

    public SqlConnectionFactory(string connectionString)
    {
        _connectionString = connectionString;
    }

    public IDbConnection CreateConnection()
    {
        return new SqlConnection(_connectionString);
    }
}
