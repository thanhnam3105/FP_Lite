IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinShikomiKeikakuUchiwake_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinShikomiKeikakuUchiwake_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      <Author,,kobayashi.y>
-- Create date: <Create Date,,2013.12.02>
-- Last Update: <2016.09.16 inoue.k>
-- Description: <Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakarihinShikomiKeikakuUchiwake_select]
    @no_lot_shikakari varchar(14)
    ,@dt_seizo datetime
    ,@false smallint
    ,@count int output
AS
BEGIN
SELECT 
--	shikakari_oya.cd_shikakari_hin
	ISNULL(shikakari_oya.cd_shikakari_hin,'') cd_shikakari_hin
	,shikakari.wt_shikomi_keikaku
	,mei.nm_haigo_en
	,mei.nm_haigo_ja
	,mei.nm_haigo_zh
	,mei.nm_haigo_vi
	,shikakari.no_lot_seihin
	,shikakari.no_lot_shikakari_oya
/*
FROM tr_keikaku_shikakari shikakari_oya
LEFT OUTER JOIN tr_keikaku_shikakari shikakari
ON shikakari_oya.no_lot_shikakari = shikakari.no_lot_shikakari_oya
AND shikakari_oya.no_lot_seihin = shikakari.no_lot_seihin
AND shikakari.no_lot_shikakari = @no_lot_shikakari
*/
FROM (SELECT * 
      FROM tr_keikaku_shikakari
	  WHERE no_lot_shikakari = @no_lot_shikakari
	  ) shikakari
LEFT OUTER JOIN tr_keikaku_shikakari shikakari_oya
ON shikakari_oya.data_key = shikakari.data_key_oya
LEFT OUTER JOIN 
(
	SELECT 
		haigo_mei.cd_haigo
		,haigo_mei.nm_haigo_en
		,haigo_mei.nm_haigo_ja
		,haigo_mei.nm_haigo_zh
		,haigo_mei.nm_haigo_vi
	FROM ma_haigo_mei haigo_mei
	INNER JOIN
	(
		SELECT
			cd_haigo
			,MAX(no_han) no_han
		FROM 
		(
			SELECT 
				cd_haigo
				,MAX(dt_from) AS dt_from
				,no_han
			FROM ma_haigo_mei 
			WHERE 
				dt_from <= @dt_seizo
				AND flg_mishiyo = @false
			GROUP BY 
				cd_haigo
				,no_han
		) yukohaigo
		GROUP BY
			cd_haigo
	) yuko
	ON haigo_mei.cd_haigo = yuko.cd_haigo
	AND haigo_mei.no_han = yuko.no_han
) AS mei
ON shikakari_oya.cd_shikakari_hin = mei.cd_haigo
/*
WHERE shikakari_oya.no_lot_shikakari
IN
(
	SELECT DISTINCT
		shikakari.no_lot_shikakari_oya
	FROM tr_keikaku_shikakari shikakari
	WHERE
		shikakari.no_lot_shikakari = @no_lot_shikakari
)
ORDER BY
	shikakari_oya.cd_shikakari_hin

END
GO
*/

ORDER BY
	shikakari_oya.cd_shikakari_hin
END
GO
