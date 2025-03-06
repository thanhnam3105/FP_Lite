SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kojo](
	[cd_kaisha] [varchar](13) NOT NULL,
	[cd_kojo] [varchar](13) NOT NULL,
	[nm_kojo] [nvarchar](60) NOT NULL,
	[nm_kaisha] [nvarchar](60) NOT NULL,
	[dt_nendo_start] [decimal](2, 0) NOT NULL,
	[no_yubin1] [varchar](10) NULL,
	[no_yubin2] [varchar](10) NULL,
	[nm_jusho_1] [nvarchar](30) NULL,
	[nm_jusho_2] [nvarchar](30) NULL,
	[nm_jusho_3] [nvarchar](30) NULL,
	[no_tel_1] [varchar](20) NULL,
	[no_tel_2] [varchar](20) NULL,
	[no_fax_1] [varchar](20) NULL,
	[no_fax_2] [varchar](20) NULL,
	[kbn_haigo_keisan_hoho] [smallint] NULL,
	[kbn_kowake_futai] [smallint] NULL,
	[dt_kigen_chokuzen] [decimal](2, 0) NOT NULL,
	[dt_kigen_chikai] [decimal](2, 0) NOT NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,
	[ts] [timestamp] NOT NULL,
	[no_com_reader_niuke] [decimal](2, 0) NULL,
	[cd_riyu] [varchar](10) NULL,
	[cd_genka_center] [varchar](10) NULL,
	[cd_soko] [varchar](10) NULL,
	[su_keta_shosuten] [smallint] NULL,
 CONSTRAINT [PK_ma_kojo] PRIMARY KEY CLUSTERED 
(
	[cd_kaisha] ASC,
	[cd_kojo] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
