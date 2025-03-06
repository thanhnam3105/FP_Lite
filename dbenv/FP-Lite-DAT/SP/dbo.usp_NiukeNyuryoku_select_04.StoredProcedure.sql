IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_04') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_04]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：荷受入力 削除対象の荷受番号がトレース用ロットトランの存在をチェックします。
ファイル名  ：usp_NiukeNyuryoku_select_04
入力引数    ：@no_niuke
出力引数    ：
戻り値      ：
作成日      ：2016.03.23  Khang
更新日      ：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_04] 
	@no_niuke				VARCHAR(14)
AS

BEGIN
	SELECT
		NIUKE.dt_niuke					--荷受日
		,NIUKE.tm_nonyu_jitsu			--納入実
		,NIUKE.no_lot					--ロット番号
		,KEIKAKU.no_lot_shikakari		--仕掛品ロット番号
		,KEIKAKU.dt_seizo				--仕込日
		,KEIKAKU.cd_shikakari_hin		--仕掛品コード
	FROM 
	(
		SELECT
			no_lot_shikakari
			,no_niuke
		FROM tr_lot_trace 
		WHERE no_niuke = @no_niuke
	) TRACE

	LEFT OUTER JOIN su_keikaku_shikakari KEIKAKU
	ON TRACE.no_lot_shikakari = KEIKAKU.no_lot_shikakari

	LEFT OUTER JOIN tr_niuke NIUKE
	ON TRACE.no_niuke = NIUKE.no_niuke
END

GO