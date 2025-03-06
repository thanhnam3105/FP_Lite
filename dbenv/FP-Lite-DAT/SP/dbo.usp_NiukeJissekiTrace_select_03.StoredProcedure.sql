IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiTrace_select_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiTrace_select_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\			�F�׎���уg���[�X��ʁ@�����i�d�|�i�������j
�t�@�C����	�Fusp_NiukeJissekiTrace_select_03
���͈���		�F@no_niuke, @kbn_hin_genryo, @kbn_hin_jika
�o�͈���		�F	
�߂�l		�F
�쐬��		�F2016.03.30  Khang
�X�V��		�F2016.12.13  motojima.m �����Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeJissekiTrace_select_03](
	@no_niuke					VARCHAR(14)			--�׎�ԍ�
	,@chk_seihin_nomi_hyoji		SMALLINT			--���i�̂ݕ\���`�F�b�N
	,@kbn_hin_seihin			SMALLINT			--�i�敪(���i�j
	,@kbn_hin_genryo			SMALLINT			--�i�敪(�����j
	,@kbn_hin_jika				SMALLINT			--�i�敪(���ƌ����j	
	,@kbn_hin_shikakari			SMALLINT			--�i�敪(�d�|�j
	,@kbn_riyu_chosei			SMALLINT			--�������R
	,@lang						VARCHAR(10)
)
AS

BEGIN
    DECLARE @tbl_niuke_jisseki_trace TABLE
	(
		no_lot_shikakari		VARCHAR(14)			--�d�|���b�g�ԍ�
		,no_lot_seihin			VARCHAR(14)			--���i���b�g�ԍ�
		,cd_hinmei				VARCHAR(14)			--�i�R�[�h
		,kbn_hin				SMALLINT			--�i�敪
		,no_niuke				VARCHAR(14)			--�׎�ԍ�
		,no_niuke_moto			VARCHAR(14)			--���̉׎�ԍ�
		,cd_seihin_keikaku		VARCHAR(14)			--���i�v��
		--,nm_seihin_keikaku	VARCHAR(50)			--���i��
		,nm_seihin_keikaku		NVARCHAR(50)		--���i��
		,dt_seizo_keikaku		DATETIME			--������
		,dt_shomi_keikaku		DATETIME			--�ܖ�������
		,no_lot_hyoji_keikaku	VARCHAR(50)			--�\�����b�g�ԍ�
	)
	DECLARE @no_niuke_moto		VARCHAR(14)
	DECLARE @false				BIT    

	SET @no_niuke_moto = @no_niuke
	SET @false = 0

	WHILE @no_niuke IS NOT NULL
	BEGIN
		INSERT INTO @tbl_niuke_jisseki_trace
		SELECT
			TRACE.no_lot_shikakari
			,ANBUN.no_lot_seihin
			,TRACE.cd_hinmei
			,KEIKAKU_SEIHIN.kbn_hin
			,TRACE.no_niuke
			,@no_niuke_moto
			,KEIKAKU_SEIHIN.cd_hinmei AS cd_seihin_keikaku
			,CASE @lang 
				WHEN 'ja' THEN 
					CASE 
						WHEN KEIKAKU_SEIHIN.nm_hinmei_ja IS NULL OR LEN(KEIKAKU_SEIHIN.nm_hinmei_ja) = 0 THEN KEIKAKU_SEIHIN.nm_hinmei_ryaku
						ELSE KEIKAKU_SEIHIN.nm_hinmei_ja
					END
				WHEN 'en' THEN
					CASE 
						WHEN KEIKAKU_SEIHIN.nm_hinmei_en IS NULL OR LEN(KEIKAKU_SEIHIN.nm_hinmei_en) = 0 THEN KEIKAKU_SEIHIN.nm_hinmei_ryaku
						ELSE KEIKAKU_SEIHIN.nm_hinmei_en
					END
				WHEN 'zh' THEN
					CASE 
						WHEN KEIKAKU_SEIHIN.nm_hinmei_zh IS NULL OR LEN(KEIKAKU_SEIHIN.nm_hinmei_zh) = 0 THEN KEIKAKU_SEIHIN.nm_hinmei_ryaku
						ELSE KEIKAKU_SEIHIN.nm_hinmei_zh
					END
				WHEN 'vi' THEN
					CASE 
						WHEN KEIKAKU_SEIHIN.nm_hinmei_vi IS NULL OR LEN(KEIKAKU_SEIHIN.nm_hinmei_vi) = 0 THEN KEIKAKU_SEIHIN.nm_hinmei_ryaku
						ELSE KEIKAKU_SEIHIN.nm_hinmei_vi
					END
			END AS nm_seihin_keikaku
			,KEIKAKU_SEIHIN.dt_seizo AS dt_seizo_keikaku
			,KEIKAKU_SEIHIN.dt_shomi AS dt_shomi_keikaku
			,KEIKAKU_SEIHIN.no_lot_hyoji AS no_lot_hyoji_keikaku
		FROM
		(
			SELECT
				no_lot_shikakari
				,cd_hinmei
				,no_niuke
			FROM tr_lot_trace
			WHERE no_niuke = @no_niuke
			AND ( kbn_hin = @kbn_hin_genryo OR kbn_hin = @kbn_hin_jika )
		) TRACE
	
		INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
		ON ANBUN.no_lot_shikakari = TRACE.no_lot_shikakari

		INNER JOIN
		(
			SELECT
				KEIKAKU.no_lot_seihin
				,HINMEI.kbn_hin
				,KEIKAKU.cd_hinmei
				,HINMEI.nm_hinmei_ja
				,HINMEI.nm_hinmei_en
				,HINMEI.nm_hinmei_zh
				,HINMEI.nm_hinmei_vi
				,HINMEI.nm_hinmei_ryaku
				,KEIKAKU.dt_seizo
				,KEIKAKU.dt_shomi
				,KEIKAKU.no_lot_hyoji
			FROM tr_keikaku_seihin KEIKAKU

			LEFT OUTER JOIN ma_hinmei HINMEI
			ON KEIKAKU.cd_hinmei = HINMEI.cd_hinmei
		) KEIKAKU_SEIHIN
		ON (ANBUN.no_lot_seihin IS NOT NULL AND ANBUN.no_lot_seihin = KEIKAKU_SEIHIN.no_lot_seihin)

		UNION ALL

		-- �d�|�p
		SELECT
			TRACE.no_lot_shikakari
			,ANBUN.no_lot_seihin
			,TRACE.cd_hinmei
			,NULL AS kbn_hin
			,TRACE.no_niuke
			,@no_niuke_moto
			,KEIKAKU_SHIKAKARI.cd_shikakari_hin AS cd_seihin_keikaku
			,KEIKAKU_SHIKAKARI.nm_shikakari_hin AS nm_seihin_keikaku
			,KEIKAKU_SHIKAKARI.dt_seizo AS dt_seizo_keikaku
			,KEIKAKU_SHIKAKARI.dt_shomi AS dt_shomi_keikaku
			,RIYU.nm_riyu AS no_lot_hyoji_keikaku
		FROM
		(
			SELECT
				no_lot_shikakari
				,cd_hinmei
				,no_niuke
			FROM tr_lot_trace
			WHERE
			(
				( @chk_seihin_nomi_hyoji = @false ) 
				OR ( kbn_hin = @kbn_hin_seihin )
			)
			AND no_niuke = @no_niuke
			AND no_niuke <> @no_niuke_moto
		) TRACE
	
		INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
		ON ANBUN.no_lot_shikakari = TRACE.no_lot_shikakari
		AND ANBUN.no_lot_seihin IS NULL

		LEFT OUTER JOIN
		(
			SELECT
				KEIKAKU.no_lot_shikakari
				,@kbn_hin_shikakari AS kbn_hin
				,KEIKAKU.cd_shikakari_hin
				,CASE @lang 
					WHEN 'ja' THEN 
						CASE 
							WHEN HAIGO.nm_haigo_ja IS NULL OR LEN(HAIGO.nm_haigo_ja) = 0 THEN HAIGO.nm_haigo_ryaku
							ELSE HAIGO.nm_haigo_ja
						END
					WHEN 'en' THEN
						CASE 
							WHEN HAIGO.nm_haigo_en IS NULL OR LEN(HAIGO.nm_haigo_en) = 0 THEN HAIGO.nm_haigo_ryaku
							ELSE HAIGO.nm_haigo_en
						END
					WHEN 'zh' THEN
						CASE 
							WHEN HAIGO.nm_haigo_zh IS NULL OR LEN(HAIGO.nm_haigo_zh) = 0 THEN HAIGO.nm_haigo_ryaku
							ELSE HAIGO.nm_haigo_zh
						END
					WHEN 'vi' THEN
						CASE 
							WHEN HAIGO.nm_haigo_vi IS NULL OR LEN(HAIGO.nm_haigo_vi) = 0 THEN HAIGO.nm_haigo_ryaku
							ELSE HAIGO.nm_haigo_vi
						END
				END AS nm_shikakari_hin
				,KEIKAKU.dt_seizo
				,NULL AS dt_shomi
			FROM su_keikaku_shikakari KEIKAKU

			LEFT OUTER JOIN ma_haigo_mei HAIGO
			ON KEIKAKU.cd_shikakari_hin = HAIGO.cd_haigo
		) KEIKAKU_SHIKAKARI
		ON (ANBUN.no_lot_seihin IS NULL AND ANBUN.no_lot_shikakari = KEIKAKU_SHIKAKARI.no_lot_shikakari)

		LEFT OUTER JOIN ma_riyu RIYU
		ON RIYU.cd_riyu = ANBUN.cd_riyu
		AND RIYU.kbn_bunrui_riyu = @kbn_riyu_chosei

		SET @no_niuke = 
		( 
			SELECT DISTINCT
				LOT_TRACE.no_niuke 
			FROM @tbl_niuke_jisseki_trace NIUKE_TRACE

			INNER JOIN tr_lot_trace LOT_TRACE
			ON NIUKE_TRACE.no_lot_seihin = LOT_TRACE.no_niuke

			WHERE NIUKE_TRACE.no_niuke = @no_niuke
		)
	END

	SELECT 
		no_lot_shikakari
		,no_lot_seihin
		,cd_hinmei
		,kbn_hin
		,no_niuke
		,no_niuke_moto
		,cd_seihin_keikaku
		,nm_seihin_keikaku
		,dt_seizo_keikaku
		,dt_shomi_keikaku
		,no_lot_hyoji_keikaku
	FROM @tbl_niuke_jisseki_trace
	WHERE
	(
		( @chk_seihin_nomi_hyoji = @false ) 
		OR ( kbn_hin = @kbn_hin_seihin )
	)	 

	-- �ꎞ�e�[�u�����폜���܂�
	DELETE FROM @tbl_niuke_jisseki_trace

END

GO