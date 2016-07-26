CREATE TABLE [stage].[CakeConversions] (
    [advertiser_id]   INT             NULL,
    [affiliate_id]    INT             NULL,
    [affiliate_name]  NVARCHAR (64)   NULL,
    [campaign_id]     INT             NULL,
    [conversion_date] DATETIME        NULL,
    [conversion_id]   NVARCHAR (64)   NULL,
    [conversion_type] NVARCHAR (64)   NULL,
    [creative_id]     INT             NULL,
    [offer_id]        INT             NULL,
    [price_paid]      DECIMAL (18, 2) NULL,
    [price_received]  DECIMAL (18, 2) NULL,
    [returned]        BIT             NULL,
    [subid_1]         NVARCHAR (255)  NULL,
    [subid_2]         NVARCHAR (255)  NULL,
    [subid_3]         NVARCHAR (255)  NULL,
    [subid_4]         NVARCHAR (255)  NULL,
    [subid_5]         NVARCHAR (255)  NULL,
    [transaction_id]  NVARCHAR (64)   NULL,
    [test]            BIT             NULL
);

