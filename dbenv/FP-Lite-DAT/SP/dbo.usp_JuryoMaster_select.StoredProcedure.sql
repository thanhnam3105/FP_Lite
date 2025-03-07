IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_JuryoMaster_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_JuryoMaster_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_JuryoMaster_select]
    @kbn_jotai SMALLINT
    ,@kbn_hin SMALLINT
    ,@cd_hinmei VARCHAR(14)
    ,@HanNoShokichi DECIMAL(4)
    ,@KotaiJotaiKubun SMALLINT
    ,@EkitaiJotaiKubun SMALLINT
    ,@SonotaJotaiKubun SMALLINT
    ,@ShikakarihinJotaiKubun SMALLINt
    ,@GenryoHinKubun SMALLINT
    ,@ShikakariHinKubun SMALLINT
    ,@lang VARCHAR(10)
    ,@skip DECIMAL(10)
    ,@top DECIMAL(10)
AS
BEGIN

    DECLARE @start DECIMAL(10)
    DECLARE @end DECIMAL(10)

    SET @start = @skip
    SET @end = @skip + @top

    -- 状態区分　個体、液体、仕掛品
    IF (@kbn_jotai = @KotaiJotaiKubun) OR (@kbn_jotai = @EkitaiJotaiKubun)
            OR (@kbn_jotai = @ShikakarihinJotaiKubun)
    BEGIN

        WITH cte AS
        (
            SELECT
                ju.kbn_jotai
                ,ju.kbn_hin
                ,ju.cd_hinmei
                ,CASE @lang WHEN 'ja' THEN hin.nm_hinmei_ja 
                            WHEN 'en' THEN hin.nm_hinmei_en
                            WHEN 'zh' THEN hin.nm_hinmei_zh
							WHEN 'vi' THEN hin.nm_hinmei_vi END AS nm_hinmei
                ,ju.wt_kowake
                ,ju.cd_create
                ,ju.dt_create
                ,ju.ts
				,ROW_NUMBER() OVER (ORDER BY ju.wt_kowake) AS RN
            FROM
            ma_juryo ju
            LEFT OUTER JOIN ma_hinmei hin
            ON ju.cd_hinmei = hin.cd_hinmei
            WHERE
                ju.kbn_jotai = @kbn_jotai
        )
        SELECT
			cte_row.cnt
            ,kbn_jotai
            ,kbn_hin
            ,cd_hinmei
			,nm_hinmei
			,wt_kowake
            ,cd_create
            ,dt_create
            ,ts
        FROM (
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) 
            cte_row
        WHERE RN BETWEEN @start AND @end

    END

    -- 状態区分　その他
    IF @kbn_jotai = @SonotaJotaiKubun
    BEGIN
        -- 品区分　原料
        IF @kbn_hin = @GenryoHinKubun
        BEGIN
            
            WITH cte AS
            (
                SELECT
                    ju.kbn_jotai
                    ,ju.kbn_hin
                    ,ju.cd_hinmei
                    ,CASE @lang WHEN 'ja' THEN hin.nm_hinmei_ja 
                                WHEN 'en' THEN hin.nm_hinmei_en
                                WHEN 'zh' THEN hin.nm_hinmei_zh
								WHEN 'vi' THEN hin.nm_hinmei_vi END AS nm_hinmei
                    ,ju.wt_kowake
                    ,ju.cd_create
                    ,ju.dt_create
					,ju.ts
					,ROW_NUMBER() OVER (ORDER BY ju.wt_kowake) AS RN
                FROM
                ma_juryo ju
                LEFT OUTER JOIN ma_hinmei hin
                ON ju.cd_hinmei = hin.cd_hinmei
                WHERE 
                    ju.kbn_jotai = @kbn_jotai
                    AND ju.kbn_hin = @kbn_hin
                    AND hin.cd_hinmei
						= CASE WHEN @cd_hinmei IS NOT NULL AND @cd_hinmei <> '' THEN @cd_hinmei
								ELSE hin.cd_hinmei END
				)
            SELECT
                cte_row.cnt
                ,kbn_jotai
                ,kbn_hin
                ,cd_hinmei
                ,nm_hinmei
                ,wt_kowake
                ,cd_create
                ,dt_create
                ,ts
            FROM (
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) 
            cte_row
            WHERE RN BETWEEN @start AND @end
            ORDER BY cd_hinmei

        END

        -- 品区分　仕掛
        IF @kbn_hin = @ShikakariHinKubun
        BEGIN

            WITH cte AS
            (
                SELECT
                    ju.kbn_jotai
                    ,ju.kbn_hin
                    ,ju.cd_hinmei
                    ,CASE @lang WHEN 'ja' THEN hai.nm_haigo_ja 
                                WHEN 'en' THEN hai.nm_haigo_en
                                WHEN 'zh' THEN hai.nm_haigo_zh
								WHEN 'vi' THEN hai.nm_haigo_vi END AS nm_hinmei
                    ,ju.wt_kowake
                    ,ju.cd_create
                    ,ju.dt_create
					,ju.ts
					,ROW_NUMBER() OVER (ORDER BY ju.wt_kowake) AS RN
                FROM
                ma_juryo ju
                LEFT OUTER JOIN ma_haigo_mei hai
                ON ju.cd_hinmei = hai.cd_haigo
                AND hai.no_han = @HanNoShokichi
                WHERE 
                    ju.kbn_jotai = @kbn_jotai
                    AND ju.kbn_hin = @kbn_hin
                    AND hai.cd_haigo
						= CASE WHEN @cd_hinmei IS NOT NULL AND @cd_hinmei <> '' THEN @cd_hinmei
								ELSE hai.cd_haigo END
            )
            SELECT
                cte_row.cnt
                ,kbn_jotai
                ,kbn_hin
                ,cd_hinmei
                ,nm_hinmei
                ,wt_kowake
                ,cd_create
                ,dt_create
                ,ts
            FROM (
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte 
			) 
            cte_row
            WHERE RN BETWEEN @start AND @end
            ORDER BY cd_hinmei

        END
    END



END
GO
