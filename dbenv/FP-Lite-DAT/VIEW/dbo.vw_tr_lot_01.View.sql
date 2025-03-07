IF OBJECT_ID ('dbo.vw_tr_lot_01', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_tr_lot_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_tr_lot_01]
AS
SELECT TOP (100) PERCENT
	dbo.tr_lot.no_lot
	,dbo.tr_kowake.dt_shomi
	,dbo.tr_kowake.no_lot_kowake
	,dbo.tr_kowake.cd_hinmei
	,dbo.tr_lot.no_lot_jisseki
FROM dbo.tr_lot
INNER JOIN dbo.tr_kowake
ON dbo.tr_kowake.no_lot_kowake = dbo.tr_lot.no_lot
ORDER BY
	dbo.tr_kowake.no_lot_kowake DESC
GO
