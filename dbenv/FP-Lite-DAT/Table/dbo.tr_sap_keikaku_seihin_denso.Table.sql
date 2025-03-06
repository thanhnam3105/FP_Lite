SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_keikaku_seihin_denso](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[no_lot_seihin] [varchar](12) NOT NULL,
	[dt_seizo] [decimal](8, 0) NULL,
	[cd_kojo] [varchar](13) NULL,
	[cd_hinmei] [varchar](14) NULL,
	[su_seizo_keikaku] [decimal](10, 0) NULL,
	[cd_tani_SAP] [varchar](10) NULL,
 CONSTRAINT [PK_tr_sap_keikaku_seihin_denso] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[no_lot_seihin] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
