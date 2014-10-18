using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ResourceScheduler.Scheduling.Internal.Entities;

namespace ResourceScheduler.Scheduling.Internal.Data
{
    public class ScheduleEventQuery
    {
        public Guid? ScheduleId { get; set; }
    }

    public interface IScheduleEventRepository
    {
        void Create(ScheduleEvent scheduleEvent);
        void Update(ScheduleEvent scheduleEvent, bool updateSeries);
        void Delete(Guid scheduleEventId);
        IList<ScheduleEvent> GetEvents(DateTime startdateUtc, DateTime endDateUtc, ScheduleEventQuery additionalOptions);
        ScheduleEvent Get(Guid occurrenceId);
    }
}
