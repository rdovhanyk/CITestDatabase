CREATE PROCEDURE [rep].[AlphaTeamHourlyDetailsReport]
	@Date date,
	@TimeZoneKey int,
	@BusinessAccountKey int,
	@AdAccountKey int,
	@AffiliateKey int,
	@CampaignKey int,
	@ROI nvarchar(20)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE 
		@TimeZoneOffset int,
		@TimeZoneOffsetStr nvarchar(20) = 'dtz.TimeZoneOffset',
		@SQL nvarchar(max),
		@params nvarchar(max)


	SET @params = '
			 @BusinessAccountKey int = NULL
			,@AdAccountKey int = NULL
			,@AffiliateKey int = NULL
			,@CampaignKey int = NULL
			,@TimeZoneOffset int = 0
	        ,@Date date = NULL
	     '
	
	IF @TimeZoneKey > 0
	BEGIN
		SELECT @TimeZoneOffset = TimeZoneOffset FROM [dbo].[DimTimeZone] WHERE TimeZoneKey = @TimeZoneKey
		SET @TimeZoneOffsetStr = '@TimeZoneOffset'
	END

	
	SET @SQL = '
	SELECT 
		 [Date] = h.[Date]
		,[Hour] = DATEPART(HOUR, h.[Date])
		,[BusinessAccount] = dba.BusinessAccountName
		,[AdAccount] = da.AdAccountName
		,[Affiliate] = daf.AffiliateName
		,[Campaign] = dc.CampaignName
		,[Source] = ds.SourceName
		,[LinkId] = h.LinkId
		,[Rev] = h.Revenue
		,[MaxRev] = MAX(h.Revenue) OVER()
		,[Spend] = h.Spend
		,[MaxSpend] = MAX(h.Spend) OVER()
		,[Profit] = h.Profit
		,[ROI] = CASE WHEN h.Spend = 0 THEN 0 ELSE h.Profit / h.Spend END
			FROM (
				SELECT 
					 [Date] = CAST(SWITCHOFFSET(dd.FullDate, 60 * (' + @TimeZoneOffsetStr + ' + fc.DLS)) AS DATETIME)
					,fc.AffiliateKey
					,fc.BusinessAccountKey
					,fc.AdAccountKey
					,fc.CampaignKey
					,fc.SpendSourceKey
					,fc.LinkId
					,fc.Revenue
					,fc.Spend
					,fc.Profit
				FROM [dbo].[FactCampaign] fc
					INNER JOIN [dbo].[DimDate] dd ON fc.DateKey = dd.DateKey
					INNER JOIN [dbo].[DimTimeZone] dtz on fc.TimeZoneKey = dtz.TimeZoneKey
					) h
		INNER JOIN [dbo].[DimBusinessAccount] dba ON h.BusinessAccountKey = dba.BusinessAccountKey
		INNER JOIN [dbo].[DimAdAccount] da ON h.AdAccountKey = da.AdAccountKey
		INNER JOIN [dbo].[DimAffiliate] daf ON h.AffiliateKey = daf.AffiliateKey
		INNER JOIN [dbo].[DimCampaign] dc ON h.CampaignKey = dc.CampaignKey
		INNER JOIN [dbo].[DimSource] ds ON h.SpendSourceKey = ds.SourceKey
	WHERE CAST(h.[Date] AS DATE) = @Date
		AND dba.BusinessAccountKey = @BusinessAccountKey
		AND da.AdAccountKey = @AdAccountKey
		AND daf.AffiliateKey = @AffiliateKey 
		AND dc.CampaignKey = @CampaignKey '

	IF @ROI = 'negative'
		SET @SQL = @SQL + ' AND CASE WHEN h.Spend = 0 THEN 0 ELSE h.Profit / h.Spend END < 0 '

	IF @ROI = 'positive'
		SET @SQL = @SQL + ' AND CASE WHEN h.Spend = 0 THEN 0 ELSE h.Profit / h.Spend END >= 0 '
    SET @SQL = @SQL + ' ORDER BY DATEPART(HOUR, h.[Date]) '

	--print @SQL

	EXEC sp_executesql @SQL,@params,@BusinessAccountKey,@AdAccountKey,@AffiliateKey,@CampaignKey,@TimeZoneOffset,@Date 

END