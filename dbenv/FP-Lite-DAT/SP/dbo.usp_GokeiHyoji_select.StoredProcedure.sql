IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GokeiHyoji_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GokeiHyoji_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.08.20>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GokeiHyoji_select]
    @cd_shokuba varchar(10)
    ,@cd_line varchar(10)
    ,@true smallint
    ,@false smallint
    ,@dt_hiduke_from datetime
    ,@dt_hiduke_to datetime
    ,@dt_hiduke_today datetime
    ,@top decimal(10)

    
AS
BEGIN
        WITH cte AS
        (
			SELECT 
				keikaku_seihin.cd_hinmei
				,keikaku_seihin.dt_seizo
				,COALESCE(keikaku_seihin.su_seizo, 0) AS su_seizo
				,ROW_NUMBER() OVER 
				(
					ORDER BY 
						keikaku_seihin.dt_seizo
						,keikaku_seihin.cd_shokuba
						,keikaku_seihin.cd_line
						,keikaku_seihin.cd_hinmei
				) AS RN
			FROM
				( 	
					-- 予定（当日より未来）
					SELECT
						  dt_seizo
						  ,cd_shokuba
						  ,cd_line
						  ,cd_hinmei
						  ,su_seizo_yotei AS su_seizo
						  ,flg_jisseki
					FROM tr_keikaku_seihin
					WHERE dt_seizo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
					AND dt_seizo > @dt_hiduke_today
					AND cd_shokuba = @cd_shokuba
					AND cd_line = @cd_line
					UNION ALL
					-- 予定（当日）
					SELECT
						  dt_seizo
						  ,cd_shokuba
						  ,cd_line
						  ,cd_hinmei
						  ,su_seizo_yotei AS su_seizo
						  ,flg_jisseki
					FROM tr_keikaku_seihin
					WHERE dt_seizo = @dt_hiduke_today
					AND cd_shokuba = @cd_shokuba
					AND cd_line = @cd_line
					AND flg_jisseki = @false
					UNION ALL
					-- 実績（当日含）
					SELECT
						  dt_seizo
						  ,cd_shokuba
						  ,cd_line
						  ,cd_hinmei
						  ,su_seizo_jisseki AS su_seizo
						  ,flg_jisseki
					FROM tr_keikaku_seihin
					WHERE dt_seizo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
					AND dt_seizo <= @dt_hiduke_today
					AND cd_shokuba = @cd_shokuba
					AND cd_line = @cd_line
					AND flg_jisseki = @true
				) keikaku_seihin
		)
		SELECT
			cte_row.cd_hinmei
			,hinmei.nm_hinmei_en
			,hinmei.nm_hinmei_ja
			,hinmei.nm_hinmei_zh
			,hinmei.nm_hinmei_vi
			,SUM(cte_row.su_seizo) AS su_seizo
		FROM(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) cte_row
		-- 画面に返却する値を取得
		LEFT OUTER JOIN ma_hinmei hinmei
		ON cte_row.cd_hinmei = hinmei.cd_hinmei
		WHERE 
			cte_row.RN <= @top
		GROUP BY 
			cte_row.cd_hinmei
			,hinmei.nm_hinmei_en
			,hinmei.nm_hinmei_ja
			,hinmei.nm_hinmei_zh
			,hinmei.nm_hinmei_vi
		ORDER BY 
			cte_row.cd_hinmei
END
GO
