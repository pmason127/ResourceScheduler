
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID(N'dbo.ufnExpandDates', N'TF') IS NOT NULL
    DROP FUNCTION dbo.ufnExpandDates;
GO
CREATE FUNCTION dbo.ufnExpandDates(
	@start datetime,
	@end datetime,
	@recurrenceType int = null,
	@recurrenceInterval int = NULL,
	@recurrenceDays varchar(7) = NULL,
	@businessDaysOnly bit = 0,
	@excludeHolidays bit =1,
	@identifier int = 1
	
)
RETURNS @dates TABLE 
(
    -- Columns returned by the function
	identifier int,
  calendarDate datetime
)
AS 

BEGIN

	--SELECT F.calendarDate,C.DayOfWeekName from ufnExpandDates(GETDATE(),DATEADD(YEAR,5,GETDATE()),3,1,'13',0,0) F
    --INNER JOIN Calendar C on C.CalendarDate = F.calendarDate

    DECLARE @cdate int,@cmonth int, @cyear int,@cweek int,@cwday int,@cordinal int
	SET @cdate = DATEPART(d,@start)
	SET @cmonth = DATEPART(m,@start)
	SET @cyear = DATEPART(d,@start)
	SET @cweek = DATEPART(WEEK,@start)
	SET @cwday = DATEPART ( dw , @start)-1
	--SELECT @start,@end,@cdate,@cmonth,@cyear,@cweek
	IF(@recurrenceType IS NULL)
	BEGIN
		INSERT INTO @dates
		SELECT @identifier,@start
	END
	ELSE IF(@recurrenceType = 1) -- daily
	BEGIN
		INSERT INTO @dates
		SELECT @identifier,t.CalendarDate
		FROM
		(
			SELECT CalendarDate,BusinessDay,Holiday,ROW_NUMBER() OVER (ORDER BY CalendarDate)  AS rownum
			FROM Calendar c
			WHERE CalendarDate >= convert(date,@start)
		    AND CalendarDate <= convert(date,@end)
		) AS t
		WHERE((t.rownum + (@recurrenceInterval-1)) % @recurrenceInterval = 0 ) 
		AND CalendarDate >= convert(date,@start)
		AND CalendarDate <= convert(date,@end)
		AND ((@businessDaysOnly IS NULL OR @businessDaysOnly =0) OR BusinessDay =@businessDaysOnly)
		AND ((@excludeHolidays IS NULL OR @excludeHolidays =0) OR Holiday =0)
		ORDER BY CalendarDate 
	END
	ELSE IF(@recurrenceType = 2) -- weekly
	BEGIN
		IF(@recurrenceDays IS NULL)
			BEGIN	
				INSERT INTO @dates
		        SELECT @identifier,c.CalendarDate
				FROM
				(
					SELECT Number,ROW_NUMBER() OVER (ORDER BY Number) AS rownum
					FROM Numbers
					WHERE Number >= @cweek
				) AS t
				INNER JOIN Calendar c on c.WkNo = t.Number
				WHERE((t.rownum + (@recurrenceInterval-1)) % @recurrenceInterval = 0 ) 
				AND [DayOfWeek] = @cwday
		        AND CalendarDate >= convert(date,@start)
		        AND CalendarDate <= convert(date,@end)
				AND ((@businessDaysOnly IS NULL OR @businessDaysOnly =0) OR BusinessDay =@businessDaysOnly)
				AND ((@excludeHolidays IS NULL OR @excludeHolidays =0) OR Holiday =0)
				ORDER BY CalendarDate 
			END
		ELSE
			BEGIN
				DECLARE @days TABLE(wday smallint NOT NULL)
				INSERT INTO @days
				SELECT SUBSTRING(a.b, v.number+1, 1) as wday
				FROM (SELECT @recurrenceDays b) a
				JOIN master..spt_values v on v.number < len(a.b)
				WHERE v.type = 'P'
			
				INSERT INTO @dates
		        SELECT @identifier,c.CalendarDate
				FROM
				(
					SELECT Number,ROW_NUMBER() OVER (ORDER BY Number) AS rownum
					FROM Numbers
					WHERE Number >= @cweek
				) AS t
				INNER JOIN Calendar c on c.WkNo = t.Number
				WHERE((t.rownum + (@recurrenceInterval-1)) % @recurrenceInterval = 0 ) 
				AND [DayOfWeek] IN(SELECT wday FROM @days)
		AND CalendarDate >= convert(date,@start)
		AND CalendarDate <= convert(date,@end)
				AND ((@businessDaysOnly IS NULL OR @businessDaysOnly =0) OR BusinessDay =@businessDaysOnly)
				AND ((@excludeHolidays IS NULL OR @excludeHolidays =0) OR Holiday =0)
				ORDER BY CalendarDate 
			END


	END
	ELSE IF(@recurrenceType = 3) -- monthly on day
	BEGIN
		INSERT INTO @dates
		SELECT @identifier,c.CalendarDate
		FROM
		(
			SELECT Number,ROW_NUMBER() OVER (ORDER BY Number) AS rownum
			FROM Numbers
			WHERE Number >= @cmonth
		) AS t
		INNER JOIN Calendar c on c.CalendarMonth = t.Number
		WHERE((t.rownum + (@recurrenceInterval-1)) % @recurrenceInterval = 0 ) 
		AND CalendarDay = @cdate 
		AND CalendarDate >= convert(date,@start)
		AND CalendarDate <= convert(date,@end)
		AND ((@businessDaysOnly IS NULL OR @businessDaysOnly =0) OR BusinessDay =@businessDaysOnly)
		AND ((@excludeHolidays IS NULL OR @excludeHolidays =0) OR Holiday =0)
		ORDER BY CalendarDate 
	END
	ELSE IF(@recurrenceType = 4) -- monthly on day of week
	BEGIN
		
		SET @cordinal =(CASE
					WHEN @cdate >= 1 and @cdate <= 7 then 1
					WHEN @cdate >= 8 and @cdate <= 14 then 2
					WHEN @cdate >= 15 and @cdate <= 21 then 3
					WHEN @cdate >= 22 and @cdate <= 28 then 4
					ELSE 5
			END)

		INSERT INTO @dates
		SELECT @identifier,c.CalendarDate
		FROM
		(
			SELECT Number,ROW_NUMBER() OVER (ORDER BY Number) AS rownum
			FROM Numbers
			WHERE Number >= @cmonth
		) AS t
		INNER JOIN Calendar c on c.CalendarMonth = t.Number
		WHERE((t.rownum + (@recurrenceInterval-1)) % @recurrenceInterval = 0 ) 
		AND DayOrdinal  = @cordinal
		AND [DayOfWeek] = @cwday
		AND CalendarDate >= convert(date,@start)
		AND CalendarDate <= convert(date,@end)
		AND ((@businessDaysOnly IS NULL OR @businessDaysOnly =0) OR BusinessDay =@businessDaysOnly)
		AND ((@excludeHolidays IS NULL OR @excludeHolidays =0) OR Holiday =0)
		ORDER BY CalendarDate 
	END
	ELSE IF(@recurrenceType = 5) --yearly
	BEGIN
		INSERT INTO @dates
		SELECT @identifier,c.CalendarDate
		FROM
		(
			SELECT Number,ROW_NUMBER() OVER (ORDER BY Number) AS rownum
			FROM Numbers
			WHERE Number >= @cyear
		) AS t
		INNER JOIN Calendar c on c.CalendarYear  = t.Number
		WHERE((t.rownum + (@recurrenceInterval-1)) % @recurrenceInterval = 0 ) 
		AND CalendarDay   = @cdate 
		AND CalendarMonth = @cmonth
		AND CalendarDate >= convert(date,@start)
		AND CalendarDate <= convert(date,@end)
		AND ((@businessDaysOnly IS NULL OR @businessDaysOnly =0) OR BusinessDay =@businessDaysOnly)
		AND ((@excludeHolidays IS NULL OR @excludeHolidays =0) OR Holiday =0)
		ORDER BY CalendarDate 
	END
    -- Return the information to the caller
  
    RETURN;
