IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_03') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_03]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�׎���� �i���R�[�h����֘A���ڂ̒l���擾���܂��B
�t�@�C����  �Fusp_NiukeNyuryoku_select_03
���͈���    �F@cd_hinmei, @cd_torihiki, @shiyoMishiyoFlg
�o�͈���    �F
�߂�l      �F
�쐬��      �F2013.11.06  ADMAX kakuta.y
�X�V��      �F2022.02.07  BRC   sato.t #1648�Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_03] 
	@cd_hinmei				VARCHAR(14)
	,@cd_torihiki			VARCHAR(13)
	,@shiyoMishiyoFlg		SMALLINT
AS
BEGIN
	DECLARE @blankStr	VARCHAR
	DECLARE @initInt	SMALLINT
	DECLARE @initDeci	DECIMAL(1,0)
	
	SET		@blankStr	= ''
	SET		@initInt	= 0
	SET		@initDeci	= 0;

	IF @cd_torihiki = '' 
		OR @cd_torihiki IS NULL
	
	BEGIN
	
		SELECT	
			m_ko.cd_torihiki													-- �����R�[�h
			,m_tori.nm_torihiki													-- ����於
			,ISNULL(m_ko.cd_torihiki2, @blankStr) AS cd_torihiki2				-- �����R�[�h2
			,m_tori2.nm_torihiki AS nm_torihiki2								-- ����於2
			,ISNULL(m_hin.kbn_hin, @initInt) AS kbn_hin							-- �i�敪
			,m_ko.cd_hinmei														-- �i���R�[�h
			,ISNULL(m_hin.nm_hinmei_ja, @blankStr) AS nm_hinmei_ja				-- �i��(���{��)
			,ISNULL(m_hin.nm_hinmei_en, @blankStr) AS nm_hinmei_en				-- �i��(�p��)
			,ISNULL(m_hin.nm_hinmei_zh, @blankStr) AS nm_hinmei_zh				-- �i��(������)
			,ISNULL(m_hin.nm_hinmei_vi, @blankStr) AS nm_hinmei_vi
			,ISNULL(m_hin.nm_nisugata_hyoji, @blankStr) AS nm_nisugata_hyoji	-- �׎p
			,m_ko.cd_tani_nonyu													-- �[���P�ʃR�[�h
			,m_tan.nm_tani														-- �[���P��
			,m_ko.tan_nonyu														-- �[���P��
			,ISNULL(m_hin.kbn_hokan, @blankStr)	AS kbn_hokan					-- �ۊǋ敪
			,m_hokan.nm_hokan_kbn												-- �i�ʏ��
			,m_ko.su_iri														-- ����
			,m_ko.wt_nonyu														-- ��̗�
			,ISNULL(m_hin.dd_shomi, @initDeci) AS dd_shomi						-- �ܖ�����
			,ISNULL(m_hin.cd_bunrui, @blankStr) AS cd_bunrui					-- ���ރR�[�h
			,m_bun.nm_bunrui													-- ���ޖ�
			,ISNULL(m_hin.biko, @blankStr) AS biko								-- ���l
			,m_hin.kbn_zei														-- �ŋ敪
			,m_hin.cd_niuke_basho												-- �׎�ꏊ�R�[�h
			,m_ko.cd_tani_nonyu_hasu													-- �[���P��(�[��)�R�[�h
			,m_tan_hasu.nm_tani AS nm_tani_hasu														-- �[���P��(�[��)
		FROM ma_konyu m_ko
		INNER JOIN
			(
				SELECT
					cd_hinmei
					,MIN(no_juni_yusen) no_juni_yusen
				FROM ma_konyu
				WHERE
					cd_hinmei = @cd_hinmei
					AND flg_mishiyo = @shiyoMishiyoFlg
				GROUP BY
					cd_hinmei
			) min_ko
		ON m_ko.cd_hinmei = min_ko.cd_hinmei
		AND m_ko.no_juni_yusen = min_ko.no_juni_yusen
		INNER JOIN ma_hinmei m_hin
		ON m_ko.cd_hinmei			= m_hin.cd_hinmei
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan
		ON m_ko.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_torihiki m_tori
		ON m_ko.cd_torihiki = m_tori.cd_torihiki
		AND m_tori.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_tori2
		ON m_ko.cd_torihiki2 = m_tori2.cd_torihiki
		AND m_tori2.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_ko.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE
			m_ko.flg_mishiyo = @shiyoMishiyoFlg
			AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
					
		UNION
		SELECT
			@blankStr AS cd_torihiki											-- �����R�[�h
			,@blankStr AS nm_torihiki											-- ����於
			,@blankStr AS cd_torihiki2											-- �����R�[�h2
			,@blankStr AS nm_torihiki2											-- ����於2
			,ISNULL(m_hin.kbn_hin, @initInt) AS kbn_hin							-- �i�敪
			,m_hin.cd_hinmei													-- �i���R�[�h
			,ISNULL(m_hin.nm_hinmei_ja, @blankStr) AS nm_hinmei_ja				-- �i��(���{��)
			,ISNULL(m_hin.nm_hinmei_en, @blankStr) AS nm_hinmei_en				-- �i��(�p��)
			,ISNULL(m_hin.nm_hinmei_zh, @blankStr) AS nm_hinmei_zh				-- �i��(������)
			,ISNULL(m_hin.nm_hinmei_vi, @blankStr) AS nm_hinmei_vi
			,ISNULL(m_hin.nm_nisugata_hyoji, @blankStr) AS nm_nisugata_hyoji	-- �׎p
			,ISNULL(m_hin.cd_tani_nonyu, @blankStr) AS cd_tani_nonyu			-- �[���P�ʃR�[�h
			,m_tan.nm_tani														-- �[���P��
			,ISNULL(m_hin.tan_nonyu, @initDeci) AS tan_nonyu					-- �[���P��
			,ISNULL(m_hin.kbn_hokan, @blankStr) AS kbn_hokan					-- �ۊǋ敪
			,m_hokan.nm_hokan_kbn												-- �i�ʏ��
			,ISNULL(m_hin.su_iri, @initDeci) AS su_iri							-- ����
			,ISNULL(m_hin.wt_ko, @initDeci) AS wt_nonyu							-- ��̗�
			,ISNULL(m_hin.dd_shomi, @initDeci) AS dd_shomi						-- �ܖ�����
			,ISNULL(m_hin.cd_bunrui, @blankStr) AS cd_bunrui					-- ���ރR�[�h
			,m_bun.nm_bunrui													-- ���ޖ�
			,ISNULL(m_hin.biko, @blankStr) AS biko								-- ���l
			,m_hin.kbn_zei														-- �ŋ敪
			,m_hin.cd_niuke_basho												-- �׎�ꏊ�R�[�h
			,ISNULL(m_hin.cd_tani_nonyu_hasu, @blankStr) AS cd_tani_nonyu_hasu			-- �[���P��(�[��)�R�[�h
			,m_tan_hasu.nm_tani AS nm_tani_hasu														-- �[���P��(�[��)
		FROM ma_hinmei m_hin
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_tani m_tan
		ON m_hin.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_hin.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE
			NOT EXISTS 
			(
				SELECT
					*
				FROM ma_konyu m_ko
				INNER JOIN
					(
						SELECT
							cd_hinmei
							,MIN(no_juni_yusen) AS no_juni_yusen
						FROM ma_konyu
						WHERE
							cd_hinmei = @cd_hinmei
							AND flg_mishiyo = @shiyoMishiyoFlg
						GROUP BY
							cd_hinmei
					) min_ko
				ON m_ko.cd_hinmei = min_ko.cd_hinmei
				AND m_ko.no_juni_yusen	= min_ko.no_juni_yusen
				INNER JOIN ma_hinmei m_hin
				ON m_ko.cd_hinmei = m_hin.cd_hinmei
				LEFT OUTER JOIN ma_tani m_tan
				ON m_ko.cd_tani_nonyu = m_tan.cd_tani
				AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
				LEFT OUTER JOIN ma_torihiki m_tori
				ON m_ko.cd_torihiki = m_tori.cd_torihiki
				AND m_tori.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
				LEFT OUTER JOIN ma_torihiki m_tori2
				ON m_ko.cd_torihiki2 = m_tori2.cd_torihiki
				AND m_tori2.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
				WHERE
					m_ko.flg_mishiyo = @shiyoMishiyoFlg
					AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
			)
			AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
			AND m_hin.cd_hinmei = @cd_hinmei
			ORDER BY
				cd_hinmei					 						

	END

	ELSE

	BEGIN
	
		SELECT	
			m_ko.cd_torihiki						-- �����R�[�h
			,m_tori.nm_torihiki						-- ����於
			,m_ko.cd_torihiki2						-- �����R�[�h2
			,m_tori2.nm_torihiki AS nm_torihiki2	-- ����於2
			,m_hin.kbn_hin				-- �i�敪
			,m_ko.cd_hinmei				-- �i���R�[�h
			,m_hin.nm_hinmei_ja			-- �i��(���{��)
			,m_hin.nm_hinmei_en			-- �i��(�p��)
			,m_hin.nm_hinmei_zh			-- �i��(������)
			,m_hin.nm_hinmei_vi
			,m_hin.nm_nisugata_hyoji	-- �׎p
			,m_ko.cd_tani_nonyu			-- �[���P�ʃR�[�h
			,m_tan.nm_tani				-- �[���P��
			,m_ko.tan_nonyu				-- �[���P��
			,m_hin.kbn_hokan			-- �ۊǋ敪
			,m_hokan.nm_hokan_kbn		-- �i�ʏ��
			,m_ko.su_iri				-- ����
			,m_ko.wt_nonyu  AS wt_nonyu	-- ��̗�
			,m_hin.dd_shomi				-- �ܖ�����
			,m_hin.cd_bunrui			-- ���ރR�[�h
			,m_bun.nm_bunrui			-- ���ޖ�
			,m_hin.biko					-- ���l
			,m_hin.kbn_zei				-- �ŋ敪
			,m_hin.cd_niuke_basho		-- �׎�ꏊ�R�[�h
			,m_ko.cd_tani_nonyu_hasu	-- �[���P��(�[��)�R�[�h
			,m_tan_hasu.nm_tani AS nm_tani_hasu	-- �[���P��(�[��)
		FROM ma_konyu m_ko
		INNER JOIN ma_hinmei m_hin
		ON m_ko.cd_hinmei = m_hin.cd_hinmei
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo	= @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan
		ON m_ko.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_torihiki m_tori
		ON m_ko.cd_torihiki	= m_tori.cd_torihiki
		AND m_tori.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_tori2
		ON m_ko.cd_torihiki2 = m_tori2.cd_torihiki
		AND m_tori2.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_ko.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE
			m_ko.flg_mishiyo = @shiyoMishiyoFlg
			AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
			AND m_ko.cd_hinmei = @cd_hinmei
			AND m_ko.cd_torihiki = @cd_torihiki
	UNION
		SELECT
			@blankStr AS cd_torihiki									-- �����R�[�h
			,@blankStr AS nm_torihiki									-- ����於
			,@blankStr AS cd_torihiki2									-- �����R�[�h2
			,@blankStr AS nm_torihiki2									-- ����於2
			,m_hin.kbn_hin												-- �i�敪
			,m_hin.cd_hinmei											-- �i���R�[�h
			,m_hin.nm_hinmei_ja											-- �i��(���{��)
			,m_hin.nm_hinmei_en											-- �i��(�p��)
			,m_hin.nm_hinmei_zh											-- �i��(������)
			,m_hin.nm_hinmei_vi
			,m_hin.nm_nisugata_hyoji									-- �׎p
			,ISNULL(m_hin.cd_tani_nonyu, @blankStr) AS cd_tani_nonyu	-- �[���P�ʃR�[�h
			,m_tan.nm_tani												-- �[���P��
			,m_hin.tan_nonyu											-- �[���P��
			,m_hin.kbn_hokan											-- �ۊǋ敪
			,m_hokan.nm_hokan_kbn										-- �i�ʏ��
			,m_hin.su_iri												-- ����
			,m_hin.wt_ko AS wt_nonyu									-- ��̗�
			,m_hin.dd_shomi												-- �ܖ�����
			,m_hin.cd_bunrui											-- ���ރR�[�h
			,m_bun.nm_bunrui											-- ���ޖ�
			,m_hin.biko													-- ���l
			,m_hin.kbn_zei												-- �ŋ敪
			,m_hin.cd_niuke_basho										-- �׎�ꏊ�R�[�h
			,ISNULL(m_hin.cd_tani_nonyu_hasu, @blankStr) AS cd_tani_nonyu_hasu	-- �[���P��(�[��)�R�[�h
			,m_tan_hasu.nm_tani AS nm_tani_hasu									-- �[���P��(�[��) 
		FROM ma_hinmei m_hin
		LEFT OUTER JOIN ma_bunrui m_bun
		ON m_hin.cd_bunrui = m_bun.cd_bunrui
		AND m_hin.kbn_hin = m_bun.kbn_hin
		AND m_bun.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_tani m_tan
		ON m_hin.cd_tani_nonyu = m_tan.cd_tani
		AND m_tan.flg_mishiyo = @shiyoMishiyoFlg	-- ���s�Ȃ�
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo	= @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tan_hasu
		ON m_hin.cd_tani_nonyu_hasu = m_tan_hasu.cd_tani
		AND m_tan_hasu.flg_mishiyo = @shiyoMishiyoFlg
		WHERE 
			NOT EXISTS 
			(
				SELECT
					*
				FROM ma_konyu m_ko
				WHERE
					m_ko.cd_hinmei = m_hin.cd_hinmei
			)
		AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
		AND m_hin.cd_hinmei = @cd_hinmei
		ORDER BY 
			cd_hinmei	
	END

END
GO
