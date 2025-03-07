SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ma_kbn_haigo_keisan_hoho](
	[kbn_haigo_keisan_hoho] [smallint] NOT NULL,
	[nm_kbn_haigo_keisan_hoho] [nvarchar](50) NOT NULL,
	[flg_mishiyo] [smallint] NOT NULL,
	[dt_update] [datetime] NOT NULL,
	[ts] [timestamp] NOT NULL,
 CONSTRAINT [PK_ma_kbn_haigo_keisan_hoho] PRIMARY KEY CLUSTERED 
(
	[kbn_haigo_keisan_hoho] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
