SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_jisseki_seihin_denso](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[no_lot_seihin] [varchar](12) NOT NULL,
	[dt_seizo] [decimal](8, 0) NULL,
	[dt_shomi] [decimal](8, 0) NULL,
	[cd_kojo] [varchar](13) NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_seizo_jisseki] [decimal](13, 3) NOT NULL,
	[cd_tani_SAP] [varchar](10) NULL,
	[no_lot_hyoji] [varchar](30) NULL,
 CONSTRAINT [PK_tr_sap_jisseki_seihin_denso] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[no_lot_seihin] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
