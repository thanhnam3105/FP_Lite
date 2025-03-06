IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotTrace_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotTrace_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能			：仕込日葡画面　トレース用ロットトランで削除処理
ファイル名		：usp_LotTrace_delete
入力引数		：no_lot_shikakari
作成日		：2016.04.11  Khang
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotTrace_delete]
	@no_lot_shikakari	varchar(14)	-- 削除条件：仕掛品ロット番号
AS
BEGIN

	-- 製品ロット番号が存在する場合：製造日報からの削除時
	IF LEN(@no_lot_shikakari) > 0
	BEGIN
		-- 仕込日報からの削除時：仕掛品ロット番号で一括削除
		DELETE
			tr_lot_trace
		WHERE
			no_lot_shikakari = @no_lot_shikakari
	END

END
GO
