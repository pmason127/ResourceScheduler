using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ResourceScheduler.Scheduling.Internal.Entities;
using SharedResources.Common;

namespace ResourceScheduler.Scheduling.Internal.Data.Implementations
{
    public class ScheduleEventSqlRepository : IScheduleEventRepository
    {
        private ISqlConnectionManager _connection;
        public ScheduleEventSqlRepository(ISqlConnectionManager connectionManager)
        {
            _connection = connectionManager;
        }

        public void Create(Entities.ScheduleEvent scheduleEvent)
        {
            using (SqlConnection conn = _connection.GetSqlConnection())
            {
                using (SqlCommand cmd = _connection.GetSprocCommand("rs_Scheduling_Event_Create", conn))
                {
                    conn.Open();
                    cmd.Parameters.Add("@EventId", SqlDbType.UniqueIdentifier).Direction = ParameterDirection.Output;
                    cmd.Parameters.Add("@ScheduleId", SqlDbType.UniqueIdentifier).Value = scheduleEvent.ScheduleId;
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 256).Value = scheduleEvent.Name;
                    cmd.Parameters.Add("@Description", SqlDbType.NVarChar).Value = scheduleEvent.Description;
                    cmd.Parameters.Add("@TimeZoneId", SqlDbType.NVarChar, 128).Value = scheduleEvent.TimeZoneId;
                    cmd.Parameters.Add("@CreateDateUtc", SqlDbType.DateTime).Value = scheduleEvent.CreateDateUtc;
                    cmd.Parameters.Add("@OccurrenceStartUtc", SqlDbType.DateTime).Value = scheduleEvent.StartUtc;
                    cmd.Parameters.Add("@OccurrenceEndUtc", SqlDbType.DateTime).Value = scheduleEvent.EndUtc;
                    cmd.Parameters.Add("@AllDay", SqlDbType.Bit).Value = scheduleEvent.IsAllDay;

                    if (scheduleEvent.RecurrenceType != RecurrenceType.None)
                        cmd.Parameters.Add("@RecurrenceType", SqlDbType.SmallInt).Value = Convert.ToInt16(scheduleEvent.RecurrenceType);

                    if (scheduleEvent.RecurrenceEnd.HasValue)
                        cmd.Parameters.Add("@RecurrenceEnd", SqlDbType.DateTime).Value = scheduleEvent.RecurrenceEnd.Value;

                    if (scheduleEvent.BusinessDaysOnly.HasValue)
                        cmd.Parameters.Add("@BusinessDaysOnly", SqlDbType.Bit).Value = scheduleEvent.BusinessDaysOnly.Value;

                    if (scheduleEvent.RecurrenceDays != null && scheduleEvent.RecurrenceDays.Length > 0)
                        cmd.Parameters.Add("@RecurrenceDays", SqlDbType.NVarChar, 7).Value = string.Join("", scheduleEvent.RecurrenceDays);

                    if (scheduleEvent.RecurrenceInterval.HasValue)
                        cmd.Parameters.Add("@RecurrenceInterval", SqlDbType.SmallInt).Value = scheduleEvent.RecurrenceInterval.Value;

                    cmd.ExecuteNonQuery();

                    scheduleEvent.Id = (Guid)cmd.Parameters["@EventId"].Value;
                    conn.Close();

                }
            }
        }


        public void Delete(Guid scheduleEventId)
        {
            using (SqlConnection conn = _connection.GetSqlConnection())
            {
                using (SqlCommand cmd = _connection.GetSprocCommand("rs_Scheduling_Event_Delete", conn))
                {
                    conn.Open();
                    cmd.Parameters.Add("@EventId", SqlDbType.UniqueIdentifier).Value = scheduleEventId;
                    cmd.ExecuteNonQuery();
                    conn.Close();

                }
            }
        }


        public void Update(Entities.ScheduleEvent scheduleEvent, bool updateSeries)
        {
            throw new NotImplementedException();
        }

        public IList<Entities.ScheduleEvent> GetEvents(DateTime startdateUtc, DateTime endDateUtc, ScheduleEventQuery additionalOptions)
        {
            if (additionalOptions == null)
                additionalOptions = new ScheduleEventQuery();

            List<ScheduleEvent> events = new List<ScheduleEvent>();
            using (SqlConnection conn = _connection.GetSqlConnection())
            {
                using (SqlCommand cmd = _connection.GetSprocCommand("rs_Scheduling_Event_GetEvents", conn))
                {


                    cmd.Parameters.Add("@StartDateUtc", SqlDbType.DateTime).Value = startdateUtc;
                    cmd.Parameters.Add("@EndDateUtc", SqlDbType.DateTime).Value = endDateUtc;

                    if (additionalOptions.ScheduleId.HasValue)
                        cmd.Parameters.Add("@ScheduleId", SqlDbType.UniqueIdentifier).Value = additionalOptions.ScheduleId.Value;

                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            events.Add(Populate(reader));
                        }
                    }


                    conn.Close();

                }
            }
            return events;
        }
        private ScheduleEvent Populate(IDataReader rdr)
        {
            var ev = new ScheduleEvent()
                         {
                             Id = rdr.GetGuidColumn("EventId")
                             ,
                             OccurrenceId = rdr.GetGuidColumn("OccurrenceId")
                             ,
                             ScheduleId = rdr.GetGuidColumn("ScheduleId")
                             ,
                             Name = rdr.GetStringColumn("Name")
                             ,
                             Description = rdr.GetStringColumn("Description")
                             ,
                             RecurrenceType = (RecurrenceType)rdr.GetSafeInt16Column("RecurrenceType", 0)
                             ,
                             RecurrenceInterval = rdr.GetSafeInt16Column("RecurrenceInterval", null)
                             ,
                             StartUtc = rdr.GetDateTimeColumn("OccurrenceStartUtc")
                             ,
                             EndUtc = rdr.GetDateTimeColumn("OccurrenceEndUtc")
                             ,
                             CreateDateUtc = rdr.GetDateTimeColumn("CreateDateUtc")
                             ,
                             TimeZoneId = rdr.GetStringColumn("TimeZoneId")
                             ,
                             IsAllDay = rdr.GetBoolColumn("AllDay")
                             ,
                             IsCancelled = rdr.GetBoolColumn("IsCancelled")
                             ,
                             IsException = rdr.GetBoolColumn("IsException")
                         };

            var days = rdr.GetSafeStringColumn("RecurrenceDays", null);
            if (!string.IsNullOrEmpty(days))
                ev.RecurrenceDays = days.ToArray().Select(s => (int)s).ToArray();

            return ev;
        }


        public ScheduleEvent Get(Guid occurrenceId)
        {
            ScheduleEvent scheduleEvent = null;
            using (SqlConnection conn = _connection.GetSqlConnection())
            {
                using (SqlCommand cmd = _connection.GetSprocCommand("rs_Scheduling_Event_GetEvent", conn))
                {
                    cmd.Parameters.Add("@OccurrenceId", SqlDbType.UniqueIdentifier).Value = occurrenceId;

                    conn.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            scheduleEvent = Populate(reader);
                        }
                    }


                    conn.Close();

                }
            }
            return scheduleEvent;
        }
    }
}
