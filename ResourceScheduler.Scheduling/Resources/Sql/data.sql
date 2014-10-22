
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Numbers')
BEGIN
TRUNCATE TABLE [dbo].[Numbers];
WITH t1 AS (SELECT 0 AS n UNION ALL SELECT 0 UNION ALL SELECT 0 UNION ALL SELECT 0)
      ,t2 AS (SELECT 0 AS n FROM t1 t1a, t1 t1b, t1 t1c, t1 t1d)
      ,t3 AS (SELECT 0 AS n FROM t2 t2a, t2 t2b, t2 t2c)
      ,numbers AS (SELECT ROW_NUMBER() OVER(ORDER BY n) - 1 AS number FROM t3)
      INSERT INTO dbo.Numbers WITH (TABLOCKX) (
            Number
            )
            SELECT number
            FROM numbers
 WHERE number < 1000000;
END
GO


IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'Calendar' AND TABLE_NAME='Numbers')
BEGIN
TRUNCATE TABLE [dbo].[Calendar];
--load dates 2000-01-01 through 2025-12-31
WITH t1 AS (SELECT 0 AS n UNION ALL SELECT 0 UNION ALL SELECT 0 UNION ALL SELECT 0)
      ,t2 AS (SELECT 0 AS n FROM t1 t1a, t1 t1b, t1 t1c, t1 t1d)
      ,t3 AS (SELECT 0 AS n FROM t2 t2a, t2 t2b)
      ,numbers AS (SELECT ROW_NUMBER() OVER(ORDER BY n) - 1 AS number FROM t3)
INSERT INTO dbo.Calendar WITH (TABLOCKX) (
      CalendarDate
      ,CalendarYear
      ,CalendarMonth
      ,CalendarDay
      ,DayOfWeekName
      ,FirstDateOfWeek
      ,LastDateOfWeek
      ,FirstDateOfMonth
      ,LastDateOfMonth
      ,FirstDateOfQuarter
      ,LastDateOfQuarter
      ,FirstDateOfYear
      ,LastDateOfYear
      ,BusinessDay
      ,NonBusinessDay
      ,Weekend
      ,Holiday
      ,Weekday
      ,CalendarDateDescription
      )
SELECT
      CalendarDate = DATEADD(day, number, '20000101')
      ,CalendarYear = DATEPART(year, DATEADD(day, number, '20000101'))
      ,CalendarMonth = DATEPART(month, DATEADD(day, number, '20000101'))
      ,CalendarDay = DATEPART(day, DATEADD(day, number, '20000101'))
      ,DayOfWeekName = DATENAME(weekday, DATEADD(day, number, '20000101'))
      ,FirstDateOfWeek = DATEADD(day,-(DATEPART(weekday ,DATEADD(day, number, '20000101'))-1),DATEADD(day, number, '20000101'))
      ,LastDateOfWeek = DATEADD(day,-(DATEPART(weekday ,DATEADD(day, number, '20000101'))-1)+6,DATEADD(day, number, '20000101'))
      ,FirstDateOfMonth = DATEADD(month, DATEDIFF(month,'20000101',DATEADD(day, number, '20000101')), '20000101')
      ,LastDateOfMonth = DATEADD(day,-1,DATEADD(month,0,DATEADD(month,DATEDIFF(month,'20000101',DATEADD(day, number, '20000101'))+1,'20000101')))
      ,FirstDateOfQuarter = DATEADD(quarter, DATEDIFF(quarter,'20000101',DATEADD(day, number, '20000101')), '20000101')
      ,LastDateOfQuarter = DATEADD(day, -1, DATEADD(quarter, DATEDIFF(quarter,'20000101',DATEADD(day, number, '20000101'))+1, '20000101'))
      ,FirstDateOfYear = DATEADD(year, DATEDIFF(year,'20000101',DATEADD(day, number, '20000101')), '20000101')
      ,LastDateOfYear = DATEADD(day,-1,DATEADD(year, DATEDIFF(year,'20000101',DATEADD(day, number, '20000101'))+1, '20000101'))
      --initially set all weekdays as business days
      ,BusinessDay = CASE WHEN DATENAME(weekday, DATEADD(day, number, '20000101')) IN('Monday','Tuesday','Wednesday','Thursday','Friday') THEN 1 ELSE 0 END
      --initially set only weekends as non-business days
      ,NonBusinessDay = CASE WHEN DATENAME(weekday, DATEADD(day, number, '20000101')) IN('Saturday','Sunday') THEN 1 ELSE 0 END
      ,Weekend = CASE WHEN DATENAME(weekday, DATEADD(day, number, '20000101')) IN('Saturday','Sunday') THEN 1 ELSE 0 END
      ,Holiday = 0 --initially no holidays
      ,Weekday = CASE WHEN DATENAME(weekday, DATEADD(day, number, '20000101')) IN('Monday','Tuesday','Wednesday','Thursday','Friday') THEN 1 ELSE 0 END
      ,CalendarDateDescription = NULL
