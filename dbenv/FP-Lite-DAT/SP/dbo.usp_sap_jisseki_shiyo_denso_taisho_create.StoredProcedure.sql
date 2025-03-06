IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：使用実績送信対象テーブル作成処理
ファイル名	：usp_sap_jisseki_shiyo_denso_taisho_create
入力引数	：
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.07.13 kaneko.m
更新日      ：2015.08.21 Hirai.a 削除は伝送区分変更なく伝送
更新日      ：2015.10.07 ADMAX taira.s 品名マスタ.テスト品=1のデータを取り込まないように修正
更新日      ：2015.10.09 kaneko.m 使用実績シーケンス番号を新規かつ伝送対象にのみ付番するよう変更
更新日      ：2015.10.27 kaneko.m 伝送データの単位を納入単位から使用単位に修正
更新日      ：2015.12.17 ADMAX shibao.s 仕掛残の使用実績を取得するように変更
更新日		：2015.12.28 Hirai.a 使用実績伝送の差分判断を製品ロット単位に変更。
更新日　　　：2016.01.04 Hirai.a 条件の日付を60日に統一
更新日		：2016.01.27 Hirai.a @densoTableを原料、資材に分割し、原料にはkbn_denso_jotaiを追加
更新日		：2017.03.06 cho.k Q&BサポートNo.47対応
更新日		：2017.10.10 sato.s Q&BサポートNo.05/KPMサポートNo.019/Q&BサポートNo.060/Q&BサポートNo.063/Q&BサポートNo.071/KPMサポートNo.031
更新日		：2018.02.20 tokumoto.k Q&BサポートNo.73対応
更新日		：2018.07.30 tokumoto.k Q&BサポートNo.195対応
更新日　　　：2024.02.05 Echigo.r 工場コード識別条件追加（TN工場追加対応）
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_create] 
	@kbnCreate		SMALLINT
	,@kbnUpdate		SMALLINT
	,@kbnDelete		SMALLINT
	,@kbnGenryo		SMALLINT
	,@kbnJikagen	SMALLINT
	,@kbnShizai		SMALLINT
	,@flgJisseki	SMALLINT
	,@kbnMidenso    SMALLINT	-- 未伝送区分追加
	,@kbnDensochu	SMALLINT
	,@kbnDensomachi	SMALLINT
	,@kbnSeizo		SMALLINT
	,@kbnZan		SMALLINT
	,@kbnSaiban		VARCHAR(2)
	,@kbnPrefix		VARCHAR(1)
	,@idoType		VARCHAR(3)
	,@idoTypeCancel	VARCHAR(3)
AS

