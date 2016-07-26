CREATE PROCEDURE [rep].[param_Campaign]
	@AdAccount nvarchar(max) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT dc.CampaignKey, dc.CampaignName
	FROM [dbo].[FactCampaign] fc
		INNER JOIN [dbo].[DimCampaign] dc ON dc.CampaignKey = fc.CampaignKey
	WHERE (@AdAccount IS NULL OR fc.AdAccountKey IN (SELECT * FROM [utils].[CSVToTable](@AdAccount, ',')))
	ORDER BY dc.CampaignName

END