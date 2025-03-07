IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_Hyoryo_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_Hyoryo_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：秤量画面 小分実績消去
ファイル名	：@usp_Hyoryo_delete
入力引数	：@no_lot_parent
出力引数	：
戻り値		：失敗時[0以外のエラーコード]
作成日		：2013.10.28  ADMAX okuda.k
更新日		：
*****************************************************/
CREATE  PROCEDURE [dbo].[usp_Hyoryo_delete]
(
	@no_lot_parent	VARCHAR(14)  --親ロット番号(ロット切替用)
)
AS
DECLARE	@no_lot_del	VARCHAR(14)

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
		DELETE FROM tr_kowake
		WHERE
			tr_kowake.no_lot_kowake = @no_lot_del

		DELETE FROM tr_lot
		WHERE
			no_lot_jisseki = @no_lot_del

		FETCH  cur_deljiseki INTO @no_lot_del
	END

	CLOSE cur_deljiseki
	DEALLOCATE cur_deljiseki

END
GO
