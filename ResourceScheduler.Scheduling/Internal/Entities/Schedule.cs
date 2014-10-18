using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ResourceScheduler.Scheduling.Internal.Entities
{
    public class Schedule
    {
        public Guid? Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public DateTime CreateDateUtc { get; set; }
    }
}
