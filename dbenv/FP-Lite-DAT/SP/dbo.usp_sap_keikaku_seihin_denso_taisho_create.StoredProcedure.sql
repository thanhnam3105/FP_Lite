IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_keikaku_seihin_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_create]
GOSET ANSI_NULLS ON
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：製品計画送信対象テーブル取込処理
ファイル名	：usp_sap_keikaku_seihin_denso_taisho_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.07 ADMAX endo.y
更新日      ：2015.10.07 ADMAX taira.s 品名マスタ.テスト品=1のデータを取り込まないように修正
更新日　　　：2016.01.04 Hirai.a 条件の日付を60日に統一
更新日　　　：2017.01.04 BRC cho.k 製造予定数０を送信対象外に
更新日　　　：2022.01.04 BRC Sato.t 送信対象テーブルの抽出条件に製造予定数が0以外を追加
更新日　　　：2024.02.05 Echigo.r 工場コード識別条件追加（TN工場追加対応）
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_create] 
	 @kbnCreate		smallint
	,@kbnUpdate		smallint
	,@kbnDelete		smallint
	,@kbnJikagen	smallint
AS
BEGIN
	
	--コピー条件用日付（システム日時 - 60日）
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())
	
	-- 製品計画送信対象テーブルの削除
	TRUNCATE TABLE tr_sap_keikaku_seihin_denso_taisho

	-- 製品計画トランのデータを製品計画送信対象テーブルにコピー
	INSERT INTO tr_sap_keikaku_seihin_denso_taisho (
		no_lot_seihin
		,dt_seizo
		,cd_shokuba
		,cd_line
		,cd_hinmei
		,su_seizo_yotei
		,su_seizo_jisseki
		,flg_jisseki
		,kbn_denso
		,flg_denso
		,dt_update
		,su_batch_keikaku
		,su_batch_jisseki
		,dt_shomi
	)
	SELECT
		no_lot_seihin
		,dt_seizo
		,cd_shokuba
		,cd_line
		,tks.cd_hinmei
		,su_seizo_yotei
		,su_seizo_jisseki
		,flg_jisseki
		,kbn_denso
		,flg_denso
		,tks.dt_update
		,su_batch_keikaku
		,su_batch_jisseki
		,dt_shomi
	FROM tr_keikaku_seihin tks
	LEFT JOIN ma_hinmei mh
		ON tks.cd_hinmei = mh.cd_hinmei
	WHERE tks.su_seizo_yotei is not null
		AND tks.su_seizo_yotei <> 0
		AND tks.dt_seizo > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1
	
	-- 製品計画抽出テーブルの削除
	TRUNCATE TABLE tr_sap_keikaku_seihin_denso
	
	--前回データから3か月前を削除
	DELETE tr_sap_keikaku_seihin_denso_taisho_zen
	WHERE dt_seizo <= @dateTaisho
	
	-- 送信データの抽出及び格納
	INSERT INTO tr_sap_keikaku_seihin_denso (
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,cd_kojo
		,cd_hinmei
		,su_seizo_keikaku
		,cd_tani_SAP
	)
	--追加データ抽出
	SELECT
		@kbnCreate
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin,4,10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_seizo,112))
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_seizo_yotei
		,mst.cd_tani_henkan
	FROM tr_sap_keikaku_seihin_denso_taisho taisho
	LEFT JOIN tr_sap_keikaku_seihin_denso_taisho_zen zen
		ON taisho.no_lot_seihin = zen.no_lot_seihin
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_nonyu = mst.cd_tani
	WHERE zen.no_lot_seihin is null
		AND taisho.su_seizo_yotei is not null
	
	--更新データ抽出
	UNION ALL
	SELECT 
		@kbnUpdate
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin,4,10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_seizo,112))
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_seizo_yotei
		,mst.cd_tani_henkan
	FROM tr_sap_keikaku_seihin_denso_taisho taisho
	INNER JOIN tr_sap_keikaku_seihin_denso_taisho_zen zen
		ON taisho.no_lot_seihin = zen.no_lot_seihin
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_nonyu = mst.cd_tani
	WHERE taisho.su_seizo_yotei <> zen.su_seizo_yotei
	
	--削除データ抽出
	UNION ALL
	SELECT 
		@kbnDelete
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END+ 
			SUBSTRING(zen.no_lot_seihin,4,10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_seizo,112))
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_seizo_yotei
		,mst.cd_tani_henkan
	FROM tr_sap_keikaku_seihin_denso_taisho_zen zen
	LEFT JOIN tr_sap_keikaku_seihin_denso_taisho taisho
		ON zen.no_lot_seihin = taisho.no_lot_seihin
	LEFT JOIN ma_hinmei mh
		ON zen.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_nonyu = mst.cd_tani
	WHERE taisho.no_lot_seihin is null
		AND zen.su_seizo_yotei is not null
END
GO