END;
GO

/*****************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rs_Scheduling_Event_Create]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [rs_Scheduling_Event_Create]
END
GO
CREATE PROCEDURE [dbo].[rs_Scheduling_Event_Create]
            @ScheduleId uniqueidentifier
           ,@Name nvarchar(256)
           ,@Description nvarchar(max)
           ,@RecurrenceType smallint = null
           ,@RecurrenceEnd datetime = null
		   ,@RecurrenceDays nvarchar(7) = null
		   ,@RecurrenceInterval smallint = null
           ,@TimeZoneId nvarchar(128)
           ,@CreateDateUtc datetime
           ,@OccurrenceStartUtc datetime
           ,@OccurrenceEndUtc datetime
           ,@AllDay bit
		   ,@BusinessDaysOnly bit = 0
           ,@EventId uniqueidentifier = null OUT

AS
BEGIN
	
	DECLARE @Err int
	IF(@EventId IS NULL)
		SET @EventId = NEWID()
		
BEGIN TRANSACTION 
	INSERT INTO [dbo].[rs_Schedule_Event]
           ([EventId]
           ,[ScheduleId]
           ,[Name]
           ,[Description]
           ,[RecurrenceType]
           ,[RecurrenceEnd]
		   ,[RecurrenceDays]
		   ,[RecurrenceInterval]
           ,[TimeZoneId]
           ,[CreateDateUtc]
		   ,[AllDay]
		   ,[BusinessDaysOnly])
     VALUES
           (@EventId
           ,@ScheduleId
           ,@Name
           ,@Description 
           ,@RecurrenceType
           ,@RecurrenceEnd
		   ,@RecurrenceDays
		   ,@RecurrenceInterval
           ,@TimeZoneId
           ,@CreateDateUtc
		   ,@AllDay
		   ,@BusinessDaysOnly)
     
     IF(@RecurrenceType IS NULL)
     BEGIN
		INSERT INTO [rs_Schedule_Occurrence](OccurrenceId,OccurrenceStartUtc,OccurrenceEndUtc,IsException,EventId,IsCancelled)
		VALUES(NEWID(),@OccurrenceStartUtc,@OccurrenceEndUtc,0,@EventId,0)
     END
	 ELSE
	 BEGIN
		DECLARE @time DATETIME, @duration int
        SET @time = CAST(@OccurrenceStartUtc as TIME)
		SET @duration = DATEDIFF(MI,@OccurrenceStartUtc,@OccurrenceEndUtc)
		

		INSERT INTO [rs_Schedule_Occurrence](OccurrenceId,OccurrenceStartUtc,OccurrenceEndUtc,IsException,EventId,IsCancelled)
		SELECT NEWID(),F.calendarDate + @time as OccurenceStatUtc,DATEADD(MI,@duration,F.calendarDate + @time),0,@EventId,0
		FROM ufnExpandDates(@OccurrenceStartUtc,@RecurrenceEnd,@RecurrenceType,@RecurrenceInterval,@RecurrenceDays,@BusinessDaysOnly,0) F
     END

	SET	@Err	=	@@ERROR
	IF	@Err	<>	0
	BEGIN
		ROLLBACK TRAN
		SET		@EventId	=	NULL
		RETURN
	END
	
	COMMIT TRAN
	

	
           
END
GO

GRANT EXECUTE ON [rs_Scheduling_Event_Create] TO PUBLIC
GO

/**********************************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rs_Scheduling_Schedule_Create]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [rs_Scheduling_Schedule_Create]
END
GO
CREATE PROCEDURE [dbo].[rs_Scheduling_Schedule_Create]
            @ScheduleId uniqueidentifier = NULL OUT
           ,@Name nvarchar(256)
           ,@Description nvarchar(max) = NULL
           ,@CreateDateUtc datetime

AS
BEGIN
	
	DECLARE @Err int
	IF(@ScheduleId IS NULL)
		SET @ScheduleId = NEWID()
		
BEGIN TRANSACTION 
	INSERT INTO [dbo].[rs_Schedule_Schedule]
           ( [ScheduleId]
           ,[Name]
           ,[Description]
           ,[CreateDateUtc])
     VALUES
           (@ScheduleId
           ,@Name
           ,@Description 
           ,@CreateDateUtc)
    

	SET	@Err	=	@@ERROR
	IF	@Err	<>	0
	BEGIN
		ROLLBACK TRAN
		SET		@ScheduleId	=	NULL
		RETURN
	END
	
	COMMIT TRAN
           
END
GO

GRANT EXECUTE ON [rs_Scheduling_Schedule_Create] TO PUBLIC
GO

/*********************************************************************/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rs_Scheduling_Schedule_Delete]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [rs_Scheduling_Schedule_Delete]
END
GO
CREATE PROCEDURE [dbo].[rs_Scheduling_Schedule_Delete]
            @ScheduleId uniqueidentifier
