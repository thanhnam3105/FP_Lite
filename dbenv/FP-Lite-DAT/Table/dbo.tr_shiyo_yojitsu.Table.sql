SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_shiyo_yojitsu](
	[no_seq] [varchar](14) NOT NULL,
	[flg_yojitsu] [smallint] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_shiyo] [datetime] NOT NULL,
	[no_lot_seihin] [varchar](14) NULL,
	[no_lot_shikakari] [varchar](14) NULL,
	[su_shiyo] [decimal](12, 6) NULL,
	[data_key_tr_shikakari] [varchar](14) NULL,
 CONSTRAINT [PK_tr_shiyo_yojitsu] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
