using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ResourceScheduler.Scheduling.Internal.Entities;

namespace ResourceScheduler.Scheduling.Internal.Data
{
    public interface IScheduleRepository
    {
        void Create(Schedule schedule);
        void Delete(Guid scheduleId);
    }
}
