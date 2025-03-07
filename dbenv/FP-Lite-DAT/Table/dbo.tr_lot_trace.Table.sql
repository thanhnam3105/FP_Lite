SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_lot_trace](
	[no_seq] [varchar](14) NOT NULL,
	[no_lot_shikakari] [varchar](14) NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[no_tonyu] [decimal](4, 0) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[kbn_hin] [smallint] NULL,
	[no_niuke] [varchar](14) NULL,
	[flg_henko] [smallint] NULL,
	[dt_create] [datetime] NULL,
	[cd_create] [varchar](10) NULL,
	[dt_update] [datetime] NULL,
	[cd_update] [varchar](10) NULL,
	[biko] [nvarchar](100) NULL,
 CONSTRAINT [PK_tr_lot_trace] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
