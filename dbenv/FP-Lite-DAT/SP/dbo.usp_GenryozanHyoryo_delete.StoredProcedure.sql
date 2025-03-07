IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanHyoryo_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanHyoryo_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：原料残秤量　残実績トラン、混合ロット実績トランデータを削除します。
ファイル名  ：usp_GenryozanHyoryo_delete
入力引数    ：@no_lot, @cd_hinmei          
出力引数    ：
戻り値      ：
作成日      ：2014.06.20  ADMAX endo.y
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanHyoryo_delete] 
	  @no_lot			VARCHAR(14)
	, @cd_hinmei		VARCHAR(14)
AS
BEGIN
	DELETE tzj
	FROM tr_zan_jiseki tzj
	INNER JOIN tr_lot tl
		ON tl.no_lot_jisseki = tzj.no_lot_zan
	WHERE cd_hinmei = @cd_hinmei
		AND tl.no_lot = @no_lot

	DELETE
	FROM tr_lot
	WHERE no_lot = @no_lot
		AND no_lot_jisseki LIKE 'Z%'
END
GO
