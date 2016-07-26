CREATE TABLE [dbo].[DimAffiliate] (
    [AffiliateKey]  INT           NOT NULL,
    [AffiliateBK]   INT           NOT NULL,
    [AffiliateName] NVARCHAR (64) NOT NULL,
    PRIMARY KEY CLUSTERED ([AffiliateKey] ASC)
);

