CREATE PROCEDURE [rep].[param_TimeZone]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT r.TimeZoneKey, r.TimeZoneName
	FROM (
		SELECT TimeZoneKey = 0, TimeZoneName = 'AdAccount Time Zone' , Ord = 0
		UNION ALL
		SELECT dtz.TimeZoneKey, dtz.TimeZoneName, Ord = 1
		FROM [dbo].[DimTimeZone] dtz
		WHERE dtz.TimeZoneKey > 0) r
	ORDER BY r.Ord, r.TimeZoneName

END