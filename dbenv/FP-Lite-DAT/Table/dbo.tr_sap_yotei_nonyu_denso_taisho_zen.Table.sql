SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_yotei_nonyu_denso_taisho_zen](
	[flg_yojitsu] [smallint] NOT NULL,
	[no_nonyu] [varchar](13) NOT NULL,
	[dt_nonyu] [datetime] NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_nonyu] [decimal](9, 2) NULL,
	[su_nonyu_hasu] [decimal](10, 3) NULL,
	[cd_torihiki] [varchar](13) NOT NULL,
	[cd_torihiki2] [varchar](13) NULL,
	[tan_nonyu] [decimal](12, 4) NULL,
	[kin_kingaku] [decimal](12, 4) NULL,
	[no_nonyusho] [varchar](20) NULL,
	[kbn_zei] [smallint] NOT NULL,
	[kbn_denso] [smallint] NULL,
	[flg_kakutei] [smallint] NULL,
	[dt_seizo] [datetime] NULL,
	[kbn_nyuko] [smallint] NULL,
	[cd_tani_shiyo] [varchar](10) NULL,
 CONSTRAINT [PK_tr_sap_yotei_nonyu_denso_taisho_zen] PRIMARY KEY CLUSTERED 
(
	[flg_yojitsu] ASC,
	[no_nonyu] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
