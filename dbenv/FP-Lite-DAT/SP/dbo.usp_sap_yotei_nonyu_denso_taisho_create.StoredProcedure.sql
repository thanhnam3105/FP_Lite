IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_yotei_nonyu_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�[���\�著�M�Ώۃe�[�u���捞����
�t�@�C����	�Fusp_sap_yotei_nonyu_denso_taisho_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.14 ADMAX endo.y
�X�V��      �F2015.10.07 ADMAX taira.s �i���}�X�^.�e�X�g�i=1�̃f�[�^����荞�܂Ȃ��悤�ɏC��
�X�V���@�@�@�F2016.01.04 Hirai.a �����̓��t��60���ɓ���
�X�V���@�@�@�F2018.05.18 BRC Noguchi.m �P�ʂ�null�œ`�������s����C��(�i���}�X�^����������ۂ̌����������C��)
�X�V���@�@�@�F2019.03.15 BRC Takaki.r ��ƈ˗�No.572�Ή� �i�R�[�h�ύX���ɓ`���ΏۂɂȂ�悤�C��
�X�V���@�@�@�F2019.08.02 nakamura.r �����_�ȉ��R���܂ŋ��e
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_yotei_nonyu_denso_taisho_create] 
	 @kbnCreate smallint
	,@kbnUpdate smallint
	,@kbnDelete smallint
	,@flgShiyo smallint
	,@flgHeijitsu smallint
	,@kbnJikagen	smallint
	,@flgYotei smallint
	,@cdTani_kg	varchar(2)
	,@cdTani_li	varchar(2)
	,@jisa smallint
AS
BEGIN

	--�R�s�[�����p���t�i�V�X�e������ - 60���j
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())

	-- �[���\�著�M�Ώۃe�[�u���̍폜
	TRUNCATE TABLE tr_sap_yotei_nonyu_denso_taisho

	-- �[���\���g�����̃f�[�^��[���\�著�M�Ώۃe�[�u���ɃR�s�[
	INSERT INTO tr_sap_yotei_nonyu_denso_taisho (
		flg_yojitsu
		,no_nonyu
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,su_nonyu_hasu
		,cd_torihiki
		,cd_torihiki2
		,tan_nonyu
		,kin_kingaku
		,no_nonyusho
		,kbn_zei
		,kbn_denso
		,flg_kakutei
		,dt_seizo
		,kbn_nyuko
		,cd_tani_shiyo
	)
	SELECT
		tr.flg_yojitsu
		,tr.no_nonyu
		,tr.dt_nonyu
		,tr.cd_hinmei

		-- �[���P�ʂ���g�p�P�ʂւ̕ϊ��FBIZ00009
		-- �����_��O�ʈȉ��͐؂�̂�
		,ROUND(CASE WHEN COALESCE(mk.cd_tani_nonyu, mh.cd_tani_nonyu) = @cdTani_kg
					OR COALESCE(mk.cd_tani_nonyu, mh.cd_tani_shiyo) = @cdTani_li
			 THEN tr.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
					+ (tr.su_nonyu_hasu / 1000)
			 ELSE tr.su_nonyu * COALESCE(mk.wt_nonyu, mh.wt_ko) * COALESCE(mk.su_iri, mh.su_iri) 
					+ (tr.su_nonyu_hasu * COALESCE(mk.wt_nonyu, mh.wt_ko))
			 END
		 , 3, 1)

		--,tr.su_nonyu_hasu
		,0
		,tr.cd_torihiki
		,tr.cd_torihiki2
		,tr.tan_nonyu
		,tr.kin_kingaku
		,tr.no_nonyusho
		,tr.kbn_zei
		,tr.kbn_denso
		,tr.flg_kakutei
		,tr.dt_seizo
		,tr.kbn_nyuko
		,mh.cd_tani_shiyo
	FROM tr_nonyu tr
	LEFT JOIN ma_konyu mk
		ON  tr.cd_hinmei = mk.cd_hinmei
		AND tr.cd_torihiki = mk.cd_torihiki
	LEFT JOIN ma_hinmei mh
--		ON mk.cd_hinmei = mh.cd_hinmei
		ON tr.cd_hinmei = mh.cd_hinmei
	WHERE
		tr.flg_yojitsu = @flgYotei
		AND tr.dt_nonyu > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1

	---- �[���\�蒊�o�e�[�u���̍폜
	TRUNCATE TABLE tr_sap_yotei_nonyu_denso
	
	--�O��f�[�^����3�����O���폜
	DELETE tr_sap_yotei_nonyu_denso_taisho_zen
	WHERE dt_nonyu <= @dateTaisho
	
	-- ���M�f�[�^�̒��o
    ;WITH cte_nonyu_yotei_denso AS
    (
		--�V�K�ǉ��̏ꍇ
		SELECT
			@kbnCreate AS 'kbn_denso_SAP'
			,SUBSTRING(taisho.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_nonyu, 112)) AS 'dt_nonyu'
			,taisho.cd_hinmei
			,taisho.su_nonyu
			,taisho.su_nonyu_hasu
			,taisho.cd_torihiki
			,mst.cd_tani_henkan
			,taisho.kbn_nyuko
			,taisho.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		LEFT JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.cd_hinmei = zen.cd_hinmei
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON taisho.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE zen.no_nonyu IS NULL
			AND taisho.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen
			
		UNION ALL
		--�����R�[�h�ȊO���ύX����Ă���ꍇ
		SELECT 
			@kbnUpdate AS 'kbn_denso_SAP'
			,SUBSTRING(taisho.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_nonyu, 112)) AS 'dt_nonyu'
			,taisho.cd_hinmei
			,taisho.su_nonyu
			,taisho.su_nonyu_hasu
			,taisho.cd_torihiki
			,mst.cd_tani_henkan
			,taisho.kbn_nyuko
			,taisho.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		INNER JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON taisho.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE (taisho.su_nonyu <> zen.su_nonyu
				OR taisho.kbn_nyuko <> zen.kbn_nyuko
				OR taisho.dt_nonyu <> zen.dt_nonyu
				)
			AND taisho.cd_torihiki = zen.cd_torihiki
			AND taisho.cd_hinmei = zen.cd_hinmei
			AND taisho.flg_yojitsu = @flgShiyo
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen
				
		UNION ALL
		--�����R�[�h���ύX����Ă���ꍇ(�f���[�g�C���T�[�g)
		SELECT 
			@kbnDelete AS 'kbn_denso_SAP'
			,SUBSTRING(zen.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_nonyu, 112)) AS 'dt_nonyu'
			,zen.cd_hinmei
			,zen.su_nonyu
			,zen.su_nonyu_hasu
			,zen.cd_torihiki
			,mst.cd_tani_henkan
			,zen.kbn_nyuko
			,zen.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		INNER JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON zen.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE taisho.cd_torihiki <> zen.cd_torihiki
			AND taisho.cd_hinmei = zen.cd_hinmei
			AND taisho.flg_yojitsu = @flgShiyo
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen

		UNION ALL
		SELECT 
			@kbnCreate AS 'kbn_denso_SAP'
			,SUBSTRING(taisho.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, taisho.dt_nonyu, 112)) AS 'dt_nonyu'
			,taisho.cd_hinmei
			,taisho.su_nonyu
			,taisho.su_nonyu_hasu
			,taisho.cd_torihiki
			,mst.cd_tani_henkan
			,taisho.kbn_nyuko
			,taisho.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho taisho
		INNER JOIN tr_sap_yotei_nonyu_denso_taisho_zen zen
			ON taisho.no_nonyu = zen.no_nonyu
				AND taisho.flg_yojitsu = @flgShiyo
				AND zen.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON taisho.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON taisho.cd_hinmei = mh.cd_hinmei
		WHERE taisho.cd_torihiki <> zen.cd_torihiki
			AND taisho.cd_hinmei = zen.cd_hinmei
			AND taisho.flg_yojitsu = @flgShiyo
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen

		UNION ALL
		--�폜����Ă���ꍇ
		SELECT 
			@kbnDelete AS 'kbn_denso_SAP'
			,SUBSTRING(zen.no_nonyu, 4, 13) AS 'no_nonyu'
			,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
			,CONVERT(DECIMAL, CONVERT(NVARCHAR, zen.dt_nonyu, 112)) AS 'dt_nonyu'
			,zen.cd_hinmei
			,zen.su_nonyu
			,zen.su_nonyu_hasu
			,zen.cd_torihiki
			,mst.cd_tani_henkan
			,zen.kbn_nyuko
			,zen.cd_tani_shiyo AS 'cd_tani_shiyo'
		FROM
			tr_sap_yotei_nonyu_denso_taisho_zen zen
		LEFT JOIN tr_sap_yotei_nonyu_denso_taisho taisho
			ON zen.no_nonyu = taisho.no_nonyu
				AND zen.cd_hinmei = taisho.cd_hinmei
				AND zen.flg_yojitsu = @flgShiyo
				AND taisho.flg_yojitsu = @flgShiyo
		LEFT JOIN ma_sap_tani_henkan mst
			ON zen.cd_tani_shiyo = mst.cd_tani
		LEFT JOIN ma_hinmei mh
			ON zen.cd_hinmei = mh.cd_hinmei
		WHERE taisho.no_nonyu IS NULL
			AND zen.flg_yojitsu = @flgShiyo
			AND mh.kbn_hin <> @kbnJikagen
	)
	

	-- ���M�Ώۃf�[�^�𒊏o�e�[�u���Ɋi�[
	INSERT INTO tr_sap_yotei_nonyu_denso (
		kbn_denso_SAP
		,no_nonyu
		,cd_kojo
		,dt_nonyu
		,cd_hinmei
		,su_nonyu
		,cd_torihiki
		,cd_tani_SAP
		,kbn_nyuko
	)
	SELECT
		cte.kbn_denso_SAP
		,cte.no_nonyu
		,cte.cd_kojo
		,cte.dt_nonyu
		,UPPER(cte.cd_hinmei) AS cd_hinmei
		,cte.su_nonyu
		,cte.cd_torihiki
		,cte.cd_tani_henkan
		,cte.kbn_nyuko
	FROM
		cte_nonyu_yotei_denso cte

END
GO
