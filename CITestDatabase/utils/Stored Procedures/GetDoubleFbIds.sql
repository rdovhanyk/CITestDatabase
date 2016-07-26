CREATE PROCEDURE [utils].[GetDoubleFbIds]
AS
BEGIN
	
IF OBJECT_ID('tempdb..#ss') IS NOT NULL
	DROP TABLE #ss


SELECT DISTINCT
account_id = r.account_id
,account_name = r.name
,campaign_name = r.campaign_name
,campaign_id = r.campaign_id
,fb_id = SUBSTRING(r.fb_id, 0, CASE WHEN CHARINDEX('&', r.fb_id, 0) > 0 THEN CHARINDEX('&', r.fb_id, 0) ELSE LEN(r.fb_id) + 1  END)
		INTO #ss
FROM (
		SELECT a.account_id, a.name, campaign_id = c.campaign_id, c.campaign_name
				,fb_id = SUBSTRING(os.link, CHARINDEX('&c2=', os.link, 0) + 4, LEN(os.link)) 
							
		FROM [stage].[FBAdaccounts] a
			INNER JOIN [stage].[FBCampaigns] c ON c.account_id = a.account_id
			INNER JOIN [stage].[FBAds] ad ON ad.campaign_id = c.campaign_id
			INNER JOIN [stage].[FBObjectStorySpec] os ON os.ad_id = ad.id
	)r


SELECT account_name, campaign_name, campaign_id, fb_id from 
(
	SELECT * FROM #ss 
	WHERE fb_id IN (SELECT fb_id FROM #ss group by fb_id having count(*) > 1)
) r
where  (r.fb_id like '%fb-%' OR r.fb_id like '%alpha%')
and r.fb_id in (select distinct subid_3 from [stage].[CakeClicks])
order by fb_id, campaign_Name

END