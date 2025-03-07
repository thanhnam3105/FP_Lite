IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanIchiran_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanIchiran_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：原料残一覧画面　削除
ファイル名	：usp_GenryozanIchiran_delete
入力引数	：@no_lot_zan
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.11.22 ADMAX onodera.s
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanIchiran_delete] 
	@no_lot_zan	VARCHAR(14) --残ロット番号
AS
BEGIN
	-- 残実績トランから対象データを削除
	DELETE FROM tr_zan_jiseki
	WHERE
		no_lot_zan = @no_lot_zan

	-- 混合ロット実績トランから対象データを削除
	DELETE FROM tr_lot
	WHERE
		no_lot_jisseki = @no_lot_zan

END
GO
