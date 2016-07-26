CREATE TABLE [stage].[StageErrorLog] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Date]        DATETIME        NULL,
    [PackageName] NVARCHAR (255)  NULL,
    [TaskName]    NVARCHAR (255)  NULL,
    [SourceName]  NVARCHAR (50)   NULL,
    [Message]     NVARCHAR (1000) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

