IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsuAnbunTran_delete_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Author     :	ADMAX kakuta.y
-- Create date: 2015.08.20
-- Last Update: 
-- Description: �g�p�\�����g�����̍폜�����F�����͍폜���A�����͖��쐬�ɂ���
-- =======================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete_02]
	@no_lot_seihin			VARCHAR(14)	-- ���i���b�g�ԍ�
	,@misakuseiDensoKubun	SMALLINT	-- �敪�^�R�[�h�ꗗ�D�`���敪�D���쐬
	,@seizoAnbunKubun		SMALLINT	-- �敪�^�R�[�h�ꗗ�D�g�p���ш��敪�D����
	,@choseiAnbunKubun		SMALLINT	-- �敪�^�R�[�h�ꗗ�D�g�p���ш��敪�D����
AS
BEGIN

	-- ���i���R�t���d�|�i�𖢍쐬�ɍX�V
	UPDATE tr_sap_shiyo_yojitsu_anbun
	SET kbn_jotai_denso = @misakuseiDensoKubun
	WHERE
		no_lot_shikakari IN (
									SELECT
										con.no_lot_shikakari
									FROM tr_sap_shiyo_yojitsu_anbun con
									WHERE
										con.no_lot_seihin = @no_lot_seihin
									GROUP BY con.no_lot_shikakari
								)
	;

	-- ���i���R�t���d�|�i�̐������폜
	DELETE FROM tr_sap_shiyo_yojitsu_anbun
	WHERE
		kbn_shiyo_jisseki_anbun = @seizoAnbunKubun
		AND no_lot_seihin = @no_lot_seihin
	;

END

GO
