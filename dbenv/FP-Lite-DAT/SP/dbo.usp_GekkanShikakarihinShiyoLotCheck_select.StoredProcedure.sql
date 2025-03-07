IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GekkanShikakarihinShiyoLotCheck_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GekkanShikakarihinShiyoLotCheck_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2014.01.15>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GekkanShikakarihinShiyoLotCheck_select]
    @no_lot_shikakari VARCHAR(14)  -- 仕掛ロット
    ,@no_lot_shikakari_oya VARCHAR(14) -- 親仕掛ロット
AS
BEGIN
SELECT
	COUNT(summary.no_lot_shikakari) AS cnt
FROM su_keikaku_shikakari summary
WHERE
	summary.no_lot_shikakari IN 
	(
		SELECT
			no_lot_shikakari
		FROM
			tr_keikaku_shikakari shikakariTrn
		WHERE
			shikakariTrn.no_lot_shikakari_oya = @no_lot_shikakari
			OR shikakariTrn.no_lot_shikakari = @no_lot_shikakari_oya
	)
END
GO
