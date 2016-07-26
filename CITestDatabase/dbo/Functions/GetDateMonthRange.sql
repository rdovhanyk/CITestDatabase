﻿CREATE FUNCTION [dbo].[GetDateMonthRange]
(	
	@StartDate datetime,
	@EndDate datetime
)
RETURNS TABLE 
AS
RETURN 
(
	WITH lst AS (
		SELECT @StartDate AS dt
		UNION ALL
		SELECT DATEADD(MONTH, 1, dt) dt
		  FROM lst s 
		 WHERE DATEADD(MONTH, 1, dt) <= @EndDate )
	SELECT * FROM lst 
)