IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_FutaiKetteiMaster_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_FutaiKetteiMaster_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_FutaiKetteiMaster_select]
	@kbn_jotai smallint
	,@cd_hinmei varchar(14)
	,@HanNoShokichi decimal(4)
	,@KotaiJotaiKubun smallint
	,@EkitaiJotaiKubun smallint
	,@SonotaJotaiKubun smallint
	,@Shiyo smallint
	,@GenryoHinKubun smallint
	,@skip decimal(10)
	,@top decimal(10)
	,@kbn_hin smallint
	,@ShikakariHinKbn smallint
AS
BEGIN

	DECLARE @start decimal(10)
	DECLARE	@end decimal(10)

	SET @start = @skip
	SET @end = @skip + @top


	-- 状態区分　個体、液体
	IF (@kbn_jotai = @KotaiJotaiKubun) OR (@kbn_jotai = @EkitaiJotaiKubun)
	BEGIN

		WITH cte AS
		(
			SELECT
				fu.kbn_jotai
				, fu.cd_hinmei as cd_hinmei
				, fu.cd_futai
				, fu.wt_kowake
				, fu.cd_tani
				, fu.flg_mishiyo
				, fu.dt_create
				, fu.cd_create
				, fu.dt_update
				, fu.cd_update
				, fu.ts
				, fu.kbn_hin as kbn_hin
				, tani.nm_tani
				, f.nm_futai
				, ROW_NUMBER() OVER (ORDER BY fu.wt_kowake) AS RN
			FROM
			ma_futai_kettei fu
			LEFT OUTER JOIN ma_futai f
			ON fu.cd_futai = f.cd_futai
			LEFT OUTER JOIN ma_tani tani
			ON fu.cd_tani = tani.cd_tani
			WHERE
			tani.flg_mishiyo = @Shiyo
			AND f.flg_mishiyo = @Shiyo
			AND fu.kbn_jotai = @kbn_jotai
		)
		SELECT
            cnt
			, kbn_jotai
			, cd_hinmei
			, cd_futai
			, wt_kowake
			, cd_tani
			, flg_mishiyo
			, dt_create
			, cd_create
			, dt_update
			, cd_update
			, ts
			, kbn_hin
			, nm_tani
			, nm_futai
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

	-- 状態区分　その他 品区分　原料or自家原料
	IF @kbn_jotai = @SonotaJotaiKubun AND @kbn_hin <> @ShikakariHinKbn 
	BEGIN

		WITH cte AS
		(
			SELECT
				fu.kbn_jotai
				, fu.cd_hinmei as cd_hinmei
				, fu.cd_futai
				, fu.wt_kowake
				, fu.cd_tani
				, fu.flg_mishiyo
				, fu.dt_create
				, fu.cd_create
				, fu.dt_update
				, fu.cd_update
				, fu.ts
				, fu.kbn_hin
				, tani.nm_tani
				, f.nm_futai
				, ROW_NUMBER() OVER (ORDER BY fu.wt_kowake) AS RN
			FROM ma_futai_kettei fu
			LEFT OUTER JOIN ma_tani tani
			ON fu.cd_tani = tani.cd_tani
			LEFT OUTER JOIN ma_futai f
			ON fu.cd_futai = f.cd_futai
			LEFT OUTER JOIN ma_hinmei hin
			ON fu.cd_hinmei = hin.cd_hinmei
			AND hin.kbn_hin = @kbn_hin
			WHERE 
			tani.flg_mishiyo = @Shiyo
			AND f.flg_mishiyo = @Shiyo
			AND hin.flg_mishiyo = @Shiyo
			AND hin.cd_hinmei = @cd_hinmei
			AND fu.kbn_hin = @kbn_hin
			--AND hin.kbn_hin = @GenryoHinKubun
			)
		SELECT
            cnt
			, kbn_jotai
			, cd_hinmei as cd_hinmei
			, cd_futai
			, wt_kowake
			, cd_tani
			, flg_mishiyo
			, dt_create
			, cd_create
			, dt_update
			, cd_update
			, ts
			, kbn_hin
			, nm_tani
			, nm_futai
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
	-- 状態区分　その他 品区分　仕掛品
	IF @kbn_jotai = @SonotaJotaiKubun AND @kbn_hin = @ShikakariHinKbn
	BEGIN	
		WITH cte AS
		(
			SELECT
				fu.kbn_jotai
				, fu.cd_hinmei as cd_hinmei
				, fu.cd_futai
				, fu.wt_kowake
				, fu.cd_tani
				, fu.flg_mishiyo
				, fu.dt_create
				, fu.cd_create
				, fu.dt_update
				, fu.cd_update
				, fu.ts
				, fu.kbn_hin
				, tani.nm_tani
				, f.nm_futai
				, ROW_NUMBER() OVER (ORDER BY fu.wt_kowake) AS RN
			FROM ma_futai_kettei fu
			LEFT OUTER JOIN ma_tani tani
			ON fu.cd_tani = tani.cd_tani
			LEFT OUTER JOIN ma_futai f
			ON fu.cd_futai = f.cd_futai
			LEFT OUTER JOIN ma_haigo_mei hai
			ON fu.cd_hinmei = hai.cd_haigo
			WHERE 
			tani.flg_mishiyo = @Shiyo
			AND f.flg_mishiyo = @Shiyo
			AND hai.flg_mishiyo = @Shiyo
			AND hai.cd_haigo = @cd_hinmei
			AND hai.no_han = @HanNoShokichi
			AND fu.kbn_hin = @ShikakariHinKbn
		)
		SELECT
            cnt
			, kbn_jotai
			, cd_hinmei as cd_hinmei
			, cd_futai
			, wt_kowake
			, cd_tani
			, flg_mishiyo
			, dt_create
			, cd_create
			, dt_update
			, cd_update
			, ts
			, kbn_hin
			, nm_tani
			, nm_futai
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

END
GO
