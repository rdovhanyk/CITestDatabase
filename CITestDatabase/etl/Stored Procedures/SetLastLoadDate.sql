CREATE PROCEDURE [etl].[SetLastLoadDate]
	@LastLoadDate DATETIME
AS
BEGIN
	UPDATE [dbo].[Settings] 
	SET [SettingValue] = CONVERT(varchar(20), @LastLoadDate, 20)  
	WHERE SettingName = 'LastLoadDate'
END