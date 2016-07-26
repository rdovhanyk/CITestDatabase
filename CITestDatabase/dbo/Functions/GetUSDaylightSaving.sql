CREATE FUNCTION dbo.GetUSDaylightSaving(@dt date)
RETURNS INT
AS
BEGIN

	--SET DATEFIRST 7

	DECLARE
		@year INT,
		@StartOfMarch DATETIME ,
		@StartOfNovember DATETIME ,
		@DstStart DATETIME ,
		@DstEnd DATETIME

	SET @year = year(@dt)
	SET @StartOfMarch = DATEADD(MONTH, 2, DATEADD(YEAR, @year - 1900, 0))
	SET @StartOfNovember = DATEADD(MONTH, 10, DATEADD(YEAR, @year - 1900, 0));
	SET @DstStart = DATEADD(HOUR, 2,
							DATEADD(day,
									( ( 15 - DATEPART(dw, @StartOfMarch) ) % 7 )
									+ 7, @StartOfMarch))
	SET @DstEnd = DATEADD(HOUR, 2,
						  DATEADD(day,
								  ( ( 8 - DATEPART(dw, @StartOfNovember) ) % 7 ),
								  @StartOfNovember))

	--select @DstStart, @DstEnd
	RETURN(SELECT CASE WHEN @dt BETWEEN @DstStart AND @DstEnd THEN -1 ELSE 0 END)

END