FROM numbers
WHERE number < 9497;
 
--New Year's Day
UPDATE dbo.calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'New Year''s Day'
WHERE
    CalendarMonth = 1
    AND CalendarDay = 1;
 
--New Year's Day celebrated on Friday, December 31 when January 1 falls on Saturday
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
    ,CalendarDateDescription = 'New Year''s Day Celebrated'
WHERE
    CalendarMonth = 12
    AND CalendarDay = 31
    AND DayOfWeekName = 'Friday';
   
--New Year's Day celebrated on Monday, January 2 when January 1 falls on Sunday
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
    ,CalendarDateDescription = 'New Year''s Day Celebrated'
WHERE
    CalendarMonth = 1
    AND CalendarDay = 2
    AND DayOfWeekName = 'Monday';   
 
--Martin Luther King Day - 3rd Monday in January
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Martin Luther King Day'
WHERE
    CalendarMonth = 1
    AND DayOfWeekName = 'Monday'
    AND (SELECT COUNT(*)
            FROM dbo.Calendar c2
        WHERE
            c2.CalendarDate <= Calendar.CalendarDate
            AND c2.CalendarYear = Calendar.CalendarYear
            AND c2.CalendarMonth = Calendar.CalendarMonth
            AND c2.DayOfWeekName = 'Monday'
        ) = 3;
 
--President's Day - 3rd Monday in February
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'President''s Day'
WHERE
    CalendarMonth = 2
    AND DayOfWeekName = 'Monday'
    AND (SELECT COUNT(*)
            FROM dbo.Calendar c2
        WHERE
            c2.CalendarDate <= Calendar.CalendarDate
            AND c2.CalendarYear = Calendar.CalendarYear
            AND c2.CalendarMonth = Calendar.CalendarMonth
            AND c2.DayOfWeekName = 'Monday'
        ) = 3;
       
--Easter - first Sunday after the full moon following the vernal (March 21) equinox
UPDATE dbo.Calendar
SET
      Holiday = 1
    ,CalendarDateDescription = 'Easter'
WHERE
    CalendarDate IN(
        '20000423'
        ,'20010415'
        ,'20020331'
        ,'20030420'
        ,'20040411'
        ,'20050327'
        ,'20060416'
        ,'20070408'
        ,'20080323'
        ,'20090412'
        ,'20100404'
        ,'20110424'
        ,'20120408'
        ,'20130331'
        ,'20140420'
        ,'20150405'
        ,'20160427'
        ,'20170416'
        ,'20180401'
        ,'20190421'
        ,'20200412'
        ,'20210404'
        ,'20220417'
        ,'20230409'
        ,'20240331'
        ,'20250420'
    );
 
--Good Friday - 2 days before Easter Sunday
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Good Friday'
WHERE
    CalendarDate IN(
        SELECT DATEADD(day, -2, c2.CalendarDate)
        FROM dbo.Calendar c2
        WHERE c2.CalendarDateDescription = 'Easter'
        );
 
--Memorial Day - last Monday in May
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Memorial Day'
WHERE
    CalendarMonth = 5
    AND DayOfWeekName = 'Monday'
    AND CalendarDate IN(
        SELECT MAX(c2.CalendarDate)
        FROM dbo.Calendar c2
        WHERE
            c2.CalendarYear = Calendar.CalendarYear
            AND c2.CalendarMonth = 5
            AND c2.DayOfWeekName = 'Monday'
        );
 
--Independence Day - July 4th
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Independence Day'
WHERE
    CalendarMonth = 7
    AND CalendarDay = 4;
 
--Independence Day celebrated on Friday, July 3 when July 4 falls on a Saturday
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
    ,CalendarDateDescription = 'Independence Day Celebrated'
WHERE
    CalendarMonth = 7
    AND CalendarDay = 3
    AND DayOfWeekName = 'Friday';
 
