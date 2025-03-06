IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_keikaku_seihin_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_create]
GOSET ANSI_NULLS ON
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F���i�v�摗�M�Ώۃe�[�u���捞����
�t�@�C����	�Fusp_sap_keikaku_seihin_denso_taisho_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.07 ADMAX endo.y
�X�V��      �F2015.10.07 ADMAX taira.s �i���}�X�^.�e�X�g�i=1�̃f�[�^����荞�܂Ȃ��悤�ɏC��
�X�V���@�@�@�F2016.01.04 Hirai.a �����̓��t��60���ɓ���
�X�V���@�@�@�F2017.01.04 BRC cho.k �����\�萔�O�𑗐M�ΏۊO��
�X�V���@�@�@�F2022.01.04 BRC Sato.t ���M�Ώۃe�[�u���̒��o�����ɐ����\�萔��0�ȊO��ǉ�
�X�V���@�@�@�F2024.02.05 Echigo.r �H��R�[�h���ʏ����ǉ��iTN�H��ǉ��Ή��j
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_keikaku_seihin_denso_taisho_create] 
	 @kbnCreate		smallint
	,@kbnUpdate		smallint
	,@kbnDelete		smallint
	,@kbnJikagen	smallint
AS
BEGIN
	
	--�R�s�[�����p���t�i�V�X�e������ - 60���j
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())
	
	-- ���i�v�摗�M�Ώۃe�[�u���̍폜
	TRUNCATE TABLE tr_sap_keikaku_seihin_denso_taisho

	-- ���i�v��g�����̃f�[�^�𐻕i�v�摗�M�Ώۃe�[�u���ɃR�s�[
	INSERT INTO tr_sap_keikaku_seihin_denso_taisho (
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
	FROM tr_keikaku_seihin tks
	LEFT JOIN ma_hinmei mh
		ON tks.cd_hinmei = mh.cd_hinmei
	WHERE tks.su_seizo_yotei is not null
		AND tks.su_seizo_yotei <> 0
		AND tks.dt_seizo > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1
	
	-- ���i�v�撊�o�e�[�u���̍폜
	TRUNCATE TABLE tr_sap_keikaku_seihin_denso
	
	--�O��f�[�^����3�����O���폜
	DELETE tr_sap_keikaku_seihin_denso_taisho_zen
	WHERE dt_seizo <= @dateTaisho
	
	-- ���M�f�[�^�̒��o�y�ъi�[
	INSERT INTO tr_sap_keikaku_seihin_denso (
		kbn_denso_SAP
		,no_lot_seihin
		,dt_seizo
		,cd_kojo
		,cd_hinmei
		,su_seizo_keikaku
		,cd_tani_SAP
	)
	--�ǉ��f�[�^���o
	SELECT
		@kbnCreate
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin,4,10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_seizo,112))
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_seizo_yotei
		,mst.cd_tani_henkan
	FROM tr_sap_keikaku_seihin_denso_taisho taisho
	LEFT JOIN tr_sap_keikaku_seihin_denso_taisho_zen zen
		ON taisho.no_lot_seihin = zen.no_lot_seihin
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_nonyu = mst.cd_tani
	WHERE zen.no_lot_seihin is null
		AND taisho.su_seizo_yotei is not null
	
	--�X�V�f�[�^���o
	UNION ALL
	SELECT 
		@kbnUpdate
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin,4,10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_seizo,112))
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_seizo_yotei
		,mst.cd_tani_henkan
	FROM tr_sap_keikaku_seihin_denso_taisho taisho
	INNER JOIN tr_sap_keikaku_seihin_denso_taisho_zen zen
		ON taisho.no_lot_seihin = zen.no_lot_seihin
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_nonyu = mst.cd_tani
	WHERE taisho.su_seizo_yotei <> zen.su_seizo_yotei
	
	--�폜�f�[�^���o
	UNION ALL
	SELECT 
		@kbnDelete
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END+ 
			SUBSTRING(zen.no_lot_seihin,4,10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_seizo,112))
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_seizo_yotei
		,mst.cd_tani_henkan
	FROM tr_sap_keikaku_seihin_denso_taisho_zen zen
	LEFT JOIN tr_sap_keikaku_seihin_denso_taisho taisho
		ON zen.no_lot_seihin = taisho.no_lot_seihin
	LEFT JOIN ma_hinmei mh
		ON zen.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_nonyu = mst.cd_tani
	WHERE taisho.no_lot_seihin is null
		AND zen.su_seizo_yotei is not null
END
GO
