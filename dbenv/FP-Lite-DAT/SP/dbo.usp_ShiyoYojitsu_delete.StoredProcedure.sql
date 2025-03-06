IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsu_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsu_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================================
-- Author:		<Author,,cho.K>
-- Create date: <Create Date,,2016.11.22>
-- Description:	�g�p�\���g�����̍폜
-- ==========================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsu_delete]
    @flg_yojitsu		SMALLINT      -- �\���t���O
    ,@no_lot_shikakari	VARCHAR(14)   -- �d�|�i���b�g�ԍ�

AS

BEGIN

	-- �ǂ����NULL�̏ꍇ�́A�X�V�������s��Ȃ�
	IF (@no_lot_shikakari IS NULL)
		RETURN

	-- ========================
    --  �g�p�\���g����DELETE
	-- ========================
	DELETE FROM tr_shiyo_yojitsu
	WHERE flg_yojitsu = @flg_yojitsu
	AND no_lot_shikakari = @no_lot_shikakari

END
GO
