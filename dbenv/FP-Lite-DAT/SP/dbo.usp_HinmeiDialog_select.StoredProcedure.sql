IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HinmeiDialog_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HinmeiDialog_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Last Update: <2016.12.13 motojima.m>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_HinmeiDialog_select]
	@kbn_hin				smallint
	--,@nm_hinmei			varchar(50)
	,@nm_hinmei				nvarchar(50)
	,@flg_mishiyo_fukumu	smallint
	,@lang					varchar(10)
	,@SagyoShijiHinKbn		smallint
	,@ShikakariHinKbn		smallint

AS
BEGIN

set @nm_hinmei =
(select case when @nm_hinmei IS NULL OR @nm_hinmei = '' then '' else @nm_hinmei end)


IF @kbn_hin <> @ShikakariHinKbn AND @kbn_hin <> @SagyoShijiHinKbn
BEGIN
	SELECT
		hin.cd_hinmei AS cd_hinmei
		,kbn.nm_kbn_hin AS nm_kbn_hin
		,CASE @lang WHEN 'ja' THEN hin.nm_hinmei_ja 
					WHEN 'en' THEN hin.nm_hinmei_en
					WHEN 'zh' THEN hin.nm_hinmei_zh
					WHEN 'vi' THEN hin.nm_hinmei_vi
		END AS nm_hinmei
		,hin.nm_nisugata_hyoji AS nm_naiyo
	FROM ma_hinmei hin
	LEFT OUTER JOIN ma_kbn_hin kbn
	ON hin.kbn_hin = kbn.kbn_hin
	WHERE
		CASE WHEN @nm_hinmei IS NULL OR @nm_hinmei = ''
			THEN '%' + @nm_hinmei + '%'
			ELSE
				(CASE @lang WHEN 'ja' THEN hin.nm_hinmei_ja 
							WHEN 'en' THEN hin.nm_hinmei_en
							WHEN 'zh' THEN hin.nm_hinmei_zh
							WHEN 'vi' THEN hin.nm_hinmei_vi
				END)
		END LIKE '%' + @nm_hinmei + '%'
		AND hin.kbn_hin = @kbn_hin
		AND (CASE WHEN @flg_mishiyo_fukumu IS NULL THEN hin.flg_mishiyo 
				ELSE 0 END) = 0
END



IF @kbn_hin = @ShikakariHinKbn
BEGIN
select @kbn_hin, @ShikakariHinKbn
	SELECT
		hai.cd_haigo AS cd_hinmei
		,kbn.nm_kbn_hin AS nm_kbn_hin
		,CASE @lang WHEN 'ja' THEN hai.nm_haigo_ja 
					WHEN 'en' THEN hai.nm_haigo_en
					WHEN 'zh' THEN hai.nm_haigo_zh
					WHEN 'vi' THEN hai.nm_haigo_vi
		END AS nm_hinmei
		,CAST(hai.wt_kihon AS VARCHAR) AS nm_naiyo
	FROM ma_haigo_mei hai
	LEFT OUTER JOIN ma_kbn_hin kbn
	ON kbn.kbn_hin = @ShikakariHinKbn
	WHERE
		CASE WHEN @nm_hinmei IS NULL OR @nm_hinmei = ''
			THEN '%' + @nm_hinmei + '%'
			ELSE
				(CASE @lang WHEN 'ja' THEN hai.nm_haigo_ja 
							WHEN 'en' THEN hai.nm_haigo_en
							WHEN 'zh' THEN hai.nm_haigo_zh
							WHEN 'vi' THEN hai.nm_haigo_vi
				END)
		END LIKE '%' + @nm_hinmei + '%'
		AND hai.no_han = 1
		AND (CASE WHEN @flg_mishiyo_fukumu IS NULL THEN hai.flg_mishiyo 
				ELSE 0 END) = 0
END

IF @kbn_hin = @SagyoShijiHinKbn
BEGIN
	SELECT
		sa.cd_sagyo AS cd_hinmei
		,kbn.nm_kbn_hin AS nm_kbn_hin
		,sa.nm_sagyo AS nm_hinmei
		,sa.cd_mark AS nm_naiyo
	FROM ma_sagyo sa
	LEFT OUTER JOIN ma_kbn_hin kbn
	ON kbn.kbn_hin = @SagyoShijiHinKbn
	WHERE
		CASE WHEN @nm_hinmei IS NULL OR @nm_hinmei = ''
			THEN '%' + @nm_hinmei + '%'
			ELSE sa.nm_sagyo
		END LIKE '%' + @nm_hinmei + '%'
		AND (CASE WHEN @flg_mishiyo_fukumu IS NULL THEN sa.flg_mishiyo 
				ELSE 0 END) = 0
END



END
GO