--Independence Day celebrated on Friday, July 3 when July 4 falls on a Saturday
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
    ,CalendarDateDescription = 'Independence Day Celebrated'
WHERE
    CalendarMonth = 7
    AND CalendarDay = 5
    AND DayOfWeekName = 'Monday';
       
--Labor Day - first Monday in September
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Labor Day'
WHERE
    CalendarMonth = 9
    AND DayOfWeekName = 'Monday'
    AND CalendarDate IN(
        SELECT MIN(c2.CalendarDate)
        FROM dbo.Calendar c2
        WHERE
            c2.CalendarYear = calendar.CalendarYear
            AND c2.CalendarMonth = 9
            AND c2.DayOfWeekName = 'Monday'
        );
 
--Columbus Day - second Monday in October
UPDATE dbo.Calendar
SET
      Holiday = 1
    ,CalendarDateDescription = 'Columbus Day'
WHERE
    CalendarMonth = 10
    AND DayOfWeekName = 'Monday'
    AND (SELECT COUNT(*)
            FROM dbo.Calendar c2
        WHERE
            c2.CalendarDate <= Calendar.CalendarDate
            AND c2.CalendarYear = Calendar.CalendarYear
            AND c2.CalendarMonth = Calendar.CalendarMonth
            AND c2.DayOfWeekName = 'Monday'
        ) = 2;
 
--Veteran's Day - November 11
UPDATE dbo.Calendar
SET
      Holiday = 1
    ,CalendarDateDescription = 'Veteran''s Day'
WHERE
    CalendarMonth = 11
    AND CalendarDay = 11;
 
--Thanksgiving - fourth Thursday in November
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Thanksgiving'
WHERE
    CalendarMonth = 11
    AND DayOfWeekName = 'Thursday'
 
    AND (SELECT COUNT(*) FROM
            dbo.Calendar c2
        WHERE
            c2.CalendarDate <= Calendar.CalendarDate
            AND c2.CalendarYear = Calendar.CalendarYear
            AND c2.CalendarMonth = Calendar.CalendarMonth
            AND c2.DayOfWeekName = 'Thursday'
        ) = 4;
       
--Day after Thanksgiving - fourth Friday in November
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Day after Thanksgiving'
WHERE
    CalendarMonth = 11
    AND DayOfWeekName = 'Friday'
    AND (SELECT COUNT(*)
            FROM dbo.Calendar c2
        WHERE
            c2.CalendarDate <= Calendar.CalendarDate
            AND c2.CalendarYear = Calendar.CalendarYear
            AND c2.CalendarMonth = Calendar.CalendarMonth
            AND c2.DayOfWeekName = 'Friday'
        ) = 4;       
       
--Christmas Day - December 25th
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
      ,Holiday = 1
    ,CalendarDateDescription = 'Christmas Day'
WHERE
    CalendarMonth = 12
    AND CalendarDay = 25;
 
--Christmas day celebrated on Friday, December 24 when December 25 falls on a Saturday
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
    ,CalendarDateDescription = 'Christmas Day Celebrated'
WHERE
    CalendarMonth = 12
    AND CalendarDay = 24
    AND DayOfWeekName = 'Friday';
 
--Christmas day celebrated on Monday, December 24 when December 25 falls on a Sunday
UPDATE dbo.Calendar
SET
      BusinessDay = 0
      ,NonBusinessDay = 1
    ,CalendarDateDescription = 'Christmas Day Celebrated'
WHERE
    CalendarMonth = 12
    AND CalendarDay = 26
    AND DayOfWeekName = 'Monday';


UPDATE Calendar
SET [DayofWeek] =(case
when DayOfWeekName ='Sunday' then 0
when DayOfWeekName ='Monday' then 1
when DayOfWeekName ='Tuesday' then 2
when DayOfWeekName ='Wednesday' then 3
when DayOfWeekName ='Thursday' then 4
when DayOfWeekName ='Friday' then 5
when DayOfWeekName ='Saturday' then 6
        end)
        
UPDATE Calendar
SET DayOrdinal =(case
     when CalendarDay >= 1 and CalendarDay <= 7 then 1
        when CalendarDay >= 8 and CalendarDay <= 14 then 2
        when CalendarDay >= 15 and CalendarDay <= 21 then 3
        when CalendarDay >= 22 and CalendarDay <= 28 then 4
        else 5
        end)

update Calendar set WkNo = DATEPART(week,CalendarDate)
END