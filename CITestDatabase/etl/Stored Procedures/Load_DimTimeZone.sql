CREATE PROCEDURE [etl].[Load_DimTimeZone]
AS
BEGIN
	/* Get max key value */
	DECLARE @maxKeyValue int;
	SET @maxKeyValue = CASE WHEN ISNULL((SELECT MAX(a.TimeZoneKey) FROM dbo.DimTimeZone a (NOLOCK)), 0) < 0 THEN 0 ELSE ISNULL((SELECT MAX(a.TimeZoneKey) FROM dbo.DimTimeZone a (NOLOCK)), 0) END;

	MERGE INTO dbo.DimTimeZone d
	USING(
			SELECT 
				RowNumber = ROW_NUMBER() OVER (ORDER BY dt.[TimeZoneKey]),
				[TimeZoneBK] = tz.timezone_id,
				[TimeZoneName] = tz.timezone_name,
				[TimeZoneOffset] = tz.timezone_offset_hours_utc
			FROM (SELECT DISTINCT timezone_id, timezone_name, timezone_offset_hours_utc FROM [stage].[FBAdaccounts] (NOLOCK)) tz
			LEFT JOIN [dbo].[DimTimeZone] dt (NOLOCK) ON tz.timezone_id = dt.TimeZoneBK

		)tz ON (tz.[TimeZoneBK] = d.[TimeZoneBK])
	WHEN MATCHED THEN
		UPDATE SET
			[TimeZoneName] = tz.[TimeZoneName],
			[TimeZoneOffset] = tz.[TimeZoneOffset]
	WHEN NOT MATCHED THEN
		INSERT
		(
			[TimeZoneKey],
			[TimeZoneBK],
			[TimeZoneName],
			[TimeZoneOffset]
		)
		VALUES
		(
			@maxKeyValue + tz.RowNumber,
			tz.[TimeZoneBK],
			tz.[TimeZoneName],
			tz.[TimeZoneOffset]
		);


	/* Add Unknown Affiliate */
	IF ISNULL((SELECT COUNT(*) FROM dbo.[DimTimeZone] dt WHERE dt.[TimeZoneKey] = -1), 0)=0
		INSERT INTO dbo.[DimTimeZone] ([TimeZoneKey], [TimeZoneBK], [TimeZoneName], [TimeZoneOffset]) values(-1, -1, 'Unknown', 0);

END