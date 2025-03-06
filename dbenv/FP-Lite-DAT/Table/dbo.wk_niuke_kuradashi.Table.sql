SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wk_niuke_kuradashi](
	[no_niuke] [varchar](14) NOT NULL,
	[su_zaiko] [decimal](9, 2) NOT NULL,
	[su_zaiko_hasu] [decimal](9, 2) NOT NULL,
	[no_seq] [decimal](8, 0) NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[dt_niuke] [datetime] NOT NULL,
 CONSTRAINT [PK_wk_niuke_kuradashi] PRIMARY KEY CLUSTERED 
(
	[no_niuke] ASC,
	[no_seq] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF)
)

GO
