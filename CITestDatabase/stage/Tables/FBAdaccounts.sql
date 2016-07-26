CREATE TABLE [stage].[FBAdaccounts] (
    [id]                        NVARCHAR (25)  NULL,
    [account_id]                NVARCHAR (25)  NULL,
    [business_id]               NVARCHAR (25)  NULL,
    [name]                      NVARCHAR (255) NULL,
    [timezone_id]               BIGINT         NULL,
    [timezone_name]             NVARCHAR (100) NULL,
    [timezone_offset_hours_utc] BIGINT         NULL
);

