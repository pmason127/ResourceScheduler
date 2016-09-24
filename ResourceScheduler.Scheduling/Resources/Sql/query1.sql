select e.Id,Identifier,Title,ISNULL(x.Id,0) as NotExcludedDayOfWeekName,f.calendarDate from
te_Calendar_CalendarEvent e
cross apply
ufnExpandDates(coalesce(e.SequenceStartUtc,e.StartDateUtc)
				,coalesce(e.SequenceEndUtc,e.EndDateUtc)
				,e.RecurrenceType
				,e.RecurrenceInterval
				,e.RecurrenceDays,0,0,e.Id) f
inner join Calendar c on f.calendarDate = c.CalendarDate
left outer join te_Calendar_CalendarEventExclusion x on x.StartDateUtc = f.calendarDate
order by f.calendarDate