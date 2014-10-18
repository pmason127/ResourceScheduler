IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rs_Schedule_Occurrence]') AND type in (N'U'))
BEGIN
DROP TABLE [rs_Schedule_Occurrence]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rs_Schedule_Event]') AND type in (N'U'))
BEGIN
DROP TABLE [rs_Schedule_Event]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Calendar]') AND type in (N'U'))
BEGIN
DROP TABLE [Calendar]
END
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Numbers]') AND type in (N'U'))
BEGIN
DROP TABLE [Numbers]
END
GO