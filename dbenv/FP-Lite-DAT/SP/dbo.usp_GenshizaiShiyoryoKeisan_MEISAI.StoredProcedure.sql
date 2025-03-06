IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShiyoryoKeisan_MEISAI') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_MEISAI]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		brc.nam
-- Create date: 2017.11.17
-- Last Update: 2017.11.17 brc.nam
-- Description:	�ɏo�˗���� �E���EXCEL�F���׎擾
--    �f�[�^���o����
-- ===============================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_MEISAI]
	  @con_hizuke			DATETIME		-- ���������F���t
	, @con_shokuba			VARCHAR(10)		-- ���������F�E��
	, @flg_yojitsu			SMALLINT		-- ���������F�\���t���O�F�\��c0�A���сc1

AS
BEGIN

	SET NOCOUNT ON

-- �g�p�\���g�����F�i�d�|�i�v��R�t���j
SELECT 
	  SHIYO_SUM.cd_hinmei						-- �i���R�[�h
	, SHIYO_SUM.dt_shiyo						-- �g�p�\���
	, SHIYO_SUM.su_shiyo_sum AS SUM_su_shiyo	-- �g�p�\���
	, SHIYO_SUM.cd_shikakari_hin AS code		-- �d�|�i�R�[�h
	, haigo.nm_haigo_en AS nm_hinmei_en			-- �z����
	, haigo.nm_haigo_ja AS nm_hinmei_ja
	, haigo.nm_haigo_zh AS nm_hinmei_zh
	, haigo.nm_haigo_vi AS nm_hinmei_vi
	, shokuba.nm_shokuba						-- �E�ꖼ
FROM 
	(
		-- �g�p�\���g����:�T�u�N�G��
		SELECT 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, SUM(su_shiyo) AS su_shiyo_sum
			, keikaku.cd_shokuba
			, keikaku.cd_shikakari_hin
			, keikaku.no_han
		FROM (
			SELECT *
			FROM tr_shiyo_yojitsu
			WHERE 
			  flg_yojitsu = @flg_yojitsu
			AND dt_shiyo = @con_hizuke
		    AND su_shiyo <> 0
			) tsy

		-- �d�|�i�v��
		INNER JOIN (
				SELECT
					  keikaku.cd_shikakari_hin
					, keikaku.cd_shokuba
					, no_lot_shikakari
					, MAX(haigo.no_han) AS no_han
				FROM su_keikaku_shikakari keikaku
				INNER JOIN ma_haigo_mei haigo
					ON keikaku.cd_shikakari_hin = haigo.cd_haigo
					AND haigo.flg_mishiyo = 0
					AND haigo.dt_from <= keikaku.dt_seizo
				WHERE (LEN(@con_shokuba) = 0 OR keikaku.cd_shokuba = @con_shokuba)
				GROUP BY
					  keikaku.cd_shokuba
					, keikaku.cd_shikakari_hin
					, keikaku.no_lot_shikakari	
		    ) keikaku
			ON tsy.no_lot_shikakari = keikaku.no_lot_shikakari
		GROUP BY 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku.cd_shokuba
			, keikaku.cd_shikakari_hin
			, keikaku.no_han
	) SHIYO_SUM

	-- �z���}�X�^
	LEFT OUTER JOIN ma_haigo_mei haigo
		ON SHIYO_SUM.cd_shikakari_hin = haigo.cd_haigo
		AND SHIYO_SUM.no_han = haigo.no_han

	-- �E��}�X�^
	LEFT OUTER JOIN ma_shokuba shokuba
		ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
		AND shokuba.flg_mishiyo = 0

UNION

-- �g�p�\���g�����F�i���i�v��R�t���j
SELECT 
	  SHIYO_SUM.cd_hinmei AS cd_hinmei			-- �i���R�[�h
	, SHIYO_SUM.dt_shiyo AS dt_shiyo			-- �g�p�\���
	, SHIYO_SUM.su_shiyo_sum AS SUM_su_shiyo	-- �g�p�\���
	, SHIYO_SUM.code AS code					-- �i���R�[�h�i���i�j
	, hinmei.nm_hinmei_en AS nm_hinmei_en		-- �i��
	, hinmei.nm_hinmei_ja AS nm_hinmei_ja
	, hinmei.nm_hinmei_zh AS nm_hinmei_zh
	, hinmei.nm_hinmei_vi AS nm_hinmei_vi
	, shokuba.nm_shokuba						-- �E�ꖼ
FROM
	(
		-- �g�p�\���g����:�T�u�N�G��
		SELECT 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, SUM(su_shiyo) AS su_shiyo_sum
			, keikaku.cd_shokuba
			, keikaku.cd_hinmei AS code
		FROM (
			SELECT *
			FROM tr_shiyo_yojitsu
			WHERE
				flg_yojitsu = @flg_yojitsu
				AND dt_shiyo = @con_hizuke
				AND su_shiyo <> 0
			) tsy

		-- ���i�v��
		INNER JOIN tr_keikaku_seihin keikaku
			ON tsy.no_lot_seihin = keikaku.no_lot_seihin
			AND (LEN(@con_shokuba) = 0 OR keikaku.cd_shokuba = @con_shokuba)
		GROUP BY 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku.cd_shokuba
			, keikaku.cd_hinmei	
	) SHIYO_SUM

	-- �i���}�X�^
	LEFT OUTER JOIN ma_hinmei hinmei
	ON SHIYO_SUM.code = hinmei.cd_hinmei
		AND hinmei.flg_mishiyo = 0

	-- �E��}�X�^
	LEFT OUTER JOIN ma_shokuba shokuba
	ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
		AND shokuba.flg_mishiyo = 0

ORDER BY 
	  code
	, cd_hinmei

END