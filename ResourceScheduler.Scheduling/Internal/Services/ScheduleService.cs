using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ResourceScheduler.Scheduling.Internal.Data;
using ResourceScheduler.Scheduling.Internal.Entities;
using SharedResources.Common;

namespace ResourceScheduler.Scheduling.Internal.Services
{
    public interface IScheduleService
    {
        void Create(Schedule scheduleEvent);
        void Delete(Guid scheduleId);
    }


    public class ScheduleService:IScheduleService
    {
        private IScheduleRepository _scheduleRepository = null;
        public ScheduleService(IScheduleRepository scheduleReository)
        {
            _scheduleRepository = scheduleReository;
        }
        public void Create(Schedule schedule)
        {
            Validate(schedule);
            _scheduleRepository.Create(schedule);
        }

        public void Delete(Guid scheduleId)
        {
            _scheduleRepository.Delete(scheduleId);
        }

        #region Helpers
        private void Validate(Schedule schedule)
        {
            Validator.NotNull("schedule",schedule,"schedule cannot be null");
            Validator.NotIsNullOrWhitespace("Description",schedule.Description,"Description must be supplied");
        }
        #endregion
    }

}
