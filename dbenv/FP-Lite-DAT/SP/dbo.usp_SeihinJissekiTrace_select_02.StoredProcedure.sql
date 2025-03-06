IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinJissekiTrace_select_02') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_02]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\			�F���i���уg���[�X��ʁ@�����i�����g�����ɑ��݂��Ȃ��ꍇ�j
�t�@�C����	�Fusp_SeihinJissekiTrace_select_02
���͈���		�F@no_lot_seihin, @no_seq, @lang
�o�͈���		�F	
�߂�l		�F
�쐬��		�F2016.03.22  Khang
*****************************************************/
CREATE PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_02](
	@no_lot_seihin				VARCHAR(14)			--���i���b�g�ԍ�
	,@no_seq					DECIMAL(8,0)		--�V�[�P���X�ԍ�
	,@kbn_hin_genryo			SMALLINT			--�i�敪(�����j
	,@kbn_hin_jika				SMALLINT			--�i�敪(���ƌ����j
	,@lang						VARCHAR(10)			--�ݒ茾��
)
AS

BEGIN
    DECLARE @tbl_seihin_jisseki_trace TABLE
	(
		no_lot_shikakari		VARCHAR(14)			--���i���b�g�ԍ�
		,no_lot_seihin_moto		VARCHAR(14)			--���̐��i���b�g�ԍ�
		,no_lot_seihin			VARCHAR(14)			--���i���b�g�ԍ�
		,cd_hinmei				VARCHAR(14)			--�i�R�[�h
		,kbn_hin				SMALLINT			--�i�敪
		,no_niuke				VARCHAR(14)			--�׎�ԍ�
		,dt_niuke_genshizai		DATETIME			--�׎��
		,cd_genshizai			VARCHAR(14)			--�����ރR�[�h
		,nm_genshizai			NVARCHAR(50)		--�����ޖ�
		,no_lot_genshizai		VARCHAR(14)			--�����ރ��b�gNo
		,dt_kigen_genshizai		DATETIME			--������-�ܖ�����
		,no_nohinsho_genshizai	VARCHAR(16)			--������-�[�i���ԍ�
	)
	DECLARE @tbl_shikakari TABLE
	(
		no_lot_shikakari		VARCHAR(14)			--���i���b�g�ԍ�
		,no_lot_seihin			VARCHAR(14)			--���i���b�g�ԍ�
	)
	DECLARE @no_lot_seihin_moto VARCHAR(14)

	-- ���̐��i���b�g�ԍ������܂�
	SET @no_lot_seihin_moto = @no_lot_seihin

	WHILE @no_lot_seihin IS NOT NULL
	BEGIN
		INSERT INTO @tbl_seihin_jisseki_trace
		SELECT
			ANBUN.no_lot_shikakari
			,@no_lot_seihin_moto
			,ANBUN.no_lot_seihin
			,TRACE.cd_hinmei
			,TRACE.kbn_hin
			,TRACE.no_niuke
			,NIUKEHIN.dt_niuke_genshizai
			,CASE
				WHEN NIUKEHIN.cd_genshizai IS NULL OR LEN(NIUKEHIN.cd_genshizai) = 0 THEN JIKA.cd_genshizai
				ELSE NIUKEHIN.cd_genshizai
			END AS cd_genshizai
			,CASE
				WHEN NIUKEHIN.nm_genshizai IS NULL OR LEN(NIUKEHIN.nm_genshizai) = 0 THEN JIKA.nm_genshizai
				ELSE NIUKEHIN.nm_genshizai
			END AS nm_genshizai
			,CASE
				WHEN NIUKEHIN.no_lot_genshizai IS NULL OR LEN(NIUKEHIN.no_lot_genshizai) = 0 THEN JIKA.no_lot_seihin
				ELSE NIUKEHIN.no_lot_genshizai
			END AS no_lot_genshizai
			,CASE
				WHEN NIUKEHIN.dt_kigen_genshizai IS NULL OR LEN(NIUKEHIN.dt_kigen_genshizai) = 0 THEN JIKA.dt_kigen_genshizai
				ELSE NIUKEHIN.dt_kigen_genshizai
			END AS no_lot_genshizai
			,NIUKEHIN.no_nohinsho_genshizai
		FROM
		(
			SELECT
				no_lot_shikakari
				,no_lot_seihin
			FROM tr_sap_shiyo_yojitsu_anbun 
			WHERE no_lot_seihin = @no_lot_seihin
		) ANBUN

		INNER JOIN
		(
			SELECT
				cd_hinmei
				,kbn_hin
				,no_niuke
				,no_lot_shikakari
			FROM tr_lot_trace 
			WHERE ( kbn_hin = @kbn_hin_genryo OR kbn_hin = @kbn_hin_jika )
		) TRACE
		ON TRACE.no_lot_shikakari = ANBUN.no_lot_shikakari

		LEFT OUTER JOIN
		(
			SELECT 
				NIUKE.no_niuke
				,NIUKE.cd_hinmei AS cd_genshizai
				,CASE @lang 
					WHEN 'ja' THEN 
						CASE 
							WHEN HIN_GENSHIZAI.nm_hinmei_ja IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_ja) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
							ELSE HIN_GENSHIZAI.nm_hinmei_ja
						END
					WHEN 'en' THEN
						CASE 
							WHEN HIN_GENSHIZAI.nm_hinmei_en IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_en) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
							ELSE HIN_GENSHIZAI.nm_hinmei_en
						END
					WHEN 'zh' THEN
						CASE 
							WHEN HIN_GENSHIZAI.nm_hinmei_zh IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_zh) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
							ELSE HIN_GENSHIZAI.nm_hinmei_zh
						END
					WHEN 'vi' THEN
						CASE 
							WHEN HIN_GENSHIZAI.nm_hinmei_vi IS NULL OR LEN(HIN_GENSHIZAI.nm_hinmei_vi) = 0 THEN HIN_GENSHIZAI.nm_hinmei_ryaku
							ELSE HIN_GENSHIZAI.nm_hinmei_vi
						END
				END AS nm_genshizai
				,NIUKE.no_lot AS no_lot_genshizai
				,NIUKE.dt_niuke AS dt_niuke_genshizai
				,NIUKE.dt_kigen AS dt_kigen_genshizai
				,NIUKE.no_nohinsho AS no_nohinsho_genshizai
			FROM
			(
				SELECT
					no_niuke
					,cd_hinmei
					,no_lot
					,dt_niuke
					,dt_kigen
					,no_nohinsho
				FROM tr_niuke
				WHERE no_seq = @no_seq
			) NIUKE

			LEFT OUTER JOIN 
			(
				SELECT
					cd_hinmei
					,nm_hinmei_ja
					,nm_hinmei_en
					,nm_hinmei_zh
					,nm_hinmei_vi
					,nm_hinmei_ryaku
				FROM ma_hinmei
			) HIN_GENSHIZAI
			ON NIUKE.cd_hinmei = HIN_GENSHIZAI.cd_hinmei		
		) NIUKEHIN
		ON TRACE.no_niuke = NIUKEHIN.no_niuke
		
		LEFT OUTER JOIN
		(
			SELECT
				KEIKAKU.cd_hinmei AS cd_genshizai
				,CASE @lang 
					WHEN 'ja' THEN 
						CASE 
							WHEN GENSHIZAI.nm_hinmei_ja IS NULL OR LEN(GENSHIZAI.nm_hinmei_ja) = 0 THEN GENSHIZAI.nm_hinmei_ryaku
							ELSE GENSHIZAI.nm_hinmei_ja
						END
					WHEN 'en' THEN
						CASE 
							WHEN GENSHIZAI.nm_hinmei_en IS NULL OR LEN(GENSHIZAI.nm_hinmei_en) = 0 THEN GENSHIZAI.nm_hinmei_ryaku
							ELSE GENSHIZAI.nm_hinmei_en
						END
					WHEN 'zh' THEN
						CASE 
							WHEN GENSHIZAI.nm_hinmei_zh IS NULL OR LEN(GENSHIZAI.nm_hinmei_zh) = 0 THEN GENSHIZAI.nm_hinmei_ryaku
							ELSE GENSHIZAI.nm_hinmei_zh
						END
					WHEN 'vi' THEN
						CASE 
							WHEN GENSHIZAI.nm_hinmei_vi IS NULL OR LEN(GENSHIZAI.nm_hinmei_vi) = 0 THEN GENSHIZAI.nm_hinmei_ryaku
							ELSE GENSHIZAI.nm_hinmei_vi
						END
				END AS nm_genshizai
				,KEIKAKU.no_lot_seihin AS no_lot_seihin
				,KEIKAKU.dt_shomi AS dt_kigen_genshizai
			FROM tr_keikaku_seihin KEIKAKU

			LEFT OUTER JOIN 
			(
				SELECT
					cd_hinmei
					,nm_hinmei_ja
					,nm_hinmei_en
					,nm_hinmei_zh
					,nm_hinmei_vi
					,nm_hinmei_ryaku
				FROM ma_hinmei
			) GENSHIZAI
			ON KEIKAKU.cd_hinmei = GENSHIZAI.cd_hinmei		
			
		) JIKA
		ON TRACE.no_niuke = JIKA.no_lot_seihin
		AND TRACE.kbn_hin = @kbn_hin_jika

		INSERT INTO @tbl_shikakari
		SELECT
			no_lot_shikakari
			,no_niuke
		FROM @tbl_seihin_jisseki_trace
		WHERE kbn_hin = @kbn_hin_jika
		AND no_lot_seihin = @no_lot_seihin

		SET @no_lot_seihin =
		(
			SELECT TOP 1
				no_lot_seihin
			FROM @tbl_shikakari
		)

		DELETE FROM @tbl_shikakari
		WHERE no_lot_seihin = @no_lot_seihin
	END

	SELECT 
		no_lot_shikakari
		,no_lot_seihin_moto
		,no_lot_seihin
		,cd_hinmei
		,kbn_hin
		,no_niuke
		,dt_niuke_genshizai
		,cd_genshizai
		,nm_genshizai
		,no_lot_genshizai
		,dt_kigen_genshizai
		,no_nohinsho_genshizai
	FROM @tbl_seihin_jisseki_trace SEIHIN_JISSEKI_TRACE	
--	WHERE kbn_hin = @kbn_hin_genryo
	WHERE kbn_hin IN (@kbn_hin_genryo,@kbn_hin_jika)
	AND no_niuke IS NOT NULL

	-- �ꎞ�e�[�u�����폜���܂�
	DELETE FROM @tbl_shikakari
	DELETE FROM @tbl_seihin_jisseki_trace

END

GO