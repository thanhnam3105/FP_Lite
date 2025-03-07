IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　在庫数チェックを行います。
ファイル名	：usp_NiukeNyuryoku_update_03
入力引数	：@no_niuke, @zaiko_kanzan, @kgKanzanKbn
			  , @lKanzanKbn, @shiyoMishiyoFlg, @ryohinZaikoKbn
			  , @kakozanNyushukkoKbn, @minusCount
出力引数	：@minusCount
戻り値		：
作成日		：2013.11.12  ADMAX kakuta.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_03]
	@no_niuke				VARCHAR(14)				-- 明細(実績)荷受番号	
	,@zaiko_kanzan			DECIMAL(18,2)			-- 在庫換算数
	,@kgKanzanKbn			VARCHAR(10)				-- コード一覧/換算区分.Kg
	,@lKanzanKbn			VARCHAR(10)				-- コード一覧/換算区分.L
	,@shiyoMishiyoFlg		SMALLINT				-- コード一覧/未使用フラグ.使用
	,@ryohinZaikoKbb		SMALLINT				-- コード一覧/在庫区分.良品
	,@kakozanNyushukkoKbn	SMALLINT				-- コード一覧/入出庫区分.加工残
AS
BEGIN

	DECLARE	@sabun 			DECIMAL(18,0)
			,@kakozan_seq 	DECIMAL(9,0)
			,@min_no_seq	DECIMAL(8,0)
			,@minusCount	DECIMAL(10,0)  	-- 在庫編集によって在庫がマイナスになるレコード数

	DECLARE @cd_niuke_basho VARCHAR(10)
		, @kbn_zaiko	SMALLINT

	SELECT 
		@cd_niuke_basho = niuke.cd_niuke_basho
		, @kbn_zaiko = niuke.kbn_zaiko
	FROM tr_niuke niuke
	WHERE
		no_niuke = @no_niuke
		AND no_seq = 1

	-- 荷受トランの最小シーケンス番号の取得
	SELECT
		@min_no_seq = MIN(no_seq)
	FROM tr_niuke

	-- 差分算出処理を行います。
	SELECT
		@sabun = CASE
					WHEN m_ko.cd_tani_nonyu = @kgKanzanKbn
							OR m_ko.cd_tani_nonyu = @lKanzanKbn
						THEN @zaiko_kanzan - (( t_niu.su_zaiko * m_ko.su_iri * 1000 ) + t_niu.su_zaiko_hasu )
					ELSE @zaiko_kanzan - (( t_niu.su_zaiko * m_ko.su_iri ) + t_niu.su_zaiko_hasu )
				 END
					
	FROM tr_niuke t_niu
	INNER JOIN ma_konyu m_ko
	ON t_niu.cd_hinmei = m_ko.cd_hinmei
	AND t_niu.cd_torihiki = m_ko.cd_torihiki
	AND m_ko.flg_mishiyo = @shiyoMishiyoFlg
			
	WHERE
		t_niu.no_niuke = @no_niuke 
		AND t_niu.kbn_zaiko = @ryohinZaikoKbb 
		AND t_niu.no_seq = @min_no_seq
		AND m_ko.flg_mishiyo = @shiyoMishiyoFlg

	-- 加工残シーケンス番号取得処理を行います。
	SELECT
		@kakozan_seq = MIN(no_seq) 
	FROM tr_niuke 
	WHERE 
		no_niuke = @no_niuke 
		AND no_seq > @min_no_seq 
		AND kbn_nyushukko = @kakozanNyushukkoKbn

	-- 入出庫区分.加工残のものがない場合は最新のシーケンス番号に1加算したものを代わりにします。
	IF @kakozan_seq IS NULL
	 
		BEGIN
			SELECT
				@kakozan_seq = MAX(no_seq) + 1 
			FROM tr_niuke 
			WHERE
				no_niuke = @no_niuke
		END

	-- 在庫数がマイナスになるレコードの数を取得します。
	SELECT
		@minusCount = COUNT(*) 
	FROM
		(
			SELECT
				t_niu.no_niuke no_niuke
				,t_niu.no_seq no_seq
				,CASE
					WHEN m_ko.cd_tani_nonyu = @kgKanzanKbn 
						OR m_ko.cd_tani_nonyu	= @lKanzanKbn
						THEN ( t_niu.su_zaiko * m_ko.su_iri * 1000 + t_niu.su_zaiko_hasu )
					ELSE ( t_niu.su_zaiko * m_ko.su_iri + t_niu.su_zaiko_hasu )	
				END kanzan
			FROM tr_niuke t_niu
			INNER JOIN ma_konyu m_ko
			ON t_niu.cd_hinmei = m_ko.cd_hinmei 
			AND t_niu.cd_torihiki = m_ko.cd_torihiki
			AND m_ko.flg_mishiyo = @shiyoMishiyoFlg
			WHERE
				no_niuke = @no_niuke
				AND kbn_zaiko = @ryohinZaikoKbb
				AND no_seq > @min_no_seq 
				AND no_seq < @kakozan_seq
				AND kbn_zaiko = @kbn_zaiko
				AND cd_niuke_basho = @cd_niuke_basho
		) t_niu_kanzan
	WHERE 
		( t_niu_kanzan.kanzan + @sabun ) < 0


	SELECT @minusCount AS minusCount;
END
GO
