using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;

namespace ResourceScheduler.Scheduling.Internal.Data.Implementations
{
    public class ScheduleSqlRepository:IScheduleRepository 
    {
        

        public void Create(Entities.Schedule schedule)
        {
            using (SqlConnection conn = DataUtility.GetSqlConnection())
            {
                using (SqlCommand cmd = DataUtility.GetSprocCommand("rs_Scheduling_Schedule_Create", conn))
                {
                    conn.Open();
                    cmd.Parameters.Add("@ScheduleId", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 256).Value = schedule.Name;

                    if(!string.IsNullOrEmpty(schedule.Description))
                        cmd.Parameters.Add("@Description", SqlDbType.NVarChar).Value = schedule.Description;

                    cmd.Parameters.Add("@CreateDateUtc", SqlDbType.DateTime).Value = schedule.CreateDateUtc;


                    cmd.ExecuteNonQuery();

                    schedule.Id = (Guid)cmd.Parameters["@ScheduleId"].Value;
                    conn.Close();

                }
            }
        }


        public void Delete(Guid scheduleId)
        {
            using (SqlConnection conn = DataUtility.GetSqlConnection())
            {
                using (SqlCommand cmd = DataUtility.GetSprocCommand("rs_Scheduling_Schedule_Delete", conn))
                {
                    conn.Open();
                    cmd.Parameters.Add("@ScheduleId", SqlDbType.UniqueIdentifier).Value = scheduleId;
                    cmd.ExecuteNonQuery();
                    conn.Close();

                }
            }
        }


    }
}
