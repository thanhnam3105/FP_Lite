IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinJissekiTrace_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\			�F���i���уg���[�X��ʁ@����
�t�@�C����	�Fusp_SeihinJissekiTrace_select_01
���͈���		�F@cd_hinmei,
			  @chk_dt_seizo, @dt_seizo_st, @dt_seizo_en
			  @chk_dt_kigen, @dt_kigen_st, @dt_kigen_en,
			  @cd_shokuba, @cd_line, @no_lot_hyoji,
			  @no_seq, @kbn_hin_genryo, @kbn_hin_jika,
			  @lang, @skip, @top, @isExcel
�o�͈���		�F	
�߂�l		�F
�쐬��		�F2016.03.17  Khang
�X�V��      �F2019.02.25  BRC takaki.r �j�A�V���A��ƈ˗�No.502
*****************************************************/
CREATE PROCEDURE [dbo].[usp_SeihinJissekiTrace_select_01](
	@cd_hinmei					VARCHAR(14)			--��������/�i���R�[�h
	,@chk_dt_seizo				SMALLINT			--��������/�������`�F�b�N
	,@dt_seizo_st				DATETIME			--��������/������(�J�n)
	,@dt_seizo_en				DATETIME			--��������/������(�I��)
	,@chk_dt_kigen				SMALLINT			--��������/�ܖ��������`�F�b�N
	,@dt_kigen_st				DATETIME			--��������/�ܖ�������(�J�n)
	,@dt_kigen_en				DATETIME			--��������/�ܖ�������(�I��)
	,@cd_shokuba				VARCHAR(10)			--��������/�E��R�[�h
	,@cd_line					VARCHAR(10)			--��������/���C���R�[�h
	,@no_lot_hyoji				VARCHAR(30)			--��������/�\�����b�gNo
	,@no_seq					DECIMAL(8,0)		--�V�[�P���X�ԍ�
	,@kbn_hin_seihin			SMALLINT			--�i�敪(���i�j
	,@kbn_hin_genryo			SMALLINT			--�i�敪(�����j
	,@kbn_hin_jika				SMALLINT			--�i�敪(���ƌ����j
	,@lang						VARCHAR(10)
	,@skip						DECIMAL(10)
	,@top						DECIMAL(10)
	,@isExcel					BIT
)
AS

BEGIN
    DECLARE  @start				DECIMAL(10)
    DECLARE  @end				DECIMAL(10)
	DECLARE  @true				BIT
	DECLARE  @false				BIT
	DECLARE  @day				SMALLINT
	DECLARE  @zero				SMALLINT
    SET      @start = @skip + 1
    SET      @end   = @skip + @top
    SET      @true  = 1
    SET      @false = 0
    SET		 @day   = 1
	SET		 @zero	= 0

	-- �v�搻�i�e�[�u��
	DECLARE @tbl_keikaku_seihin TABLE
	(
		cn_row					INT					--�s�ԍ�
		,no_lot_seihin			VARCHAR(14)			--���i���b�g�ԍ�
		,dt_seizo				DATETIME			--������
		,cd_seihin				VARCHAR(14)			--���i�R�[�h
		,cd_shokuba				VARCHAR(10)			--�E��R�[�h
		,cd_line				VARCHAR(10)			--���C���R�[�h
		,dt_kigen				DATETIME			--�ܖ�������
		,no_lot_hyoji			VARCHAR(30)			--�\�����b�g�ԍ�
		,kbn_sonzai				BIT					--���݋敪
	)

	-- �����g�����ɑ��݂���e�[�u��
	DECLARE @tbl_seihin_jisseki_trace_02 TABLE
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

	-- �����g�����ɑ��݂��Ȃ��e�[�u��
	DECLARE @tbl_seihin_jisseki_trace_03 TABLE
	(
		no_lot_shikakari		VARCHAR(14)			--���i���b�g�ԍ�
		,no_lot_seihin			VARCHAR(14)			--���i���b�g�ԍ�
		,dt_niuke_genshizai		DATETIME			--�׎��
		,cd_genshizai			VARCHAR(14)			--�����ރR�[�h
		,nm_genshizai			NVARCHAR(50)		--�����ޖ�
		,no_lot_genshizai		VARCHAR(14)			--�����ރ��b�gNo
		,dt_kigen_genshizai		DATETIME			--������-�ܖ�����
		,no_nohinsho_genshizai	VARCHAR(16)			--������-�[�i���ԍ�
	)

	-- ���i�v��g���������ʂ̏����ɂ���Ď��܂�
	INSERT INTO @tbl_keikaku_seihin
	SELECT
		ROW_NUMBER() OVER 
		( 
			PARTITION BY 
				uni.kbn_sonzai
			ORDER BY 
				uni.no_lot_seihin
		) AS cn_row 
		,*
	FROM
	(	
		SELECT
			KEIKAKU_SEIHIN.no_lot_seihin
			,KEIKAKU_SEIHIN.dt_seizo
			,KEIKAKU_SEIHIN.cd_hinmei AS cd_seihin
			,KEIKAKU_SEIHIN.cd_shokuba
			,KEIKAKU_SEIHIN.cd_line
			,KEIKAKU_SEIHIN.dt_shomi AS dt_kigen
			,KEIKAKU_SEIHIN.no_lot_hyoji
			,CASE
				WHEN EXISTS
				(
					SELECT 1
					FROM 
					(
						SELECT
							no_lot_shikakari
						FROM tr_sap_shiyo_yojitsu_anbun
						WHERE no_lot_seihin = KEIKAKU_SEIHIN.no_lot_seihin
					) ANBUN

					INNER JOIN tr_tonyu TONYU
					ON ANBUN.no_lot_shikakari = TONYU.no_lot_seihin
				) THEN @true
				ELSE @false
			END AS kbn_sonzai
		FROM tr_keikaku_seihin KEIKAKU_SEIHIN
		WHERE ( @cd_hinmei IS NULL OR KEIKAKU_SEIHIN.cd_hinmei = @cd_hinmei )
		AND 
		(
			( @chk_dt_seizo = @false ) 
			OR ( @dt_seizo_st <= KEIKAKU_SEIHIN.dt_seizo AND KEIKAKU_SEIHIN.dt_seizo < DATEADD(DD, @day, @dt_seizo_en) )
		)
		AND 
		(
			( @chk_dt_kigen = @false ) 
			OR ( @dt_kigen_st <= KEIKAKU_SEIHIN.dt_shomi AND KEIKAKU_SEIHIN.dt_shomi < DATEADD(DD, @day, @dt_kigen_en) )
		)
		AND ( @cd_shokuba IS NULL OR KEIKAKU_SEIHIN.cd_shokuba = @cd_shokuba )
		AND ( @cd_line IS NULL OR KEIKAKU_SEIHIN.cd_line = @cd_line )
		AND ( @no_lot_hyoji IS NULL OR KEIKAKU_SEIHIN.no_lot_hyoji = @no_lot_hyoji )
	) uni

	DECLARE	@no_lot_seihin	VARCHAR(14)
    DECLARE @totalrows		INT 
    DECLARE @currentrow		INT
	SET		@totalrows	=	( SELECT COUNT(*) FROM @tbl_keikaku_seihin )

	-- �����g�����ɑ��݂��Ȃ��ꍇ�A�g���[�X�p���b�g�g��������Ƃ�܂�
	SET		@currentrow =	0

	WHILE @currentrow < @totalrows  
    BEGIN
		SET @no_lot_seihin = 
		( 
			SELECT DISTINCT
				KEIKAKU.no_lot_seihin 
			FROM @tbl_keikaku_seihin KEIKAKU
						
			INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
			ON KEIKAKU.no_lot_seihin = ANBUN.no_lot_seihin

			WHERE KEIKAKU.cn_row = @currentrow + 1
			AND KEIKAKU.kbn_sonzai = @false
		)

		INSERT INTO @tbl_seihin_jisseki_trace_02
		(
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
		)
		EXECUTE usp_SeihinJissekiTrace_select_02 @no_lot_seihin, @no_seq, @kbn_hin_genryo, @kbn_hin_jika, @lang
		SET @currentrow = @currentrow + 1
	END

	-- �����g�����ɑ��݂���ꍇ�A�����g����������܂�
	SET		@currentrow =	0

	WHILE @currentrow < @totalrows  
    BEGIN
		SET @no_lot_seihin = 
		( 
			SELECT DISTINCT 
				KEIKAKU.no_lot_seihin 
			FROM @tbl_keikaku_seihin KEIKAKU

			INNER JOIN tr_sap_shiyo_yojitsu_anbun ANBUN
			ON KEIKAKU.no_lot_seihin = ANBUN.no_lot_seihin

			WHERE KEIKAKU.cn_row = @currentrow + 1
			AND KEIKAKU.kbn_sonzai = @true
		)

		INSERT INTO @tbl_seihin_jisseki_trace_03
		(
			no_lot_shikakari
			,no_lot_seihin
			,dt_niuke_genshizai
			,cd_genshizai
			,nm_genshizai
			,no_lot_genshizai
			,dt_kigen_genshizai
			,no_nohinsho_genshizai
		)
		EXECUTE usp_SeihinJissekiTrace_select_03 @no_lot_seihin, @no_seq, @lang
		SET @currentrow = @currentrow + 1
	END

	-- ���̃e�[�u���ƌ��ѕt���܂�
    BEGIN
		WITH cte AS
		(
			SELECT
				*
				,ROW_NUMBER() OVER (ORDER BY
					uni.dt_seizo
					,uni.cd_seihin
					,uni.nm_seihin
					,uni.cd_shokuba
					,uni.nm_shokuba
					,uni.cd_line
					,uni.nm_line
					,uni.dt_kigen
					,uni.no_lot_hyoji
					,uni.dt_niuke_genshizai
					,uni.cd_genshizai
					,uni.nm_genshizai
					,uni.no_lot_genshizai
					,uni.dt_kigen_genshizai
					,uni.no_nohinsho_genshizai
				) AS RN
			FROM
			(
				SELECT
					SEIHIN.dt_seizo								--������
					,SEIHIN.cd_seihin							--���i�R�[�h
					,CASE @lang 
						WHEN 'ja' THEN 
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_ja IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_ja) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_ja
							END
						WHEN 'en' THEN
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_en IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_en) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_en
							END
						WHEN 'zh' THEN
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_zh IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_zh) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_zh
							END
						WHEN 'vi' THEN
							CASE 
								WHEN HIN_SEIHIN.nm_hinmei_vi IS NULL OR LEN(HIN_SEIHIN.nm_hinmei_vi) = 0 THEN HIN_SEIHIN.nm_hinmei_ryaku
								ELSE HIN_SEIHIN.nm_hinmei_vi
							END
					END AS nm_seihin							--���i��
					,SEIHIN.cd_shokuba							--�E��R�[�h
					,SHOKUBA.nm_shokuba							--�E�ꖼ
					,SEIHIN.cd_line								--���C���R�[�h
					,LINE.nm_line								--���C����
					,SEIHIN.dt_kigen							--�ܖ�������
					,SEIHIN.no_lot_hyoji						--�\���p���b�g�m��
					,SEIHIN_JISSEKI_TRACE.dt_niuke_genshizai		--�׎��
					,SEIHIN_JISSEKI_TRACE.cd_genshizai			--�����ރR�[�h
					,SEIHIN_JISSEKI_TRACE.nm_genshizai			--�����ޖ�
					,SEIHIN_JISSEKI_TRACE.no_lot_genshizai		--�����ރ��b�gNo
					,SEIHIN_JISSEKI_TRACE.dt_kigen_genshizai		--������-�ܖ�����
					,SEIHIN_JISSEKI_TRACE.no_nohinsho_genshizai	--������-�[�i���ԍ�
				FROM @tbl_keikaku_seihin SEIHIN

				LEFT OUTER JOIN ma_hinmei HIN_SEIHIN
				ON SEIHIN.cd_seihin = HIN_SEIHIN.cd_hinmei

				LEFT OUTER JOIN ma_shokuba SHOKUBA
				ON SEIHIN.cd_shokuba = SHOKUBA.cd_shokuba

				LEFT OUTER JOIN ma_line LINE
				ON SEIHIN.cd_line = LINE.cd_line

				INNER JOIN
				(
					SELECT DISTINCT
						SEIHIN_JISSEKI_TRACE_02.no_lot_seihin_moto
						,SEIHIN_JISSEKI_TRACE_02.dt_niuke_genshizai
						,SEIHIN_JISSEKI_TRACE_02.cd_genshizai
						,SEIHIN_JISSEKI_TRACE_02.nm_genshizai
						,SEIHIN_JISSEKI_TRACE_02.no_lot_genshizai
						,SEIHIN_JISSEKI_TRACE_02.dt_kigen_genshizai
						,SEIHIN_JISSEKI_TRACE_02.no_nohinsho_genshizai
						,SEIHIN_JISSEKI_TRACE_02.kbn_hin
					FROM @tbl_seihin_jisseki_trace_02 SEIHIN_JISSEKI_TRACE_02

					UNION ALL
					
					SELECT DISTINCT
						SEIHIN_JISSEKI_TRACE_03.no_lot_seihin AS no_lot_seihin_moto
						,SEIHIN_JISSEKI_TRACE_03.dt_niuke_genshizai
						,SEIHIN_JISSEKI_TRACE_03.cd_genshizai
						,SEIHIN_JISSEKI_TRACE_03.nm_genshizai
						,SEIHIN_JISSEKI_TRACE_03.no_lot_genshizai
						,SEIHIN_JISSEKI_TRACE_03.dt_kigen_genshizai
						,SEIHIN_JISSEKI_TRACE_03.no_nohinsho_genshizai
						,'2' AS kbn_hin
					FROM @tbl_seihin_jisseki_trace_03 SEIHIN_JISSEKI_TRACE_03
				) SEIHIN_JISSEKI_TRACE
				ON SEIHIN.no_lot_seihin = SEIHIN_JISSEKI_TRACE.no_lot_seihin_moto
				AND SEIHIN_JISSEKI_TRACE.kbn_hin IN (@kbn_hin_genryo,@kbn_hin_jika)
			) uni
		)

		--��ʂɕԋp����l���擾
		SELECT
			cnt
			,cte_row.dt_seizo
			,cte_row.cd_seihin
			,cte_row.nm_seihin
			,cte_row.cd_shokuba
			,cte_row.nm_shokuba
			,cte_row.cd_line
			,cte_row.nm_line
			,cte_row.dt_kigen
			,cte_row.no_lot_hyoji
			,cte_row.dt_niuke_genshizai
			,cte_row.cd_genshizai
			,cte_row.nm_genshizai
			,cte_row.no_lot_genshizai
			,cte_row.dt_kigen_genshizai
			,cte_row.no_nohinsho_genshizai
		FROM
		(
			SELECT 
				MAX(RN) OVER() cnt
				,*
			FROM cte 
		) cte_row
		WHERE
		( 
			(
				@isExcel = @false
				AND RN BETWEEN @start AND @end
			)
			OR (
				@isExcel = @true
			)
		)
	END

	-- �ꎞ�e�[�u�����폜���܂�
	DELETE FROM @tbl_keikaku_seihin
	DELETE FROM @tbl_seihin_jisseki_trace_02
	DELETE FROM @tbl_seihin_jisseki_trace_03

END

GO