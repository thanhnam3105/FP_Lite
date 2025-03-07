IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_Summary_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_Summary_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ======================================================
-- Author:      <Author,,tsujita.s>
-- Create date: <Create Date,,2014.11.26>
-- Last update: 2014.12.12 tsujita.s
-- Description: 月間製品計画の削除処理で使用。
--   同じ仕掛品ロット番号のデータ(合算データ)を取得する。
-- ======================================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_Summary_select]
	@seihinLotNo	VARCHAR(14)
AS

	-- UPDATE対象の仕掛品サマリデータを取得
	SELECT
		su.cd_shikakari_hin AS cd_shikakari_hin
		,su.no_lot_shikakari AS no_lot_shikakari
		,(su.wt_shikomi_keikaku - tr.wt_shikomi_keikaku) AS wt_shikomi_keikaku
	FROM su_keikaku_shikakari su

	INNER JOIN (
		SELECT no_lot_shikakari
			,SUM(wt_shikomi_keikaku) AS wt_shikomi_keikaku
		FROM tr_keikaku_shikakari
		WHERE no_lot_seihin = @seihinLotNo
		GROUP BY no_lot_shikakari
	) tr
	ON su.no_lot_shikakari = tr.no_lot_shikakari
GO
