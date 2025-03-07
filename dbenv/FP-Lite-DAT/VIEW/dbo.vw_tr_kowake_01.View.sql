IF OBJECT_ID ('dbo.vw_tr_kowake_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_kowake_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_kowake_01]
AS
SELECT TOP (100) PERCENT
	lot.no_lot_jisseki
	, lot.no_lot
	, lot.wt_jisseki
	, lot.dt_shomi
	, lot.dt_shomi_kaifu
	, lot.dt_seizo_genryo
	, kowake.dt_kowake
	, kowake.dt_seizo
	, kowake.cd_seihin
	, kowake.cd_hinmei
	, kowake.su_ko
	, kowake.su_kai
	, kowake.no_tonyu
	, kowake.cd_line
	, kowake.no_kotei
	, kowake.no_lot_seihin
	, kowake.no_lot_oya
	, kowake.dt_shomi_kaifu AS Expr1
FROM
	dbo.tr_kowake AS kowake

INNER JOIN dbo.tr_lot AS lot
ON kowake.no_lot_kowake = lot.no_lot_jisseki

ORDER BY Expr1
GO
