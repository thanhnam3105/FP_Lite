IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_bom_master_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2015.01.22>
-- Last Update: <2015.10.30 kaneko.m> �i���}�X�^.�e�X�g�i=1�̃f�[�^����荞�܂Ȃ��悤�ɍďC��
-- Last Update: <2019.03.26 BRC kanehira> ���g�p�̎��ނ�`�����Ȃ��悤�ɏC��
-- Last Update: <2019.09.13 nakamura.r> �z�����V�s�̗L���ł̎擾���@�ύX
-- Description:	<Description,,BOM�}�X�^���M> 
--   �`���Ώۃe�[�u���쐬����
-- ============================================================================
CREATE PROCEDURE [dbo].[usp_sap_bom_master_denso_taisho_create]
	@kbnCreate			smallint		-- SAP�`���敪�F�V�K
	,@kbnUpdate			smallint		-- SAP�`���敪�F�X�V
	,@kbnDelete			smallint		-- SAP�`���敪�F�폜
	,@su_kihon			decimal(4, 0)	-- ��{����
	,@flg_true			smallint		-- �萔�F�t���O�F1
	,@flg_false			smallint		-- �萔�F�t���O�F0
	,@kbn_hin_seihin	smallint		-- �萔�F�i�敪�F���i
	,@kbn_hin_genryo	smallint		-- �萔�F�i�敪�F����
	,@kbn_hin_shizai	smallint		-- �萔�F�i�敪�F����
	,@kbn_hin_shikakari	smallint		-- �萔�F�i�敪�F�d�|�i
	,@kbn_hin_jikagen	smallint		-- �萔�F�i�敪�F���ƌ���
	,@fixed_value		smallint		-- �Œ�l�F1
	,@init_tani			varchar(2)		-- �����l�F�P�ʃR�[�h�FKg
	,@init_budomari		decimal(5, 2)	-- �����l�F����
	,@utc				int				-- �����F-6�i�A�����J�j
AS
BEGIN

	-- �Ώۈꎞ���[�N�e�[�u��
	CREATE TABLE #tmp_taisho (
		cd_seihin		VARCHAR(14)
		,no_han			DECIMAL(4, 0)
		,dt_from		DATETIME
		,cd_hinmei		VARCHAR(14)
		,wt_haigo		DECIMAL(12, 6)
		,cd_tani		VARCHAR(2)
		,cd_haigo		VARCHAR(14)
		,no_kotei		DECIMAL(4, 0)
		--,no_tonyu		DECIMAL(4, 0)
		,no_tonyu		VARCHAR(30)
		,flg_mishiyo	SMALLINT
		,kbn_hin		SMALLINT
		,ritsu_budomari	DECIMAL(5, 2)
		,oya_wt_haigo	DECIMAL(12, 6)
		,oya_budomari	DECIMAL(5, 2)
		,oya_haigo		VARCHAR(14)
		,jikagen_code	VARCHAR(14)
	)

	-- �W�J�p�ꎞ���[�N�e�[�u��
	CREATE TABLE #tmp_tenkai (
		cd_seihin		VARCHAR(14)
		,no_han			DECIMAL(4, 0)
		,dt_from		DATETIME
		,cd_hinmei		VARCHAR(14)
		,wt_haigo		DECIMAL(12, 6)
		,cd_tani		VARCHAR(2)
		,cd_haigo		VARCHAR(14)
		,no_kotei		DECIMAL(4, 0)
		--,no_tonyu		DECIMAL(4, 0)
		,no_tonyu		VARCHAR(30)
		,flg_mishiyo	SMALLINT
		,kbn_hin		SMALLINT
		,ritsu_budomari	DECIMAL(5, 2)
		,oya_wt_haigo	DECIMAL(12, 6)
		,oya_budomari	DECIMAL(5, 2)
		,oya_haigo		VARCHAR(14)
		,jikagen_code	VARCHAR(14)
	)

	-- �W�J�p�̔{�����X�g
	CREATE TABLE #tmp_bairitsu (
		su_kaiso		SMALLINT
		,cd_seihin		VARCHAR(14)
		,cd_haigo		VARCHAR(14)
		,batch			DECIMAL(12, 6)
		,batch_hasu		DECIMAL(12, 6)
		,bairitsu		DECIMAL(12, 6)
		,bairitsu_hasu	DECIMAL(12, 6)
	)

	-- �L����
	CREATE TABLE #udf_haigo (
		cd_haigo	VARCHAR(14)
		,no_han		DECIMAL(4, 0)
		,dt_from	DATETIME
	)

	-- �ϐ����X�g
	DECLARE @msg					VARCHAR(500)		-- �������ʃ��b�Z�[�W�i�[�p
	DECLARE @cd_kojo				VARCHAR(13)			-- ���O�C�����F�H��R�[�h
	DECLARE @tenkai_kaiso			SMALLINT = 1		-- �W�J�p�̊K�w�F�����l1
	DECLARE @flg_error				SMALLINT = 0		-- �G���[�t���O
	-- �J�[�\���p�̕ϐ����X�g
	DECLARE @cur_cd_seihin			VARCHAR(14)
	DECLARE @cur_no_han				DECIMAL(4, 0)
	DECLARE @cur_dt_from			DATETIME
	DECLARE @cur_cd_hinmei			VARCHAR(14)
	DECLARE @cur_wt_haigo			DECIMAL(12, 6)
	DECLARE @cur_cd_tani			VARCHAR(2)
	DECLARE @cur_cd_haigo			VARCHAR(14)
	DECLARE @cur_no_kotei			DECIMAL(4, 0)
	--DECLARE @cur_no_tonyu			DECIMAL(4, 0)
	DECLARE @cur_no_tonyu			VARCHAR(30)
	DECLARE @cur_flg_mishiyo		SMALLINT
	DECLARE @cur_kbn_hin			SMALLINT
	DECLARE @cur_recipe_budomari	DECIMAL(5, 2)
	DECLARE @cur_oya_wt_haigo		DECIMAL(12, 6)		-- �e�d�|�i�̔z�����V�s�D�z���d��
	DECLARE @cur_oya_budomari		DECIMAL(5, 2)		-- �e�d�|�i�̔z�����V�s�D����
	DECLARE @cur_oya_haigo			VARCHAR(14)			-- �e�d�|�i�̔z���R�[�h
	DECLARE @cur_jikagen_code		VARCHAR(14)			-- ���ƌ����̏ꍇ�A���ƌ����R�[�h������
	DECLARE @cur_su_hinmoku			DECIMAL(30, 6)		-- 100�{�ɂ����Ƃ��̌����ӂ�p

	SET NOCOUNT ON

	-- �H��R�[�h�̎擾
	SET @cd_kojo = (SELECT TOP 1 cd_kojo FROM ma_kojo)
	-- BOM�}�X�^���M�Ώۃe�[�u�����N���A
	DELETE ma_sap_bom_denso_taisho
	
	-- �V�X�e�����t�̎擾
	DECLARE @systemDate DATETIME = DATEADD(hour, @utc, GETUTCDATE())
	PRINT ''
	PRINT @systemDate
	SET @systemDate = CONVERT(NVARCHAR, @systemDate, 111) + ' 10:00:00'

	-- �L���ł̎擾
	INSERT INTO #udf_haigo (
		cd_haigo
		,no_han
	)
	SELECT
		yuko.cd_haigo
		,MAX(hai.no_han) AS no_han
	FROM
	(
		SELECT
			cd_haigo
			,MAX(dt_from) AS dt_from
		FROM
			ma_haigo_mei
		WHERE dt_from <= @systemDate
		AND flg_mishiyo = @flg_false
		GROUP BY cd_haigo
	) yuko
	LEFT OUTER JOIN dbo.ma_haigo_mei hai
    ON yuko.cd_haigo = hai.cd_haigo
    AND yuko.dt_from = hai.dt_from
    GROUP BY yuko.cd_haigo, yuko.dt_from


-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
--    BOM�}�X�^���M�Ώۃe�[�u��(ma_sap_bom_denso_taisho)�̍쐬
-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	-- ==============================================
	--  �� ��
	-- ==============================================
	INSERT INTO ma_sap_bom_denso_taisho (
		cd_seihin
		,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
	)
	SELECT
		seihin.cd_hinmei AS 'cd_seihin'
		,shizai.no_han AS 'no_han'
		,@cd_kojo AS 'cd_kojo'
		,shizai.dt_from AS 'dt_from'
		,@su_kihon AS 'su_kihon'
		,shizai.cd_shizai AS 'cd_hinmei'
		
		-- 1000C/S�P�ʂɊ��Z�F1000 * �g�p�� / �i���}�X�^_����.���� * 100 �������_�掵�ʂŐ؂�グ
		,CEILING (
			ROUND(((@su_kihon * shizai.su_shiyo / hin_shizai.ritsu_budomari * 100) * 10000000), 0, 1) / 10
		 ) / 1000000 AS 'su_hinmoku'
		--,(@su_kihon * shizai_b.su_shiyo / hin_shizai.ritsu_budomari * 100) AS debug_val	--�f�o�b�O�p
		--,shizai_b.su_shiyo as su_shiyo	--�f�o�b�O�p
		--,hin_shizai.ritsu_budomari AS budomari	--�f�o�b�O�p

		--,seihin.kbn_kanzan AS 'cd_tani'
		,hin_shizai.cd_tani_shiyo AS 'cd_tani'
		,@fixed_value AS 'su_kaiso'
		,seihin.cd_hinmei AS 'cd_haigo'	-- ���ނɔz���R�[�h�͂Ȃ��̂ő���ɐ��i�R�[�h��ݒ�
		,@fixed_value AS 'no_kotei'
		,(seihin.cd_hinmei + shizai.cd_shizai) AS 'no_tonyu'
		,seihin.flg_mishiyo
	FROM (
		SELECT cd_hinmei
			,COALESCE(kbn_kanzan, @init_tani) AS kbn_kanzan
			,flg_mishiyo
			,kbn_hin
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) seihin

	-- �`�����ŗL���Ȏ��ގg�p�}�X�^���擾
	--LEFT JOIN udf_ShizaiShiyoYukoHan(seihin.cd_hinmei, @flg_false, @systemDate) shizai
	--ON shizai.cd_hinmei = seihin.cd_hinmei
	LEFT JOIN (
        SELECT
            h.cd_hinmei
            ,h.dt_from
            ,h.no_han
            ,h.flg_mishiyo
            ,b.cd_shizai
            ,b.su_shiyo
        FROM
        -- �L�����t���Ŕԍ��Ԃœ���̏ꍇ�A�ő�̔Ŕԍ����擾����
        (
            SELECT
                yuko.cd_hinmei
                ,yuko.dt_from
                ,h.flg_mishiyo
                ,MAX(h.no_han) AS no_han
            FROM
            -- �i�����̍ő�̗L�����t���擾����
            (
                SELECT
                    cd_hinmei
                    ,MAX(dt_from) AS dt_from
                FROM
                ma_shiyo_h
                WHERE
                    flg_mishiyo = @flg_false
                    AND dt_from <= @systemDate
                GROUP BY cd_hinmei
            ) yuko
            LEFT OUTER JOIN ma_shiyo_h h
            ON yuko.cd_hinmei = h.cd_hinmei
            AND yuko.dt_from = h.dt_from
            GROUP BY 
                yuko.cd_hinmei
                ,yuko.dt_from
                ,h.flg_mishiyo
        ) h
        LEFT OUTER JOIN ma_shiyo_b b
        ON h.cd_hinmei = b.cd_hinmei
        AND h.no_han = b.no_han
    ) shizai
    ON shizai.cd_hinmei = seihin.cd_hinmei

	-- �i���}�X�^_���ށF�g�p���̌v�Z�p
	INNER JOIN (
		SELECT cd_hinmei
			,COALESCE(ritsu_budomari, @init_budomari) AS ritsu_budomari
			,cd_tani_shiyo
			,flg_mishiyo
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_shizai
	) hin_shizai
	ON shizai.cd_shizai = hin_shizai.cd_hinmei

	WHERE
		-- �I�[�o�[�t���[�΍�
		(@su_kihon * shizai.su_shiyo / hin_shizai.ritsu_budomari * 100) <= 999999.999999
		AND seihin.flg_mishiyo = @flg_false
		AND hin_shizai.flg_mishiyo = @flg_false

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :ma_sap_bom_denso_taisho-shizai failed insert.'
		GOTO Error_Handling
	END

	--PRINT '���ޏI��'

	-- ==============================================
	--  �z �� (�d�|�i�E���ƌ���)
	-- ==============================================
	--  ���i�̏����A�z���f�[�^�𒊏o�B
	--  �L���łȂǂ͋C�ɂ��Ȃ��i���ׂĎ擾����j
	INSERT INTO #tmp_taisho (
		cd_seihin
		,no_han
		,dt_from
		,cd_hinmei
		,wt_haigo
		,cd_tani
		,cd_haigo
		,no_kotei
		,no_tonyu
		,flg_mishiyo
		,kbn_hin
		,ritsu_budomari
		,oya_wt_haigo
		,oya_budomari
		,oya_haigo
	)
	SELECT
		seihin.cd_hinmei AS 'cd_seihin'
		,haigo_mei.no_han AS 'no_han'
		,haigo_mei.dt_from AS 'dt_from'
		,recipe.cd_hinmei AS 'cd_hinmei'
		,recipe.wt_shikomi AS 'wt_haigo'
		--,seihin.kbn_kanzan AS 'kbn_kanzan'
		,COALESCE(genryo_hin.kbn_kanzan, @init_tani) AS 'kbn_kanzan'
		,haigo_mei.cd_haigo AS 'cd_haigo'
		,recipe.no_kotei AS 'no_kotei'
		,RIGHT('000' + CONVERT(VARCHAR, recipe.no_tonyu), 3) AS 'no_tonyu'
		,seihin.flg_mishiyo AS 'flg_mishiyo'
		,kbn_hin AS 'kbn_hin'
		,recipe.ritsu_budomari
		,@init_budomari AS 'oya_wt_haigo'
		,@init_budomari AS 'oya_budomari'
		,haigo_mei.cd_haigo AS 'oya_haigo'
	FROM (
		SELECT cd_hinmei
			,cd_haigo
			,flg_mishiyo
			,COALESCE(kbn_kanzan, @init_tani) AS kbn_kanzan
			,su_iri
			,wt_ko
			,ritsu_hiju
		FROM ma_hinmei
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) seihin
	-- �L���ł��擾
	INNER JOIN #udf_haigo udf
	ON udf.cd_haigo = seihin.cd_haigo
	INNER JOIN (
		SELECT cd_haigo
			,no_han
			,dt_from
			--,ritsu_budomari
		FROM ma_haigo_mei
	) haigo_mei
	ON haigo_mei.cd_haigo = udf.cd_haigo
	AND haigo_mei.no_han = udf.no_han
	INNER JOIN (
		SELECT cd_haigo
			,no_han
			,cd_hinmei
			,wt_shikomi
			,no_kotei
			,no_tonyu
			,kbn_hin
			,ritsu_budomari
		FROM ma_haigo_recipe
		WHERE kbn_hin = @kbn_hin_genryo
		OR kbn_hin = @kbn_hin_shikakari
		OR kbn_hin = @kbn_hin_jikagen
	) recipe
	ON haigo_mei.cd_haigo = recipe.cd_haigo
	AND haigo_mei.no_han = recipe.no_han
	-- �����̕i���}�X�^
	LEFT JOIN (
		SELECT cd_hinmei
			,kbn_kanzan
		FROM ma_hinmei
	) genryo_hin
	ON genryo_hin.cd_hinmei = recipe.cd_hinmei
	WHERE
		seihin.flg_mishiyo = @flg_false

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :#tmp_taisho failed insert.'
        GOTO Error_Handling
    END

	--PRINT '�W�J�X�^�[�g'

	-- ///////////////////////////////////////////
	--  �W�J�����F�d�|�i�͓W�J����i���ƌ����͌����Ƃ��Ĉ����j
	-- ///////////////////////////////////////////
	-- �W�J�͍ő�10�K�w�܂łƂ���B
	WHILE (@tenkai_kaiso < 10)
	BEGIN
		-- /=======================================================/
		--   �Ώۃf�[�^���J�[�\���ցF1000C/S�P�ʂւ̊��Z�����̂���
		-- /=======================================================/
		DECLARE cursor_taisho CURSOR FOR
			SELECT
				tmp.cd_seihin
				,tmp.no_han
				,tmp.dt_from
				,tmp.cd_hinmei
				,tmp.wt_haigo
				,tmp.cd_tani
				,tmp.cd_haigo
				,tmp.no_kotei
				,tmp.no_tonyu
				,tmp.flg_mishiyo
				,tmp.ritsu_budomari
				,tmp.oya_wt_haigo
				,tmp.oya_budomari
				,tmp.oya_haigo
				,tmp.jikagen_code
			FROM #tmp_taisho tmp
			WHERE tmp.kbn_hin = @kbn_hin_genryo
			OR tmp.kbn_hin = @kbn_hin_jikagen

--SELECT * FROM #tmp_taisho

		OPEN cursor_taisho
			IF (@@error <> 0)
			BEGIN
				SET @msg = 'CURSOR OPEN ERROR: cursor_taisho'
				GOTO Error_Handling
			END

		FETCH NEXT FROM cursor_taisho INTO
			@cur_cd_seihin
			,@cur_no_han
			,@cur_dt_from
			,@cur_cd_hinmei
			,@cur_wt_haigo
			,@cur_cd_tani
			,@cur_cd_haigo
			,@cur_no_kotei
			,@cur_no_tonyu
			,@cur_flg_mishiyo
			,@cur_recipe_budomari
			,@cur_oya_wt_haigo
			,@cur_oya_budomari
			,@cur_oya_haigo
			,@cur_jikagen_code

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--PRINT '�J�[�\���X�^�[�g'
			--PRINT @tenkai_kaiso
			DECLARE @su_seizo decimal(26, 6) = 0	-- �����\�萔
			DECLARE @batch decimal(12, 6) = 0		-- �o�b�`��
			DECLARE @batch_hasu decimal(12, 6) = 0	-- �o�b�`�[��
			DECLARE @bairitsu decimal(12, 6) = 0	-- �{��
			DECLARE @bairitsu_hasu decimal(12, 6) = 0	-- �{���[��
			--DECLARE @wt_haigo_keikaku_hasu decimal(12, 6) = 0	-- �v��z���d�ʒ[��
			DECLARE @hinmoku_suryo decimal(26, 6) = 0	-- �i�ڐ���
			DECLARE @flg_overflow smallint = 0	-- �I�[�o�[�t���[�t���O
			-- �z�����}�X�^
			DECLARE @budomari decimal(5, 2) -- ����
			DECLARE @wt_haigo_gokei decimal(12, 6) = 0	-- ���v�z���d��
			DECLARE @ritsu_kihon decimal(5, 2) = 0	-- ��{�{��
			SELECT TOP 1 @budomari = ritsu_budomari
				,@wt_haigo_gokei = wt_haigo_gokei
				,@ritsu_kihon = ritsu_kihon
			FROM ma_haigo_mei
			WHERE cd_haigo = @cur_cd_haigo
			AND no_han = @cur_no_han
			IF @budomari = 0
				SET @budomari = @init_budomari	-- ������0�̏ꍇ�͏����l100��ݒ�
			IF @cur_recipe_budomari = 0
				SET @cur_recipe_budomari = @init_budomari
			IF @cur_oya_budomari = 0
				SET @cur_oya_budomari = @init_budomari

			IF @wt_haigo_gokei > 0	-- 0���Z�΍�
			BEGIN
				-- ///// 1�K�w��
				IF @tenkai_kaiso = 1
				BEGIN
					-- �i���}�X�^(���i)
					DECLARE @su_iri decimal(5, 0) = 1	-- ����
					DECLARE @wt_ko decimal(12, 6) = 1	-- �d��
					DECLARE @ritsu_hiju decimal(6, 4) = 1	-- ��d
					DECLARE @kbn_kanzan_hin varchar(10) = @init_tani	-- ���Z�敪
					SELECT TOP 1 @su_iri = su_iri, @wt_ko = wt_ko,
						@ritsu_hiju = ritsu_hiju, @kbn_kanzan_hin = kbn_kanzan
					FROM ma_hinmei WHERE cd_hinmei = @cur_cd_seihin
					
					--PRINT '1�K�w��'
					--PRINT @su_iri
					--PRINT @wt_ko
					--PRINT @ritsu_hiju
					
					IF @ritsu_hiju > 0	-- 0���Z�΍�
					BEGIN
						-- �z�����}�X�^�̊��Z�敪
						DECLARE @kbn_kanzan_haigo varchar(10) = @init_tani	-- ���Z�敪
						SELECT TOP 1 @kbn_kanzan_haigo = kbn_kanzan
						FROM ma_haigo_mei
						WHERE cd_haigo = @cur_cd_haigo
						AND no_han = @cur_no_han
						
						-- ��d�̊��Z�͕i���}�X�^.���Z�敪���z�����}�X�^.���Z�敪�ƈႤ�Ƃ��̂݉����i���S�̂��߁j
						-- �����Z�敪���ꏏ�̂Ƃ��͔�d���P�ɂ��Ă�����OK
						IF @kbn_kanzan_hin = @kbn_kanzan_haigo
						BEGIN
							SET @ritsu_hiju = 1
						END
						
						SET @su_seizo = (@su_kihon * @su_iri * @wt_ko / @ritsu_hiju / @budomari * 100)

						IF @su_seizo <= 999999.999999
						BEGIN
							-- �����_�掵�ʂŐ؂�グ
							SET @su_seizo = CEILING (ROUND((@su_seizo * 10000000), 0, 1) / 10) / 1000000

							-- �o�b�`���Ɣ{���̐ݒ�
							SELECT TOP 1 @batch = batch
								,@batch_hasu = batch_hasu
								,@bairitsu = bairitsu
								,@bairitsu_hasu = bairitsu_hasu
							FROM udf_MakeBairitsuObject(@su_seizo, @wt_haigo_gokei, @ritsu_kihon)
						END
						ELSE BEGIN
							-- �Z�p�I�[�o�[�t���[�Ȃ̂ŁA�t���O��ON�ɂ���
							SET @flg_overflow = 1
						END
					END
				END
				-- ///// 2�K�w�ڈȍ~
				ELSE BEGIN
					-- �{�����X�g����O�K�w�̃o�b�`���Ɣ{�����擾
					SELECT TOP 1 @batch = batch
						,@batch_hasu = batch_hasu
						,@bairitsu = bairitsu
						,@bairitsu_hasu = bairitsu_hasu
					FROM #tmp_bairitsu
					WHERE
						su_kaiso = (@tenkai_kaiso - 1)
					AND cd_haigo = @cur_oya_haigo
					AND cd_seihin = @cur_cd_seihin
					
					--PRINT '2�K�w�ڈȍ~'
					--SET @msg = '�O�K�w�o�b�`:' + CONVERT(VARCHAR, @batch) + ', B�[��:' + CONVERT(VARCHAR, @batch_hasu)
					--	+ ', �O�K�w�{��:' + CONVERT(VARCHAR, @bairitsu) + ', �{���[��:' + CONVERT(VARCHAR, @bairitsu_hasu)
					--	+ ', �e�z���̔z���d��:' + CONVERT(VARCHAR, @cur_oya_wt_haigo)
					--	+ ', �e�z�����V�s����:' + CONVERT(VARCHAR, @cur_oya_budomari) + ', �e�z��cd:' + @cur_oya_haigo
					--PRINT @msg
					
					IF @cur_jikagen_code IS NOT NULL
					BEGIN
					-- ���ƌ����̏ꍇ�͐����\�萔(�K�v��)�̌v�Z���ς��
					-- ����ʂŐ��i�v��𗧈Ă����Ƃ��Ɠ��������ɂȂ�
						DECLARE @su_keikaku decimal(10, 0) = 1	-- ���i�v�搔
						-- �i���}�X�^(���ƌ���)
						DECLARE @su_iri_jika decimal(5, 0) = 1	-- ����
						DECLARE @wt_ko_jika decimal(12, 6) = 1	-- �d��
						DECLARE @ritsu_hiju_jika decimal(6, 4) = 1	-- ��d
						DECLARE @kbn_kanzan_jika varchar(10) = @init_tani	-- ���Z�敪
						SELECT TOP 1 @su_iri_jika = su_iri, @wt_ko_jika = wt_ko,
							@ritsu_hiju_jika = ritsu_hiju, @kbn_kanzan_jika = kbn_kanzan
						FROM ma_hinmei WHERE cd_hinmei = @cur_jikagen_code

						-- �z�����}�X�^�̊��Z�敪
						DECLARE @kbn_kanzan_jika_haigo varchar(10) = @init_tani	-- ���Z�敪
						SELECT TOP 1 @kbn_kanzan_jika_haigo = kbn_kanzan
						FROM ma_haigo_mei
						WHERE cd_haigo = @cur_cd_haigo
						AND no_han = @cur_no_han

						--PRINT '���ƌ����̏ꍇ'
						--SET @msg = '���ƌ�cd:' + @cur_jikagen_code + ', �z��cd:' + @cur_cd_haigo
						--	+ ', ����:' + CONVERT(VARCHAR, @su_iri_jika) + ', �d��:' + CONVERT(VARCHAR, @wt_ko_jika)
						--	+ ', ��d:' + CONVERT(VARCHAR, @ritsu_hiju_jika) + ', ����:' + @cur_cd_hinmei
						--	+ ', ���Z�敪_��:' + @kbn_kanzan_jika + ', ���Z�敪_�z:' + @kbn_kanzan_jika_haigo
						--PRINT @msg
						
						IF @kbn_kanzan_jika = @kbn_kanzan_jika_haigo
						BEGIN
							-- ���Z�敪���ꏏ�̂Ƃ��͔�d���P
							SET @ritsu_hiju_jika = 1
						END
						
						-- �܂��͐��i�v�搔(���ƌ����̎g�p��)�����߂�
						SET @su_seizo = (@cur_oya_wt_haigo * @batch * @bairitsu / @cur_oya_budomari * 100)
											+ (@cur_oya_wt_haigo * @batch_hasu * @bairitsu_hasu / @cur_oya_budomari * 100)
						SET @su_keikaku = ROUND(@su_seizo, 0, 1)	-- �������𐻕i�v�搔�Ƃ���

						--SET @msg = '���ƌ����̎g�p��:' + CONVERT(VARCHAR, @su_seizo) + ', C/S:' + CONVERT(VARCHAR, @su_keikaku)
						--PRINT @msg
						
						-- �����\�萔(�K�v��)�����߂�
						SET @su_seizo = (@su_keikaku * @su_iri_jika * @wt_ko_jika / @ritsu_hiju_jika / @budomari * 100)
						--PRINT @su_seizo
						--PRINT ' '
					END
					ELSE BEGIN
					-- �d�|�i�̏ꍇ�̐����\�萔(�K�v��)�̌v�Z
						SET @su_seizo = (@cur_oya_wt_haigo * @batch * @bairitsu / @cur_oya_budomari * 100
										 + @cur_oya_wt_haigo * @batch_hasu * @bairitsu_hasu / @cur_oya_budomari * 100
										) / @budomari * 100
					END

					IF @su_seizo <= 999999.999999
					BEGIN
						-- �o�b�`���Ɣ{���̐ݒ�
						SELECT TOP 1 @batch = batch
							,@batch_hasu = batch_hasu
							,@bairitsu = bairitsu
							,@bairitsu_hasu = bairitsu_hasu
						FROM udf_MakeBairitsuObject(@su_seizo, @wt_haigo_gokei, @ritsu_kihon)
					END
					ELSE BEGIN
						-- �Z�p�I�[�o�[�t���[�Ȃ̂ŁA�t���O��ON�ɂ���
						SET @flg_overflow = 1
					END
				END
				
				IF @flg_overflow = 0
				BEGIN
					-- �i�ڐ��ʂ̌v�Z
					-- �z�����V�s�}�X�^.�d���d��(��ʂ̔z���d��) * �o�b�`�� * �{�� / �z�����V�s�}�X�^.���� * 100
					--    + �z�����V�s�}�X�^.�d���d�� * �o�b�`���[�� * �{���[�� / �z�����V�s�}�X�^.���� * 100
					SET @hinmoku_suryo = (@cur_wt_haigo * @batch * @bairitsu / @cur_recipe_budomari * 100)
											+ (@cur_wt_haigo * @batch_hasu * @bairitsu_hasu / @cur_recipe_budomari * 100)
					--SET @hinmoku_suryo = ROUND(@hinmoku_suryo, 6, 1)

						--PRINT '�p�����[�^�[�`�F�b�N'
						--SET @msg = '���icd:' + @cur_cd_seihin + ', �z��cd:' + @cur_cd_haigo
						--	+ ', ��:' + CONVERT(VARCHAR, @cur_no_han) + ', �H��:' + CONVERT(VARCHAR, @cur_no_kotei)
						--	+ ', ����:' + CONVERT(VARCHAR, @cur_no_tonyu) + ', ����:' + @cur_cd_hinmei
						--	+ ', �K�v��:' + CONVERT(VARCHAR, @su_seizo) + ', �g�p��:' + CONVERT(VARCHAR, @hinmoku_suryo)
						--	+ ', cur_wt_haigo:' + CONVERT(VARCHAR, @cur_wt_haigo) + ', ���v�z���d��:' + CONVERT(VARCHAR, @wt_haigo_gokei)
						--	+ ', �o�b�`:' + CONVERT(VARCHAR, @batch) + ', �o�b�`�[��:' + CONVERT(VARCHAR, @batch_hasu)
						--	+ ', �{��:' + CONVERT(VARCHAR, @bairitsu) + ', �{���[��:' + CONVERT(VARCHAR, @bairitsu_hasu)
						--	+ ', �z�����}�X�^����:' + CONVERT(VARCHAR, @budomari) + ', ��{�{��:' + CONVERT(VARCHAR, @ritsu_kihon)
						--	+ ', ���V�s����:' + CONVERT(VARCHAR, @cur_recipe_budomari)
						--	+ ', �K�w:' + CONVERT(VARCHAR, @tenkai_kaiso) + ', overFlg:' + CONVERT(VARCHAR, @flg_overflow)
						--PRINT @msg
						--PRINT ' '

					IF @hinmoku_suryo <= 999999.999999	-- �I�[�o�[�t���[�΍�
					BEGIN
						-- /==================================/
						--   �Ώۃf�[�^��Ώۃe�[�u����INSERT
						-- /==================================/
						INSERT INTO ma_sap_bom_denso_taisho (
							cd_seihin
							,no_han
							,cd_kojo
							,dt_from
							,su_kihon
							,cd_hinmei
							,su_hinmoku
							,cd_tani
							,su_kaiso
							,cd_haigo
							,no_kotei
							,no_tonyu
							,flg_mishiyo
						)
						VALUES (
							@cur_cd_seihin
							,@cur_no_han
							,@cd_kojo
							,@cur_dt_from
							,@su_kihon
							,@cur_cd_hinmei
							,@hinmoku_suryo
							,@cur_cd_tani
							,@tenkai_kaiso
							,@cur_cd_haigo
							,@cur_no_kotei
							,@cur_no_tonyu
							,@cur_flg_mishiyo
						)

						IF @@ERROR <> 0
						BEGIN
							SET @msg = 'error :ma_sap_bom_denso_taisho-haigo failed insert.'
							GOTO Error_Handling
						END
					END
					ELSE BEGIN
						-- �Z�p�I�[�o�[�t���[�Ȃ̂ŁA�t���O��ON�ɂ���
						SET @flg_overflow = 1
					END
					
					IF @flg_overflow = 0
					BEGIN
						-- �{�����X�g�ɑ��݂��Ȃ���΁A�o�b�`�Ɣ{������ǉ�����
						IF (SELECT TOP 1 su_kaiso FROM #tmp_bairitsu
							WHERE su_kaiso = @tenkai_kaiso
							AND cd_haigo = @cur_cd_haigo
							AND cd_seihin = @cur_cd_seihin) IS NULL
						BEGIN
							--PRINT '�{�����X�g�ɒǉ�'
							--SET @msg = '�K�w:' + CONVERT(VARCHAR, @tenkai_kaiso)
							--	+ ', ���icd:' + @cur_cd_seihin + ', �z��cd:' + @cur_cd_haigo
							--	+ ', �o�b�`:' + CONVERT(VARCHAR, @batch) + ', �o�b�`�[��:' + CONVERT(VARCHAR, @batch_hasu)
							--	+ ', �{��:' + CONVERT(VARCHAR, @bairitsu) + ', �{���[��:' + CONVERT(VARCHAR, @bairitsu_hasu)
							--PRINT @msg

							INSERT #tmp_bairitsu (
								su_kaiso
								,cd_seihin
								,cd_haigo
								,batch
								,batch_hasu
								,bairitsu
								,bairitsu_hasu
							)
							VALUES (
								@tenkai_kaiso
								,@cur_cd_seihin
								,@cur_cd_haigo
								,@batch
								,@batch_hasu
								,@bairitsu
								,@bairitsu_hasu
							)
						END
					END
				END

				-- �Z�p�I�[�o�[�t���[���������Ƃ��͑Ώۃf�[�^�����O�ɕ\������
				IF @flg_overflow = 1
				BEGIN
					SET @flg_error = 1	-- �G���[�t���O�𗧂Ă�

					PRINT 'Arithmetic overflow or other arithmetic exception occurred.�F�Z�p�I�[�o�[�t���['
					SET @msg = '  Object data... cd_seihin:' + @cur_cd_seihin + ', cd_haigo:' + @cur_cd_haigo
						+ ', no_han:' + CONVERT(VARCHAR, @cur_no_han) + ', no_kotei:' + CONVERT(VARCHAR, @cur_no_kotei)
						+ ', no_tonyu:' + CONVERT(VARCHAR, @cur_no_tonyu) + ', cd_hinmei:' + @cur_cd_hinmei
						+ ', su_seizo:' + CONVERT(VARCHAR, @su_seizo) + ', su_hinmoku:' + CONVERT(VARCHAR, @hinmoku_suryo)
					PRINT @msg
					PRINT ' '
				END
			END

			FETCH NEXT FROM cursor_taisho INTO
				@cur_cd_seihin
				,@cur_no_han
				,@cur_dt_from
				,@cur_cd_hinmei
				,@cur_wt_haigo
				,@cur_cd_tani
				,@cur_cd_haigo
				,@cur_no_kotei
				,@cur_no_tonyu
				,@cur_flg_mishiyo
				,@cur_recipe_budomari
				,@cur_oya_wt_haigo
				,@cur_oya_budomari
				,@cur_oya_haigo
				,@cur_jikagen_code
		END

		CLOSE cursor_taisho
		DEALLOCATE cursor_taisho
		-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
		--   �Ώۃf�[�^�̃J�[�\�������܂�
		-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

		-- �W�J�p�ꎞ�e�[�u�����N���A
		DELETE #tmp_tenkai
		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_tenkai failed delete.'
			GOTO Error_Handling
		END

		-- �W�J�f�[�^�̗L���F�d�|�i�����݂��邩
		IF (SELECT TOP 1 cd_seihin
			FROM #tmp_taisho
			WHERE kbn_hin = @kbn_hin_shikakari
			--OR kbn_hin = @kbn_hin_jikagen
			) IS NULL
		BEGIN
			-- �擾���ʂ��Ȃ���ΓW�J�����I��
			--PRINT '�擾���ʂȂ�'
			BREAK
		END

		-- /==================================/
		--   �W�J�Ώۂ�W�J�p�ꎞ�e�[�u����
		-- /==================================/
		INSERT INTO #tmp_tenkai (
			cd_seihin
			,no_han
			,dt_from
			,cd_hinmei
			,wt_haigo
			,cd_tani
			,cd_haigo
			,no_kotei
			,no_tonyu
			,flg_mishiyo
			,kbn_hin
			,ritsu_budomari
			,oya_wt_haigo
			,oya_budomari
			,oya_haigo
			,jikagen_code
		)
			-- ////////// �d�|�i //////////
			SELECT tmp.cd_seihin
				,tenkai_haigo.no_han
				,tenkai_haigo.dt_from
				,tenkai_recipe.cd_hinmei
				,tenkai_recipe.wt_shikomi
				--,tmp.cd_tani
				,COALESCE(genryo_hin.kbn_kanzan, @init_tani) AS kbn_kanzan
				,tenkai_haigo.cd_haigo AS 'cd_haigo'
				,tenkai_recipe.no_kotei
				--,tenkai_recipe.no_tonyu
				,tmp.no_tonyu + RIGHT('000' + CONVERT(VARCHAR, tenkai_recipe.no_tonyu), 3) AS 'no_tonyu'
				,tmp.flg_mishiyo
				,tenkai_recipe.kbn_hin
				,tenkai_recipe.ritsu_budomari
				,tmp.wt_haigo AS 'oya_wt_haigo'
				,tmp.ritsu_budomari AS 'oya_budomari'
				,tmp.cd_haigo AS 'oya_haigo'
				,null AS 'jikagen_code'
			FROM (
				SELECT cd_seihin
					,no_han
					,cd_hinmei
					,cd_tani
					,flg_mishiyo
					,wt_haigo
					,ritsu_budomari
					,cd_haigo
					,no_tonyu
				FROM #tmp_taisho
				WHERE kbn_hin = @kbn_hin_shikakari
				GROUP BY cd_seihin, no_han, cd_hinmei, cd_tani, flg_mishiyo, wt_haigo,
					ritsu_budomari, cd_haigo, no_tonyu
			) tmp
			-- �L���ł��擾
			INNER JOIN #udf_haigo udf
			ON udf.cd_haigo = tmp.cd_hinmei
			INNER JOIN (
				SELECT cd_haigo
					,no_han
					,dt_from
				FROM ma_haigo_mei
			) tenkai_haigo
			ON tenkai_haigo.cd_haigo = udf.cd_haigo
			--AND tenkai_haigo.no_han = tmp.no_han
			AND tenkai_haigo.no_han = udf.no_han
			INNER JOIN (
				SELECT cd_haigo
					,no_han
					,cd_hinmei
					,wt_shikomi
					,no_kotei
					,no_tonyu
					,kbn_hin
					,ritsu_budomari
				FROM ma_haigo_recipe
				WHERE kbn_hin = @kbn_hin_genryo
				OR kbn_hin = @kbn_hin_shikakari
				OR kbn_hin = @kbn_hin_jikagen
			) tenkai_recipe
			ON tenkai_haigo.cd_haigo = tenkai_recipe.cd_haigo
			AND tenkai_haigo.no_han = tenkai_recipe.no_han
			-- �����̕i���}�X�^
			LEFT JOIN (
				SELECT cd_hinmei
					,kbn_kanzan
				FROM ma_hinmei
			) genryo_hin
			ON genryo_hin.cd_hinmei = tenkai_recipe.cd_hinmei

		-- ���ƌ����͓W�J���Ȃ�(2015.07.03 tsujita.s)
		--UNION ALL
		--	-- ////////// ���ƌ��� //////////
		--	SELECT tmp.cd_seihin
		--		,tenkai_haigo.no_han
		--		,tenkai_haigo.dt_from
		--		,tenkai_recipe.cd_hinmei
		--		,tenkai_recipe.wt_shikomi
		--		--,tmp.cd_tani
		--		,COALESCE(genryo_hin.kbn_kanzan, @init_tani) AS kbn_kanzan
		--		,tenkai_haigo.cd_haigo
		--		--,tmp.cd_hinmei AS 'cd_haigo'
		--		,tenkai_recipe.no_kotei
		--		--,tenkai_recipe.no_tonyu
		--		,tmp.no_tonyu + RIGHT('000' + CONVERT(VARCHAR, tenkai_recipe.no_tonyu), 3) AS 'no_tonyu'
		--		,tmp.flg_mishiyo
		--		,tenkai_recipe.kbn_hin
		--		,tenkai_recipe.ritsu_budomari
		--		,tmp.wt_haigo AS 'oya_wt_haigo'
		--		,tmp.ritsu_budomari AS 'oya_budomari'
		--		,tmp.cd_haigo AS 'oya_haigo'
		--		,tmp.cd_hinmei AS 'jikagen_code'
		--	FROM (
		--		SELECT cd_seihin
		--			,cd_hinmei
		--			,cd_tani
		--			,flg_mishiyo
		--			,wt_haigo
		--			,ritsu_budomari
		--			,cd_haigo
		--			,no_tonyu
		--		FROM #tmp_taisho
		--		WHERE kbn_hin = @kbn_hin_jikagen
		--		GROUP BY cd_seihin, cd_hinmei, cd_tani, flg_mishiyo, wt_haigo,
		--			ritsu_budomari, cd_haigo, no_tonyu
		--	) tmp
		--	INNER JOIN (
		--		-- ���ƌ����͕i���}�X�^����z���R�[�h���擾����
		--		SELECT cd_hinmei
		--			,cd_haigo
		--		FROM ma_hinmei
		--		WHERE kbn_hin = @kbn_hin_jikagen
		--	) hin
		--	ON tmp.cd_hinmei = hin.cd_hinmei

		--	-- �L���ł��擾
		--	INNER JOIN #udf_haigo udf
		--	ON udf.cd_haigo = hin.cd_haigo
		--	INNER JOIN (
		--		SELECT cd_haigo
		--			,no_han
		--			,dt_from
		--		FROM ma_haigo_mei
		--	) tenkai_haigo
		--	ON tenkai_haigo.cd_haigo = udf.cd_haigo
		--	AND tenkai_haigo.no_han = udf.no_han
		--	INNER JOIN (
		--		SELECT cd_haigo
		--			,no_han
		--			,cd_hinmei
		--			,wt_shikomi
		--			,no_kotei
		--			,no_tonyu
		--			,kbn_hin
		--			,ritsu_budomari
		--		FROM ma_haigo_recipe
		--		WHERE kbn_hin = @kbn_hin_genryo
		--		OR kbn_hin = @kbn_hin_shikakari
		--		OR kbn_hin = @kbn_hin_jikagen
		--	) tenkai_recipe
		--	ON tenkai_haigo.cd_haigo = tenkai_recipe.cd_haigo
		--	AND tenkai_haigo.no_han = tenkai_recipe.no_han
		--	-- �����̕i���}�X�^
		--	LEFT JOIN (
		--		SELECT cd_hinmei
		--			,kbn_kanzan
		--		FROM ma_hinmei
		--	) genryo_hin
		--	ON genryo_hin.cd_hinmei = tenkai_recipe.cd_hinmei

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_tenkai failed insert.'
			GOTO Error_Handling
		END

		-- ��ʂ�̒��o���I������̂őΏۈꎞ�e�[�u���̒��g���N���A
		DELETE #tmp_taisho
		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_taisho failed delete.'
			GOTO Error_Handling
		END

		-- �Ώۃf�[�^�ɃR�s�[	
		INSERT INTO #tmp_taisho (
			cd_seihin
			,no_han
			,dt_from
			,cd_hinmei
			,wt_haigo
			,cd_tani
			,cd_haigo
			,no_kotei
			,no_tonyu
			,flg_mishiyo
			,kbn_hin
			,ritsu_budomari
			,oya_wt_haigo
			,oya_budomari
			,oya_haigo
			,jikagen_code
		)
		SELECT
			cd_seihin
			,no_han
			,dt_from
			,cd_hinmei
			,wt_haigo
			,cd_tani
			,cd_haigo
			,no_kotei
			,no_tonyu
			,flg_mishiyo
			,kbn_hin
			,ritsu_budomari
			,oya_wt_haigo
			,oya_budomari
			,oya_haigo
			,jikagen_code
		FROM #tmp_tenkai

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :#tmp_taisho failed insert.'
			GOTO Error_Handling
		END

		-- ���̊K�w��
		SET @tenkai_kaiso = @tenkai_kaiso + 1
	END
	-- ///////////////////////////////////////////
	--  �W�J�����F�����܂�
	-- ///////////////////////////////////////////
	DROP TABLE #tmp_taisho
	DROP TABLE #tmp_tenkai
	DROP TABLE #tmp_bairitsu
	DROP TABLE #udf_haigo

	-- �I�[�o�[�t���[���������ꍇ�̓G���[�ŏ������I������
	IF @flg_error = 1
	BEGIN
		GOTO Overflow_Handling
	END

	--PRINT 'BOM�}�X�^���o�J�n'

-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
--    BOM�}�X�^���o�e�[�u��(ma_sap_bom_denso)�̍쐬
-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-

	--���M�Ώۃe�[�u���Ƀe�X�g�i = 1�̃f�[�^�����݂���ꍇ�A���̃f�[�^���܂ސ��i���̂𑗐M�ΏۂƂ��Ȃ�
	DELETE FROM ma_sap_bom_denso_taisho
	WHERE cd_seihin IN (
		SELECT DISTINCT
		  bdt.cd_seihin 
		FROM
		  ma_sap_bom_denso_taisho bdt 
		  LEFT OUTER JOIN ma_hinmei mh 
		    ON bdt.cd_seihin = mh.cd_hinmei 
		  LEFT OUTER JOIN ( 
		    SELECT DISTINCT
		      cd_seihin
		      , flg_testitem 
		    FROM
		      ma_sap_bom_denso_taisho bdt 
		      LEFT OUTER JOIN ma_hinmei mh 
		        ON bdt.cd_hinmei = mh.cd_hinmei 
		    WHERE
		      mh.flg_testitem = 1
		  ) test 
		    ON bdt.cd_seihin = test.cd_seihin 
		  LEFT OUTER JOIN ma_hinmei mh2 
		    ON bdt.cd_hinmei = mh2.cd_hinmei 
		WHERE
		  mh.flg_testitem = 1 
		  OR test.flg_testitem = 1
	)

	-- ���o�e�[�u������x�N���A
	DELETE ma_sap_bom_denso
		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :ma_sap_bom_denso failed delete.'
			GOTO Error_Handling
		END

	INSERT INTO ma_sap_bom_denso (
		kbn_denso_SAP
		,cd_seihin
		--,no_han
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
	)
	-- ==============================================
	--   �V �K
	-- ==============================================
		SELECT
			@kbnCreate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			--,taisho.no_han
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		-- �O��Ώۃe�[�u��
		LEFT JOIN ma_sap_bom_denso_taisho_zen zen
		ON zen.cd_seihin = taisho.cd_seihin
		--AND zen.no_han = taisho.no_han
		--AND zen.cd_hinmei = taisho.cd_hinmei
		--AND zen.su_kaiso = taisho.su_kaiso
		--AND zen.cd_haigo = taisho.cd_haigo
		--AND zen.no_kotei = taisho.no_kotei
		--AND zen.no_tonyu = taisho.no_tonyu
		-- �P�ʕϊ��}�X�^
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		
		-- �O��Ώۃe�[�u���ɑ��݂��Ȃ��f�[�^�͐V�K
		WHERE zen.cd_seihin IS NULL

	-- ==============================================
	--   �X �V
	-- ==============================================
		UNION ALL

		-- �L�����t�i�J�n�j�A�i�ڐ��ʁA���ʒP�ʂ��ύX�ƂȂ��Ă���
		-- ���R�[�h�̐��i�R�[�h���擾
		SELECT
			@kbnUpdate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			--,taisho.no_han
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		LEFT JOIN (
			SELECT
				taisho.cd_seihin
			FROM
				ma_sap_bom_denso_taisho taisho
			-- �O��Ώۃe�[�u��
			LEFT JOIN ma_sap_bom_denso_taisho_zen zen
			ON zen.cd_seihin = taisho.cd_seihin
			--AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			-- �X�V�ΏۃJ�����̂ǂꂩ�ЂƂł��ύX������΍X�V
			WHERE zen.dt_from <> taisho.dt_from
			OR zen.su_hinmoku <> taisho.su_hinmoku
			OR zen.cd_tani <> taisho.cd_tani
			GROUP BY
				taisho.cd_seihin
		) up_data
		ON taisho.cd_seihin = up_data.cd_seihin
		-- �P�ʕϊ��}�X�^
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		-- �Ώۂ̐��i�R�[�h�����ׂĒ��o
		WHERE taisho.cd_seihin = up_data.cd_seihin

	-- ==============================================
	--   �� ��
	-- ==============================================
		UNION ALL
		SELECT
			@kbnDelete AS 'kbn_denso_SAP'
			,UPPER(zen.cd_seihin) AS 'cd_seihin'
			--,0 AS 'no_han'
			,zen.cd_kojo
			,null AS 'dt_from'
			,null AS 'su_kihon'
			,'' AS 'cd_hinmei'
			,null AS 'su_hinmoku'
			,'' AS 'cd_tani_henkan'
			,'' AS 'su_kaiso'
			,'' AS 'cd_haigo'
			,'' AS 'no_kotei'
			,'' AS 'no_tonyu'
		FROM
			ma_sap_bom_denso_taisho_zen zen
		-- ���ގg�p�}�X�^�A�z���}�X�^�̑S�Ŕԍ����w�b�_���x���ō폜�����ꍇ�͍폜
		LEFT JOIN (
			SELECT
				zen.cd_seihin
				,zen.cd_kojo
			FROM
				ma_sap_bom_denso_taisho_zen zen	-- �O��Ώۃe�[�u��
			-- �Ώۃe�[�u��
			LEFT JOIN ma_sap_bom_denso_taisho taisho
			ON zen.cd_seihin = taisho.cd_seihin
			--AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			-- �O��Ώۃe�[�u���ɂ̂ݑ��݂���f�[�^�̐��i�R�[�h���擾
			WHERE taisho.cd_seihin IS NULL
			GROUP BY zen.cd_seihin, zen.cd_kojo
		) del_data
		ON zen.cd_seihin = del_data.cd_seihin
		-- �Ώۃe�[�u��
		LEFT JOIN ma_sap_bom_denso_taisho taisho
		ON zen.cd_seihin = taisho.cd_seihin
		-- �O��Ώۃe�[�u���ɑ��݂��āA���M�Ώۃe�[�u���ɑ��݂��Ȃ����i�R�[�h�𒊏o
		WHERE
			zen.cd_seihin = del_data.cd_seihin
		AND taisho.cd_seihin IS NULL
		GROUP BY
			zen.cd_seihin, zen.cd_kojo

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :ma_sap_bom_denso failed insert.'
		GOTO Error_Handling
	END

	-- ==============================================
	--   �X �V
	-- ==============================================
	INSERT INTO ma_sap_bom_denso (
		kbn_denso_SAP
		,cd_seihin
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
	)
		-- �O��Ώۃe�[�u���ɂ̂݃L�[�����݂���A���A�O��Ώۃe�[�u���D���i�R�[�h��
		-- ���M�Ώۃe�[�u���ɑ��݂��郌�R�[�h�̐��i�R�[�h���擾
		SELECT
			@kbnUpdate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		-- �z�����V�s�̖��ׂ̂����A�ꕔ�����s�폜���ꂽ�ꍇ�Ȃǂ��ύX�Ƃ��Ĉ���
		LEFT JOIN (
			SELECT
				zen.cd_seihin
			FROM
				ma_sap_bom_denso_taisho_zen zen	-- �O��Ώۃe�[�u��
			-- �Ώۃe�[�u��
			LEFT JOIN ma_sap_bom_denso_taisho taisho
			ON zen.cd_seihin = taisho.cd_seihin
			AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			-- �O��Ώۃe�[�u���ɂ̂ݑ��݂���f�[�^�̐��i�R�[�h���擾
			WHERE taisho.cd_seihin IS NULL
			GROUP BY zen.cd_seihin
		) up_data
		ON taisho.cd_seihin = up_data.cd_seihin
		-- ���o�e�[�u��
		LEFT JOIN ma_sap_bom_denso denso
		ON up_data.cd_seihin = denso.cd_seihin
		-- �P�ʕϊ��}�X�^
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		-- ���o�e�[�u���ɑ��݂��Ȃ��Ώۂ̐��i�R�[�h�����ׂĒ��o
		WHERE taisho.cd_seihin = up_data.cd_seihin
		AND denso.cd_seihin IS NULL

	-- �����ԍ��A�H���ԍ��Ȃǂ̃L�[���ύX�ɂȂ����ꍇ���ύX�Ƃ��Ĉ���
	INSERT INTO ma_sap_bom_denso (
		kbn_denso_SAP
		,cd_seihin
		,cd_kojo
		,dt_from
		,su_kihon
		,cd_hinmei
		,su_hinmoku
		,cd_tani
		,su_kaiso
		,cd_haigo
		,no_kotei
		,no_tonyu
	)
		SELECT
			@kbnUpdate AS 'kbn_denso_SAP'
			,UPPER(taisho.cd_seihin) AS cd_seihin
			,taisho.cd_kojo
			,CONVERT(DECIMAL, CONVERT(VARCHAR, taisho.dt_from, 112)) AS dt_from
			,CONVERT(VARCHAR, taisho.su_kihon) AS su_kihon
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_hinmoku
			,mst.cd_tani_henkan
			,CONVERT(VARCHAR, taisho.su_kaiso) AS su_kaiso
			,taisho.cd_haigo
			,CONVERT(VARCHAR, taisho.no_kotei) AS no_kotei
			,taisho.no_tonyu
		FROM
			ma_sap_bom_denso_taisho taisho
		LEFT JOIN (
			SELECT
				taisho.cd_seihin
			FROM
				ma_sap_bom_denso_taisho taisho
			-- �O��Ώۃe�[�u��
			LEFT JOIN ma_sap_bom_denso_taisho_zen zen
			ON zen.cd_seihin = taisho.cd_seihin
			AND zen.no_han = taisho.no_han
			AND zen.cd_hinmei = taisho.cd_hinmei
			AND zen.su_kaiso = taisho.su_kaiso
			AND zen.cd_haigo = taisho.cd_haigo
			AND zen.no_kotei = taisho.no_kotei
			AND zen.no_tonyu = taisho.no_tonyu
			WHERE zen.cd_seihin IS NULL
			GROUP BY taisho.cd_seihin
		) up_data
		ON taisho.cd_seihin = up_data.cd_seihin
		-- ���o�e�[�u��
		LEFT JOIN ma_sap_bom_denso denso
		ON up_data.cd_seihin = denso.cd_seihin
		-- �P�ʕϊ��}�X�^
		LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani
		-- ���o�e�[�u���ɑ��݂��Ȃ��Ώۂ̐��i�R�[�h�����ׂĒ��o
		WHERE taisho.cd_seihin = up_data.cd_seihin
		AND denso.cd_seihin IS NULL

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :ma_sap_bom_denso failed insert2.'
		GOTO Error_Handling
	END


-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
--    �������Ή�
-- /-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-/-
	-- �i�ڐ��ʂ�0.001�ȉ��̃f�[�^������ꍇ�A�Ώۃf�[�^�̐��i��
	-- ��{���ʂƕi�ڐ��ʂ�100�{�ɂ���(�������i�P�ʁI�I����)
	
	-- 100�{���邱�ƂŌ����ӂ���N�������ꍇ�̓G���[�Ƃ���
	DECLARE cursor_err CURSOR FOR
		SELECT
			cd_seihin
			,cd_hinmei
			,su_hinmoku * 100
			,cd_haigo
			,no_kotei
			,no_tonyu
		FROM
			ma_sap_bom_denso
		WHERE cd_seihin IN (SELECT cd_seihin
							FROM ma_sap_bom_denso
							WHERE su_hinmoku < 0.001
							AND su_hinmoku > 0 -- 0���Ȃ������Ƃ�
							GROUP BY cd_seihin)
		AND (su_hinmoku * 100) > 999999.999999

	OPEN cursor_err
		IF (@@error <> 0)
		BEGIN
			SET @msg = 'CURSOR OPEN ERROR: cursor_err'
			GOTO Error_Handling
		END

	FETCH NEXT FROM cursor_err INTO
		@cur_cd_seihin
		,@cur_cd_hinmei
		,@cur_su_hinmoku
		,@cur_cd_haigo
		,@cur_no_kotei
		,@cur_no_tonyu

	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- �G���[���O�̏o��
		PRINT 'Arithmetic overflow or other arithmetic exception occurred.�F�Z�p�I�[�o�[�t���['
		SET @msg = '  Object data... cd_seihin:' + @cur_cd_seihin + ', cd_haigo:' + @cur_cd_haigo
			+ ', cd_hinmei:' + @cur_cd_hinmei + ', no_kotei:' + CONVERT(VARCHAR, @cur_no_kotei)
			+ ', no_tonyu:' + @cur_no_tonyu + ', su_hinmoku:' + CONVERT(VARCHAR, @cur_su_hinmoku)
		PRINT @msg
		PRINT ' '

		SET @flg_error = 1

		FETCH NEXT FROM cursor_err INTO
			@cur_cd_seihin
			,@cur_cd_hinmei
			,@cur_su_hinmoku
			,@cur_cd_haigo
			,@cur_no_kotei
			,@cur_no_tonyu
	END
	CLOSE cursor_err
	DEALLOCATE cursor_err

	IF @flg_error = 1
	BEGIN
		GOTO Overflow_Handling
	END

	-- �Ώۃf�[�^�̊�{���ʂƕi�ڐ��ʂ�100�{�ɂ���
	--UPDATE ma_sap_bom_denso
	--SET su_kihon = su_kihon * 100
	--	,su_hinmoku = su_hinmoku * 100
	--WHERE cd_seihin IN (SELECT cd_seihin
	--					FROM ma_sap_bom_denso
	--					WHERE su_hinmoku < 0.001
	--					AND su_hinmoku > 0 -- 0���Ȃ������Ƃ�
	--					GROUP BY cd_seihin)
	UPDATE denso
	SET denso.su_kihon = denso.su_kihon * 100
		,denso.su_hinmoku = denso.su_hinmoku * 100
	FROM ma_sap_bom_denso AS denso
	INNER JOIN ma_sap_bom_denso taisho
	ON denso.cd_seihin = taisho.cd_seihin 
	AND taisho.cd_seihin IN (SELECT cd_seihin
						FROM ma_sap_bom_denso
						WHERE su_hinmoku < 0.001
						AND su_hinmoku > 0 -- 0���Ȃ������Ƃ�
						GROUP BY cd_seihin)

	IF @@ERROR <> 0
	BEGIN
		PRINT 'error :ma_sap_bom_denso failed update.'
		RETURN
	END


	RETURN

	-- //////////// --
	--  �G���[����
	-- //////////// --
	Error_Handling:
	--	DELETE ma_sap_bom_denso_taisho
		DELETE ma_sap_bom_denso
		CLOSE cursor_taisho
		DEALLOCATE cursor_taisho
		PRINT @msg

		RETURN

	-- ////////////////////////////// --
	--  �I�[�o�[�t���[���̃G���[����
	-- ////////////////////////////// --
	Overflow_Handling:
		-- �킴�Ƒ傫�Ȑ��l��INSERT���Ė�����G���[���N����
		INSERT INTO ma_sap_bom_denso (
			kbn_denso_SAP
			,cd_seihin
			,cd_kojo
			,dt_from
			,su_kihon
			,cd_hinmei
			,su_hinmoku
			,cd_tani
			,su_kaiso
			,cd_haigo
			,no_kotei
			,no_tonyu
		) VALUES (
			0
			,'cd_seihin'
			,'cd_kojo'
			,null
			,0
			,'cd_hinmei'
			,9999999999
			,'cd_tani'
			,0
			,'cd_haigo'
			,'no_kotei'
			,'no_tonyu'
		)

		RETURN

END



GO
