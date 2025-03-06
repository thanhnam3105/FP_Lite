IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShiyoryoKeisan_SYUKEI') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_SYUKEI]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		brc.nam
-- Create date: 2017.11.17
-- Last Update: 2017.11.17 brc.nam
-- Description:	�ɏo�˗���� �E���EXCEL�F�W�v�擾
--    �f�[�^���o����
-- ===============================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShiyoryoKeisan_SYUKEI]
	  @con_hizuke			DATETIME		-- ���������F���t
	, @con_bunrui			VARCHAR(10)		-- ���������F����
	, @con_hinKubun			SMALLINT		-- ���������F�i�敪
	, @con_shokuba			VARCHAR(10)		-- ���������F�E��
	, @flg_yojitsu			SMALLINT		-- ���������F�\���t���O�F�\��c0�A���сc1
	, @flg_shiyo			SMALLINT		-- �萔�F���g�p�t���O�F�g�p
	, @kbn_genryo			SMALLINT		-- �萔�F�i�敪�F����
	, @kbn_shizai			SMALLINT		-- �萔�F�i�敪�F����
	, @kbn_jikagen			SMALLINT		-- �萔�F�i�敪�F���ƌ���
	, @tani_li				VARCHAR(2)		-- �萔�F�P�ʁFL
	, @utc					INT				-- ���n��UTC���Ԃ̎���
AS
BEGIN

	SET NOCOUNT ON
	
	--�o�ɓ��ɋx�����ݒ肳��Ȃ��悤�c�Ɠ����擾
	DECLARE @dtShukko DATETIME
	SELECT
		@dtShukko = MAX(dt_hizuke)
	FROM ma_calendar
	WHERE
		flg_kyujitsu = 0
		AND dt_hizuke < @con_hizuke
	
	-- �萔�F0
	DECLARE @zero DECIMAL
		SET @zero = 0
	
	-- �g�p�\���g����(�d�|�i�v��R�t��)
	SELECT
		  hinmei.kbn_hin AS kbn_hin													-- �i�敪
		, hinmei.cd_bunrui AS cd_bunrui												-- ���ރR�[�h
		, bunrui.nm_bunrui AS nm_bunrui												-- ���ޖ�
		, hinmei.cd_hinmei AS cd_hinmei												-- �i���R�[�h
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja	-- �i��(�����ޖ�)
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_vi, '') AS nm_hinmei_vi
		, hinmei.cd_tani_shiyo AS cd_tani_shiyo										-- �P�ʃR�[�h
		, tani.nm_tani AS nm_tani													-- �P�ʖ�
		, ISNULL(hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji					-- �׎p�\��
		, SHIYO_SUM.dt_shiyo AS dt_hiduke											-- �g�p�\���
		, SHIYO_SUM.su_shiyo_sum AS su_shiyo_sum									-- �g�p�\���		
		, @zero AS wt_shiyo_zan														-- �O���c(0�Œ�)
		, @dtShukko AS dt_shukko													-- �o�ɓ�
		, ISNULL(hinmei.su_iri, 0) AS su_iri										-- ����
		, ISNULL(hinmei.wt_ko, 0) AS wt_ko											-- �d��
		, hinmei.ritsu_hiju AS ritsu_hiju											-- ����d
		, m_konyu.cd_tani_nonyu AS cd_tani_nonyu									-- �ɏo�P�ʃR�[�h
		, tani2.nm_tani AS nm_tani_kuradashi										-- �ɏo�P�ʖ�
		, shokuba.cd_shokuba AS cd_shokuba											-- �E��R�[�h
		, shokuba.nm_shokuba AS nm_shokuba											-- �E�ꖼ
	FROM
	(
		-- �g�p�\���g�����F�T�u�N�G��
		SELECT 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, SUM(su_shiyo) AS su_shiyo_sum
			, keikaku_sikakari.cd_shokuba
		FROM (
			SELECT *
			FROM tr_shiyo_yojitsu
			WHERE
				flg_yojitsu = @flg_yojitsu
				AND dt_shiyo = @con_hizuke
				AND su_shiyo <> 0
		) tsy

		-- �d�|�i�v��
		INNER JOIN su_keikaku_shikakari keikaku_sikakari
			ON tsy.no_lot_shikakari = keikaku_sikakari.no_lot_shikakari
			AND (LEN(@con_shokuba) = 0 OR keikaku_sikakari.cd_shokuba = @con_shokuba)
		GROUP BY 	
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku_sikakari.cd_shokuba
	) SHIYO_SUM
		
	-- �i���}�X�^
	INNER JOIN
		(
			SELECT
				  cd_hinmei
				, kbn_hin
				, nm_hinmei_ja
				, nm_hinmei_en
				, nm_hinmei_zh
				, nm_hinmei_vi
				, nm_hinmei_ryaku
				, nm_nisugata_hyoji
				, cd_tani_shiyo
				, cd_bunrui
				, ritsu_hiju
				, su_iri
				, wt_ko
			FROM ma_hinmei
			WHERE
				flg_mishiyo = @flg_shiyo
				AND (kbn_hin = @kbn_genryo OR kbn_hin = @kbn_shizai OR kbn_hin = @kbn_jikagen)
				AND (@con_hinKubun = 0 OR kbn_hin = @con_hinKubun)
				AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
		) hinmei
	ON SHIYO_SUM.cd_hinmei = hinmei.cd_hinmei
	
	-- �����ލw����}�X�^
	LEFT OUTER JOIN
		(
			SELECT 
				  ma_konyu.cd_hinmei
				, cd_tani_nonyu
			FROM ma_konyu
			INNER JOIN
				(
					SELECT cd_hinmei, MIN(no_juni_yusen) juni
					FROM ma_konyu
					WHERE
						flg_mishiyo = @flg_shiyo
					GROUP BY cd_hinmei
				)mk
			ON mk.cd_hinmei = ma_konyu.cd_hinmei
			AND mk.juni = ma_konyu.no_juni_yusen
		) m_konyu
	ON hinmei.cd_hinmei = m_konyu.cd_hinmei
	
	-- �P�ʃ}�X�^
	LEFT OUTER JOIN ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	AND tani.flg_mishiyo = @flg_shiyo

	-- �P�ʃ}�X�^(�[���P�ʗp)
	LEFT OUTER JOIN ma_tani tani2
	ON m_konyu.cd_tani_nonyu = tani2.cd_tani
	AND tani2.flg_mishiyo = @flg_shiyo

	-- �E��}�X�^
	LEFT OUTER JOIN ma_shokuba shokuba
	ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
	AND shokuba.flg_mishiyo = @flg_shiyo

	-- ���ރ}�X�^
	LEFT OUTER JOIN ma_bunrui bunrui
	ON hinmei.cd_bunrui = bunrui.cd_bunrui
	AND bunrui.kbn_hin = hinmei.kbn_hin
	AND bunrui.flg_mishiyo = @flg_shiyo

