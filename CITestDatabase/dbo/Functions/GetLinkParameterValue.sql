CREATE FUNCTION [dbo].[GetLinkParameterValue](@Link nvarchar(255), @ParameterName nvarchar(32))
RETURNS NVARCHAR(64)
AS
BEGIN

	SET @ParameterName = @ParameterName + '='

	IF CHARINDEX(@ParameterName, @Link, 0) <= 0 
		RETURN NULL

	SET @link = SUBSTRING(@Link, CHARINDEX(@ParameterName, @Link, 0) + LEN(@ParameterName), LEN(@Link)) 
	RETURN RTRIM(SUBSTRING(@Link, 0, CASE WHEN CHARINDEX('&', @Link, 0) > 0 THEN CHARINDEX('&', @Link, 0) ELSE LEN(@Link) + 1 END))


END