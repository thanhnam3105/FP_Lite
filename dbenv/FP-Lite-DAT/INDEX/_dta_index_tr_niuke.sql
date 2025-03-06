IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[tr_niuke]') AND name = N'_dta_index_tr_niuke')
DROP INDEX [_dta_index_tr_niuke] ON [dbo].[tr_niuke] WITH ( ONLINE = OFF )
GO

CREATE NONCLUSTERED INDEX [_dta_index_tr_niuke] ON [dbo].[tr_niuke] 
(
	[cd_hinmei] ASC,
	[dt_kigen] ASC,
	[no_lot] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
