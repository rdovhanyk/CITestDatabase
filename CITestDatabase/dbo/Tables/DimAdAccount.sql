CREATE TABLE [dbo].[DimAdAccount] (
    [AdAccountKey]  INT            NOT NULL,
    [AdAccountBK]   NVARCHAR (25)  NOT NULL,
    [AdAccountName] NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([AdAccountKey] ASC)
);

