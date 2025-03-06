IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuJissekiDensoIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuJissekiDensoIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�[�����ѓ`���ꗗ�̌�������
�t�@�C����	�F[usp_NonyuJissekiDensoIchiran_select]
�쐬��		�F2015.03.16 tsujita.s
�ŏI�X�V��  �F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NonyuJissekiDensoIchiran_select] 
	@dt_denso_from DATETIME		-- ���������F�`����_�J�n��
	,@dt_denso_to DATETIME		-- ���������F�`����_�I����
	,@dt_nonyu_from DATETIME	-- ���������F�[����_�J�n��
	,@dt_nonyu_to DATETIME		-- ���������F�[����_�I����
	,@cd_hinmei VARCHAR(14)		-- ���������F�i���R�[�h
	,@no_nonyu VARCHAR(14)		-- ���������F�[���ԍ�
	,@chk_denso SMALLINT		-- ���������F�`�����`�F�b�N�{�b�N�X
	,@chk_nonyu SMALLINT		-- ���������F�[�����`�F�b�N�{�b�N�X
	,@lot_put_char VARCHAR(3)	-- �萔�F�[���ԍ��̓��ɕt�^����Prefix
	,@chk_off SMALLINT			-- �萔�F�`�F�b�N�{�b�N�X��OFF�̂Ƃ��̒l
AS
BEGIN

    WITH cte_pool AS
    (
		SELECT 
			pl.dt_denso
			,CONVERT(DATETIME, CONVERT(VARCHAR, pl.dt_nonyu) + ' 10:00:00', 112) AS 'dt_nonyu'
			,pl.kbn_denso_SAP
			,@lot_put_char + pl.no_nonyu AS no_nonyu
			,pl.cd_hinmei
			,mh.nm_hinmei_ja
			,mh.nm_hinmei_en
			,mh.nm_hinmei_zh
			,mh.nm_hinmei_vi
			,pl.cd_torihiki
			,tori.nm_torihiki
			,pl.su_nonyu_jitsu AS su_nonyu
			,mt.cd_tani
			,mt.nm_tani
			,pl.kbn_nyuko
		FROM
			tr_sap_jisseki_nonyu_denso_pool pl
		-- �i���}�X�^
		LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = pl.cd_hinmei
		-- �����}�X�^
		LEFT JOIN ma_torihiki tori
		ON pl.cd_torihiki = tori.cd_torihiki
		-- �P�ʕϊ��}�X�^
		LEFT JOIN ma_sap_tani_henkan msth
		ON pl.cd_tani_nonyu = msth.cd_tani_henkan
		-- �P�ʃ}�X�^
		LEFT JOIN ma_tani mt
		ON msth.cd_tani = mt.cd_tani
	)
	
	SELECT
		dt_denso
		,dt_nonyu
		,kbn_denso_SAP
		,no_nonyu
		,cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,cd_torihiki
		,nm_torihiki
		,su_nonyu
		,cd_tani
		,nm_tani
		,kbn_nyuko
	FROM
		cte_pool
	WHERE
		(@chk_denso = @chk_off OR dt_denso BETWEEN @dt_denso_from AND @dt_denso_to)
	AND (@chk_nonyu = @chk_off OR dt_nonyu BETWEEN @dt_nonyu_from AND @dt_nonyu_to)
	AND (LEN(@cd_hinmei) = 0 OR cd_hinmei = @cd_hinmei)
	AND (LEN(@no_nonyu) = 0 OR no_nonyu like '%' + @no_nonyu + '%')

	ORDER BY
		dt_denso DESC, cd_hinmei, dt_nonyu, no_nonyu, kbn_denso_SAP DESC
END
GO
