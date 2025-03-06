IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HistoryChange_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HistoryChange_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,trung.nq>
-- Create date: <Create Date,,2021.06.15>
-- Last Update: <>
-- Description: <Description,,>
-- =============================================

CREATE PROCEDURE [dbo].[usp_HistoryChange_select]
     @kbn_data			decimal(2)
    ,@kbn_shori			decimal(2)
    ,@dt_hiduke_from	datetime
    ,@dt_hiduke_to		datetime
	,@cd_hinmei			varchar(14)
	,@dt_henko_from		datetime
    ,@dt_henko_to		datetime
	,@cd_nm_tanto		nvarchar(50)
    ,@skip				decimal(10)
    ,@top				decimal(10)
	,@isExcel			smallint
    ,@count				int output
AS
BEGIN
WITH cte AS
(
	SELECT 
		  HENKO.dt_hizuke
		, HENKO.cd_hinmei
		, FORMAT(HENKO.su_henko, '#,##0.######') AS su_henko
		, FORMAT(HENKO.su_henko_hasu, '#,##0.######') AS su_henko_hasu
		, HENKO.no_lot
		, HENKO.biko
		, HENKO.cd_update
		, HENKO.dt_update
		, HENKO.kbn_data
		, HENKO.kbn_shori

		, TANTO.nm_tanto

		, HINMEI.nm_hinmei_en
		, HINMEI.nm_hinmei_ja
		, HINMEI.nm_hinmei_zh
		, HINMEI.nm_hinmei_vi

		, ROW_NUMBER() OVER(ORDER BY  HENKO.kbn_data
									, HENKO.kbn_shori
									, HENKO.dt_hizuke
									, HENKO.cd_hinmei) AS RN

	FROM tr_henko_rireki HENKO

	LEFT JOIN ma_tanto TANTO
	ON TANTO.cd_tanto = HENKO.cd_update

	LEFT JOIN ma_hinmei HINMEI
	ON HINMEI.cd_hinmei = HENKO.cd_hinmei

	WHERE
	( 
		@kbn_data IS NULL
		OR HENKO.kbn_data = @kbn_data
	)
	AND
	(
		@kbn_shori IS NULL
		OR HENKO.kbn_shori = @kbn_shori
	)
	AND
	(
		@dt_hiduke_from IS NULL
		OR CAST(HENKO.dt_hizuke AS DATE) >= CAST(@dt_hiduke_from AS DATE)
	)
	AND
	(
		@dt_hiduke_to IS NULL
		OR CAST(HENKO.dt_hizuke AS DATE) <= CAST(@dt_hiduke_to AS DATE)
	)
	AND
	(
		@cd_hinmei IS NULL
		OR HENKO.cd_hinmei = @cd_hinmei
	)
	AND
	(
		@dt_henko_from IS NULL
		OR CAST(HENKO.dt_update AS DATE) >= CAST(@dt_henko_from AS DATE)
	)
	AND
	(
		@dt_henko_to IS NULL
		OR CAST(HENKO.dt_update AS DATE) <= CAST(@dt_henko_to AS DATE)
	)
	AND
	(
		@cd_nm_tanto IS NULL
		OR HENKO.cd_update = @cd_nm_tanto
		OR TANTO.nm_tanto LIKE N'%' + LTRIM(RTRIM(@cd_nm_tanto)) + '%'
	)	
)

	SELECT
		  cte_row.dt_hizuke
		, cte_row.cd_hinmei
		, cte_row.su_henko
		, cte_row.su_henko_hasu
		, cte_row.no_lot
		, cte_row.biko
		, cte_row.cd_update
		, cte_row.dt_update
		, cte_row.kbn_data
		, cte_row.kbn_shori
		, cte_row.nm_tanto
		, cte_row.nm_hinmei_en
		, cte_row.nm_hinmei_ja
		, cte_row.nm_hinmei_zh
		, cte_row.nm_hinmei_vi
		, cte_row.cnt
	FROM 
		(
			SELECT 
				MAX(RN) OVER() cnt
				,*				
			FROM
				cte 
		) cte_row
	WHERE
	( 
		(
			@isExcel != 1
			AND cte_row.RN <= @top
		)
		OR (
			@isExcel = 1
		)
	)

	ORDER BY 
		  cte_row.kbn_data
		, cte_row.dt_hizuke
		, cte_row.cd_hinmei
		, cte_row.kbn_shori

	SET @count = @@ROWCOUNT
END
GO