SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_tonyu_start](
	[dt_start] [datetime] NOT NULL,
	[dt_end] [datetime] NULL,
	[cd_haigo] [varchar](14) NOT NULL,
	[nm_haigo] [nvarchar](50) NOT NULL,
	[dt_seizo] [datetime] NOT NULL,
	[dt_yotei_seizo] [datetime] NOT NULL,
	[no_kotei] [decimal](4, 0) NOT NULL,
	[su_kai] [decimal](4, 0) NOT NULL,
	[su_yotei_seizo] [decimal](4, 0) NOT NULL,
	[su_yotei_seizo_hasu] [decimal](4, 0) NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[cd_tanto] [varchar](10) NOT NULL,
	[no_lot_seihin] [varchar](14) NOT NULL,
	[kbn_seikihasu] [smallint] NOT NULL,
 CONSTRAINT [PK_tr_tonyu_start] PRIMARY KEY CLUSTERED 
(
	[cd_haigo] ASC,
	[no_kotei] ASC,
	[su_kai] ASC,
	[no_lot_seihin] ASC,
	[kbn_seikihasu] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
