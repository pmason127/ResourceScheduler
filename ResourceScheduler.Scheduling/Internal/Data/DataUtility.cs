using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace ResourceScheduler.Scheduling.Internal.Data
{
    public static class DataUtility
    {
        public static string ConnectionString { get; set; }

        public static SqlConnection  GetSqlConnection()
        {
            return new SqlConnection(ConnectionString);
        }
        public static SqlCommand GetSprocCommand(string commandText,SqlConnection conn)
        {
            SqlCommand cmd = new SqlCommand(commandText);
            cmd.CommandTimeout = 120;
            cmd.Connection = conn;
            cmd.CommandType = CommandType.StoredProcedure;
            return cmd;
        }
        
    }
}
