using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using ResourceScheduler.Scheduling.Internal.Data;
using ResourceScheduler.Scheduling.Internal.Data.Implementations;
using ResourceScheduler.Scheduling.Internal.Entities;

namespace ResourceScheduler.Tests.Integration
{
    public class ScheduleCreate:BaseIntegrationTest
    {
        private IScheduleRepository _repo;
        private DateTime _now;
        [TestFixtureSetUp]
        public void Setup()
        {
            _repo = new ScheduleSqlRepository(new SqlConnectionManager());
            _now = DateTime.UtcNow;
        }

        [Test]
        public void when_creating_schedule()
        {
            var schedule = new Schedule();
            schedule.CreateDateUtc = _now;
            schedule.Name = "Test_Schedule";
            schedule.Description = "Sample Schedule";

            _repo.Create(schedule);

            Assert.IsTrue(schedule.Id.HasValue);
        }
       
    }
}
