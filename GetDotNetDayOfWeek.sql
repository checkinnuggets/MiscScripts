-- =============================================
-- Author:        @checkinnuggets
-- Create date: 2012-02-19
-- Description:    Function to retrieve numeric representation of the day of the
--                for a given date.
-- 
-- The problem faced was that:
--     a) The .NET DayOfWeek Enumeration runs 0-6 but T-SQL DayOfWeek values
--          run 1-7, so we always have to -1.
--       b) Depending on the regional settings of the database server, the values
--          SQL Server uses to represent a week day vary.  For example, in British
--        English 1 is Monday, but in US English 1 is Sunday.
--          The development database server is set to US English.  We don't know 
--          how any other server the application may be deployed to will be configured
-- =============================================
CREATE FUNCTION [dbo].[GetDotNetDayOfWeek]
(
    @checkDate    DATE
)
RETURNS TINYINT
AS
BEGIN
    -- First we just get the value SQL Server Value...
    DECLARE @dateVal TINYINT
    SET @dateVal = DATEPART(dw, @checkDate);
     
    -- Next, we must adjust based on the date setting    
    DECLARE @offset TINYINT
    SET @offset = @@DateFirst - 1;
     
     
    IF ( @dateVal + @offset < 7 )
        SET @dateVal = @dateVal + @offset
    ELSE
        SET @dateVal = @dateVal - ( 7 - @offset )
         
     
    IF @dateVal = 7
        SET @dateVal = 0;    -- .NET Runs 0-6 rather than 1-7
         
    RETURN @dateVal
END
GO