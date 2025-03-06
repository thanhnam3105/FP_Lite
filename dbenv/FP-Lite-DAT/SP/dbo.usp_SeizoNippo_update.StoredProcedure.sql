IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoNippo_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoNippo_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kasahara.a>
-- Create date: <Create Date,,2013.05.27>
-- Update: <2017.11.21 cho.k>
--       : <2022.12.16 brc.takaki> #1997�Ή��F�g�p�\���g�����f�[�^�̍폜���������ގg�p�}�X�^�̃f�[�^�ɂ�����炸���s�����悤�ɏC���B
-- Description:	��������̍X�V����
-- =============================================

CREATE PROCEDURE [dbo].[usp_SeizoNippo_update]
	@no_lot_seihin VARCHAR(14)
	,@dt_seizo DATETIME
	,@cd_hinmei VARCHAR(14)
	,@su_seizo_jisseki DECIMAL(13, 3)
	,@flg_jisseki SMALLINT
    ,@JissekiYojitsuFlag smallint
    ,@ShiyoYojitsuSeqNoSaibanKbn varchar(2)
    ,@ShiyoYojitsuSeqNoPrefixSaibanKbn varchar(1)
    ,@FlagFalse varchar(1)
    ,@persentKanzan DECIMAL(5, 2)
    ,@su_batch_jisseki DECIMAL(12, 6)
    ,@dt_shomi DATETIME
	,@no_lot_hyoji VARCHAR(30)
	,@isUpdateAnbun SMALLINT -- ��ʂł�isCheckAnbun�BNull���P�œn�����B -- SAP�A�g�Ή�
	,@midensoDensoKubun SMALLINT -- �敪�^�R�[�h�ꗗ�D�`���敪�D���`�� -- SAP�A�g�Ή�
AS
BEGIN

	-- UTC���t�փt�H�[�}�b�g
	--SET @dt_seizo = DATEADD(SECOND, DATEDIFF(SECOND, GETDATE(), GETUTCDATE()), @dt_seizo)

	DECLARE @flg_jisseki_old SMALLINT
	DECLARE @su_seizo_jisseki_old DECIMAL(13, 3)
	DECLARE @kbn_shikomi_jisseki_update SMALLINT

	-- �X�V�O�̊m��L�����擾
	SELECT @flg_jisseki_old = flg_jisseki FROM tr_keikaku_seihin WHERE no_lot_seihin = @no_lot_seihin

	-- �X�V�O�̎��ѐ����擾
	SELECT @su_seizo_jisseki_old = su_seizo_jisseki FROM tr_keikaku_seihin WHERE no_lot_seihin = @no_lot_seihin

	-- �@�\�I���̎d�����эX�V�敪�y�敪�F30�z���擾
	SELECT @kbn_shikomi_jisseki_update = ISNULL(kbn_kino_naiyo,0) FROM cn_kino_sentaku WHERE kbn_kino = 30

	/*******************************
		���i�v��g�����@�X�V
	*******************************/
	UPDATE tr_keikaku_seihin
	SET su_seizo_jisseki = @su_seizo_jisseki
		,flg_jisseki = @flg_jisseki
		,dt_update = GETUTCDATE()
		,su_batch_jisseki = @su_batch_jisseki
		,dt_shomi = @dt_shomi
		,no_lot_hyoji = @no_lot_hyoji
	WHERE no_lot_seihin = @no_lot_seihin

	/*******************************************
		�g�p�\���g�����@�V�K�o�^�E�X�V�E�폜
	*******************************************/
	-- �g�p�\���g�����@�폜
	-- �m���������ꂽ�f�[�^�̂ݍs��
	IF (@flg_jisseki_old = 1 AND @flg_jisseki = 0)
	BEGIN
		-- �g�p�\���g�����̍폜
		DELETE tr_shiyo_yojitsu
		WHERE flg_yojitsu = 1
			AND no_lot_seihin = @no_lot_seihin
			AND no_lot_shikakari IS NULL

		-- �����p�g�p�g�����̍폜
		EXEC dbo.usp_GenkaShiyo_delete @no_lot_seihin, null
	END

	-- �g�p�\���g�����@�X�V(DELTE)
	-- �m��@���@�������ѐ��ɕύX�̂������f�[�^�̂ݍs��
	IF (@flg_jisseki_old = 1 AND @flg_jisseki = 1)
	BEGIN
		DELETE tr_shiyo_yojitsu
		WHERE flg_yojitsu = 1
			AND dt_shiyo = @dt_seizo
			AND no_lot_seihin = @no_lot_seihin
			AND no_lot_shikakari IS NULL
	END
	
	-- ���ގg�p�}�X�^�@����
	DECLARE @cd_shizai VARCHAR(14)
	DECLARE @su_shiyo_shizai DECIMAL(12,6)
	DECLARE @su_shiyo DECIMAL(12,6)
	DECLARE @no_seq varchar(14)
    DECLARE @budomari DECIMAL(5,2)
	--DECLARE @cnt smallint
	--SET @cnt = 0

	DECLARE ichiran_cd_shizai CURSOR FAST_FORWARD FOR
	SELECT cd_shizai, su_shiyo FROM udf_ShizaiShiyoYukoHan(@cd_hinmei, @FlagFalse, @dt_seizo)

	OPEN ichiran_cd_shizai
		IF (@@error <> 0)
		BEGIN
			DEALLOCATE ichiran_cd_shizai
		END
		FETCH NEXT FROM ichiran_cd_shizai INTO @cd_shizai, @su_shiyo_shizai
		WHILE @@FETCH_STATUS = 0
		BEGIN
            
            -- �i���}�X�^����������擾
            SET @budomari = NULL -- ��x�N���A
            SET @budomari = (SELECT ma.ritsu_budomari FROM ma_hinmei ma
							 WHERE ma.cd_hinmei = @cd_shizai)
            IF @budomari IS NULL
            BEGIN
				SET @budomari = @persentKanzan	-- NULL�̏ꍇ�A�����l��ݒ�
			END
			
			-- �g�p�����v�Z
			SET @su_shiyo = 0.00 -- ��x�N���A
			SET @su_shiyo = @su_seizo_jisseki * @su_shiyo_shizai / @budomari * @persentKanzan

			--�g�p�\���g�����@�V�K�o�^�E�X�V(INSERT)
			-- �m��f�[�^�̂ݍs��
			--IF (@flg_jisseki_old = 0 AND @flg_jisseki = 1 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			IF ((@flg_jisseki_old = 0 OR @flg_jisseki_old = 1) AND @flg_jisseki = 1 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			BEGIN
				-- �g�p�\���@�̔ԏ���
				EXEC dbo.usp_cm_Saiban @ShiyoYojitsuSeqNoSaibanKbn, @ShiyoYojitsuSeqNoPrefixSaibanKbn,
				@no_saiban = @no_seq output

				INSERT INTO tr_shiyo_yojitsu (
					no_seq
					,flg_yojitsu
					,cd_hinmei
					,dt_shiyo
					,no_lot_seihin
					,no_lot_shikakari
					,su_shiyo
				) VALUES (
					@no_seq
					,@JissekiYojitsuFlag
					,@cd_shizai
					,@dt_seizo
					,@no_lot_seihin
					,NULL
					--,(@su_seizo_jisseki * @su_shiyo_shizai) -- �g�p��
					,@su_shiyo
				)
			END
	        
			/*******************************
				�g�p�\���g�����@�폜
			*******************************/
			-- �m���������ꂽ�f�[�^�̂ݍs��
			/*
			IF (@flg_jisseki_old = 1 AND @flg_jisseki = 0 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			BEGIN
			*/
				-- �g�p�\���g�����̍폜
				/*
				DELETE tr_shiyo_yojitsu
				WHERE flg_yojitsu = 1
					AND cd_hinmei = @cd_shizai
					AND dt_shiyo = @dt_seizo
					AND no_lot_seihin = @no_lot_seihin
					AND no_lot_shikakari IS NULL
				*/				
			/*
				IF(@cnt = 0)
				BEGIN
					DELETE tr_shiyo_yojitsu
					WHERE flg_yojitsu = 1
						AND no_lot_seihin = @no_lot_seihin
						AND no_lot_shikakari IS NULL
				END
				-- �����p�g�p�g�����̍폜
				EXEC dbo.usp_GenkaShiyo_delete @no_lot_seihin, null
			END
			*/
	        
			/*******************************
				�g�p�\���g�����@�X�V
			*******************************/
			/*
			-- �m��@���@�������ѐ��ɕύX�̂������f�[�^�̂ݍs��
			IF (@flg_jisseki_old = 1 AND @flg_jisseki = 1 AND @cd_shizai IS NOT NULL AND @cd_shizai <> '')
			BEGIN
				-- �폜
				IF (@cnt = 0)
				BEGIN
					DELETE tr_shiyo_yojitsu
				WHERE
					flg_yojitsu = 1
					AND dt_shiyo = @dt_seizo
					AND no_lot_seihin = @no_lot_seihin
					AND no_lot_shikakari IS NULL
				END

				-- �g�p�\���@�̔ԏ���
				EXEC dbo.usp_cm_Saiban @ShiyoYojitsuSeqNoSaibanKbn, @ShiyoYojitsuSeqNoPrefixSaibanKbn,
				@no_saiban = @no_seq output

				-- �V�K�o�^
				INSERT INTO tr_shiyo_yojitsu (
					no_seq
					,flg_yojitsu
					,cd_hinmei
					,dt_shiyo
					,no_lot_seihin
					,no_lot_shikakari
					,su_shiyo
				) VALUES (
					@no_seq
					,@JissekiYojitsuFlag
					,@cd_shizai
					,@dt_seizo
					,@no_lot_seihin
					,NULL
					--,(@su_seizo_jisseki * @su_shiyo_shizai) -- �g�p��
					,@su_shiyo
				)
			END
			SET @cnt = @cnt + 1
			*/
			FETCH NEXT FROM ichiran_cd_shizai INTO @cd_shizai, @su_shiyo_shizai
		END
		
	CLOSE ichiran_cd_shizai
	BEGIN
		DEALLOCATE ichiran_cd_shizai
	END

	IF @isUpdateAnbun = 1
	BEGIN
		UPDATE tr_sap_shiyo_yojitsu_anbun
		SET kbn_jotai_denso = @midensoDensoKubun
		WHERE
			no_lot_seihin = @no_lot_seihin
	END
	
	-- �d�����эX�V�敪��1�i�X�V�j���A�����������у`�F�b�N���ύX���ꂽ�ꍇ�͎d�����т��X�V����B
	IF (
			@kbn_shikomi_jisseki_update = 1
			AND (
					(@su_seizo_jisseki <> @su_seizo_jisseki_old)
				 OR (@flg_jisseki <> @flg_jisseki_old)
				)
		)
	BEGIN
		IF @flg_jisseki = 0
		BEGIN
			SET @su_seizo_jisseki = 0
		END
		-- �d�����т̍X�V���s��
		EXEC usp_SeizoNippoShikomiJisseki_update
				@dt_seizo
				, @cd_hinmei
				, @no_lot_seihin
				, @su_seizo_jisseki
	END

END





















GO