BEGIN

	DECLARE @densoTable_genryo TABLE
	(
		[no_seq] [varchar](14) NULL
		,[flg_yojitsu] [smallint] NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[no_lot_seihin] [varchar](14) NOT NULL
		,[no_lot_shikakari] [varchar](14) NULL
		,[su_shiyo] [decimal](9, 3) NOT NULL
		,[data_key_tr_shikakari] [varchar](14) NULL
		,[kbn_jotai_denso] [smallint] NOT NULL
	)

	DECLARE @densoTable_shizai TABLE
	(
		[no_seq] [varchar](14) NULL
		,[flg_yojitsu] [smallint] NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[no_lot_seihin] [varchar](14) NOT NULL
		,[no_lot_shikakari] [varchar](14) NULL
		,[su_shiyo] [decimal](9, 3) NOT NULL
		,[data_key_tr_shikakari] [varchar](14) NULL
		-- 資材に伝送区分を追加
		,[kbn_jotai_denso] [smallint] NOT NULL
	)
	
	-- シーケンス採番前に実績を一元化するため、一時テーブルを準備
	DECLARE @densoTable TABLE
	(
		[no_seq] [varchar](14) NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[no_lot_seihin] [varchar](14) NOT NULL
		,[su_shiyo] [decimal](9, 3) NOT NULL
		,[kbn_jotai_denso] [smallint] NOT NULL
	)
	
	-- 誤差調整用テーブル
	DECLARE @densoTable_chosei TABLE
	(
		[no_seq] [varchar](14) NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[su_shiyo_diff] [decimal](9, 3) NOT NULL
	)

	DECLARE @msg						VARCHAR(500)		-- 処理結果メッセージ格納用
	DECLARE @cd_kojo					VARCHAR(13)
	DECLARE @dateTaisho					DATETIME
	DECLARE @seqNo						VARCHAR(14)
		
	DECLARE @cur_no_seq					VARCHAR(14)
	DECLARE @cur_flg_yojitsu			SMALLINT
	DECLARE @cur_cd_hinmei				VARCHAR(14)
	DECLARE @cur_dt_shiyo				DATETIME
	DECLARE @cur_no_lot_seihin			VARCHAR(14)
	DECLARE @cur_no_lot_shikakari		VARCHAR(14)
	DECLARE @cur_su_shiyo				DECIMAL(9, 3)
	DECLARE @cur_data_key_tr_shikakari	VARCHAR(14)
	DECLARE @cur_kbn_jotai_denso			SMALLINT

	SET NOCOUNT ON

	-- 工場コードの取得
	SET @cd_kojo = (SELECT TOP 1 cd_kojo FROM ma_kojo)
	
	--検索条件用日付（システム日時 - 60日）
	SET @dateTaisho = DATEADD(DD,-60,getutcdate())

	-- ##### 取込処理 #####
	-- 使用予実按分ワークをtruncate
	TRUNCATE TABLE wk_sap_shiyo_yojitsu_anbun_seizo
	
	-- 使用予実按分ワーク作成
	INSERT INTO wk_sap_shiyo_yojitsu_anbun_seizo(
		no_seq
		,no_lot_shikakari
		,kbn_shiyo_jisseki_anbun
		,no_lot_seihin
		,dt_shiyo_shikakari
		,su_shiyo_shikakari
		,cd_riyu
		,cd_genka_center
		,cd_soko
		,kbn_jotai_denso
	)
	SELECT
		no_seq
		,no_lot_shikakari
		,kbn_shiyo_jisseki_anbun
		,no_lot_seihin
		,dt_shiyo_shikakari
		,su_shiyo_shikakari
		,cd_riyu
		,cd_genka_center
		,cd_soko
		,kbn_jotai_denso
	FROM tr_sap_shiyo_yojitsu_anbun
  	WHERE
  		dt_shiyo_shikakari >= @dateTaisho
	AND kbn_jotai_denso <> @kbnMidenso
		
	-- 使用予実按分トラン　区分更新(製造)
	EXECUTE usp_sap_shiyo_yojitsu_anbun_jotai_denso_update
		@kbnSeizo
		,@kbnDensomachi
		,@kbnDensochu
		
	-- 使用予実按分トラン　区分更新(残)
	EXECUTE usp_sap_shiyo_yojitsu_anbun_jotai_denso_update
		@kbnZan
		,@kbnDensomachi
		,@kbnDensochu

		
	-- ##### 使用実績送信データ抽出 #####
	-- 使用実績送信対象テーブルをtruncate
	TRUNCATE TABLE tr_sap_jisseki_shiyo_denso_taisho

	-- 使用実績送信対象一時テーブルにデータを作成（原料、自家原料）
	-- 按分テーブルと使用予実で製品ロット毎の原料使用実績を作成
	INSERT INTO @densoTable_genryo (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
		,kbn_jotai_denso
	)
	-- 原料、自家原料の使用量を取得
	SELECT
		zen.no_seq
		,@flgJisseki AS flg_yojitsu
		,warifuri.cd_hinmei
		,warifuri.dt_shiyo
		,warifuri.no_lot_seihin
		,NULL AS no_lot_shikakari
		-- 製造ロット、使用日、品名でグループ化し、実績数を合算
		,CEILING(SUM(warifuri.su_shiyo) * 1000) / 1000 AS su_shiyo
		,NULL AS data_key_tr_shikakari
		-- 伝送待ちを含む場合は伝送待ちを取得（未伝送は除外してあるので、最小値は伝送待ちになる）
		,MIN(warifuri.kbn_jotai_denso) AS kbn_jotai_denso
	FROM ( 
		SELECT
			wariai.no_seq
			,shiyo.flg_yojitsu
			,shiyo.cd_hinmei
			,shiyo.dt_shiyo AS dt_shiyo
			,wariai.no_lot_seihin
			,wariai.no_lot_shikakari
			,SUM(shiyo.su_shiyo * wariai.ritsu_anbun) AS su_shiyo
			,shiyo.data_key_tr_shikakari
			,wariai.kbn_jotai_denso
		FROM ( 
			SELECT
				anbun.no_seq
				,anbun.no_lot_shikakari
				,anbun.kbn_shiyo_jisseki_anbun
				,anbun.kbn_jotai_denso
				,anbun.no_lot_seihin
				,anbun.dt_shiyo_shikakari
				,anbun.su_shiyo_shikakari / summary.su_shiyo_shikakari_sum AS ritsu_anbun
			FROM
				wk_sap_shiyo_yojitsu_anbun_seizo anbun
			LEFT OUTER JOIN (
				-- 未伝送除外したワークでは仕掛品単位の実績数が正常に取得出来ないので
				-- トランのデータを対象日で絞り仕掛品単位の実績数を取得
				SELECT
					no_lot_shikakari
					,SUM(su_shiyo_shikakari) AS su_shiyo_shikakari_sum
				FROM
					tr_sap_shiyo_yojitsu_anbun
				WHERE
					dt_shiyo_shikakari >= @dateTaisho
				GROUP BY
					no_lot_shikakari
			) summary
			ON anbun.no_lot_shikakari = summary.no_lot_shikakari
		) wariai
	LEFT OUTER JOIN tr_shiyo_yojitsu shiyo
	ON wariai.no_lot_shikakari = shiyo.no_lot_shikakari
	LEFT OUTER JOIN ma_hinmei hin
	ON hin.cd_hinmei = shiyo.cd_hinmei
	WHERE(
		wariai.kbn_shiyo_jisseki_anbun = @kbnSeizo
	 	OR wariai.kbn_shiyo_jisseki_anbun = @kbnZan
	)
	AND shiyo.flg_yojitsu = @flgJisseki 
	AND hin.kbn_hin IN (@kbnGenryo, @kbnJikagen)
	AND ISNULL(hin.flg_testitem, 0) <> 1
	GROUP BY
		wariai.no_seq
		,shiyo.flg_yojitsu
		,shiyo.cd_hinmei
		,shiyo.dt_shiyo
		,wariai.no_lot_seihin
		,wariai.no_lot_shikakari
		,shiyo.data_key_tr_shikakari
		,wariai.kbn_jotai_denso
	) warifuri
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
	ON warifuri.cd_hinmei = zen.cd_hinmei 
	AND warifuri.dt_shiyo = zen.dt_shiyo
	AND warifuri.no_lot_seihin = zen.no_lot_seihin
	-- 「製造ロット、品名、使用日」で使用数を合算
	GROUP BY
		zen.no_seq
		,warifuri.cd_hinmei
		,warifuri.dt_shiyo
		,warifuri.no_lot_seihin

	-- 使用実績送信対象一時テーブルにデータを作成（資材）
	-- 使用予実から製品ロット毎の資材使用実績を作成
	INSERT INTO @densoTable_shizai (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
		-- 伝送状態区分追加
		,kbn_jotai_denso
	)
	-- 資材の使用量を取得
	SELECT
		zen.no_seq
		,shiyo.flg_yojitsu
		,shiyo.cd_hinmei
		,shiyo.dt_shiyo
		,anbun.no_lot_seihin
		,null AS no_lot_shikakari
		,CEILING(SUM(shiyo.su_shiyo) * 1000) / 1000 AS su_shiyo
		,null AS data_key_tr_shikakari
		,anbun.kbn_jotai_denso
		FROM(
			SELECT 
				no_lot_seihin
				-- 按分情報から伝送状態区分取得（一つでも伝送待ちがあれば資材も伝送待ちにする）
				,MIN(kbn_jotai_denso) AS kbn_jotai_denso
			FROM
				wk_sap_shiyo_yojitsu_anbun_seizo
			GROUP BY
				no_lot_seihin
		) anbun
	LEFT OUTER JOIN tr_shiyo_yojitsu shiyo
	ON anbun.no_lot_seihin = shiyo.no_lot_seihin
	LEFT OUTER JOIN ma_hinmei hin
	ON shiyo.cd_hinmei = hin.cd_hinmei
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
	ON shiyo.cd_hinmei = zen.cd_hinmei
	AND shiyo.dt_shiyo = zen.dt_shiyo
	AND anbun.no_lot_seihin = zen.no_lot_seihin
	AND shiyo.no_lot_shikakari IS NULL
	WHERE 
		shiyo.flg_yojitsu = @flgJisseki 
	AND hin.kbn_hin = @kbnShizai
	AND ISNULL(hin.flg_testitem, 0) <> 1
	GROUP BY
		zen.no_seq
		,shiyo.flg_yojitsu
		,shiyo.cd_hinmei
		,shiyo.dt_shiyo
		,anbun.no_lot_seihin
		,anbun.kbn_jotai_denso

	-- 使用実績送信対象一時テーブルを作成（原料・自家原料、資材の実績を一元化）
	INSERT INTO @densoTable (
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	)
	SELECT
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	FROM
		@densoTable_genryo
	-- 使用数が０の実績は伝送しない（採番前に絞り込むことで、無駄な採番が減る）
	WHERE
		su_shiyo <> 0
	-- 対象日内のデータに絞る
	AND dt_shiyo >= @dateTaisho
	
	UNION ALL
	
	SELECT
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	FROM
		@densoTable_shizai
	-- 使用数が０の実績は伝送しない
	WHERE
		su_shiyo <> 0
	-- 対象日内のデータに絞る
	AND dt_shiyo >= @dateTaisho
	
	-- シーケンス番号取り付け　ここから
	DECLARE cursor_denso CURSOR FOR
	SELECT
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	FROM
		@densoTable
	WHERE
		no_seq IS NULL
	
	OPEN cursor_denso
		IF (@@error <> 0)
		BEGIN
			SET @msg = 'CURSOR OPEN ERROR: cursor_denso'
			GOTO Error_Handling
		END
	FETCH NEXT FROM cursor_denso INTO
		@cur_no_seq
		,@cur_cd_hinmei
		,@cur_dt_shiyo
		,@cur_no_lot_seihin
		,@cur_su_shiyo
		,@cur_kbn_jotai_denso

	WHILE @@FETCH_STATUS = 0
	BEGIN	
		EXECUTE usp_cm_Saiban @kbnSaiban, @kbnPrefix, @seqNo OUTPUT

		UPDATE @densoTable
		SET no_seq = @seqNo
		WHERE
			cd_hinmei = @cur_cd_hinmei 
		AND dt_shiyo = @cur_dt_shiyo
		AND no_lot_seihin = @cur_no_lot_seihin

		FETCH NEXT FROM cursor_denso INTO
			@cur_no_seq
			,@cur_cd_hinmei
			,@cur_dt_shiyo
			,@cur_no_lot_seihin
			,@cur_su_shiyo
			,@cur_kbn_jotai_denso
	END
	CLOSE cursor_denso
	DEALLOCATE cursor_denso
	-- シーケンス番号取り付け　ここまで
	
	-- 使用実績送信対象テーブルにデータを作成（シーケンス採番後の伝送テーブル）
	INSERT INTO tr_sap_jisseki_shiyo_denso_taisho (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
	)
	SELECT
		no_seq
		,@flgJisseki AS flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,NULL AS no_lot_shikakari
		,su_shiyo
		,NULL AS data_key_tr_shikakari
	FROM 
		@densoTable
	
	EXEC usp_sap_jisseki_shiyo_denso_taisho_shuusei
	-- ##### 誤差調整終了 #####
	
			
	-- ##### 送信データ抽出 #####
	TRUNCATE TABLE tr_sap_jisseki_shiyo_denso
	INSERT INTO tr_sap_jisseki_shiyo_denso (
		kbn_denso_SAP
		,no_seq
		,no_lot_seihin
		,dt_shiyo
		,cd_kojo
		,cd_hinmei
		,su_shiyo
		,cd_tani_SAP
		,type_ido
		,hokan_basho
	)
	-- 新規追加データ
	SELECT
		@kbnCreate
		,taisho.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoType AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho taisho
		-- 製造ロット、使用日単位で前回と比較
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
	ON taisho.no_lot_seihin = zen.no_lot_seihin
	AND taisho.dt_shiyo = zen.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON taisho.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani
	-- 前回に無い実績を取得
	WHERE
		zen.no_lot_seihin IS NULL
		
	UNION ALL
	
	-- 変更データ（赤）
	SELECT
		@kbnDelete
		,zen.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoTypeCancel AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho_zen zen
	INNER JOIN (
		SELECT
			h_taisho.no_lot_seihin
			,h_taisho.dt_shiyo
		FROM (
			-- 前回今回どちらにもある変更対象セット（製品、使用日）を取得
			SELECT DISTINCT
				taisho.no_lot_seihin 
				,taisho.dt_shiyo
			FROM tr_sap_jisseki_shiyo_denso_taisho taisho
			INNER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
			ON zen.no_lot_seihin = taisho.no_lot_seihin
			AND zen.dt_shiyo = taisho.dt_shiyo
			-- 対象トランの使用日と紐付くものしか取得しないから、ここでは対象日での抽出は必要ない
		) h_taisho
		INNER JOIN (
			-- 使用数の変更、レシピの変更のある実績のみ取得
			SELECT DISTINCT
				ISNULL(zen.no_lot_seihin,taisho.no_lot_seihin) AS no_lot_seihin
				,ISNULL(zen.dt_shiyo,taisho.dt_shiyo) AS dt_shiyo
			FROM (
				SELECT
					no_lot_seihin
					,dt_shiyo
					,cd_hinmei
					,su_shiyo
				FROM tr_sap_jisseki_shiyo_denso_taisho_zen
			-- 対象トランと紐付かないデータも取得されてしまうので、対象日で絞り込む
			WHERE dt_shiyo >= @dateTaisho
			) zen
			FULL OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho taisho
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.dt_shiyo = zen.dt_shiyo
			AND taisho.cd_hinmei = zen.cd_hinmei
			WHERE
				-- 下記三点いずれかに当てはまる実績のセットを取得
				-- １．使用数が異なる
				-- ２．対象トランがNULL（原料削除）
				-- ３．前回トランがNULL（原料追加）
				ISNULL(taisho.su_shiyo,0) <> ISNULL(zen.su_shiyo,0)
		)h_check
		ON h_taisho.no_lot_seihin = h_check.no_lot_seihin
		AND h_taisho.dt_shiyo = h_check.dt_shiyo
	)henko
	ON henko.no_lot_seihin = zen.no_lot_seihin
	AND henko.dt_shiyo = zen.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON zen.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani

	UNION ALL

	-- 変更データ（黒）
	SELECT
		@kbnCreate
		,taisho.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoType AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho taisho
	INNER JOIN (
		SELECT
			h_taisho.no_lot_seihin
			,h_taisho.dt_shiyo
		FROM (
			-- 前回今回どちらにもある変更対象セット（製品、使用日）を取得
			SELECT DISTINCT
				taisho.no_lot_seihin 
				,taisho.dt_shiyo
			FROM tr_sap_jisseki_shiyo_denso_taisho taisho
			INNER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
			ON zen.no_lot_seihin = taisho.no_lot_seihin
			AND zen.dt_shiyo = taisho.dt_shiyo
			-- 対象トランの使用日と紐付くものしか取得しないから、ここでは対象日での抽出は必要ない？
			-- WHERE zen.dt_shiyo >= @dateTaisho
		) h_taisho
		INNER JOIN (
			-- 使用数の変更、レシピの変更のある実績のみ取得
			SELECT DISTINCT
				ISNULL(zen.no_lot_seihin,taisho.no_lot_seihin) AS no_lot_seihin
				,ISNULL(zen.dt_shiyo,taisho.dt_shiyo) AS dt_shiyo
			FROM (
				SELECT
					no_lot_seihin
					,dt_shiyo
					,cd_hinmei
					,su_shiyo
				FROM tr_sap_jisseki_shiyo_denso_taisho_zen
			-- 対象トランと紐付かないデータも取得されてしまうので、対象日で絞り込む
			WHERE dt_shiyo >= @dateTaisho
			) zen
			FULL OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho taisho
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.dt_shiyo = zen.dt_shiyo
			AND taisho.cd_hinmei = zen.cd_hinmei
			WHERE
				-- 下記三点いずれかに当てはまる実績のセットを取得
				-- １．使用数が異なる
				-- ２．対象トランがNULL（原料削除）
				-- ３．前回トランがNULL（原料追加）
				ISNULL(taisho.su_shiyo,0) <> ISNULL(zen.su_shiyo,0)
		)h_check
		ON h_taisho.no_lot_seihin = h_check.no_lot_seihin
		AND h_taisho.dt_shiyo = h_check.dt_shiyo
	)henko
	ON henko.no_lot_seihin = taisho.no_lot_seihin
	AND henko.dt_shiyo = taisho.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON taisho.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani

	UNION ALL

	-- 削除データ
	SELECT
		@kbnDelete
		,zen.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoTypeCancel AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho_zen zen
	-- 前回にあるが対象に含まれない実績を取得
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho taisho
	ON taisho.no_lot_seihin = zen.no_lot_seihin
	AND taisho.dt_shiyo = zen.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON zen.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani
	WHERE
		taisho.no_lot_seihin IS NULL 
	AND zen.dt_shiyo >= @dateTaisho

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




GO
