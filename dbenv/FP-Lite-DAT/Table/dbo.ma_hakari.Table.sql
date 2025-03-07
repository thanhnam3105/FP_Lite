SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_hakari](
	[cd_hakari] [varchar](10) NOT NULL,
	[nm_hakari] [nvarchar](50) NOT NULL,
	[cd_tani] [varchar](10) NOT NULL,
	[kbn_baurate] [varchar](6) NOT NULL,
	[kbn_parity] [varchar](1) NOT NULL,
	[kbn_databit] [varchar](1) NOT NULL,
	[kbn_stopbit] [varchar](1) NOT NULL,
	[kbn_handshake] [varchar](1) NOT NULL,
	[nm_antei] [nvarchar](6) NOT NULL,
	[nm_fuantei] [nvarchar](6) NOT NULL,
	[su_keta] [decimal](4, 0) NOT NULL,
	[su_ichi_dot] [decimal](4, 0) NOT NULL,
	[su_ichi_fugo] [decimal](4, 0) NOT NULL,
	[cd_fundo] [varchar](10) NOT NULL,
	[flg_fugo] [smallint] NOT NULL,
	[no_ichi_juryo] [decimal](4, 0) NULL,
	[dt_create] [datetime] NOT NULL,
	[cd_create] [varchar](10) NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[no_com] [varchar](2) NULL,
	[ts] [timestamp] NULL,
	[flg_hakari_check] [smallint] NOT NULL,
	[tm_interval] [decimal](4, 0) NULL,
 CONSTRAINT [PK_ma_hakari] PRIMARY KEY CLUSTERED 
(
	[cd_hakari] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