AS
BEGIN
	
DECLARE @Err int
	
		
BEGIN TRANSACTION 
	DELETE o 
		FROM rs_Schedule_Occurrence o
			INNER JOIN rs_Schedule_Event e on e.EventId = o.EventId
				AND e.ScheduleId = @ScheduleId
				
	DELETE FROM rs_Schedule_Event WHERE ScheduleId = @ScheduleId
	DELETE FROM rs_Schedule_Schedule WHERE ScheduleId = @ScheduleId
    

	SET	@Err	=	@@ERROR
	IF	@Err	<>	0
	BEGIN
		ROLLBACK TRAN
		RETURN
	END
	
	COMMIT TRAN
           
END
GO

GRANT EXECUTE ON [rs_Scheduling_Schedule_Delete] TO PUBLIC
GO
/**************************************************/

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rs_Scheduling_Event_GetEvents]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [rs_Scheduling_Event_GetEvents]
END
GO
CREATE PROCEDURE [dbo].[rs_Scheduling_Event_GetEvents]
             @StartDateUtc datetime
            ,@EndDateUtc datetime
            ,@ScheduleId uniqueidentifier = NULL
AS
BEGIN
	SELECT E.[EventId]
      ,[ScheduleId]
      ,[Name]
      ,[Description]
      ,[RecurrenceType]
      ,[RecurrenceEnd]
      ,[TimeZoneId]
      ,[CreateDateUtc]
      ,[AllDay]
      ,[RecurrenceInterval]
      ,[RecurrenceDays]
      ,[OccurrenceId]
      ,[OccurrenceStartUtc]
      ,[OccurrenceEndUtc]
      ,[IsException]
      ,[IsCancelled]
  FROM [rs_Schedule_Event] E
  INNER JOIN [rs_Schedule_Occurrence] O ON O.[EventId] = E.[EventID]
  WHERE ([OccurrenceStartUtc] >= @StartDateUtc or [OccurrenceEndUtc] >= @StartDateUtc) and ([OccurrenceEndUtc] <= @EndDateUtc or [OccurrenceStartUtc] <= @EndDateUtc)
  AND(@ScheduleId IS NULL OR [ScheduleId] = @ScheduleId)
  ORDER BY [OccurrenceStartUtc]
      
