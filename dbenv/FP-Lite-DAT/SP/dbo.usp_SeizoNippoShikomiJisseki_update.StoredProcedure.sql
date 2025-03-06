IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippoShikomiJisseki_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippoShikomiJisseki_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	�������񂩂�̎d�����эX�V
-- Update: 2017.11.21	BRC	cho.k	�V�K
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoNippoShikomiJisseki_update]
	(
		  @dt_seizo							DATETIME		-- ������
		, @cd_hinmei						VARCHAR(14)		-- �i���R�[�h
		, @no_lot_seihin					VARCHAR(14)		-- ���i���b�g�ԍ�
		, @su_seizo_jisseki					DECIMAL(12,6)	-- �������ѐ�
	)
AS
BEGIN
-- =============================================
--               �ϐ���`
-- =============================================	
	-- �Ώۈꎞ���[�N�e�[�u��
	CREATE TABLE #wk_tr_shikakari (
	      dt_seizo			DATETIME
		, cd_haigo			VARCHAR(14) COLLATE database_default
		, su_kai            INT
		, no_lot_seihin		VARCHAR(14) COLLATE database_default
		, no_lot_shikakari	VARCHAR(14) COLLATE database_default
		, wt_shikomi		DECIMAL(12, 6)
	)

	-- �Ώۈꎞ���[�N�e�[�u��
	CREATE TABLE #wk_su_shikakari (
	      dt_seizo			DATETIME
		, cd_haigo			VARCHAR(14) COLLATE database_default
		, no_han            DECIMAL(4, 0)
		, no_lot_shikakari	VARCHAR(14) COLLATE database_default
		, wt_shikomi		DECIMAL(12, 6)
		, wt_haigo_gokei	DECIMAL(12, 6)
		, ritsu_kihon		DECIMAL(5, 2)
		, su_batch			DECIMAL(12, 6)
		, su_batch_hasu		DECIMAL(12, 6)
		, ritsu				DECIMAL(12, 6)
		, ritsu_hasu		DECIMAL(12, 6)
	)

	-- �����ϐ�
	DECLARE @wt_shikomi_jisseki DECIMAL(12,6)
	DECLARE @cnt				INT
	DECLARE @msg				VARCHAR(500)		-- �������ʃ��b�Z�[�W�i�[�p
	DECLARE @cd_haigo			VARCHAR(14)
	DECLARE @no_seq				VARCHAR(14)
	
	-- �J�[�\���p�ϐ�
	DECLARE @cur_dt_seizo			DATETIME
	DECLARE @cur_cd_hinmei			VARCHAR(14) 
	DECLARE @cur_no_lot_seihin		VARCHAR(14)
	DECLARE @cur_su_seizo_jisseki	DECIMAL(12, 6)
	
	DECLARE @cur_cd_haigo			VARCHAR(14) 
	DECLARE @cur_no_han				DECIMAL(4, 0)
	DECLARE @cur_no_lot_shikakari	VARCHAR(14)
	DECLARE @cur_wt_shikomi			DECIMAL(12, 6)
	DECLARE @cur_ritsu_kihon		DECIMAL(5, 2)
	DECLARE @cur_wt_haigo_gokei		DECIMAL(12, 6)
	
	DECLARE @cur_su_shiyo			DECIMAL(12, 6)
	
	
	
-- =============================================
--         �d�|�i�v��̎��т��v�Z
-- =============================================	
	-- �d�|�i���т��v�Z����B
	INSERT INTO #wk_tr_shikakari
	EXECUTE usp_ShikomiJissekiTenkai @dt_seizo, @cd_hinmei, @no_lot_seihin, @su_seizo_jisseki
	
	DECLARE cursor_seizo_jisseki CURSOR FOR
	SELECT DISTINCT
		seihin.dt_seizo
		, seihin.cd_hinmei
		, seihin.no_lot_seihin
		, seihin.su_seizo_jisseki
	FROM tr_keikaku_seihin seihin
	INNER JOIN tr_keikaku_shikakari shikakari
	  ON shikakari.dt_seizo = seihin.dt_seizo
	  AND shikakari.no_lot_seihin = seihin.no_lot_seihin
	WHERE seihin.no_lot_seihin <> @no_lot_seihin
	    AND seihin.flg_jisseki = 1
		AND shikakari.no_lot_shikakari IN (
				SELECT no_lot_shikakari 
				FROM #wk_tr_shikakari
			)
	
  	OPEN cursor_seizo_jisseki
	IF (@@error <> 0)
	BEGIN
		SET @msg = 'CURSOR OPEN ERROR: cursor_seizo_jisseki'
		GOTO Error_Handling
	END
	
	FETCH NEXT FROM cursor_seizo_jisseki INTO
		  @cur_dt_seizo
		, @cur_cd_hinmei	
		, @cur_no_lot_seihin 
		, @cur_su_seizo_jisseki
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		INSERT INTO #wk_tr_shikakari
		EXECUTE usp_ShikomiJissekiTenkai
			@cur_dt_seizo
			, @cur_cd_hinmei
			, @cur_no_lot_seihin
			, @cur_su_seizo_jisseki
	
		FETCH NEXT FROM cursor_seizo_jisseki INTO
			  @cur_dt_seizo
			, @cur_cd_hinmei	
			, @cur_no_lot_seihin 
			, @cur_su_seizo_jisseki
			
	END
	
	CLOSE cursor_seizo_jisseki
	DEALLOCATE cursor_seizo_jisseki
	
-- =============================================
--         �d���v��̎��т��v�Z
-- =============================================	
	
	DECLARE cursor_shikomi_jisseki CURSOR FOR
	SELECT
		shikakari.dt_seizo
		, shikakari.cd_haigo
		, max_han.no_han
		, shikakari.no_lot_shikakari
		, shikakari.wt_shikomi
		, CAST(CEILING(haigo.wt_haigo_gokei * 1000000) / 1000000 AS DECIMAL(12,6)) AS wt_haigo_gokei
		, haigo.ritsu_kihon
	FROM (
		SELECT
			dt_seizo
			, cd_haigo
			, no_lot_shikakari
			, SUM(wt_shikomi) AS wt_shikomi 
		FROM #wk_tr_shikakari
		WHERE no_lot_shikakari IN (
				SELECT no_lot_shikakari 
				FROM #wk_tr_shikakari
				WHERE no_lot_seihin = @no_lot_seihin
				)
		GROUP BY dt_seizo, cd_haigo, no_lot_shikakari
	) shikakari
	INNER JOIN (
		SELECT
			cd_haigo
			, MAX(no_han) AS no_han
		FROM ma_haigo_mei
		WHERE dt_from <= @dt_seizo
		  AND flg_mishiyo = 0
		GROUP BY cd_haigo
		  ) max_han
		ON max_han.cd_haigo = shikakari.cd_haigo
	INNER JOIN ma_haigo_mei haigo
	    ON haigo.cd_haigo = max_han.cd_haigo
	    AND haigo.no_han = max_han.no_han


  	OPEN cursor_shikomi_jisseki
	IF (@@error <> 0)
	BEGIN
		SET @msg = 'CURSOR OPEN ERROR: cursor_shikomi_jisseki'
		GOTO Error_Handling
	END
	
	FETCH NEXT FROM cursor_shikomi_jisseki INTO
		  @cur_dt_seizo
		, @cur_cd_haigo
		, @cur_no_han
		, @cur_no_lot_shikakari 
		, @cur_wt_shikomi
		, @cur_wt_haigo_gokei
		, @cur_ritsu_kihon
		
	WHILE @@FETCH_STATUS = 0
	BEGIN

		INSERT INTO #wk_su_shikakari
		SELECT TOP(1)
			@cur_dt_seizo
			, @cur_cd_haigo
			, @cur_no_han
			, @cur_no_lot_shikakari
			, @cur_wt_shikomi
			, @cur_wt_haigo_gokei
			, @cur_ritsu_kihon
			, batch
			, batch_hasu
			, bairitsu
			, bairitsu_hasu
		FROM udf_MakeBairitsuObject(@cur_wt_shikomi, @cur_wt_haigo_gokei, @cur_ritsu_kihon)

		FETCH NEXT FROM cursor_shikomi_jisseki INTO
		  @cur_dt_seizo
		, @cur_cd_haigo
		, @cur_no_han
		, @cur_no_lot_shikakari 
		, @cur_wt_shikomi
		, @cur_wt_haigo_gokei
		, @cur_ritsu_kihon
			
	END
	
	CLOSE cursor_shikomi_jisseki
	DEALLOCATE cursor_shikomi_jisseki

-- =============================================
--         �d���v��̎��т��X�V
-- =============================================		
	-- �d�����т̍X�V
	-- �y�X�V�Ώہz
	-- 1.�d�����т����Ɋm�肳��Ă��Ȃ����ƁB
	-- 2.�X�V���ꂽ�������тɕR�Â��d�����тł��邱�ƁB
	UPDATE su_keikaku_shikakari
	SET wt_shikomi_jisseki = jisseki.wt_shikomi
	  , su_batch_jisseki = jisseki.su_batch
	  , su_batch_jisseki_hasu = jisseki.su_batch_hasu
	  , ritsu_jisseki = jisseki.ritsu
	  , ritsu_jisseki_hasu = jisseki.ritsu_hasu
	FROM su_keikaku_shikakari shikakari
	INNER JOIN #wk_su_shikakari jisseki
	  ON jisseki.no_lot_shikakari = shikakari.no_lot_shikakari
	WHERE shikakari.flg_jisseki = 0
	  AND shikakari.no_lot_shikakari IN (
					SELECT no_lot_shikakari
					FROM #wk_tr_shikakari
					WHERE no_lot_seihin = @no_lot_seihin
					)
					
		
-- =============================================
--         �ꎞ�e�[�u���폜
-- =============================================					
	DROP TABLE #wk_tr_shikakari
	DROP TABLE #wk_su_shikakari
	
	RETURN
	
-- =============================================
--         ��O����
-- =============================================	
	-- //////////// --
	--  �G���[����
	-- //////////// --
	Error_Handling:
		CLOSE cursor_seizo_jisseki
		DEALLOCATE cursor_seizo_jisseki
		CLOSE cursor_shikomi_jisseki
		DEALLOCATE cursor_shikomi_jisseki
		
		PRINT @msg
		DROP TABLE #wk_tr_shikakari
		DROP TABLE #wk_su_shikakari

		RETURN
END
GO