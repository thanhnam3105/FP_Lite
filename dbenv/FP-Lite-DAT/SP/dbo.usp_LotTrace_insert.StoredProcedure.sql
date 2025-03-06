IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotTrace_insert') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotTrace_insert]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\			�F�d��������ʁ@�g���[�X�p���b�g�g�����Œǉ�����
�t�@�C����		�F@kbn_saiban_genryo_lot, @kbn_prefix_chosei
			 @dt_seizo, @cd_shikakari_hin, @no_lot_shikakari
			 @kbn_hin_shikakari, @kbn_hin_genryo, @kbn_hin_jika, @kbn_shukko
			 @cd_create, @dt_create, @cd_update, @dt_update
���͈���		�Fno_lot_shikakari
�쐬��		�F2016.04.11  Khang
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotTrace_insert]    
	@kbn_saiban_genryo_lot	VARCHAR(2)			--�����g����_�̔ԋ敪
	,@kbn_prefix_chosei		VARCHAR(1)			--�����g����_�̔ԋ敪prefix
	,@dt_seizo 				DATETIME			--��������/������
	,@cd_shikakari_hin		VARCHAR(14)			--�d�|�i�R�[�h
	,@no_lot_shikakari		VARCHAR(14)			--�d�|�i���b�g�ԍ�	
	,@kbn_hin_shikakari		SMALLINT			--�i�敪(���i�j
	,@kbn_hin_genryo		SMALLINT			--�i�敪(�����j
	,@kbn_hin_jika			SMALLINT			--�i�敪(���ƌ����j
	,@kbn_shukko			SMALLINT			--�o�ɋ敪
	,@cd_create				VARCHAR(10)			--�쐬��	
	,@dt_create				DATETIME			--�쐬��
	,@cd_update				VARCHAR(10)			--�X�V��
	,@dt_update				DATETIME			--�X�V��
AS

BEGIN
	-- �d�|�i�v��T�}���[�e�[�u��
	DECLARE @tbl_su_keikaku_shikakari TABLE
	(
		cn_row				INT					--�s�ԍ�
		,no_lot_shikakari	VARCHAR(14)			--�d�|�i���b�g�ԍ�
		,no_kotei			DECIMAL(4,0)		--�H��
		,no_tonyu			DECIMAL(4,0)		--�����ԍ�
		,cd_hinmei			VARCHAR(14)			--�i���R�[�h
		,kbn_hin			SMALLINT			--�i�敪
		,no_niuke			VARCHAR(14)			--�׎�ԍ�
		,flg_henko			SMALLINT			--�ύX�t���O
	)

	DECLARE @no_seq			VARCHAR(14)
	DECLARE @true			BIT
	DECLARE @false			BIT	
	DECLARE @zero			SMALLINT
	DECLARE	@dt_seizo_max	DATETIME

	SET     @true  = 1
    SET     @false = 0
	SET		@zero	= 0
	SET		@dt_seizo_max =
	(
		SELECT
			MAX(CALENDAR.dt_hizuke)
		FROM ma_calendar CALENDAR
		WHERE CALENDAR.dt_hizuke < @dt_seizo
		AND CALENDAR.flg_kyujitsu = @zero
		AND CALENDAR.flg_shukujitsu = @zero
	)

	INSERT INTO @tbl_su_keikaku_shikakari
	SELECT
		ROW_NUMBER() OVER 
		( 
			PARTITION BY 
				uni.no_lot_shikakari
			ORDER BY 
				uni.no_lot_shikakari
		) AS cn_row 
		,*
	FROM
	(
		SELECT
			KEIKAKU.no_lot_shikakari
			,HAIGO_RECIPE.no_kotei
			,HAIGO_RECIPE.no_tonyu
			,HAIGO_RECIPE.cd_hinmei
			,HAIGO_RECIPE.kbn_hin
			,CASE
				WHEN HAIGO_RECIPE.kbn_hin = @kbn_hin_genryo OR HAIGO_RECIPE.kbn_hin = @kbn_hin_jika THEN 
				CASE
					WHEN HAIGO_RECIPE.flg_trace_taishogai IS NULL OR HAIGO_RECIPE.flg_trace_taishogai = @false THEN no_niuke
					ELSE NULL
				END 								
				ELSE NULL
			END AS no_niuke
			,@zero AS flg_henko
		FROM (
			SELECT
				no_lot_shikakari
				,cd_shikakari_hin				
			FROM su_keikaku_shikakari
			WHERE CAST(dt_seizo AS DATE) = CAST(@dt_seizo AS DATE)
			AND cd_shikakari_hin = @cd_shikakari_hin
			AND no_lot_shikakari = @no_lot_shikakari  
			AND (su_batch_jisseki > @zero OR su_batch_jisseki_hasu > @zero)
		) KEIKAKU
	
		INNER JOIN 
		(
			SELECT
				haigo.cd_haigo
				,haigo.no_han
			FROM
			(
				SELECT
					cd_haigo
					,MAX(dt_from) AS dt_from
				FROM ma_haigo_mei 
				WHERE flg_mishiyo = @false
				AND dt_from <= @dt_seizo
				GROUP BY cd_haigo
			) yuko

			LEFT OUTER JOIN dbo.ma_haigo_mei AS haigo
			ON yuko.cd_haigo = haigo.cd_haigo 
			AND yuko.dt_from = haigo.dt_from
		) HAIGO_MEI
		ON KEIKAKU.cd_shikakari_hin = HAIGO_MEI.cd_haigo

		INNER JOIN
		(
			SELECT
				recipe.cd_hinmei
				,recipe.no_kotei
				,recipe.no_tonyu
				,recipe.kbn_hin
				,recipe.cd_haigo
				,recipe.no_han
				,hinmei.flg_trace_taishogai
			FROM ma_haigo_recipe recipe

			LEFT JOIN ma_hinmei hinmei
			ON recipe.cd_hinmei = hinmei.cd_hinmei
			AND hinmei.flg_mishiyo = @false
			WHERE recipe.kbn_hin IN (@kbn_hin_genryo,@kbn_hin_shikakari,@kbn_hin_jika)
		) HAIGO_RECIPE
		ON HAIGO_MEI.cd_haigo = HAIGO_RECIPE.cd_haigo
		AND HAIGO_MEI.no_han = HAIGO_RECIPE.no_han

		LEFT JOIN
		(
			SELECT
				cd_hinmei
				,no_niuke
				,no_lot
			FROM tr_niuke 
			WHERE kbn_nyushukko = @kbn_shukko
			AND kbn_hin = @kbn_hin_genryo
			AND CAST(dt_niuke AS DATE) = CAST(@dt_seizo_max AS DATE)
		) NIUKE
		ON HAIGO_RECIPE.cd_hinmei = NIUKE.cd_hinmei
	) uni

	DECLARE	@no_lot_seihin	VARCHAR(14)
    DECLARE @totalrows		INT 
    DECLARE @currentrow		INT
	SET		@totalrows	=	( SELECT COUNT(*) FROM @tbl_su_keikaku_shikakari )

	-- �d�|�i�v��T�}���[�����ʂ̏����ɂ���Ď��܂�
	SET		@currentrow =	0

	WHILE @currentrow <= @totalrows  
    BEGIN
		EXEC dbo.usp_cm_Saiban @kbn_saiban_genryo_lot, @kbn_prefix_chosei, @no_saiban = @no_seq OUTPUT

		INSERT INTO tr_lot_trace
		(
			no_seq
			,no_lot_shikakari
			,no_kotei
			,no_tonyu
			,cd_hinmei
			,kbn_hin
			,no_niuke
			,flg_henko
			,dt_create
			,cd_create
			,dt_update
			,cd_update
		)
		SELECT
			@no_seq
			,no_lot_shikakari
			,no_kotei
			,no_tonyu
			,cd_hinmei
			,kbn_hin
			,no_niuke
			,flg_henko
			,@dt_create
			,@cd_create
			,@dt_update
			,@cd_update
		FROM @tbl_su_keikaku_shikakari
		WHERE cn_row = @currentrow

		SET @currentrow = @currentrow + 1
	END

	-- �ꎞ�e�[�u�����폜���܂�
	DELETE FROM @tbl_su_keikaku_shikakari

END
GO