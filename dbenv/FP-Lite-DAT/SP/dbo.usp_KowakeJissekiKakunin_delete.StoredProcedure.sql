IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KowakeJissekiKakunin_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KowakeJissekiKakunin_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：小分実績確認 削除
ファイル名	：usp_KowakeJissekiKakunin_delete
入力引数	：@no_lot_kowake, @no_lot_oya
出力引数	：
戻り値		：
作成日		：2013.10.15  ADMAX kakuta.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KowakeJissekiKakunin_delete] 
	@no_lot_kowake		VARCHAR(14) 
	,@no_lot_oya		VARCHAR(14)
AS
BEGIN
	
	IF @no_lot_oya IS NULL--ロット切り替えなし
	OR @no_lot_oya = ''
	BEGIN
		DELETE FROM tr_kowake							-- 小分実績トラン削除処理
		WHERE
			no_lot_kowake = @no_lot_kowake

		DELETE FROM tr_lot								-- 混合ロット実績トラン削除処理
		WHERE
			no_lot_jisseki = @no_lot_kowake

	END
	ELSE-- ロット切り替えあり
	BEGIN
		DELETE FROM tr_lot								-- 混合ロット実績トラン削除処理
		WHERE no_lot_jisseki IN
			(
				SELECT
					no_lot_kowake
				FROM tr_kowake
				WHERE
					no_lot_oya = @no_lot_oya
			)

		DELETE FROM tr_kowake							-- 小分実績トラン削除処理(親ロット番号)
		WHERE
			no_lot_oya = @no_lot_oya
	END
END
GO
