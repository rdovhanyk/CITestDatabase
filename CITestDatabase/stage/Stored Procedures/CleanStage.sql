CREATE PROCEDURE [stage].[CleanStage]
AS
BEGIN
	
	TRUNCATE TABLE [stage].[FBAdaccounts];
	TRUNCATE TABLE [stage].[FBAds];
	TRUNCATE TABLE [stage].[FBObjectStorySpec];
	TRUNCATE TABLE [stage].[FBInsights];
	TRUNCATE TABLE [stage].[CakeConversions];
	TRUNCATE TABLE [stage].[SHLCampaignSummary];
	TRUNCATE TABLE [stage].[SHLConversions];
	TRUNCATE TABLE [stage].[A4DCampaignSummary];
	TRUNCATE TABLE [stage].[A4DConversions];
	
END