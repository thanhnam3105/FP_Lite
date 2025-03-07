IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippo_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippo_delete]
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
更新日：2014.10.30 tsujita.s
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_SeizoNippo_delete]
    @FlagTrue smallint --確定フラグ「確定」
	,@dt_seizo datetime --製造日
	,@cd_hinmei varchar(14) --品名コード
	,@no_lot_seihin varchar(14) --製品ロット番号
	,@JissekiYojitsuFlag smallint --予実フラグ「実績」
AS
BEGIN

	-- UTC日付へフォーマット
	SET @dt_seizo = DATEADD(SECOND, DATEDIFF(SECOND, GETDATE(), GETUTCDATE()), @dt_seizo)

	DECLARE @flg_jisseki smallint
	-- 確定フラグを取得する
	SELECT @flg_jisseki = flg_jisseki
	FROM tr_keikaku_seihin
	WHERE no_lot_seihin = @no_lot_seihin
		
	/*******************************************
		製品計画トラン　削除
	*******************************************/
	DELETE tr_keikaku_seihin
	WHERE no_lot_seihin = @no_lot_seihin

	/*******************************************
		使用予実トラン　削除
	*******************************************/
	-- 確定データのみ削除実施
	IF @flg_jisseki = @FlagTrue
	BEGIN
		DELETE tr_shiyo_yojitsu
		WHERE flg_yojitsu = @JissekiYojitsuFlag
			AND no_lot_seihin = @no_lot_seihin
			AND no_lot_shikakari IS NULL
	END


END
GO
