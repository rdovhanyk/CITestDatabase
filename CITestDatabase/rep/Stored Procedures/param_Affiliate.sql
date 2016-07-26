CREATE PROCEDURE [rep].[param_Affiliate]
	@UserId NVARCHAR(128)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [AffiliateKey], [AffiliateName] 
	FROM  [dbo].[DimAffiliate] da
		INNER JOIN [dbo].[UserAffiliates] ua ON ua.AffiliateId = da.AffiliateKey
		INNER JOIN [dbo].[Users] u ON ua.UserId = u.Id
	WHERE u.UserName = @UserId
		--AND [AffiliateKey] > -1
	ORDER BY [AffiliateName]
END