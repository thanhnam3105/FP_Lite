IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_yotei_nonyu_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能		：納入予定送信対象テーブル取込処理
ファイル名	：usp_sap_yotei_nonyu_denso_taisho_create
入力引数	：				
出力引数	：
戻り値		：成功時[0] 失敗時[0以外のエラーコード]
作成日		：2015.01.14 ADMAX endo.y
更新日      ：2015.10.07 ADMAX taira.s 品名マスタ.テスト品=1のデータを取り込まないように修正
更新日　　　：2016.01.04 Hirai.a 条件の日付を60日に統一
更新日　　　：2018.05.18 BRC Noguchi.m 単位がnullで伝送される不具合を修正(品名マスタを結合する際の結合条件を修正)
更新日　　　：2019.03.15 BRC Takaki.r 作業依頼No.572対応 品コード変更時に伝送対象になるよう修正
更新日　　　：2019.08.02 nakamura.r 小数点以下３桁まで許容
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_create] 
	 @kbnCreate smallint
	,@kbnUpdate smallint
	,@kbnDelete smallint
	,@flgShiyo smallint
	,@flgHeijitsu smallint
	,@kbnJikagen	smallint
	,@flgYotei smallint
	,@cdTani_kg	varchar(2)
	,@cdTani_li	varchar(2)
	,@jisa smallint
AS
BEGIN

	--コピー条件用日付（システム日時 - 60日）
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())

	-- 納入予定送信対象テーブルの削除
	TRUNCATE TABLE tr_sap_yotei_nonyu_denso_taisho

	-- 納入予実トランのデータを納入予定送信対象テーブルにコピー
	INSERT INTO tr_sap_yotei_nonyu_denso_taisho (
		flg_yojitsu
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,kin_kingaku
		,no_nonyusho
		,kbn_zei
		,kbn_denso
		,flg_kakutei
		,dt_seizo
		,kbn_nyuko
		,cd_tani_shiyo
	)
	SELECT
		tr.flg_yojitsu
		,tr.no_nonyu
		,tr.dt_nonyu
		,tr.cd_hinmei

		-- 納入単位から使用単位への変換：BIZ00009
		-- 小数点第三位以下は切り捨て
		,ROUND(CASE WHEN COALESCE(mk.cd_tani_nonyu, mh.cd_tani_nonyu) = @cdTani_kg
					OR COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cdTani_li
			 THEN tr.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
					+ (tr.su_nonyu_hasu / 1000)
			 ELSE tr.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
					+ (tr.su_nonyu_hasu * COALESCE(mk.wt_nonyu, mh.wt_ko))
			 END
		 , 3, 1)

		--,tr.su_nonyu_hasu
		,0
		,tr.cd_torihiki
		,tr.cd_torihiki2
		,tr.tan_nonyu
		,tr.kin_kingaku
		,tr.no_nonyusho
		,tr.kbn_zei
		,tr.kbn_denso
		,tr.flg_kakutei
		,tr.dt_seizo
		,tr.kbn_nyuko
		,mh.cd_tani_shiyo
	FROM tr_nonyu tr
	LEFT JOIN ma_konyu mk
		ON  tr.cd_hinmei = mk.cd_hinmei
		AND tr.cd_torihiki = mk.cd_torihiki
	LEFT JOIN ma_hinmei mh
