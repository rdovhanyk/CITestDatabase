CREATE PROCEDURE [utils].[GetAdDetails]
	@campaignid nvarchar(25),
	@FB_ID nvarchar(50)
AS
BEGIN
	
	SELECT c.campaign_name, a.name, os.link
	FROM [stage].[FBAds] a
		INNER JOIN [stage].[FBObjectStorySpec] os ON a.id = os.ad_id
		INNER JOIN [stage].[FBCampaigns] c ON a.campaign_id = c.campaign_id
	WHERE a.campaign_id = @campaignid
	AND os.link like '%' + @FB_ID + '%'

END