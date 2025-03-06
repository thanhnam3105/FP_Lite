IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�����ޒ������́@�V�K�s�ɂ�����g�p�\�����V�[�P���X�̎擾���@
�t�@�C����  �Fusp_GenshizaiChoseiNyuryokuAnbunNoSeq_select
�쐬��      �F2015.11.30 shibao.s
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select]
	@no_lot_seihin	VARCHAR(14)		-- ���i���b�g��
AS
BEGIN
	SELECT 
		anbun.no_seq 
	FROM tr_keikaku_seihin keikaku
	LEFT OUTER JOIN tr_sap_shiyo_yojitsu_anbun anbun
	ON keikaku.no_lot_seihin = anbun.no_lot_seihin
	WHERE
		keikaku.no_lot_seihin = @no_lot_seihin
END
GO
