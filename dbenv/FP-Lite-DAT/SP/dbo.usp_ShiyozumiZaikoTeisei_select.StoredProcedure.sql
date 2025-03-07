IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyozumiZaikoTeisei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyozumiZaikoTeisei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：使用済在庫訂正の保存前検索
ファイル名	：usp_ShiyozumiZaikoTeisei_select
入力引数	：@no_niuke, @kbn_zaiko
出力引数	：
戻り値		：
作成日		：2013.09.24  ADMAX endo.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ShiyozumiZaikoTeisei_select] 
    @no_niuke	VARCHAR(14)
	,@kbn_zaiko	SMALLINT
AS
BEGIN
	SELECT 
		kbn_nyushukko
		,dt_niuke
		,tm_nonyu_jitsu
		,
			(
				SELECT
					MAX(no_seq)
				FROM tr_niuke
				WHERE
					no_niuke = @no_niuke
			) AS no_seq
	FROM tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND no_seq =
		(
			SELECT
				MAX(no_seq)
			FROM tr_niuke
			WHERE
				no_niuke = @no_niuke
				AND kbn_zaiko = @kbn_zaiko
		)
		AND kbn_zaiko = @kbn_zaiko
		AND su_zaiko = 0
		AND su_zaiko_hasu = 0
END
GO
