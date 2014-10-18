using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ResourceScheduler.Scheduling.Internal.Entities
{
    public class ScheduleEvent
    {
        public Guid? Id { get; set; }
        public Guid? OccurrenceId { get; set; }
        public Guid ScheduleId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public RecurrenceType RecurrenceType { get; set; }
        public int[] RecurrenceDays { get; set; }
        public int? RecurrenceInterval { get; set; }
        public DateTime? RecurrenceEnd { get; set; }
        public DateTime StartUtc { get; set; }
        public DateTime EndUtc { get; set; }
        public DateTime CreateDateUtc { get; set; }
        public string TimeZoneId { get; set; }
        public bool IsAllDay { get; set; }
        public bool IsCancelled { get; set; }
        public bool IsException { get; set; }
        public bool? BusinessDaysOnly { get; set; }
      
    }
}
