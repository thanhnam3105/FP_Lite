IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShikakarihinShiyoIchiran_shikakari_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShikakarihinShiyoIchiran_shikakari_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.06.26>
-- Last Update: <2018.01.30 motojima.m>
-- Description:	<Description,,�����ށE�d�|�i�g�p�ꗗ> 
-- ��������/�i�敪�Łu�d�|�i�v���I�����ꂽ�Ƃ��̌�������
--
-- ���� �߂�l�ɏC��������ꍇ ����
-- usp_GenshizaiShikakarihinShiyoIchiran_select_Result�͎�ŏC�����Ă��������I
-- �ꎞ�e�[�u���ŕԋp���Ă���ׁA�֐��C���|�[�g�́u����̎擾�v�ł͎擾����܂���
-- ��Result������Ύ��s�ł��܂��B
-- =================================================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShikakarihinShiyoIchiran_shikakari_select]
	@con_kbn_hin		smallint		-- ���������F�i�敪
	,@con_bunrui		varchar(10)		-- ���������F����
	--,@con_name		varchar(50)		-- ���������F����(�i���R�[�hor�i��)
	,@con_name			nvarchar(50)	-- ���������F����(�i���R�[�hor�i��)
	,@dt_from			DATETIME		-- ���������F�L�����t
	,@lang				varchar(2)		-- ���������F�u���E�U����
	,@kbn_hin_seihin	smallint		-- �萔�F�i�敪�F���i
	,@kbn_hin_shikakari	smallint		-- �萔�F�i�敪�F�d�|�i
	,@kbn_hin_jikagen	smallint		-- �萔�F�i�敪�F���ƌ���
	,@shiyoMishiyoFlg	BIT				-- �萔�F���g�p�t���O�F�g�p
AS
BEGIN

	-- �ϐ����X�g
	--DECLARE @msg			VARCHAR(200)		-- �������ʃ��b�Z�[�W�i�[�p
	DECLARE @msg			NVARCHAR(200)		-- �������ʃ��b�Z�[�W�i�[�p
	DECLARE @kaiso			DECIMAL(2, 0) = 1	-- �K�w���F�����l1
	DECLARE @target_code	VARCHAR(14)			-- ���������d�|�i�R�[�h�̃`�F�b�N�p

	-- ==============================
	--  �ꎞ�e�[�u���̍쐬
	-- ==============================
	-- �ԋp�p�̃��[�N�e�[�u��
	create table #return_work (
		nm_kbn_hin					NVARCHAR(50)
		,cd_hinmei					VARCHAR(14)
		,nm_hinmei_ja				NVARCHAR(50)
		--,nm_hinmei_en				VARCHAR(50)
		,nm_hinmei_en				NVARCHAR(50)
		,nm_hinmei_zh				NVARCHAR(50)
		,nm_hinmei_vi				NVARCHAR(50)
		,mishiyo_hin				SMALLINT
		,cd_shikakari				VARCHAR(14)
		,wt_haigo					DECIMAL(12,6)
		,su_shiyo					DECIMAL(12,6)
		,no_han						DECIMAL(4, 0)
		,nm_haigo_ja				NVARCHAR(50)
		--,nm_haigo_en				VARCHAR(50)
		,nm_haigo_en				NVARCHAR(50)
		,nm_haigo_zh				NVARCHAR(50)
		,nm_haigo_vi				NVARCHAR(50)
		,mishiyo_shikakari			SMALLINT
		,cd_seihin					VARCHAR(14)
		,nm_seihin_ja				NVARCHAR(50)
		,nm_seihin_en				VARCHAR(50)
		,nm_seihin_zh				NVARCHAR(50)
		,nm_seihin_vi				NVARCHAR(50)
		,mishiyo_seihin				SMALLINT
		,dt_saishu_shikomi_yotei	DATETIME
		,dt_saishu_shikomi			DATETIME
		,dt_saishu_seizo_yotei		DATETIME
		,dt_saishu_seizo			DATETIME
	)

	-- �t�W�J�p�̈ꎞ���[�N�e�[�u��1
	create table #tmp_work1 (
		nm_kbn_hin1					NVARCHAR(50)
		,cd_hinmei1					VARCHAR(14)
		,nm_hinmei_ja1				NVARCHAR(50)
		--,nm_hinmei_en1			VARCHAR(50)
		,nm_hinmei_en1				NVARCHAR(50)
		,nm_hinmei_zh1				NVARCHAR(50)
		,nm_hinmei_vi1				NVARCHAR(50)
		,mishiyo_hin1				SMALLINT
		,cd_shikakari1				VARCHAR(14)
		,wt_haigo1					DECIMAL(12,6)
		,su_shiyo1					DECIMAL(12,6)
		,no_han1					DECIMAL(4, 0)
		,nm_haigo_ja1				NVARCHAR(50)
		--,nm_haigo_en1				VARCHAR(50)
		,nm_haigo_en1				NVARCHAR(50)
		,nm_haigo_zh1				NVARCHAR(50)
		,nm_haigo_vi1				NVARCHAR(50)
		,mishiyo_shikakari1			SMALLINT
		,cd_seihin1					VARCHAR(14)
		,nm_seihin_ja1				NVARCHAR(50)
		,nm_seihin_en1				VARCHAR(50)
		,nm_seihin_zh1				NVARCHAR(50)
		,nm_seihin_vi1				NVARCHAR(50)
		,mishiyo_seihin1			SMALLINT
		,dt_saishu_shikomi_yotei1	DATETIME
		,dt_saishu_shikomi1			DATETIME
		,dt_saishu_seizo_yotei1		DATETIME
		,dt_saishu_seizo1			DATETIME
		,wk_cd_shikakari1			VARCHAR(14)
	)
	-- �t�W�J�p�̈ꎞ���[�N�e�[�u��2
	create table #tmp_work2 (
		nm_kbn_hin2					NVARCHAR(50)
		,cd_hinmei2					VARCHAR(14)
		,nm_hinmei_ja2				NVARCHAR(50)
		--,nm_hinmei_en2			VARCHAR(50)
		,nm_hinmei_en2				NVARCHAR(50)
		,nm_hinmei_zh2				NVARCHAR(50)
		,nm_hinmei_vi2				NVARCHAR(50)
		,mishiyo_hin2				SMALLINT
		,cd_shikakari2				VARCHAR(14)
		,wt_haigo2					DECIMAL(12,6)
		,su_shiyo2					DECIMAL(12,6)
		,no_han2					DECIMAL(4, 0)
		,nm_haigo_ja2				NVARCHAR(50)
		--,nm_haigo_en2				VARCHAR(50)
		,nm_haigo_en2				NVARCHAR(50)
		,nm_haigo_zh2				NVARCHAR(50)
		,nm_haigo_vi2				NVARCHAR(50)
		,mishiyo_shikakari2			SMALLINT
		,cd_seihin2					VARCHAR(14)
		,nm_seihin_ja2				NVARCHAR(50)
		,nm_seihin_en2				VARCHAR(50)
		,nm_seihin_zh2				NVARCHAR(50)
		,nm_seihin_vi2				NVARCHAR(50)
		,mishiyo_seihin2			SMALLINT
		,dt_saishu_shikomi_yotei2	DATETIME
		,dt_saishu_shikomi2			DATETIME
		,dt_saishu_seizo_yotei2		DATETIME
		,dt_saishu_seizo2			DATETIME
		,wk_cd_shikakari2			VARCHAR(14)
	)
	-- �L���ŕێ��e�[�u��
	CREATE TABLE #yukoHanTable (
		cd_hinmei					VARCHAR(14)
		,no_han						DECIMAL(4,0)
	)

	-- ===========================
	--  ���[�N�e�[�u���ւ�INSERT
	-- ===========================
	INSERT INTO #yukoHanTable (
		cd_hinmei
		,no_han
	)
	--SELECT
	--	yuko.cd_hinmei
	--	,yuko.no_han
	--FROM
	--	(
	--		SELECT
	--			haigo.cd_haigo AS 'cd_hinmei'
	--			,haigo.no_han
	--			,yukoH.no_han_max
	--		FROM ma_haigo_mei haigo
	--		LEFT OUTER JOIN
	--			(
	--				SELECT
	--					maxH.cd_haigo
	--					,MAX(maxH.no_han) AS 'no_han_max'
	--				FROM ma_haigo_mei maxH
	--				WHERE
	--					maxH.flg_mishiyo = @shiyoMishiyoFlg
	--					AND maxH.dt_from <= @dt_from
	--				GROUP BY maxH.cd_haigo
	--			) yukoH
	--		ON haigo.cd_haigo = yukoH.cd_haigo
	--		AND haigo.no_han = yukoH.no_han_max
	--	) yuko
	--WHERE
	--	@dt_from IS NULL
	--	OR (@dt_from IS NOT NULL AND yuko.no_han_max IS NOT NULL)

	-- �L�����t�����ƂɗL���ł̍ő�̂��̂��擾���Ĉꎞ�e�[�u����INSERT���܂�
	SELECT
		han.cd_haigo
		,MAX(han.no_han) AS 'no_han'
	FROM ma_haigo_mei han
	INNER JOIN (
		-- �L���ȗL�����t��i���R�[�h���ƂɎ擾
		SELECT
			haigo.cd_haigo
			,MAX(haigo.dt_from) AS 'dt_from'
		FROM ma_haigo_mei haigo
		WHERE
			(@dt_from IS NULL OR (@dt_from IS NOT NULL AND haigo.dt_from <= @dt_from))
			AND haigo.flg_mishiyo = @shiyoMishiyoFlg
		GROUP BY haigo.cd_haigo
	) yukoDate
	ON han.cd_haigo = yukoDate.cd_haigo
	AND han.dt_from = yukoDate.dt_from
	WHERE
		han.flg_mishiyo = @shiyoMishiyoFlg
	GROUP BY han.cd_haigo




	INSERT INTO #tmp_work1 (
		nm_kbn_hin1
		,cd_hinmei1
		,nm_hinmei_ja1
		,nm_hinmei_en1
		,nm_hinmei_zh1
		,nm_hinmei_vi1
		,mishiyo_hin1
		,cd_shikakari1
		,wt_haigo1
		,su_shiyo1
		,no_han1
		,nm_haigo_ja1
		,nm_haigo_en1
		,nm_haigo_zh1
		,nm_haigo_vi1
		,mishiyo_shikakari1
		,cd_seihin1
		,nm_seihin_ja1
		,nm_seihin_en1
		,nm_seihin_zh1
		,nm_seihin_vi1
		,mishiyo_seihin1
		,dt_saishu_shikomi_yotei1
		,dt_saishu_shikomi1
		,dt_saishu_seizo_yotei1
		,dt_saishu_seizo1
		,wk_cd_shikakari1
	)
	SELECT
		kbn.nm_kbn_hin AS 'nm_kbn_hin'
		,ma.cd_haigo AS 'cd_hinmei'
		,ma.nm_haigo_ja AS 'nm_hinmei_ja'
		,ma.nm_haigo_en AS 'nm_hinmei_en'
		,ma.nm_haigo_zh AS 'nm_hinmei_zh'
		,ma.nm_haigo_vi AS 'nm_hinmei_vi'
		,ma.flg_mishiyo AS 'mishiyo_hin'
		,haigo.cd_haigo AS 'cd_shikakari'
		,recipe.wt_shikomi AS 'wt_haigo'
		,null AS 'su_shiyo'
		,haigo.no_han AS 'no_han'
		,haigo.nm_haigo_ja AS 'nm_haigo_ja'
		,haigo.nm_haigo_en AS 'nm_haigo_en'
		,haigo.nm_haigo_zh AS 'nm_haigo_zh'
		,haigo.nm_haigo_vi AS 'nm_haigo_vi'
		,haigo.flg_mishiyo AS 'mishiyo_shikakari'
		,seihin.cd_hinmei AS 'cd_seihin'
		,seihin.nm_hinmei_ja AS 'nm_seihin_ja'
		,seihin.nm_hinmei_en AS 'nm_seihin_en'
		,seihin.nm_hinmei_zh AS 'nm_seihin_zh'
		,seihin.nm_hinmei_vi AS 'nm_seihin_vi'
		,seihin.flg_mishiyo AS 'mishiyo_seihin'
		,haigo_shikakari_yotei.dt_seizo AS 'dt_saishu_shikomi_yotei'
		,haigo_shikakari_jisseki.dt_seizo AS 'dt_saishu_shikomi'
		,haigo_seizo_yotei.dt_seizo AS 'dt_saishu_seizo_yotei'
		,haigo_seizo_jisseki.dt_seizo AS 'dt_saishu_seizo'
		,recipe.cd_haigo AS 'wk_cd_shikakari'
	FROM
		ma_haigo_mei ma
	INNER JOIN (
		SELECT
			ma.cd_haigo
			,MAX(ma.no_han) AS no_han
		FROM ma_haigo_mei ma
		INNER JOIN #yukoHanTable yuko
		ON ma.cd_haigo = yuko.cd_hinmei
		AND ma.no_han = yuko.no_han
		WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0 OR
				(ma.cd_haigo like '%' + @con_name + '%'
					OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
					OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
					OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
					OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
				)
			)
		GROUP BY ma.cd_haigo
	) yuko_haigo
	ON ma.cd_haigo = yuko_haigo.cd_haigo
	AND ma.no_han = yuko_haigo.no_han

	-- �i���}�X�^�F���������̎d�|�i���R�t�����i�����邩�ǂ����̔���p
	LEFT JOIN (
		SELECT
			cd_haigo
		FROM ma_hinmei	
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) ma_seihin
	ON ma.cd_haigo = ma_seihin.cd_haigo

	-- �z�����V�s�}�X�^�F���������̎d�|�i���R�t�����V�s���擾
	LEFT JOIN (
		SELECT
			reci.cd_hinmei
			,reci.cd_haigo
--			,reci.wt_shikomi
			,SUM(reci.wt_shikomi) AS wt_shikomi
			,reci.no_han
		FROM ma_haigo_recipe reci
		INNER JOIN #yukoHanTable yuko
		ON reci.cd_haigo = yuko.cd_hinmei
		AND reci.no_han = yuko.no_han
		WHERE reci.kbn_hin = @kbn_hin_shikakari
--		GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.wt_shikomi, reci.no_han
--		GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
		GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
	) recipe
	ON recipe.cd_hinmei = ma.cd_haigo

	-- �z�����}�X�^�F�擾�����z�����V�s�̔z�������擾
	LEFT JOIN (
		SELECT
			ma.cd_haigo
			,ma.nm_haigo_ja
			,ma.nm_haigo_en
			,ma.nm_haigo_zh
			,ma.nm_haigo_vi
			,ma.no_han
			,ma.flg_mishiyo
			,ma.dt_from
			,ma.cd_bunrui
		FROM ma_haigo_mei ma
		INNER JOIN #yukoHanTable yuko
		ON ma.cd_haigo = yuko.cd_hinmei
		AND ma.no_han = yuko.no_han
	) haigo
	ON recipe.cd_haigo = haigo.cd_haigo
	AND recipe.no_han = haigo.no_han
	
	-- �i�敪�}�X�^�F�i�敪�����擾
	LEFT JOIN ma_kbn_hin kbn
	ON kbn.kbn_hin = @kbn_hin_shikakari

	-- �i���}�X�^�F���i�p�̕i���}�X�^
	LEFT JOIN (
		SELECT
			cd_hinmei
			,cd_haigo
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,flg_mishiyo
		FROM ma_hinmei	
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) seihin
	ON recipe.cd_haigo = seihin.cd_haigo

	-- ===============================================
	-- �� haigo_shikakari_yotei�F�d�|�i_�\��̔z�����
	-- ===============================================
	LEFT JOIN (
		SELECT
			recipe.cd_hinmei
			,recipe.cd_haigo
			,MAX(shikakari_yotei.dt_seizo) AS dt_seizo
			,recipe.no_han
		FROM (
			SELECT cd_haigo, no_han
			FROM ma_haigo_mei
		) haigo_meisai
		INNER JOIN (
			SELECT
				ma.cd_haigo
				,MAX(ma.no_han) AS no_han
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
					(ma.cd_haigo like '%' + @con_name + '%'
						OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
						OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
						OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
						OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
					)
				)
			GROUP BY ma.cd_haigo
		) yuko_haigo
		ON haigo_meisai.cd_haigo = yuko_haigo.cd_haigo
		AND haigo_meisai.no_han = yuko_haigo.no_han

		-- �z�����V�s�}�X�^�F���������̎d�|�i���R�t�����V�s���擾
		LEFT JOIN (
			SELECT
				reci.cd_hinmei
				,reci.cd_haigo
--				,reci.wt_shikomi
				,SUM(reci.wt_shikomi) AS wt_shikomi
				,reci.no_han
			FROM ma_haigo_recipe reci
			INNER JOIN #yukoHanTable yuko
			ON reci.cd_haigo = yuko.cd_hinmei
			AND reci.no_han = yuko.no_han
			WHERE reci.kbn_hin = @kbn_hin_shikakari
--			GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
--			GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
			GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
		) recipe
		ON recipe.cd_hinmei = haigo_meisai.cd_haigo

		-- �z�����}�X�^�F�L�����t�̊J�n�����擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,ma.dt_from
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
		) haigo
		ON recipe.cd_haigo = haigo.cd_haigo
		AND recipe.no_han = haigo.no_han

		-- �z�����}�X�^�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				-- ���߂̗L���J�n���̑O��
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			
			LEFT JOIN ma_haigo_mei sub
			ON ma.cd_haigo = sub.cd_haigo
			AND ma.dt_from < sub.dt_from
			
			GROUP BY ma.cd_haigo, ma.no_han
		) haigo_to
		ON haigo.cd_haigo = haigo_to.cd_haigo
		AND haigo.no_han = haigo_to.no_han

		-- �d�|�i�v��T�}���[(�\��)�F�d���\����p
		LEFT JOIN (
			SELECT
				cd_shikakari_hin
				,dt_seizo
			FROM su_keikaku_shikakari
			WHERE wt_shikomi_keikaku IS NOT NULL
		) shikakari_yotei
		ON shikakari_yotei.cd_shikakari_hin = recipe.cd_haigo
		AND shikakari_yotei.dt_seizo >= haigo.dt_from
		AND (haigo_to.dt_to IS NULL OR
				shikakari_yotei.dt_seizo <= haigo_to.dt_to)

		GROUP BY recipe.cd_hinmei, recipe.cd_haigo, recipe.no_han

	) haigo_shikakari_yotei
	ON recipe.cd_hinmei = haigo_shikakari_yotei.cd_hinmei
	AND recipe.cd_haigo = haigo_shikakari_yotei.cd_haigo
	AND recipe.no_han = haigo_shikakari_yotei.no_han
	-- /////�� haigo_shikakari_yotei�F�����܂� �� /////

	-- =================================================
	-- �� haigo_shikakari_jisseki�F�d�|�i_���т̔z�����
	-- =================================================
	LEFT JOIN (
		SELECT
			recipe.cd_hinmei
			,recipe.cd_haigo
			,MAX(shikakari_jisseki.dt_seizo) AS dt_seizo
			,recipe.no_han
		FROM (
			SELECT cd_haigo, no_han
			FROM ma_haigo_mei
		) haigo_meisai
		INNER JOIN (
			SELECT
				ma.cd_haigo
				,MAX(ma.no_han) AS no_han
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
					(ma.cd_haigo like '%' + @con_name + '%'
						OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
						OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
						OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
						OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
					)
				)
			GROUP BY ma.cd_haigo
		) yuko_haigo
		ON haigo_meisai.cd_haigo = yuko_haigo.cd_haigo
		AND haigo_meisai.no_han = yuko_haigo.no_han

		-- �z�����V�s�}�X�^�F���������̎d�|�i���R�t�����V�s���擾
		LEFT JOIN (
			SELECT
				reci.cd_hinmei
				,reci.cd_haigo
--				,reci.wt_shikomi
				,SUM(reci.wt_shikomi) AS wt_shikomi
				,reci.no_han
			FROM ma_haigo_recipe reci
			INNER JOIN #yukoHanTable yuko
			ON reci.cd_haigo = yuko.cd_hinmei
			AND reci.no_han = yuko.no_han
			WHERE reci.kbn_hin = @kbn_hin_shikakari
--			GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
--			GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
			GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
		) recipe
		ON recipe.cd_hinmei = haigo_meisai.cd_haigo

		-- �z�����}�X�^�F�L�����t�̊J�n�����擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,ma.dt_from
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
		) haigo
		ON recipe.cd_haigo = haigo.cd_haigo
		AND recipe.no_han = haigo.no_han

		-- �z�����}�X�^�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			
			LEFT JOIN ma_haigo_mei sub
			ON ma.cd_haigo = sub.cd_haigo
			AND ma.dt_from < sub.dt_from
			
			GROUP BY ma.cd_haigo, ma.no_han
		) haigo_to
		ON haigo.cd_haigo = haigo_to.cd_haigo
		AND haigo.no_han = haigo_to.no_han

		-- �d�|�i�v��T�}���[(����)�F�d�����p
		LEFT JOIN (
			SELECT
				cd_shikakari_hin
				,dt_seizo
			FROM su_keikaku_shikakari
			WHERE wt_shikomi_jisseki IS NOT NULL
		) shikakari_jisseki
		ON shikakari_jisseki.cd_shikakari_hin = recipe.cd_haigo
		AND shikakari_jisseki.dt_seizo >= haigo.dt_from
		AND (haigo_to.dt_to IS NULL OR
				shikakari_jisseki.dt_seizo <= haigo_to.dt_to)

		GROUP BY recipe.cd_hinmei, recipe.cd_haigo, recipe.no_han

	) haigo_shikakari_jisseki
	ON recipe.cd_hinmei = haigo_shikakari_jisseki.cd_hinmei
	AND recipe.cd_haigo = haigo_shikakari_jisseki.cd_haigo
	AND recipe.no_han = haigo_shikakari_jisseki.no_han
	-- /////�� haigo_shikakari_jisseki�F�����܂� �� /////

	-- =================================================
	-- �� haigo_seizo_yotei�F���i_�\��̔z�����
	-- =================================================
	LEFT JOIN (
		SELECT
			recipe.cd_hinmei
			,recipe.cd_haigo
			,MAX(seizo_yotei.dt_seizo) AS dt_seizo
			,recipe.no_han
			,seihin.cd_hinmei AS cd_seihin
		FROM (
			SELECT cd_haigo, no_han
			FROM ma_haigo_mei
		) haigo_meisai
		INNER JOIN (
			SELECT
				ma.cd_haigo
				,MAX(ma.no_han) AS no_han
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
					(ma.cd_haigo like '%' + @con_name + '%'
						OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
						OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
						OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
						OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
					)
				)
			GROUP BY cd_haigo
		) yuko_haigo
		ON haigo_meisai.cd_haigo = yuko_haigo.cd_haigo
		AND haigo_meisai.no_han = yuko_haigo.no_han

		-- �z�����V�s�}�X�^�F���������̌������R�t�����V�s���擾
		LEFT JOIN (
			SELECT
				reci.cd_hinmei
				,reci.cd_haigo
--				,reci.wt_shikomi
				,SUM(reci.wt_shikomi) AS wt_shikomi
				,reci.no_han
			FROM ma_haigo_recipe reci
			INNER JOIN #yukoHanTable yuko
			ON reci.cd_haigo = yuko.cd_hinmei
			AND reci.no_han = yuko.no_han
			WHERE reci.kbn_hin = @con_kbn_hin
--			GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
			GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
		) recipe
		ON recipe.cd_hinmei = haigo_meisai.cd_haigo

		-- �z�����}�X�^�F�L�����t�̊J�n�����擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,ma.dt_from
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
		) haigo
		ON recipe.cd_haigo = haigo.cd_haigo
		AND recipe.no_han = haigo.no_han

		-- �z�����}�X�^�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			
			LEFT JOIN ma_haigo_mei sub
			ON ma.cd_haigo = sub.cd_haigo
			AND ma.dt_from < sub.dt_from
			
			GROUP BY ma.cd_haigo, ma.no_han
		) haigo_to
		ON haigo.cd_haigo = haigo_to.cd_haigo
		AND haigo.no_han = haigo_to.no_han

		-- �i���}�X�^�F���i�p�̕i���}�X�^
		LEFT JOIN (
			SELECT
				cd_hinmei
				,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_haigo = recipe.cd_haigo

		-- �����v��g����(�\��)�F�����\����p
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
		) seizo_yotei
		ON seizo_yotei.cd_hinmei = seihin.cd_hinmei
		AND seizo_yotei.dt_seizo >= haigo.dt_from
		AND (haigo_to.dt_to IS NULL OR
				seizo_yotei.dt_seizo <= haigo_to.dt_to)

		GROUP BY recipe.cd_hinmei, recipe.cd_haigo, recipe.no_han, seihin.cd_hinmei

	) haigo_seizo_yotei
	ON recipe.cd_hinmei = haigo_seizo_yotei.cd_hinmei
	AND recipe.cd_haigo = haigo_seizo_yotei.cd_haigo
	AND recipe.no_han = haigo_seizo_yotei.no_han
	AND seihin.cd_hinmei = haigo_seizo_yotei.cd_seihin
	-- /////�� haigo_seizo_yotei�F�����܂� �� /////

	-- =================================================
	-- �� haigo_seizo_jisseki�F���i_���т̔z�����
	-- =================================================
	LEFT JOIN (
		SELECT
			recipe.cd_hinmei
			,recipe.cd_haigo
			,MAX(seizo_jisseki.dt_seizo) AS dt_seizo
			,recipe.no_han
			,seihin.cd_hinmei AS cd_seihin
		FROM (
			SELECT cd_haigo, no_han
			FROM ma_haigo_mei
		) haigo_meisai
		INNER JOIN (
			SELECT
				ma.cd_haigo
				,MAX(ma.no_han) AS no_han
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
					(ma.cd_haigo like '%' + @con_name + '%'
						OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
						OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
						OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
						OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
					)
				)
			GROUP BY ma.cd_haigo
		) yuko_haigo
		ON haigo_meisai.cd_haigo = yuko_haigo.cd_haigo
		AND haigo_meisai.no_han = yuko_haigo.no_han

		-- �z�����V�s�}�X�^�F���������̌������R�t�����V�s���擾
		LEFT JOIN (
			SELECT
				reci.cd_hinmei
				,reci.cd_haigo
--				,reci.wt_shikomi
				,SUM(reci.wt_shikomi) AS wt_shikomi
				,reci.no_han
			FROM ma_haigo_recipe reci
			INNER JOIN #yukoHanTable yuko
			ON reci.cd_haigo = yuko.cd_hinmei
			AND reci.no_han = yuko.no_han
			WHERE reci.kbn_hin = @con_kbn_hin
--			GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
			GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
		) recipe
		ON recipe.cd_hinmei = haigo_meisai.cd_haigo

		-- �z�����}�X�^�F�L�����t�̊J�n�����擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,ma.dt_from
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
		) haigo
		ON recipe.cd_haigo = haigo.cd_haigo
		AND recipe.no_han = haigo.no_han

		-- �z�����}�X�^�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			
			LEFT JOIN ma_haigo_mei sub
			ON ma.cd_haigo = sub.cd_haigo
			AND ma.dt_from < sub.dt_from
			
			GROUP BY ma.cd_haigo, ma.no_han
		) haigo_to
		ON haigo.cd_haigo = haigo_to.cd_haigo
		AND haigo.no_han = haigo_to.no_han

		-- �i���}�X�^�F���i�p�̕i���}�X�^
		LEFT JOIN (
			SELECT
				cd_hinmei
				,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_haigo = recipe.cd_haigo

		-- �����v��g����(����)�F�������p
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
			WHERE su_seizo_jisseki IS NOT NULL
		) seizo_jisseki
		ON seizo_jisseki.cd_hinmei = seihin.cd_hinmei
		AND seizo_jisseki.dt_seizo >= haigo.dt_from
		AND (haigo_to.dt_to IS NULL OR
				seizo_jisseki.dt_seizo <= haigo_to.dt_to)

		GROUP BY recipe.cd_hinmei, recipe.cd_haigo, recipe.no_han, seihin.cd_hinmei

	) haigo_seizo_jisseki
	ON recipe.cd_hinmei = haigo_seizo_jisseki.cd_hinmei
	AND recipe.cd_haigo = haigo_seizo_jisseki.cd_haigo
	AND recipe.no_han = haigo_seizo_jisseki.no_han
	AND seihin.cd_hinmei = haigo_seizo_jisseki.cd_seihin
	-- /////�� haigo_seizo_jisseki�F�����܂� �� /////

	WHERE
		haigo.cd_haigo IS NOT NULL
	OR (haigo.cd_haigo IS NULL
		AND ma_seihin.cd_haigo IS NULL)

	UNION
	-----------------------------------------------
	-- /*/*/* ���g�����ڕR�t�����i���擾���� */*/*/
	-----------------------------------------------
	SELECT
		kbn.nm_kbn_hin AS 'nm_kbn_hin'
		,ma.cd_haigo AS 'cd_hinmei'
		,ma.nm_haigo_ja AS 'nm_hinmei_ja'
		,ma.nm_haigo_en AS 'nm_hinmei_en'
		,ma.nm_haigo_zh AS 'nm_hinmei_zh'
		,ma.nm_haigo_vi AS 'nm_hinmei_vi'
		,ma.flg_mishiyo AS 'mishiyo_hin'
		,NULL AS 'cd_shikakari'
		,NULL AS 'wt_haigo'
		,NULL AS 'su_shiyo'
		,NULL AS 'no_han'
		,NULL AS 'nm_haigo_ja'
		,NULL AS 'nm_haigo_en'
		,NULL AS 'nm_haigo_zh'
		,NULL AS 'nm_haigo_vi'
		,NULL AS 'mishiyo_shikakari'
		,seihin.cd_hinmei AS 'cd_seihin'
		,seihin.nm_hinmei_ja AS 'nm_seihin_ja'
		,seihin.nm_hinmei_en AS 'nm_seihin_en'
		,seihin.nm_hinmei_zh AS 'nm_seihin_zh'
		,seihin.nm_hinmei_vi AS 'nm_seihin_vi'
		,seihin.flg_mishiyo AS 'mishiyo_seihin'
		,NULL AS 'dt_saishu_shikomi_yotei'
		,NULL AS 'dt_saishu_shikomi'
		,ma_seizo_yotei.dt_seizo AS 'dt_saishu_seizo_yotei'
		,ma_seizo_jisseki.dt_seizo AS 'dt_saishu_seizo'
		,NULL AS 'wk_cd_shikakari'
	FROM
		ma_haigo_mei ma
	INNER JOIN (
		SELECT
			ma.cd_haigo
			,MAX(ma.no_han) AS no_han
		FROM ma_haigo_mei ma
		INNER JOIN #yukoHanTable yuko
		ON ma.cd_haigo = yuko.cd_hinmei
		AND ma.no_han = yuko.no_han
		WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
			AND (LEN(@con_name) = 0 OR
				(ma.cd_haigo like '%' + @con_name + '%'
					OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
					OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
					OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
					OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
				)
			)
		GROUP BY ma.cd_haigo
	) yuko_haigo
	ON ma.cd_haigo = yuko_haigo.cd_haigo
	AND ma.no_han = yuko_haigo.no_han
	
	-- �i�敪�}�X�^�F�i�敪�����擾
	LEFT JOIN ma_kbn_hin kbn
	ON kbn.kbn_hin = @kbn_hin_shikakari

	-- �i���}�X�^�F���i�p�̕i���}�X�^
	LEFT JOIN (
		SELECT
			cd_hinmei
			,cd_haigo
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,flg_mishiyo
		FROM ma_hinmei	
		WHERE kbn_hin = @kbn_hin_seihin
		OR kbn_hin = @kbn_hin_jikagen
	) seihin
	ON ma.cd_haigo = seihin.cd_haigo

	-- =================================================
	-- �� ma_seizo_yotei�F���g�̐��i_�\��̐�����
	-- =================================================
	LEFT JOIN (
		SELECT
			haigo_meisai.cd_haigo
			,MAX(seizo_yotei.dt_seizo) AS dt_seizo
			,haigo_meisai.no_han
			,seihin.cd_hinmei AS cd_seihin
		FROM (
			-- �L�����t�̊J�n�����擾
			SELECT cd_haigo, no_han, dt_from
			FROM ma_haigo_mei
		) haigo_meisai
		INNER JOIN (
			SELECT
				ma.cd_haigo
				,MAX(ma.no_han) AS no_han
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
					(ma.cd_haigo like '%' + @con_name + '%'
						OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
						OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
						OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
						OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
					)
				)
			GROUP BY ma.cd_haigo
		) yuko_haigo
		ON haigo_meisai.cd_haigo = yuko_haigo.cd_haigo
		AND haigo_meisai.no_han = yuko_haigo.no_han

		-- �z�����}�X�^�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			
			LEFT JOIN ma_haigo_mei sub
			ON ma.cd_haigo = sub.cd_haigo
			AND ma.dt_from < sub.dt_from
			
			GROUP BY ma.cd_haigo, ma.no_han
		) haigo_to
		ON haigo_meisai.cd_haigo = haigo_to.cd_haigo
		AND haigo_meisai.no_han = haigo_to.no_han

		-- �i���}�X�^�F���i�p�̕i���}�X�^
		LEFT JOIN (
			SELECT
				cd_hinmei
				,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_haigo = haigo_meisai.cd_haigo

		-- �����v��g����(�\��)�F�����\����p
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
		) seizo_yotei
		ON seizo_yotei.cd_hinmei = seihin.cd_hinmei
		AND seizo_yotei.dt_seizo >= haigo_meisai.dt_from
		AND (haigo_to.dt_to IS NULL OR
				seizo_yotei.dt_seizo <= haigo_to.dt_to)

		GROUP BY haigo_meisai.cd_haigo, haigo_meisai.no_han, seihin.cd_hinmei

	) ma_seizo_yotei
	ON ma.cd_haigo = ma_seizo_yotei.cd_haigo
	AND ma.no_han = ma_seizo_yotei.no_han
	AND seihin.cd_hinmei = ma_seizo_yotei.cd_seihin
	-- /////�� ma_seizo_yotei�F�����܂� �� /////

	-- =================================================
	-- �� ma_seizo_jisseki�F���g�̐��i_���т̐�����
	-- =================================================
	LEFT JOIN (
		SELECT
			haigo_meisai.cd_haigo
			,MAX(seizo_yotei.dt_seizo) AS dt_seizo
			,haigo_meisai.no_han
			,seihin.cd_hinmei AS cd_seihin
		FROM (
			-- �L�����t�̊J�n�����擾
			SELECT cd_haigo, no_han, dt_from
			FROM ma_haigo_mei
		) haigo_meisai
		INNER JOIN (
			SELECT
				ma.cd_haigo
				,MAX(ma.no_han) AS no_han
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			WHERE (LEN(@con_bunrui) = 0 OR ma.cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
					(ma.cd_haigo like '%' + @con_name + '%'
						OR (@lang = 'ja' AND ma.nm_haigo_ja like '%' + @con_name + '%')
						OR (@lang = 'en' AND ma.nm_haigo_en like '%' + @con_name + '%')
						OR (@lang = 'zh' AND ma.nm_haigo_zh like '%' + @con_name + '%')
						OR (@lang = 'vi' AND ma.nm_haigo_vi like '%' + @con_name + '%')
					)
				)
			GROUP BY ma.cd_haigo
		) yuko_haigo
		ON haigo_meisai.cd_haigo = yuko_haigo.cd_haigo
		AND haigo_meisai.no_han = yuko_haigo.no_han

		-- �z�����}�X�^�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_haigo
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_haigo_mei ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_haigo = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han
			
			LEFT JOIN ma_haigo_mei sub
			ON ma.cd_haigo = sub.cd_haigo
			AND ma.dt_from < sub.dt_from
			
			GROUP BY ma.cd_haigo, ma.no_han
		) haigo_to
		ON haigo_meisai.cd_haigo = haigo_to.cd_haigo
		AND haigo_meisai.no_han = haigo_to.no_han

		-- �i���}�X�^�F���i�p�̕i���}�X�^
		LEFT JOIN (
			SELECT
				cd_hinmei
				,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_haigo = haigo_meisai.cd_haigo

		-- �����v��g����(����)�F�����\����p
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
			WHERE su_seizo_jisseki IS NOT NULL
		) seizo_yotei
		ON seizo_yotei.cd_hinmei = seihin.cd_hinmei
		AND seizo_yotei.dt_seizo >= haigo_meisai.dt_from
		AND (haigo_to.dt_to IS NULL OR
				seizo_yotei.dt_seizo <= haigo_to.dt_to)

		GROUP BY haigo_meisai.cd_haigo, haigo_meisai.no_han, seihin.cd_hinmei

	) ma_seizo_jisseki
	ON ma.cd_haigo = ma_seizo_jisseki.cd_haigo
	AND ma.no_han = ma_seizo_jisseki.no_han
	AND seihin.cd_hinmei = ma_seizo_jisseki.cd_seihin
	-- /////�� ma_seizo_jisseki�F�����܂� �� /////

	WHERE seihin.cd_hinmei IS NOT NULL

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :tmp_work1 failed insert.'
        GOTO Error_Handling
    END

	-- ==============================================
	--  �ԋp�p���[�N�e�[�u���ɕ\���Ώۃf�[�^��INSERT
	-- ==============================================
	INSERT INTO #return_work (
		nm_kbn_hin
		,cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,mishiyo_hin
		,cd_shikakari
		,wt_haigo
		,su_shiyo
		,no_han
		,nm_haigo_ja
		,nm_haigo_en
		,nm_haigo_zh
		,nm_haigo_vi
		,mishiyo_shikakari
		,cd_seihin
		,nm_seihin_ja
		,nm_seihin_en
		,nm_seihin_zh
		,nm_seihin_vi
		,mishiyo_seihin
		,dt_saishu_shikomi_yotei
		,dt_saishu_shikomi
		,dt_saishu_seizo_yotei
		,dt_saishu_seizo
	)
	SELECT
		nm_kbn_hin1
		,cd_hinmei1
		,nm_hinmei_ja1
		,nm_hinmei_en1
		,nm_hinmei_zh1
		,nm_hinmei_vi1
		,mishiyo_hin1
		,cd_shikakari1
		,wt_haigo1
		,su_shiyo1
		,no_han1
		,nm_haigo_ja1
		,nm_haigo_en1
		,nm_haigo_zh1
		,nm_haigo_vi1
		,mishiyo_shikakari1
		,cd_seihin1
		,nm_seihin_ja1
		,nm_seihin_en1
		,nm_seihin_zh1
		,nm_seihin_vi1
		,mishiyo_seihin1
		,dt_saishu_shikomi_yotei1
		,dt_saishu_shikomi1
		,dt_saishu_seizo_yotei1
		,dt_saishu_seizo1
	FROM
		#tmp_work1
	WHERE cd_seihin1 IS NOT NULL	-- ���i�����݂���
	OR cd_shikakari1 IS NULL		-- �܂��͎d�|�̕i���R�[�h�̂݁i�ǂ��ɂ��g�p����Ă��Ȃ��d�|�i�j

    IF @@ERROR <> 0
    BEGIN
        SET @msg = 'error :return_work failed insert.'
        GOTO Error_Handling
    END

	-- =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
	--  �� �t �W �J �� �� ��
	-- =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
	-- �d�|�i�R�[�h�����݂����ꍇ�A�������R�t���d�|�i���Ȃ�������������B
	-- �W�J�͍ő�10�K�w�܂łƂ���B
	WHILE (@kaiso <= 10)
	BEGIN
		SET @target_code = NULL	-- ��x�N���A����
		-- ���������̎d�|�i�R�[�h���擾
		SET @target_code = (SELECT TOP 1 wk_cd_shikakari1
							FROM #tmp_work1
							WHERE cd_shikakari1 IS NOT NULL)

		-- �擾���ʂ��Ȃ���ΓW�J�����I��
		IF @target_code IS NULL
			BREAK

		-- =============================================================
		--  �������R�t���d�|�i�̎擾�����F�J�n
		-- =============================================================
		INSERT INTO #tmp_work2 (
			nm_kbn_hin2
			,cd_hinmei2
			,nm_hinmei_ja2
			,nm_hinmei_en2
			,nm_hinmei_zh2
			,nm_hinmei_vi2
			,mishiyo_hin2
			,cd_shikakari2
			,wt_haigo2
			,su_shiyo2
			,no_han2
			,nm_haigo_ja2
			,nm_haigo_en2
			,nm_haigo_zh2
			,nm_haigo_vi2
			,mishiyo_shikakari2
			,cd_seihin2
			,nm_seihin_ja2
			,nm_seihin_en2
			,nm_seihin_zh2
			,nm_seihin_vi2
			,mishiyo_seihin2
			,dt_saishu_shikomi_yotei2
			,dt_saishu_shikomi2
			,dt_saishu_seizo_yotei2
			,dt_saishu_seizo2
			,wk_cd_shikakari2
		)
		-- �擾�����l��ݒ肷��J�����ɂ���AS��t���Ă��܂�
		SELECT
			wk1.nm_kbn_hin1
			,wk1.cd_hinmei1
			,wk1.nm_hinmei_ja1
			,wk1.nm_hinmei_en1
			,wk1.nm_hinmei_zh1
			,wk1.nm_hinmei_vi1
			,wk1.mishiyo_hin1
			,wk1.cd_shikakari1
			,wk1.wt_haigo1
			,wk1.su_shiyo1
			,wk1.no_han1
			,wk1.nm_haigo_ja1
			,wk1.nm_haigo_en1
			,wk1.nm_haigo_zh1
			,wk1.nm_haigo_vi1
			,wk1.mishiyo_shikakari1
			,seihin.cd_hinmei AS 'cd_seihin'
			,seihin.nm_hinmei_ja AS 'nm_seihin_ja'
			,seihin.nm_hinmei_en AS 'nm_seihin_en'
			,seihin.nm_hinmei_zh AS 'nm_seihin_zh'
			,seihin.nm_hinmei_vi AS 'nm_seihin_vi'
			,seihin.flg_mishiyo AS 'mishiyo_seihin'
			,wk1.dt_saishu_shikomi_yotei1
			,wk1.dt_saishu_shikomi1
			,haigo_seizo_yotei.dt_seizo AS 'dt_saishu_seizo_yotei'
			,haigo_seizo_jisseki.dt_seizo AS 'dt_saishu_seizo'
			,recipe.cd_haigo AS 'wk_cd_shikakari'
		FROM (
			SELECT *
			FROM #tmp_work1
			WHERE cd_shikakari1 IS NOT NULL
		) wk1

		-- �z�����V�s�}�X�^�F���������̎d�|�i���R�t�����V�s���擾
		LEFT JOIN (
			SELECT
				reci.cd_hinmei
				,reci.cd_haigo
--				,reci.wt_shikomi
				,SUM(reci.wt_shikomi) AS wt_shikomi
				,reci.no_han
			FROM ma_haigo_recipe reci
			INNER JOIN #yukoHanTable yuko
			ON reci.cd_haigo = yuko.cd_hinmei
			AND reci.no_han = yuko.no_han
			WHERE kbn_hin = @kbn_hin_shikakari
--			GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
--			GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
			GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
		) recipe
		ON wk1.wk_cd_shikakari1 = recipe.cd_hinmei

		-- �i���}�X�^�F���i�p�̕i���}�X�^
		LEFT JOIN (
			SELECT
				cd_hinmei
				,cd_haigo
				,nm_hinmei_ja
				,nm_hinmei_en
				,nm_hinmei_zh
				,nm_hinmei_vi
				,flg_mishiyo
				,kbn_hin
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_haigo = recipe.cd_haigo

		-- =================================================
		-- �� haigo_seizo_yotei�F���i_�\��̔z�����
		-- =================================================
		LEFT JOIN (
			SELECT
				recipe.cd_hinmei
				,recipe.cd_haigo
				,MAX(seizo_yotei.dt_seizo) AS dt_seizo
				,recipe.no_han
				,seihin.cd_hinmei AS cd_seihin
			FROM (
				SELECT cd_hinmei
				FROM ma_hinmei
				WHERE kbn_hin = @con_kbn_hin
				AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
						(cd_hinmei like '%' + @con_name + '%'
							OR (@lang = 'ja' AND nm_hinmei_ja like '%' + @con_name + '%')
							OR (@lang = 'en' AND nm_hinmei_en like '%' + @con_name + '%')
							OR (@lang = 'zh' AND nm_hinmei_zh like '%' + @con_name + '%')
							OR (@lang = 'vi' AND nm_hinmei_vi like '%' + @con_name + '%')
						)
					)
				) haigo_meisai_genryo

			-- �z�����V�s�}�X�^�F���������̌������R�t�����V�s���擾
			LEFT JOIN (
				SELECT
					reci.cd_hinmei
					,reci.cd_haigo
--					,reci.wt_shikomi
					,SUM(reci.wt_shikomi) AS wt_shikomi
					,reci.no_han
				FROM ma_haigo_recipe reci
				INNER JOIN #yukoHanTable yuko
				ON reci.cd_haigo = yuko.cd_hinmei
				AND reci.no_han = yuko.no_han
				WHERE reci.kbn_hin = @con_kbn_hin
--				GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
				GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
			) recipe
			ON recipe.cd_hinmei = haigo_meisai_genryo.cd_hinmei

			-- �z�����}�X�^�F�L�����t�̊J�n�����擾
			LEFT JOIN (
				SELECT
					ma.cd_haigo
					,ma.no_han
					,ma.dt_from
				FROM ma_haigo_mei ma
				INNER JOIN #yukoHanTable yuko
				ON ma.cd_haigo = yuko.cd_hinmei
				AND ma.no_han = yuko.no_han
			) haigo
			ON recipe.cd_haigo = haigo.cd_haigo
			AND recipe.no_han = haigo.no_han

			-- �z�����}�X�^�F�L�����t�̏I�������擾
			LEFT JOIN (
				SELECT
					ma.cd_haigo
					,ma.no_han
					,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
				FROM ma_haigo_mei ma
				INNER JOIN #yukoHanTable yuko
				ON ma.cd_haigo = yuko.cd_hinmei
				AND ma.no_han = yuko.no_han
				
				LEFT JOIN ma_haigo_mei sub
				ON ma.cd_haigo = sub.cd_haigo
				AND ma.dt_from < sub.dt_from
				
				GROUP BY ma.cd_haigo, ma.no_han
			) haigo_to
			ON haigo.cd_haigo = haigo_to.cd_haigo
			AND haigo.no_han = haigo_to.no_han

			-- �i���}�X�^�F���i�p�̕i���}�X�^
			LEFT JOIN (
				SELECT
					cd_hinmei
					,cd_haigo
				FROM ma_hinmei
				WHERE kbn_hin = @kbn_hin_seihin
				OR kbn_hin = @kbn_hin_jikagen
			) seihin
			ON seihin.cd_haigo = recipe.cd_haigo

			-- �����v��g����(�\��)�F�����\����p
			LEFT JOIN (
				SELECT
					cd_hinmei
					,dt_seizo
				FROM tr_keikaku_seihin
			) seizo_yotei
			ON seizo_yotei.cd_hinmei = seihin.cd_hinmei
			AND seizo_yotei.dt_seizo >= haigo.dt_from
			AND (haigo_to.dt_to IS NULL OR
					seizo_yotei.dt_seizo <= haigo_to.dt_to)

			GROUP BY recipe.cd_hinmei, recipe.cd_haigo, recipe.no_han, seihin.cd_hinmei

		) haigo_seizo_yotei
		ON recipe.cd_hinmei = haigo_seizo_yotei.cd_hinmei
		AND recipe.cd_haigo = haigo_seizo_yotei.cd_haigo
		AND recipe.no_han = haigo_seizo_yotei.no_han
		AND seihin.cd_hinmei = haigo_seizo_yotei.cd_seihin
		-- /////�� haigo_seizo_yotei�F�����܂� �� /////

		-- =================================================
		-- �� haigo_seizo_jisseki�F���i_���т̔z�����
		-- =================================================
		LEFT JOIN (
			SELECT
				recipe.cd_hinmei
				,recipe.cd_haigo
				,MAX(seizo_jisseki.dt_seizo) AS dt_seizo
				,recipe.no_han
				,seihin.cd_hinmei AS cd_seihin
			FROM (
				SELECT cd_hinmei
				FROM ma_hinmei
				WHERE kbn_hin = @con_kbn_hin
				AND (LEN(@con_bunrui) = 0 OR cd_bunrui = @con_bunrui)
				AND (LEN(@con_name) = 0 OR
					(cd_hinmei like '%' + @con_name + '%'
						OR (@lang = 'ja' AND nm_hinmei_ja like '%' + @con_name + '%')
						OR (@lang = 'en' AND nm_hinmei_en like '%' + @con_name + '%')
						OR (@lang = 'zh' AND nm_hinmei_zh like '%' + @con_name + '%')
						OR (@lang = 'vi' AND nm_hinmei_vi like '%' + @con_name + '%')
					)
				)
			) haigo_meisai_genryo

			-- �z�����V�s�}�X�^�F���������̌������R�t�����V�s���擾
			LEFT JOIN (
				SELECT
					reci.cd_hinmei
					,reci.cd_haigo
--					,reci.wt_shikomi
					,SUM(reci.wt_shikomi) AS wt_shikomi
					,reci.no_han
				FROM ma_haigo_recipe reci
				INNER JOIN #yukoHanTable yuko
				ON reci.cd_haigo = yuko.cd_hinmei
				AND reci.no_han = yuko.no_han
				WHERE reci.kbn_hin = @con_kbn_hin
--				GROUP BY reci.cd_hinmei, reci.cd_haigo,reci.wt_shikomi, reci.no_han
				GROUP BY reci.cd_hinmei, reci.cd_haigo, reci.no_han
			) recipe
			ON recipe.cd_hinmei = haigo_meisai_genryo.cd_hinmei

			-- �z�����}�X�^�F�L�����t�̊J�n�����擾
			LEFT JOIN (
				SELECT
					ma.cd_haigo
					,ma.no_han
					,ma.dt_from
				FROM ma_haigo_mei ma
				INNER JOIN #yukoHanTable yuko
				ON ma.cd_haigo = yuko.cd_hinmei
				AND ma.no_han = yuko.no_han
			) haigo
			ON recipe.cd_haigo = haigo.cd_haigo
			AND recipe.no_han = haigo.no_han

			-- �z�����}�X�^�F�L�����t�̏I�������擾
			LEFT JOIN (
				SELECT
					ma.cd_haigo
					,ma.no_han
					,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
				FROM ma_haigo_mei ma
				INNER JOIN #yukoHanTable yuko
				ON ma.cd_haigo = yuko.cd_hinmei
				AND ma.no_han = yuko.no_han
				
				LEFT JOIN ma_haigo_mei sub
				ON ma.cd_haigo = sub.cd_haigo
				AND ma.dt_from < sub.dt_from
				
				GROUP BY ma.cd_haigo, ma.no_han
			) haigo_to
			ON haigo.cd_haigo = haigo_to.cd_haigo
			AND haigo.no_han = haigo_to.no_han

			-- �i���}�X�^�F���i�p�̕i���}�X�^
			LEFT JOIN (
				SELECT
					cd_hinmei
					,cd_haigo
				FROM ma_hinmei
				WHERE kbn_hin = @kbn_hin_seihin
				OR kbn_hin = @kbn_hin_jikagen
			) seihin
			ON seihin.cd_haigo = recipe.cd_haigo

			-- �����v��g����(����)�F�������p
			LEFT JOIN (
				SELECT
					cd_hinmei
					,dt_seizo
				FROM tr_keikaku_seihin
				WHERE su_seizo_jisseki IS NOT NULL
			) seizo_jisseki
			ON seizo_jisseki.cd_hinmei = seihin.cd_hinmei
			AND seizo_jisseki.dt_seizo >= haigo.dt_from
			AND (haigo_to.dt_to IS NULL OR
					seizo_jisseki.dt_seizo <= haigo_to.dt_to)

			GROUP BY recipe.cd_hinmei, recipe.cd_haigo, recipe.no_han, seihin.cd_hinmei

		) haigo_seizo_jisseki
		ON recipe.cd_hinmei = haigo_seizo_jisseki.cd_hinmei
		AND recipe.cd_haigo = haigo_seizo_jisseki.cd_haigo
		AND recipe.no_han = haigo_seizo_jisseki.no_han
		AND seihin.cd_hinmei = haigo_seizo_jisseki.cd_seihin
		-- /////�� haigo_seizo_jisseki�F�����܂� �� /////
		-- =============================================================
		--  �������R�t���d�|�i�̎擾�����F�����܂�
		-- =============================================================

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :tenkai :tmp_work2 failed insert.'
			GOTO Error_Handling
		END

		--  �ԋp�p���[�N�e�[�u���ɕ\���Ώۃf�[�^��INSERT
		INSERT INTO #return_work (
			nm_kbn_hin
			,cd_hinmei
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,mishiyo_hin
			,cd_shikakari
			,wt_haigo
			,su_shiyo
			,no_han
			,nm_haigo_ja
			,nm_haigo_en
			,nm_haigo_zh
			,nm_haigo_vi
			,mishiyo_shikakari
			,cd_seihin
			,nm_seihin_ja
			,nm_seihin_en
			,nm_seihin_zh
			,nm_seihin_vi
			,mishiyo_seihin
			,dt_saishu_shikomi_yotei
			,dt_saishu_shikomi
			,dt_saishu_seizo_yotei
			,dt_saishu_seizo
		)
		SELECT
			nm_kbn_hin2
			,cd_hinmei2
			,nm_hinmei_ja2
			,nm_hinmei_en2
			,nm_hinmei_zh2
			,nm_hinmei_vi2
			,mishiyo_hin2
			,cd_shikakari2
			,wt_haigo2
			,su_shiyo2
			,no_han2
			,nm_haigo_ja2
			,nm_haigo_en2
			,nm_haigo_zh2
			,nm_haigo_vi2
			,mishiyo_shikakari2
			,cd_seihin2
			,nm_seihin_ja2
			,nm_seihin_en2
			,nm_seihin_zh2
			,nm_seihin_vi2
			,mishiyo_seihin2
			,dt_saishu_shikomi_yotei2
			,dt_saishu_shikomi2
			,dt_saishu_seizo_yotei2
			,dt_saishu_seizo2
		FROM
			#tmp_work2
		WHERE cd_seihin2 IS NOT NULL	-- ���i�����݂���
		OR wk_cd_shikakari2 IS NULL -- �܂��͕R�t���d�|�i�R�[�h���Ȃ��������R�[�h

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :tenkai :return_work failed insert.'
			GOTO Error_Handling
		END

		-- ���[�N1���N���A���A���[�N2�����[�N1�ɑS�R�s�[������A���[�N2���N���A����
		DELETE #tmp_work1

		INSERT INTO #tmp_work1 (
			nm_kbn_hin1
			,cd_hinmei1
			,nm_hinmei_ja1
			,nm_hinmei_en1
			,nm_hinmei_zh1
			,nm_hinmei_vi1
			,mishiyo_hin1
			,cd_shikakari1
			,wt_haigo1
			,su_shiyo1
			,no_han1
			,nm_haigo_ja1
			,nm_haigo_en1
			,nm_haigo_zh1
			,nm_haigo_vi1
			,mishiyo_shikakari1
			,cd_seihin1
			,nm_seihin_ja1
			,nm_seihin_en1
			,nm_seihin_zh1
			,nm_seihin_vi1
			,mishiyo_seihin1
			,dt_saishu_shikomi_yotei1
			,dt_saishu_shikomi1
			,dt_saishu_seizo_yotei1
			,dt_saishu_seizo1
			,wk_cd_shikakari1
		)
		SELECT
			nm_kbn_hin2
			,cd_hinmei2
			,nm_hinmei_ja2
			,nm_hinmei_en2
			,nm_hinmei_zh2
			,nm_hinmei_vi2
			,mishiyo_hin2
			,cd_shikakari2
			,wt_haigo2
			,su_shiyo2
			,no_han2
			,nm_haigo_ja2
			,nm_haigo_en2
			,nm_haigo_zh2
			,nm_haigo_vi2
			,mishiyo_shikakari2
			,cd_seihin2
			,nm_seihin_ja2
			,nm_seihin_en2
			,nm_seihin_zh2
			,nm_seihin_vi2
			,mishiyo_seihin2
			,dt_saishu_shikomi_yotei2
			,dt_saishu_shikomi2
			,dt_saishu_seizo_yotei2
			,dt_saishu_seizo2
			,wk_cd_shikakari2
		FROM #tmp_work2

		IF @@ERROR <> 0
		BEGIN
			SET @msg = 'error :copy :tmp_work1 failed insert.'
			GOTO Error_Handling
		END

		DELETE #tmp_work2


		-- ���̊K�w��
		SET @kaiso = @kaiso + 1
	END
	-- =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
	--  �� �t �W �J �� �� �� �����܂�
	-- =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=


	-- =========================
	--  �� �I �I �� �� �o �� ��
	-- =========================
	-- ��w�ɐ��i�����݂��Ă���d�|�i�݂̂̃��R�[�h���폜
	DELETE wk
		FROM #return_work wk
		INNER JOIN (
			SELECT
				cd_hinmei
				,cd_shikakari
				,no_han
			FROM #return_work
			WHERE cd_seihin IS NOT NULL
		) exist_seihin
		ON wk.cd_hinmei = exist_seihin.cd_hinmei
		AND wk.cd_shikakari = exist_seihin.cd_shikakari
		AND wk.no_han = exist_seihin.no_han
		WHERE wk.cd_seihin IS NULL

	IF @@ERROR <> 0
	BEGIN
		SET @msg = 'error :return_work failed insert.'
		GOTO Error_Handling
	END

	-- ====================
	--   �� �� �� �� �p
	-- ====================
	SELECT
	DISTINCT
		nm_kbn_hin
		,cd_hinmei
		,nm_hinmei_ja
		,nm_hinmei_en
		,nm_hinmei_zh
		,nm_hinmei_vi
		,mishiyo_hin
		,cd_shikakari
		,wt_haigo
		,su_shiyo
		,no_han
		,nm_haigo_ja
		,nm_haigo_en
		,nm_haigo_zh
		,nm_haigo_vi
		,mishiyo_shikakari
		,cd_seihin
		,nm_seihin_ja
		,nm_seihin_en
		,nm_seihin_zh
		,nm_seihin_vi
		,mishiyo_seihin
		,dt_saishu_shikomi_yotei
		,dt_saishu_shikomi
		,dt_saishu_seizo_yotei
		,dt_saishu_seizo
	FROM #return_work
--	GROUP BY
--		nm_kbn_hin
--		,cd_hinmei
--		,nm_hinmei_ja
--		,nm_hinmei_en
--		,nm_hinmei_zh
--		,mishiyo_hin
--		,cd_shikakari
--		,wt_haigo
--		,su_shiyo
--		,no_han
--		,nm_haigo_ja
--		,nm_haigo_en
--		,nm_haigo_zh
--		,mishiyo_shikakari
--		,cd_seihin
--		,nm_seihin_ja
--		,nm_seihin_en
--		,nm_seihin_zh
--		,mishiyo_seihin
--		,dt_saishu_shikomi_yotei
--		,dt_saishu_shikomi
--		,dt_saishu_seizo_yotei
--		,dt_saishu_seizo
	ORDER BY cd_hinmei, cd_shikakari, no_han, cd_seihin

	RETURN

	-- //////////// --
	--  �G���[����
	-- //////////// --
	Error_Handling:
		DROP TABLE #return_work
		DROP TABLE #tmp_work1
		DROP TABLE #tmp_work2
		DROP TABLE #yukoHanTable
		PRINT @msg

END
GO
