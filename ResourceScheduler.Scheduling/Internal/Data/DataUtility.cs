using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace ResourceScheduler.Scheduling.Internal.Data
{
    public interface ISqlConnectionManager
    {
         SqlConnection  GetSqlConnection();
         SqlCommand GetSprocCommand(string commandText,SqlConnection conn);
    }

    public  class SqlConnectionManager : ISqlConnectionManager
    {
      

        public  SqlConnection  GetSqlConnection()
        {
            return new SqlConnection(System.Configuration.ConfigurationManager.ConnectionStrings["resources"].ConnectionString);
        }
        public  SqlCommand GetSprocCommand(string commandText,SqlConnection conn)
        {
            SqlCommand cmd = new SqlCommand(commandText);
            cmd.CommandTimeout = 120;
            cmd.Connection = conn;
            cmd.CommandType = CommandType.StoredProcedure;
            return cmd;
        }
        
    }
}
