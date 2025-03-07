IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HinmeiDialogKeikaku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HinmeiDialogKeikaku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.07.09>
-- Last Update: <2016.12.13 motojima.m>
-- Description: <Description,,
--      品名マスタセレクタの計画系用検索処理>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HinmeiDialogKeikaku_select]
	@seizoDate				DATETIME		-- 検索条件：製造日（有効版取得のため）
    ,@lineCode				VARCHAR(10)		-- 検索条件：ラインコード
    ,@shokubaCode			VARCHAR(10)		-- 検索条件：職場コード
    ,@hinKbn				SMALLINT		-- 検索条件：品区分
    --,@con_name			varchar(50)		-- 検索条件：品名
    ,@con_name				nvarchar(50)	-- 検索条件：品名
	,@flg_mishiyo_fukumu	smallint		-- 検索条件：未使用含む
    ,@falseFlag				SMALLINT		-- 定数：未使用フラグ：未使用
    ,@masterKbnHinmei		SMALLINT		-- 定数：マスタ区分：品名マスタ
    ,@masterKbnHaigo		SMALLINT		-- 定数：マスタ区分：配合名マスタ
	,@lang					VARCHAR(2)		-- ブラウザ言語
	,@isSeihin				SMALLINT		-- 起動元画面：製品計画…1　仕掛品計画…2
    ,@con_bunrui			varchar(10)		-- 検索条件：分類
