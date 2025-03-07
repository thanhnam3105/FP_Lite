IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LineMitorokuHaigo_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LineMitorokuHaigo_select]
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
CREATE PROCEDURE [dbo].[usp_LineMitorokuHaigo_select]
	@flg_mishiyo smallint
	,@kbn_master smallint
	,@searchHan smallint
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
			haigoMei.cd_haigo AS cd_hinmei
			, haigoMei.nm_haigo_ja AS nm_hinmei_ja
			, haigoMei.nm_haigo_en AS nm_hinmei_en
			, haigoMei.nm_haigo_zh AS nm_hinmei_zh
			, haigoMei.nm_haigo_vi AS nm_hinmei_vi
			,ROW_NUMBER() OVER (ORDER BY haigoMei.cd_haigo) AS RN
		FROM
			(
				SELECT
					cd_haigo
					,nm_haigo_ja
					,nm_haigo_en
					,nm_haigo_zh
					,nm_haigo_vi
					,flg_mishiyo
				FROM dbo.ma_haigo_mei
				WHERE no_han = @searchHan
				AND flg_mishiyo = @flg_mishiyo
			) haigoMei
		LEFT JOIN
			(
				SELECT 
					cd_haigo
					, kbn_master
				FROM dbo.ma_seizo_line
				WHERE kbn_master = @kbn_master
				AND flg_mishiyo = @flg_mishiyo
			 ) seizoLine
		ON seizoLine.cd_haigo = haigoMei.cd_haigo
		WHERE seizoLine.cd_haigo IS NULL
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
			haigoMei.cd_haigo AS cd_hinmei
			, haigoMei.nm_haigo_ja AS nm_hinmei_ja
			, haigoMei.nm_haigo_en AS nm_hinmei_en
			, haigoMei.nm_haigo_zh AS nm_hinmei_zh
			, haigoMei.nm_haigo_vi AS nm_hinmei_vi
			,ROW_NUMBER() OVER (ORDER BY haigoMei.cd_haigo) AS RN
		FROM
			(
				SELECT
					cd_haigo
					,nm_haigo_ja
					,nm_haigo_en
					,nm_haigo_zh
					,nm_haigo_vi
					,flg_mishiyo
				FROM dbo.ma_haigo_mei
				WHERE no_han = @searchHan
				AND flg_mishiyo = @flg_mishiyo
			) haigoMei
		LEFT JOIN
			(
				SELECT 
					cd_haigo
					, kbn_master
				FROM dbo.ma_seizo_line
				WHERE kbn_master = @kbn_master
				AND flg_mishiyo = @flg_mishiyo
			 ) seizoLine
		ON seizoLine.cd_haigo = haigoMei.cd_haigo
		WHERE seizoLine.cd_haigo IS NULL

	SET @count = @@ROWCOUNT

END
GO
