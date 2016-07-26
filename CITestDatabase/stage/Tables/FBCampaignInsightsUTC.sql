CREATE TABLE [stage].[FBCampaignInsightsUTC] (
    [campaign_id]      NVARCHAR (25)      NULL,
    [fb_id]            NVARCHAR (255)     NULL,
    [insight_utc_date] DATETIMEOFFSET (7) NULL,
    [spend]            DECIMAL (12, 2)    NULL,
    [dls]              SMALLINT           DEFAULT ((0)) NOT NULL
);

