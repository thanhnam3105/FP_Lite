SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [tr_sap_jisseki_shiyo_denso](
	[kbn_denso_SAP] [smallint] NOT NULL,
	[no_seq] [varchar](13) NOT NULL,
	[no_lot_seihin] [varchar](14) NOT NULL,
	[dt_shiyo] [decimal](8, 0) NOT NULL,
	[cd_kojo] [varchar](13) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_shiyo] [decimal](9, 3) NOT NULL,
	[cd_tani_SAP] [varchar](10) NULL,
	[type_ido] [varchar](3) NULL,
	[hokan_basho] [varchar](10) NULL,
 CONSTRAINT [PK_tr_sap_jisseki_shiyo_denso] PRIMARY KEY CLUSTERED 
(
	[kbn_denso_SAP] ASC,
	[no_seq] ASC,
	[no_lot_seihin] ASC,
	[dt_shiyo] ASC,
	[cd_kojo] ASC,
	[cd_hinmei] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
