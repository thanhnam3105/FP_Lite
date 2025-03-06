SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_keikaku_seihin_denso_taisho](
	[no_lot_seihin] [varchar](14) NOT NULL,
	[dt_seizo] [datetime] NOT NULL,
	[cd_shokuba] [varchar](10) NOT NULL,
	[cd_line] [varchar](10) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_seizo_yotei] [decimal](10, 0) NULL,
	[su_seizo_jisseki] [decimal](10, 0) NULL,
	[flg_jisseki] [smallint] NOT NULL,
	[kbn_denso] [smallint] NULL,
	[flg_denso] [smallint] NULL,
	[dt_update] [datetime] NULL,
	[su_batch_keikaku] [decimal](12, 6) NULL,
	[su_batch_jisseki] [decimal](12, 6) NULL,
	[dt_shomi] [datetime] NULL,
 CONSTRAINT [PK_tr_sap_keikaku_seihin_denso_taisho] PRIMARY KEY CLUSTERED 
(
	[no_lot_seihin] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
