IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ma_haigo_mei_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ma_haigo_mei_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ADMAX kakuta.y
-- Create date: 2016.01.04
-- Description:	vw_ma_haigo_mei_01を有効版で取得するためストアド化
-- =============================================
CREATE PROCEDURE [dbo].[usp_ma_haigo_mei_01]
	@haigoCode			VARCHAR(14)	-- 画面.明細/コード
	,@today				DATETIME	-- システム日付(比較対象のdt_fromと同様に時刻は10:00固定)
	,@shikakariHinKubun	SMALLINT	-- 区分／コード一覧.品区分.仕掛品
	,@shiyoMishiyoFlag	SMALLINT	-- 区分／コード一覧.未使用フラグ.使用
AS
BEGIN
	SET NOCOUNT ON;

    SELECT TOP 1
		haigo.cd_haigo								AS cd_haigo
		,haigo.nm_haigo_ja							AS nm_haigo_ja
		,haigo.nm_haigo_en							AS nm_haigo_en
		,haigo.nm_haigo_zh							AS nm_haigo_zh
		,haigo.nm_haigo_vi							AS nm_haigo_vi
		,haigo.nm_haigo_ryaku						AS nm_haigo_ryaku
		,haigo.ritsu_budomari						AS ritsu_budomari
		,haigo.wt_kihon								AS wt_kihon
		,haigo.ritsu_kihon							AS ritsu_kihon
		,haigo.flg_gassan_shikomi					AS flg_gassan_shikomi
		,haigo.wt_saidai_shikomi					AS wt_saidai_shikomi
		,haigo.no_han								AS no_han
		,haigo.wt_haigo								AS wt_haigo
		,haigo.wt_haigo_gokei						AS wt_haigo_gokei
		,haigo.biko									AS biko
		,haigo.no_seiho								AS no_seiho
		,ISNULL(haigo.cd_tanto_seizo, '')			AS cd_tanto_seizo
		,ISNULL(tanto_seizo.nm_tanto, '')			AS nm_tanto_seizo
		,haigo.dt_seizo_koshin						AS dt_seizo_koshin
		,ISNULL(haigo.cd_tanto_hinkan, '')			AS cd_tanto_hinkan
		,ISNULL(tanto_hinkan.nm_tanto, '')			AS nm_tanto_hinkan
		,haigo.dt_hinkan_koshin						AS dt_hinkan_koshin
		,haigo.dt_from								AS dt_from
		,haigo.kbn_kanzan							AS kbn_kanzan
		,ISNULL(tani.nm_tani, '')					AS nm_tani_shiyo
		,ISNULL(haigo.ritsu_hiju, 0)				AS ritsu_hiju
		,haigo.flg_shorihin							AS flg_shorihin
		,haigo.flg_tanto_hinkan						AS flg_tanto_hinkan
		,haigo.flg_tanto_seizo						AS flg_tanto_seizo
		,haigo.kbn_shiagari							AS kbn_shiagari
		,haigo.cd_bunrui							AS cd_bunrui
		,haigo.flg_mishiyo							AS flg_mishiyo
		,haigo.wt_kowake							AS wt_kowake
		,haigo.su_kowake							AS su_kowake
		,haigo.ts									AS ts
		,ISNULL(bunrui.kbn_hin, @shikakariHinKubun)	AS kbn_hin
		,bunrui.nm_bunrui							AS nm_bunrui
		,haigo.cd_create							AS cd_create
		,toroku.nm_tanto							AS nm_create
		,haigo.dt_create							AS dt_create
		,haigo.cd_update							AS cd_update
		,koshin.nm_tanto							AS nm_update
		,haigo.dt_update							AS dt_update
		,ISNULL(haigo.flg_tenkai, 0)				AS flg_tenkai
		,haigo.dd_shomi								AS dd_shomi
		,haigo.kbn_hokan							AS kbn_hokan
		,hokan.nm_hokan_kbn                         AS nm_hokan_kbn
	FROM dbo.ma_haigo_mei haigo
	INNER JOIN
	(
		SELECT TOP 1
			udf.cd_haigo
			,udf.no_han
		FROM udf_HaigoRecipeYukoHan(@haigoCode, @shiyoMishiyoFlag, @today) udf
	) yukoHaigo
	ON haigo.cd_haigo = yukoHaigo.cd_haigo
	AND haigo.no_han = yukoHaigo.no_han

	LEFT OUTER JOIN dbo.ma_tani tani
	ON haigo.kbn_kanzan = tani.cd_tani
	LEFT OUTER JOIN dbo.ma_tanto toroku
	ON haigo.cd_create = toroku.cd_tanto
	LEFT OUTER JOIN dbo.ma_tanto koshin
	ON haigo.cd_update = koshin.cd_tanto
	LEFT OUTER JOIN dbo.ma_tanto tanto_seizo
	ON haigo.cd_tanto_seizo = tanto_seizo.cd_tanto
	LEFT OUTER JOIN dbo.ma_tanto tanto_hinkan
	ON haigo.cd_tanto_hinkan = tanto_hinkan.cd_tanto
	LEFT OUTER JOIN dbo.ma_bunrui bunrui
	ON haigo.cd_bunrui = bunrui.cd_bunrui
	LEFT OUTER JOIN dbo.ma_kbn_hokan hokan
	ON haigo.kbn_hokan = hokan.cd_hokan_kbn

	WHERE
		haigo.cd_haigo = @haigoCode
		AND ISNULL(haigo.flg_mishiyo, 0) = @shiyoMishiyoFlag

END
GO