END
GO

GRANT EXECUTE ON [rs_Scheduling_Event_GetEvents] TO PUBLIC
GO
/*********************************************************/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rs_Scheduling_Event_GetEvent]') AND type in (N'P', N'PC'))
BEGIN
	DROP PROCEDURE [rs_Scheduling_Event_GetEvent]
END
GO
CREATE PROCEDURE [dbo].[rs_Scheduling_Event_GetEvent]
@OccurrenceId uniqueidentifier
AS
BEGIN
	SELECT E.[EventId]
      ,[ScheduleId]
      ,[Name]
      ,[Description]
      ,[RecurrenceType]
      ,[RecurrenceEnd]
      ,[TimeZoneId]
      ,[CreateDateUtc]
      ,[AllDay]
      ,[RecurrenceInterval]
      ,[RecurrenceDays]
      ,[OccurrenceId]
      ,[OccurrenceStartUtc]
      ,[OccurrenceEndUtc]
      ,[IsException]
      ,[IsCancelled]
  FROM [rs_Schedule_Event] E
  INNER JOIN [rs_Schedule_Occurrence] O ON O.[EventId] = E.[EventID]
 WHERE OccurrenceId = @OccurrenceId
      
END
GO

GRANT EXECUTE ON [rs_Scheduling_Event_GetEvent] TO PUBLIC
GO