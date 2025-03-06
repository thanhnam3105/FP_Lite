IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotTrace_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotTrace_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\			�F�d��������ʁ@�g���[�X�p���b�g�g�����ō폜����
�t�@�C����		�Fusp_LotTrace_delete
���͈���		�Fno_lot_shikakari
�쐬��		�F2016.04.11  Khang
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotTrace_delete]
	@no_lot_shikakari	varchar(14)	-- �폜�����F�d�|�i���b�g�ԍ�
AS
BEGIN

	-- ���i���b�g�ԍ������݂���ꍇ�F�������񂩂�̍폜��
	IF LEN(@no_lot_shikakari) > 0
	BEGIN
		-- �d�����񂩂�̍폜���F�d�|�i���b�g�ԍ��ňꊇ�폜
		DELETE
			tr_lot_trace
		WHERE
			no_lot_shikakari = @no_lot_shikakari
	END

END
GO
