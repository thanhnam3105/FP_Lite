SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [wk_sap_shiyo_yojitsu_anbun_seizo](
	[no_seq] [varchar](14) NOT NULL,
	[no_lot_shikakari] [varchar](14) NOT NULL,
	[kbn_shiyo_jisseki_anbun] [varchar](10) NOT NULL,
	[no_lot_seihin] [varchar](14) NULL,
	[dt_shiyo_shikakari] [datetime] NOT NULL,
	[su_shiyo_shikakari] [decimal](12, 6) NOT NULL,
	[cd_riyu] [varchar](10) NULL,
	[cd_genka_center] [varchar](10) NULL,
	[cd_soko] [varchar](10) NULL,
	[kbn_jotai_denso] [smallint] NOT NULL,
 CONSTRAINT [PK_wk_sap_shiyo_yojitsu_anbun_seizo] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
