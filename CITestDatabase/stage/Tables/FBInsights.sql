CREATE TABLE [stage].[FBInsights] (
    [account_id]                 NVARCHAR (25)   NULL,
    [ad_id]                      NVARCHAR (25)   NOT NULL,
    [spend]                      DECIMAL (18, 2) NULL,
    [date_start]                 DATE            NULL,
    [hs_by_advertiser_time_zone] VARCHAR (20)    NULL
);

