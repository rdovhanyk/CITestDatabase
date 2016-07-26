CREATE procedure [etl].[Load_DimDate]
as
begin
	set datefirst 1;

	declare @startDate datetimeoffset = TODATETIMEOFFSET(dateadd(dd, 1, dbo.GetLastDateFromDimDate()), 0);
	
	declare @yearsCount tinyint;
	select @yearsCount = cast(SettingValue as tinyint) from dbo.Settings where SettingName = 'YearsCountToPopulate';

	declare @endDate datetimeoffset;

	if datediff(mm, @startDate, getdate()) >= -1
		begin
			if datediff(yy, @startDate, getdate()) - @yearsCount <= 0
				set @endDate = dateadd(yy, @yearsCount, @startDate)
			else
				set @endDate = dateadd(yy, datediff(yy, @startDate, getdate()) + @yearsCount, @startDate)
		end
	else
		set @endDate = dateadd(dd, -1, @startDate);

	while @startDate <= @endDate
	begin
		insert into [dbo].[DimDate]
				([DateKey]
				,[FullDate]
				,[DayOfWeek]
				,[DayNumInMonth]
				,[DayName]
				,[DayAbbrev]
				,[WeekdayFlag]
				,[WeekNumInYear]
				,[Month]
				,[MonthName]
				,[MonthAbbrev]
				,[Quarter]
				,[Year]
				,[Yearmo])
		select  
				REPLACE(REPLACE(CONVERT(nvarchar(13), @startDate, 120), '-', ''), ' ', ''),
				@startDate as 'Full_Date', 
				DATEPART (weekday, @startDate) as 'Day_Of_Week',
				DATEPART (d, @startDate) as 'Day_Num_In_Month',
				DATENAME (dw, @startDate) as 'Day_Name',
				LEFT (DATENAME (dw, @startDate), 3) 'Day_Abbrev',
				case when DATEPART (dw, @startDate) < 6 then 'y' else 'n' end as 'Weekday_Flag',
				DATEPART (ww, @startDate) as 'Week_Num_In_Year',
				MONTH(@startDate) as 'Month',
				DATENAME (mm, @startDate) as 'Month_Name',
				LEFT(DATENAME (mm, @startDate), 3) as 'Month_Abbrev',
				DATEPART(qq, @startDate) as 'Quarter',
				YEAR(@startDate) as 'Year',
				REPLACE (LEFT (CONVERT(nvarchar, @startDate, 102), 7), '.', '') as 'Yearmo'
		set @startDate = DATEADD (hour, 1, @startDate)
	end
end