AS
BEGIN

	SET NOCOUNT ON

	-- ====================================
	--  起動元画面が月間製品計画の場合
	-- ====================================
	IF @isSeihin = 1
	BEGIN
		SELECT
			hin.cd_hinmei
			,hin.kbn_hin
			,kbn.nm_kbn_hin
			,hin.nm_hinmei_ja 
			,hin.nm_hinmei_en
			,hin.nm_hinmei_zh
			,hin.nm_hinmei_vi
			,hin.nm_nisugata_hyoji AS nm_naiyo
		FROM (
			SELECT
				cd_hinmei
				,kbn_hin
				,nm_hinmei_ja
				,nm_hinmei_en
				,nm_hinmei_zh
				,nm_hinmei_vi
				,nm_nisugata_hyoji
				,cd_haigo
				,flg_mishiyo
			FROM
				ma_hinmei
			WHERE
				kbn_hin = @hinKbn
			AND (@flg_mishiyo_fukumu <> @falseFlag OR flg_mishiyo = @falseFlag)
			AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0
				OR nm_hinmei_ja LIKE '%' + @con_name + '%'
				OR nm_hinmei_en LIKE '%' + @con_name + '%'
				OR nm_hinmei_zh LIKE '%' + @con_name + '%'
				OR nm_hinmei_vi LIKE '%' + @con_name + '%'
				OR cd_hinmei LIKE '%' + @con_name + '%')
		) hin

		-- 製品の製造可能ラインマスタ
		INNER JOIN (
			SELECT cd_haigo
			FROM ma_seizo_line
			WHERE cd_line = @lineCode
			AND kbn_master = @masterKbnHinmei
			GROUP BY cd_haigo
		) sl
		ON sl.cd_haigo = hin.cd_hinmei

		-- 直下の仕掛品の製造可能ラインマスタ
		INNER JOIN (
			SELECT
				cd_haigo
			FROM ma_seizo_line
			WHERE kbn_master = @masterKbnHaigo
			GROUP BY cd_haigo
		) shikakariLine
		ON shikakariLine.cd_haigo = hin.cd_haigo

		LEFT JOIN ma_kbn_hin kbn
		ON kbn.kbn_hin = hin.kbn_hin

		-- 有効版用の品名マスタ
		LEFT JOIN (
			SELECT
				ma.cd_hinmei
				,ma.cd_haigo
				,(SELECT top 1 udf.cd_hinmei
				  FROM udf_HaigoRecipeYukoHan(ma.cd_haigo, @falseFlag, @seizoDate) udf
				 ) AS yuko_haigo
			FROM
				ma_hinmei ma
			WHERE
				ma.kbn_hin = @hinKbn
			AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (@flg_mishiyo_fukumu <> @falseFlag OR ma.flg_mishiyo = @falseFlag)
			AND (LEN(@con_name) = 0
				OR nm_hinmei_ja LIKE '%' + @con_name + '%'
				OR nm_hinmei_en LIKE '%' + @con_name + '%'
				OR nm_hinmei_zh LIKE '%' + @con_name + '%'
				OR nm_hinmei_vi LIKE '%' + @con_name + '%'
				OR cd_hinmei LIKE '%' + @con_name + '%')
		) yuko_hin
		ON yuko_hin.cd_hinmei = hin.cd_hinmei

		WHERE yuko_hin.yuko_haigo IS NOT NULL
		ORDER BY hin.cd_hinmei
	END

	-- ====================================
	--  起動元画面が月間仕掛品計画の場合
	-- ====================================
	ELSE IF @isSeihin = 2
	BEGIN
		SELECT
			haigo.cd_haigo AS cd_hinmei
			,kbn.kbn_hin
			,kbn.nm_kbn_hin
			,haigo.nm_haigo_ja AS nm_hinmei_ja
			,haigo.nm_haigo_en AS nm_hinmei_en
			,haigo.nm_haigo_zh AS nm_hinmei_zh
			,haigo.nm_haigo_vi AS nm_hinmei_vi
			,CONVERT(VARCHAR, haigo.wt_kihon) AS nm_naiyo
		FROM (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,ma.nm_haigo_ja
				,ma.nm_haigo_en
				,ma.nm_haigo_zh
				,ma.nm_haigo_vi
				,ma.wt_kihon
				,ma.flg_mishiyo
			FROM
				ma_haigo_mei ma
			INNER JOIN (
				-- 最大版を取得
				SELECT cd_haigo
					,MAX(no_han) AS no_han
				FROM ma_haigo_mei
				WHERE
					(@flg_mishiyo_fukumu <> @falseFlag OR flg_mishiyo = @falseFlag)
				GROUP BY cd_haigo
			) maxHan
			ON ma.cd_haigo = maxHan.cd_haigo
			AND ma.no_han = maxHan.no_han
			
			WHERE
				(@flg_mishiyo_fukumu <> @falseFlag OR ma.flg_mishiyo = @falseFlag)
			AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0
				OR ma.nm_haigo_ja LIKE '%' + @con_name + '%'
				OR ma.nm_haigo_en LIKE '%' + @con_name + '%'
				OR ma.nm_haigo_zh LIKE '%' + @con_name + '%'
				OR ma.nm_haigo_vi LIKE '%' + @con_name + '%'
				OR ma.cd_haigo LIKE '%' + @con_name + '%')
		) haigo

		-- 製品の製造可能ラインマスタ
		INNER JOIN (
			SELECT ma.cd_haigo
			FROM ma_seizo_line ma
			
			INNER JOIN ma_line li
			ON ma.cd_line = li.cd_line
			AND li.cd_shokuba = @shokubaCode
			AND li.flg_mishiyo = @falseFlag
			
			INNER JOIN ma_shokuba sho
			ON li.cd_shokuba = sho.cd_shokuba
			AND sho.flg_mishiyo = @falseFlag
			
			WHERE kbn_master = @masterKbnHaigo
			GROUP BY cd_haigo
		) sl
		ON sl.cd_haigo = haigo.cd_haigo

		-- 品区分マスタ
		LEFT JOIN ma_kbn_hin kbn
		ON kbn.kbn_hin = @hinKbn

		-- 有効版用の配合名マスタ
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,(SELECT top 1 udf.cd_hinmei
				  FROM udf_HaigoRecipeYukoHan(ma.cd_haigo, @falseFlag, @seizoDate) udf
				 ) AS yuko_haigo
			FROM
				ma_haigo_mei ma
			INNER JOIN (
				-- 最大版を取得
				SELECT cd_haigo
					,MAX(no_han) AS no_han
				FROM ma_haigo_mei
				WHERE
					(@flg_mishiyo_fukumu <> @falseFlag OR flg_mishiyo = @falseFlag)
				GROUP BY cd_haigo
			) maxHan
			ON ma.cd_haigo = maxHan.cd_haigo
			AND ma.no_han = maxHan.no_han
			WHERE
				(@flg_mishiyo_fukumu <> @falseFlag OR ma.flg_mishiyo = @falseFlag)
			AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0
				OR ma.nm_haigo_ja LIKE '%' + @con_name + '%'
				OR ma.nm_haigo_en LIKE '%' + @con_name + '%'
				OR ma.nm_haigo_zh LIKE '%' + @con_name + '%'
				OR ma.nm_haigo_vi LIKE '%' + @con_name + '%'
				OR ma.cd_haigo LIKE '%' + @con_name + '%')
		) yuko_hin
		ON yuko_hin.cd_haigo = haigo.cd_haigo

		WHERE yuko_hin.yuko_haigo IS NOT NULL
		ORDER BY haigo.cd_haigo
	END



END
GO
