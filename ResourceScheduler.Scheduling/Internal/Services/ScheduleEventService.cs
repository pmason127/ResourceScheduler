using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ResourceScheduler.Scheduling.Internal.Data;
using ResourceScheduler.Scheduling.Internal.Entities;
using SharedResources.Common;

namespace ResourceScheduler.Scheduling.Internal.Services
{
    public interface IScheduleEventService
    {
        void Create(ScheduleEvent scheduleEvent);
        void Delete(Guid scheduleEventId);
        IList<ScheduleEvent> GetEvents(DateTime startdateUtc, DateTime endDateUtc, ScheduleEventQuery additionalOptions);
        ScheduleEvent Get(Guid occurrenceId);
    }

    public class ScheduleEventService:IScheduleEventService
    {
        private IScheduleEventRepository _scheduleEventRepository = null;
        public ScheduleEventService(IScheduleEventRepository scheduleEventRepository)
        {
            _scheduleEventRepository = scheduleEventRepository;
        }
        public ScheduleEvent Get(Guid occurrenceId)
        {
            return _scheduleEventRepository.Get(occurrenceId);
        }
        public void Create(ScheduleEvent scheduleEvent)
        {
            scheduleEvent.CreateDateUtc = DateTime.UtcNow;
            Validate(scheduleEvent);
            _scheduleEventRepository.Create(scheduleEvent);
        }

        public void Delete(Guid scheduleEventId)
        {
            _scheduleEventRepository.Delete(scheduleEventId);
        }
        public IList<ScheduleEvent> GetEvents(DateTime startdateUtc, DateTime endDateUtc, ScheduleEventQuery additionalOptions)
        {
            return _scheduleEventRepository.GetEvents(startdateUtc, endDateUtc, additionalOptions);
        }
        #region Helpers
        private void Validate(ScheduleEvent scheduleEvent)
        {
            Validator.NotNull("scheduleEvent", scheduleEvent, "scheduleEvent cannot be null");
            Validator.HasValue("StartUtc",scheduleEvent.StartUtc,"A start date is required");
            Validator.HasValue("EndUtc", scheduleEvent.StartUtc, "An end date is required");
            Validator.NotIsNullOrEmpty("ScheduleId", scheduleEvent.ScheduleId, "Events require a schedule Id");
            Validator.NotIsNullOrWhitespace("TimeZoneId", scheduleEvent.TimeZoneId, "A timezone is required");
            Validator.NotIsNullOrWhitespace("Description", scheduleEvent.Description, "A timezone is required");
            Validator.NotIsNullOrWhitespace("Name", scheduleEvent.Name, "A name is required");

            if(scheduleEvent.RecurrenceType != RecurrenceType.None)
            {
                Validator.HasValue("RecurrenceEnd", scheduleEvent.RecurrenceEnd,
                                   "System does not support non-ending patterns");

                if(DateTime.UtcNow.Subtract(scheduleEvent.RecurrenceEnd.Value).Days > 365)
                    throw new ArgumentException("Recurrence end must be less than a year");

                if(scheduleEvent.RecurrenceEnd.Value <= scheduleEvent.StartUtc)
                    throw new ArgumentException("Recurrence end must be greater than start date");

                if (scheduleEvent.RecurrenceEnd.Value <= scheduleEvent.EndUtc)
                    throw new ArgumentException("Recurrence end must be greater than end date");
            }

            if (scheduleEvent.EndUtc <= scheduleEvent.StartUtc)
                    throw new ArgumentException("end date cannot be before start date");
                
        }
        #endregion



    }
}
