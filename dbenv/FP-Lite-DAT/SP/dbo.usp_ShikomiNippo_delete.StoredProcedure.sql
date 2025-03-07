IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikomiNippo_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikomiNippo_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************
機能：製造日報画面　明細削除処理
ファイル名：usp_SizoNippo_delete
入力引数：@FlgKakuteiKakutei, @dt_seizo, @cd_hinmei, @no_lot_seihin
出力引数：-
戻り値：-
作成日：2013.05.27 kasahara.a
更新日：2014.11.07 tsujita.s
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_ShikomiNippo_delete]
    @FlagTrue smallint --フラグTRUE
	,@dt_seizo datetime --製造日
	,@cd_shikakari_hin varchar(14) --仕掛品コード
	,@no_lot_shikakari varchar(14) --仕掛品ロット番号
    ,@JissekiYojitsuFlag smallint --予実フラグ：実績
    ,@GenryoHinKbn smallint --品区分：原料

AS
BEGIN

	DECLARE @flg_jisseki smallint
	-- 確定フラグを取得する
	SELECT @flg_jisseki = flg_jisseki
	FROM su_keikaku_shikakari
	WHERE no_lot_shikakari = @no_lot_shikakari

	/*******************************************
		仕掛品計画サマリー　削除
	*******************************************/
	DELETE su_keikaku_shikakari
	WHERE no_lot_shikakari = @no_lot_shikakari

	/*******************************************
		仕掛品計画トラン　削除
	*******************************************/
	DELETE tr_keikaku_shikakari
	WHERE no_lot_shikakari = @no_lot_shikakari

	/*******************************************
		使用予実トラン　削除
	*******************************************/
	-- 確定データのみ削除実施
	IF @flg_jisseki = @FlagTrue
	BEGIN
		DELETE tr_shiyo_yojitsu
		WHERE flg_yojitsu = @JissekiYojitsuFlag
			AND no_lot_seihin IS NULL
			AND no_lot_shikakari = @no_lot_shikakari
	END


END
GO
