﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using ResourceScheduler.Scheduling;
using ResourceScheduler.Scheduling.Internal.Data;
using ResourceScheduler.Scheduling.Internal.Data.Implementations;
using ResourceScheduler.Scheduling.Internal.Entities;

namespace ResourceScheduler.Tests.Integration
{
    public class EventCreate:BaseIntegrationTest
    {
        private IScheduleRepository _scheduleRepo = null;
        private Schedule _schedule;
        private IScheduleEventRepository _eventRepo;

        [TestFixtureSetUp]
        public void Setup()
        {
            ISqlConnectionManager mgr = new SqlConnectionManager();
            _scheduleRepo = new ScheduleSqlRepository(mgr);
            _eventRepo = new ScheduleEventSqlRepository(mgr);

            _schedule = new Schedule(){Name = "Test",Description = "TestDesc",CreateDateUtc = DateTime.UtcNow};
            _scheduleRepo.Create(_schedule);
        }

        [Test]
        public void create_single_event()
        {
            ScheduleEvent ev = new ScheduleEvent()
            {
                IsAllDay = false,
                CreateDateUtc = DateTime.UtcNow,
                Description = "Test event",
                IsCancelled = false,
                StartUtc = DateTime.UtcNow.AddDays(2),
                EndUtc = DateTime.UtcNow.AddDays(2).AddHours(1),
                Name = "Sample Event",
                RecurrenceType = RecurrenceType.None,
                TimeZoneId = TimeZoneInfo.Local.Id,
                ScheduleId = _schedule.Id.Value
            };
            _eventRepo.Create(ev);
            Assert.IsTrue(ev.Id.HasValue);
        }
        [Test]
        public void create_event_weekly_on_day()
        {
            var start = new DateTime(2014, 10, 23, 10, 00, 00, DateTimeKind.Utc);
            var end = new DateTime(2014, 10, 23, 11, 00, 00, DateTimeKind.Utc);
            var rend = new DateTime(2014, 12, 4, 11, 00, 00, DateTimeKind.Utc);
            ScheduleEvent ev = new ScheduleEvent()
            {
                IsAllDay = false,
                CreateDateUtc = DateTime.UtcNow,
                Description = "Test event",
                IsCancelled = false,
                StartUtc = start,
                EndUtc =end,
                Name = "Sample Event",
                RecurrenceType = RecurrenceType.Weekly,
                RecurrenceDays = new []{4},
                TimeZoneId = TimeZoneInfo.Local.Id,
                RecurrenceInterval =1,
                ScheduleId = _schedule.Id.Value,
                RecurrenceEnd = rend
            };
            _eventRepo.Create(ev);
            Assert.IsTrue(ev.Id.HasValue);

            var events = _eventRepo.GetEvents(start, rend, null);
            Assert.AreEqual(7,events.Count);
        }
    }
}
