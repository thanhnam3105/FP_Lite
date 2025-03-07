IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KowakeJisseki_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KowakeJisseki_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：小分け実績 消去
ファイル名	：usp_KowakeJisseki_delete
入力引数	：@no_lot_kowake, @no_lot_parent
出力引数	：
戻り値		：失敗時[0以外のエラーコード]
作成日		：2013.10.17  ADMAX  okuda.k
更新日		：
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_KowakeJisseki_delete]
(
	@no_lot_kowake	VARCHAR(14) --小分けロット番号
	,@no_lot_parent	VARCHAR(14) --親ロット番号(ロット切替用)
)
AS
BEGIN

	DECLARE	@no_lot_del	VARCHAR(14)

	IF @no_lot_parent = '' 
	BEGIN
		DELETE FROM tr_lot 
		WHERE
			no_lot_jisseki = @no_lot_kowake

		DELETE FROM tr_kowake
		WHERE
			no_lot_kowake = @no_lot_kowake
	END
	ELSE
	BEGIN
		DECLARE cur_deljiseki CURSOR FOR
		SELECT
			tk.no_lot_kowake
		FROM tr_kowake tk
		WHERE
			no_lot_oya = @no_lot_parent

		OPEN cur_deljiseki
		FETCH cur_deljiseki INTO @no_lot_del

		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM tr_lot
			WHERE
				no_lot_jisseki = @no_lot_del

			FETCH cur_deljiseki INTO @no_lot_del
		END

		CLOSE cur_deljiseki
		DEALLOCATE cur_deljiseki

		DELETE FROM tr_kowake
		WHERE
			no_lot_oya = @no_lot_parent
	END
END
GO
