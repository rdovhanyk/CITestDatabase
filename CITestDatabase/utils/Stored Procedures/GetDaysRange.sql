CREATE PROCEDURE [utils].[GetDaysRange]
	@DateFrom DateTime,
	@DateTo DateTime
AS
BEGIN
	
	IF @DateFrom > @DateTo RETURN;

	WITH lst AS (
		SELECT cast(cast(@DateFrom as date) as datetime) AS dt
		UNION ALL
		SELECT DATEADD(dd, 1, dt) dt
		  FROM lst s 
		 WHERE DATEADD(dd, 1, dt) < @DateTo )

	SELECT DateFrom, DateTo
	FROM (SELECT dt as DateFrom, LEAD(dt) OVER(order by dt) as DateTo
			FROM (SELECT CONVERT(VARCHAR(20), CAST(@DateFrom AS DateTime), 120) as dt
			UNION
			SELECT DISTINCT CONVERT(VARCHAR(20), dt, 120) FROM lst  WHERE dt > cast(@DateFrom as date) AND dt <= cast(@DateTo as date)
			UNION
			SELECT CONVERT(VARCHAR(20), CAST(@DateTo AS DateTime), 120) as dt) r) res
	WHERE res.DateTo IS NOT NULL
	OPTION (maxrecursion 0)


END