CREATE PROCEDURE [etl].[Load_DimCampaign]
AS
BEGIN

	/* Get max key value */
	DECLARE @maxKeyValue int;
	SET @maxKeyValue = CASE WHEN ISNULL((SELECT MAX(c.CampaignKey) FROM dbo.DimCampaign c (NOLOCK)), 0) < 0 THEN 0 ELSE ISNULL((SELECT MAX(c.CampaignKey) FROM dbo.DimCampaign c (NOLOCK)), 0) END;

	MERGE INTO dbo.DimCampaign dc
	USING(
			SELECT 
				RowNumber = ROW_NUMBER() OVER (ORDER BY dc.CampaignKey),
				CampaignBK = a.campaign_id,
				CampaignName = a.campaign_name
			FROM (SELECT DISTINCT campaign_id, campaign_name FROM [stage].[FBCampaigns] (NOLOCK)) a
			LEFT JOIN [dbo].[DimCampaign] dc (NOLOCK) ON a.campaign_id = dc.[CampaignBK]
		)c ON (c.CampaignBK = dc.CampaignBK)
	WHEN MATCHED THEN
		UPDATE SET
			CampaignName = c.CampaignName
	WHEN NOT MATCHED THEN
		INSERT
		(
			CampaignKey,
			CampaignBK,
			CampaignName
		)
		VALUES
		(
			@maxKeyValue + c.RowNumber,
			c.CampaignBK,
			c.CampaignName
		);


	/* Add Unknown Campaign */
	IF ISNULL((SELECT COUNT(*) FROM dbo.[DimCampaign] dc WHERE dc.CampaignKey = -1), 0)=0
		INSERT INTO dbo.[DimCampaign] (CampaignKey, CampaignBK, CampaignName) values(-1, -1, 'Unknown');

END