--		ON mk.cd_hinmei = mh.cd_hinmei
		ON tr.cd_hinmei = mh.cd_hinmei
	WHERE
		tr.flg_yojitsu = @flgYotei
		AND tr.dt_nonyu > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1

	---- 納入予定抽出テーブルの削除
	TRUNCATE TABLE tr_sap_yotei_nonyu_denso
	
	--前回データから3か月前を削除
	DELETE tr_sap_yotei_nonyu_denso_taisho_zen
	WHERE dt_nonyu <= @dateTaisho
	
	-- 送信データの抽出
    ;WITH cte_nonyu_yotei_denso AS
    (
		--新規追加の場合
		SELECT
			@kbnCreate AS 'kbn_denso_SAP'
			,SUBSTRING(taisho.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_nonyu, 112)) AS 'dt_nonyu'
			,taisho.cd_hinmei
			,taisho.su_nonyu
			,taisho.su_nonyu_hasu
			,taisho.cd_torihiki
			,mst.cd_tani_henkan
			,taisho.kbn_nyuko
			,taisho.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		LEFT JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.cd_hinmei = zen.cd_hinmei
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON taisho.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE zen.no_nonyu IS NULL
			AND taisho.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen
			
		UNION ALL
		--取引先コード以外が変更されている場合
		SELECT 
			@kbnUpdate AS 'kbn_denso_SAP'
			,SUBSTRING(taisho.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_nonyu, 112)) AS 'dt_nonyu'
			,taisho.cd_hinmei
			,taisho.su_nonyu
			,taisho.su_nonyu_hasu
			,taisho.cd_torihiki
			,mst.cd_tani_henkan
			,taisho.kbn_nyuko
			,taisho.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		INNER JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON taisho.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE (taisho.su_nonyu <> zen.su_nonyu
				OR taisho.kbn_nyuko <> zen.kbn_nyuko
				OR taisho.dt_nonyu <> zen.dt_nonyu
				)
			AND taisho.cd_torihiki = zen.cd_torihiki
			AND taisho.cd_hinmei = zen.cd_hinmei
			AND taisho.flg_yojitsu = @flgShiyo
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen
				
		UNION ALL
		--取引先コードが変更されている場合(デリートインサート)
		SELECT 
			@kbnDelete AS 'kbn_denso_SAP'
			,SUBSTRING(zen.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_nonyu, 112)) AS 'dt_nonyu'
			,zen.cd_hinmei
			,zen.su_nonyu
			,zen.su_nonyu_hasu
			,zen.cd_torihiki
			,mst.cd_tani_henkan
			,zen.kbn_nyuko
			,zen.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		INNER JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON zen.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE taisho.cd_torihiki <> zen.cd_torihiki
			AND taisho.cd_hinmei = zen.cd_hinmei
			AND taisho.flg_yojitsu = @flgShiyo
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen

		UNION ALL
		SELECT 
			@kbnCreate AS 'kbn_denso_SAP'
			,SUBSTRING(taisho.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_nonyu, 112)) AS 'dt_nonyu'
			,taisho.cd_hinmei
			,taisho.su_nonyu
			,taisho.su_nonyu_hasu
			,taisho.cd_torihiki
			,mst.cd_tani_henkan
			,taisho.kbn_nyuko
			,taisho.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		INNER JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON taisho.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE taisho.cd_torihiki <> zen.cd_torihiki
			AND taisho.cd_hinmei = zen.cd_hinmei
			AND taisho.flg_yojitsu = @flgShiyo
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen

		UNION ALL
		--削除されている場合
		SELECT 
			@kbnDelete AS 'kbn_denso_SAP'
			,SUBSTRING(zen.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_nonyu, 112)) AS 'dt_nonyu'
			,zen.cd_hinmei
			,zen.su_nonyu
			,zen.su_nonyu_hasu
			,zen.cd_torihiki
			,mst.cd_tani_henkan
			,zen.kbn_nyuko
			,zen.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho_zen zen
		LEFT JOIN tr_sap_yotei_nonyu_denso_taisho taisho
			ON zen.no_nonyu = taisho.no_nonyu
				AND zen.cd_hinmei = taisho.cd_hinmei
				AND zen.flg_yojitsu = @flgShiyo
				AND taisho.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON zen.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON zen.cd_hinmei = mh.cd_hinmei
		WHERE taisho.no_nonyu IS NULL
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen
	)
	

	-- 送信対象データを抽出テーブルに格納
	INSERT INTO tr_sap_yotei_nonyu_denso (
		kbn_denso_SAP
		,no_nonyu
		,cd_kojo
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,cd_torihiki
		,cd_tani_SAP
		,kbn_nyuko
	)
	SELECT
		cte.kbn_denso_SAP
		,cte.no_nonyu
		,cte.cd_kojo
		,cte.dt_nonyu
		,UPPER(cte.cd_hinmei) AS cd_hinmei
		,cte.su_nonyu
		,cte.cd_torihiki
		,cte.cd_tani_henkan
		,cte.kbn_nyuko
	FROM
		cte_nonyu_yotei_denso cte

END
GO
