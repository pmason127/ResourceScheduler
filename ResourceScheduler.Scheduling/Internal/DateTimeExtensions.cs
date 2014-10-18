using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ResourceScheduler.Scheduling
{
    public static class DateTimeExtensions
    {
        public static DateTime ToUtcForTimezone(this DateTime givenDateTime, string systemTimeZoneId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(systemTimeZoneId);
            if (tz == null)
                return givenDateTime.ToUniversalTime();

            var newDate = TimeZoneInfo.ConvertTimeToUtc(givenDateTime,TimeZoneInfo.FindSystemTimeZoneById(systemTimeZoneId));
            return newDate;
        }
        public static DateTime ToTimezoneFromUtc(this DateTime givenDateTime, string systemTimeZoneId)
        {
            var tz = TimeZoneInfo.FindSystemTimeZoneById(systemTimeZoneId);
            if (tz == null)
                return givenDateTime;

            var newDate = TimeZoneInfo.ConvertTimeFromUtc(givenDateTime, TimeZoneInfo.FindSystemTimeZoneById(systemTimeZoneId));
            return newDate;
        }
    }
}
