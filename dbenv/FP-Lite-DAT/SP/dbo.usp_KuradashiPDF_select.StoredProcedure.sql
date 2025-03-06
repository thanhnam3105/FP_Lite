IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_KuradashiPDF_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_KuradashiPDF_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�ړ��o�ɉ�ʁ@�ɏo��MPDF
�t�@�C����	�Fusp_KuradashiPDF_select
�쐬��		�F2014.11.06  ADMAX endo.y
�X�V��		�F2015.07.29  ADMAX tsujita.s
*****************************************************/
CREATE PROCEDURE [dbo].[usp_KuradashiPDF_select]
	@dt_search		DATETIME	-- ��������/�o�ɓ�
	,@hinKbn		SMALLINT	-- ��������/�i�敪
	,@kbnShukko		SMALLINT	-- ���o�ɋ敪.�o��
	,@flg_mishiyo	SMALLINT	-- ���g�p�t���O.�g�p
	,@flg_kakutei	SMALLINT	-- �m��t���O.�m��
	,@sumiJusin		SMALLINT	-- ��M�敪.��M��
	,@cd_niuke_basho VARCHAR(10)-- ��������/�׎�ꏊ
	,@cd_bunrui		VARCHAR(10)	-- ��������/����
	,@cd_hinmei		VARCHAR(MAX)-- ����Ώۂ̕i���R�[�h
	,@flg_true		SMALLINT	-- �t���OON
	,@print_status	VARCHAR(1)	--��������/����X�e�[�^�X
AS
BEGIN
	SET NOCOUNT ON

	-- ��������/����X�e�[�^�X�̐ݒ�
	DECLARE @st_print SMALLINT
	IF LEN(@print_status) > 0
	BEGIN
		SET @st_print = CAST(@print_status AS SMALLINT)
	END

	-- ////////////////////////////////////////////
	--  ����t���O�̍X�V
	-- ////////////////////////////////////////////
	UPDATE tr_niuke
	SET flg_print = @flg_true
	FROM
		tr_niuke tn
	INNER JOIN ma_hinmei mh
		ON tn.cd_hinmei = mh.cd_hinmei
			AND mh.flg_mishiyo = @flg_mishiyo
			AND mh.kbn_hin = @hinKbn
	LEFT JOIN (
		SELECT 
			no_niuke
			,no_seq
			,dt_niuke
			,tm_nonyu_jitsu
		FROM tr_niuke
		) tn1
		ON tn.no_niuke = tn1.no_niuke
			AND tn1.no_seq = 1
	LEFT JOIN ma_location ml
		ON mh.cd_location = ml.cd_location
		AND ml.flg_mishiyo = @flg_mishiyo
	WHERE 
		tn.kbn_nyushukko = @kbnShukko
			AND tn.dt_niuke = @dt_search
			AND (( @cd_niuke_basho = '') OR (tn.cd_niuke_basho = @cd_niuke_basho))
			AND (( @cd_bunrui = '') OR (mh.cd_bunrui = @cd_bunrui))
			AND (LEN(@cd_hinmei) = 0 OR tn.cd_hinmei IN (SELECT id FROM udf_SplitCommaValue(@cd_hinmei)))
			AND (LEN(@print_status) = 0 OR ISNULL(tn.flg_print, @flg_mishiyo) = @st_print)

	-- ////////////////////////////////////////////
	--  ����Ώۂ̒��o(���o�����͏�LUPDATE�Ɠ���)
	-- ////////////////////////////////////////////
	SELECT
		tn.cd_hinmei AS cd_hinmei
		,ISNULL(mh.nm_hinmei_ryaku, '') AS nm_hinmei_ryaku
		,ISNULL(mh.nm_hinmei_ja, '') AS nm_hinmei_ja
		,ISNULL(mh.nm_hinmei_en, '') AS nm_hinmei_en
		,ISNULL(mh.nm_hinmei_zh, '') AS nm_hinmei_zh
		,ISNULL(mh.nm_hinmei_vi, '') AS nm_hinmei_vi
		,ISNULL(mh.nm_nisugata_hyoji, '') AS nm_nisugata
		,tn.su_shukko AS su_irai
		,tn.su_shukko_hasu AS su_irai_hasu
		,tn.su_zaiko AS su_zaiko
		,tn.su_zaiko_hasu AS su_zaiko_hasu
		,tn.no_lot AS no_lot
		,tn.dt_kigen AS dt_kigen
		,ml.nm_location AS nm_location
		,tn.no_niuke
		,tn.kbn_zaiko
		,tn.no_seq
		,tn.flg_print
	FROM
		tr_niuke tn
	INNER JOIN ma_hinmei mh
		ON tn.cd_hinmei = mh.cd_hinmei
			AND mh.flg_mishiyo = @flg_mishiyo
			AND mh.kbn_hin = @hinKbn
	LEFT JOIN (
		SELECT 
			no_niuke
			,no_seq
			,dt_niuke
			,tm_nonyu_jitsu
		FROM tr_niuke
		) tn1
		ON tn.no_niuke = tn1.no_niuke
			AND tn1.no_seq = 1
	LEFT JOIN ma_location ml
		ON mh.cd_location = ml.cd_location
		AND ml.flg_mishiyo = @flg_mishiyo
	WHERE 
		tn.kbn_nyushukko = @kbnShukko
			AND tn.dt_niuke = @dt_search
			AND (( @cd_niuke_basho = '') OR (tn.cd_niuke_basho = @cd_niuke_basho))
			AND (( @cd_bunrui = '') OR (mh.cd_bunrui = @cd_bunrui))
			AND (LEN(@cd_hinmei) = 0 OR tn.cd_hinmei IN (SELECT id FROM udf_SplitCommaValue(@cd_hinmei)))
			AND (LEN(@print_status) = 0 OR ISNULL(tn.flg_print, @flg_mishiyo) = @st_print)
	ORDER BY 
		tn.cd_hinmei
		,tn.dt_kigen
		,tn1.dt_niuke
		,tn1.tm_nonyu_jitsu

END
GO
