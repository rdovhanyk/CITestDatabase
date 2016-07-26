CREATE TABLE [dbo].[DimCampaign] (
    [CampaignKey]  INT            NOT NULL,
    [CampaignBK]   NVARCHAR (25)  NOT NULL,
    [CampaignName] NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([CampaignKey] ASC)
);

