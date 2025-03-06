IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[ma_haigo_recipe]') AND name = N'_dta_index_ma_haigo_recipe')
DROP INDEX [_dta_index_ma_haigo_recipe] ON [dbo].[ma_haigo_recipe] WITH ( ONLINE = OFF )
GO

CREATE NONCLUSTERED INDEX [_dta_index_ma_haigo_recipe] ON [dbo].[ma_haigo_recipe] 
(
	[cd_haigo] ASC,
	[kbn_hin] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
