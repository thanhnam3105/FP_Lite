SET ANSI_PADDING ON
GO

CREATE NONCLUSTERED INDEX [IDX_NiukeJissekiTrace_select] ON [dbo].[tr_tonyu]
(
	[cd_hinmei] ASC,
	[su_kai] ASC,
	[no_tonyu] ASC,
	[no_kotei] ASC,
	[no_lot_seihin] ASC,
	[su_ko_label] ASC,
	[cd_line] ASC,
	[dt_shori] ASC,
	[kbn_seikihasu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


