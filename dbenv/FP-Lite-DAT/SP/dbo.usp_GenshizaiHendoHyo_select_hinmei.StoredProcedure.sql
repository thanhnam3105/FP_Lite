IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiHendoHyo_select_hinmei') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiHendoHyo_select_hinmei]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.02.04>
-- Last Update: <2017.01.06 NAM>
-- �����ޕϓ��\�F��������/�i�����̎擾����
--     �N�G����...vw_ma_hinmei_07
-- =============================================
CREATE PROCEDURE [dbo].[usp_GenshizaiHendoHyo_select_hinmei]
	@cd_hinmei			VARCHAR(14)		-- ���������F�i���R�[�h
	,@flg_shiyo			SMALLINT		-- �萔�F���g�p�t���O�F�g�p
	,@kbn_hin_genryo 	SMALLINT		-- �萔�F�i�敪�F����
	,@kbn_hin_shizai 	SMALLINT		-- �萔�F�i�敪�F����
	,@kbn_hin_jikagen 	SMALLINT		-- �萔�F�i�敪�F���ƌ���
	,@tani_cs		 	VARCHAR(2)		-- �萔�F�P�ʁFC/S
	,@utc_sysdate		DATETIME		-- �V�X�e�����t
AS
BEGIN

	SET NOCOUNT ON

	-- �i���}�X�^�ƍw����}�X�^�ɂ��鍀�ڂ́A�w����}�X�^��D�悷��
	SELECT
		hin.cd_hinmei
		,hin.nm_hinmei_ja
		,hin.nm_hinmei_en
		,hin.nm_hinmei_zh
		,hin.nm_hinmei_vi
		,COALESCE(konyu.nm_nisugata_hyoji, hin.nm_nisugata_hyoji) AS nm_nisugata_hyoji
		--,CAST(hin.su_hachu_lot_size AS VARCHAR) + ' ' + konyu_tani.nm_tani AS su_hachu_lot_size

		-- �g�p�P�ʂ�C/S�ȊO�͊��Z�������s��
		,CAST(
			CASE WHEN hin.cd_tani_shiyo = @tani_cs
				THEN
					COALESCE(konyu.su_hachu_lot_size, hin.su_hachu_lot_size)
				ELSE
					-- �������b�g�T�C�Y����������̗�
					-- �����_�ȉ�2�P�^�ŁA3�ȍ~�͐؂�̂�
					CAST(
						ROUND(
							(( COALESCE(konyu.su_hachu_lot_size, hin.su_hachu_lot_size)
							 * COALESCE(konyu.su_iri, hin.su_iri)
							 * COALESCE(konyu.wt_nonyu, hin.wt_ko) ) * 100), 1) / 100
					 AS decimal(12, 2))
				END
		  --AS VARCHAR) + ' ' + konyu_tani.nm_tani AS su_hachu_lot_size
		  AS NVARCHAR) + ' ' + konyu_tani.nm_tani AS su_hachu_lot_size
		--,CAST(hin.su_hachu_lot_size AS VARCHAR) + ' ' + konyu_tani.nm_tani AS su_hachu_lot_size

		,hin.cd_tani_shiyo
		,COALESCE(konyu.su_leadtime, hin.dd_leadtime) AS dd_leadtime
		--,hin.su_zaiko_min
		,ROUND(hin.su_zaiko_min,3,1) AS su_zaiko_min
		,hin.kbn_kanzan
		,hin.kbn_hin
		,konyu.cd_torihiki
		,tori.nm_torihiki
		--,hin.dd_kotei
		,kotei.dt_kotei
		,ISNULL(soko.cd_soko, init_ma_soko.cd_soko) AS cd_niuke_basho
		,ISNULL(hin.biko,'') AS biko
	FROM
		ma_hinmei AS hin
	
	-- ���o�����ōi�����i���}�X�^���
	INNER JOIN (
		SELECT cd_hinmei
		FROM ma_hinmei
		WHERE cd_hinmei = @cd_hinmei
		AND (kbn_hin = @kbn_hin_genryo
			OR kbn_hin = @kbn_hin_shizai
			OR kbn_hin = @kbn_hin_jikagen)
	) key_hin
	ON hin.cd_hinmei = key_hin.cd_hinmei

	-- �ŗD��̍w����}�X�^
	INNER JOIN ma_konyu AS konyu
	ON hin.cd_hinmei = konyu.cd_hinmei
	AND konyu.no_juni_yusen =
		(SELECT MIN(no_juni_yusen) AS no_juni_yusen
		 FROM ma_konyu
		 WHERE cd_hinmei = @cd_hinmei
		 AND flg_mishiyo = @flg_shiyo)

	-- �P�ʃ}�X�^
	INNER JOIN ma_tani AS konyu_tani
	ON konyu_tani.flg_mishiyo = @flg_shiyo
	--AND konyu.cd_tani_nonyu = konyu_tani.cd_tani
	AND hin.cd_tani_shiyo = konyu_tani.cd_tani

	-- �����}�X�^
	INNER JOIN ma_torihiki AS tori
	ON tori.flg_mishiyo = @flg_shiyo
	AND konyu.cd_torihiki = tori.cd_torihiki

	-- �Œ��
	LEFT JOIN (
		-- �J�����_�[�}�X�^����c�Ɠ��������擾
		SELECT dt_hizuke AS dt_kotei
			,ROW_NUMBER() OVER(ORDER BY dt_hizuke) - 1 AS no_kotei
		FROM ma_calendar
		WHERE dt_hizuke >= @utc_sysdate
		AND flg_kyujitsu = @flg_shiyo
	) kotei
	ON kotei.no_kotei = COALESCE(hin.dd_kotei, 0)

	-- �׎�ꏊ�ƕR�t���q�ɃR�[�h�擾
	LEFT OUTER JOIN ma_soko soko
	ON soko.cd_soko = hin.cd_niuke_basho

	-- �����l�q�ɃR�[�h�擾
	LEFT OUTER JOIN
	(
		SELECT TOP 1
			cd_soko
		FROM ma_soko
		WHERE
			flg_mishiyo = @flg_shiyo
		ORDER BY cd_soko
	) init_ma_soko
	ON 1 = 1

END



GO
