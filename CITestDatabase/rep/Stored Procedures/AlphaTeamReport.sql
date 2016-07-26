CREATE PROCEDURE [rep].[AlphaTeamReport]
	@BusinessAccountKey nvarchar(max) = NULL,
	@AdAccountKey nvarchar(max) = NULL,
	@AffiliateKey nvarchar(max) = NULL,
	@CampaignKey nvarchar(max) = NULL,
	@ROI nvarchar(20) = NULL, /* negative / positive / ELSE - both */
	@TimeZoneKey int = 0,
	@DateFrom date = NULL,
	@DateTo date = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@TimeZoneOffset int,
		@TimeZoneOffsetStr nvarchar(20) = 'dtz.TimeZoneOffset',
		@SQL nvarchar(max),
		@params nvarchar(max),
		@WhereClause nvarchar(max),
		@OrderByClause nvarchar(max)


	SET @params = '
			 @BusinessAccountKey nvarchar(max) = NULL
			,@AdAccountKey nvarchar(max) = NULL
			,@AffiliateKey nvarchar(max) = NULL
			,@CampaignKey nvarchar(max) = NULL
			,@TimeZoneOffset int = 0
	        ,@DateFrom date = NULL
	        ,@DateTo date = NULL
	     '
	
	IF @TimeZoneKey > 0
	BEGIN
		SELECT @TimeZoneOffset = TimeZoneOffset FROM [dbo].[DimTimeZone] WHERE TimeZoneKey = @TimeZoneKey
		SET @TimeZoneOffsetStr = '@TimeZoneOffset'
	END

	
	SET @SQL = '
	SELECT 	 
			 [Date] = agr.[Date] 
			,[BusinessAccountKey] = dba.BusinessAccountKey
			,[BusinessAccount] = dba.BusinessAccountName
			,[AdAccountKey] = da.AdAccountKey
			,[AdAccount] = da.AdAccountName
			,[AffiliateKey] = daf.AffiliateKey
			,[Affiliate] = daf.AffiliateName
			,[CampaignKey] = dc.CampaignKey
			,[Campaign] = dc.CampaignName
			,[Source] = ds.SourceName
			,[Rev] = agr.Revenue
			,[MaxRev] = MAX(agr.Revenue) OVER()
			,[Spend] = agr.Spend
			,[MaxSpend] = MAX(agr.Spend) OVER()
			,[Profit] = agr.Profit
			,[ROI] = CASE WHEN agr.Spend = 0 THEN 0 ELSE agr.Profit / agr.Spend END
		FROM (
				SELECT h.[Date], h.AffiliateKey, h.BusinessAccountKey, h.AdAccountKey, h.CampaignKey, h.SpendSourceKey
						,Revenue = SUM(h.Revenue), Spend = SUM(h.Spend), Profit = SUM(h.Profit)
				FROM (
					SELECT 
						 [Date] = CAST(SWITCHOFFSET(dd.FullDate, 60 * (' + @TimeZoneOffsetStr + ' + fc.DLS)) AS DATE)
						,fc.AffiliateKey
						,fc.BusinessAccountKey
						,fc.AdAccountKey
						,fc.CampaignKey
						,fc.SpendSourceKey
						,fc.Revenue
						,fc.Spend
						,fc.Profit
					FROM [dbo].[FactCampaign] fc
						INNER JOIN [dbo].[DimDate] dd ON fc.DateKey = dd.DateKey
						INNER JOIN [dbo].[DimTimeZone] dtz on fc.TimeZoneKey = dtz.TimeZoneKey
						) h
				WHERE (h.[Date] >= @DateFrom) AND (h.[Date] <= @DateTo)
				GROUP BY h.[Date], h.AffiliateKey, h.BusinessAccountKey, h.AdAccountKey, h.CampaignKey, h.SpendSourceKey) agr
			INNER JOIN [dbo].[DimBusinessAccount] dba ON agr.BusinessAccountKey = dba.BusinessAccountKey
			INNER JOIN [dbo].[DimAdAccount] da ON agr.AdAccountKey = da.AdAccountKey
			INNER JOIN [dbo].[DimAffiliate] daf ON agr.AffiliateKey = daf.AffiliateKey
			INNER JOIN [dbo].[DimCampaign] dc ON agr.CampaignKey = dc.CampaignKey
			INNER JOIN [dbo].[DimSource] ds ON agr.SpendSourceKey = ds.SourceKey
		WHERE (dba.BusinessAccountKey IN (SELECT * FROM utils.[CSVToTable](@BusinessAccountKey, '','')))
			AND (da.AdAccountKey IN (SELECT * FROM utils.[CSVToTable](@AdAccountKey, '','')))
			AND (daf.AffiliateKey IN (SELECT * FROM utils.[CSVToTable](@AffiliateKey, '','')))
			AND (dc.CampaignKey IN (SELECT * FROM utils.[CSVToTable](@CampaignKey, '',''))) '

	IF @ROI = 'negative'
		SET @SQL = @SQL + ' AND CASE WHEN agr.Spend = 0 THEN 0 ELSE agr.Profit / agr.Spend END < 0 '

	IF @ROI = 'positive'
		SET @SQL = @SQL + ' AND CASE WHEN agr.Spend = 0 THEN 0 ELSE agr.Profit / agr.Spend END >= 0 '

    SET @SQL = @SQL + ' ORDER BY agr.[Date] DESC, ds.SourceName, dba.BusinessAccountName, da.AdAccountName, dc.CampaignName '

	--print @SQL

	EXEC sp_executesql @SQL,@params,@BusinessAccountKey,@AdAccountKey,@AffiliateKey,@CampaignKey,@TimeZoneOffset,@DateFrom,@DateTo

END