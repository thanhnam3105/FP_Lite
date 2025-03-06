IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_chosei_zaiko_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�݌ɒ������M�Ώۃe�[�u���쐬����
�t�@�C����	�Fusp_sap_chosei_zaiko_denso_taisho_create
���͈���	�F				
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.01.28 endo.y
�X�V��      �F2015.03.03 hirai.a �ړ��敪��ǉ�
�X�V��      �F2015.03.12 hirai.a �}�C�i�X�������ɑΉ�
�X�V��      �F2015.03.23 endo.y 3�����ȑO���O�̃f�[�^��ΏۊO�ɏC��
�X�V���@�@�@�F2015.07.15 kobayashi.y �ĕ������Ή�
�X�V��      �F2015.09.24 taira.s ���o�f�[�^�ɔ[�i���ԍ��A�ԕi���R��ǉ�
�X�V��      �F2015.09.29 taira.s ���o�f�[�^�Ɏ����R�[�h��ǉ�
�X�V��      �F2015.10.07 ADMAX taira.s �i���}�X�^.�e�X�g�i=1�̃f�[�^����荞�܂Ȃ��悤�ɏC��
�X�V��      �F2015.11.26 ADMAX kakuta.y �q�ɃR�[�h��i���ƂɎ擾����悤�ɏC��
�X�V���@�@�@�F2016.01.04 Hirai.a �����̓��t��60���ɓ���
�X�V���@�@�@�F2016.10.27 motojima.m Q&B�T�|�[�gNo4�Ή�(�������̏�����2������3���ɏC��)
�X�V���@�@�@�F2018.10.05 motojima.m I/F�Ɋւ���q�Ƀ}�X�^�̉��C
�X�V���@�@�@�F2022.11.01 echigo.r �ԕi�����ł͂Ȃ��A���l���e��SAP�ɓ`��
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_chosei_zaiko_denso_taisho_create] 
	@kbnCreate		SMALLINT
	,@kbnUpdate		SMALLINT
	,@kbnDelete		SMALLINT
	,@riyuBunrui	SMALLINT
	,@flgDenso		SMALLINT
	,@jisa			SMALLINT
	,@kbnJikagen	SMALLINT
	,@kbnDensochu	SMALLINT
	,@kbnDensozumi	SMALLINT
	,@kbnDensomachi	SMALLINT
	,@kbnChosei		SMALLINT
	,@flgJisseki	SMALLINT
	,@kbnGenryo		SMALLINT
	,@kbnSaiban		VARCHAR(2)
	,@kbnPrefix		VARCHAR(1)
	,@flgShiyo		SMALLINT
AS
BEGIN

	-- DECLARE START --

	--�R�s�[�����p���t�i�V�X�e������ - 60���j
	DECLARE @dateTaisho DATETIME = DATEADD(DD,-60,getutcdate())

	--�R�s�[�����p���t�i�ĕ������p�j�i�V�X�e������ - 60���j
	DECLARE @dateTaishoAnbun DATETIME = DATEADD(DD,-60,getutcdate())

	-- LOOP�p 
	DECLARE @keyAnbunSeq VARCHAR(14)
	DECLARE @keyShikakariLot VARCHAR(14)
	DECLARE @keyHinCode VARCHAR(14)
	DECLARE @keyRiyuCode VARCHAR(10)
	DECLARE @seqNo VARCHAR(14)

	--�������ꎞ�e�[�u���@�i�V�[�N�G���XNo��t���ɗ��p�j
	--������TBL�p�ɃV�[�N�G���XNo��t�^����
	DECLARE @anbunChoseiTable TABLE
	(
		[no_seq] [varchar](14) NULL
		,[no_seq_anbun] [varchar](14) NOT NULL
		,[no_lot_shikakari] [varchar](14) NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_hizuke] [datetime] NULL
		,[cd_riyu] [varchar](10) NOT NULL
		,[su_chosei] [decimal](12, 6) NOT NULL
		,[cd_genka_center] [varchar](10) NULL
		,[cd_soko] [varchar](10) NULL
	)

	-- �q�ɃR�[�h�����l�p
	--DECLARE @init_sokoCode VARCHAR(10)

	-- DECLARE END --
	-- PROCESS START --

	-- �q�ɃR�[�h�̏����l���擾
	/*
	SET @init_sokoCode = (
							SELECT TOP 1 soko.cd_soko
							FROM ma_soko soko
							WHERE
								soko.flg_mishiyo = @flgShiyo
							ORDER BY soko.cd_soko
						 )
	*/

	-- ## �g�p�\���ɑ΂��ď��� ## --
	-- �g�p�\�����������[�N��truncate
	TRUNCATE TABLE wk_sap_shiyo_yojitsu_anbun_chosei
	
	-- �g�p�\�����������[�N��insert
	INSERT INTO wk_sap_shiyo_yojitsu_anbun_chosei(
		no_seq
		,no_lot_shikakari
		,kbn_shiyo_jisseki_anbun
		,no_lot_seihin
		,dt_shiyo_shikakari
		,su_shiyo_shikakari
		,cd_riyu
		,cd_genka_center
		,cd_soko
		,kbn_jotai_denso
	)
	SELECT
		no_seq
		,no_lot_shikakari
		,kbn_shiyo_jisseki_anbun
		,no_lot_seihin
		,dt_shiyo_shikakari
		,su_shiyo_shikakari
		,cd_riyu
		,cd_genka_center
		,cd_soko
		,kbn_jotai_denso
	FROM tr_sap_shiyo_yojitsu_anbun
	WHERE
		dt_shiyo_shikakari >= @dateTaishoAnbun
	

	-- �g�p�\���������g�����@�敪�X�V
	EXECUTE usp_sap_shiyo_yojitsu_anbun_jotai_denso_update
		@kbnChosei
		,@kbnDensomachi
		,@kbnDensochu
	
	-- ## �������e�[�u���ɑ΂��ď��� ## --

	-- �������e�[�u����truncate
	TRUNCATE TABLE tr_sap_chosei_anbun

	-- �������e�[�u����insert
	INSERT INTO @anbunChoseiTable (
		no_seq
		,no_seq_anbun
		,no_lot_shikakari
		,cd_hinmei
		,dt_hizuke
		,cd_riyu
		,su_chosei
		,cd_genka_center
		,cd_soko
	)
	SELECT
		zen.no_seq
		,anbunChosei.no_seq_anbun
		,anbunChosei.no_lot_shikakari
		,anbunChosei.cd_hinmei
		,anbunChosei.dt_hiduke
		,anbunChosei.cd_riyu
		,anbunChosei.su_chosei
		,anbunChosei.cd_genka_center
		--,anbunChosei.cd_soko
		--,ISNULL(soko.cd_soko, @init_sokoCode)
		,soko.cd_soko
	FROM
	(
		SELECT
			wariai.no_seq AS no_seq_anbun
			,wariai.no_lot_shikakari
			,yojitsu.cd_hinmei
			,yojitsu.dt_shiyo AS dt_hiduke
			,wariai.cd_riyu
			--,CEILING(SUM(yojitsu.su_shiyo * wariai.ritsu_anbun) * 100) / 100 AS su_chosei
			,CEILING(SUM(yojitsu.su_shiyo * wariai.ritsu_anbun) * 1000) / 1000 AS su_chosei
			,wariai.cd_genka_center
			,wariai.cd_soko
		FROM 
			(
				SELECT
					anbun.no_seq
					,anbun.no_lot_shikakari
					,anbun.kbn_shiyo_jisseki_anbun
					,anbun.kbn_jotai_denso
					,anbun.cd_riyu
					,anbun.cd_genka_center
					,anbun.cd_soko
					,anbun.dt_shiyo_shikakari
					,anbun.su_shiyo_shikakari / summary.su_shiyo_shikakari_sum AS ritsu_anbun
				FROM
					wk_sap_shiyo_yojitsu_anbun_chosei anbun
					LEFT OUTER JOIN (
						SELECT
							anbun.no_lot_shikakari
							,SUM(anbun.su_shiyo_shikakari) AS su_shiyo_shikakari_sum
						FROM wk_sap_shiyo_yojitsu_anbun_chosei anbun
						GROUP BY
							anbun.no_lot_shikakari
					)summary
					ON anbun.no_lot_shikakari = summary.no_lot_shikakari
			) wariai
			LEFT OUTER JOIN tr_shiyo_yojitsu yojitsu
			ON wariai.no_lot_shikakari = yojitsu.no_lot_shikakari
			LEFT OUTER JOIN ma_hinmei hin
			ON hin.cd_hinmei = yojitsu.cd_hinmei
			AND ISNULL(hin.flg_testitem, 0) <> 1
		WHERE
			wariai.kbn_shiyo_jisseki_anbun = @kbnChosei
			AND wariai.kbn_jotai_denso >= @kbnDensomachi
			AND yojitsu.flg_yojitsu = @flgJisseki
			AND hin.kbn_hin IN (@kbnGenryo, @kbnJikagen)
		GROUP BY
			wariai.no_seq
			,yojitsu.cd_hinmei
			,yojitsu.dt_shiyo
			,wariai.no_lot_shikakari
			,wariai.cd_riyu
			,wariai.cd_genka_center
			,wariai.cd_soko
	) anbunChosei
	LEFT OUTER JOIN tr_sap_chosei_anbun_zen zen
	ON anbunChosei.no_lot_shikakari = zen.no_lot_shikakari
	AND anbunChosei.no_seq_anbun = zen.no_seq_anbun
	AND anbunChosei.cd_hinmei = zen.cd_hinmei
	AND anbunChosei.dt_hiduke = zen.dt_hizuke
	LEFT OUTER JOIN ma_hinmei hinmei
	ON anbunChosei.cd_hinmei = hinmei.cd_hinmei
	LEFT OUTER JOIN ma_kbn_soko kbn_soko
	ON hinmei.kbn_hin = kbn_soko.kbn_hin
	LEFT OUTER JOIN ma_soko soko
	--ON hinmei.cd_niuke_basho = soko.cd_soko
	ON kbn_soko.cd_soko_kbn = soko.cd_soko
		
	-- �V�[�N�G���XNo�t�^
	WHILE EXISTS (SELECT no_seq FROM @anbunChoseiTable WHERE no_seq IS NULL)
		BEGIN
			SELECT TOP 1 
				@keyAnbunSeq = no_seq_anbun
				, @keyShikakariLot = no_lot_shikakari
				, @keyHinCode = cd_hinmei
	            , @keyRiyuCode = cd_riyu
			FROM @anbunChoseiTable
			WHERE no_seq IS NULL

			-- get sequence no
			EXECUTE usp_cm_Saiban @kbnSaiban, @kbnPrefix, @seqNo OUTPUT

			UPDATE @anbunChoseiTable 
			SET no_seq = @seqNo
			WHERE
				no_seq_anbun = @keyAnbunSeq
				AND no_lot_shikakari = @keyShikakariLot
				AND cd_hinmei = @keyHinCode
				AND cd_riyu = @keyRiyuCode
		END

	-- �������e�[�u���ɃC���T�[�g
	INSERT INTO tr_sap_chosei_anbun (
		no_seq
		,no_seq_anbun
		,no_lot_shikakari
		,cd_hinmei
		,dt_hizuke
		,cd_riyu
		,su_chosei
		,cd_genka_center
		,cd_soko
	)
	SELECT 
		no_seq
		,no_seq_anbun
		,no_lot_shikakari
		,cd_hinmei
		,dt_hizuke
		,cd_riyu
		,su_chosei
		,cd_genka_center
		,cd_soko
	FROM @anbunChoseiTable

	-- ## �������M���� ## --
	-- �݌ɒ������M�Ώۃe�[�u���̍폜
	TRUNCATE TABLE tr_sap_chosei_zaiko_denso_taisho
	
	-- �����g�����̃f�[�^���݌ɒ������M�Ώۃe�[�u���ɃR�s�[
	INSERT INTO tr_sap_chosei_zaiko_denso_taisho (
		no_seq
		,cd_hinmei
		,dt_hizuke
		,cd_riyu
		,su_chosei
		,dt_update
		,cd_update
		,cd_genka_center
		,cd_soko
		,cd_torihiki
		,biko
		,no_nohinsho
	)
	SELECT
		no_seq
		,chosei.cd_hinmei
		,dt_hizuke
		-- ���������}�C�i�X�̏ꍇ�͗��R�R�[�h������̃R�[�h�ɂ���
		,CASE WHEN chosei.su_chosei < 0
		 THEN
			COALESCE(msr.cd_riyu_torikeshi,chosei.cd_riyu)
		 ELSE
			chosei.cd_riyu
		 END AS cd_riyu
		,CASE WHEN chosei.su_chosei < 0
		 THEN
			--CEILING(chosei.su_chosei * 100 * (-1))/100
			CEILING(chosei.su_chosei * 1000 * (-1))/1000
		 ELSE
			--CEILING(su_chosei * 100)/100
			CEILING(su_chosei * 1000)/1000
		 END AS su_chosei
		,chosei.dt_update
		,chosei.cd_update
		,cd_genka_center
		,cd_soko
		,cd_torihiki
		,ISNULL(chosei.nm_henpin,chosei.biko)
		,no_nohinsho
	FROM tr_chosei chosei
	LEFT JOIN ma_riyu mr
		ON chosei.cd_riyu = mr.cd_riyu
			AND mr.kbn_bunrui_riyu = @riyuBunrui
	LEFT JOIN ma_sap_riyu_torikeshi  msr
		ON mr.cd_riyu = msr.cd_riyu
	LEFT JOIN ma_hinmei mh
		ON chosei.cd_hinmei = mh.cd_hinmei
	WHERE chosei.dt_hizuke > @dateTaisho
		AND ISNULL(mh.flg_testitem, 0) <> 1

	UNION ALL
	-- �������e�[�u��
	SELECT
		no_seq
		,cd_hinmei
		,dt_hizuke
		,cd_riyu
		,su_chosei
		,GETUTCDATE() AS dt_update
		,'' AS cd_update
		,cd_genka_center
		,cd_soko
		,'' AS cd_torihiki
		,'' AS biko
		,'' AS no_nohinsho
	FROM tr_sap_chosei_anbun anbun
	WHERE dt_hizuke > @dateTaishoAnbun
		
	--�O��f�[�^����3�����O���폜�i�����g�������j
	DELETE tr_sap_chosei_zaiko_denso_taisho_zen
	WHERE dt_hizuke <= @dateTaisho
	
	--�O��f�[�^����2�����O���폜�i�������g�������j
	DELETE tr_sap_chosei_zaiko_denso_taisho_zen
	WHERE dt_hizuke <= @dateTaishoAnbun
	AND cd_update = ''

	-- ���M�f�[�^���o�F�݌ɒ������o�e�[�u����TRUNCATE
	TRUNCATE TABLE tr_sap_chosei_zaiko_denso
	-- ���M�f�[�^���o�F�݌ɒ������o�e�[�u���ւ�INSERT
	INSERT INTO tr_sap_chosei_zaiko_denso (
		kbn_denso_SAP
		,no_seq
		,cd_hinmei
		,cd_kojo
		,cd_soko
		,cd_riyu
		,su_chosei
		,cd_tani_SAP
		,cd_genka_center
		,dt_denpyo
		,dt_hizuke
		,kbn_ido
		,cd_torihiki
		,biko
		,no_nohinsho
	)
	--�ǉ��X�g�A�h
	SELECT
		@kbnCreate
		,taisho.no_seq
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,taisho.cd_soko
		,taisho.cd_riyu
		,taisho.su_chosei
		,mst.cd_tani_henkan
		,taisho.cd_genka_center
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,dateadd(hour,@jisa,taisho.dt_update),112)) AS dt_update
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_hizuke,112)) AS dt_hizuke
		,msr.kbn_ido as kbn_ido
		,taisho.cd_torihiki
		,taisho.biko
		,taisho.no_nohinsho
	FROM tr_sap_chosei_zaiko_denso_taisho taisho
	LEFT JOIN tr_sap_chosei_zaiko_denso_taisho_zen zen
		ON taisho.no_seq = zen.no_seq
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_shiyo = mst.cd_tani
	LEFT JOIN ma_riyu mr
		ON taisho.cd_riyu = mr.cd_riyu
			AND mr.kbn_bunrui_riyu = @riyuBunrui
	LEFT JOIN ma_sap_riyu_torikeshi msr
		ON taisho.cd_riyu = msr.cd_riyu
	WHERE zen.no_seq IS NULL
			AND msr.nm_riyu IS NOT NULL
	
	UNION ALL
	
	--�X�V�f�[�^(��)
	SELECT
		@kbnDelete
		,zen.no_seq
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,zen.cd_soko
		,msr.cd_riyu_torikeshi
		,zen.su_chosei
		,mst.cd_tani_henkan
		,zen.cd_genka_center
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,dateadd(hour,@jisa,zen.dt_update),112)) AS dt_update
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_hizuke,112)) AS dt_hizuke
		,msr.kbn_ido_torikeshi as kbn_ido
		,zen.cd_torihiki
		,zen.biko
		,zen.no_nohinsho
	FROM tr_sap_chosei_zaiko_denso_taisho taisho
	INNER JOIN tr_sap_chosei_zaiko_denso_taisho_zen zen
		ON taisho.no_seq = zen.no_seq
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_shiyo = mst.cd_tani
	LEFT JOIN ma_riyu mr
		ON taisho.cd_riyu = mr.cd_riyu
		AND mr.kbn_bunrui_riyu = @riyuBunrui
	LEFT JOIN ma_sap_riyu_torikeshi msr
		ON zen.cd_riyu = msr.cd_riyu
	WHERE  msr.nm_riyu IS NOT NULL
		AND (taisho.cd_hinmei <> zen.cd_hinmei
			OR	taisho.su_chosei <> zen.su_chosei
			OR taisho.cd_riyu <> zen.cd_riyu
			OR taisho.cd_genka_center <> zen.cd_genka_center
			OR taisho.cd_soko <> zen.cd_soko			
			OR ISNULL(taisho.biko,'') <> ISNULL(zen.biko,'')
			OR ISNULL(taisho.no_nohinsho,'') <> ISNULL(zen.no_nohinsho,'')
			)
	
	UNION ALL
	
	--�X�V�f�[�^(��)
	SELECT
		@kbnCreate
		,taisho.no_seq
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,taisho.cd_soko
		,taisho.cd_riyu
		,taisho.su_chosei
		,mst.cd_tani_henkan
		,taisho.cd_genka_center
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,dateadd(hour,@jisa,taisho.dt_update),112)) AS dt_update
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_hizuke,112)) AS dt_hizuke
		,msr.kbn_ido as kbn_ido
		,taisho.cd_torihiki
		,taisho.biko
		,taisho.no_nohinsho
	FROM tr_sap_chosei_zaiko_denso_taisho taisho
	INNER JOIN tr_sap_chosei_zaiko_denso_taisho_zen zen
		ON taisho.no_seq = zen.no_seq
	LEFT JOIN ma_hinmei mh
		ON taisho.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_shiyo = mst.cd_tani
	LEFT JOIN ma_riyu mr
		ON taisho.cd_riyu = mr.cd_riyu
		AND mr.kbn_bunrui_riyu = @riyuBunrui
	LEFT JOIN ma_sap_riyu_torikeshi msr
		ON taisho.cd_riyu = msr.cd_riyu 
	WHERE msr.nm_riyu IS NOT NULL
		AND (taisho.cd_hinmei <> zen.cd_hinmei 
			OR taisho.su_chosei <> zen.su_chosei
			OR taisho.cd_riyu <> zen.cd_riyu
			OR taisho.cd_genka_center <> zen.cd_genka_center
			OR taisho.cd_soko <> zen.cd_soko			
			OR ISNULL(taisho.biko,'') <> ISNULL(zen.biko,'')
			OR ISNULL(taisho.no_nohinsho,'') <> ISNULL(zen.no_nohinsho,'')
			)
	
	UNION ALL
	
	--�폜�f�[�^
	SELECT
		@kbnDelete
		,zen.no_seq
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,(SELECT TOP 1 cd_kojo FROM ma_kojo) AS cd_kojo
		,zen.cd_soko
		,msr.cd_riyu_torikeshi
		,zen.su_chosei
		,mst.cd_tani_henkan
		,zen.cd_genka_center
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,dateadd(hour,@jisa,zen.dt_update),112)) AS dt_update
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_hizuke,112)) AS dt_hizuke
		,msr.kbn_ido_torikeshi as kbn_ido
		,zen.cd_torihiki
		,zen.biko
		,zen.no_nohinsho
	FROM tr_sap_chosei_zaiko_denso_taisho_zen zen
	LEFT JOIN tr_sap_chosei_zaiko_denso_taisho taisho
		ON zen.no_seq = taisho.no_seq
	LEFT JOIN ma_hinmei mh
		ON zen.cd_hinmei = mh.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan mst
		ON mh.cd_tani_shiyo = mst.cd_tani
	LEFT JOIN ma_riyu mr
		ON zen.cd_riyu = mr.cd_riyu
		AND mr.kbn_bunrui_riyu = @riyuBunrui
	LEFT JOIN ma_sap_riyu_torikeshi msr
		ON zen.cd_riyu = msr.cd_riyu
	WHERE taisho.no_seq IS NULL
		AND msr.nm_riyu IS NOT NULL

	-- PROCESS END --
END
GO
