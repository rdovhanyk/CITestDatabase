CREATE PROCEDURE [stage].[CleanAdAccountData]
@AdAccountId NVARCHAR(25)
AS
BEGIN
	
	DELETE os
	FROM [stage].[FBCampaigns] c
		INNER JOIN [stage].[FBAds] a ON a.campaign_id = c.campaign_id
		INNER JOIN [stage].[FBObjectStorySpec] os ON os.ad_id = a.id
	WHERE c.account_id = @AdAccountId

	DELETE a
	FROM [stage].[FBCampaigns] c
		INNER JOIN [stage].[FBAds] a ON a.campaign_id = c.campaign_id
	WHERE c.account_id = @AdAccountId

	DELETE c
	FROM [stage].[FBCampaigns] c WHERE c.account_id = @AdAccountId
	
END