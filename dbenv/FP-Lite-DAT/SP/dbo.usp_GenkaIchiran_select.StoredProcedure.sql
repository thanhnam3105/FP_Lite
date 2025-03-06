IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenkaIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenkaIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      tsujita.s
-- Create date: 2014.08.22
-- Last Update: 2016.05.20 motojima.m
-- Description: �����ꗗ��������
-- 2015.12.10 hirai.a �ꕔ�g�p�����ނ̂݌����P�������鎞�̕s��C��
-- ================================================
CREATE PROCEDURE [dbo].[usp_GenkaIchiran_select]
    @dt_from			datetime	-- ���������F�N��(�J�n)
    ,@dt_to				datetime	-- ���������F�N��(�I��)
    ,@cd_shokuba		varchar(10)	-- ���������F�E��
    ,@cd_line			varchar(10)	-- ���������F���C���R�[�h
    ,@cd_bunrui			varchar(10)	-- ���������F���ރR�[�h
    ,@cd_seihin			varchar(14)	-- ���������F���i�R�[�h
    ,@tanka_settei		smallint	-- ���������F�P���ݒ�F�I���c1�A�[���c2
    ,@master_tanka		smallint	-- ���������F�}�X�^�P���g�p�F�`�F�b�N����c1�A�Ȃ��c0
    ,@flg_yotei			smallint	-- �萔�F�\���t���O�F�\��
    ,@flg_jisseki		smallint	-- �萔�F�\���t���O�F����
    ,@flg_kakutei		smallint	-- �萔�F�m��t���O�F�m��
    ,@flg_shiyo			smallint	-- �萔�F���g�p�t���O�F�g�p
    ,@kbn_tanka_tana	smallint	-- �萔�F�P���敪�F�I���P��
    ,@kbn_tanka_nonyu	smallint	-- �萔�F�P���敪�F�[���P��
    ,@kbn_tanka_romu	smallint	-- �萔�F�P���敪�F�J����
    ,@kbn_tanka_keihi	smallint	-- �萔�F�P���敪�F�o��
    ,@kbn_tanka_cs		smallint	-- �萔�F�P���敪�FCS�P��
    ,@kbn_genryo		smallint	-- �萔�F�i�敪�F����
    ,@kbn_shizai		smallint	-- �萔�F�i�敪�F����
AS
BEGIN

	-- ====================
	--  �ꎞ�e�[�u���̍쐬
	-- ====================
	-- �����g�p�g�����ꎞ�e�[�u��
	create table #tmp_genka_shiyo (
		no_seq			varchar(14)
		,cd_hinmei		varchar(14)
		,dt_shiyo		datetime
		,no_lot_seihin	varchar(14)
		,su_shiyo		decimal(12, 6)
	)			

	-- ���b�gNo�ʍޗ���ꎞ�e�[�u��
	create table #tmp_zairyo (
		kbn_hin			smallint
		,no_lot_seihin	varchar(14)
		,kin_genshizai	decimal(16, 4)
	)			


	SET NOCOUNT ON

	-- ======================================
	--   �����g�p�g�����ꎞ�f�[�^�̍쐬
	-- ======================================
	INSERT INTO #tmp_genka_shiyo (
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
	)	
	SELECT
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
	FROM tr_shiyo_genka
	WHERE dt_shiyo BETWEEN @dt_from AND @dt_to
	
	UNION

	SELECT
		tr.no_seq
		,tr.cd_hinmei
		,tr.dt_shiyo
		,tr.no_lot_seihin
		,tr.su_shiyo
	FROM tr_shiyo_yojitsu tr
	INNER JOIN ma_hinmei ma
	ON ma.kbn_hin = @kbn_shizai
	AND tr.cd_hinmei = ma.cd_hinmei
	WHERE
		tr.dt_shiyo BETWEEN @dt_from AND @dt_to
	AND tr.flg_yojitsu = @flg_jisseki

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tmp_genka_shiyo failed.'
        RETURN
    END


	-- ======================================
	--   ���b�gNo�ʍޗ���ꎞ�f�[�^�̍쐬
	-- ======================================
	INSERT INTO #tmp_zairyo (
		kbn_hin
		,no_lot_seihin
		,kin_genshizai
	)
	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	--   �u�i�敪���v�����ދ��z�̎擾
	-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	SELECT
		hin_kingaku.kbn_hin
		,hin_kingaku.no_lot_seihin
		,SUM(hin_kingaku.kin_genshizai) as kin_genshizai
	FROM
		-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
		--   �u�i�����v�����ދ��z�̎擾
		-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
		(SELECT
			hin.kbn_hin
			,genka_shiyo.no_lot_seihin
			-- /-/-/-/-/-/-/-/-/-/-/-/-
			--   �����ދ��z�̎擾
			-- /-/-/-/-/-/-/-/-/-/-/-/-

			-- ��������/�P���ݒ肪�u�I���v���}�X�^�P���g�p�Ƀ`�F�b�N���聕�����P���g����_�I���̌����P����NULL
			-- �܂��́A��������/�P���ݒ肪�u�[���v���}�X�^�P���g�p�Ƀ`�F�b�N���聕�����P���g����_�[���̌����P����NULL
			,CASE WHEN (@tanka_settei = @kbn_tanka_tana AND @master_tanka = 1 AND SUM(tana.tan_genka) IS NULL)
					OR (@tanka_settei = @kbn_tanka_nonyu AND @master_tanka = 1 AND SUM(nonyu.tan_genka) IS NULL)
				THEN SUM(genka_shiyo.su_shiyo * COALESCE(hin.tan_ko, 0) / hin.wt_ko)
					
			-- ��������/�P���ݒ肪�u�I���v���}�X�^�P���g�p�Ƀ`�F�b�N���聕�����P���g����_�I���̌����P����NULL�ȊO
			-- �܂��́A��������/�P���ݒ肪�u�I���v���}�X�^�P���g�p�Ƀ`�F�b�N�Ȃ�
			 WHEN (@tanka_settei = @kbn_tanka_tana AND @master_tanka = 1 AND SUM(tana.tan_genka) IS NOT NULL)
					OR (@tanka_settei = @kbn_tanka_tana AND @master_tanka = 0)
				THEN SUM(genka_shiyo.su_shiyo * COALESCE(tana.tan_genka, 0))

			-- ��������/�P���ݒ肪�u�[���v���}�X�^�P���g�p�Ƀ`�F�b�N���聕�����P���g����_�[���̌����P����NULL�ȊO
			-- �܂��́A��������/�P���ݒ肪�u�[���v���}�X�^�P���g�p�Ƀ`�F�b�N�Ȃ�
			 WHEN (@tanka_settei = @kbn_tanka_nonyu AND @master_tanka = 1 AND SUM(nonyu.tan_genka) IS NOT NULL)
					OR (@tanka_settei = @kbn_tanka_nonyu AND @master_tanka = 0)
				THEN SUM(genka_shiyo.su_shiyo * COALESCE(nonyu.tan_genka, 0))
			 END AS kin_genshizai
			,genka_shiyo.cd_hinmei
		FROM
			#tmp_genka_shiyo genka_shiyo

		-- �i���}�X�^
		INNER JOIN ma_hinmei hin
		ON genka_shiyo.cd_hinmei = hin.cd_hinmei

		-- �����P���g����_�I��
		LEFT JOIN (
			SELECT cd_hinmei
				,SUM(tan_genka) AS tan_genka
			FROM tr_genka_tanka
			WHERE kbn_tanka = @kbn_tanka_tana
			AND dt_genka_keisan BETWEEN @dt_from AND @dt_to
			GROUP BY cd_hinmei
		) tana
		ON genka_shiyo.cd_hinmei = tana.cd_hinmei

		-- �����P���g����_�[��
		LEFT JOIN (
			SELECT cd_hinmei
				,SUM(tan_genka) AS tan_genka
			FROM tr_genka_tanka
			WHERE kbn_tanka = @kbn_tanka_nonyu
			AND dt_genka_keisan BETWEEN @dt_from AND @dt_to
			GROUP BY cd_hinmei
		) nonyu
		ON genka_shiyo.cd_hinmei = nonyu.cd_hinmei

		-- �g�p�\���g����
		--LEFT JOIN ma_hinmei hin
		--ON genka_shiyo.cd_hinmei = hin.cd_hinmei

		GROUP BY genka_shiyo.no_lot_seihin, hin.kbn_hin,genka_shiyo.cd_hinmei) hin_kingaku
	GROUP BY hin_kingaku.no_lot_seihin,hin_kingaku.kbn_hin

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tmp_zairyo failed.'
        RETURN
    END


	-- ======================================
	--   �����ꗗ�̌�������
	-- ======================================
	SELECT
		zairyo_seihin.cd_hinmei
		,zairyo_seihin.nm_hinmei_ja
		,zairyo_seihin.nm_hinmei_en
		,zairyo_seihin.nm_hinmei_zh
		,zairyo_seihin.nm_hinmei_vi
		,zairyo_seihin.nm_nisugata_hyoji
		,zairyo_seihin.su_seizo_jisseki
		,CEILING(COALESCE(genka_cs.tan_genka, 0)) AS tan_genka_cs
		,CEILING(COALESCE(genka_romu.tan_genka, 0)) AS tan_genka_romu
		,CEILING(COALESCE(genka_keihi.tan_genka, 0)) AS tan_genka_keihi
		--,zairyo_seihin.su_seizo_jisseki * genka_cs.tan_genka AS kingaku
		,CEILING(COALESCE(zairyo_seihin.kin_genryo, 0)) AS kin_genryo
		,CEILING(COALESCE(zairyo_seihin.kin_shizai, 0)) AS kin_shizai
		--,zairyo_seihin.kin_genryo * zairyo_seihin.kin_shizai AS kin_zairyo_total
		--,zairyo_seihin.su_seizo_jisseki * genka_romu.tan_genka AS kin_romu
		--,zairyo_seihin.su_seizo_jisseki * genka_keihi.tan_genka AS kin_keihi
		--,(zairyo_seihin.su_seizo_jisseki * genka_romu.tan_genka AS kin_romu)
		--	+ (zairyo_seihin.su_seizo_jisseki * genka_keihi.tan_genka AS kin_keihi) AS keihi_total
	FROM (
		SELECT
			--seihin.dt_seizo
			@dt_to AS dt_seizo
			,seihin.cd_hinmei
			,hin.nm_hinmei_ja
			,hin.nm_hinmei_en
			,hin.nm_hinmei_zh
			,hin.nm_hinmei_vi
			,hin.nm_nisugata_hyoji
			,SUM(seihin.su_seizo_jisseki) AS su_seizo_jisseki
			,SUM(COALESCE(zairyo_gen.kin_genshizai, 0)) AS kin_genryo
			,SUM(COALESCE(zairyo_shi.kin_genshizai, 0)) AS kin_shizai
		FROM (
			SELECT dt_seizo, cd_hinmei, no_lot_seihin, su_seizo_jisseki
			FROM tr_keikaku_seihin
			WHERE dt_seizo BETWEEN @dt_from AND @dt_to
			AND flg_jisseki = @flg_kakutei
			AND (LEN(@cd_shokuba) = 0 OR cd_shokuba = @cd_shokuba)
			AND (LEN(@cd_line) = 0 OR cd_line = @cd_line)
			AND (LEN(@cd_seihin) = 0 OR cd_hinmei = @cd_seihin)
		) seihin

		INNER JOIN (
			SELECT cd_hinmei, nm_hinmei_ja, nm_hinmei_en, nm_hinmei_zh, nm_hinmei_vi,
				kbn_hin, cd_bunrui, nm_nisugata_hyoji
			FROM ma_hinmei
			WHERE (LEN(@cd_bunrui) = 0 OR cd_bunrui = @cd_bunrui)
		) hin
		ON seihin.cd_hinmei = hin.cd_hinmei
		
		-- �ޗ��e�[�u��_����
		LEFT JOIN #tmp_zairyo zairyo_gen
		ON zairyo_gen.kbn_hin = @kbn_genryo
		AND seihin.no_lot_seihin = zairyo_gen.no_lot_seihin
			
		-- �ޗ��e�[�u��_����
		LEFT JOIN #tmp_zairyo zairyo_shi
		ON zairyo_shi.kbn_hin = @kbn_shizai
		AND seihin.no_lot_seihin = zairyo_shi.no_lot_seihin
		
		GROUP BY --seihin.dt_seizo,
			seihin.cd_hinmei, hin.nm_nisugata_hyoji,
			hin.nm_hinmei_ja, hin.nm_hinmei_en, hin.nm_hinmei_zh, hin.nm_hinmei_vi
	) zairyo_seihin

	-- �����P���g����_�J��
	LEFT JOIN tr_genka_tanka genka_romu
	ON genka_romu.kbn_tanka = @kbn_tanka_romu
	AND zairyo_seihin.dt_seizo = genka_romu.dt_genka_keisan
	AND zairyo_seihin.cd_hinmei = genka_romu.cd_hinmei

	-- �����P���g����_�o��
	LEFT JOIN tr_genka_tanka genka_keihi
	ON genka_keihi.kbn_tanka = @kbn_tanka_keihi
	AND zairyo_seihin.dt_seizo = genka_keihi.dt_genka_keisan
	AND zairyo_seihin.cd_hinmei = genka_keihi.cd_hinmei

	-- �����P���g����_CS
	LEFT JOIN tr_genka_tanka genka_cs
	ON genka_cs.kbn_tanka = @kbn_tanka_cs
	AND zairyo_seihin.dt_seizo = genka_cs.dt_genka_keisan
	AND zairyo_seihin.cd_hinmei = genka_cs.cd_hinmei
	
	ORDER BY zairyo_seihin.cd_hinmei


END
GO
