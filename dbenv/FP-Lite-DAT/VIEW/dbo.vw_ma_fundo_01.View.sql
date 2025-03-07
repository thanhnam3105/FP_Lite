IF OBJECT_ID ('dbo.vw_ma_fundo_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_fundo_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ma_fundo_01]
AS
	SELECT
	mf.cd_fundo
	, mf.wt_fundo
	, mf.wt_fundo_jogen
	, mf.wt_fundo_kagen
	, mf.dt_create
	, mf.cd_create
	, mf.dt_update
	, mf.cd_update
	, mf.flg_mishiyo
	, mf.cd_tani
	, mf.ts
	, CONVERT(varchar, mf.wt_fundo ) +' ' + mt.nm_tani AS wt_fundo_nm_tani
	, mt.nm_tani
FROM
	dbo.ma_fundo AS mf
LEFT JOIN ma_tani mt
ON mf.cd_tani = mt.cd_tani
GO
