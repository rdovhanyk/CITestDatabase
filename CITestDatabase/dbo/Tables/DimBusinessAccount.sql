CREATE TABLE [dbo].[DimBusinessAccount] (
    [BusinessAccountKey]  INT            NOT NULL,
    [BusinessAccountBK]   NVARCHAR (25)  NOT NULL,
    [BusinessAccountName] NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([BusinessAccountKey] ASC)
);

