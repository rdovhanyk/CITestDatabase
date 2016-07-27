CREATE PROCEDURE [stage].[Load_CakeCampaignInsightsUTC]
	@InightsDate Date
AS
BEGIN
	SET DATEFIRST 7
	/* Test comment 2 */
	DECLARE @USDLS smallint, @cake_timezone_offset_hours_utc int
	
	SELECT @cake_timezone_offset_hours_utc = SettingValue FROM [dbo].[Settings] WHERE SettingName = 'CAKETimeZoneOffsetHoursUTC'
	
	SET @USDLS = [dbo].[GetUSDaylightSaving](@InightsDate)
	SET @cake_timezone_offset_hours_utc = 60 * (@cake_timezone_offset_hours_utc + @USDLS)

	MERGE INTO [stage].[CakeCampaignInsightsUTC] cu
	USING(
			SELECT 
				ISNULL(cl.affiliate_id, cc.affiliate_id) as affiliate_id, 
				ISNULL(cl.campaign_id, cc.campaign_id) as campaign_id, 
				ISNULL(cl.subid_3, cc.subid_3) as fb_id, 
				SWITCHOFFSET(TODATETIMEOFFSET(DATEADD(HOUR, ISNULL(cc.conversion_hour, 0), CAST(ISNULL(cl.click_date, cc.conversion_date) as DateTime)), @cake_timezone_offset_hours_utc), '+00:00')  as insight_utc_date,
				ISNULL(cc.Revenue, 0) AS revenue,
				dls = @USDLS
			FROM (SELECT DISTINCT affiliate_id, campaign_id, CAST(click_date AS DATE) AS click_date, subid_3 FROM [stage].[CakeClicks] WHERE campaign_id > 0 AND CAST(click_date AS DATE) = @InightsDate) cl
				FULL JOIN (
							SELECT cc.affiliate_id, cc.campaign_id, RTRIM(LTRIM(cc.subid_3)) as subid_3, CAST(cc.conversion_date AS DATE) as conversion_date, 
														DATEPART(HOUR,cc.conversion_date) as conversion_hour, 
														cc.price_paid as price,
														cc.price_paid * count(*) as Revenue
							FROM [stage].[CakeConversions] cc
							WHERE CAST(cc.conversion_date as date) = @InightsDate
							GROUP BY cc.affiliate_id, cc.campaign_id, CAST(cc.conversion_date AS DATE), DATEPART(HOUR,cc.conversion_date), cc.[price_paid], cc.subid_3) cc 
			ON cc.subid_3 = cl.subid_3 AND cc.campaign_id = cl.campaign_id AND cc.conversion_date = cl.click_date
		)n ON (n.affiliate_id = cu.affiliate_id AND n.campaign_id = cu.campaign_id AND n.fb_id = cu.fb_id AND n.insight_utc_date = cu.insight_utc_date)
	WHEN MATCHED THEN
		UPDATE SET
			revenue = n.revenue
	WHEN NOT MATCHED THEN
		INSERT
		(
			[affiliate_id],
			[campaign_id],
			[fb_id],
			[insight_utc_date],
			[revenue],
			[dls]
		)
		VALUES
		(
			n.[affiliate_id],
			n.[campaign_id],
			n.[fb_id],
			n.[insight_utc_date],
			n.[revenue],
			n.[dls]
		);
END