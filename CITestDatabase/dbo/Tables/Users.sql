CREATE TABLE [dbo].[Users] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [UserName] NVARCHAR (128) NOT NULL,
    [Mail]     NVARCHAR (128) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