UNION

	-- �g�p�\���g����(���i�v��R�t��)
	SELECT
		  hinmei.kbn_hin AS kbn_hin													-- �i�敪
		, hinmei.cd_bunrui AS cd_bunrui												-- ���ރR�[�h
		, bunrui.nm_bunrui AS nm_bunrui												-- ���ޖ�
		, hinmei.cd_hinmei AS cd_hinmei												-- �i���R�[�h
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja	-- �i��(�����ޖ�)
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_en, '') AS nm_hinmei_en
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
		, COALESCE(hinmei.nm_hinmei_ryaku,hinmei.nm_hinmei_vi, '') AS nm_hinmei_vi
		, hinmei.cd_tani_shiyo AS cd_tani_shiyo										-- �P�ʃR�[�h
		, tani.nm_tani AS nm_tani													-- �P�ʖ�
		, ISNULL(hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji					-- �׎p�\��
		, SHIYO_SUM.dt_shiyo AS dt_hiduke											-- �g�p�\���
		, SHIYO_SUM.su_shiyo_sum AS su_shiyo_sum									-- �g�p�\���		
		, @zero AS wt_shiyo_zan														-- �O���c(0�Œ�)
		, @dtShukko AS dt_shukko													-- �o�ɓ�
		, ISNULL(hinmei.su_iri, 0) AS su_iri										-- ����
		, ISNULL(hinmei.wt_ko, 0) AS wt_ko											-- �d��
		, hinmei.ritsu_hiju AS ritsu_hiju											-- ����d
		, m_konyu.cd_tani_nonyu AS cd_tani_nonyu									-- �ɏo�P�ʃR�[�h
		, tani2.nm_tani AS nm_tani_kuradashi										-- �ɏo�P�ʖ�
		, shokuba.cd_shokuba AS cd_shokuba											-- �E��R�[�h
		, shokuba.nm_shokuba AS nm_shokuba											-- �E�ꖼ
	FROM 
		(
			-- �g�p�\���g�����F�T�u�N�G��
			SELECT 
				  tsy.cd_hinmei
				, tsy.dt_shiyo
				, SUM(tsy.su_shiyo) AS su_shiyo_sum
				, keikaku.cd_shokuba AS cd_shokuba
			FROM (
				SELECT *
				FROM tr_shiyo_yojitsu
				WHERE
					flg_yojitsu = @flg_yojitsu
					AND dt_shiyo = @con_hizuke
					AND su_shiyo <> 0
			) tsy
			
			-- ���i�v��
			INNER JOIN
				(
					SELECT 
						  no_lot_seihin
						, cd_shokuba
					FROM tr_keikaku_seihin
				) keikaku
				ON tsy.no_lot_seihin = keikaku.no_lot_seihin
				AND (LEN(@con_shokuba) = 0 OR keikaku.cd_shokuba = @con_shokuba)
			GROUP BY 
			  tsy.cd_hinmei
			, tsy.dt_shiyo
			, keikaku.cd_shokuba
		) SHIYO_SUM

	-- �i���}�X�^
	INNER JOIN
		(
			SELECT
				  cd_hinmei
				, kbn_hin
				, nm_hinmei_ja
				, nm_hinmei_en
				, nm_hinmei_zh
				, nm_hinmei_vi
				, nm_hinmei_ryaku
				, nm_nisugata_hyoji
				, cd_tani_shiyo
				, cd_bunrui
				, ritsu_hiju
				, su_iri
				, wt_ko
			FROM ma_hinmei
			WHERE
				flg_mishiyo = @flg_shiyo
				AND (kbn_hin = @kbn_genryo OR kbn_hin = @kbn_shizai OR kbn_hin = @kbn_jikagen)
				AND (@con_hinKubun = 0 OR kbn_hin = @con_hinKubun)
				AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
		) hinmei
	ON SHIYO_SUM.cd_hinmei = hinmei.cd_hinmei
	
	-- �����ލw����}�X�^
	LEFT OUTER JOIN
		(
			SELECT 
				  ma_konyu.cd_hinmei
				, cd_tani_nonyu
			FROM ma_konyu
			INNER JOIN
				(
					SELECT cd_hinmei, MIN(no_juni_yusen) juni
					FROM ma_konyu
					WHERE
						flg_mishiyo = @flg_shiyo
					GROUP BY cd_hinmei
				)mk
			ON mk.cd_hinmei = ma_konyu.cd_hinmei
			AND mk.juni = ma_konyu.no_juni_yusen
		) m_konyu
	ON hinmei.cd_hinmei = m_konyu.cd_hinmei

	-- �P�ʃ}�X�^
	LEFT OUTER JOIN ma_tani tani
	ON hinmei.cd_tani_shiyo = tani.cd_tani
	AND tani.flg_mishiyo = @flg_shiyo
	
	-- �P�ʃ}�X�^(�[���P�ʗp)
	LEFT OUTER JOIN ma_tani tani2
	ON m_konyu.cd_tani_nonyu = tani2.cd_tani
	AND tani2.flg_mishiyo = @flg_shiyo

	-- �E��}�X�^
	LEFT OUTER JOIN ma_shokuba shokuba
	ON SHIYO_SUM.cd_shokuba = shokuba.cd_shokuba
	AND shokuba.flg_mishiyo = @flg_shiyo

	-- ���ރ}�X�^
	LEFT OUTER JOIN ma_bunrui bunrui
	ON hinmei.cd_bunrui = bunrui.cd_bunrui
	AND bunrui.kbn_hin = hinmei.kbn_hin
	AND bunrui.flg_mishiyo = @flg_shiyo

ORDER BY 
	  hinmei.kbn_hin
	, hinmei.cd_bunrui
	, hinmei.cd_hinmei

END