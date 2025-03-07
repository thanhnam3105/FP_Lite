SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_genka_tanka](
	[dt_genka_keisan] [datetime] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[kbn_tanka] [smallint] NOT NULL,
	[tan_genka] [decimal](14, 4) NULL,
 CONSTRAINT [PK_tr_genka_tanka] PRIMARY KEY CLUSTERED 
(
	[dt_genka_keisan] ASC,
	[cd_hinmei] ASC,
	[kbn_tanka] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
