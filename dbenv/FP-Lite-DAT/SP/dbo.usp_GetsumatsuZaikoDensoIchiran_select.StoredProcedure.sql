IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GetsumatsuZaikoDensoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GetsumatsuZaikoDensoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�����݌ɓ`���ꗗ�̌�������
�t�@�C����	�F[usp_GetsumatsuZaikoDensoIchiran_select]
�쐬��		�F2015.03.13 endo.y
�X�V��      �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_GetsumatsuZaikoDensoIchiran_select] 
	@dt_denso_from DATETIME		-- ���������F�`����_�J�n��
	,@dt_denso_to DATETIME		-- ���������F�`����_�I����
	,@dt_zaiko_from DATETIME	-- ���������F������_�J�n��
	,@dt_zaiko_to DATETIME		-- ���������F������_�I����
	,@cd_hinmei VARCHAR(14)		-- ���������F���i�R�[�h
	,@chk_denso SMALLINT		-- ���������F�`�����`�F�b�N�{�b�N�X
	,@chk_zaiko SMALLINT		-- ���������F�������`�F�b�N�{�b�N�X
	,@chk_off SMALLINT			-- �萔�F�`�F�b�N�{�b�N�X��OFF�̂Ƃ��̒l
	,@kbn_zaiko SMALLINT		-- ���������F�݌ɋ敪
	,@zaiko_off SMALLINT		-- �萔�F���W�I�{�^���������̂Ƃ��̒l
AS
BEGIN
    WITH cte_pool AS
    (
	select 
		sap.dt_denso
		,sap.kbn_denso_SAP
		,CONVERT(DATETIME, CONVERT(VARCHAR, sap.dt_tanaoroshi) + ' 10:00:00', 112) dt_tanaoroshi
		,sap.cd_hinmei
		,mh.nm_hinmei_ja
		,mh.nm_hinmei_en
		,mh.nm_hinmei_zh
		,mh.nm_hinmei_vi
		,sap.hokan_basho
		,ms.nm_soko
		,msth.cd_tani
		,mt.nm_tani
		,sap.su_tanaoroshi
		,sap.kbn_zaiko
		,mkz.nm_kbn_zaiko
	FROM tr_sap_getsumatsu_zaiko_denso_pool sap
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = sap.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan msth
		ON msth.cd_tani_henkan = sap.cd_tani
	LEFT JOIN ma_tani mt
		ON mt.cd_tani = msth.cd_tani
	LEFT JOIN ma_soko ms
		ON ms.cd_soko = sap.hokan_basho
	LEFT JOIN ma_kbn_zaiko mkz
		ON mkz.kbn_zaiko = sap.kbn_zaiko
	)
	
	SELECT
		dt_denso
		,kbn_denso_SAP
		,dt_tanaoroshi
		,cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,hokan_basho
		,nm_soko
		,cd_tani
		,nm_tani
		,su_tanaoroshi
		,nm_kbn_zaiko
	FROM
		cte_pool
	WHERE
		(@chk_denso = @chk_off OR dt_denso BETWEEN @dt_denso_from AND @dt_denso_to)
	AND (@chk_zaiko = @chk_off OR dt_tanaoroshi BETWEEN @dt_zaiko_from AND @dt_zaiko_to)
	AND (LEN(@cd_hinmei) = 0 OR cd_hinmei = @cd_hinmei)
	AND (@kbn_zaiko = @zaiko_off OR kbn_zaiko = @kbn_zaiko)

	ORDER BY
		dt_denso DESC, cd_hinmei, kbn_denso_SAP DESC
END
GO
