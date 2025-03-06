IF OBJECT_ID ('dbo.vw_ma_chui_kanki_genryo_02', 'V') IS NOT NULL
DROP VIEW [dbo].[vw_ma_chui_kanki_genryo_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW[dbo].[vw_ma_chui_kanki_genryo_02]
AS

SELECT	
	  kbnhin.nm_kbn_hin	
      ,chui.cd_hinmei
	  ,ISNULL(hin.nm_hinmei_ja,haigo.nm_haigo_ja) AS nm_hinmei_ja
	  ,ISNULL(hin.nm_hinmei_en,haigo.nm_haigo_en) AS nm_hinmei_en
	  ,ISNULL(hin.nm_hinmei_zh,haigo.nm_haigo_zh) AS nm_hinmei_zh
	  ,ISNULL(hin.nm_hinmei_vi,haigo.nm_haigo_vi) AS nm_hinmei_vi
	  ,chui.no_juni_yusen	      	
	  ,kbnchu.nm_kbn_chui_kanki	
	  ,chui.cd_chui_kanki  	
	  ,are.nm_chui_kanki	
      ,chui.flg_chui_kanki_hyoji		
      ,chui.flg_mishiyo		
  FROM dbo.ma_chui_kanki_genryo chui		
  LEFT OUTER JOIN ma_hinmei  hin		
  ON chui.cd_hinmei = hin.cd_hinmei
  LEFT OUTER JOIN
  (
	SELECT
		haigo_mei.cd_haigo
		,haigo_mei.no_han
		,nm_haigo_ja
		,nm_haigo_en
		,nm_haigo_zh
		,nm_haigo_vi
	FROM ma_haigo_mei haigo_mei
	INNER JOIN
		(
		SELECT 
		cd_haigo
		,MAX(no_han) as no_han
		FROM ma_haigo_mei
		GROUP BY cd_haigo
		) AS haigo_no
	ON haigo_mei.cd_haigo = haigo_no.cd_haigo
	AND haigo_mei.no_han = haigo_no.no_han
   ) AS haigo
  ON chui.cd_hinmei = haigo.cd_haigo
  LEFT OUTER JOIN ma_chui_kanki are		
  ON chui.cd_chui_kanki = are.cd_chui_kanki		
  LEFT OUTER JOIN ma_kbn_chui_kanki kbnchu		
  ON kbnchu.kbn_chui_kanki = chui.kbn_chui_kanki		
  LEFT OUTER JOIN ma_kbn_hin kbnhin		
  ON chui.kbn_hin = kbnhin.kbn_hin				
	

GO