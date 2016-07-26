CREATE PROCEDURE [etl].[Load_DimProduct]
AS
BEGIN

	/* Get max key value */
	DECLARE @maxKeyValue int;
	SET @maxKeyValue = CASE WHEN ISNULL((SELECT MAX(p.ProductKey) FROM dbo.DimProduct p (NOLOCK)), 0) < 0 THEN 0 ELSE ISNULL((SELECT MAX(p.ProductKey) FROM dbo.DimProduct p (NOLOCK)), 0) END;

	--MERGE INTO dbo.DimProduct dp
	--USING(
	--		SELECT 
	--			RowNumber = ROW_NUMBER() OVER (ORDER BY dp.ProductKey),
	--			ProductName = vn.vertical_name
	--		FROM (SELECT DISTINCT vertical_name FROM [stage].[SHLCampaignSummary] (NOLOCK)
	--			  UNION ALL 
	--			  SELECT DISTINCT vertical_name FROM [stage].[A4DCampaignSummary] (NOLOCK)) vn
	--		LEFT JOIN [dbo].[DimProduct] dp (NOLOCK) ON vn.vertical_name = dp.ProductName
	--	)p ON (p.ProductName = dp.ProductName)
	--WHEN NOT MATCHED THEN
	--	INSERT
	--	(
	--		ProductKey,
	--		ProductName
	--	)
	--	values
	--	(
	--		@maxKeyValue + p.RowNumber,
	--		p.ProductName
	--	);
	/* Add Unknown Product */
	IF ISNULL((SELECT COUNT(*) FROM dbo.DimProduct p WHERE p.ProductKey=-1), 0)=0
		INSERT INTO dbo.DimProduct (ProductKey, ProductName) values(-1, '');
END