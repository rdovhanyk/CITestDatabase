CREATE PROCEDURE [etl].[GetLastLoadDate]
AS
BEGIN
	SELECT LastLoadDate = CAST([SettingValue] AS DATETIME)  FROM [dbo].[Settings] WHERE SettingName = 'LastLoadDate'
END