IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenkaTanka_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenkaTanka_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ================================================
-- Author:      <Author,,tsujita.s>
-- Create date: <Create Date,,2014.08.20>
-- Last Update: 2015.02.18 tsujita.s
-- Description: <Description,,�����P���쐬����>
--	<TODO>�����P���͈ꗥ�A�����_�S�ʈȉ���؂�̂�
-- ================================================
CREATE PROCEDURE [dbo].[usp_GenkaTanka_create]
    @dt_from			datetime	-- ���������F�N��(�J�n)
    ,@dt_to				datetime	-- ���������F�N��(�I��)
    ,@kbn_hin			varchar(2)	-- ���������F�i�敪
    ,@cd_bunrui			varchar(10)	-- ���������F���ރR�[�h
    ,@cd_hinmei			varchar(14)	-- ���������F�i���R�[�h
    ,@flg_yotei			smallint	-- �萔�F�\���t���O�F�\��
    ,@flg_jisseki		smallint	-- �萔�F�\���t���O�F����
    ,@kbn_kanzan_kg		varchar(2)	-- �萔�F���Z�敪�FKg
    ,@kbn_kanzan_li		varchar(2)	-- �萔�F���Z�敪�FL
    ,@flg_shiyo			smallint	-- �萔�F���g�p�t���O�F�g�p
    ,@kbn_tanka_tana	smallint	-- �萔�F�P���敪�F�I���P��
    ,@kbn_tanka_nonyu	smallint	-- �萔�F�P���敪�F�[���P��
    ,@kbn_tanka_romu	smallint	-- �萔�F�P���敪�F�J����
    ,@kbn_tanka_keihi	smallint	-- �萔�F�P���敪�F�o��
    ,@kbn_tanka_cs		smallint	-- �萔�F�P���敪�FCS�P��
    ,@kbn_seihin		smallint	-- �萔�F�i�敪�F���i
    ,@kbn_jikagen		smallint	-- �萔�F�i�敪�F���ƌ���
    ,@max_genka			decimal(12, 4)	-- �����P���̍ő�l(�����̎Z�p�I�[�o�[�΍�)
    ,@kbn_zaiko_ryohin	SMALLINT		-- �萔�F�݌ɋ敪�F�Ǖi
AS
BEGIN

	-- ====================
	--  �ꎞ�e�[�u���̍쐬
	-- ====================
	-- �i�}�X�ꎞ�e�[�u��
	create table #tmp_hinmei (
		cd_hinmei		varchar(14)
		,kbn_hin		smallint
		,cd_tani_nonyu	varchar(10)
		,su_iri			decimal(5, 0)
		,tan_ko			decimal(12, 4)
		,wt_ko			decimal(12, 6)
		,kin_romu		decimal(12, 4)
		,kin_keihi_cs	decimal(12, 4)
	)			


	SET NOCOUNT ON

	-- �Ώۂ̕i���}�X�^�f�[�^���ɒ��o���Ă���
	INSERT INTO #tmp_hinmei (
		cd_hinmei
		,kbn_hin
		,cd_tani_nonyu
		,su_iri
		,tan_ko
		,wt_ko
		,kin_romu
		,kin_keihi_cs
	)
	SELECT
		cd_hinmei
		,kbn_hin
		,cd_tani_nonyu
		,su_iri
		,tan_ko
		,wt_ko
		,kin_romu
		,kin_keihi_cs
	FROM ma_hinmei
	WHERE (LEN(@kbn_hin) = 0 OR kbn_hin = @kbn_hin)
	AND (LEN(@cd_bunrui) = 0 OR cd_bunrui = @cd_bunrui)
	AND (LEN(@cd_hinmei) = 0 OR cd_hinmei = @cd_hinmei)

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tmp_hinmei failed insert.'
        RETURN
    END

	-- ===============================
	--   �����f�[�^�폜����
	-- ===============================
	DELETE tr_genka_tanka
	WHERE dt_genka_keisan BETWEEN @dt_from AND @dt_to
	AND cd_hinmei IN (SELECT cd_hinmei
					  FROM #tmp_hinmei)

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tr_genka_tanka failed delete.'
        RETURN
    END


	-- ==============================
	--   �I���P���쐬
	-- ==============================
	INSERT INTO tr_genka_tanka (
		dt_genka_keisan
		,cd_hinmei
		,kbn_tanka
		,tan_genka
	)
	SELECT
		@dt_to AS dt_genka_keisan
		,MEISAI_TOTAL.cd_hinmei
		,@kbn_tanka_tana AS kbn_tanka
		-- ���d���ρFSUM(���v���z) / SUM(�݌ɐ�)
		--,SUM(MEISAI_TOTAL.kin_total) / SUM(MEISAI_TOTAL.su_zaiko) AS ave_kaju
		,ROUND(SUM(MEISAI_TOTAL.kin_total) / SUM(MEISAI_TOTAL.su_zaiko), 4, 1) AS ave_kaju
	FROM (
		-- ���ז��̍��v���z�����߂�
		SELECT
			tr.cd_hinmei, tr.su_zaiko
			-- �I���P���܂��͍݌ɐ���0�̏ꍇ�A���v���z��0��ݒ�
			-- ��L�ȊO�F(�݌ɐ� / �i���}�X�^.�d��)���I���P��
			,ROUND(CASE WHEN COALESCE(tr.tan_tana, 0) = 0 OR tr.su_zaiko = 0
				THEN 0
				ELSE (tr.su_zaiko / hin.wt_ko) * tr.tan_tana
			END, 0, 1) AS kin_total
		FROM (
			SELECT
				cd_hinmei
				,dt_hizuke
				,SUM(su_zaiko) AS su_zaiko
				,SUM(tan_tana) AS tan_tana
			FROM tr_zaiko
			WHERE dt_hizuke BETWEEN @dt_from AND @dt_to
			AND kbn_zaiko = @kbn_zaiko_ryohin
			GROUP BY cd_hinmei, dt_hizuke
		) tr
		INNER JOIN #tmp_hinmei hin
		ON tr.cd_hinmei = hin.cd_hinmei
	) MEISAI_TOTAL
	WHERE MEISAI_TOTAL.su_zaiko > 0
	GROUP BY MEISAI_TOTAL.cd_hinmei

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :tanaoroshi_tanka failed.'
        RETURN
    END


	-- ==============================
	--   �[���P���쐬
	-- ==============================
	INSERT INTO tr_genka_tanka (
		dt_genka_keisan
		,cd_hinmei
		,kbn_tanka
		,tan_genka
	)
	SELECT
		@dt_to AS dt_genka_keisan
		,MEISAI_TOTAL.cd_hinmei
		,@kbn_tanka_nonyu AS kbn_tanka
		-- ���d���ρFSUM(���v���z) / SUM(���v����)
		,ROUND(SUM(MEISAI_TOTAL.kin_total) / SUM(MEISAI_TOTAL.su_total), 4, 1) AS ave_kaju
	FROM (
		-- ���ז��̍��v���z�����߂�
		SELECT
			tr.cd_hinmei
			-- ���v���z
			-- �[���P���܂��͔[�����Ɣ[���[����0�̏ꍇ�A���v���z��0��ݒ�
			,ROUND(CASE WHEN COALESCE(tr.tan_nonyu, 0) = 0
				OR (tr.su_nonyu = 0 AND COALESCE(tr.su_nonyu_hasu, 0) = 0)
				THEN 0
				ELSE 
					-- �i���}�X�^.�[���P�ʂ�Kg�܂���L�̏ꍇ
					-- (�[�������[���P��)�{((�[���[�� / (�������d�ʂ�1000))���[���P��)
					CASE WHEN hin.cd_tani_nonyu = @kbn_kanzan_kg OR hin.cd_tani_nonyu = @kbn_kanzan_li
					THEN (tr.su_nonyu * tr.tan_nonyu) + ((COALESCE(tr.su_nonyu_hasu, 0) / (hin.su_iri * hin.wt_ko * 1000)) * tr.tan_nonyu)
					-- �i���}�X�^.�[���P�ʂ�Kg��L�ȊO�̏ꍇ
					-- (�[�������[���P��)�{((�[���[�� / ����)���[���P��)
					ELSE (tr.su_nonyu * tr.tan_nonyu) + ((COALESCE(tr.su_nonyu_hasu, 0) / hin.su_iri) * tr.tan_nonyu)
					END
			 END, 0, 1) AS kin_total
			-- ���v����
			-- �[���P���܂��͔[�����Ɣ[���[����0�̏ꍇ�A���v���z��0��ݒ�
			,CASE WHEN COALESCE(tr.tan_nonyu, 0) = 0
				OR (tr.su_nonyu = 0 AND COALESCE(tr.su_nonyu_hasu, 0) = 0)
				THEN 0
				ELSE
					-- �i���}�X�^.�[���P�ʂ�Kg�܂���L�̏ꍇ
					-- (�[�������d�ʂ�����)�{(�[���[�� / 1000)
					CASE WHEN hin.cd_tani_nonyu = @kbn_kanzan_kg OR hin.cd_tani_nonyu = @kbn_kanzan_li
					THEN (tr.su_nonyu * hin.wt_ko * hin.su_iri) + (COALESCE(tr.su_nonyu_hasu, 0) / 1000)
					-- �i���}�X�^.�[���P�ʂ�Kg��L�ȊO�̏ꍇ
					-- (�[�������d�ʂ�����)�{(�[���[�����d��)
					ELSE (tr.su_nonyu * hin.wt_ko * hin.su_iri) + (COALESCE(tr.su_nonyu_hasu, 0) * hin.wt_ko)
					END
			 END AS su_total
		FROM (
			SELECT cd_hinmei, dt_nonyu, su_nonyu, su_nonyu_hasu, tan_nonyu
			FROM tr_nonyu
			WHERE dt_nonyu BETWEEN @dt_from AND @dt_to
			AND flg_yojitsu = @flg_jisseki
		) tr
		--INNER JOIN ma_hinmei hin
		INNER JOIN #tmp_hinmei hin
		ON hin.kbn_hin <> @kbn_seihin	-- ���i�ȊO
		AND tr.cd_hinmei = hin.cd_hinmei
	) MEISAI_TOTAL
	WHERE MEISAI_TOTAL.su_total > 0
	GROUP BY MEISAI_TOTAL.cd_hinmei

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :nonyu_tanka failed.'
        RETURN
    END


	-- ==============================
	--   ���i�P���쐬
	-- ==============================
	INSERT INTO tr_genka_tanka (
		dt_genka_keisan
		,cd_hinmei
		,kbn_tanka
		,tan_genka
	)
	------- �J����F�i���}�X�^.�W���J����
	SELECT
		@dt_to AS dt_genka_keisan
		,cd_hinmei
		,@kbn_tanka_romu AS kbn_tanka
		,COALESCE(kin_romu, 0) AS tan_genka
	FROM #tmp_hinmei
	WHERE kbn_hin = @kbn_seihin
	OR kbn_hin = @kbn_jikagen	-- ���i�܂��͎��ƌ����̂�
		-- ���p�t�H�[�}���X���l������IN�ł͂Ȃ�OR���g�p

	UNION ALL

	------- �o��F�i���}�X�^.1C/S�o��
	SELECT
		@dt_to AS dt_genka_keisan
		,cd_hinmei
		,@kbn_tanka_keihi AS kbn_tanka
		,COALESCE(kin_keihi_cs, 0) AS tan_genka
	FROM #tmp_hinmei
	WHERE kbn_hin = @kbn_seihin
	OR kbn_hin = @kbn_jikagen

	UNION ALL

	------- CS�P���F�i���}�X�^.�P�����i���}�X�^.����
	SELECT
		@dt_to AS dt_genka_keisan
		,cd_hinmei
		,@kbn_tanka_cs AS kbn_tanka
		,COALESCE(tan_ko, 0) * su_iri AS tan_genka
	FROM #tmp_hinmei
	WHERE (kbn_hin = @kbn_seihin OR kbn_hin = @kbn_jikagen)
	AND COALESCE(tan_ko, 0) * su_iri <= @max_genka

    IF @@ERROR <> 0
    BEGIN
        PRINT 'error :seihin_tanka failed.'
        RETURN
    END


END
GO
