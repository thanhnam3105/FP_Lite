IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippo_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ADMAX kakuta.y
-- Create date: 2015.12.21
-- Last Update: 2022.04.25 yashiro.k
-- Description:	製造日報検索処理
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoNippo_select]
	@seizoDate			DATETIME
	,@shokubaCode		VARCHAR(10)
	,@lineCode			VARCHAR(10)
	,@masterKubun		SMALLINT
	,@anbunKubunSeizo	VARCHAR(1)
	,@anbunKubunZan		VARCHAR(1)
	,@mishiyoFlagShiyo	SMALLINT
	,@skip				SMALLINT
	,@top				SMALLINT
	,@isExcel			BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @start	SMALLINT
			,@end	SMALLINT
			,@true	BIT
			,@false	BIT
	SET @start = @skip + 1;
	SET @end = @top;
	SET @true = 1;
	SET @false = 0;

	WITH cte AS
	(
		SELECT
			nippo.*
			,ROW_NUMBER() OVER (ORDER BY nippo.cd_hinmei, nippo.no_lot_seihin) AS RN
		FROM
		(
			SELECT DISTINCT
				seihin.no_lot_seihin
				, seihin.dt_seizo
				, seihin.cd_shokuba
				, seihin.cd_line
				, seihin.cd_hinmei
				, seihin.su_seizo_yotei
				, COALESCE(seihin.su_seizo_jisseki, seihin.su_seizo_yotei) AS 'su_seizo_jisseki'
				, seihin.flg_jisseki
				, seihin.kbn_denso
				, seihin.flg_denso
				, seihin.dt_update
				, hin.nm_hinmei_ja
				, hin.nm_hinmei_en
				, hin.nm_hinmei_zh
				, hin.nm_hinmei_vi
				, '' AS 'nm_hinmei'
				, shoku.nm_shokuba
				, line.nm_line
				, hin.flg_mishiyo AS 'flg_mishiyo_hinmei'
				, line.flg_mishiyo AS 'flg_mishiyo_line'
				, seihin.dt_shomi AS 'dt_shomi'
				, seizoLine.flg_mishiyo AS 'flg_mishiyo_seizo_line'
				, seizoLine.kbn_master
				, seihin.su_batch_jisseki
				, hin.wt_ko
				, hin.su_iri
				, hin.flg_mishiyo
				, hin.dd_shomi
				 -- 倍率
				,CASE
					WHEN hin.cd_haigo IS NOT NULL THEN (SELECT TOP 1 ritsu_kihon FROM udf_HaigoRecipeYukoHan(hin.cd_haigo, hin.flg_mishiyo, seihin.dt_seizo))
					ELSE NULL
				 END AS 'ritsu_kihon'
				 -- 合計配合重量
				,CASE
					WHEN hin.cd_haigo IS NOT NULL THEN (SELECT TOP 1 wt_haigo_gokei FROM udf_HaigoRecipeYukoHan(hin.cd_haigo, hin.flg_mishiyo, seihin.dt_seizo))
					ELSE 0
				 END AS 'wt_haigo_gokei'
				 -- 歩留
				,CASE
					WHEN hin.cd_haigo IS NOT NULL THEN (SELECT TOP 1 ritsu_budomari_mei FROM udf_HaigoRecipeYukoHan(hin.cd_haigo, hin.flg_mishiyo, seihin.dt_seizo))
					ELSE NULL
				 END AS 'haigo_budomari'
				,seihin.no_lot_hyoji
				,CASE
					WHEN EXISTS(SELECT * FROM udf_SeizoNippoUchiwake_select(seihin.cd_hinmei, seihin.no_lot_seihin, @anbunKubunSeizo, @anbunKubunZan, @mishiyoFlagShiyo)) THEN '1'
					ELSE NULL
				END AS 'flg_uchiwake'
				,ISNULL(anbun.no_lot_seihin, '') AS 'flg_zan'
				, hin.kbn_hin AS 'kbn_hin'
			FROM dbo.tr_keikaku_seihin seihin

			LEFT OUTER JOIN dbo.ma_hinmei hin
			ON seihin.cd_hinmei = hin.cd_hinmei

			LEFT OUTER JOIN dbo.ma_line line
			ON seihin.cd_line = line.cd_line

			LEFT OUTER JOIN dbo.ma_shokuba shoku
			ON seihin.cd_shokuba = shoku.cd_shokuba

			LEFT OUTER JOIN dbo.ma_seizo_line seizoLine
			ON seihin.cd_hinmei = seizoLine.cd_haigo
			AND line.cd_line = seizoLine.cd_line

			LEFT OUTER JOIN dbo.tr_sap_shiyo_yojitsu_anbun anbun
			ON seihin.no_lot_seihin = anbun.no_lot_seihin
			AND anbun.kbn_shiyo_jisseki_anbun = @anbunKubunZan

			WHERE
				seihin.dt_seizo = @seizoDate
				AND seihin.cd_shokuba = @shokubaCode
				AND seizoLine.kbn_master = @masterKubun
				AND (@lineCode IS NULL
					OR (@lineCode IS NOT NULL AND @lineCode = seihin.cd_line))
		) nippo
	)

	SELECT
		cte_row.no_lot_seihin
		,cte_row.dt_seizo
		,cte_row.cd_shokuba
		,cte_row.cd_line
		,cte_row.cd_hinmei
		,cte_row.su_seizo_yotei
		,cte_row.su_seizo_jisseki
		,cte_row.flg_jisseki
		,cte_row.kbn_denso
		,cte_row.flg_denso
		,cte_row.dt_update
		,cte_row.nm_hinmei_ja
		,cte_row.nm_hinmei_en
		,cte_row.nm_hinmei_zh
		,cte_row.nm_hinmei_vi
		,cte_row.nm_hinmei
		,cte_row.nm_shokuba
		,cte_row.nm_line
		,cte_row.flg_mishiyo_hinmei
		,cte_row.flg_mishiyo_line
		,cte_row.dt_shomi
		,cte_row.flg_mishiyo_seizo_line
		,cte_row.kbn_master
		,cte_row.su_batch_jisseki
		,cte_row.wt_ko
		,cte_row.su_iri
		,cte_row.flg_mishiyo
		,cte_row.dd_shomi
		,cte_row.ritsu_kihon
		,cte_row.wt_haigo_gokei
		,cte_row.haigo_budomari
		,cte_row.no_lot_hyoji
		,cte_row.flg_uchiwake
		,cte_row.flg_zan
		,cte_row.RN
		,cte_row.cnt
		,cte_row.kbn_hin
	FROM
		(
			SELECT 
				MAX(RN) OVER() AS cnt
				,*
			FROM cte 
		) cte_row
	WHERE
		( 
			( 
				@isExcel = @false				-- 検索のみの場合は指定行数を抽出
				AND RN BETWEEN @start AND @end
			)
			OR @isExcel = @true					-- Excel出力は全行出力
		)

	ORDER BY cte_row.RN

END

GO
