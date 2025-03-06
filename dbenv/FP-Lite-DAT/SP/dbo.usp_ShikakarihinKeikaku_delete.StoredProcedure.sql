IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinKeikaku_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinKeikaku_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.03.12>
-- Last update: 2015.01.15 tsujita.s
-- Description:	月間仕掛品計画の削除処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakarihinKeikaku_delete]
    @no_lot			varchar(14)		-- 削除対象の仕掛品ロット番号
    ,@cd_shikakari	varchar(14)		-- 削除対象の仕掛品コード
    ,@cd_shokuba	varchar(10)		-- 削除対象の職場コード
    ,@cd_line		varchar(10)		-- 削除対象のラインコード
	,@dt_seizo		DATETIME		-- 削除対象の製造日
	,@wt_shikomi	DECIMAL(12,6)	-- 削除対象の計画仕込重量
	,@data_key		varchar(14)		-- 削除対象の仕掛品計画トランデータキー
AS
BEGIN

	-- 返却用「0」
	DECLARE @return_val DECIMAL(12,6) = 0.0

	IF @no_lot IS NOT NULL OR LEN(@no_lot) > 0
	BEGIN
		--=====================
		-- 仕掛品トランの削除
		--=====================
		DELETE tr_keikaku_shikakari
		WHERE data_key = @data_key


		--========================
		-- 使用予実トランの削除
		--========================
		-- 削除した仕掛品ロット番号をキーに、使用予実トランのデータを削除する
		DELETE tr_shiyo_yojitsu
		WHERE data_key_tr_shikakari = @data_key


		--========================
		-- 仕掛品計画サマリの削除
		--========================

		-- 自分以外の合算データがない場合は、サマリと使用予実の実績をDELETE
		IF (select TOP 1
			tr.no_lot_shikakari
			FROM tr_keikaku_shikakari tr
			WHERE tr.no_lot_shikakari = @no_lot
			AND tr.data_key <> @data_key) IS NULL
		BEGIN
			-- 仕掛品計画サマリ
			DELETE su_keikaku_shikakari
			WHERE no_lot_shikakari = @no_lot

			-- 使用予実トラン
			DELETE tr_shiyo_yojitsu
			WHERE no_lot_shikakari = @no_lot

			-- 「0」を返却
			SELECT @return_val AS wt_shikomi_keikaku
		END
		ELSE BEGIN
			-- 削除した仕掛品トランデータの計画仕込重量の分、サマリの計画仕込重量から引く
			UPDATE su_keikaku_shikakari
			SET wt_shikomi_keikaku = wt_shikomi_keikaku - @wt_shikomi
				,wt_hitsuyo = wt_shikomi_keikaku - @wt_shikomi
			WHERE no_lot_shikakari = @no_lot

			--==============================================
			-- 更新後の仕掛品計画サマリの計画仕込重量を返却
			--==============================================
			SELECT wt_shikomi_keikaku FROM su_keikaku_shikakari
			WHERE no_lot_shikakari = @no_lot
		END

	END
	ELSE BEGIN
		-- @no_lotがnullまたは空文字だった場合は削除処理を行わず「0」を返却
		SELECT @return_val AS wt_shikomi_keikaku
	END

END
GO
