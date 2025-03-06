IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_sap_jisseki_shiyo_denso_taisho_create') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_create]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�g�p���ё��M�Ώۃe�[�u���쐬����
�t�@�C����	�Fusp_sap_jisseki_shiyo_denso_taisho_create
���͈���	�F
�o�͈���	�F
�߂�l		�F������[0] ���s��[0�ȊO�̃G���[�R�[�h]
�쐬��		�F2015.07.13 kaneko.m
�X�V��      �F2015.08.21 Hirai.a �폜�͓`���敪�ύX�Ȃ��`��
�X�V��      �F2015.10.07 ADMAX taira.s �i���}�X�^.�e�X�g�i=1�̃f�[�^����荞�܂Ȃ��悤�ɏC��
�X�V��      �F2015.10.09 kaneko.m �g�p���уV�[�P���X�ԍ���V�K���`���Ώۂɂ̂ݕt�Ԃ���悤�ύX
�X�V��      �F2015.10.27 kaneko.m �`���f�[�^�̒P�ʂ�[���P�ʂ���g�p�P�ʂɏC��
�X�V��      �F2015.12.17 ADMAX shibao.s �d�|�c�̎g�p���т��擾����悤�ɕύX
�X�V��		�F2015.12.28 Hirai.a �g�p���ѓ`���̍������f�𐻕i���b�g�P�ʂɕύX�B
�X�V���@�@�@�F2016.01.04 Hirai.a �����̓��t��60���ɓ���
�X�V��		�F2016.01.27 Hirai.a @densoTable�������A���ނɕ������A�����ɂ�kbn_denso_jotai��ǉ�
�X�V��		�F2017.03.06 cho.k Q&B�T�|�[�gNo.47�Ή�
�X�V��		�F2017.10.10 sato.s Q&B�T�|�[�gNo.05/KPM�T�|�[�gNo.019/Q&B�T�|�[�gNo.060/Q&B�T�|�[�gNo.063/Q&B�T�|�[�gNo.071/KPM�T�|�[�gNo.031
�X�V��		�F2018.02.20 tokumoto.k Q&B�T�|�[�gNo.73�Ή�
�X�V��		�F2018.07.30 tokumoto.k Q&B�T�|�[�gNo.195�Ή�
�X�V���@�@�@�F2024.02.05 Echigo.r �H��R�[�h���ʏ����ǉ��iTN�H��ǉ��Ή��j
*****************************************************/
CREATE PROCEDURE [dbo].[usp_sap_jisseki_shiyo_denso_taisho_create] 
	@kbnCreate		SMALLINT
	,@kbnUpdate		SMALLINT
	,@kbnDelete		SMALLINT
	,@kbnGenryo		SMALLINT
	,@kbnJikagen	SMALLINT
	,@kbnShizai		SMALLINT
	,@flgJisseki	SMALLINT
	,@kbnMidenso    SMALLINT	-- ���`���敪�ǉ�
	,@kbnDensochu	SMALLINT
	,@kbnDensomachi	SMALLINT
	,@kbnSeizo		SMALLINT
	,@kbnZan		SMALLINT
	,@kbnSaiban		VARCHAR(2)
	,@kbnPrefix		VARCHAR(1)
	,@idoType		VARCHAR(3)
	,@idoTypeCancel	VARCHAR(3)
AS

BEGIN

	DECLARE @densoTable_genryo TABLE
	(
		[no_seq] [varchar](14) NULL
		,[flg_yojitsu] [smallint] NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[no_lot_seihin] [varchar](14) NOT NULL
		,[no_lot_shikakari] [varchar](14) NULL
		,[su_shiyo] [decimal](9, 3) NOT NULL
		,[data_key_tr_shikakari] [varchar](14) NULL
		,[kbn_jotai_denso] [smallint] NOT NULL
	)

	DECLARE @densoTable_shizai TABLE
	(
		[no_seq] [varchar](14) NULL
		,[flg_yojitsu] [smallint] NOT NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[no_lot_seihin] [varchar](14) NOT NULL
		,[no_lot_shikakari] [varchar](14) NULL
		,[su_shiyo] [decimal](9, 3) NOT NULL
		,[data_key_tr_shikakari] [varchar](14) NULL
		-- ���ނɓ`���敪��ǉ�
		,[kbn_jotai_denso] [smallint] NOT NULL
	)
	
	-- �V�[�P���X�̔ԑO�Ɏ��т��ꌳ�����邽�߁A�ꎞ�e�[�u��������
	DECLARE @densoTable TABLE
	(
		[no_seq] [varchar](14) NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[no_lot_seihin] [varchar](14) NOT NULL
		,[su_shiyo] [decimal](9, 3) NOT NULL
		,[kbn_jotai_denso] [smallint] NOT NULL
	)
	
	-- �덷�����p�e�[�u��
	DECLARE @densoTable_chosei TABLE
	(
		[no_seq] [varchar](14) NULL
		,[cd_hinmei] [varchar](14) NOT NULL
		,[dt_shiyo] [datetime] NOT NULL
		,[su_shiyo_diff] [decimal](9, 3) NOT NULL
	)

	DECLARE @msg						VARCHAR(500)		-- �������ʃ��b�Z�[�W�i�[�p
	DECLARE @cd_kojo					VARCHAR(13)
	DECLARE @dateTaisho					DATETIME
	DECLARE @seqNo						VARCHAR(14)
		
	DECLARE @cur_no_seq					VARCHAR(14)
	DECLARE @cur_flg_yojitsu			SMALLINT
	DECLARE @cur_cd_hinmei				VARCHAR(14)
	DECLARE @cur_dt_shiyo				DATETIME
	DECLARE @cur_no_lot_seihin			VARCHAR(14)
	DECLARE @cur_no_lot_shikakari		VARCHAR(14)
	DECLARE @cur_su_shiyo				DECIMAL(9, 3)
	DECLARE @cur_data_key_tr_shikakari	VARCHAR(14)
	DECLARE @cur_kbn_jotai_denso			SMALLINT

	SET NOCOUNT ON

	-- �H��R�[�h�̎擾
	SET @cd_kojo = (SELECT TOP 1 cd_kojo FROM ma_kojo)
	
	--���������p���t�i�V�X�e������ - 60���j
	SET @dateTaisho = DATEADD(DD,-60,getutcdate())

	-- ##### �捞���� #####
	-- �g�p�\�������[�N��truncate
	TRUNCATE TABLE wk_sap_shiyo_yojitsu_anbun_seizo
	
	-- �g�p�\�������[�N�쐬
	INSERT INTO wk_sap_shiyo_yojitsu_anbun_seizo(
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
  		dt_shiyo_shikakari >= @dateTaisho
	AND kbn_jotai_denso <> @kbnMidenso
		
	-- �g�p�\�����g�����@�敪�X�V(����)
	EXECUTE usp_sap_shiyo_yojitsu_anbun_jotai_denso_update
		@kbnSeizo
		,@kbnDensomachi
		,@kbnDensochu
		
	-- �g�p�\�����g�����@�敪�X�V(�c)
	EXECUTE usp_sap_shiyo_yojitsu_anbun_jotai_denso_update
		@kbnZan
		,@kbnDensomachi
		,@kbnDensochu

		
	-- ##### �g�p���ё��M�f�[�^���o #####
	-- �g�p���ё��M�Ώۃe�[�u����truncate
	TRUNCATE TABLE tr_sap_jisseki_shiyo_denso_taisho

	-- �g�p���ё��M�Ώۈꎞ�e�[�u���Ƀf�[�^���쐬�i�����A���ƌ����j
	-- ���e�[�u���Ǝg�p�\���Ő��i���b�g���̌����g�p���т��쐬
	INSERT INTO @densoTable_genryo (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
		,kbn_jotai_denso
	)
	-- �����A���ƌ����̎g�p�ʂ��擾
	SELECT
		zen.no_seq
		,@flgJisseki AS flg_yojitsu
		,warifuri.cd_hinmei
		,warifuri.dt_shiyo
		,warifuri.no_lot_seihin
		,NULL AS no_lot_shikakari
		-- �������b�g�A�g�p���A�i���ŃO���[�v�����A���ѐ������Z
		,CEILING(SUM(warifuri.su_shiyo) * 1000) / 1000 AS su_shiyo
		,NULL AS data_key_tr_shikakari
		-- �`���҂����܂ޏꍇ�͓`���҂����擾�i���`���͏��O���Ă���̂ŁA�ŏ��l�͓`���҂��ɂȂ�j
		,MIN(warifuri.kbn_jotai_denso) AS kbn_jotai_denso
	FROM ( 
		SELECT
			wariai.no_seq
			,shiyo.flg_yojitsu
			,shiyo.cd_hinmei
			,shiyo.dt_shiyo AS dt_shiyo
			,wariai.no_lot_seihin
			,wariai.no_lot_shikakari
			,SUM(shiyo.su_shiyo * wariai.ritsu_anbun) AS su_shiyo
			,shiyo.data_key_tr_shikakari
			,wariai.kbn_jotai_denso
		FROM ( 
			SELECT
				anbun.no_seq
				,anbun.no_lot_shikakari
				,anbun.kbn_shiyo_jisseki_anbun
				,anbun.kbn_jotai_denso
				,anbun.no_lot_seihin
				,anbun.dt_shiyo_shikakari
				,anbun.su_shiyo_shikakari / summary.su_shiyo_shikakari_sum AS ritsu_anbun
			FROM
				wk_sap_shiyo_yojitsu_anbun_seizo anbun
			LEFT OUTER JOIN (
				-- ���`�����O�������[�N�ł͎d�|�i�P�ʂ̎��ѐ�������Ɏ擾�o���Ȃ��̂�
				-- �g�����̃f�[�^��Ώۓ��ōi��d�|�i�P�ʂ̎��ѐ����擾
				SELECT
					no_lot_shikakari
					,SUM(su_shiyo_shikakari) AS su_shiyo_shikakari_sum
				FROM
					tr_sap_shiyo_yojitsu_anbun
				WHERE
					dt_shiyo_shikakari >= @dateTaisho
				GROUP BY
					no_lot_shikakari
			) summary
			ON anbun.no_lot_shikakari = summary.no_lot_shikakari
		) wariai
	LEFT OUTER JOIN tr_shiyo_yojitsu shiyo
	ON wariai.no_lot_shikakari = shiyo.no_lot_shikakari
	LEFT OUTER JOIN ma_hinmei hin
	ON hin.cd_hinmei = shiyo.cd_hinmei
	WHERE(
		wariai.kbn_shiyo_jisseki_anbun = @kbnSeizo
	 	OR wariai.kbn_shiyo_jisseki_anbun = @kbnZan
	)
	AND shiyo.flg_yojitsu = @flgJisseki 
	AND hin.kbn_hin IN (@kbnGenryo, @kbnJikagen)
	AND ISNULL(hin.flg_testitem, 0) <> 1
	GROUP BY
		wariai.no_seq
		,shiyo.flg_yojitsu
		,shiyo.cd_hinmei
		,shiyo.dt_shiyo
		,wariai.no_lot_seihin
		,wariai.no_lot_shikakari
		,shiyo.data_key_tr_shikakari
		,wariai.kbn_jotai_denso
	) warifuri
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
	ON warifuri.cd_hinmei = zen.cd_hinmei 
	AND warifuri.dt_shiyo = zen.dt_shiyo
	AND warifuri.no_lot_seihin = zen.no_lot_seihin
	-- �u�������b�g�A�i���A�g�p���v�Ŏg�p�������Z
	GROUP BY
		zen.no_seq
		,warifuri.cd_hinmei
		,warifuri.dt_shiyo
		,warifuri.no_lot_seihin

	-- �g�p���ё��M�Ώۈꎞ�e�[�u���Ƀf�[�^���쐬�i���ށj
	-- �g�p�\�����琻�i���b�g���̎��ގg�p���т��쐬
	INSERT INTO @densoTable_shizai (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
		-- �`����ԋ敪�ǉ�
		,kbn_jotai_denso
	)
	-- ���ނ̎g�p�ʂ��擾
	SELECT
		zen.no_seq
		,shiyo.flg_yojitsu
		,shiyo.cd_hinmei
		,shiyo.dt_shiyo
		,anbun.no_lot_seihin
		,null AS no_lot_shikakari
		,CEILING(SUM(shiyo.su_shiyo) * 1000) / 1000 AS su_shiyo
		,null AS data_key_tr_shikakari
		,anbun.kbn_jotai_denso
		FROM(
			SELECT 
				no_lot_seihin
				-- ����񂩂�`����ԋ敪�擾�i��ł��`���҂�������Ύ��ނ��`���҂��ɂ���j
				,MIN(kbn_jotai_denso) AS kbn_jotai_denso
			FROM
				wk_sap_shiyo_yojitsu_anbun_seizo
			GROUP BY
				no_lot_seihin
		) anbun
	LEFT OUTER JOIN tr_shiyo_yojitsu shiyo
	ON anbun.no_lot_seihin = shiyo.no_lot_seihin
	LEFT OUTER JOIN ma_hinmei hin
	ON shiyo.cd_hinmei = hin.cd_hinmei
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
	ON shiyo.cd_hinmei = zen.cd_hinmei
	AND shiyo.dt_shiyo = zen.dt_shiyo
	AND anbun.no_lot_seihin = zen.no_lot_seihin
	AND shiyo.no_lot_shikakari IS NULL
	WHERE 
		shiyo.flg_yojitsu = @flgJisseki 
	AND hin.kbn_hin = @kbnShizai
	AND ISNULL(hin.flg_testitem, 0) <> 1
	GROUP BY
		zen.no_seq
		,shiyo.flg_yojitsu
		,shiyo.cd_hinmei
		,shiyo.dt_shiyo
		,anbun.no_lot_seihin
		,anbun.kbn_jotai_denso

	-- �g�p���ё��M�Ώۈꎞ�e�[�u�����쐬�i�����E���ƌ����A���ނ̎��т��ꌳ���j
	INSERT INTO @densoTable (
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	)
	SELECT
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	FROM
		@densoTable_genryo
	-- �g�p�����O�̎��т͓`�����Ȃ��i�̔ԑO�ɍi�荞�ނ��ƂŁA���ʂȍ̔Ԃ�����j
	WHERE
		su_shiyo <> 0
	-- �Ώۓ����̃f�[�^�ɍi��
	AND dt_shiyo >= @dateTaisho
	
	UNION ALL
	
	SELECT
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	FROM
		@densoTable_shizai
	-- �g�p�����O�̎��т͓`�����Ȃ�
	WHERE
		su_shiyo <> 0
	-- �Ώۓ����̃f�[�^�ɍi��
	AND dt_shiyo >= @dateTaisho
	
	-- �V�[�P���X�ԍ����t���@��������
	DECLARE cursor_denso CURSOR FOR
	SELECT
		no_seq
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,su_shiyo
		,kbn_jotai_denso
	FROM
		@densoTable
	WHERE
		no_seq IS NULL
	
	OPEN cursor_denso
		IF (@@error <> 0)
		BEGIN
			SET @msg = 'CURSOR OPEN ERROR: cursor_denso'
			GOTO Error_Handling
		END
	FETCH NEXT FROM cursor_denso INTO
		@cur_no_seq
		,@cur_cd_hinmei
		,@cur_dt_shiyo
		,@cur_no_lot_seihin
		,@cur_su_shiyo
		,@cur_kbn_jotai_denso

	WHILE @@FETCH_STATUS = 0
	BEGIN	
		EXECUTE usp_cm_Saiban @kbnSaiban, @kbnPrefix, @seqNo OUTPUT

		UPDATE @densoTable
		SET no_seq = @seqNo
		WHERE
			cd_hinmei = @cur_cd_hinmei 
		AND dt_shiyo = @cur_dt_shiyo
		AND no_lot_seihin = @cur_no_lot_seihin

		FETCH NEXT FROM cursor_denso INTO
			@cur_no_seq
			,@cur_cd_hinmei
			,@cur_dt_shiyo
			,@cur_no_lot_seihin
			,@cur_su_shiyo
			,@cur_kbn_jotai_denso
	END
	CLOSE cursor_denso
	DEALLOCATE cursor_denso
	-- �V�[�P���X�ԍ����t���@�����܂�
	
	-- �g�p���ё��M�Ώۃe�[�u���Ƀf�[�^���쐬�i�V�[�P���X�̔Ԍ�̓`���e�[�u���j
	INSERT INTO tr_sap_jisseki_shiyo_denso_taisho (
		no_seq
		,flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,no_lot_shikakari
		,su_shiyo
		,data_key_tr_shikakari
	)
	SELECT
		no_seq
		,@flgJisseki AS flg_yojitsu
		,cd_hinmei
		,dt_shiyo
		,no_lot_seihin
		,NULL AS no_lot_shikakari
		,su_shiyo
		,NULL AS data_key_tr_shikakari
	FROM 
		@densoTable
	
	EXEC usp_sap_jisseki_shiyo_denso_taisho_shuusei
	-- ##### �덷�����I�� #####
	
			
	-- ##### ���M�f�[�^���o #####
	TRUNCATE TABLE tr_sap_jisseki_shiyo_denso
	INSERT INTO tr_sap_jisseki_shiyo_denso (
		kbn_denso_SAP
		,no_seq
		,no_lot_seihin
		,dt_shiyo
		,cd_kojo
		,cd_hinmei
		,su_shiyo
		,cd_tani_SAP
		,type_ido
		,hokan_basho
	)
	-- �V�K�ǉ��f�[�^
	SELECT
		@kbnCreate
		,taisho.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoType AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho taisho
		-- �������b�g�A�g�p���P�ʂőO��Ɣ�r
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
	ON taisho.no_lot_seihin = zen.no_lot_seihin
	AND taisho.dt_shiyo = zen.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON taisho.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani
	-- �O��ɖ������т��擾
	WHERE
		zen.no_lot_seihin IS NULL
		
	UNION ALL
	
	-- �ύX�f�[�^�i�ԁj
	SELECT
		@kbnDelete
		,zen.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoTypeCancel AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho_zen zen
	INNER JOIN (
		SELECT
			h_taisho.no_lot_seihin
			,h_taisho.dt_shiyo
		FROM (
			-- �O�񍡉�ǂ���ɂ�����ύX�ΏۃZ�b�g�i���i�A�g�p���j���擾
			SELECT DISTINCT
				taisho.no_lot_seihin 
				,taisho.dt_shiyo
			FROM tr_sap_jisseki_shiyo_denso_taisho taisho
			INNER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
			ON zen.no_lot_seihin = taisho.no_lot_seihin
			AND zen.dt_shiyo = taisho.dt_shiyo
			-- �Ώۃg�����̎g�p���ƕR�t�����̂����擾���Ȃ�����A�����ł͑Ώۓ��ł̒��o�͕K�v�Ȃ�
		) h_taisho
		INNER JOIN (
			-- �g�p���̕ύX�A���V�s�̕ύX�̂�����т̂ݎ擾
			SELECT DISTINCT
				ISNULL(zen.no_lot_seihin,taisho.no_lot_seihin) AS no_lot_seihin
				,ISNULL(zen.dt_shiyo,taisho.dt_shiyo) AS dt_shiyo
			FROM (
				SELECT
					no_lot_seihin
					,dt_shiyo
					,cd_hinmei
					,su_shiyo
				FROM tr_sap_jisseki_shiyo_denso_taisho_zen
			-- �Ώۃg�����ƕR�t���Ȃ��f�[�^���擾����Ă��܂��̂ŁA�Ώۓ��ōi�荞��
			WHERE dt_shiyo >= @dateTaisho
			) zen
			FULL OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho taisho
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.dt_shiyo = zen.dt_shiyo
			AND taisho.cd_hinmei = zen.cd_hinmei
			WHERE
				-- ���L�O�_�����ꂩ�ɓ��Ă͂܂���т̃Z�b�g���擾
				-- �P�D�g�p�����قȂ�
				-- �Q�D�Ώۃg������NULL�i�����폜�j
				-- �R�D�O��g������NULL�i�����ǉ��j
				ISNULL(taisho.su_shiyo,0) <> ISNULL(zen.su_shiyo,0)
		)h_check
		ON h_taisho.no_lot_seihin = h_check.no_lot_seihin
		AND h_taisho.dt_shiyo = h_check.dt_shiyo
	)henko
	ON henko.no_lot_seihin = zen.no_lot_seihin
	AND henko.dt_shiyo = zen.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON zen.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani

	UNION ALL

	-- �ύX�f�[�^�i���j
	SELECT
		@kbnCreate
		,taisho.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(taisho.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,taisho.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(taisho.cd_hinmei) AS cd_hinmei
		,taisho.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoType AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho taisho
	INNER JOIN (
		SELECT
			h_taisho.no_lot_seihin
			,h_taisho.dt_shiyo
		FROM (
			-- �O�񍡉�ǂ���ɂ�����ύX�ΏۃZ�b�g�i���i�A�g�p���j���擾
			SELECT DISTINCT
				taisho.no_lot_seihin 
				,taisho.dt_shiyo
			FROM tr_sap_jisseki_shiyo_denso_taisho taisho
			INNER JOIN tr_sap_jisseki_shiyo_denso_taisho_zen zen
			ON zen.no_lot_seihin = taisho.no_lot_seihin
			AND zen.dt_shiyo = taisho.dt_shiyo
			-- �Ώۃg�����̎g�p���ƕR�t�����̂����擾���Ȃ�����A�����ł͑Ώۓ��ł̒��o�͕K�v�Ȃ��H
			-- WHERE zen.dt_shiyo >= @dateTaisho
		) h_taisho
		INNER JOIN (
			-- �g�p���̕ύX�A���V�s�̕ύX�̂�����т̂ݎ擾
			SELECT DISTINCT
				ISNULL(zen.no_lot_seihin,taisho.no_lot_seihin) AS no_lot_seihin
				,ISNULL(zen.dt_shiyo,taisho.dt_shiyo) AS dt_shiyo
			FROM (
				SELECT
					no_lot_seihin
					,dt_shiyo
					,cd_hinmei
					,su_shiyo
				FROM tr_sap_jisseki_shiyo_denso_taisho_zen
			-- �Ώۃg�����ƕR�t���Ȃ��f�[�^���擾����Ă��܂��̂ŁA�Ώۓ��ōi�荞��
			WHERE dt_shiyo >= @dateTaisho
			) zen
			FULL OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho taisho
			ON taisho.no_lot_seihin = zen.no_lot_seihin
			AND taisho.dt_shiyo = zen.dt_shiyo
			AND taisho.cd_hinmei = zen.cd_hinmei
			WHERE
				-- ���L�O�_�����ꂩ�ɓ��Ă͂܂���т̃Z�b�g���擾
				-- �P�D�g�p�����قȂ�
				-- �Q�D�Ώۃg������NULL�i�����폜�j
				-- �R�D�O��g������NULL�i�����ǉ��j
				ISNULL(taisho.su_shiyo,0) <> ISNULL(zen.su_shiyo,0)
		)h_check
		ON h_taisho.no_lot_seihin = h_check.no_lot_seihin
		AND h_taisho.dt_shiyo = h_check.dt_shiyo
	)henko
	ON henko.no_lot_seihin = taisho.no_lot_seihin
	AND henko.dt_shiyo = taisho.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON taisho.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani

	UNION ALL

	-- �폜�f�[�^
	SELECT
		@kbnDelete
		,zen.no_seq
		,CASE WHEN EXISTS 
				(SELECT TOP 1 cd_kojo FROM ma_kojo WHERE cd_kojo= '4010') THEN '41' 
				ELSE  SUBSTRING((SELECT TOP 1 cd_kojo FROM ma_kojo),1,2) END + 
			SUBSTRING(zen.no_lot_seihin, 4, 10) AS no_lot_seihin
		,CONVERT(DECIMAL,CONVERT(NVARCHAR,zen.dt_shiyo,112)) AS dt_shiyo
		,@cd_kojo
		,UPPER(zen.cd_hinmei) AS cd_hinmei
		,zen.su_shiyo
		,saptani.cd_tani_henkan AS cd_tani_SAP
		,@idoTypeCancel AS type_ido
		,null AS hokan_basho
	FROM
		tr_sap_jisseki_shiyo_denso_taisho_zen zen
	-- �O��ɂ��邪�ΏۂɊ܂܂�Ȃ����т��擾
	LEFT OUTER JOIN tr_sap_jisseki_shiyo_denso_taisho taisho
	ON taisho.no_lot_seihin = zen.no_lot_seihin
	AND taisho.dt_shiyo = zen.dt_shiyo
	LEFT JOIN ma_hinmei hin
	ON zen.cd_hinmei = hin.cd_hinmei
	LEFT JOIN ma_sap_tani_henkan saptani
	ON hin.cd_tani_shiyo = saptani.cd_tani
	WHERE
		taisho.no_lot_seihin IS NULL 
	AND zen.dt_shiyo >= @dateTaisho

	RETURN

	-- //////////// --
	--  �G���[����
	-- //////////// --
	Error_Handling:
		CLOSE cursor_denso
		DEALLOCATE cursor_denso
		PRINT @msg

		RETURN

END




GO
