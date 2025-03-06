IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShikakarihinKeikaku_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShikakarihinKeikaku_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.03.12>
-- Last update: 2015.01.15 tsujita.s
-- Description:	���Ԏd�|�i�v��̍폜����
-- =============================================
CREATE PROCEDURE [dbo].[usp_ShikakarihinKeikaku_delete]
    @no_lot			varchar(14)		-- �폜�Ώۂ̎d�|�i���b�g�ԍ�
    ,@cd_shikakari	varchar(14)		-- �폜�Ώۂ̎d�|�i�R�[�h
    ,@cd_shokuba	varchar(10)		-- �폜�Ώۂ̐E��R�[�h
    ,@cd_line		varchar(10)		-- �폜�Ώۂ̃��C���R�[�h
	,@dt_seizo		DATETIME		-- �폜�Ώۂ̐�����
	,@wt_shikomi	DECIMAL(12,6)	-- �폜�Ώۂ̌v��d���d��
	,@data_key		varchar(14)		-- �폜�Ώۂ̎d�|�i�v��g�����f�[�^�L�[
AS
BEGIN

	-- �ԋp�p�u0�v
	DECLARE @return_val DECIMAL(12,6) = 0.0

	IF @no_lot IS NOT NULL OR LEN(@no_lot) > 0
	BEGIN
		--=====================
		-- �d�|�i�g�����̍폜
		--=====================
		DELETE tr_keikaku_shikakari
		WHERE data_key = @data_key


		--========================
		-- �g�p�\���g�����̍폜
		--========================
		-- �폜�����d�|�i���b�g�ԍ����L�[�ɁA�g�p�\���g�����̃f�[�^���폜����
		DELETE tr_shiyo_yojitsu
		WHERE data_key_tr_shikakari = @data_key


		--========================
		-- �d�|�i�v��T�}���̍폜
		--========================

		-- �����ȊO�̍��Z�f�[�^���Ȃ��ꍇ�́A�T�}���Ǝg�p�\���̎��т�DELETE
		IF (select TOP 1
			tr.no_lot_shikakari
			FROM tr_keikaku_shikakari tr
			WHERE tr.no_lot_shikakari = @no_lot
			AND tr.data_key <> @data_key) IS NULL
		BEGIN
			-- �d�|�i�v��T�}��
			DELETE su_keikaku_shikakari
			WHERE no_lot_shikakari = @no_lot

			-- �g�p�\���g����
			DELETE tr_shiyo_yojitsu
			WHERE no_lot_shikakari = @no_lot

			-- �u0�v��ԋp
			SELECT @return_val AS wt_shikomi_keikaku
		END
		ELSE BEGIN
			-- �폜�����d�|�i�g�����f�[�^�̌v��d���d�ʂ̕��A�T�}���̌v��d���d�ʂ������
			UPDATE su_keikaku_shikakari
			SET wt_shikomi_keikaku = wt_shikomi_keikaku - @wt_shikomi
				,wt_hitsuyo = wt_shikomi_keikaku - @wt_shikomi
			WHERE no_lot_shikakari = @no_lot

			--==============================================
			-- �X�V��̎d�|�i�v��T�}���̌v��d���d�ʂ�ԋp
			--==============================================
			SELECT wt_shikomi_keikaku FROM su_keikaku_shikakari
			WHERE no_lot_shikakari = @no_lot
		END

	END
	ELSE BEGIN
		-- @no_lot��null�܂��͋󕶎��������ꍇ�͍폜�������s�킸�u0�v��ԋp
		SELECT @return_val AS wt_shikomi_keikaku
	END

END
GO
