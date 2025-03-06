IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiShikakarihinShiyoIchiran_shizai_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiShikakarihinShiyoIchiran_shizai_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================================================
-- Author:		<Author,,tsujita.s>
-- Create date: <Create Date,,2014.06.23>
-- Last Update: <2016.12.13 motojima.m>
-- Description:	<Description,,�����ށE�d�|�i�g�p�ꗗ> 
-- ��������/�i�敪�Łu���ށv���I�����ꂽ�Ƃ��̌�������
--
-- ���� �߂�l�ɏC��������ꍇ ����
-- usp_GenshizaiShikakarihinShiyoIchiran_select_Result�͎�ŏC�����Ă��������I
-- ���ʂŏ�LResult���g�p���Ă��錴���E���ƌ����Ǝd�|�i�̌���SP��
-- �ꎞ�e�[�u���ŕԋp���Ă���ׁA�֐��C���|�[�g�́u����̎擾�v�ł͎擾����܂���
-- ��Result������Ύ��s�ł��܂��B
-- ============================================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiShikakarihinShiyoIchiran_shizai_select]
	@con_kbn_hin		SMALLINT		-- ���������F�i�敪
	,@con_bunrui		VARCHAR(10)		-- ���������F����
	--,@con_name		VARCHAR(50)		-- ���������F����(�i���R�[�hor�i��)
	,@con_name			NVARCHAR(50)	-- ���������F����(�i���R�[�hor�i��)
	,@dt_from			DATETIME		-- ���������F�L�����t
	,@lang				VARCHAR(2)		-- ���������F�u���E�U����
	,@kbn_hin_seihin	SMALLINT		-- �萔�F�i�敪�F���i
	,@kbn_hin_jikagen	SMALLINT		-- �萔�F�i�敪�F���ƌ���
	,@shiyoMishiyoFlg	BIT				-- �萔�F���g�p�t���O�F�g�p
AS
BEGIN

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
	--			shiyo.cd_hinmei
	--			,shiyo.no_han
	--			,yukoS.no_han_max
	--		FROM ma_shiyo_h shiyo
	--		LEFT OUTER JOIN
	--			(
	--				SELECT
	--					maxS.cd_hinmei
	--					,MAX(maxS.no_han) AS 'no_han_max'
	--				FROM ma_shiyo_h maxS
	--				WHERE
	--					maxS.flg_mishiyo = @shiyoMishiyoFlg
	--					AND maxS.dt_from <= @dt_from
	--				GROUP BY maxS.cd_hinmei
	--			) yukoS
	--		ON shiyo.cd_hinmei = yukoS.cd_hinmei
	--		AND shiyo.no_han = yukoS.no_han_max
	--	) yuko
	--WHERE
	--	@dt_from IS NULL
	--	OR (@dt_from IS NOT NULL AND yuko.no_han_max IS NOT NULL)

	-- �L�����t�����ƂɗL���ł̍ő�̂��̂��擾���Ĉꎞ�e�[�u����INSERT���܂�
	SELECT
		han.cd_hinmei
		,MAX(han.no_han) AS 'no_han'
	FROM ma_shiyo_h han
	INNER JOIN (
		-- �L���ȗL�����t��i���R�[�h���ƂɎ擾
		SELECT
			shiyo.cd_hinmei
			,MAX(shiyo.dt_from) AS 'dt_from'
		FROM ma_shiyo_h shiyo
		WHERE
			(@dt_from IS NULL OR (@dt_from IS NOT NULL AND shiyo.dt_from <= @dt_from))
			AND shiyo.flg_mishiyo = @shiyoMishiyoFlg
		GROUP BY shiyo.cd_hinmei
	) yukoDate
	ON han.cd_hinmei = yukoDate.cd_hinmei
	AND han.dt_from = yukoDate.dt_from
	WHERE
		han.flg_mishiyo = @shiyoMishiyoFlg
	GROUP BY han.cd_hinmei


	-- �擾�{����
	SELECT
		kbn.nm_kbn_hin AS 'nm_kbn_hin'
		,genryo.cd_hinmei AS 'cd_hinmei'
		,genryo.nm_hinmei_ja AS 'nm_hinmei_ja'
		,genryo.nm_hinmei_en AS 'nm_hinmei_en'
		,genryo.nm_hinmei_zh AS 'nm_hinmei_zh'
		,genryo.nm_hinmei_vi AS 'nm_hinmei_vi'
		,genryo.flg_mishiyo AS 'mishiyo_hin'
		,'' AS 'cd_shikakari'
--**--
		,null AS 'wt_haigo'
		,shizai.su_shiyo AS 'su_shiyo'
--**--
		,shizai.no_han AS 'no_han'
		,'' AS 'nm_haigo_ja'
		,'' AS 'nm_haigo_en'
		,'' AS 'nm_haigo_zh'
		,'' AS 'nm_haigo_vi'
		,head.flg_mishiyo AS 'mishiyo_shikakari'
		,seihin.cd_hinmei AS 'cd_seihin'
		,seihin.nm_hinmei_ja AS 'nm_seihin_ja'
		,seihin.nm_hinmei_en AS 'nm_seihin_en'
		,seihin.nm_hinmei_zh AS 'nm_seihin_zh'
		,seihin.nm_hinmei_vi AS 'nm_seihin_vi'
		,seihin.flg_mishiyo AS 'mishiyo_seihin'
		,NULL AS 'dt_saishu_shikomi_yotei'
		,NULL AS 'dt_saishu_shikomi'
		,shizai_seizo_yotei.dt_seizo AS 'dt_saishu_seizo_yotei'
		,shizai_seizo_jisseki.dt_seizo AS 'dt_saishu_seizo'
	FROM (
		SELECT cd_hinmei
			,nm_hinmei_ja
			,nm_hinmei_en
			,nm_hinmei_zh
			,nm_hinmei_vi
			,flg_mishiyo
			,kbn_hin
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
	) genryo

	-- �i�敪�}�X�^�F�i�敪�����擾
	LEFT JOIN ma_kbn_hin kbn
	ON kbn.kbn_hin = genryo.kbn_hin

	-- ���ގg�p�}�X�^�{�f�B�F���������̎��ނ��R�t�����ގg�p�}�X�^���擾
	LEFT JOIN (
		SELECT
			b.cd_hinmei
			,b.cd_shizai
			,b.su_shiyo 
			,b.no_han
		FROM ma_shiyo_b b
		INNER JOIN #yukoHanTable yuko
		ON b.cd_hinmei = yuko.cd_hinmei
		AND b.no_han = yuko.no_han
		GROUP BY b.cd_hinmei, b.cd_shizai,b.su_shiyo, b.no_han
	) shizai
	ON genryo.cd_hinmei = shizai.cd_shizai

	-- ���ގg�p�}�X�^�w�b�_�[�F�{�f�B�ɑ΂���w�b�_�[���擾
	LEFT JOIN (
		SELECT
			h.cd_hinmei
			,h.no_han
			,h.flg_mishiyo
		FROM ma_shiyo_h h
		INNER JOIN #yukoHanTable yuko
		ON h.cd_hinmei = yuko.cd_hinmei
		AND h.no_han = yuko.no_han
	) head
	ON head.cd_hinmei = shizai.cd_hinmei
	AND head.no_han = shizai.no_han

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
	ON seihin.cd_hinmei = shizai.cd_hinmei

	-- =================================================
	-- �� shizai_seizo_yotei�F���i_�\��̎��ޏ��
	-- =================================================
	LEFT JOIN (
		SELECT
			body.cd_hinmei
			,body.cd_shizai
			,MAX(seizo_yotei.dt_seizo) AS dt_seizo
			,body.no_han
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
		) info_genryo

		-- ���ގg�p�}�X�^�{�f�B�F���������̎��ނ��R�t�����ގg�p�}�X�^���擾
		LEFT JOIN (
			SELECT
				b.cd_hinmei
				,b.cd_shizai
				,b.no_han
			FROM ma_shiyo_b b
			INNER JOIN #yukoHanTable yuko
			ON b.cd_hinmei = yuko.cd_hinmei
			AND b.no_han = yuko.no_han
			GROUP BY b.cd_hinmei, b.cd_shizai, b.no_han
		) body
		ON info_genryo.cd_hinmei = body.cd_shizai

		-- ���ގg�p�}�X�^�w�b�_�[�F�L�����t�i�J�n�j���擾
		LEFT JOIN (
			SELECT
				h.cd_hinmei
				,h.no_han
				,h.dt_from
			FROM ma_shiyo_h h
			INNER JOIN #yukoHanTable yuko
			ON h.cd_hinmei = yuko.cd_hinmei
			AND h.no_han = yuko.no_han
		) head
		ON head.cd_hinmei = body.cd_hinmei
		AND head.no_han = body.no_han

		-- ���ގg�p�}�X�^�w�b�_�[�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_hinmei
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_shiyo_h ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_hinmei = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han

			LEFT JOIN ma_shiyo_h sub
			ON ma.cd_hinmei = sub.cd_hinmei
			AND ma.dt_from < sub.dt_from

			GROUP BY ma.cd_hinmei, ma.no_han
		) head_to
		ON head.cd_hinmei = head_to.cd_hinmei
		AND head.no_han = head_to.no_han

		-- �i���}�X�^�F���i�p�̕i���}�X�^
		LEFT JOIN (
			SELECT
				cd_hinmei
				--,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_hinmei = body.cd_hinmei

		-- �����v��g����(�\��)�F�����\����p
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
		) seizo_yotei
		ON seizo_yotei.cd_hinmei = seihin.cd_hinmei
		AND seizo_yotei.dt_seizo >= head.dt_from
		AND (head_to.dt_to IS NULL OR
				seizo_yotei.dt_seizo <= head_to.dt_to)

		GROUP BY body.cd_hinmei, body.cd_shizai, body.no_han, seihin.cd_hinmei

	) shizai_seizo_yotei
	ON shizai.cd_hinmei = shizai_seizo_yotei.cd_hinmei
	AND shizai.cd_shizai = shizai_seizo_yotei.cd_shizai
	AND shizai.no_han = shizai_seizo_yotei.no_han
	AND seihin.cd_hinmei = shizai_seizo_yotei.cd_seihin
	-- /////�� shizai_seizo_yotei�F�����܂� �� /////

	-- =================================================
	-- �� shizai_seizo_jisseki�F���i_���т̎��ޏ��
	-- =================================================
	LEFT JOIN (
		SELECT
			body.cd_hinmei
			,body.cd_shizai
			,MAX(seizo_jisseki.dt_seizo) AS dt_seizo
			,body.no_han
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
		) info_genryo

		-- ���ގg�p�}�X�^�{�f�B�F���������̎��ނ��R�t�����ގg�p�}�X�^���擾
		LEFT JOIN (
			SELECT
				b.cd_hinmei
				,b.cd_shizai
				,b.no_han
			FROM ma_shiyo_b b
			INNER JOIN #yukoHanTable yuko
			ON b.cd_hinmei = yuko.cd_hinmei
			AND b.no_han = yuko.no_han
			GROUP BY b.cd_hinmei, b.cd_shizai, b.no_han
		) body
		ON info_genryo.cd_hinmei = body.cd_shizai

		-- ���ގg�p�}�X�^�w�b�_�[�F�L�����t�i�J�n�j���擾
		LEFT JOIN (
			SELECT
				h.cd_hinmei
				,h.no_han
				,h.dt_from
			FROM ma_shiyo_h h
			INNER JOIN #yukoHanTable yuko
			ON h.cd_hinmei = yuko.cd_hinmei
			AND h.no_han = yuko.no_han
		) head
		ON head.cd_hinmei = body.cd_hinmei
		AND head.no_han = body.no_han

		-- ���ގg�p�}�X�^�w�b�_�[�F�L�����t�̏I�������擾
		LEFT JOIN (
			SELECT
				ma.cd_hinmei
				,ma.no_han
				,DATEADD(day, -1, MIN(sub.dt_from)) AS 'dt_to'
			FROM ma_shiyo_h ma
			INNER JOIN #yukoHanTable yuko
			ON ma.cd_hinmei = yuko.cd_hinmei
			AND ma.no_han = yuko.no_han

			LEFT JOIN ma_shiyo_h sub
			ON ma.cd_hinmei = sub.cd_hinmei
			AND ma.dt_from < sub.dt_from

			GROUP BY ma.cd_hinmei, ma.no_han
		) head_to
		ON head.cd_hinmei = head_to.cd_hinmei
		AND head.no_han = head_to.no_han

		-- �i���}�X�^�F���i�p�̕i���}�X�^
		LEFT JOIN (
			SELECT
				cd_hinmei
				--,cd_haigo
			FROM ma_hinmei
			WHERE kbn_hin = @kbn_hin_seihin
			OR kbn_hin = @kbn_hin_jikagen
		) seihin
		ON seihin.cd_hinmei = body.cd_hinmei

		-- �����v��g����(����)�F�������p
		LEFT JOIN (
			SELECT
				cd_hinmei
				,dt_seizo
			FROM tr_keikaku_seihin
			WHERE su_seizo_jisseki IS NOT NULL
		) seizo_jisseki
		ON seizo_jisseki.cd_hinmei = seihin.cd_hinmei
		AND seizo_jisseki.dt_seizo >= head.dt_from
		AND (head_to.dt_to IS NULL OR
				seizo_jisseki.dt_seizo <= head_to.dt_to)

		GROUP BY body.cd_hinmei, body.cd_shizai, body.no_han, seihin.cd_hinmei

	) shizai_seizo_jisseki
	ON shizai.cd_hinmei = shizai_seizo_jisseki.cd_hinmei
	AND shizai.cd_shizai = shizai_seizo_jisseki.cd_shizai
	AND shizai.no_han = shizai_seizo_jisseki.no_han
	AND seihin.cd_hinmei = shizai_seizo_jisseki.cd_seihin
	-- /////�� shizai_seizo_jisseki�F�����܂� �� /////

	ORDER BY genryo.cd_hinmei, shizai.cd_hinmei, shizai.no_han , seihin.cd_hinmei

END
GO
