IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KakozanZaikoCopy_insert') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KakozanZaikoCopy_insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能        ：加工残 在庫コピー
ファイル名  ：[usp_KakozanZaikoCopy_insert]
入力引数    ：
出力引数    ：
戻り値      ：
作成日      ：2019.07.25  trinh.bd
更新日      ：2019.08.25  nakamura.r 保留品も含むように変更、Insert文に項目を追加
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KakozanZaikoCopy_insert] 
	@dt_hizuke				DATETIME	  -- 在庫訂正日
	, @ryohinZaikoKbn		SMALLINT	  -- 在庫区分.良品
	, @shiyoMishiyoFlg		SMALLINT	  -- 未使用フラグ.使用
	, @jikagenryoHinKbn		SMALLINT	  -- 品区分.自家原料
	--TOsVN 19076 thong.ph START
	, @cd_hinmei			NVARCHAR(50)
	, @kbn_hin				SMALLINT
	, @mode                  INT
	, @lang                  VARCHAR(2)
	--TOsVN 19076 thong.ph END
	, @userCode				VARCHAR(10)
AS
BEGIN
SET XACT_ABORT ON
BEGIN TRAN
BEGIN TRY

DECLARE @minSeqNo DECIMAL(8, 0);

SET @minSeqNo = 1;

	DECLARE @taniKg		VARCHAR(10)
		, @taniL		VARCHAR(10)
		, @dateNow		DATETIME

	SET	@taniKg		=	4;
	SET	@taniL		=	11;
	SET @dateNow	= GETUTCDATE();

	DECLARE  @zaikoTemp TABLE(
		cd_hinmei		VARCHAR(14),
		dt_hizuke		DATETIME,
		su_zaiko		DECIMAL(14, 6),
		dt_jisseki_zaiko DATETIME,
		dt_update		DATETIME,
		cd_update		VARCHAR(10),
		tan_tana		DECIMAL(12, 4),
		kbn_zaiko		SMALLINT,
		cd_soko			VARCHAR(10)
		)

INSERT INTO @zaikoTemp
SELECT 
	data.cd_hinmei
	, @dt_hizuke		AS dt_hizuke
	, data.su_shiyo		AS su_zaiko
	, @dateNow			AS dt_jisseki_zaiko
	, @dateNow			AS dt_update
	, @userCode			AS cd_update
	, data.tan_ko		AS tan_tana
	, data.kbn_zaiko	AS kbn_zaiko
	, data.cd_soko_kbn	AS cd_soko
