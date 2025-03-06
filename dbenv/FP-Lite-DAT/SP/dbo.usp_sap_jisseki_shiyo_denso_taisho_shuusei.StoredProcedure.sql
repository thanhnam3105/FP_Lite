IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_taisho_shuusei') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_shuusei]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：使用実績送信対象テーブル誤差修正処理
ファイル名	：usp_sap_jisseki_shiyo_denso_taisho_shuusei
入力引数	：
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.07.13 kaneko.m
更新日		：2018.12.12 BRC.kanehira 誤差を付与するデータ取得の条件（並び順）を修正
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_shuusei] 
AS
BEGIN

	-- 一時テーブル作成
	CREATE TABLE #tmp_anbun
	(
		[no_seq] [varchar](14) NOT NULL
		,[no_lot_shikakari] [varchar](14) NOT NULL
		,[kbn_shiyo_jisseki_anbun] [varchar](10) NOT NULL
		,[no_lot_seihin] [varchar](14) NULL
		,[dt_shiyo_shikakari] [datetime] NULL
		,[su_shiyo_shikakari] [decimal](12, 6) NOT NULL
		,[kbn_jotai_denso] [smallint] NOT NULL
		,[wt_shikomi_jisseki] [decimal](12, 6) NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[su_shiyo] [decimal](12, 6) NOT NULL
	)
	
	CREATE NONCLUSTERED INDEX idx_anbun1 ON #tmp_anbun (no_seq)

	CREATE TABLE #tmp_diff
	(
		[no_lot_shikakari] [varchar](14) NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[su_shiyo_sum] [decimal](12, 6) NOT NULL
		,[su_shiyo] [decimal](12, 6) NOT NULL
		,[diff] [decimal](12, 6) NULL
	)
	
	CREATE TABLE #tmp_taisho
	(
		[no_lot_seihin] [varchar](14) NULL
		,[no_lot_shikakari] [varchar](14) NULL
		,[dt_shiyo] [datetime] NULL
		,[cd_hinmei] [varchar](14) NULL
		,[su_shiyo] [decimal](12, 6) NULL
	)
	
	DECLARE @msg VARCHAR(500)		-- 処理結果メッセージ格納用
	DECLARE @dt_taisho DATETIME

	--SET @dt_taisho = DATEADD(DD, -60, GETDATE())
	SET @dt_taisho = DATEADD(DD, -60, GETUTCDATE())

	-- 案分情報取得
	INSERT INTO #tmp_anbun
	SELECT
		anbun.no_seq
		, anbun.no_lot_shikakari
		, anbun.kbn_shiyo_jisseki_anbun
		, anbun.no_lot_seihin
		, anbun.dt_shiyo_shikakari
		, anbun.su_shiyo_shikakari
		, anbun.kbn_jotai_denso
		, shikakari.wt_shikomi_jisseki
		, shiyo.cd_hinmei
		, shiyo.dt_shiyo
		, CEILING(shiyo.su_shiyo * (anbun.su_shiyo_shikakari / shikakari.wt_shikomi_jisseki) * 1000) / 1000 AS su_shiyo
	FROM tr_sap_shiyo_yojitsu_anbun anbun
	INNER JOIN (
		SELECT DISTINCT no_lot_shikakari 
		FROM tr_sap_shiyo_yojitsu_anbun
		WHERE dt_shiyo_shikakari >= @dt_taisho
	) taisho
	  ON taisho.no_lot_shikakari = anbun.no_lot_shikakari
	INNER JOIN su_keikaku_shikakari shikakari
	  ON shikakari.no_lot_shikakari = anbun.no_lot_shikakari
	INNER JOIN (
		SELECT
			no_lot_shikakari
			, dt_shiyo
			, cd_hinmei
			, SUM(su_shiyo) AS su_shiyo
		FROM tr_shiyo_yojitsu
		WHERE flg_yojitsu = 1
		GROUP BY no_lot_shikakari,dt_shiyo, cd_hinmei
	  ) shiyo
	  ON shiyo.no_lot_shikakari = anbun.no_lot_shikakari

	-- 一時案分トランと使用実績との差分（仕掛品ロット・品名コード単位）
	INSERT INTO #tmp_diff
	SELECT
		*
	FROM (
		SELECT
			summary.no_lot_shikakari
			, summary.cd_hinmei
			, summary.su_shiyo AS su_shiyo_sum
			, shiyo.su_shiyo
			, summary.su_shiyo - shiyo.su_shiyo AS diff
		FROM (
			SELECT
				no_lot_shikakari
				, cd_hinmei
				, SUM(su_shiyo) AS su_shiyo
			FROM #tmp_anbun
			GROUP BY no_lot_shikakari, cd_hinmei
		) summary
		INNER JOIN (
			SELECT
				no_lot_shikakari
				, cd_hinmei
				, CEILING(SUM(su_shiyo) * 1000) / 1000 AS su_shiyo
			FROM tr_shiyo_yojitsu
			WHERE flg_yojitsu = 1
			  AND no_lot_shikakari IS NOT NULL
			GROUP BY no_lot_shikakari,cd_hinmei
			) shiyo
		ON shiyo.no_lot_shikakari = summary.no_lot_shikakari
		AND shiyo.cd_hinmei = summary.cd_hinmei
	) foo
	WHERE su_shiyo <> su_shiyo_sum

	-- 仕掛品ロット、品名コードごとに調整対象の１件を選択
	-- 案分から出したデータ-案分と使用実績の差分
	-- 誤差修正後の案分データ
	INSERT INTO #tmp_taisho
	SELECT
		foo.no_lot_seihin
		, foo.no_lot_shikakari
		, foo.dt_shiyo
		, foo.cd_hinmei
		, foo.su_shiyo - ISNULL(diff.diff, 0) AS su_shiyo
	FROM (
		SELECT
			*
			--, ROW_NUMBER() OVER(PARTITION BY no_lot_shikakari, cd_hinmei ORDER BY su_shiyo_shikakari DESC) AS RN
			, ROW_NUMBER() OVER(PARTITION BY no_lot_shikakari, cd_hinmei ORDER BY su_shiyo_shikakari DESC, no_lot_seihin DESC) AS RN
		FROM #tmp_anbun
		WHERE no_lot_seihin IS NOT NULL
		) foo
	LEFT OUTER JOIN #tmp_diff diff
	  ON foo.RN = 1
	  AND diff.no_lot_shikakari = foo.no_lot_shikakari
	  AND diff.cd_hinmei = foo.cd_hinmei
	  
	  
	-- 対象トランを更新
	UPDATE tr_sap_jisseki_shiyo_denso_taisho
	SET su_shiyo = tmp.su_shiyo
	FROM tr_sap_jisseki_shiyo_denso_taisho taisho
	INNER JOIN (
		SELECT
			no_lot_seihin
			, dt_shiyo
			, cd_hinmei
			, CEILING(SUM(su_shiyo) * 1000) / 1000 AS su_shiyo 
		FROM #tmp_taisho
		GROUP BY no_lot_seihin, dt_shiyo, cd_hinmei
	) tmp
	  ON tmp.no_lot_seihin = taisho.no_lot_seihin
	  AND tmp.dt_shiyo = taisho.dt_shiyo
	  AND tmp.cd_hinmei = taisho.cd_hinmei
	WHERE taisho.su_shiyo <> tmp.su_shiyo
	
	-- 一時テーブルの削除
	DROP TABLE #tmp_anbun
	DROP TABLE #tmp_diff
	DROP TABLE #tmp_taisho

	RETURN

	-- //////////// --
	--  エラー処理
	-- //////////// --
	Error_Handling:
		CLOSE cursor_denso
		DEALLOCATE cursor_denso
		PRINT @msg

		RETURN

END