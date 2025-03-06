IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanHyoryoKeikaku_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：原料残秤量（計画変更） 小分実績削除処理
ファイル名	：usp_GenryozanHyoryoKeikaku_delete
入力引数	：@no_lot_kowake, @no_lot_oya
出力引数	：
戻り値		：
作成日		：2013.11.27  ADMAX shinohara.m
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_delete]
(
	@no_lot_kowake	VARCHAR(14)
	,@no_lot_oya	VARCHAR(14)
)
AS
BEGIN
	IF @no_lot_oya IS NULL
		OR @no_lot_oya = ''
	BEGIN
		--画面処理で、小分実績トランを取得した時に親ロットが無い場合
		DELETE FROM tr_lot
		WHERE
			no_lot_jisseki = @no_lot_kowake

		DELETE FROM tr_kowake
		WHERE
			no_lot_kowake  = @no_lot_kowake
	END
	ELSE
	--画面処理で、小分実績トランを取得した時に親ロットがある場合
	BEGIN
		--小分実績トランから親ロットを使って抽出
		DECLARE del_cursor CURSOR FOR
		SELECT
			no_lot_kowake
		FROM tr_kowake
		WHERE
			no_lot_oya = @no_lot_oya

		--親にぶら下がる小分けロット番号をカーソルに定義
		OPEN del_cursor
		FETCH NEXT FROM del_cursor
		INTO @no_lot_kowake

		--混合実績トランから削除処理を繰り返す
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM tr_lot
			WHERE
				no_lot_jisseki = @no_lot_kowake

			FETCH NEXT FROM del_cursor
			INTO @no_lot_kowake
		END

		--終了処理
		CLOSE del_cursor
		DEALLOCATE del_cursor

		--小分実績トランから親ロットをキーに削除
		DELETE FROM tr_kowake
		WHERE
			no_lot_oya = @no_lot_oya
	END
END
GO
