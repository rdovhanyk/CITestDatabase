CREATE function [dbo].[GetLastDateFromDimDate]()
returns smalldatetime
as
begin
	declare @lastDate smalldatetime
	select @lastDate = max(FullDate) from dbo.DimDate;

	if @lastDate is null
		select @lastDate = SettingValue from dbo.Settings where SettingName = 'StartDate';

	return @lastDate
end