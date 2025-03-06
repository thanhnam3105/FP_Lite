SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tr_henko_rireki](
	[no_seq] [decimal](8, 0) IDENTITY(1,1) NOT NULL,
	[kbn_data] [decimal](2, 0) NOT NULL,
	[kbn_shori] [decimal](2, 0) NOT NULL,
	[dt_hizuke] [datetime] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[su_henko] [decimal](16, 6) NOT NULL,
	[su_henko_hasu] [decimal](12, 6) NOT NULL,
	[no_lot] [varchar](14) NULL,
	[biko] [nvarchar](200) NULL,
	[dt_update] [datetime] NOT NULL,
	[cd_update] [varchar](10) NOT NULL,

 CONSTRAINT [PK_tr_henko_rireki] PRIMARY KEY CLUSTERED 
(
	[no_seq] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO