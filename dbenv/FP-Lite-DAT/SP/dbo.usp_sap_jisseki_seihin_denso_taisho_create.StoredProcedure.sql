IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_seihin_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���i���ё��M�Ώۃe�[�u���쐬����
�t�@�C����	�Fusp_sap_jisseki_seihin_denso_taisho_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.07 kaneko.m
�X�V��      �F2015.10.07 ADMAX taira.s �i���}�X�^.�e�X�g�i=1�̃f�[�^����荞�܂Ȃ��悤�ɏC��
�X�V��      �F2015.12.01 ADMAX kakuta.y ���уf�[�^�̔��f���t���O�ɓ���B���M�Ώۍi�荞�ݎ��Ƀt���O�ōi��̂ŁA����ȍ~�̏����Ńt���O���݂Ȃ��悤�ɏC���B
�X�V���@�@�@�F2016.01.04 Hirai.a �����̓��t��60���ɓ���
�X�V���@�@�@�F2024.02.05 Echigo.r �H��R�[�h���ʏ����ǉ��iTN�H��ǉ��Ή��j
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_seihin_denso_taisho_create] 
	@createFlag smallint
	,@updateFlag smallint
	,@deleteFlag smallint
	,@kbnJikagen smallint
	,@flgJisseki smallint
AS
BEGIN

	-- �H��R�[�h�̎擾
	DECLARE @cd_kojo VARCHAR(13)
	SET @cd_kojo = (SELECT TOP 1 cd_kojo FROM ma_kojo)

	--�R�s�[�����p���t�i�V�X�e������ - 60���j
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())

	-- �捞�����F���i���ё��M�Ώ� �e�[�u����trancate
	TRUNCATE TABLE tr_sap_jisseki_seihin_denso_taisho

	-- �捞�����F���i�v��g�����𐻕i���ё��M�Ώۃe�[�u����INSERT
	INSERT INTO tr_sap_jisseki_seihin_denso_taisho (
		no_lot_seihin
		,dt_seizo
		,cd_shokuba
		,cd_line
		,cd_hinmei
		,su_seizo_yotei
		,su_seizo_jisseki
		,flg_jisseki
		,kbn_denso
		,flg_denso
		,dt_update
		,su_batch_keikaku
		,su_batch_jisseki
		,dt_shomi
		,no_lot_hyoji
	)
		 SELECT
				no_lot_seihin
			   ,dt_seizo
			   ,cd_shokuba
			   ,cd_line
			   ,tks.cd_hinmei
			   ,su_seizo_yotei
			   ,su_seizo_jisseki
			   ,flg_jisseki
			   ,kbn_denso
			   ,flg_denso
			   ,tks.dt_update
			   ,su_batch_keikaku
			   ,su_batch_jisseki
			   ,dt_shomi
			   ,no_lot_hyoji
		 FROM tr_keikaku_seihin tks
		 LEFT JOIN ma_hinmei mh
		    ON tks.cd_hinmei = mh.cd_hinmei
		 WHERE
			tks.flg_jisseki = @flgJisseki
			AND tks.dt_seizo > @dateTaisho
			AND ISNULL(mh.flg_testitem, 0) <> 1

	-- ���M�f�[�^���o�F���i���ђ��o�e�[�u����TRUNCATE
	TRUNCATE TABLE tr_sap_jisseki_seihin_denso
	
	--�O��f�[�^����3�����O���폜
	DELETE tr_sap_jisseki_seihin_denso_taisho_zen
	WHERE dt_seizo <= @dateTaisho

	-- ���M�f�[�^���o�F���i���ђ��o�e�[�u���ւ�INSERT
	INSERT INTO tr_sap_jisseki_seihin_denso (
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,dt_shomi
		,cd_kojo
		,cd_hinmei
		,su_seizo_jisseki
		,cd_tani_SAP
		,no_lot_hyoji
	)
		-- ���M�f�[�^���o�F�V�K�f�[�^���o
		SELECT
			@createFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_seizo_jisseki
			,mst.cd_tani_henkan
			,taisho.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho taisho
		LEFT JOIN tr_sap_jisseki_seihin_denso_taisho_zen zen
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.flg_jisseki = zen.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE zen.no_lot_seihin is null

		-- ���M�f�[�^���o�F�X�V�f�[�^���o�i�ԁj
		UNION ALL
		SELECT
			@deleteFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(zen.cd_hinmei) AS cd_hinmei
			,zen.su_seizo_jisseki
			,mst.cd_tani_henkan
			,zen.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho taisho
		INNER JOIN tr_sap_jisseki_seihin_denso_taisho_zen zen
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.flg_jisseki = zen.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE (taisho.su_seizo_jisseki <> zen.su_seizo_jisseki 
				OR taisho.dt_shomi <> zen.dt_shomi
				OR COALESCE(taisho.no_lot_hyoji, '') <> COALESCE(zen.no_lot_hyoji, ''))

		-- ���M�f�[�^���o�F�X�V�f�[�^���o�i���j
		UNION ALL
		SELECT
			@createFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,taisho.su_seizo_jisseki
			,mst.cd_tani_henkan
			,taisho.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho taisho
		INNER JOIN tr_sap_jisseki_seihin_denso_taisho_zen zen
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.flg_jisseki = zen.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE (taisho.su_seizo_jisseki <> zen.su_seizo_jisseki
				OR taisho.dt_shomi <> zen.dt_shomi
				OR COALESCE(taisho.no_lot_hyoji, '') <> COALESCE(zen.no_lot_hyoji, ''))

		-- ���M�f�[�^���o�F�폜�f�[�^���o
		UNION ALL
		SELECT
			@deleteFlag AS kbn_denso_SAP
			,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
				SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_seizo, 112)) AS dt_seizo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_shomi, 112)) AS dt_shomi
			,@cd_kojo AS cd_kojo
			,UPPER(zen.cd_hinmei) AS cd_hinmei
			,zen.su_seizo_jisseki
			,mst.cd_tani_henkan
			,zen.no_lot_hyoji
		FROM tr_sap_jisseki_seihin_denso_taisho_zen zen
		LEFT JOIN tr_sap_jisseki_seihin_denso_taisho taisho
			ON zen.no_lot_seihin = taisho.no_lot_seihin
			AND zen.flg_jisseki = taisho.flg_jisseki
		LEFT JOIN ma_hinmei mh
			ON zen.cd_hinmei = mh.cd_hinmei
		LEFT JOIN ma_sap_tani_henkan mst
			ON mh.cd_tani_nonyu = mst.cd_tani
		WHERE taisho.no_lot_seihin is null
			AND zen.flg_jisseki = @flgJisseki
END

GO
