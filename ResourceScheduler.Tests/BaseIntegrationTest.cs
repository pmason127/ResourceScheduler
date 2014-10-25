using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using ResourceScheduler.Scheduling.Internal.Data;

namespace ResourceScheduler.Tests
{
    [TestFixture]
   public class BaseIntegrationTest
    {
        [TestFixtureTearDown]
        public void TearDown()
        {
           // return;
            var scm = new SqlConnectionManager();
            using (SqlConnection conn = scm.GetSqlConnection())
            {
                using (SqlCommand cmd = new SqlCommand())
                {
                    cmd.Connection = conn;
                    cmd.CommandType = CommandType.Text;
                    conn.Open();
                    cmd.CommandText = @"
DELETE FROM rs_Schedule_ScheduleOwner;
DELETE FROM rs_Schedule_Occurrence;
DELETE FROM rs_Schedule_Event;
DELETE FROM rs_Schedule_Schedule";
                    cmd.ExecuteNonQuery();
                    conn.Close();

                }
            }
        }
    }
}
