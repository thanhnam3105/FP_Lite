SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wk_nonyu](
	[dt_nonyu] [datetime] NOT NULL,
	[cd_hinmei] [varchar](14) NOT NULL,
	[cd_torihiki] [varchar](13) NOT NULL,
	[su_nonyu] [decimal](9, 2) NULL,
 CONSTRAINT [PK_wk_nonyu] PRIMARY KEY CLUSTERED 
(
	[dt_nonyu] ASC,
	[cd_hinmei] ASC,
	[cd_torihiki] ASC
)WITH (STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF)
)
GO
