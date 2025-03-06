SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_kongo_nisugata](
	[dt_kowake] [datetime] NOT NULL,
	[no_lot_jisseki] [varchar](14) NOT NULL,
	[no_lot] [varchar](14) NOT NULL,
	[old_no_lot_jisseki] [varchar](14) NOT NULL,
	[old_no_lot] [varchar](14) NOT NULL,
	[old_wt_jisseki] [decimal](12, 6) NOT NULL,
	[old_dt_shomi] [datetime] NOT NULL,
	[old_dt_shomi_kaifu] [datetime] NOT NULL,
	[old_dt_seizo_genryo] [datetime] NULL,
	[cd_maker] [varchar](20) NOT NULL,
	[old_dt_shomi_kaito] [datetime] NULL,
 CONSTRAINT [PK_tr_kongo_nisugata] PRIMARY KEY CLUSTERED 
(
	[dt_kowake] ASC,
	[no_lot_jisseki] ASC,
	[no_lot] ASC,
	[old_no_lot_jisseki] ASC,
	[old_no_lot] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
