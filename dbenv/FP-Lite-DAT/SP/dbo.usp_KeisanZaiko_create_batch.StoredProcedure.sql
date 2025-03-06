IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KeisanZaiko_create_batch') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KeisanZaiko_create_batch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =======================================================
-- Author:		nakamura.r
-- Create date: 2019.05.27
-- Last Update: 2019.11.15 takaki.r
-- Description:	�v�Z�݌ɍ쐬
--   �v�Z�݌Ƀg�����̌v�Z�ƍX�V����
--   (�o�b�`�N��)
-- 2019.11.15: �v�Z�݌ɐ���NULL�œo�^����Ȃ��悤�C��
-- =======================================================
CREATE PROCEDURE [dbo].[usp_KeisanZaiko_create_batch]
	 @cd_update 		VARCHAR(10)		-- �X�V�ҁFSYSTEM
	,@flg_shiyo			SMALLINT		-- �萔�F���g�p�t���O�F�g�p
	,@flg_yojitsu_yo 	SMALLINT		-- �萔�F�\���t���O�F�\��
	,@flg_yojitsu_ji 	SMALLINT		-- �萔�F�\���t���O�F����
	,@kbn_hin_genryo 	SMALLINT		-- �萔�F�i�敪�F����
	,@kbn_hin_shizai 	SMALLINT		-- �萔�F�i�敪�F����
	,@kbn_hin_jikagen 	SMALLINT		-- �萔�F�i�敪�F���ƌ���
	,@cd_kg				varchar(2)		-- �萔�F�P�ʃR�[�h�FKg
	,@cd_li				varchar(2)		-- �萔�F�P�ʃR�[�h�FL
	,@kbn_zaiko_ryohin	SMALLINT		-- �萔�F�݌ɋ敪�F�Ǖi
	,@kikan_from		SMALLINT		-- �萔�F�Ώۊ��ԁF�`����
	,@kikan_to			SMALLINT		-- �萔�F�Ώۊ��ԁF�`����
AS
BEGIN

-- ======================================
--		�y�ϐ���`�z
-- ======================================

	-- �ϐ����X�g
	DECLARE @msg			VARCHAR(100)	-- �������ʃ��b�Z�[�W�i�[�p
	-- �J�[�\���p�̕ϐ����X�g
	DECLARE @cur_hizuke		DATETIME
	-- �X�V����
	DECLARE @systemUtcDate	DATETIME = GETUTCDATE()
	-- �V���K�|�[���̓��擾
	DECLARE @today	DATETIME = CONVERT(DATETIME,CONVERT(VARCHAR,GETDATE(),111) + ' 10:00')

	--�Ώۓ����擾
	DECLARE @hizuke_from DATETIME = DATEADD(mm,@kikan_from,@today)
	DECLARE @hizuke_to DATETIME = DATEADD(mm,@kikan_to,@today)


-- ======================================
--		�y�ꎞ�e�[�u����`�z
-- ======================================
	-- �i�}�X�ꎞ�e�[�u��
	create table #tmp_hinmei (
		  cd_hinmei				VARCHAR(14) COLLATE database_default
		, kbn_hin				SMALLINT
		, cd_tani_shiyo			VARCHAR(10) COLLATE database_default
		, cd_tani_nonyu			VARCHAR(10) COLLATE database_default
		, cd_tani_nonyu_hasu	VARCHAR(10) COLLATE database_default
		, wt_ko					DECIMAL(12,6) 
		, su_iri				DECIMAL(5,0)
	)
			

	-- �[���ꎞ�e�[�u��
	create table #tmp_nonyu (
		  flg_yojitsu	SMALLINT
		, cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_nonyu		DATETIME
		, su_nonyu		DECIMAL(13,6)
	)
	
	-- �[���ꎞ�e�[�u���T�}��
	create table #tmp_su_nonyu (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_nonyu		DATETIME
		, su_nonyu		DECIMAL(13,6)
	)
	
	-- ���i�v��ꎞ�e�[�u��			
	create table #tmp_seihin (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_seizo		DATETIME
		, su_seizo		DECIMAL(13,6)
	)
		
	-- �g�p�\���ꎞ�e�[�u��
	create table #tmp_shiyo (
		flg_yojitsu		SMALLINT
		,cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_shiyo		DATETIME
		,su_shiyo		DECIMAL(13,6)
	)
	
	-- �g�p�\���ꎞ�e�[�u���T�}��
	create table #tmp_su_shiyo (
		  cd_hinmei		VARCHAR(14) COLLATE database_default
		, dt_shiyo		DATETIME
		, su_shiyo		DECIMAL(13,6)
	)	
	
	-- �����ꎞ�e�[�u��			
	create table #tmp_chosei (
		cd_hinmei		VARCHAR(14) COLLATE database_default
		,dt_hizuke		DATETIME
		,su_chosei		DECIMAL(13,6)
	)		
	
	-- ���݌Ɉꎞ�e�[�u��
	create table #tmp_zaiko (
		  cd_hinmei			VARCHAR(14) COLLATE database_default
		, dt_hizuke			DATETIME
		, su_zaiko			DECIMAL(14,6)
	)

	-- �v�Z�݌Ɉꎞ�e�[�u��
	create table #tmp_zaiko_keisan (
		  cd_hinmei			VARCHAR(14) COLLATE database_default
		, dt_hizuke			DATETIME
		, su_zaiko			DECIMAL(14,6)
	)

	SET NOCOUNT ON

-- ======================================
--		�y�ꎞ�e�[�u�������z
-- ======================================
-- ===========================
--		�i���}�X�^
-- ===========================
	INSERT INTO #tmp_hinmei
	SELECT
		hin.cd_hinmei
		, hin.kbn_hin
		, hin.cd_tani_shiyo
		, ISNULL(konyu.cd_tani_nonyu, hin.cd_tani_nonyu) AS cd_tani_nonyu
		, ISNULL(konyu.cd_tani_nonyu_hasu, hin.cd_tani_nonyu_hasu) AS cd_tani_nonyu_hasu
		, COALESCE(konyu.wt_nonyu, hin.wt_ko, 1) AS wt_ko
		, COALESCE(konyu.su_iri, hin.su_iri, 1) AS su_iri
	FROM (
		SELECT
			*
		FROM ma_hinmei ma
		WHERE ma.flg_mishiyo = @flg_shiyo
			AND ma.kbn_hin IN(@kbn_hin_genryo, @kbn_hin_shizai, @kbn_hin_jikagen)
		) hin
	INNER JOIN (
		SELECT
			cd_hinmei
			, MIN(no_juni_yusen) AS no_juni_yusen
		FROM ma_konyu
		WHERE flg_mishiyo = @flg_shiyo
		GROUP BY cd_hinmei
		) yusen
	  ON yusen.cd_hinmei = hin.cd_hinmei
	INNER JOIN ma_konyu konyu
	  ON konyu.cd_hinmei = yusen.cd_hinmei
	  AND konyu.no_juni_yusen = yusen.no_juni_yusen
	 
	
	-- �ꎞ�i���}�X�^�ɃC���f�b�N�X��t��
	CREATE NONCLUSTERED INDEX idx_hin1 ON #tmp_hinmei (cd_hinmei)
	
-- ===========================
--		�[���g����
-- ===========================
	-- �ꎞ�[���g����
	INSERT INTO #tmp_nonyu 
	SELECT
		nonyu.flg_yojitsu
		, nonyu.cd_hinmei
		, nonyu.dt_nonyu
		, SUM(
			CASE
				WHEN hin.cd_tani_nonyu IN (@cd_kg, @cd_li)
					THEN nonyu.su_nonyu * hin.su_iri * hin.wt_ko + (nonyu.su_nonyu_hasu / 1000)
				ELSE nonyu.su_nonyu * hin.su_iri * hin.wt_ko + nonyu.su_nonyu_hasu * hin.wt_ko
			END
			) AS su_nonyu
	FROM (
		SELECT
			*
		FROM tr_nonyu  
		WHERE dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
		) nonyu
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = nonyu.cd_hinmei
	GROUP BY nonyu.flg_yojitsu, nonyu.cd_hinmei, nonyu.dt_nonyu
	
	-- �ꎞ�[���g�����T�}���[
	INSERT INTO #tmp_su_nonyu
	SELECT
		base.cd_hinmei
		, base.dt_nonyu
		, CASE
			-- �����̓��t�͗\��
			WHEN base.dt_nonyu > @today THEN ROUND(COALESCE(yotei.su_nonyu, 0),3,1)
			-- �����̓��t�́A���т�����Ύ��сA�Ȃ���Η\��
			WHEN base.dt_nonyu = @today THEN ROUND(COALESCE(jisseki.su_nonyu,yotei.su_nonyu, 0),3,1)
			-- �ߋ��̓��t�͎���
		    ELSE COALESCE(jisseki.su_nonyu, 0)
		  END AS su_nonyu
	FROM (
		SELECT DISTINCT
			cd_hinmei
			, dt_nonyu
		FROM #tmp_nonyu
	) base
	LEFT OUTER JOIN #tmp_nonyu yotei
	  ON yotei.flg_yojitsu = @flg_yojitsu_yo
	  AND yotei.cd_hinmei = base.cd_hinmei
	  AND yotei.dt_nonyu = base.dt_nonyu
	LEFT OUTER JOIN #tmp_nonyu jisseki
	  ON jisseki.flg_yojitsu = @flg_yojitsu_ji
	  AND jisseki.cd_hinmei = base.cd_hinmei
	  AND jisseki.dt_nonyu = base.dt_nonyu
	  
	-- �ꎞ�[���g�����ɃC���f�b�N�X��t��
	CREATE NONCLUSTERED INDEX idx_nonyu2 ON #tmp_su_nonyu (cd_hinmei, dt_nonyu)
	
-- ===========================
--		���i�v��g����
-- ===========================
	
	INSERT INTO #tmp_seihin
	SELECT
		jikagen.cd_hinmei
		, jikagen.dt_seizo
		, CASE
			-- �����̓��t�͗\��
			WHEN jikagen.dt_seizo > @today THEN ROUND(su_seizo_yotei, 3, 1)
			-- �����̓��t�́A���т�����Ύ��сA�Ȃ���Η\��
			WHEN jikagen.dt_seizo = @today THEN ROUND(COALESCE(su_seizo_jisseki,su_seizo_yotei,0),3,1)
			-- �ߋ��̓��t�͎���
		    ELSE su_seizo_jisseki
		  END AS su_seizo
	FROM (
		SELECT
			seihin.cd_hinmei
			, seihin.dt_seizo
			, SUM(seihin.su_seizo_yotei * hin.su_iri * hin.wt_ko) AS su_seizo_yotei
			, SUM(seihin.su_seizo_jisseki * hin.su_iri * hin.wt_ko) AS su_seizo_jisseki
		FROM (
			SELECT
				*
			FROM tr_keikaku_seihin
			WHERE dt_seizo BETWEEN @hizuke_from AND @hizuke_to
			) seihin
		INNER JOIN #tmp_hinmei hin
		  ON hin.cd_hinmei = seihin.cd_hinmei
		GROUP BY seihin.cd_hinmei, seihin.dt_seizo
	) jikagen
	
	-- �ꎞ���i�v��g�����ɃC���f�b�N�X��t��
	CREATE NONCLUSTERED INDEX idx_sei1 ON #tmp_seihin (cd_hinmei, dt_seizo)
	
	
-- ===========================
--		�g�p�\���g����
-- ===========================
	-- �ꎞ�g�p�\���g����
	INSERT INTO #tmp_shiyo 
	SELECT
		shiyo.flg_yojitsu
		, shiyo.cd_hinmei
		, shiyo.dt_shiyo
		, SUM(shiyo.su_shiyo)AS su_shiyo
	FROM (
		SELECT
			*
		FROM tr_shiyo_yojitsu  
		WHERE dt_shiyo BETWEEN @hizuke_from AND @hizuke_to
		) shiyo
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = shiyo.cd_hinmei
	GROUP BY shiyo.flg_yojitsu, shiyo.cd_hinmei, shiyo.dt_shiyo
	
	-- �ꎞ�g�p�\���T�}���[
	INSERT INTO #tmp_su_shiyo
	SELECT
		base.cd_hinmei
		, base.dt_shiyo
		, CASE
			-- �����̓��t�͗\��i�����܂ށj
			WHEN base.dt_shiyo >= @today THEN CEILING(COALESCE(yotei.su_shiyo,0) * 1000) / 1000
			-- �ߋ��̓��t�͎���
		    ELSE CEILING(COALESCE(jisseki.su_shiyo,0) * 1000) / 1000
		  END AS su_shiyo
	FROM (
		SELECT DISTINCT
			cd_hinmei
			, dt_shiyo
		FROM #tmp_shiyo
		) base
	LEFT OUTER JOIN #tmp_shiyo yotei
	  ON yotei.flg_yojitsu = @flg_yojitsu_yo
	  AND yotei.cd_hinmei = base.cd_hinmei
	  AND yotei.dt_shiyo = base.dt_shiyo
	LEFT OUTER JOIN #tmp_shiyo jisseki
	  ON jisseki.flg_yojitsu = @flg_yojitsu_ji
	  AND jisseki.cd_hinmei = base.cd_hinmei
	  AND jisseki.dt_shiyo = base.dt_shiyo
	  
	
	-- �ꎞ�g�p�\���g�����ɃC���f�b�N�X��t��
	CREATE NONCLUSTERED INDEX idx_shi2 ON #tmp_su_shiyo (cd_hinmei, dt_shiyo)

	
-- ===========================
--		�����g����
-- ===========================
	INSERT INTO #tmp_chosei
	SELECT
		chosei.cd_hinmei
		, chosei.dt_hizuke
		, CEILING(SUM(COALESCE(chosei.su_chosei, 0)) * 1000) / 1000 AS su_chosei
	FROM (
		SELECT
			*
		FROM tr_chosei
		WHERE dt_hizuke BETWEEN @hizuke_from AND @hizuke_to
		) chosei 
	INNER JOIN  #tmp_hinmei hin
	  ON hin.cd_hinmei = chosei.cd_hinmei
	GROUP BY chosei.cd_hinmei, chosei.dt_hizuke
	  
	-- �ꎞ�����g�����ɃC���f�b�N�X��t��
	CREATE NONCLUSTERED INDEX idx_cho1 ON #tmp_chosei (cd_hinmei, dt_hizuke)
	

-- ===========================
--		�݌Ƀg����
-- ===========================

	-- ���݌ɂ͑O���ȍ~�̂����擾
	INSERT INTO #tmp_zaiko
	SELECT
		  zaiko.cd_hinmei
		, zaiko.dt_hizuke
		, ROUND(zaiko.su_zaiko, 3, 1) AS su_zaiko
	FROM (
		SELECT * 
		FROM tr_zaiko
		WHERE dt_hizuke BETWEEN DATEADD(day, -1, @hizuke_from) AND DATEADD(day, -1, @hizuke_to)
          AND kbn_zaiko = @kbn_zaiko_ryohin
		) zaiko
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = zaiko.cd_hinmei

	
	-- �ꎞ�݌Ƀg�����ɃC���f�b�N�X��t��
	CREATE NONCLUSTERED INDEX idx_zai1 ON #tmp_zaiko (cd_hinmei, dt_hizuke)

-- ===========================
--		�v�Z�݌Ƀg����
-- ===========================
	--�v�Z�݌Ƀg�����͑O�����_�ł̌v�Z�݌ɂ݂̂�ݒ�
	INSERT INTO #tmp_zaiko_keisan
	SELECT
		zaiko_keisan.cd_hinmei
		, DATEADD(day, -1, @hizuke_from) AS dt_hizuke
		, ROUND(COALESCE(zaiko_keisan.su_zaiko,0), 3, 1) AS su_zaiko
	FROM (
		SELECT cd_hinmei
		    , MAX(dt_hizuke) dt_hizuke
		FROM tr_zaiko_keisan
		WHERE dt_hizuke < @hizuke_from
		GROUP BY cd_hinmei
		) chokkin_zaiko
	INNER JOIN tr_zaiko_keisan zaiko_keisan
	  ON zaiko_keisan.cd_hinmei = chokkin_zaiko.cd_hinmei
	  AND zaiko_keisan.dt_hizuke = chokkin_zaiko.dt_hizuke
	INNER JOIN #tmp_hinmei hin
	  ON hin.cd_hinmei = zaiko_keisan.cd_hinmei

-- ======================================
--		�y�v�Z�݌ɎZ�o�z
-- ======================================

	-- ================================
	--  ��ʂœ��͂��ꂽ�w����Ԃ𒊏o
	-- ================================
	DECLARE cursor_calendar CURSOR FOR
		SELECT
			dt_hizuke
		FROM ma_calendar
		WHERE
			dt_hizuke BETWEEN @hizuke_from AND @hizuke_to


	-- ============================================
	--  �� �w�����(�v�Z�Ώۓ�)�̃J�[�\���X�^�[�g ��
	-- ============================================
	OPEN cursor_calendar
		IF (@@error <> 0)
		BEGIN
		    SET @msg = 'CURSOR OPEN ERROR: cursor_calendar'
		    GOTO Error_Handling
		END

	FETCH NEXT FROM cursor_calendar INTO
		@cur_hizuke

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		INSERT INTO #tmp_zaiko_keisan
		SELECT
			keisan.cd_hinmei
			, @cur_hizuke AS dt_hizuke
			-- �O���݌Ɂ{�[����-�g�p��-������
			, keisan.su_zaiko_zen + keisan.su_nonyu - keisan.su_shiyo - keisan.su_chosei AS zaiko
		FROM (
			SELECT
				hin.cd_hinmei
				, CASE
					WHEN hin.kbn_hin = @kbn_hin_jikagen THEN COALESCE(seihin.su_seizo,0)
					ELSE COALESCE(nonyu.su_nonyu,0)
				  END AS su_nonyu
				, COALESCE(shiyo.su_shiyo,0) AS su_shiyo
				, COALESCE(chosei.su_chosei,0) AS su_chosei
				, COALESCE(zaiko.su_zaiko, zaiko_keisan.su_zaiko,0) AS su_zaiko_zen
			FROM #tmp_hinmei hin
			-- �[�����i�����E���ށj
			LEFT OUTER JOIN #tmp_su_nonyu nonyu
			  ON nonyu.cd_hinmei = hin.cd_hinmei
			  AND nonyu.dt_nonyu = @cur_hizuke
			-- �������i���ƌ����j
			LEFT OUTER JOIN #tmp_seihin seihin
			  ON seihin.cd_hinmei = hin.cd_hinmei
			  AND seihin.dt_seizo = @cur_hizuke
			-- �g�p��
			LEFT OUTER JOIN #tmp_su_shiyo shiyo
			  ON shiyo.cd_hinmei = hin.cd_hinmei
			  AND shiyo.dt_shiyo = @cur_hizuke
			-- ������
			LEFT OUTER JOIN #tmp_chosei chosei
			  ON chosei.cd_hinmei = hin.cd_hinmei
			  AND chosei.dt_hizuke = @cur_hizuke
			-- ���݌Ɂi�O���j
			LEFT OUTER JOIN #tmp_zaiko zaiko
			  ON zaiko.cd_hinmei = hin.cd_hinmei
			  AND zaiko.dt_hizuke = DATEADD(day, -1, @cur_hizuke)
			-- �v�Z�݌Ɂi�O���ȑO�̒��߁j
			LEFT OUTER JOIN (
				SELECT cd_hinmei
					, MAX(dt_hizuke) dt_hizuke
				FROM #tmp_zaiko_keisan
				WHERE dt_hizuke < @cur_hizuke
				GROUP BY cd_hinmei
				) chokkin_zaiko
			  ON chokkin_zaiko.cd_hinmei = hin.cd_hinmei
			LEFT OUTER JOIN #tmp_zaiko_keisan zaiko_keisan
			  ON zaiko_keisan.cd_hinmei = chokkin_zaiko.cd_hinmei
			  AND zaiko_keisan.dt_hizuke = chokkin_zaiko.dt_hizuke
		) keisan
		
		-- �v�Z�Ώۓ��̃J�[�\�������̍s��
		FETCH NEXT FROM cursor_calendar INTO
			@cur_hizuke
	END
    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :#tmp_zaiko_keisan failed insert.'
        GOTO Error_Handling
    END

	-- �J�[�\�������
	CLOSE cursor_calendar
	DEALLOCATE cursor_calendar

-- ======================================
--		�y�ꎞ�v�Z�݌ɂ̑O�������폜�z
-- ======================================
	DELETE #tmp_zaiko_keisan
	WHERE dt_hizuke = DATEADD(day, -1, @hizuke_from)

-- ======================================
--		�y�v�Z�݌ɍ폜�z
-- ======================================
	DELETE tr
		FROM tr_zaiko_keisan tr
		INNER JOIN #tmp_hinmei tmp_hin
			ON tr.cd_hinmei = tmp_hin.cd_hinmei
		WHERE tr.dt_hizuke BETWEEN @hizuke_from AND @hizuke_to

	IF @@ERROR <> 0
	BEGIN
        SET @msg = 'error :tr_zaiko_keisan failed delete.'
        GOTO Error_Handling
    END

-- ======================================
--		�y�v�Z�݌ɓo�^�z
-- ======================================
	INSERT INTO tr_zaiko_keisan (
		cd_hinmei
		,dt_hizuke
		,su_zaiko
		,dt_update
		,cd_update
	)
	SELECT
		cd_hinmei
		, dt_hizuke
		, su_zaiko
		, @systemUtcDate
		, @cd_update
	FROM #tmp_zaiko_keisan

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :tr_zaiko_keisan failed insert.'
        GOTO Error_Handling
    END

 --============================
 -- �����ތv��Ǘ��g�����̍X�V
 --============================
	-- ���݂����UPDATE�A�Ȃ����INSERT
	MERGE INTO tr_genshizai_keikaku AS tr
		USING
			(
				SELECT DISTINCT 
					tzk.cd_hinmei
				FROM #tmp_zaiko_keisan tzk
			) AS tmp
			ON tr.cd_hinmei = tmp.cd_hinmei
		WHEN MATCHED THEN
			UPDATE SET tr.dt_zaiko_keisan = @hizuke_to
		WHEN NOT MATCHED THEN
			INSERT (cd_hinmei, dt_zaiko_keisan, dt_keikaku_nonyu)
			VALUES (tmp.cd_hinmei, @hizuke_to, NULL);
	
	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :tr_genshizai_keikaku failed update.'
		GOTO Error_Handling
	END	

-- ======================================
--		�y�I�������z
-- ======================================	
	DROP TABLE #tmp_hinmei
	DROP TABLE #tmp_nonyu
	DROP TABLE #tmp_su_nonyu
	DROP TABLE #tmp_shiyo
	DROP TABLE #tmp_su_shiyo
	DROP TABLE #tmp_seihin
	DROP TABLE #tmp_chosei
	DROP TABLE #tmp_zaiko
	DROP TABLE #tmp_zaiko_keisan
	
	RETURN 0

-- ======================================
--		�y�G���[�����z
-- ======================================	
	Error_Handling:
		CLOSE cursor_calendar
		DEALLOCATE cursor_calendar
			
		DROP TABLE #tmp_hinmei
		DROP TABLE #tmp_nonyu
		DROP TABLE #tmp_su_nonyu
		DROP TABLE #tmp_shiyo
		DROP TABLE #tmp_su_shiyo
		DROP TABLE #tmp_seihin
		DROP TABLE #tmp_chosei
		DROP TABLE #tmp_zaiko
		DROP TABLE #tmp_zaiko_keisan
		
		PRINT @msg
		RETURN 1


END



GO
