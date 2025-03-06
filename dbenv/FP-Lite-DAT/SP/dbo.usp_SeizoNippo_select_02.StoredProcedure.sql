IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippo_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippo_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        	：製造日報 削除対象の荷受番号がトレース用ロットトランの存在をチェックします。
ファイル名  	：usp_SeizoNippo_select_02
入力引数    	：@no_niuke
出力引数    	：
戻り値      	：
作成日      	：2016.04.14  Khang
更新日      	：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_SeizoNippo_select_02] 
	@no_niuke		VARCHAR(14)
	,@flg_jisseki	SMALLINT
AS

BEGIN
	DECLARE @flg_jisseki_old SMALLINT

	SET @flg_jisseki_old = ( SELECT flg_jisseki FROM tr_keikaku_seihin WHERE no_lot_seihin = @no_niuke )

	-- 確定チェックが外されていた場合だけを取ります
	IF (@flg_jisseki_old = 1 AND @flg_jisseki = 0)
	BEGIN
		SELECT		
			TRACE.no_niuke AS no_lot_seihin	--製品ロット番号
			,KEIKAKU.no_lot_shikakari		--仕掛品ロット番号
			,KEIKAKU.dt_seizo				--仕込日
		FROM 
		(
			SELECT DISTINCT
				no_lot_shikakari
				,no_niuke
			FROM tr_lot_trace 
			WHERE no_niuke = @no_niuke
		) TRACE

		INNER JOIN su_keikaku_shikakari KEIKAKU
		ON TRACE.no_lot_shikakari = KEIKAKU.no_lot_shikakari
	END
	ELSE
	BEGIN
		SELECT		
			NULL AS no_lot_seihin			--製品ロット番号
			,NULL AS no_lot_shikakari		--仕掛品ロット番号
			,NULL AS dt_seizo				--仕込日
	END

END

GO