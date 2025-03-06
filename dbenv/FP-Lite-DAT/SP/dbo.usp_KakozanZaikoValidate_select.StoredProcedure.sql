IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_KakozanZaikoValidate_select]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[usp_KakozanZaikoValidate_select]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*****************************************************
機能        ：加工残 バリデーション 必要在庫数の取得
ファイル名  ：usp_KakozanZaikoValidate_select
入力引数    ：@no_niuke,@kbn_zaiko,@dt_hizuke,@kbn_nyushukko_kakozan
出力引数    ：
戻り値      ：hitsuyo_zaiko,hitsuyo_zaiko_hasu
作成日      ：2019.02.20  brc kanehira
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KakozanZaikoValidate_select]
	@no_niuke					VARCHAR(14)		-- 荷受ロット番号
	,@kbn_zaiko					SMALLINT		-- 在庫区分
	,@dt_hizuke					DATETIME		-- 在庫訂正日
	,@kbn_nyushukko_kakozan		SMALLINT		-- 入出庫区分（加工残）
AS
BEGIN
	
	-- 変数定義
	DECLARE
		@no_seq_min_kakozan		DECIMAL(8,0)
		,@no_seq_max_kakozan	DECIMAL(8,0)
	
	-- 対象データの最小のシーケンスNo.
	SELECT
		@no_seq_min_kakozan = MIN(no_seq)
	FROM
		tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND dt_niuke > @dt_hizuke
	
	-- 対象加工残データの最大のシーケンスNo.
	SELECT
		@no_seq_max_kakozan = MIN(no_seq)
	FROM
		tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND kbn_nyushukko = @kbn_nyushukko_kakozan
		AND dt_niuke > @dt_hizuke
	
	-- 加工残データの最大のシーケンスNo.が取得できない場合
	IF @no_seq_max_kakozan IS NULL
	BEGIN
	
		-- 対象データの最大のシーケンスNo.を取得
		SELECT
			@no_seq_max_kakozan = MAX(no_seq)
		FROM
			tr_niuke
		WHERE
			no_niuke = @no_niuke
			
	END
	
	-- 最大のシーケンスNo.がNULLの場合
	IF @no_seq_min_kakozan IS NULL
	BEGIN
	
		-- 必要在庫を0で返す
		SELECT 
			CONVERT(DECIMAL(9,2), 0) AS hitsuyo_zaiko
			,CONVERT(DECIMAL(9,2), 0) AS hitsuyo_zaiko_hasu
		RETURN
		
	END
	
	-- 出庫数合計を取得する
	SELECT
		CONVERT(DECIMAL(9,2), SUM(su_shukko)) AS hitsuyo_zaiko
		,CONVERT(DECIMAL(9,2), SUM(su_shukko_hasu)) AS hitsuyo_zaiko_hasu
	FROM
		tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND kbn_zaiko = @kbn_zaiko
		AND no_seq BETWEEN @no_seq_min_kakozan AND @no_seq_max_kakozan
	RETURN  
END

GO

