CREATE TABLE [dbo].[DimDate] (
    [DateKey]       INT                NOT NULL,
    [FullDate]      DATETIMEOFFSET (7) NULL,
    [DayOfWeek]     TINYINT            NULL,
    [DayNumInMonth] TINYINT            NULL,
    [DayName]       VARCHAR (9)        NULL,
    [DayAbbrev]     CHAR (3)           NULL,
    [WeekdayFlag]   CHAR (1)           NULL,
    [WeekNumInYear] TINYINT            NULL,
    [Month]         TINYINT            NULL,
    [MonthName]     VARCHAR (9)        NULL,
    [MonthAbbrev]   CHAR (3)           NULL,
    [Quarter]       TINYINT            NULL,
    [Year]          SMALLINT           NULL,
    [Yearmo]        INT                NULL,
    CONSTRAINT [PK_DimDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);

