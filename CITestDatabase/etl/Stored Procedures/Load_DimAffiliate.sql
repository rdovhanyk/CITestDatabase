CREATE PROCEDURE [etl].[Load_DimAffiliate]
AS
BEGIN
	/* Get max key value */
	DECLARE @maxKeyValue int;
	SET @maxKeyValue = CASE WHEN ISNULL((SELECT MAX(a.AffiliateKey) FROM dbo.DimAffiliate a (NOLOCK)), 0) < 0 THEN 0 ELSE ISNULL((SELECT MAX(a.AffiliateKey) FROM dbo.DimAffiliate a (NOLOCK)), 0) END;

	MERGE INTO dbo.DimAffiliate d
	USING(
			SELECT 
				RowNumber = ROW_NUMBER() OVER (ORDER BY da.AffiliateKey),
				AffiliateBK = a.affiliate_id,
				AffiliateName = a.affiliate_name
			FROM (SELECT DISTINCT [affiliate_id], [affiliate_name] FROM [stage].[CakeConversions] (NOLOCK)) a
			LEFT JOIN [dbo].[DimAffiliate] da (NOLOCK) ON a.[affiliate_id] = da.AffiliateBK
		)a ON (a.AffiliateBK = d.AffiliateBK)
	WHEN MATCHED THEN
		UPDATE SET
			AffiliateName = a.AffiliateName
	WHEN NOT MATCHED THEN
		INSERT
		(
			AffiliateKey,
			AffiliateBK,
			AffiliateName
		)
		VALUES
		(
			@maxKeyValue + a.RowNumber,
			a.AffiliateBK,
			a.AffiliateName
		);


			/* Add Unknown Affiliate */
	IF ISNULL((SELECT COUNT(*) FROM dbo.[DimAffiliate] da WHERE da.AffiliateKey = -1), 0)=0
		INSERT INTO dbo.[DimAffiliate] (AffiliateKey, AffiliateBK, AffiliateName) values(-1, -1, 'Unknown');

END