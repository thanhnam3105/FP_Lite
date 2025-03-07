IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinKeikakuDelete_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinKeikakuDelete_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.03.12>
-- Description:	月間仕掛品計画：削除対象のデータ取得処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakarihinKeikakuDelete_select]
    @no_lot			varchar(14)	-- 削除対象の仕掛品ロット番号
    ,@data_key		varchar(14)	-- 画面で修正された行のデータキー
AS
BEGIN

	-- 対象の仕掛品ロット番号を親に持つ仕掛品データを再帰的に取得していく
	WITH [cte_shikakari] (
		no_lot_shikakari
		,no_lot_shikakari_oya
		,cd_shikakari_hin
		,wt_shikomi_keikaku
		,cd_shokuba
		,cd_line
		,dt_seizo
		,data_key
		,data_key_oya
	)
	AS (
		SELECT
			no_lot_shikakari
			,no_lot_shikakari_oya
			,cd_shikakari_hin
			,wt_shikomi_keikaku
			,cd_shokuba
			,cd_line
			,dt_seizo
			,data_key
			,data_key_oya
		FROM tr_keikaku_shikakari
		WHERE no_lot_shikakari = @no_lot
		AND data_key = @data_key

		UNION ALL 

		SELECT 
			tr.no_lot_shikakari
			,tr.no_lot_shikakari_oya
			,tr.cd_shikakari_hin
			,tr.wt_shikomi_keikaku
			,tr.cd_shokuba
			,tr.cd_line
			,tr.dt_seizo
			,tr.data_key
			,tr.data_key_oya
		FROM tr_keikaku_shikakari tr
			INNER JOIN [cte_shikakari] cte
			ON tr.no_lot_shikakari_oya = cte.no_lot_shikakari
			AND tr.data_key_oya = cte.data_key
	)
				
	---- 削除対象のデータを返却
	SELECT * FROM [cte_shikakari]
END
GO
