CREATE PROCEDURE [etl].[Load_FactCampaign]
	@InsightsDate DATE = NULL
AS
BEGIN
	
	MERGE INTO [dbo].[FactCampaign] fc
	USING(
			SELECT 
				 [SpendSourceKey] = ISNULL(dss.[SourceKey], -1)
				,[RevenueSourceKey] = ISNULL(dsr.[SourceKey], -1)
				,[BusinessAccountKey] = ISNULL(dba.[BusinessAccountKey], -1)
				,[AdAccountKey] = ISNULL(da.[AdAccountKey], -1)
				,[AffiliateKey] = ISNULL(daf.[AffiliateKey], -1)
				,[CampaignKey] = ISNULL(dc.[CampaignKey], -1)
				,[ProductKey] = -1
				,[DateKey] = dd.[DateKey]
				,[TimeZoneKey] = ISNULL(dtz.[TimeZoneKey], 4)
				,[DLS] = st.dls
				,[LinkId] = st.fb_id
				,[Spend] = st.spend
				,[Revenue] = st.Revenue
				,[Profit] =  st.Revenue - st.spend
			FROM(
					select 'Facebook' as spend_source, 'CAKE' as revenue_source, ac.[business_id], u.affiliate_id, ac.account_id, u.campaign_id,
							u.fb_id, ac.timezone_id, u.insight_utc_date, u.dls, sum(u.revenue) as revenue, sum(u.spend) as spend
					from (
						select	isnull(i.affiliate_id, a.affiliate_id) as affiliate_id
								,isnull(i.campaign_id, c.campaign_id) as campaign_id
								,i.fb_id
								,i.insight_utc_date
								,i.dls
								,i.spend 
								,i.revenue
						from (select cu.affiliate_id,
								fu.campaign_id,
								ISNULL(fu.fb_id, cu.fb_id) as fb_id, 
								ISNULL(fu.insight_utc_date, cu.insight_utc_date) as insight_utc_date,
								ISNULL(fu.dls, cu.dls) as dls, 
								ISNULL(fu.spend, 0) as spend,
								ISNULL(cu.revenue, 0) as revenue
							from [stage].[FBCampaignInsightsUTC] fu
								full join [stage].[CakeCampaignInsightsUTC]  cu ON fu.fb_id = cu.fb_id and fu.insight_utc_date = cu.insight_utc_date
							where (@InsightsDate is null or (CAST(ISNULL(fu.insight_utc_date, cu.insight_utc_date) as date) BETWEEN dateadd(day, -1, @InsightsDate) AND dateadd(day, 1, @InsightsDate)))) i
							left join (select distinct campaign_id, fb_id from [stage].[FBCampaignInsightsUTC]) c on i.fb_id = c.fb_id and i.campaign_id is null
							left join (select distinct fb_id, affiliate_id from [stage].[CakeCampaignInsightsUTC]) a on i.fb_id = a.fb_id and i.affiliate_id is null 
						) u
					left join [stage].[FBCampaigns] c on c.campaign_id = u.campaign_id
					left join [stage].[FBAdaccounts] ac on ac.account_id = c.account_id
					group by ac.[business_id], ac.account_id, u.affiliate_id, u.campaign_id, u.fb_id, ac.timezone_id, u.insight_utc_date, u.dls ) st
			LEFT JOIN [dbo].[DimBusinessAccount] dba ON dba.[BusinessAccountBK] = st.business_id
			LEFT JOIN [dbo].[DimAdAccount] da ON da.[AdAccountBK] = st.account_id
			LEFT JOIN [dbo].[DimAffiliate] daf ON daf.[AffiliateBK] = st.affiliate_id
			LEFT JOIN [dbo].[DimSource] dss ON dss.[SourceName] = st.spend_source
			LEFT JOIN [dbo].[DimSource] dsr ON dsr.[SourceName] = st.revenue_source
			LEFT JOIN [dbo].[DimCampaign] dc ON dc.[CampaignBK] = st.campaign_id
			LEFT JOIN [dbo].[DimDate] dd ON dd.FullDate = st.insight_utc_date
			LEFT JOIN [dbo].[DimTimeZone] dtz ON dtz.[TimeZoneBK] = st.timezone_id
		WHERE (st.spend <> 0 OR st.Revenue <> 0)
	) c ON (c.[DateKey] = fc.[DateKey] AND c.[AffiliateKey] = fc.[AffiliateKey] AND c.[CampaignKey] = fc.[CampaignKey] AND c.[LinkId] = fc.[LinkId])
	WHEN MATCHED THEN
			UPDATE SET
				 [AffiliateKey] = c.[AffiliateKey]
				,[DLS] = c.[DLS]
				,[Spend] = c.[Spend]
				,[Revenue] = c.[Revenue]
				,[Profit] = c.[Profit]
	WHEN NOT MATCHED THEN
			INSERT 
			([SpendSourceKey], [RevenueSourceKey], [BusinessAccountKey], [AdAccountKey], [AffiliateKey], [CampaignKey], [ProductKey], [DateKey], [TimeZoneKey], [DLS], [LinkId], [Spend], [Revenue], [Profit])
			VALUES (c.[SpendSourceKey], c.[RevenueSourceKey], c.[BusinessAccountKey], c.[AdAccountKey], c.[AffiliateKey], c.[CampaignKey], c.[ProductKey], c.[DateKey], c.[TimeZoneKey], c.[DLS], c.[LinkId], c.[Spend], c.[Revenue], c.[Profit]);

	RETURN 0;

END