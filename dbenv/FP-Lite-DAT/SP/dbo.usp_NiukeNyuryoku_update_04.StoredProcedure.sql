IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_update_04') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_update_04]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：荷受入力　在庫数調整を行います。
ファイル名	：usp_NiukeNyuryoku_update_04
入力引数	：@no_niuke, @zaiko_kanzan, @kgKanzanKbn
出力引数	：
戻り値		：
作成日		：2013.11.19  ADMAX kakuta.y
更新日		：
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_update_04]
	@no_niuke					VARCHAR(14)	-- 在庫調整を行うデータの荷受番号
	,@kbn_zaiko					SMALLINT	-- 調整をする任意の在庫区分
	,@kbn_nyushukko				SMALLINT	-- 調整を終える任意の入出庫区分
	,@kgKanzanKbn				VARCHAR(2)	-- コード一覧．換算区分．Kg
	,@lKanzanKbn				VARCHAR(2)	-- コード一覧．換算区分．L
AS
BEGIN

	DECLARE @endNoSeq			DECIMAL(8,0)	-- 在庫変動で影響する最後のシーケンス番号
	DECLARE @endKbnNyushukko	SMALLINT		-- 在庫変動で影響する最後の入出庫区分
	DECLARE @dynmcNoSeq			DECIMAL(8,0)	-- while文で加算していくシーケンス番号。@endNoSeqと同じになった場合に処理を中止します。
	DECLARE @su_iri				DECIMAL(8,0)	-- 入数(1000を乗算する場合があるので8桁分確保します)
	DECLARE @cd_tani_nonyu		VARCHAR(10)		-- 原資材購入先マスタの納入単位コード
	DECLARE @totalZaiko			DECIMAL(10,2)	-- シーケンス番号が一つ前の在庫総数
	DECLARE @totalNonyu			DECIMAL(10,2)	-- 算出するレコードの実納入総数
	DECLARE @totalShukko		DECIMAL(10,2)	-- 算出するレコードの出庫総数
	DECLARE @setZaiko			DECIMAL(10,2)	-- 算出した在庫総数
	DECLARE @maxSu				DECIMAL(7,0)	-- 在庫数・端数の最大値格納用変数
	DECLARE @newZaiko			DECIMAL(8,0)	-- セットする在庫数用変数
	DECLARE @newZaikoHasu		DECIMAL(8,0)	-- セットする在庫端数用変数
	DECLARE @cd_niuke_basho		VARCHAR(10)		-- Place current inventory
	
	SET @maxSu = 9999999;

	-- シーケンス番号の初期値取得(仕入・外移入は調整しません。)
	SELECT
		@dynmcNoSeq = MIN(no_seq) + 1
	FROM tr_niuke
	WHERE
		no_niuke = @no_niuke

	--Place current inventory
	SELECT
		@cd_niuke_basho = cd_niuke_basho
	FROM tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND no_seq = @dynmcNoSeq - 1

	-- 入数と納入単位コードの取得
	SELECT
		@su_iri = m_ko.su_iri
		,@cd_tani_nonyu	= m_ko.cd_tani_nonyu
	FROM ma_konyu m_ko
	INNER JOIN tr_niuke t_niu
	ON m_ko.cd_hinmei = t_niu.cd_hinmei
	AND m_ko.cd_torihiki = t_niu.cd_torihiki
	WHERE
		t_niu.no_niuke = @no_niuke
		AND	t_niu.kbn_zaiko = @kbn_zaiko
		AND t_niu.no_seq =
		(
			SELECT
				MIN(no_seq) AS no_seq
			FROM tr_niuke
			WHERE
				no_niuke = @no_niuke
				AND kbn_zaiko = @kbn_zaiko
		)
	-- 入数が0の場合は1をセットし、納入単位が「Kg」「L」のものは「g」「ml」に合わせます。
	IF @su_iri = 0 
		OR @su_iri IS NULL
	BEGIN
		SET @su_iri = 1
	END

	IF @cd_tani_nonyu = @kgKanzanKbn 
		OR @cd_tani_nonyu = @lKanzanKbn
		
	BEGIN
		SET @su_iri = @su_iri * 1000
	END
		
	-- 調整を行う最後のシーケンス番号
	SELECT
		TOP 1 
		@endNoSeq =	
			CASE kbn_nyushukko
				WHEN @kbn_nyushukko THEN (no_seq - 1)
				ELSE no_seq
			END 
	FROM tr_niuke
	WHERE
		no_niuke = @no_niuke
		AND(kbn_nyushukko = @kbn_nyushukko OR no_seq =
		(
			SELECT
				MAX(no_seq)
			FROM tr_niuke
			WHERE
				no_niuke = @no_niuke
		))
	ORDER BY
		no_seq

	-- 在庫調整処理( 在庫数 = 一つ前の在庫数 + 実納入総数 - 出庫総数 )
	WHILE (@dynmcNoSeq <= @endNoSeq)
		BEGIN
			
			-- 一つ前の在庫総数を算出
			SELECT
				@totalZaiko = ( ISNULL(su_zaiko, 0) * @su_iri + ISNULL(su_zaiko_hasu, 0) )
			FROM tr_niuke
			WHERE
				no_niuke = @no_niuke
				AND kbn_zaiko = @kbn_zaiko
				AND no_seq = (@dynmcNoSeq - 1)
				AND cd_niuke_basho = @cd_niuke_basho
						
			-- 在庫数算出用の実納入総数と出庫総数
			SELECT
				@totalNonyu = ( ISNULL(su_nonyu_jitsu, 0) * @su_iri + ISNULL(su_nonyu_jitsu_hasu, 0))
				,@totalShukko = ( ISNULL(su_shukko, 0) * @su_iri + ISNULL(su_shukko_hasu, 0) )
			FROM tr_niuke
			WHERE
				no_niuke = @no_niuke
				AND kbn_zaiko = @kbn_zaiko
				AND no_seq = @dynmcNoSeq
				AND cd_niuke_basho = @cd_niuke_basho
			
			-- 在庫換算数の算出	
			SET @setZaiko = @totalZaiko + @totalNonyu - @totalShukko
			SET @newZaiko = ROUND((@setZaiko / @su_iri),0,1)
			SET @newZaikoHasu = (@setZaiko % @su_iri)
			
			-- 在庫数がオーバーフローするのをふせぎます。
			IF @newZaiko > @maxSu
			BEGIN
				SET @newZaiko = @maxSu
			END
			IF @newZaikoHasu > @maxSu
			BEGIN
				SET @newZaikoHasu = @maxSu
			END
			
			-- 在庫調整
			UPDATE tr_niuke
			SET
				su_zaiko = ROUND((@setZaiko / @su_iri),0,1)
				,su_zaiko_hasu = (@setZaiko % @su_iri)
			WHERE
				no_niuke = @no_niuke
				AND kbn_zaiko = @kbn_zaiko
				AND no_seq = @dynmcNoSeq
				AND cd_niuke_basho = @cd_niuke_basho

			-- インデックスのインクリメント
			SET @dynmcNoSeq = @dynmcNoSeq + 1;
		END
END
GO
