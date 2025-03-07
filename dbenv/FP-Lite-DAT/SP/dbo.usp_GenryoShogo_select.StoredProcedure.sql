IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryoShogo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryoShogo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：秤量画面 秤量検索
ファイル名	：usp_GenryoShogo_select
入力引数	：@no_lot, @cd_hinmei, @flg_haki
出力引数	：
戻り値		：失敗時[0以外のエラーコード]
作成日		：2014.06.20  ADMAX endo.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryoShogo_select]
(
	@no_lot		VARCHAR(14)  --ロット番号
	,@cd_hinmei	VARCHAR(14)  --原料コード
	,@flg_haki	INT          --破棄フラグ
)
AS 
BEGIN
	SELECT tzj.no_lot_zan
	FROM tr_zan_jiseki tzj
	INNER JOIN tr_lot tl
	ON tl.no_lot_jisseki = tzj.no_lot_zan 
	WHERE cd_hinmei = @cd_hinmei
	AND no_lot = @no_lot
	AND flg_haki = @flg_haki
END
GO
