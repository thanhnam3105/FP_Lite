SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_sap_getsumatsu_zaiko_denso_taisho_zen](
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_tanaoroshi] [datetime] NOT NULL,
	[cd_kojo] [varchar](13) NULL,
	[hokan_basho] [varchar](10) NOT NULL,
	[su_tanaoroshi] [decimal](14, 6) NULL,
	[cd_tani] [varchar](10) NULL,
	[dt_update] [datetime] NULL,
	[kbn_zaiko] [smallint] NOT NULL,
 CONSTRAINT [PK_tr_sap_getsumatsu_zaiko_denso_taisho_zen] PRIMARY KEY CLUSTERED 
(
	[cd_hinmei] ASC,
	[dt_tanaoroshi] ASC,
	[kbn_zaiko] ASC,
	[hokan_basho] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
