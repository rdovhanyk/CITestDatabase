CREATE TABLE [dbo].[DimSource] (
    [SourceKey]  INT           NOT NULL,
    [SourceName] NVARCHAR (64) NULL,
    PRIMARY KEY CLUSTERED ([SourceKey] ASC)
);

