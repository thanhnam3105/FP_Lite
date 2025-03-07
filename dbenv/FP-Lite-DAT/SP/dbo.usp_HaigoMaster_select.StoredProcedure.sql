IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoMaster_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoMaster_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.05.30>
-- Last Update: <2016.12.13 motojima.m>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoMaster_select]
	@kbn_hin smallint
	,@kbn_master smallint
	,@dt_shokichi varchar(10)
	,@flg_mishiyo smallint
	,@cd_bunrui varchar(6)
	--,@nm_haigo varchar(50)
	,@nm_haigo nvarchar(50)
	,@lang varchar(2)
	,@skip decimal(10)
	,@top decimal(10)
	,@count int output
AS
BEGIN

	DECLARE 
		@errno int
		,@start decimal(10)
		,@end decimal(10)
		,@searchHan int = 1

	SET @start = @skip
	SET @end = @skip + @top;
	
	WITH cte AS
	(
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
			,haigo.cd_tanto_seizo				AS cd_tanto_seizo
			,tanto_seizo.nm_tanto				AS nm_tanto_seizo
			,ISNULL(haigo.dt_seizo_koshin,'')	AS dt_seizo_koshin
			,haigo.cd_tanto_hinkan				AS cd_tanto_hinkan
			,tanto_hinkan.nm_tanto				AS nm_tanto_hinkan
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
			,ROW_NUMBER() OVER (ORDER BY haigo.cd_haigo) AS RN
		FROM 
			(
				SELECT
					*
				FROM dbo.ma_haigo_mei
				WHERE 
					no_han = @searchHan
					AND CASE WHEN ISNULL(@flg_mishiyo,0) = 0
							THEN flg_mishiyo
							ELSE ISNULL(@flg_mishiyo,0)
						END = ISNULL(@flg_mishiyo,0)
					AND CASE WHEN @cd_bunrui IS NULL
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
			) haigo
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
	)
	SELECT
		cd_haigo
		,nm_haigo_ja
		,nm_haigo_en
		,nm_haigo_zh
		,nm_haigo_vi
		,nm_haigo_ryaku
		,ritsu_budomari
		,wt_kihon
		,ritsu_kihon
		,flg_gassan_shikomi
		,wt_saidai_shikomi
		,no_han
		,wt_haigo
		,wt_haigo_gokei
		,biko
		,no_seiho
		,cd_tanto_seizo
		,nm_tanto_seizo
		,dt_seizo_koshin
		,cd_tanto_hinkan
		,nm_tanto_hinkan
		,dt_hinkan_koshin
		,dt_from
		,kbn_kanzan
		,nm_tani
		,ritsu_hiju
		,flg_shorihin
		,flg_tanto_hinkan
		,flg_tanto_seizo
		,kbn_shiagari
		,cd_bunrui
		,flg_tenkai
		,flg_mishiyo
		,wt_kowake
		,su_kowake
		,ts
		,kbn_hin
		,nm_bunrui
		,cd_line
		,nm_line
		,no_juni_yusen
		,cd_create
		,nm_create
		,dt_create
		,cd_update
		,nm_update
		,dt_update
	FROM cte		
	WHERE 
		RN BETWEEN @start AND @end
		
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
			,haigo.cd_tanto_seizo				AS cd_tanto_seizo
			,tanto_seizo.nm_tanto				AS nm_tanto_seizo
			,haigo.dt_seizo_koshin				AS dt_seizo_koshin
			,haigo.cd_tanto_hinkan				AS cd_tanto_hinkan
			,tanto_hinkan.nm_tanto				AS nm_tanto_hinkan
			,haigo.dt_hinkan_koshin				AS dt_hinkan_koshin
			,ISNULL(haigo.dt_from,@dt_shokichi)	AS dt_from
			,ISNULL(haigo.kbn_kanzan,0)			AS kbn_kanzan
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
			,ROW_NUMBER() OVER (ORDER BY haigo.cd_haigo) AS RN
		FROM 
			(
				SELECT
					*
				FROM dbo.ma_haigo_mei
				WHERE 
					no_han = @searchHan
					AND CASE WHEN ISNULL(@flg_mishiyo,0) = 0
							THEN flg_mishiyo
							ELSE ISNULL(@flg_mishiyo,0)
						END = ISNULL(@flg_mishiyo,0)
					AND CASE WHEN @cd_bunrui IS NULL
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
			) haigo
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

	SET @count = @@ROWCOUNT

END
GO
