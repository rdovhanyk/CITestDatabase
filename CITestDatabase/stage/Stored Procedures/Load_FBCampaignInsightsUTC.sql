CREATE PROCEDURE [stage].[Load_FBCampaignInsightsUTC]
	@InightsDate Date
AS
BEGIN
	SET DATEFIRST 7

	DECLARE @USDLS smallint
	SET @USDLS = [dbo].[GetUSDaylightSaving](@InightsDate)


	MERGE INTO [stage].[FBCampaignInsightsUTC] fu
	USING(
			SELECT campaign_id = res.campaign_id
						,fb_id = res.fb_id
						,insight_utc_date = res.insight_utc_date
						,spend = SUM(res.spend)
						,dls = @USDLS
				FROM (
						SELECT 
								campaign_id = r.campaign_id
								,fb_id = r.fb_id
								,insight_utc_date = SWITCHOFFSET(r.insight_utc_date, '+00:00') 
								,spend = r.spend
						FROM (
								SELECT campaign_id = c.campaign_id
										,fb_id = ISNULL([dbo].[GetLinkParameterValue](os.link, 'c2'), [dbo].[GetLinkParameterValue](os.link, 's3'))
										,insight_utc_date = TODATETIMEOFFSET(cast(cast(i.date_start as varchar(10)) + ' ' + CAST(i.[hs_by_advertiser_time_zone] as varchar(8)) as DateTime),  60 * (a.timezone_offset_hours_utc + @USDLS))
										,spend = SUM(ISNULL(i.spend, 0))
								FROM [stage].[FBAdaccounts] a
									INNER JOIN [stage].[FBCampaigns] c ON c.account_id = a.account_id
									INNER JOIN [stage].[FBAds] ad ON ad.campaign_id = c.campaign_id
									INNER JOIN [stage].[FBInsights] i ON i.ad_id = ad.id AND i.[date_start] = @InightsDate
									INNER JOIN [stage].[FBObjectStorySpec] os ON os.ad_id = ad.id
								GROUP BY a.business_id, a.account_id, c.campaign_id, i.date_start, i.hs_by_advertiser_time_zone, os.link, a.timezone_id, a.timezone_offset_hours_utc
								UNION ALL 
								SELECT campaign_id = e.campaign_id
										,fb_id = e.fb_id 
										,insight_utc_date = TODATETIMEOFFSET(CAST(cast(@InightsDate as varchar(10)) + ' 12:00:00' AS DATETIME),  60 * (e.timezone_offset_hours_utc + @USDLS))
										,spend = 0
								FROM (SELECT c.campaign_id,
												ISNULL([dbo].[GetLinkParameterValue](os.link, 'c2'), [dbo].[GetLinkParameterValue](os.link, 's3')) as fb_id,
												i.date_start,
												a.[timezone_id], 
												a.timezone_offset_hours_utc
										FROM [stage].[FBAdaccounts] a
											INNER JOIN [stage].[FBCampaigns] c ON c.account_id = a.account_id
											INNER JOIN [stage].[FBAds] ad ON ad.campaign_id = c.campaign_id
											LEFT JOIN [stage].[FBInsights] i ON i.ad_id = ad.id AND i.[date_start] = @InightsDate
											INNER JOIN [stage].[FBObjectStorySpec] os ON os.ad_id = ad.id
										GROUP BY a.business_id, a.account_id, c.campaign_id, i.date_start, i.hs_by_advertiser_time_zone, os.link, a.timezone_id, a.timezone_offset_hours_utc) e
								GROUP BY e.campaign_id, e.fb_id, e.[timezone_id], e.timezone_offset_hours_utc
								HAVING COUNT(*) = 1 AND MIN(e.date_start) IS NULL) r) res
				WHERE res.fb_id IS NOT NULL
				GROUP BY res.campaign_id, res.fb_id, res.insight_utc_date
		)n ON (n.campaign_id = fu.campaign_id AND n.fb_id = fu.fb_id AND n.insight_utc_date = fu.insight_utc_date)
	WHEN MATCHED THEN
		UPDATE SET
			spend = n.spend
	WHEN NOT MATCHED THEN
		INSERT
		(
			[campaign_id],
			[fb_id],
			[insight_utc_date],
			[spend],
			[dls]
		)
		VALUES
		(
			n.[campaign_id],
			n.[fb_id],
			n.[insight_utc_date],
			n.[spend],
			n.[dls]
		);
END