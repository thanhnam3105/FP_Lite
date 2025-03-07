SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_lot](
	[no_lot_jisseki] [varchar](14) NOT NULL,
	[no_lot] [varchar](14) NOT NULL,
	[wt_jisseki] [decimal](12, 6) NOT NULL,
	[dt_shomi] [datetime] NOT NULL,
	[dt_shomi_kaifu] [datetime] NOT NULL,
	[dt_seizo_genryo] [datetime] NULL,
	[dt_shomi_kaito] [datetime] NULL,
 CONSTRAINT [PK_tr_lot] PRIMARY KEY CLUSTERED 
(
	[no_lot_jisseki] ASC,
	[no_lot] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
