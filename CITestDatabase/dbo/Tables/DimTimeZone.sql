CREATE TABLE [dbo].[DimTimeZone] (
    [TimeZoneKey]    INT           NOT NULL,
    [TimeZoneBK]     INT           NOT NULL,
    [TimeZoneName]   NVARCHAR (64) NOT NULL,
    [TimeZoneOffset] INT           NOT NULL
);