FROM (
	SELECT 
		niuke.cd_hinmei
		, SUM(ISNULL(CASE
			WHEN ISNULL ( konyu.cd_tani_nonyu, hinmei.cd_tani_nonyu ) IN (@taniKg,@taniL)
				THEN
					CASE niuke.kbn_hin
						WHEN  @jikagenryoHinKbn  THEN ISNUll(hinmei.su_iri,1) * ISNULL(FLOOR(hinmei.wt_ko * 1000) / 1000,1) * ISNULL(niuke.su_zaiko, 0) + ISNULL(niuke.su_zaiko_hasu, 0) / 1000
						ELSE ISNUll(konyu.su_iri,1) * ISNUll(FLOOR(konyu.wt_nonyu * 1000) / 1000,1) * ISNULL(niuke.su_zaiko, 0) + ISNULL(niuke.su_zaiko_hasu, 0) / 1000
					END
				ELSE
					CASE niuke.kbn_hin
						WHEN  @jikagenryoHinKbn  THEN ISNUll(hinmei.su_iri,1) * ISNULL(FLOOR(hinmei.wt_ko * 1000) / 1000,1) * ISNULL(niuke.su_zaiko, 0) + ISNULL(niuke.su_zaiko_hasu, 0)
						ELSE ISNUll(konyu.su_iri,1) * ISNUll(FLOOR(konyu.wt_nonyu * 1000) / 1000,1) * ISNULL(niuke.su_zaiko, 0) + ISNULL(niuke.su_zaiko_hasu, 0)
					END
		END, 0)) AS su_shiyo
		, ISNULL(hinmei.tan_ko, 0) AS tan_ko
		, soko.cd_soko_kbn	
		, max_niuke.kbn_zaiko
	FROM tr_niuke niuke

	INNER JOIN (
		SELECT 
			MAX(no_seq) AS no_seq
			, no_niuke
			, cd_niuke_basho
			, kbn_zaiko
		FROM tr_niuke
		WHERE 
			((
				no_seq <> @minSeqNo
				AND dt_niuke <= @dt_hizuke
			)
			OR 
			(
				dt_nonyu <= @dt_hizuke
				AND no_seq = @minSeqNo
			))
		GROUP BY 
			no_niuke
			, cd_niuke_basho
			, kbn_zaiko
	) max_niuke
	ON niuke.no_niuke = max_niuke.no_niuke
	AND niuke.cd_niuke_basho = max_niuke.cd_niuke_basho
	AND niuke.kbn_zaiko = max_niuke.kbn_zaiko
	AND niuke.no_seq = max_niuke.no_seq

	INNER JOIN	ma_konyu konyu
	ON niuke.cd_torihiki = konyu.cd_torihiki
	AND niuke.cd_hinmei = konyu.cd_hinmei
	--AND konyu.flg_mishiyo = @shiyoMishiyoFlg

	LEFT JOIN ma_hinmei hinmei
	ON	niuke.cd_hinmei	= hinmei.cd_hinmei

	LEFT JOIN ma_kbn_soko soko
	ON hinmei.kbn_hin = soko.kbn_hin
	
	INNER JOIN (
		SELECT
			no_niuke
		FROM tr_niuke
		GROUP BY no_niuke
		HAVING MIN(no_seq) = 1) min_seq
	ON niuke.no_niuke = min_seq.no_niuke

	WHERE
		( 
			(
				niuke.no_seq <> @minSeqNo
				AND niuke.dt_niuke <= @dt_hizuke
			)
			OR 
			(
				niuke.dt_nonyu <= @dt_hizuke
				AND niuke.no_seq = @minSeqNo
			)
		)		
		AND 
		(
			@kbn_hin IS NULL
			OR hinmei.kbn_hin = @kbn_hin
		)
		AND 
		( 
			(
				@mode  = 1
				AND 
				(
					LEN(ISNULL(@cd_hinmei, '')) = 0 
					OR hinmei.cd_hinmei LIKE '%' + @cd_hinmei + '%' 
					OR 
					(
						@lang = 'en' 
						AND hinmei.nm_hinmei_en	LIKE '%' + @cd_hinmei + '%'
					)
					OR 
					(
						@lang = 'ja' 
						AND hinmei.nm_hinmei_ja	LIKE '%' + @cd_hinmei + '%'
					)
					OR 
					(
						@lang = 'zh' 
						AND hinmei.nm_hinmei_zh	LIKE '%' + @cd_hinmei + '%'
					)	
					OR 
					(
						@lang = 'vi' 
						AND hinmei.nm_hinmei_vi	LIKE '%' + @cd_hinmei + '%'
					)
				)
			)
			OR
			(
				@mode  = 0
				AND 
				(
					LEN(ISNULL(@cd_hinmei, '')) = 0 
					OR hinmei.cd_hinmei = @cd_hinmei
				) 
			)
		)
	GROUP BY
		niuke.cd_hinmei
		, tan_ko
		, soko.cd_soko_kbn	
		, max_niuke.kbn_zaiko
) data
DELETE zaiko
FROM tr_zaiko zaiko
INNER JOIN @zaikoTemp temp
ON zaiko.dt_hizuke = temp.dt_hizuke
AND zaiko.cd_hinmei = temp.cd_hinmei
AND zaiko.kbn_zaiko = temp.kbn_zaiko
--AND zaiko.cd_soko = temp.cd_soko


INSERT INTO tr_zaiko
	(cd_hinmei
	,dt_hizuke
	,su_zaiko
	,dt_jisseki_zaiko
	,dt_update
	,cd_update
	,tan_tana
	,kbn_zaiko
	,cd_soko)
SELECT 
	cd_hinmei
	, dt_hizuke
	, su_zaiko
	, dt_jisseki_zaiko
	, dt_update
	, cd_update
	, tan_tana
	, kbn_zaiko
	, cd_soko
FROM @zaikoTemp

COMMIT
END TRY
BEGIN CATCH
   ROLLBACK
   DECLARE @ErrorMessage VARCHAR(2000)
   SELECT @ErrorMessage = 'ERROR: ' + ERROR_MESSAGE()
   RAISERROR(@ErrorMessage, 16, 1)
END CATCH

END
GO
