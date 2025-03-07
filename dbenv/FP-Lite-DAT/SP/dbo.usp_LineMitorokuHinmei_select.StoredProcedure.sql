IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LineMitorokuHinmei_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LineMitorokuHinmei_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.10.23>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineMitorokuHinmei_select]
	@flg_mishiyo smallint
	,@kbn_master smallint
	,@kbn_seihin smallint
	,@kbn_jikagen smallint
	,@skip decimal(10)
	,@top decimal(10)
	,@count int output
AS
BEGIN

	DECLARE 
		@errno int
		,@start decimal(10)
		,@end decimal(10)

	SET @start = @skip
	SET @end = @skip + @top;
	
	WITH cte AS
	(
		SELECT
			hinmei.cd_hinmei AS cd_hinmei
			, hinmei.nm_hinmei_ja AS nm_hinmei_ja
			, hinmei.nm_hinmei_en AS nm_hinmei_en
			, hinmei.nm_hinmei_zh AS nm_hinmei_zh
			, hinmei.nm_hinmei_vi AS nm_hinmei_vi
			, ROW_NUMBER() OVER (ORDER BY hinmei.cd_hinmei) AS RN
		FROM 
			(
				SELECT
					cd_hinmei
					,nm_hinmei_ja
					,nm_hinmei_en
					,nm_hinmei_zh
					,nm_hinmei_vi
				FROM dbo.ma_hinmei
				WHERE flg_mishiyo = @flg_mishiyo
				AND (kbn_hin = @kbn_seihin
				OR kbn_hin = @kbn_jikagen)
			) hinmei
		LEFT JOIN 
			(
				SELECT 
					cd_haigo
					, kbn_master
				FROM dbo.ma_seizo_line
				WHERE kbn_master = @kbn_master
				AND flg_mishiyo = @flg_mishiyo
			 ) seizoLine
		ON seizoLine.cd_haigo = hinmei.cd_hinmei
		WHERE 
			seizoLine.cd_haigo IS NULL
	)
	SELECT
		cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
	FROM cte		
	WHERE 
		RN BETWEEN @start AND @end
		
	SELECT
			hinmei.cd_hinmei AS cd_hinmei
			, hinmei.nm_hinmei_ja AS nm_hinmei_ja
			, hinmei.nm_hinmei_en AS nm_hinmei_en
			, hinmei.nm_hinmei_zh AS nm_hinmei_zh
			, hinmei.nm_hinmei_vi AS nm_hinmei_vi
			, ROW_NUMBER() OVER (ORDER BY hinmei.cd_hinmei) AS RN
		FROM 
			(
				SELECT
					cd_hinmei
					,nm_hinmei_ja
					,nm_hinmei_en
					,nm_hinmei_zh
					,nm_hinmei_vi
				FROM dbo.ma_hinmei
				WHERE flg_mishiyo = @flg_mishiyo
				AND (kbn_hin = @kbn_seihin
				OR kbn_hin = @kbn_jikagen)
			) hinmei
		LEFT JOIN
			(
				SELECT 
					cd_haigo
					, kbn_master
				FROM dbo.ma_seizo_line
				WHERE kbn_master = @kbn_master
				AND flg_mishiyo = @flg_mishiyo
			 ) seizoLine
		ON seizoLine.cd_haigo = hinmei.cd_hinmei
		WHERE 
			seizoLine.cd_haigo IS NULL

	SET @count = @@ROWCOUNT

END
GO
