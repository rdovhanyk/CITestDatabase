CREATE TABLE [dbo].[FactCampaign] (
    [DateKey]            INT             NOT NULL,
    [TimeZoneKey]        INT             NOT NULL,
    [DLS]                SMALLINT        DEFAULT ((0)) NOT NULL,
    [RevenueSourceKey]   INT             NOT NULL,
    [SpendSourceKey]     INT             NOT NULL,
    [BusinessAccountKey] INT             DEFAULT ((-1)) NOT NULL,
    [AdAccountKey]       INT             DEFAULT ((-1)) NOT NULL,
    [ProductKey]         INT             NOT NULL,
    [AffiliateKey]       INT             DEFAULT ((-1)) NOT NULL,
    [CampaignKey]        INT             NOT NULL,
    [LinkId]             NVARCHAR (255)  NULL,
    [Revenue]            DECIMAL (12, 2) NULL,
    [Spend]              DECIMAL (12, 2) NULL,
    [Profit]             DECIMAL (12, 2) NULL
);

