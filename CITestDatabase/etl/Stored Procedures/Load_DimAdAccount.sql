CREATE PROCEDURE [etl].[Load_DimAdAccount]
AS
BEGIN
	/* Get max key value */
	DECLARE @maxKeyValue int;
	SET @maxKeyValue = CASE WHEN ISNULL((SELECT MAX(a.AdAccountKey) FROM dbo.DimAdAccount a (NOLOCK)), 0) < 0 THEN 0 ELSE ISNULL((SELECT MAX(a.AdAccountKey) FROM dbo.DimAdAccount a (NOLOCK)), 0) END;

	MERGE INTO dbo.DimAdAccount d
	USING(
			SELECT 
				RowNumber = ROW_NUMBER() OVER (ORDER BY da.AdAccountKey),
				AdAccountBK = a.account_id,
				AdAccountName = a.name
			FROM (SELECT DISTINCT account_id, name FROM [stage].[FBAdaccounts] (NOLOCK)) a
			LEFT JOIN [dbo].[DimAdAccount] da (NOLOCK) ON a.account_id = da.[AdAccountBK]
		)a ON (a.AdAccountBK = d.AdAccountBK)
	WHEN MATCHED THEN
		UPDATE SET
			AdAccountName = a.AdAccountName
	WHEN NOT MATCHED THEN
		INSERT
		(
			AdAccountKey,
			AdAccountBK,
			AdAccountName
		)
		VALUES
		(
			@maxKeyValue + a.RowNumber,
			a.AdAccountBK,
			a.AdAccountName
		);


			/* Add Unknown Ad Account */
	IF ISNULL((SELECT COUNT(*) FROM dbo.[DimAdAccount] da WHERE da.AdAccountKey = -1), 0)=0
		INSERT INTO dbo.[DimAdAccount] (AdAccountKey, AdAccountBK, AdAccountName) values(-1, -1, 'Unknown');

END