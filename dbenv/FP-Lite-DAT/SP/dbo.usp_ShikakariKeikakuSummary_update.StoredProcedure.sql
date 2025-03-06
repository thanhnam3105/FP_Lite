IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakariKeikakuSummary_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakariKeikakuSummary_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2013.12.03>
-- Last update: 2016.05.30 motojima.m
-- Description:	�d�|�i�d���v��̍X�V����
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakariKeikakuSummary_update]
	@dt_seizo					DATETIME
	,@cd_shikakari_hin			VARCHAR(14)
	,@cd_shokuba				VARCHAR(10)
	,@cd_line					VARCHAR(10)
	,@no_lot_shikakari			VARCHAR(14)
	,@flg_shikomi				SMALLINT
	,@wt_shikomi_keikaku		DECIMAL(12,6)
	,@ritsu_keikaku				DECIMAL(12,6)
	,@ritsu_keikaku_hasu		DECIMAL(12,6)
	,@su_batch_keikaku			DECIMAL(12,6)
	,@su_batch_keikaku_hasu		DECIMAL(12,6)
	,@flg_shusei				SMALLINT
	,@wt_haigo_keikaku			DECIMAL(12,6)
	,@wt_haigo_keikaku_hasu		DECIMAL(12,6)
	,@flg_jisseki				SMALLINT
	,@new_no_lot_shikakari		VARCHAR(14)
	,@isChange					BIT				-- �m��`�F�b�N�{�b�N�X�ȊO���ҏW����Ă��邩�ǂ���
	,@nashiLabelPrintFlg		SMALLINT		-- ���x�����s�t���O�D���x���o�͂Ȃ�
AS
BEGIN

	-- �ϐ����X�g
	DECLARE @msg			VARCHAR(100)	-- �������ʃ��b�Z�[�W�i�[�p
	DECLARE @new_no_lot		VARCHAR(13)		-- �̔Ԃ��ꂽ���b�g�ԍ�

	-- =============================
	--  �ꎞ�T�}���[�e�[�u���̍쐬
	-- =============================
	create table #tmp_shikakari_summary (
		dt_seizo				DATETIME
		,cd_shikakari_hin		VARCHAR(14)
		,cd_shokuba				VARCHAR(10)
		,cd_line				VARCHAR(10)
		,wt_hitsuyo				DECIMAL(12,6)
		,wt_shikomi_keikaku		DECIMAL(12,6)
		,wt_shikomi_jisseki		DECIMAL(12,6)
		,wt_zaiko_keikaku		DECIMAL(12,6)
		,wt_zaiko_jisseki		DECIMAL(12,6)
		,wt_shikomi_zan			DECIMAL(12,6)
		,wt_haigo_keikaku		DECIMAL(12,6)
		,wt_haigo_keikaku_hasu	DECIMAL(12,6)
		,su_batch_keikaku		DECIMAL(12,6)
		,su_batch_keikaku_hasu	DECIMAL(12,6)
		,ritsu_keikaku			DECIMAL(12,6)
		,ritsu_keikaku_hasu		DECIMAL(12,6)
		,wt_haigo_jisseki		DECIMAL(12,6)
		,wt_haigo_jisseki_hasu	DECIMAL(12,6)
		,su_batch_jisseki		DECIMAL(12,6)
		,su_batch_jisseki_hasu	DECIMAL(12,6)
		,ritsu_jisseki			DECIMAL(12,6)
		,ritsu_jisseki_hasu		DECIMAL(12,6)
		,su_label_sumi			DECIMAL(4,0)
		,flg_label				SMALLINT
		,su_label_sumi_hasu		DECIMAL(4,0)
		,flg_label_hasu			SMALLINT
		,flg_keikaku			SMALLINT
		,flg_jisseki			SMALLINT
		,flg_shusei				SMALLINT
		,no_lot_shikakari		VARCHAR(14)
		,flg_shikomi			SMALLINT
	)


	/**************************************************************
	  INSERT�p�f�[�^�i�����f�[�^�{�p�����[�^�j���ꎞ�e�[�u���ɐݒ�
	***************************************************************/
	INSERT INTO #tmp_shikakari_summary (
		dt_seizo
		,cd_shikakari_hin
		,cd_shokuba
		,cd_line
		,wt_hitsuyo
		,wt_shikomi_keikaku
		,wt_shikomi_jisseki
		,wt_zaiko_keikaku
		,wt_zaiko_jisseki
		,wt_shikomi_zan
		,wt_haigo_keikaku
		,wt_haigo_keikaku_hasu
		,su_batch_keikaku
		,su_batch_keikaku_hasu
		,ritsu_keikaku
		,ritsu_keikaku_hasu
		,wt_haigo_jisseki
		,wt_haigo_jisseki_hasu
		,su_batch_jisseki
		,su_batch_jisseki_hasu
		,ritsu_jisseki
		,ritsu_jisseki_hasu
		,su_label_sumi
		,flg_label
		,su_label_sumi_hasu
		,flg_label_hasu
		,flg_keikaku
		,flg_jisseki
		,flg_shusei
		,no_lot_shikakari
		,flg_shikomi
	)
	SELECT
		dt_seizo
		,cd_shikakari_hin
		,cd_shokuba
		,cd_line
		,wt_hitsuyo
		,@wt_shikomi_keikaku
		,@wt_shikomi_keikaku
		,wt_zaiko_keikaku
		,wt_zaiko_jisseki
		,wt_shikomi_zan
		,@wt_haigo_keikaku
		,@wt_haigo_keikaku_hasu
		,@su_batch_keikaku
		,@su_batch_keikaku_hasu
		,@ritsu_keikaku
		,@ritsu_keikaku_hasu
		,@wt_haigo_keikaku
		,@wt_haigo_keikaku_hasu
		,@su_batch_keikaku
		,@su_batch_keikaku_hasu
		,@ritsu_keikaku
		,@ritsu_keikaku_hasu
		-- ,su_label_sumi
		-- ,flg_label
		-- ,su_label_sumi_hasu
		-- ,flg_label_hasu
		,CASE @isChange
			WHEN 1 THEN 0
			ELSE su_label_sumi
		END AS su_label_sumi
		,CASE @isChange
			WHEN 1 THEN @nashiLabelPrintFlg
			ELSE flg_label
		END AS flg_label
		,CASE @isChange
			WHEN 1 THEN 0
			ELSE su_label_sumi_hasu
		END AS su_label_sumi_hasu
		,CASE @isChange
			WHEN 1 THEN @nashiLabelPrintFlg
			ELSE flg_label_hasu
		END AS flg_label_hasu
		,flg_keikaku
		,@flg_jisseki
		,@flg_shusei
		,@new_no_lot_shikakari	-- �V�����d�|�i���b�g�ԍ�
		,@flg_shikomi
	FROM
		su_keikaku_shikakari
	WHERE 
		dt_seizo = @dt_seizo
	AND cd_shikakari_hin = @cd_shikakari_hin
	AND cd_shokuba = @cd_shokuba
	AND cd_line = @cd_line
	AND no_lot_shikakari = @no_lot_shikakari


	/************************************
		�d�|�i�d���T�}���@DELETE��INSERT
	*************************************/
	DELETE su_keikaku_shikakari
	WHERE 
		dt_seizo = @dt_seizo
	AND cd_shikakari_hin = @cd_shikakari_hin
	AND cd_shokuba = @cd_shokuba
	AND cd_line = @cd_line
	AND no_lot_shikakari = @no_lot_shikakari


	INSERT INTO su_keikaku_shikakari (
		dt_seizo
		,cd_shikakari_hin
		,cd_shokuba
		,cd_line
		,wt_hitsuyo
		,wt_shikomi_keikaku
		,wt_shikomi_jisseki
		,wt_zaiko_keikaku
		,wt_zaiko_jisseki
		,wt_shikomi_zan
		,wt_haigo_keikaku
		,wt_haigo_keikaku_hasu
		,su_batch_keikaku
		,su_batch_keikaku_hasu
		,ritsu_keikaku
		,ritsu_keikaku_hasu
		,wt_haigo_jisseki
		,wt_haigo_jisseki_hasu
		,su_batch_jisseki
		,su_batch_jisseki_hasu
		,ritsu_jisseki
		,ritsu_jisseki_hasu
		,su_label_sumi
		,flg_label
		,su_label_sumi_hasu
		,flg_label_hasu
		,flg_keikaku
		,flg_jisseki
		,flg_shusei
		,no_lot_shikakari
		,flg_shikomi
	)
	SELECT
		dt_seizo
		,cd_shikakari_hin
		,cd_shokuba
		,cd_line
		,wt_hitsuyo
		,wt_shikomi_keikaku
		,wt_shikomi_jisseki
		,wt_zaiko_keikaku
		,wt_zaiko_jisseki
		,wt_shikomi_zan
		,wt_haigo_keikaku
		,wt_haigo_keikaku_hasu
		,su_batch_keikaku
		,su_batch_keikaku_hasu
		,ritsu_keikaku
		,ritsu_keikaku_hasu
		,wt_haigo_jisseki
		,wt_haigo_jisseki_hasu
		,su_batch_jisseki
		,su_batch_jisseki_hasu
		,ritsu_jisseki
		,ritsu_jisseki_hasu
		,su_label_sumi
		,flg_label
		,su_label_sumi_hasu
		,flg_label_hasu
		,flg_keikaku
		,flg_jisseki
		,flg_shusei
		,no_lot_shikakari
		,flg_shikomi
	FROM
		#tmp_shikakari_summary


	/*******************************
		�d�|�i�d���T�}���@�X�V
	*******************************/
	--UPDATE su_keikaku_shikakari
	--SET flg_shikomi = @flg_shikomi
	--	,wt_shikomi_keikaku = @wt_shikomi_keikaku
	--	,wt_shikomi_jisseki = @wt_shikomi_keikaku
	--	,wt_haigo_keikaku = @wt_haigo_keikaku
	--	,wt_haigo_keikaku_hasu = @wt_haigo_keikaku_hasu
	--	,ritsu_keikaku = @ritsu_keikaku
	--	,ritsu_keikaku_hasu = @ritsu_keikaku_hasu
	--	,su_batch_keikaku = @su_batch_keikaku
	--	,su_batch_keikaku_hasu = @su_batch_keikaku_hasu
	--	,flg_jisseki = @flg_jisseki
	--	,flg_shusei = @flg_shusei
	--	,wt_haigo_jisseki = @wt_haigo_keikaku
	--	,wt_haigo_jisseki_hasu = @wt_haigo_keikaku_hasu
	--	,su_batch_jisseki = @su_batch_keikaku
	--	,su_batch_jisseki_hasu = @su_batch_keikaku_hasu
	--	,ritsu_jisseki = @ritsu_keikaku
	--	,ritsu_jisseki_hasu = @ritsu_keikaku_hasu
	--WHERE 
	--	dt_seizo = @dt_seizo
	--AND cd_shikakari_hin = @cd_shikakari_hin
	--AND cd_shokuba = @cd_shokuba
	--AND cd_line = @cd_line
	--AND no_lot_shikakari = @no_lot_shikakari
	
END
GO
