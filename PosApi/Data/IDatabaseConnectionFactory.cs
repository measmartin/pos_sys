using System.Data;

namespace PosApi.Data;

public interface IDatabaseConnectionFactory
{
    IDbConnection CreateConnection();
}
