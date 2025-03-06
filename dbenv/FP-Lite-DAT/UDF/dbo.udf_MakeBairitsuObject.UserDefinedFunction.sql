IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_MakeBairitsuObject') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_MakeBairitsuObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：レシピ展開処理支援用：バッチ数と倍率の計算
ファイル名 ：udf_MakeBairitsuObject
入力引数 ：@hitsuyoJuryo, @gokeiHaigoJuryo, @kihonBairitsu
出力引数 ：-
戻り値  ：@table_bairitsu_obj
作成日  ：2015.02.09 tsujita.s
更新日  ：2015.02.10 tsujita.s
更新日  ：2019.07.02 kanehira
更新日  ：2021.05.31 BRC.saito #1323対応
*****************************************************/
CREATE FUNCTION [dbo].[udf_MakeBairitsuObject]
	(
		@hitsuyoJuryo decimal(38, 19) -- 製造予定量、必要重量
		,@gokeiHaigoJuryo decimal(12, 6) -- 配合名マスタ．合計重量
		,@kihonBairitsu decimal(5, 2) -- 配合名マスタ．基本倍率
	)
-- 戻りテーブル
RETURNS @table_bairitsu_obj TABLE
    (
		batch decimal(12, 6) -- バッチ数
		,batch_hasu decimal(12, 6) -- バッチ端数
		,bairitsu decimal(12, 6) -- 倍率
		,bairitsu_hasu decimal(12, 6) -- 倍率端数
    )
AS
	BEGIN
		DECLARE @val_batch decimal(12, 6) = 0		-- バッチ数
		DECLARE @val_batch_hasu decimal(12, 6) = 0	-- バッチ端数
		DECLARE @val_bairitsu decimal(12, 6) = 0	-- 倍率
		DECLARE @val_bairitsu_hasu decimal(12, 6) = 0	-- 倍率端数
		DECLARE @val_su_seizo decimal(12, 6) = 0	-- 値判定用
		DECLARE @wt_haigo_keikaku_hasu decimal(12, 6) = 0	-- 計画配合重量端数


		IF  @kihonBairitsu <= 0
		BEGIN
			-- ///// 除算する値が0(基本倍率が0)になる場合1 /////
			SET @val_batch = 1
			SET @val_bairitsu = 1
		END
		ELSE BEGIN
			SET @val_su_seizo = (@hitsuyoJuryo / (@gokeiHaigoJuryo * @kihonBairitsu))
			-- ///// 製造予定数 / (配合名マスタ.合計配合重量 * 配合名マスタ.基本倍率) ≧ 1 のとき /////
			IF @val_su_seizo >= 1
			BEGIN
				-- バッチ数と倍率
				SET @val_batch = ROUND(@val_su_seizo, 0, 1)
				SET @val_bairitsu = @kihonBairitsu
				
				-- 計画配合重量端数
				SET @wt_haigo_keikaku_hasu = @hitsuyoJuryo - (@gokeiHaigoJuryo * @val_bairitsu * @val_batch)
				
				-- 倍率端数
				SET @val_bairitsu_hasu = 
					--CEILING (
						--(@wt_haigo_keikaku_hasu / @gokeiHaigoJuryo) * 1000000
					--) / 1000000
					CEILING (
						(@wt_haigo_keikaku_hasu / @gokeiHaigoJuryo) * 100
					) / 100
				
				-- バッチ端数
				-- 計画配合重量端数が存在する場合1、存在しない場合は0
				IF @wt_haigo_keikaku_hasu > 0
				BEGIN
					SET @val_batch_hasu = 1
				END
				
				-- 正規倍率と端数倍率が等しい場合
				-- 正規バッチ数に端数バッチ数を加算する
				IF @val_bairitsu = @val_bairitsu_hasu
				BEGIN
					SET @val_batch = @val_batch + @val_bairitsu_hasu
					SET @val_bairitsu_hasu = 0
					SET @val_batch_hasu = 0
				END
				
			END
			-- ///// 製造予定数 / (配合名マスタ.合計配合重量 * 配合名マスタ.基本倍率) ＜ 1 のとき /////
			ELSE BEGIN
				-- バッチ数（バッチ端数と倍率端数は0）
				SET @val_batch = 1
				-- 倍率
				-- calcKeikakuBairitsu = Math.Ceiling(data.hitsuyoJuryo / (gokeiHaigoJuryo * keikakuBatchSu) * 100m) / 100m;
				--SET @val_bairitsu = CEILING(@val_su_seizo * 1000000) / 1000000
				--SET @val_bairitsu = CEILING(@hitsuyoJuryo / (@gokeiHaigoJuryo * @val_batch) * 100) / 100
				SET @val_bairitsu = CEILING((ROUND(@hitsuyoJuryo / (@gokeiHaigoJuryo * @val_batch) * 10000 ,0) / 10000) * 10000) / 10000
			END
		END

        -- 戻りテーブルへ倍率オブジェクトを追加
		INSERT INTO @table_bairitsu_obj
        SELECT
            @val_batch
            ,@val_batch_hasu
            ,@val_bairitsu
            ,@val_bairitsu_hasu

	RETURN
	END
GO
