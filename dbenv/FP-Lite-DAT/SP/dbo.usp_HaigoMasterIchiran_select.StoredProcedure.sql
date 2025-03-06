IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoMasterIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoMasterIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.11.21>
-- Last Update: <2016.12.13 motojima.m>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoMasterIchiran_select]
	@kbn_hin				SMALLINT		-- 品区分
	,@kbn_master			SMALLINT		-- マスタ区分
	--,@dt_shokichi			varchar(10)		-- 日付初期値
	,@dt_shokichi			DATETIME		-- 日付初期値
	,@flg_mishiyo			SMALLINT		-- 未使用フラグ
	,@cd_bunrui				VARCHAR(10)		-- 分類コード
	--,@nm_haigo			VARCHAR(50)		-- 配合名
	,@nm_haigo				NVARCHAR(50)	-- 配合名
	,@lang					VARCHAR(2)		-- 言語
	--,@searchHan			decimal			-- 検索版
	--,@sysDate				datetime		--当日日付
	,@dt_from				DATETIME		-- 有効日付
	,@shiyoMishiyoFlag		SMALLINT		-- 未使用フラグ.使用
	,@mishiyoMishiyoFlag	SMALLINT		-- 未使用フラグ.未使用
AS
BEGIN

	SET NOCOUNT ON
	
	SELECT
		ISNULL(haigo.cd_haigo,'')			AS cd_haigo
		,haigo.nm_haigo_ja					AS nm_haigo_ja
		,haigo.nm_haigo_en					AS nm_haigo_en
		,haigo.nm_haigo_zh					AS nm_haigo_zh
		,haigo.nm_haigo_vi					AS nm_haigo_vi
		,haigo.nm_haigo_ryaku				AS nm_haigo_ryaku
		,haigo.ritsu_budomari				AS ritsu_budomari
		,ISNULL(haigo.wt_kihon,0)			AS wt_kihon
		,haigo.ritsu_kihon					AS ritsu_kihon
		,ISNULL(haigo.flg_gassan_shikomi,0)	AS flg_gassan_shikomi
		,haigo.wt_saidai_shikomi			AS wt_saidai_shikomi
		,ISNULL(haigo.no_han,0)				AS no_han
		,ISNULL(haigo.wt_haigo,0)			AS wt_haigo
		,haigo.wt_haigo_gokei				AS wt_haigo_gokei
		,haigo.biko							AS biko
		,haigo.no_seiho						AS no_seiho
		,ISNULL(haigo.cd_tanto_seizo,'')	AS cd_tanto_seizo
		,ISNULL(tanto_seizo.nm_tanto,'')	AS nm_tanto_seizo
		,ISNULL(haigo.dt_seizo_koshin,'')	AS dt_seizo_koshin
		,ISNULL(haigo.cd_tanto_hinkan,'')	AS cd_tanto_hinkan
		,ISNULL(tanto_hinkan.nm_tanto,'')	AS nm_tanto_hinkan
		,ISNULL(haigo.dt_hinkan_koshin,'')	AS dt_hinkan_koshin
		,ISNULL(haigo.dt_from,@dt_shokichi)	AS dt_from
		,ISNULL(haigo.kbn_kanzan,'0')		AS kbn_kanzan
		,ISNULL(tani.nm_tani,'')			AS nm_tani
		,haigo.ritsu_hiju					AS ritsu_hiju
		,ISNULL(haigo.flg_shorihin,0)		AS flg_shorihin
		,ISNULL(haigo.flg_tanto_hinkan,0)	AS flg_tanto_hinkan
		,ISNULL(haigo.flg_tanto_seizo,0)	AS flg_tanto_seizo
		,ISNULL(haigo.kbn_shiagari,0)		AS kbn_shiagari
		,haigo.cd_bunrui					AS cd_bunrui
		,ISNULL(haigo.flg_tenkai,0)			AS flg_tenkai
		,haigo.flg_mishiyo					AS flg_mishiyo
		,haigo.wt_kowake					AS wt_kowake
		,haigo.su_kowake					AS su_kowake
		,haigo.ts							AS ts
		,bunrui.kbn_hin						AS kbn_hin
		,bunrui.nm_bunrui					AS nm_bunrui
		,seizo_line.cd_line					AS cd_line
		,seizo_line.nm_line					AS nm_line
		,seizo_line.no_juni_yusen			AS no_juni_yusen
		,ISNULL(haigo.cd_create,'')			AS cd_create
		,toroku.nm_tanto					AS nm_create
		,ISNULL(haigo.dt_create,@dt_shokichi) AS dt_create
		,ISNULL(haigo.cd_update,'')			AS cd_update
		,koshin.nm_tanto					AS nm_update
		,ISNULL(haigo.dt_update,@dt_shokichi) AS dt_update
	FROM 
		(
			SELECT
				uni.cd_haigo
				,MAX(uni.no_han) AS no_han
			FROM
				(
					SELECT DISTINCT
						--*,
						haigoMax.cd_haigo
						--,MAX(haigoMax.no_han) AS no_han
						,(SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(haigoMax.cd_haigo, @mishiyoMishiyoFlag, @dt_from)) AS no_han
					FROM dbo.ma_haigo_mei haigoMax
					WHERE
						--no_han = @searchHan
						--dt_from <= @sysDate
						--AND CASE WHEN ISNULL(@flg_mishiyo,0) = 0
						--		THEN flg_mishiyo
						--		ELSE ISNULL(@flg_mishiyo,0)
						--	END = ISNULL(@flg_mishiyo,0)
						--AND 
						CASE WHEN @cd_bunrui IS NULL
								THEN ISNULL(@cd_bunrui,'0') 
								ELSE cd_bunrui
							END = ISNULL(@cd_bunrui,'0')
						AND	(
							CASE WHEN @nm_haigo IS NULL OR @nm_haigo = '' 
								THEN '%' + ISNULL(@nm_haigo,'') + '%'
								ELSE(
									CASE @lang	WHEN 'ja' THEN nm_haigo_ja 
												WHEN 'en' THEN nm_haigo_en
												WHEN 'zh' THEN nm_haigo_zh
												WHEN 'vi' THEN nm_haigo_vi
									END)
							END LIKE '%' + ISNULL(@nm_haigo,'') + '%'
							OR cd_haigo LIKE '%' + ISNULL(@nm_haigo,'') + '%'
						)
					--GROUP BY haigoMax.cd_haigo--, haigoMax.no_han

					--
					UNION ALL

					SELECT DISTINCT
						haigoMax.cd_haigo
						,(SELECT TOP 1 no_han FROM udf_HaigoRecipeYukoHan(haigoMax.cd_haigo, @shiyoMishiyoFlag, @dt_from)) AS no_han
					FROM dbo.ma_haigo_mei haigoMax
					WHERE
						CASE WHEN @cd_bunrui IS NULL
							THEN ISNULL(@cd_bunrui,'0') 
							ELSE cd_bunrui
						END = ISNULL(@cd_bunrui,'0')
						AND	(
							CASE WHEN @nm_haigo IS NULL OR @nm_haigo = '' 
								THEN '%' + ISNULL(@nm_haigo,'') + '%'
								ELSE(
									CASE @lang	WHEN 'ja' THEN nm_haigo_ja 
												WHEN 'en' THEN nm_haigo_en
												WHEN 'zh' THEN nm_haigo_zh
												WHEN 'vi' THEN nm_haigo_vi
									END)
							END LIKE '%' + ISNULL(@nm_haigo,'') + '%'
							OR cd_haigo LIKE '%' + ISNULL(@nm_haigo,'') + '%'
						)
						AND @flg_mishiyo = @shiyoMishiyoFlag
				) uni
			GROUP BY uni.cd_haigo
		) haigoHan
	LEFT OUTER JOIN dbo.ma_haigo_mei haigo
	ON haigo.cd_haigo = haigoHan.cd_haigo
	AND haigo.no_han = haigoHan.no_han
	LEFT JOIN dbo.ma_tani tani
	ON haigo.kbn_kanzan = tani.cd_tani
	LEFT JOIN dbo.ma_tanto toroku
	ON haigo.cd_create = toroku.cd_tanto
	LEFT JOIN dbo.ma_tanto koshin
	ON haigo.cd_update = koshin.cd_tanto
	LEFT JOIN dbo.ma_tanto tanto_seizo
	ON haigo.cd_tanto_seizo = tanto_seizo.cd_tanto
	LEFT JOIN dbo.ma_tanto tanto_hinkan
	ON haigo.cd_tanto_hinkan = tanto_hinkan.cd_tanto
	LEFT JOIN
		(
			SELECT
				cd_bunrui
				,kbn_hin
				,nm_bunrui 
			FROM dbo.ma_bunrui	
			WHERE 
				kbn_hin = @kbn_hin		--仕掛品
		) bunrui
	ON haigo.cd_bunrui = bunrui.cd_bunrui
	LEFT JOIN	
		(
			SELECT
				msl.cd_haigo AS cd_haigo
				,msl.cd_line AS cd_line
				,ml.nm_line AS nm_line
				,msl.no_juni_yusen AS no_juni_yusen
			FROM ma_seizo_line msl
			INNER JOIN
				(
					SELECT
						cd_haigo
						,kbn_master
						,MIN(no_juni_yusen) no_juni_yusen	--優先順位の高いライン
					FROM ma_seizo_line
					WHERE 
						kbn_master = @kbn_master
						AND flg_mishiyo = 0
					GROUP BY 
						cd_haigo
						,kbn_master
				) yusen
			ON msl.cd_haigo = yusen.cd_haigo
			AND msl.no_juni_yusen = yusen.no_juni_yusen
			AND msl.kbn_master = yusen.kbn_master
			INNER JOIN ma_line ml
			ON msl.cd_line = ml.cd_line
		) seizo_line
	ON haigo.cd_haigo = seizo_line.cd_haigo
	WHERE
		haigoHan.no_han IS NOT NULL
END
GO
