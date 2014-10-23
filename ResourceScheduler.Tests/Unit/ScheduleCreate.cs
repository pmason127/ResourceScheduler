using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Moq;
using NUnit.Framework;
using ResourceScheduler.Scheduling.Internal.Data;
using ResourceScheduler.Scheduling.Internal.Entities;
using ResourceScheduler.Scheduling.Internal.Services;

namespace ResourceScheduler.Tests.Unit
{
    [TestFixture]
    public class ScheduleCreate
    {
        private IScheduleService _service;
        private IScheduleRepository _repo;
        
        [TestFixtureSetUp]
        public void Setup()
        {
            var mock = new Mock<IScheduleRepository>();
            mock.Setup(r => r.Create(It.IsAny<Schedule>())).Callback<Schedule>((s)=>
            {
                s.Id = Guid.NewGuid();
                s.CreateDateUtc = DateTime.UtcNow;
            });

            _repo = mock.Object;
            _service = new ScheduleService(_repo);
        }

        [Test]
        public void name_is_required()
        {
            Schedule s = new Schedule()
            {
                Description = "Test"
            };

            var ex = Assert.Throws<ArgumentException>(() => _service.Create(s));
            Assert.AreEqual(ex.ParamName,"Name");

        }
        [Test]
        public void description_is_required()
        {
            Schedule s = new Schedule()
            {
                Name = "Test"
            };

            var ex = Assert.Throws<ArgumentException>(() => _service.Create(s));
            Assert.AreEqual(ex.ParamName, "Description");

        }
        [Test]
        public void schedule_is_required()
        {
            Schedule s = new Schedule()
            {
                Name = "Test",
                Description = "Test123"
            };

            _service.Create(s);
            Assert.IsTrue(s.Id.HasValue);

        }
    }
}
