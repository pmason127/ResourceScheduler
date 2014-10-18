using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ResourceScheduler.Scheduling.Internal.Entities
{
    public class Occurrence
    {
        public  Guid Id { get; set; }
        public Guid EventId { get; set; }
        public DateTime  StartUtc { get; set; }
        public DateTime  EndUtc { get; set; }
        public bool IsException { get; set; }

    }
}
