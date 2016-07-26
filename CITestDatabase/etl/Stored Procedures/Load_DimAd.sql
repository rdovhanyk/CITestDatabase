CREATE PROCEDURE [etl].[Load_DimAd]
AS
BEGIN

	/* Get max key value */
	DECLARE @maxKeyValue int;
	SET @maxKeyValue = CASE WHEN ISNULL((SELECT MAX(a.AdKey) FROM dbo.DimAd a (NOLOCK)), 0) < 0 THEN 0 ELSE ISNULL((SELECT MAX(a.AdKey) FROM dbo.DimAd a (NOLOCK)), 0) END;

	MERGE INTO dbo.DimAd da
	USING(
			SELECT 
				RowNumber = ROW_NUMBER() OVER (ORDER BY da.AdKey),
				AdBK = a.Id,
				AdName = a.Name
			FROM (SELECT DISTINCT Id, Name FROM [stage].[FBAds] (NOLOCK)) a
			LEFT JOIN [dbo].[DimAd] da (NOLOCK) ON a.id = da.[AdBK]
		)a ON (a.AdBK = da.AdBK)
	WHEN MATCHED THEN
		UPDATE SET
			AdName = a.AdName
	WHEN NOT MATCHED THEN
		INSERT
		(
			AdKey,
			AdBK,
			AdName
		)
		VALUES
		(
			@maxKeyValue + a.RowNumber,
			a.AdBK,
			a.AdName
		);
END