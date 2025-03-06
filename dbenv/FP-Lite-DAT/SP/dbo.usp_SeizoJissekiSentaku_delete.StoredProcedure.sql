IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoJissekiSentaku_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoJissekiSentaku_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,inamori.h>
-- Create date: <Create Date,,2015.12.24>
-- Description:	<Description,,���i���b�g�ԍ��Ő��i�v��g�����Ǝd�|�c�g�p�\���g�����A�V�[�P���X�ԍ��Œ����g�����A�g�p�\�����V�[�P���X�Ŏd�|�c�g�p�ʃg�������폜>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentaku_delete]
	@lotNo VARCHAR(14)
	,@seqNo VARCHAR(14)
AS

-- ���i�v��g�����̍폜
DELETE FROM tr_keikaku_seihin
WHERE 
    no_lot_seihin = @lotNo
    
--�����g�����̍폜
DELETE FROM tr_chosei
WHERE
	no_lot_seihin = @lotNo

--�d�|�c�g�p�\���g�����̍폜
DELETE tr_shiyo_yojitsu
WHERE
	no_seq IN 
	(SELECT
		no_seq_shiyo_yojitsu
	FROM tr_shiyo_shikakari_zan
	WHERE 
		no_seq_shiyo_yojitsu_anbun = @seqNo
	)


--�d�|�c�g�p�ʃg�����̍폜
DELETE tr_shiyo_shikakari_zan
WHERE
	no_seq_shiyo_yojitsu_anbun = @seqNo



--
GO
