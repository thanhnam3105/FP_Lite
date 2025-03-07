IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_GetBikoniuke') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_GetBikoniuke]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Trinh.BD
-- Create date: 2018/10/30
-- Description:	get note with kbn_nyushukko(1,9,12)
-- =============================================
CREATE FUNCTION [dbo].[udf_GetBikoniuke]
(
	@no_seq				DECIMAL(8,0)
	, @cd_niuke_basho   VARCHAR(10)	
	, @no_niuke			VARCHAR(14)	
	, @dt_shukko		DATETIME	
	, @kbn_zaiko		SMALLINT

)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @biko_19			NVARCHAR(50)
		, @cd_niuke_basho_19	VARCHAR(10)
		, @biko_result			NVARCHAR(50);

	SELECT TOP 1
		@cd_niuke_basho_19 = cd_niuke_basho 
		, @biko_19 = biko
	FROM tr_niuke
	WHERE                       
		kbn_nyushukko IN(1,9)
		AND no_niuke = @no_niuke
		AND no_seq <= @no_seq
		AND cd_niuke_basho = @cd_niuke_basho


	SELECT
		@biko_result = CASE WHEN (niuke.cd_niuke_basho = @cd_niuke_basho AND niuke.kbn_nyushukko = 12 AND biko IS NULL ) 
							THEN @biko_19 
							ELSE niuke.biko 
						END
	FROM tr_niuke niuke

	INNER JOIN (
		SELECT
			MAX(no_seq) AS no_seq
			, no_niuke
			, kbn_zaiko
			, cd_niuke_basho
		FROM tr_niuke
		WHERE                       
			kbn_nyushukko IN(1,9)
			OR (kbn_nyushukko = 12
			AND dt_niuke <= @dt_shukko)

		GROUP BY 
			no_niuke
			, kbn_zaiko
			, cd_niuke_basho
	) max_niuke
	ON niuke.no_seq = max_niuke.no_seq
	AND niuke.no_niuke = max_niuke.no_niuke
	AND niuke.cd_niuke_basho = max_niuke.cd_niuke_basho
	AND niuke.kbn_zaiko = max_niuke.kbn_zaiko

	WHERE                       
		niuke.kbn_nyushukko IN(1,9,12)
		AND niuke.no_niuke = @no_niuke
		AND niuke.no_seq <= @no_seq
		AND niuke.cd_niuke_basho = @cd_niuke_basho
		AND niuke.kbn_zaiko = @kbn_zaiko

	-- Return the result of the function
	RETURN @biko_result;

END
