IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_nonyu_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�[�����ё��M�Ώۃe�[�u���쐬����
�t�@�C����	�Fusp_sap_jisseki_nonyu_denso_taisho_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.19 endo.y
�X�V��      �F2015.08.19 taira.s �[�i���ԍ��A�Ŋ֏���No.��ǉ�
�X�V��      �F2015.09.29 taira.s �[���ԍ��̎擾����[���g�����̔[���\��ԍ��ɕύX
�X�V��      �F2015.10.07 ADMAX taira.s �i���}�X�^.�e�X�g�i=1�̃f�[�^����荞�܂Ȃ��悤�ɏC��
�X�V��      �F2016.01.04 Hirai.a �����̓��t��60���ɓ���
�X�V��      �F2017.07.21 BRC Kurimoto.m [KPM�T�|�[�gNo.23] �X�V���Ɏ��ђl0�̃f�[�^���`������Ȃ��悤�ɏC��
�X�V��      �F2018.03.12 BRC cho.k �׎󊮗��t���O�𑼂̎��уf�[�^�ƕ������ē`������悤�ɏC�� 
�X�V��		�F2018.10.26 BRC kanehira.d �׎�ꏊ�R�[�h�ł͂Ȃ��q�ɃR�[�h���擾����悤�ɏC��
�X�V��      �F2018.11.26 BRC kanehira �g�p�P�ʂ�LB�ȊO�̊��ł��[�����т̌v�Z�����������悤�ɏC��
�X�V��      �F2019.08.02 nakamura.r ���ʂ������_�ȉ��R���܂ŋ��e
�X�V��      �F2020.08.26 BRC nojima ���׍폜���s���ɔ[�����т��c���Ă���f�[�^���m��f�[�^�Ƃ��ē`������悤�ɏC��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_nonyu_denso_taisho_create] 
	@kbnCreate smallint
	,@kbnUpdate smallint
	,@kbnDelete smallint
	,@flgKakutei smallint
	,@flgJisseki smallint
	,@kbnJikagen smallint
	,@kbnTani	smallint
	,@kbnTaniSyonin	smallint
	,@kbnTaniLB	smallint
	,@kbnTaniShiyo	smallint
	,@flgShiyo	smallint
	,@cdTaniKg	varchar(2)
	,@cdTaniL	varchar(2)
AS
BEGIN
	DECLARE @kinoLB SMALLINT
	SELECT @kinoLB = kbn_kino_naiyo
	FROM cn_kino_sentaku
	WHERE kbn_kino = @kbnTani
	
	--�@�\�I���D�[�����я��F�敪���擾
	DECLARE @kinoSyonin SMALLINT
	SELECT @kinoSyonin = kbn_kino_naiyo
	FROM cn_kino_sentaku
	WHERE kbn_kino = @kbnTaniSyonin
	
	-- �[�����ё��M�Ώۃe�[�u���̍폜
	TRUNCATE TABLE tr_sap_jisseki_nonyu_denso_taisho
	
	--�R�s�[�����p���t�i�V�X�e������ - 60���j
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())
	
	-- �׎�E�[���\���g�����̎��уf�[�^(���K)��[�����ё��M�Ώۃe�[�u���ɒǉ�
	INSERT INTO tr_sap_jisseki_nonyu_denso_taisho (
		no_nonyu
		,no_niuke
		,cd_kojo
		,cd_niuke_basho
		,dt_nonyu
		,cd_hinmei
		,su_nonyu_jitsu
		,cd_torihiki
		,cd_tani_nonyu
		,kbn_nyuko
		,flg_kakutei
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT 
		SUBSTRING(tno.no_nonyu_yotei,4,14) no_nonyu
		,SUBSTRING(tni.no_niuke,4,14) + '1' AS no_niuke
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		--,tni.cd_niuke_basho
		,mks.cd_soko_kbn AS cd_niuke_basho
		,tni.dt_nonyu
		,tni.cd_hinmei
		--,tni.su_nonyu_jitsu
		--,CASE WHEN mk.cd_tani_nonyu = mk.cd_tani_nonyu_hasu THEN
		,CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = COALESCE(mk.cd_tani_nonyu_hasu,mh.cd_tani_nonyu_hasu) THEN
				--CASE WHEN  @kinoLB = @kbnTaniLB AND (COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL) 
				CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL
					THEN ROUND(tni.su_nonyu_jitsu_hasu / 1000,3,1) + tni.su_nonyu_jitsu
				ELSE   tni.su_nonyu_jitsu_hasu + tni.su_nonyu_jitsu
				END
		 ELSE tni.su_nonyu_jitsu END AS su_nonyu_jitsu
		,tni.cd_torihiki
		--,mk.cd_tani_nonyu
		,COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu)
		,tni.kbn_nyuko
		,COALESCE(tn2.flg_kakutei,0)
		,ISNULL(tni.no_nohinsho,'')
		,ISNULL(tni.no_zeikan_shorui,'')
	FROM tr_niuke tni
	LEFT JOIN tr_nonyu tno
		--ON tno.dt_nonyu = tni.dt_niuke
		--AND tno.cd_hinmei = tni.cd_hinmei
		--AND tno.cd_torihiki = tni.cd_torihiki
		--AND tno.kbn_nyuko = tni.kbn_nyuko
		ON tno.no_nonyu = tni.no_nonyu
		AND tni.no_seq = 1
		AND tno.flg_yojitsu = @flgJisseki
		AND CASE WHEN @kinoSyonin = @kbnTaniShiyo THEN tni.flg_shonin ELSE @kbnTaniShiyo END = @kbnTaniShiyo
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = tni.cd_hinmei
	LEFT JOIN (
				SELECT 
					cd_hinmei
					,cd_torihiki
					,kbn_nyuko
					,MAX(no_niuke) no_niuke
					,flg_kakutei
				FROM tr_niuke
				WHERE flg_kakutei = @flgKakutei
				AND no_seq = 1
				GROUP BY cd_hinmei,cd_torihiki,kbn_nyuko,flg_kakutei,dt_niuke,no_nonyu
			) tn2
		ON tn2.no_niuke = tni.no_niuke
	LEFT JOIN ma_konyu mk
		ON tni.cd_hinmei = mk.cd_hinmei
			AND tni.cd_torihiki = mk.cd_torihiki
			--AND mk.flg_mishiyo = @flgShiyo
	LEFT JOIN ma_kbn_soko mks
		ON mh.kbn_hin = mks.kbn_hin
	WHERE tni.no_nonyu = tno.no_nonyu
		AND tno.flg_yojitsu = @flgJisseki
		AND tni.no_seq = 1
		AND tni.dt_nonyu > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1

	-- �׎�E�[���\���g�����̎��уf�[�^(�[��)��[�����ё��M�Ώۃe�[�u���ɒǉ�
	INSERT INTO tr_sap_jisseki_nonyu_denso_taisho (
		no_nonyu
		,no_niuke
		,cd_kojo
		,cd_niuke_basho
		,dt_nonyu
		,cd_hinmei
		,su_nonyu_jitsu
		,cd_torihiki
		,cd_tani_nonyu
		,kbn_nyuko
		,flg_kakutei
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT
		SUBSTRING(tno.no_nonyu_yotei,4,14) no_nonyu
		,SUBSTRING(tni.no_niuke,4,14) + '2' AS no_niuke
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		--,tni.cd_niuke_basho
		,mks.cd_soko_kbn AS cd_niuke_basho
		,tni.dt_nonyu
		,tni.cd_hinmei
		--,tni.su_nonyu_jitsu_hasu
		--,CASE WHEN  @kinoLB = @kbnTaniLB AND (COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL) 
		,CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL
				THEN ROUND(tni.su_nonyu_jitsu_hasu / 1000,2,1)
			  ELSE   tni.su_nonyu_jitsu_hasu
		 END AS su_nonyu_jitsu_hasu
		,tni.cd_torihiki
		,COALESCE(mk.cd_tani_nonyu_hasu,mh.cd_tani_nonyu_hasu,'') AS cd_tani_nonyu_hasu
		,tni.kbn_nyuko
		,COALESCE(tn2.flg_kakutei,0)
		,tni.no_nohinsho
		,tni.no_zeikan_shorui
	FROM tr_niuke tni
	LEFT JOIN tr_nonyu tno
		--ON tno.dt_nonyu = tni.dt_niuke
		--AND tno.cd_hinmei = tni.cd_hinmei
		--AND tno.cd_torihiki = tni.cd_torihiki
		--AND tno.kbn_nyuko = tni.kbn_nyuko
		ON tno.no_nonyu = tni.no_nonyu
		AND tno.flg_yojitsu = @flgJisseki
		AND CASE WHEN @kinoSyonin = @kbnTaniShiyo THEN tni.flg_shonin ELSE @kbnTaniShiyo END = @kbnTaniShiyo
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = tni.cd_hinmei
	LEFT JOIN (
				SELECT
					cd_hinmei
					,cd_torihiki
					,kbn_nyuko
					,MAX(no_niuke) no_niuke
					,flg_kakutei
				FROM tr_niuke
				WHERE flg_kakutei = @flgKakutei
					AND no_seq = 1
				GROUP BY cd_hinmei,cd_torihiki,kbn_nyuko,flg_kakutei,dt_niuke,no_nonyu
			) tn2
		ON tn2.no_niuke = tni.no_niuke
	LEFT JOIN ma_konyu mk
		ON tni.cd_hinmei = mk.cd_hinmei
			AND tni.cd_torihiki = mk.cd_torihiki
			--AND mk.flg_mishiyo = @flgShiyo
	LEFT JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = SUBSTRING(tno.no_nonyu,4,14)
			AND zen.no_niuke = SUBSTRING(tni.no_niuke,4,14) + '2'
	LEFT JOIN ma_kbn_soko mks
		ON mh.kbn_hin = mks.kbn_hin
	WHERE tni.no_nonyu = tno.no_nonyu
		AND tni.no_seq = 1
		AND tno.flg_yojitsu = @flgJisseki
		AND (zen.su_nonyu_jitsu is null 
			or (zen.su_nonyu_jitsu != 0
				--AND CASE WHEN  @kinoLB = @kbnTaniLB AND (mk.cd_tani_nonyu = @cdTaniKg OR mk.cd_tani_nonyu = @cdTaniL) 
				--AND CASE WHEN  @kinoLB = @kbnTaniLB AND (COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL) 
				AND CASE WHEN COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniKg OR COALESCE(mk.cd_tani_nonyu,mh.cd_tani_nonyu) = @cdTaniL
					THEN ROUND(tni.su_nonyu_jitsu_hasu / 1000,2,1)
					ELSE   tni.su_nonyu_jitsu_hasu
					END != 0))
		AND mk.cd_tani_nonyu <> mk.cd_tani_nonyu_hasu
		AND tni.dt_nonyu > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1
		
	-- ���M�f�[�^���o�F�[�����ђ��o�e�[�u����TRUNCATE
	TRUNCATE TABLE tr_sap_jisseki_nonyu_denso
	
	--�O��f�[�^����3�����O���폜
	DELETE tr_sap_jisseki_nonyu_denso_taisho_zen
	WHERE dt_nonyu <= @dateTaisho
	
	-- ���M�f�[�^���o�F�[�����ђ��o�e�[�u���ւ�INSERT
	INSERT INTO tr_sap_jisseki_nonyu_denso (
		kbn_denso_SAP
		,no_nonyu
		,no_niuke
		,cd_kojo
		,cd_niuke_basho
		,dt_nonyu
		,cd_hinmei
		,su_nonyu_jitsu
		,cd_torihiki
		,cd_tani_nonyu
		,kbn_nyuko
		,flg_kakutei
		,no_nohinsho
		,no_zeikan_shorui
	)
	--�V�K�ǉ��f�[�^
	SELECT
		@kbnCreate
		,taisho.no_nonyu
		,taisho.no_niuke
		,taisho.cd_kojo
		,taisho.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_nonyu,112)) AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_nonyu_jitsu
		,taisho.cd_torihiki
		,mst.cd_tani_henkan
		,taisho.kbn_nyuko
		,9 AS flg_kakutei
		,taisho.no_nohinsho
		,taisho.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho taisho
	LEFT JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = taisho.no_nonyu
			AND zen.no_niuke = taisho.no_niuke
			AND zen.cd_hinmei = taisho.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = taisho.cd_hinmei
	WHERE taisho.su_nonyu_jitsu <> 0
		AND zen.no_nonyu IS NULL
		AND mh.kbn_hin <> @kbnJikagen
	
	UNION ALL
	
	--�X�V�f�[�^(��)
	SELECT
		@kbnDelete
		,zen.no_nonyu
		,zen.no_niuke
		,zen.cd_kojo
		,zen.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_nonyu,112)) AS dt_nonyu
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_nonyu_jitsu
		,zen.cd_torihiki
		,mst.cd_tani_henkan
		,zen.kbn_nyuko
		,9 AS flg_kakutei
		,zen.no_nohinsho
		,zen.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho taisho
	INNER JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = taisho.no_nonyu
			AND zen.no_niuke = taisho.no_niuke
			AND zen.cd_hinmei = taisho.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = zen.cd_hinmei
	WHERE (taisho.dt_nonyu <> zen.dt_nonyu
		OR taisho.su_nonyu_jitsu <> zen.su_nonyu_jitsu
		--OR taisho.flg_kakutei <> zen.flg_kakutei
		OR taisho.no_nohinsho <> zen.no_nohinsho
		OR taisho.no_zeikan_shorui <> zen.no_zeikan_shorui)
		AND zen.su_nonyu_jitsu <> 0
		AND mh.kbn_hin <> @kbnJikagen
	
	UNION ALL
	
	--�X�V�f�[�^(��)
	SELECT
		@kbnCreate
		,taisho.no_nonyu
		,taisho.no_niuke
		,taisho.cd_kojo
		,taisho.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_nonyu,112)) AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_nonyu_jitsu
		,taisho.cd_torihiki
		,mst.cd_tani_henkan
		,taisho.kbn_nyuko
		,9 AS flg_kakutei
		,taisho.no_nohinsho
		,taisho.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho taisho
	INNER JOIN tr_sap_jisseki_nonyu_denso_taisho_zen zen
		ON zen.no_nonyu = taisho.no_nonyu
			AND zen.no_niuke = taisho.no_niuke
			AND zen.cd_hinmei = taisho.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = taisho.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = taisho.cd_hinmei
	WHERE (taisho.dt_nonyu <> zen.dt_nonyu
		OR taisho.su_nonyu_jitsu <> zen.su_nonyu_jitsu
		--OR taisho.flg_kakutei <> zen.flg_kakutei
		OR taisho.no_nohinsho <> zen.no_nohinsho
		OR taisho.no_zeikan_shorui <> zen.no_zeikan_shorui)
		AND taisho.su_nonyu_jitsu <> 0
		AND mh.kbn_hin <> @kbnJikagen
	
	UNION ALL
	
	--�폜�f�[�^
	SELECT
		@kbnDelete
		,zen.no_nonyu
		,zen.no_niuke
		,zen.cd_kojo
		,zen.cd_niuke_basho
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_nonyu,112)) AS dt_nonyu
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_nonyu_jitsu
		,zen.cd_torihiki
		,mst.cd_tani_henkan
		,zen.kbn_nyuko
		,9 AS flg_kakutei
		,zen.no_nohinsho
		,zen.no_zeikan_shorui
	FROM tr_sap_jisseki_nonyu_denso_taisho_zen zen
	LEFT JOIN tr_sap_jisseki_nonyu_denso_taisho taisho
		ON taisho.no_nonyu = zen.no_nonyu
			AND taisho.no_niuke = zen.no_niuke
			AND taisho.cd_hinmei = zen.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mst.cd_tani = zen.cd_tani_nonyu
	LEFT JOIN ma_hinmei mh
		ON mh.cd_hinmei = zen.cd_hinmei
	WHERE zen.su_nonyu_jitsu <> 0
		AND taisho.no_nonyu IS NULL
		AND mh.kbn_hin <> @kbnJikagen
		
	UNION ALL
		
	-- �m��t���O
	SELECT DISTINCT
		@kbnUpdate
		,taisho.no_nonyu AS no_nonyu
		,'0' AS no_niuke
		,taisho.cd_kojo AS cd_kojo
		,taisho.cd_niuke_basho AS cd_niuke_basho
		,NULL AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,0 AS su_nonyu_jitsu
		,taisho.cd_torihiki
		,'' AS cd_tani_nonyu
		,NULL AS kbn_nyuko
		,taisho.flg_kakutei
		,'' AS no_nohinsho
		,'' AS no_zeikan_shorui
	FROM (
		SELECT
			no_nonyu
			, cd_kojo
			, cd_niuke_basho
			, cd_hinmei
			, cd_torihiki
			, MAX(flg_kakutei) AS flg_kakutei
		FROM tr_sap_jisseki_nonyu_denso_taisho
		WHERE su_nonyu_jitsu <> 0
		GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
		) taisho
	LEFT OUTER JOIN (
		SELECT
			no_nonyu
			, cd_kojo
			, cd_niuke_basho
			, cd_hinmei
			, cd_torihiki
			, MAX(flg_kakutei) AS flg_kakutei
		FROM tr_sap_jisseki_nonyu_denso_taisho_zen
		WHERE su_nonyu_jitsu <> 0
		GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
	) zen
		ON zen.no_nonyu = taisho.no_nonyu
	   AND zen.cd_hinmei = taisho.cd_hinmei
	   AND zen.cd_kojo = taisho.cd_kojo
	   AND zen.cd_niuke_basho = taisho.cd_niuke_basho
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	WHERE  (zen.no_nonyu IS NULL
	     OR taisho.flg_kakutei <> zen.flg_kakutei)
		AND mh.kbn_hin <> @kbnJikagen
	
	--20190417�m��t���O���ς���Ă��Ȃ��X�V�f�[�^�̊m��t���O������悤�ɏC��
	INSERT INTO tr_sap_jisseki_nonyu_denso (
		kbn_denso_SAP
		,no_nonyu
		,no_niuke
		,cd_kojo
		,cd_niuke_basho
		,dt_nonyu
		,cd_hinmei
		,su_nonyu_jitsu
		,cd_torihiki
		,cd_tani_nonyu
		,kbn_nyuko
		,flg_kakutei
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT DISTINCT
		@kbnUpdate
		,taisho.no_nonyu AS no_nonyu
		,'0' AS no_niuke
		,taisho.cd_kojo AS cd_kojo
		,taisho.cd_niuke_basho AS cd_niuke_basho
		,NULL AS dt_nonyu
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,0 AS su_nonyu_jitsu
		,taisho.cd_torihiki
		,'' AS cd_tani_nonyu
		,NULL AS kbn_nyuko
		,taisho.flg_kakutei
		,'' AS no_nohinsho
		,'' AS no_zeikan_shorui
	FROM (
		SELECT
			no_nonyu
			, cd_kojo
			, cd_niuke_basho
			, cd_hinmei
			, cd_torihiki
			, MAX(flg_kakutei) AS flg_kakutei
		FROM tr_sap_jisseki_nonyu_denso_taisho
		WHERE su_nonyu_jitsu <> 0
		GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
		) taisho
	INNER JOIN tr_sap_jisseki_nonyu_denso denso
		ON taisho.no_nonyu = denso.no_nonyu
		AND denso.kbn_denso_SAP <> @kbnDelete
		AND denso.su_nonyu_jitsu <> 0 --�t���O�݂̂̃f�[�^������
	LEFT JOIN tr_sap_jisseki_nonyu_denso denso_flg
		ON taisho.no_nonyu = denso_flg.no_nonyu
		AND denso_flg.su_nonyu_jitsu = 0
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	WHERE mh.kbn_hin <> @kbnJikagen
		AND denso_flg.no_nonyu IS NULL

	--20200826�폜(@kbnDelete)���`������A�[�����т��c���Ă���f�[�^���m��f�[�^�Ƃ��ē`�����悤�ɏC��		
	INSERT INTO tr_sap_jisseki_nonyu_denso (
		kbn_denso_SAP
		,no_nonyu
		,no_niuke
		,cd_kojo
		,cd_niuke_basho
		,dt_nonyu
		,cd_hinmei
		,su_nonyu_jitsu
		,cd_torihiki
		,cd_tani_nonyu
		,kbn_nyuko
		,flg_kakutei
		,no_nohinsho
		,no_zeikan_shorui
	)
	SELECT
		@kbnUpdate 
		,denso_kbn2.no_nonyu AS no_nonyu
		,'0' AS no_niuke
		,denso_kbn2.cd_kojo
		,denso_kbn2.cd_niuke_basho AS cd_niuke_basho
		,NULL AS dt_nonyu
		,UPPER(denso_kbn2.cd_hinmei) AS cd_hinmei
		,0 AS su_nonyu_jitsu
		,denso_kbn2.cd_torihiki
		,'' AS cd_tani_nonyu
		,NULL AS kbn_nyuko
		,denso_kbn2.flg_kakutei
		,'' AS no_nohinsho
		,'' AS no_zeikan_shorui
	FROM(	
		SELECT DISTINCT
			@kbnUpdate AS kbn_denso_SAP 
			,taisho.no_nonyu AS no_nonyu
			,'0' AS no_niuke
			,taisho.cd_kojo AS cd_kojo
			,taisho.cd_niuke_basho AS cd_niuke_basho
			,NULL AS dt_nonyu
			,UPPER(taisho.cd_hinmei) AS cd_hinmei
			,0 AS su_nonyu_jitsu
			,taisho.cd_torihiki
			,'' AS cd_tani_nonyu
			,NULL AS kbn_nyuko
			,taisho.flg_kakutei
			,'' AS no_nohinsho
			,'' AS no_zeikan_shorui
		FROM (
			SELECT
				no_nonyu
				, cd_kojo
				, cd_niuke_basho
				, cd_hinmei
				, cd_torihiki
				, MAX(flg_kakutei) AS flg_kakutei
			FROM tr_sap_jisseki_nonyu_denso_taisho
			WHERE su_nonyu_jitsu <> 0
			GROUP BY no_nonyu, cd_kojo, cd_niuke_basho, cd_hinmei, cd_torihiki
			) taisho
		INNER JOIN tr_sap_jisseki_nonyu_denso denso--�폜�敪���`�����ꂽ���R�[�h������
			ON taisho.no_nonyu = denso.no_nonyu
			AND denso.kbn_denso_SAP = @kbnDelete 
			AND denso.su_nonyu_jitsu <> 0 
	   )denso_kbn2
	   LEFT JOIN tr_sap_jisseki_nonyu_denso denso--1�x�m��f�[�^���`������Ă���f�[�^�ȊO���m��Ώ�
		ON denso_kbn2.kbn_denso_SAP = denso.kbn_denso_SAP
		AND denso_kbn2.no_nonyu = denso.no_nonyu
	   WHERE denso.no_nonyu IS NULL

END
GO
