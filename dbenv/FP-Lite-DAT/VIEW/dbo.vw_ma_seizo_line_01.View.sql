IF OBJECT_ID ('dbo.vw_ma_seizo_line_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_seizo_line_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_seizo_line_01]
AS
SELECT
	dbo.ma_seizo_line.kbn_master
	, dbo.ma_seizo_line.cd_haigo
	, dbo.ma_seizo_line.no_juni_yusen
	, dbo.ma_seizo_line.cd_line
	, dbo.ma_line.nm_line
	, dbo.ma_seizo_line.flg_mishiyo AS seizo_line_mishiyo
	, dbo.ma_seizo_line.dt_create
	, dbo.ma_seizo_line.cd_create
	, dbo.ma_seizo_line.dt_update
	, dbo.ma_seizo_line.cd_update
	, dbo.ma_seizo_line.ts
	, dbo.ma_line.flg_mishiyo AS line_mishiyo
	, dbo.ma_line.cd_shokuba
FROM
	dbo.ma_seizo_line
LEFT OUTER JOIN dbo.ma_line
ON dbo.ma_seizo_line.cd_line = dbo.ma_line.cd_line
GO
