IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinShiyoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinShiyoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**********************************************************************
機能：仕掛品使用一覧画面　検索処理
ファイル名：usp_ShikakarihinShiyoIchiran_select
入力引数：@dt_seizo
            ,@cd_shokuba
            ,@cd_line
            ,@FlagFalse
            ,@HaigoMasterKbn
            ,@skip
            ,@top
出力引数：-
戻り値：-
作成日：2014.03.24 endo.y
更新日：
**********************************************************************/
CREATE PROCEDURE [dbo].[usp_ShikakarihinShiyoIchiran_select]
    @dt_shikomi_search	DATETIME
    ,@shikakariCode		VARCHAR(14)
    ,@no_han			SMALLINT
	,@skip				DECIMAL(10)
	,@top				DECIMAL(10)
	,@isExcel			BIT
AS
BEGIN
	DECLARE @start	DECIMAL(10)
	DECLARE	@end	DECIMAL(10)
	DECLARE @true	BIT
	DECLARE @false	BIT
	SET @start = @skip + 1
	SET @end = @skip + @top
	SET @true  = 1
	SET @false = 0
	BEGIN
	WITH cte AS
		(
			select
				isnull(s_shi.flg_keikaku,0) AS flg_keikaku
				,t_shi.dt_seizo AS dt_shikomi
				,isnull(shikakari_shokuba.nm_shokuba,'') AS nm_shokuba_shikomi
				,isnull(shikakari_line.nm_line,'') AS nm_line_shikomi
				,isnull(t_shi.wt_shikomi_keikaku,0) AS wt_shikomi_keikaku
				,isnull(t_shi.no_lot_shikakari,'') AS no_lot_shikakari
				,isnull(s_shi.flg_label,0) AS flg_label
				,isnull(s_shi.flg_label_hasu,0) AS flg_label_hasu
				,t_sei.dt_seizo AS dt_seihin_seizo
				,isnull(seihin_shokuba.nm_shokuba,'') AS nm_shokuba_seizo
				,isnull(seihin_line.nm_line,'') AS nm_line_seizo
				,isnull(t_sei.cd_hinmei,'') AS cd_hinmei
				,isnull(mh.nm_hinmei_ja,'') AS nm_hinmei_ja
				,isnull(mh.nm_hinmei_en,'') AS nm_hinmei_en
				,isnull(mh.nm_hinmei_zh,'') AS nm_hinmei_zh
				,isnull(mh.nm_hinmei_vi,'') AS nm_hinmei_vi
				,isnull(t_sei.su_seizo_yotei,0) AS su_seizo_yotei
				,isnull(t_shi.no_lot_seihin,'') AS no_lot_seihin
				,t_shi.cd_shikakari_hin AS cd_shikakari_hin
				,isnull(mhm.nm_haigo_ja,'') AS nm_haigo_ja
				,isnull(mhm.nm_haigo_en,'') AS nm_haigo_en
				,isnull(mhm.nm_haigo_zh,'') AS nm_haigo_zh
				,isnull(mhm.nm_haigo_vi,'') AS nm_haigo_vi
				,isnull(t_shi.no_lot_shikakari_oya,'') AS no_lot_shikakari_oya
                ,ROW_NUMBER() OVER (ORDER BY t_shi.dt_seizo,t_shi.cd_shokuba,t_shi.cd_line,t_shi.no_lot_shikakari) AS RN
			from tr_keikaku_shikakari t_shi
				left join tr_keikaku_seihin t_sei
					on t_shi.no_lot_seihin = t_sei.no_lot_seihin
				left join ma_shokuba seihin_shokuba
					on t_sei.cd_shokuba = seihin_shokuba.cd_shokuba
				left join ma_line seihin_line
					on t_sei.cd_line = seihin_line.cd_line
				left join su_keikaku_shikakari s_shi
					on t_shi.no_lot_shikakari = s_shi.no_lot_shikakari
				left join su_keikaku_shikakari s_shi_oya
					on t_shi.no_lot_shikakari_oya = s_shi_oya.no_lot_shikakari
				left join ma_shokuba shikakari_shokuba
					on t_shi.cd_shokuba = shikakari_shokuba.cd_shokuba
				left join ma_line shikakari_line
					on t_shi.cd_line = shikakari_line.cd_line
				left join ma_haigo_mei mhm
					on s_shi_oya.cd_shikakari_hin = mhm.cd_haigo
						and mhm.no_han = 1
				left join ma_hinmei mh
					on t_sei.cd_hinmei = mh.cd_hinmei
			where t_shi.cd_shikakari_hin = @shikakariCode --画面.検索条件/仕掛品コード
				and t_shi.dt_seizo >= @dt_shikomi_search --画面.検索条件/製造日
		)
		SELECT
            cnt
			,cte_row.flg_keikaku
			,cte_row.dt_shikomi
			,cte_row.nm_shokuba_shikomi
			,cte_row.nm_line_shikomi
			,cte_row.wt_shikomi_keikaku
			,cte_row.no_lot_shikakari
			,cte_row.flg_label
			,cte_row.flg_label_hasu
			,cte_row.dt_seihin_seizo
			,cte_row.nm_shokuba_seizo
			,cte_row.nm_line_seizo
			,cte_row.cd_hinmei
			,cte_row.nm_hinmei_ja
			,cte_row.nm_hinmei_en
			,cte_row.nm_hinmei_zh
			,cte_row.nm_hinmei_vi
			,cte_row.su_seizo_yotei
			,cte_row.no_lot_seihin 
			,cte_row.cd_shikakari_hin
			,cte_row.nm_haigo_ja
			,cte_row.nm_haigo_en
			,cte_row.nm_haigo_zh
			,cte_row.nm_haigo_vi
			,cte_row.no_lot_shikakari_oya
		FROM (
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) 
            cte_row
		WHERE
		( 
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR (
				@isExcel = @true
			)
		)
	END
END
GO
