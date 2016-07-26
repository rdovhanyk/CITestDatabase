CREATE PROCEDURE [etl].[Load_DimBusinessAccount]
AS
BEGIN
	/* Get max key value */
	DECLARE @maxKeyValue int;
	SET @maxKeyValue = CASE WHEN ISNULL((SELECT MAX(a.BusinessAccountKey) FROM dbo.DimBusinessAccount a (NOLOCK)), 0) < 0 THEN 0 ELSE ISNULL((SELECT MAX(a.BusinessAccountKey) FROM dbo.DimBusinessAccount a (NOLOCK)), 0) END;

	MERGE INTO dbo.DimBusinessAccount d
	USING(
			SELECT 
				RowNumber = ROW_NUMBER() OVER (ORDER BY da.BusinessAccountKey),
				BusinessAccountBK = a.id,
				BusinessAccountName = a.name
			FROM (SELECT DISTINCT id, name FROM [stage].[FBBusinessAccounts] (NOLOCK)) a
			LEFT JOIN [dbo].[DimBusinessAccount] da (NOLOCK) ON a.id = da.[BusinessAccountBK]
		)a ON (a.BusinessAccountBK = d.BusinessAccountBK)
	WHEN MATCHED THEN
		UPDATE SET
			BusinessAccountName = a.BusinessAccountName
	WHEN NOT MATCHED THEN
		INSERT
		(
			BusinessAccountKey,
			BusinessAccountBK,
			BusinessAccountName
		)
		VALUES
		(
			@maxKeyValue + a.RowNumber,
			a.BusinessAccountBK,
			a.BusinessAccountName
		);


			/* Add Unknown Business Account */
	IF ISNULL((SELECT COUNT(*) FROM dbo.[DimBusinessAccount] da WHERE da.BusinessAccountKey = -1), 0)=0
		INSERT INTO dbo.[DimBusinessAccount] (BusinessAccountKey, BusinessAccountBK, BusinessAccountName) values(-1, -1, 'Unknown');

END