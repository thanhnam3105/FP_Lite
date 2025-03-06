IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HaigoRecipeMaster_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HaigoRecipeMaster_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.10.18>
-- Last Update: 2015.05.01 tsujita.s
-- Last Update: 2017.03.17 BRC.kanehira.d ZH要望対応_マークL対応
-- Description:	配合レシピ登録PDFの検索処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_HaigoRecipeMaster_select_02]
	@cd_haigo varchar(14)
	,@no_han decimal(4,0)
	,@no_kotei decimal(4,0)
	,@hanNoShokichi decimal(4,0)
AS
BEGIN

	DECLARE 
		@errno int
		
		SELECT
			recipe.no_seq AS no_seq
			,recipe.cd_haigo AS cd_haigo
			,mei.nm_haigo_ryaku AS nm_haigo_ryaku
			,recipe.no_han AS no_han
			,recipe.no_kotei AS no_kotei
			,recipe.wt_haigo AS wt_haigo
			,mei.flg_mishiyo AS flg_mishiyo
			,mei.no_seiho AS no_seiho
			,mei.biko AS biko
			,mei.dt_from AS dt_from
			,recipe.cd_hinmei AS cd_hinmei
			,recipe.nm_hinmei AS nm_hinmei
			,recipe.no_tonyu AS no_tonyu
			,recipe.kbn_hin AS kbn_hin
			,recipe.cd_mark AS cd_mark
			,mark.mark AS mark
			,mark.nm_mark AS nm_mark
			,recipe.wt_shikomi AS wt_shikomi
			,COALESCE(tani.cd_tani, haigoTani.cd_tani) AS kbn_kanzan
			,COALESCE(tani.nm_tani, haigoTani.nm_tani) AS nm_tani_shiyo
			,recipe.wt_nisugata AS wt_nisugata
			,recipe.su_nisugata AS su_nisugata
			,recipe.wt_kowake AS wt_kowake
			,recipe.su_kowake AS su_kowake
			,recipe.ritsu_budomari AS ritsu_budomari
			,recipe.ritsu_hiju AS ritsu_hiju
			,recipe.su_settei AS su_settei
			,recipe.su_settei_max AS su_settei_max
			,recipe.su_settei_min AS su_settei_min
			,recipe.cd_futai AS cd_futai
			,futai.nm_futai AS nm_futai
			,recipe.dt_create AS dt_create
			,recipe.cd_create AS cd_create
			,recipe.dt_update AS dt_update
			,recipe.cd_update AS cd_update
			,recipe.ts AS ts
			,plc.no_komoku
			,plc.nm_komoku
		FROM
			dbo.ma_haigo_recipe recipe

		INNER JOIN dbo.ma_haigo_mei mei
		ON recipe.cd_haigo = mei.cd_haigo
		AND recipe.no_han = mei.no_han

		LEFT JOIN 
			(SELECT
				cd_haigo 
				,kbn_kanzan
				FROM dbo.ma_haigo_mei
				WHERE no_han = @hanNoShokichi
			) shikakari
		ON recipe.cd_hinmei = shikakari.cd_haigo

		LEFT JOIN dbo.ma_hinmei hinmei
		ON recipe.cd_hinmei = hinmei.cd_hinmei

		LEFT JOIN dbo.ma_mark mark
		ON recipe.cd_mark = mark.cd_mark

		LEFT JOIN ma_tanto seizo
		ON mei.cd_tanto_seizo = seizo.cd_tanto

		LEFT JOIN ma_tanto hinkan
		ON mei.cd_tanto_hinkan = hinkan.cd_tanto

		LEFT JOIN ma_tani tani
		--ON hinmei.cd_tani_shiyo = tani.cd_tani
		ON hinmei.kbn_kanzan = tani.cd_tani

		LEFT JOIN ma_tani haigoTani
		ON shikakari.kbn_kanzan = haigoTani.cd_tani

		LEFT JOIN ma_futai futai
		ON recipe.cd_futai = futai.cd_futai
		
		LEFT JOIN ma_plc plc
		ON recipe.no_plc_komoku = plc.no_komoku

		WHERE recipe.cd_haigo = @cd_haigo
		AND recipe.no_han = @no_han
		AND CONVERT(VARCHAR,recipe.no_kotei) LIKE 
			CASE WHEN ISNULL(@no_kotei, 0) <> 0 
				THEN CONVERT(VARCHAR,@no_kotei)
				ELSE '%'
			END

		ORDER BY recipe.no_tonyu

END
GO
