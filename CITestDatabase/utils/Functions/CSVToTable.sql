CREATE FUNCTION [utils].[CSVToTable] (@InStr varchar(max), @sep char(1))
RETURNS @TempTab TABLE
   (value varchar(max) NOT NULL)
AS
BEGIN
    ;-- Ensure input ends with comma
	SET @InStr = replace(@InStr + @sep, @sep+@sep, @sep)
	DECLARE 
		@SP int, 
		@len int, 
		@spos int, @fpos int
	DECLARE @value1 varchar(1000)

	SET @len = LEN(@InStr);
	SET @spos = 1; SET @fpos = 1;
	WHILE @fpos <= @len BEGIN
		IF SUBSTRING(@InStr, @fpos, 1) = @sep BEGIN	
			INSERT INTO @TempTab(value) VALUES (ltrim(rtrim(SUBSTRING(@InStr, @spos, @fpos - @spos))));

			SET @fpos = @fpos + 1; 
			SET @spos = @fpos;
		END ELSE 
			SET @fpos = @fpos + 1;
	END;
	RETURN
END