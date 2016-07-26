
CREATE PROCEDURE [rep].[param_AdAccount]
	@BusinessAccount nvarchar(max) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT daa.AdAccountKey, daa.AdAccountName
	FROM [dbo].[FactCampaign] fc
		INNER JOIN [dbo].[DimAdAccount] daa ON daa.[AdAccountKey] = fc.AdAccountKey
	WHERE (@BusinessAccount IS NULL OR fc.[BusinessAccountKey] IN (SELECT * FROM [utils].[CSVToTable](@BusinessAccount, ',')))
	ORDER BY daa.AdAccountName

END