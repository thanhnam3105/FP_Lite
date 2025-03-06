IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenryozanHyoryoKeikaku_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����c���ʁi�v��ύX�j �������э폜����
�t�@�C����	�Fusp_GenryozanHyoryoKeikaku_delete
���͈���	�F@no_lot_kowake, @no_lot_oya
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.11.27  ADMAX shinohara.m
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenryozanHyoryoKeikaku_delete]
(
	@no_lot_kowake	VARCHAR(14)
	,@no_lot_oya	VARCHAR(14)
)
AS
BEGIN
	IF @no_lot_oya IS NULL
		OR @no_lot_oya = ''
	BEGIN
		--��ʏ����ŁA�������уg�������擾�������ɐe���b�g�������ꍇ
		DELETE FROM tr_lot
		WHERE
			no_lot_jisseki = @no_lot_kowake

		DELETE FROM tr_kowake
		WHERE
			no_lot_kowake  = @no_lot_kowake
	END
	ELSE
	--��ʏ����ŁA�������уg�������擾�������ɐe���b�g������ꍇ
	BEGIN
		--�������уg��������e���b�g���g���Ē��o
		DECLARE del_cursor CURSOR FOR
		SELECT
			no_lot_kowake
		FROM tr_kowake
		WHERE
			no_lot_oya = @no_lot_oya

		--�e�ɂԂ牺���鏬�������b�g�ԍ����J�[�\���ɒ�`
		OPEN del_cursor
		FETCH NEXT FROM del_cursor
		INTO @no_lot_kowake

		--�������уg��������폜�������J��Ԃ�
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM tr_lot
			WHERE
				no_lot_jisseki = @no_lot_kowake

			FETCH NEXT FROM del_cursor
			INTO @no_lot_kowake
		END

		--�I������
		CLOSE del_cursor
		DEALLOCATE del_cursor

		--�������уg��������e���b�g���L�[�ɍ폜
		DELETE FROM tr_kowake
		WHERE
			no_lot_oya = @no_lot_oya
	END
END
GO
