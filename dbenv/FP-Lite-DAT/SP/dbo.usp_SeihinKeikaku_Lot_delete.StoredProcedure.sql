IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_Lot_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_Lot_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==================================================
-- Author:      <Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.10.15>
-- Last update: 2014.11.26 tsujita.s
--            : 2022.01.07 BRC.sonoyama 削除処理の場合のみ製品計画トランを削除
-- Description: 製品ロット番号を元に関連データを削除
-- ==================================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_Lot_delete]
	@lotNo			VARCHAR(14)
    ,@cd_line		VARCHAR(10)
    ,@dt_seizo		DATETIME
    ,@cd_riyu		VARCHAR(10)
	,@flg_delete	smallint		-- 削除処理かどうか
AS

	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	--  製品計画トランの削除
	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	IF @flg_delete = 1
		BEGIN
			DELETE FROM tr_keikaku_seihin
			WHERE no_lot_seihin = @lotNo
		END

	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	--  仕掛品計画サマリの削除
	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	IF @flg_delete = 0
	BEGIN
		DELETE FROM su_keikaku_shikakari
		WHERE no_lot_shikakari IN 
		(SELECT no_lot_shikakari FROM tr_keikaku_shikakari
		 WHERE no_lot_seihin = @lotNo)
	END
	ELSE BEGIN
		-- ========================================
		--  自分以外の合算データがない場合はDELETE
		-- ========================================
		DELETE su FROM su_keikaku_shikakari su
			INNER JOIN tr_keikaku_shikakari tr
			ON tr.no_lot_seihin = @lotNo
			AND su.no_lot_shikakari = tr.no_lot_shikakari

			LEFT JOIN tr_keikaku_shikakari tr_gassan
			ON tr.no_lot_shikakari = tr_gassan.no_lot_shikakari
			AND tr_gassan.no_lot_seihin <> @lotNo

			WHERE tr_gassan.no_lot_seihin IS NULL
		-- ====================================================
		--  合算データがない場合は使用予実トランの実績もDELETE
		-- ====================================================
		DELETE shiyo_ji FROM tr_shiyo_yojitsu shiyo_ji
			INNER JOIN tr_keikaku_shikakari tr
			ON tr.no_lot_seihin = @lotNo
			AND shiyo_ji.no_lot_shikakari = tr.no_lot_shikakari

			LEFT JOIN tr_keikaku_shikakari tr_gassan
			ON tr.no_lot_shikakari = tr_gassan.no_lot_shikakari
			AND tr_gassan.no_lot_seihin <> @lotNo

			WHERE tr_gassan.no_lot_seihin IS NULL

		-- /////////////////////////////////////////////////////////////////////////////
		--  他に同じ仕掛品ロット番号のデータ(合算データ)が存在する場合はUPDATE（引き算）
		--  削除した仕掛品トランデータの計画仕込重量の分、サマリの計画仕込重量から引く
		--  ※※ サービス側で実施 ※※
		-- /////////////////////////////////////////////////////////////////////////////
	END

	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	--  仕掛品トランの削除
	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	DELETE FROM tr_keikaku_shikakari
	WHERE no_lot_seihin = @lotNo

	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	--  使用予実トランの削除
	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	DELETE FROM tr_shiyo_yojitsu
	WHERE no_lot_seihin = @lotNo

	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	BEGIN
		IF @cd_line IS null
			--休日トランの削除（理由も入れておかないと必要のない行も削除してしまうため）
			DELETE FROM tr_line_kyujitsu
			WHERE 
				cd_line = @cd_line
				AND dt_seizo = @dt_seizo
				AND cd_riyu = @cd_riyu
	END
	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
GO
