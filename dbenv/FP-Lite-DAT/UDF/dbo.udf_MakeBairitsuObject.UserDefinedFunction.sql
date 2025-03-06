IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_MakeBairitsuObject') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_MakeBairitsuObject]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\  �F���V�s�W�J�����x���p�F�o�b�`���Ɣ{���̌v�Z
�t�@�C���� �Fudf_MakeBairitsuObject
���͈��� �F@hitsuyoJuryo, @gokeiHaigoJuryo, @kihonBairitsu
�o�͈��� �F-
�߂�l  �F@table_bairitsu_obj
�쐬��  �F2015.02.09 tsujita.s
�X�V��  �F2015.02.10 tsujita.s
�X�V��  �F2019.07.02 kanehira
�X�V��  �F2021.05.31 BRC.saito #1323�Ή�
*****************************************************/
CREATE FUNCTION [dbo].[udf_MakeBairitsuObject]
	(
		@hitsuyoJuryo decimal(38, 19) -- �����\��ʁA�K�v�d��
		,@gokeiHaigoJuryo decimal(12, 6) -- �z�����}�X�^�D���v�d��
		,@kihonBairitsu decimal(5, 2) -- �z�����}�X�^�D��{�{��
	)
-- �߂�e�[�u��
RETURNS @table_bairitsu_obj TABLE
    (
		batch decimal(12, 6) -- �o�b�`��
		,batch_hasu decimal(12, 6) -- �o�b�`�[��
		,bairitsu decimal(12, 6) -- �{��
		,bairitsu_hasu decimal(12, 6) -- �{���[��
    )
AS
	BEGIN
		DECLARE @val_batch decimal(12, 6) = 0		-- �o�b�`��
		DECLARE @val_batch_hasu decimal(12, 6) = 0	-- �o�b�`�[��
		DECLARE @val_bairitsu decimal(12, 6) = 0	-- �{��
		DECLARE @val_bairitsu_hasu decimal(12, 6) = 0	-- �{���[��
		DECLARE @val_su_seizo decimal(12, 6) = 0	-- �l����p
		DECLARE @wt_haigo_keikaku_hasu decimal(12, 6) = 0	-- �v��z���d�ʒ[��


		IF  @kihonBairitsu <= 0
		BEGIN
			-- ///// ���Z����l��0(��{�{����0)�ɂȂ�ꍇ1 /////
			SET @val_batch = 1
			SET @val_bairitsu = 1
		END
		ELSE BEGIN
			SET @val_su_seizo = (@hitsuyoJuryo / (@gokeiHaigoJuryo * @kihonBairitsu))
			-- ///// �����\�萔 / (�z�����}�X�^.���v�z���d�� * �z�����}�X�^.��{�{��) �� 1 �̂Ƃ� /////
			IF @val_su_seizo >= 1
			BEGIN
				-- �o�b�`���Ɣ{��
				SET @val_batch = ROUND(@val_su_seizo, 0, 1)
				SET @val_bairitsu = @kihonBairitsu
				
				-- �v��z���d�ʒ[��
				SET @wt_haigo_keikaku_hasu = @hitsuyoJuryo - (@gokeiHaigoJuryo * @val_bairitsu * @val_batch)
				
				-- �{���[��
				SET @val_bairitsu_hasu = 
					--CEILING (
						--(@wt_haigo_keikaku_hasu / @gokeiHaigoJuryo) * 1000000
					--) / 1000000
					CEILING (
						(@wt_haigo_keikaku_hasu / @gokeiHaigoJuryo) * 100
					) / 100
				
				-- �o�b�`�[��
				-- �v��z���d�ʒ[�������݂���ꍇ1�A���݂��Ȃ��ꍇ��0
				IF @wt_haigo_keikaku_hasu > 0
				BEGIN
					SET @val_batch_hasu = 1
				END
				
				-- ���K�{���ƒ[���{�����������ꍇ
				-- ���K�o�b�`���ɒ[���o�b�`�������Z����
				IF @val_bairitsu = @val_bairitsu_hasu
				BEGIN
					SET @val_batch = @val_batch + @val_bairitsu_hasu
					SET @val_bairitsu_hasu = 0
					SET @val_batch_hasu = 0
				END
				
			END
			-- ///// �����\�萔 / (�z�����}�X�^.���v�z���d�� * �z�����}�X�^.��{�{��) �� 1 �̂Ƃ� /////
			ELSE BEGIN
				-- �o�b�`���i�o�b�`�[���Ɣ{���[����0�j
				SET @val_batch = 1
				-- �{��
				-- calcKeikakuBairitsu = Math.Ceiling(data.hitsuyoJuryo / (gokeiHaigoJuryo * keikakuBatchSu) * 100m) / 100m;
				--SET @val_bairitsu = CEILING(@val_su_seizo * 1000000) / 1000000
				--SET @val_bairitsu = CEILING(@hitsuyoJuryo / (@gokeiHaigoJuryo * @val_batch) * 100) / 100
				SET @val_bairitsu = CEILING((ROUND(@hitsuyoJuryo / (@gokeiHaigoJuryo * @val_batch) * 10000 ,0) / 10000) * 10000) / 10000
			END
		END

        -- �߂�e�[�u���֔{���I�u�W�F�N�g��ǉ�
		INSERT INTO @table_bairitsu_obj
        SELECT
            @val_batch
            ,@val_batch_hasu
            ,@val_bairitsu
            ,@val_bairitsu_hasu

	RETURN
	END
GO
