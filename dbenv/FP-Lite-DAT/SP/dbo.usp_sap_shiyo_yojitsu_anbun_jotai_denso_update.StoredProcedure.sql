IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_shiyo_yojitsu_anbun_jotai_denso_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_shiyo_yojitsu_anbun_jotai_denso_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�g�p�\�����g�����`����ԍX�V����
�t�@�C����	�Fusp_sap_shiyo_yojitsu_anbun_jotai_denso_update
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.07.13 kaneko.m
�X�V��      �F2015.12.22 ADMAX s.shibao �c���т̍X�V�p�����ǉ�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_shiyo_yojitsu_anbun_jotai_denso_update]
	@kbnShiyoJissekiAnbun	VARCHAR(10)
	,@kbnDensoJotaiBefore	SMALLINT
	,@kbnDensoJotaiAfter	SMALLINT
AS
BEGIN
	IF @kbnShiyoJissekiAnbun = '1'
	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbnDensoJotaiAfter
	WHERE EXISTS (
		SELECT 1 FROM wk_sap_shiyo_yojitsu_anbun_seizo wk
		WHERE
			wk.no_seq = tr_sap_shiyo_yojitsu_anbun.no_seq
			AND wk.no_lot_shikakari = tr_sap_shiyo_yojitsu_anbun.no_lot_shikakari
			AND wk.kbn_shiyo_jisseki_anbun = @kbnShiyoJissekiAnbun
			AND wk.kbn_jotai_denso = @kbnDensoJotaiBefore
	)
	ELSE IF @kbnShiyoJissekiAnbun = '2'
	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbnDensoJotaiAfter
	WHERE EXISTS (
		SELECT 1 FROM wk_sap_shiyo_yojitsu_anbun_chosei wk
		WHERE
			wk.no_seq = tr_sap_shiyo_yojitsu_anbun.no_seq
			AND wk.no_lot_shikakari = tr_sap_shiyo_yojitsu_anbun.no_lot_shikakari
			AND wk.kbn_shiyo_jisseki_anbun = @kbnShiyoJissekiAnbun
			AND wk.kbn_jotai_denso = @kbnDensoJotaiBefore
	)
	ELSE IF @kbnShiyoJissekiAnbun = '3'
	UPDATE
		tr_sap_shiyo_yojitsu_anbun
	SET
		kbn_jotai_denso = @kbnDensoJotaiAfter
	WHERE EXISTS (
		SELECT 1 FROM wk_sap_shiyo_yojitsu_anbun_seizo wk
		WHERE
			wk.no_seq = tr_sap_shiyo_yojitsu_anbun.no_seq
			AND wk.no_lot_shikakari = tr_sap_shiyo_yojitsu_anbun.no_lot_shikakari
			AND wk.kbn_shiyo_jisseki_anbun = @kbnShiyoJissekiAnbun
			AND wk.kbn_jotai_denso = @kbnDensoJotaiBefore
	)

END
GO
