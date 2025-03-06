IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ZaikoChoseiDensoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ZaikoChoseiDensoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�݌ɒ����`���ꗗ�̌�������
�t�@�C����	�F[usp_ZaikoChoseiDensoIchiran_select]
�쐬��		�F2015.03.16 endo.y
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_ZaikoChoseiDensoIchiran_select] 
	@dt_denso_from DATETIME		-- ���������F�`����_�J�n��
	,@dt_denso_to DATETIME		-- ���������F�`����_�I����
	,@dt_tenki_from DATETIME	-- ���������F�]�L��_�J�n��
	,@dt_tenki_to DATETIME		-- ���������F�]�L_�I����
	,@cd_hinmei VARCHAR(14)		-- ���������F�i���R�[�h
	,@chk_denso SMALLINT		-- ���������F�`�����`�F�b�N�{�b�N�X
	,@chk_tenki SMALLINT		-- ���������F�]�L���`�F�b�N�{�b�N�X
	,@chk_off SMALLINT			-- �萔�F�`�F�b�N�{�b�N�X��OFF�̂Ƃ��̒l
AS
BEGIN
    WITH cte_pool AS
    (
		select 
			sap.dt_denso
			,sap.kbn_denso_SAP
			--,sap.dt_hizuke
			,CONVERT(DATETIME, CONVERT(VARCHAR, sap.dt_hizuke) + ' 10:00:00', 112) dt_hizuke
			,sap.cd_soko
			,ms.nm_soko
			,sap.cd_genka_center
			,mgc.nm_genka_center
			,msrt.cd_riyu
			,msrt.nm_riyu
			,sap.cd_hinmei
			,mh.nm_hinmei_ja
			,mh.nm_hinmei_en
			,mh.nm_hinmei_zh
			,mh.nm_hinmei_vi
			,sap.su_chosei
			,sap.cd_tani_SAP
			,mt.nm_tani
			--,sap.dt_denpyo
			,CONVERT(DATETIME, CONVERT(VARCHAR, sap.dt_denpyo) + ' 10:00:00', 112) dt_denpyo
			,sap.kbn_ido
		from tr_sap_chosei_zaiko_denso_pool sap
		left join ma_hinmei mh
		on sap.cd_hinmei = mh.cd_hinmei
		left join ma_soko ms
		on sap.cd_soko = ms.cd_soko
		left join ma_sap_tani_henkan msth
		on sap.cd_tani_SAP = msth.cd_tani_henkan
		left join ma_tani mt
		on msth.cd_tani = mt.cd_tani
		left join ma_genka_center mgc
		on sap.cd_genka_center = mgc.cd_genka_center
		left join ma_sap_riyu_torikeshi msrt
		on sap.cd_riyu = msrt.cd_riyu_torikeshi
		--left join ma_riyu mr
		--on sap.cd_riyu = mr.cd_riyu
	)
	
	SELECT
			dt_denso
			,kbn_denso_SAP
			,dt_hizuke AS dt_tenki
			,cd_soko
			,nm_soko
			,cd_genka_center
			,nm_genka_center
			,cd_riyu
			,nm_riyu
			,cd_hinmei
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,su_chosei
			,cd_tani_SAP AS cd_tani
			,nm_tani
			,dt_denpyo
			,kbn_ido
	FROM
		cte_pool
	WHERE
		(@chk_denso = @chk_off OR dt_denso BETWEEN @dt_denso_from AND @dt_denso_to)
	AND (@chk_tenki = @chk_off OR dt_hizuke BETWEEN @dt_tenki_from AND @dt_tenki_to)
	AND (LEN(@cd_hinmei) = 0 OR cd_hinmei = @cd_hinmei)

	ORDER BY
		dt_denso DESC,cd_hinmei,kbn_denso_SAP DESC
END
GO
