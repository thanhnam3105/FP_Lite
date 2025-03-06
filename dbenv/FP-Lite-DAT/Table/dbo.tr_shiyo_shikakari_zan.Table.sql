SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_shiyo_shikakari_zan](
	[kbn_shiyo_jisseki_anbun] [smallint] NOT NULL,
	[no_lot] [varchar](14) NOT NULL,
	[no_seq_shiyo_yojitsu_anbun] [varchar](14) NOT NULL,
	[no_seq_shiyo_yojitsu] [nvarchar](14) NULL,
	[su_shiyo] [decimal](12, 6) NULL,
 CONSTRAINT [PK_tr_shiyo_shikakari_zan] PRIMARY KEY CLUSTERED 
(
	[kbn_shiyo_jisseki_anbun] ASC,
	[no_lot] ASC,
	[no_seq_shiyo_yojitsu_anbun] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
