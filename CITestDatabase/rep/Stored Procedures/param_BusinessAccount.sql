CREATE PROCEDURE [rep].[param_BusinessAccount]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [BusinessAccountKey], [BusinessAccountName] 
	FROM [dbo].[DimBusinessAccount] 
	--WHERE [BusinessAccountKey] > -1
	ORDER BY [BusinessAccountName]
END