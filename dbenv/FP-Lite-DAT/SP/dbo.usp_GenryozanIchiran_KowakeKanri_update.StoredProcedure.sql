IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanIchiran_KowakeKanri_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanIchiran_KowakeKanri_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：原料残一覧画面 更新 破棄フラグの更新を行う
ファイル名	：usp_GenryozanIchiran_KowakeKanri_update
入力引数	：@no_lot_zan, @flg_haki, @taishogaiHakiFlg
              , @taishoHakiFlg
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2013.10.30 ADMAX onodera.s
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanIchiran_KowakeKanri_update] 
	@no_lot_zan			VARCHAR(14) --残ロット番号
	,@flg_haki			SMALLINT    --破棄フラグ
	,@taishogaiHakiFlg	SMALLINT    --破棄フラグ（破棄対象外）
	,@taishoHakiFlg	 	SMALLINT    --破棄フラグ（破棄対象）
AS
BEGIN
	-- 残ロット番号が一致するものに更新をかける
	UPDATE tr_zan_jiseki
	SET
		flg_haki = @flg_haki
	WHERE
		no_lot_zan = @no_lot_zan
END
GO
