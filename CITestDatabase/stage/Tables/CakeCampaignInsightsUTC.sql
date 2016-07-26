CREATE TABLE [stage].[CakeCampaignInsightsUTC] (
    [affiliate_id]     INT                NULL,
    [campaign_id]      INT                NULL,
    [fb_id]            NVARCHAR (255)     NULL,
    [insight_utc_date] DATETIMEOFFSET (7) NULL,
    [revenue]          DECIMAL (12, 2)    NULL,
    [dls]              SMALLINT           DEFAULT ((0)) NOT NULL
);

