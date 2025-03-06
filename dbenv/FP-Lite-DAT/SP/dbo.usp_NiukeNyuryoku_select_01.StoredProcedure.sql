IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeNyuryoku_select_01') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeNyuryoku_select_01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F�׎���́@�׎�\�茟��
�t�@�C����	�Fusp_NiukeNyuryoku_select_01
���͈���	�F@dt_niuke, @cd_niuke, @flg_kakutei
			  , @shiyoMishiyoFlg, @yoteiYojitsuFlg, @jissekiYojitsuFlg
			  , @shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn, @skip
			  , @shiireName, @top, @isExcel
�o�͈���	�F
�߂�l		�F
�쐬��		�F2013.11.09  ADMAX kakute.y
�X�V��		�F2015.10.13  MJ    ueno.k
�X�V��		�F2016.05.26  BRC   motojima.m
�X�V��		�F2016.09.01  BRC   motojima.m �׎���͍s�ǉ��Ή�
�X�V��		�F2016.11.15  BRC   cho.k �׎���ё��݃t���O�ǉ�
�X�V��		�F2016.11.22  BRC   kanehira.d ���o�ɋ敪�ǉ�
�X�V��		�F2016.12.13  BRC   motojima.m �����Ή�
�X�V��		�F2016.02.20  BRC   cho.k Q&B�T�|�[�gNo.41�Ή�
�X�V��		�F2016.03.08  BRC   cho.k �T�|�[�gNo.7�Ή�
�X�V��		�F2018.01.12  BRC   cho.k HQP�T�|�[�gNo009�Ή�
�X�V��		�F2022.02.07  BRC   sato.t #1648�Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeNyuryoku_select_01]
	-- ��������
	@dt_niuke				DATETIME		-- �׎��
	, @cd_niuke				VARCHAR(10)		-- �׎�ꏊ�R�[�h
	, @flg_kakutei			SMALLINT		-- ���m��̂�
	-- �R�[�h
	, @shiyoMishiyoFlg		SMALLINT		-- ���g�p�t���O.�g�p
	, @yoteiYojitsuFlg		SMALLINT		-- �[���\���t���O.�\��
	, @jissekiYojitsuFlg	SMALLINT		-- �[���\���t���O.����
	, @shiireNyushukoKbn	SMALLINT		-- ���o�ɋ敪.�d��
	, @addKbn	            SMALLINT		-- ���o�ɋ敪.�ǉ�
	, @sotoinyuNyushukoKbn	SMALLINT		-- ���o�ɋ敪.�O�ړ�
	, @ryohinZaikoKbn		SMALLINT		-- �݌ɋ敪.�Ǖi
	--, @shiireName			VARCHAR(50)		-- ���o�ɋ敪��.�d�� -- �ϓ��\����\��𗧂Ă����Ɏg�p(EXCEL�o�͗p) -- �g�p���Ȃ�
	, @shiireName			NVARCHAR(50)	-- ���o�ɋ敪��.�d�� -- �ϓ��\����\��𗧂Ă����Ɏg�p(EXCEL�o�͗p) -- �g�p���Ȃ�
	
	, @skip					DECIMAL(10)		-- �X�L�b�v
	, @top					DECIMAL(10)		-- �����f�[�^���
	, @isExcel				BIT				-- �G�N�Z���t���O
AS
BEGIN
	
	-- �������l
	DECLARE @initBlank	VARCHAR
	DECLARE @initZero	SMALLINT
	DECLARE @initTime	DATETIME
	-- �t���O�l
	DECLARE @zeroToFlg	SMALLINT
	DECLARE @oneToFlg	SMALLINT
	 
	DECLARE @start		DECIMAL(10)
    DECLARE @end		DECIMAL(10)
	DECLARE @true		BIT
	DECLARE @false		BIT
	
	-- �l�Z�b�g
	SET @initBlank	= ''
	SET @initZero	= 0
	SET @initTime	= '00:00:00.000'
	
	SET @zeroToFlg	= 0
	SET @oneToFlg	= 1
	
    SET	@start		= @skip + 1
    SET	@end		= @skip + @top
    SET	@true		= 1
    SET	@false		= 0;
    
    -- ����
    WITH cte AS
    
		(
			SELECT
				*
				--,ROW_NUMBER() OVER (ORDER BY uni.tm_nonyu_yotei, uni.cd_hinmei) AS RN
				,ROW_NUMBER() OVER (ORDER BY uni.cd_torihiki, uni.cd_bunrui, uni.cd_hinmei) AS RN
			FROM
				(
					-- ���Y�Ǘ��i�����ޕϓ��\�A�[���\�胊�X�g�쐬��ʁj�ō쐬���ꂽ�׎�\��
					 SELECT
						-- �\������
						  ISNULL(niuke.flg_kakutei, @zeroToFlg) AS flg_kakutei						-- �m��(�׎�g����)
						, ISNULL(bunrui.nm_bunrui, '') AS nm_bunrui									-- �i����
						, nonyu.cd_hinmei															-- �i���R�[�h
						, ISNULL(hin.nm_hinmei_ja, '') AS nm_hinmei_ja
						, ISNULL(hin.nm_hinmei_en, '') AS nm_hinmei_en
						, ISNULL(hin.nm_hinmei_zh, '') AS nm_hinmei_zh
						, ISNULL(hin.nm_hinmei_vi, '') AS nm_hinmei_vi
						, ISNULL(hin.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						, ISNULL(nyushukko.nm_kbn_nyushukko, @initBlank) AS nm_kbn_nyushukko		-- ���ɋ敪		-- EXCEL�o�͗p(��ʂł͖��g�p)
						, ISNULL(torihiki_1.nm_torihiki, @initBlank) AS nm_torihiki
						, ISNULL(hokan.nm_hokan_kbn, @initBlank) AS nm_hokan_kbn
						, @initTime AS tm_nonyu_yotei												-- �\�莞��
						, ISNULL(nonyu.su_nonyu, @initZero)	AS su_nonyu_yotei						-- �\��C/S��
						, ISNULL(nonyu.su_nonyu_hasu, @initZero) AS su_nonyu_yotei_hasu				-- �\��[��
						-- ��\������
						, ISNULL(niuke.kbn_nyushukko, @shiireNyushukoKbn) AS kbn_nyushukko			-- ���o�ɋ敪
						, nonyu.cd_torihiki															-- �����R�[�h
						, hin.kbn_hokan
						, hin.biko
						, ISNULL(niuke.no_niuke, @zeroToFlg) AS no_niuke										-- �׎�ԍ�
						, @oneToFlg AS flg_nonyu															-- �[���\���g�����L���t���O
						, hin.cd_niuke_basho														-- �׎�ꏊ�R�[�h
						, ISNULL(nonyu_jitsu.flg_yojitsu, @zeroToFlg) AS flg_jisseki							-- �[�����їL���t���O
						, konyu.su_iri
						, konyu.wt_nonyu
						, ISNULL(nonyu.flg_kakutei, @zeroToFlg) AS flg_kakutei_nonyu							-- �m��t���O(�[���\���g����)
						, hin.dd_shomi
						, konyu.cd_tani_nonyu
						, tani.nm_tani
						, hin.kbn_zei
						, hin.kbn_hin
						, konyu.cd_torihiki2														-- �����R�[�h2
						, konyu.tan_nonyu
						, bunrui.cd_bunrui
						, konyu.cd_tani_nonyu_hasu
						, tani_hasu.nm_tani AS nm_tani_hasu
						, nonyu.kbn_nyuko AS kbn_nyuko												-- ���ɋ敪
						, nonyu.no_nonyu AS no_nonyu_yotei											-- �[���\��ԍ�
						, nonyu.no_nonyu AS no_nonyu_yotei_disp										-- �\���p�[���\��ԍ�
						, CASE
							WHEN niuke.no_niuke IS NULL THEN 0
							ELSE 1
						  END AS flg_niuke_jisseki													-- �׎���їL���t���O 
						, nonyu.no_nonyusho															-- �[�����ԍ�
					FROM 
						(
							SELECT
								*
							FROM tr_nonyu yotei
							WHERE yotei.flg_yojitsu = @yoteiYojitsuFlg
							  AND yotei.dt_nonyu >= @dt_niuke
							  AND yotei.dt_nonyu < DATEADD(DD,1,@dt_niuke)
						) nonyu
					LEFT OUTER JOIN tr_niuke niuke
					  ON niuke.no_nonyu = nonyu.no_nonyu
--					  AND niuke.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
					 AND niuke.kbn_nyushukko = @shiireNyushukoKbn
					LEFT OUTER JOIN (
							SELECT
								no_nonyu_yotei
								, @jissekiYojitsuFlg AS flg_yojitsu
							FROM tr_nonyu jisseki
							WHERE jisseki.flg_yojitsu = @jissekiYojitsuFlg
							  AND jisseki.dt_nonyu >= @dt_niuke
							  AND jisseki.dt_nonyu < DATEADD(DD,1,@dt_niuke)
							GROUP BY no_nonyu_yotei
					  ) nonyu_jitsu
					  ON nonyu_jitsu.no_nonyu_yotei = nonyu.no_nonyu
					-- �i���}�X�^
					INNER JOIN ma_hinmei hin
					  ON hin.cd_hinmei = nonyu.cd_hinmei
					  AND hin.cd_niuke_basho = @cd_niuke
					  AND hin.flg_mishiyo = @shiyoMishiyoFlg
					-- ���ރ}�X�^
					LEFT OUTER JOIN ma_bunrui bunrui
					  ON bunrui.kbn_hin = hin.kbn_hin
					  AND bunrui.cd_bunrui = hin.cd_bunrui
					  AND bunrui.flg_mishiyo = @shiyoMishiyoFlg
					-- �ۊǋ敪�}�X�^
					LEFT OUTER JOIN ma_kbn_hokan hokan
					  ON hokan.cd_hokan_kbn = hin.kbn_hokan
					  AND hokan.flg_mishiyo = @shiyoMishiyoFlg
					-- �����}�X�^�i�����P�j
					LEFT OUTER JOIN	ma_torihiki torihiki_1
					  ON torihiki_1.cd_torihiki = nonyu.cd_torihiki
					  AND torihiki_1.flg_mishiyo = @shiyoMishiyoFlg
					-- �w����}�X�^
					LEFT OUTER JOIN ma_konyu konyu
					  ON konyu.cd_hinmei = nonyu.cd_hinmei
					  AND konyu.cd_torihiki = nonyu.cd_torihiki
					  AND konyu.flg_mishiyo = @shiyoMishiyoFlg
					-- �P�ʃ}�X�^�i�[���P�ʁj
					LEFT OUTER JOIN	ma_tani tani
					  ON tani.cd_tani = konyu.cd_tani_nonyu
					  AND tani.flg_mishiyo = @shiyoMishiyoFlg
					-- �P�ʃ}�X�^�i�[���P�ʁj
					LEFT OUTER JOIN	ma_tani tani_hasu
					  ON tani_hasu.cd_tani = konyu.cd_tani_nonyu_hasu
					  AND tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					-- ���o�ɋ敪
					LEFT OUTER JOIN ma_kbn_nyushukko nyushukko
					  ON nyushukko.kbn_nyushukko = @shiireNyushukoKbn
					WHERE
						niuke.flg_kakutei IS NULL
					 OR niuke.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0)

					UNION ALL

					-- �׎�i�׎���͉�ʁj�Œǉ������׎�\��
					SELECT
						-- �\������
						  ISNULL(niuke.flg_kakutei, @zeroToFlg) AS flg_kakutei						-- �m��(�׎�g����)
						, ISNULL(bunrui.nm_bunrui, '') AS nm_bunrui									-- �i����
						, niuke.cd_hinmei															-- �i���R�[�h
						, ISNULL(hin.nm_hinmei_ja, '') AS nm_hinmei_ja
						, ISNULL(hin.nm_hinmei_en, '') AS nm_hinmei_en
						, ISNULL(hin.nm_hinmei_zh, '') AS nm_hinmei_zh
						, ISNULL(hin.nm_hinmei_vi, '') AS nm_hinmei_vi
						, ISNULL(hin.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						, ISNULL(nyushukko.nm_kbn_nyushukko, @initBlank) AS nm_kbn_nyushukko		-- ���ɋ敪		-- EXCEL�o�͗p(��ʂł͖��g�p)
						, ISNULL(torihiki_1.nm_torihiki, @initBlank) AS nm_torihiki
						, ISNULL(hokan.nm_hokan_kbn, @initBlank) AS nm_hokan_kbn
						, niuke.tm_nonyu_yotei														-- �\�莞��
						, niuke.su_nonyu_yotei														-- �\��C/S��
						, niuke.su_nonyu_yotei_hasu													-- �\��[��
						-- ��\������
						, niuke.kbn_nyushukko AS kbn_nyushukko										-- ���o�ɋ敪
						, niuke.cd_torihiki															-- �����R�[�h
						, hin.kbn_hokan
						, hin.biko
						, niuke.no_niuke															-- �׎�ԍ�
						, @zeroToFlg AS flg_nonyu													-- �[���\���g�����L���t���O
						, hin.cd_niuke_basho														-- �׎�ꏊ�R�[�h
						, @zeroToFlg AS flg_jisseki													-- �[�����їL���t���O
						, konyu.su_iri
						, konyu.wt_nonyu
						, @zeroToFlg AS flg_kakutei_nonyu											-- �m��t���O(�[���\���g����)
						, hin.dd_shomi
						, konyu.cd_tani_nonyu
						, tani.nm_tani
						, hin.kbn_zei
						, hin.kbn_hin
						, konyu.cd_torihiki2														-- �����R�[�h2
						, konyu.tan_nonyu
						, bunrui.cd_bunrui
						, konyu.cd_tani_nonyu_hasu
						, tani_hasu.nm_tani AS nm_tani_hasu
						, niuke.kbn_nyuko AS kbn_nyuko												-- ���ɋ敪
						, niuke.no_nonyu AS no_nonyu_yotei											-- �[���\��ԍ�
						, NULL AS no_nonyu_yotei_disp										-- �\���p�[���\��ԍ�
						, CASE
							WHEN niuke.su_nonyu_jitsu = 0 AND niuke.su_nonyu_jitsu_hasu = 0 THEN 0
							ELSE 1
						  END AS flg_niuke_jisseki													-- �׎���їL���t���O 
						, NULL AS no_nonyusho														-- �[�����ԍ�
					FROM (
							-- ���ѓ��͍ς݂̉׎�\��
							SELECT
								MIN(no_niuke) AS no_niuke
							FROM tr_niuke tr
							WHERE tr.tm_nonyu_yotei >= @dt_niuke
							  AND tr.tm_nonyu_yotei < DATEADD(DD,1,@dt_niuke)
							  AND tr.kbn_nyushukko = @addKbn
							  --AND tr.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
							  AND tr.cd_niuke_basho = @cd_niuke
							  AND tr.no_nonyu IS NOT NULL
							GROUP BY no_nonyu
							
							UNION ALL
							
							-- ���тȂ��ŕۑ������׎�\��
							SELECT
								no_niuke
							FROM tr_niuke tr
							WHERE tr.tm_nonyu_yotei >= @dt_niuke
							  AND tr.tm_nonyu_yotei < DATEADD(DD,1,@dt_niuke)
							  AND tr.kbn_nyushukko = @addKbn
							  --AND tr.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
							  AND tr.cd_niuke_basho = @cd_niuke
							  AND tr.no_nonyu IS NULL
						) yotei
					INNER JOIN tr_niuke niuke
					  ON niuke.no_niuke = yotei.no_niuke
					  AND niuke.kbn_nyushukko = @addKbn
					  AND niuke.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
					-- �i���}�X�^
					LEFT OUTER JOIN ma_hinmei hin
					  ON hin.cd_hinmei = niuke.cd_hinmei
					  AND hin.flg_mishiyo = @shiyoMishiyoFlg
					-- ���ރ}�X�^
					LEFT OUTER JOIN ma_bunrui bunrui
					  ON bunrui.kbn_hin = hin.kbn_hin
					  AND bunrui.cd_bunrui = hin.cd_bunrui
					  AND bunrui.flg_mishiyo = @shiyoMishiyoFlg
					-- �ۊǋ敪�}�X�^
					LEFT OUTER JOIN ma_kbn_hokan hokan
					  ON hokan.cd_hokan_kbn = hin.kbn_hokan
					  AND hokan.flg_mishiyo = @shiyoMishiyoFlg
					-- �����}�X�^�i�����P�j
					LEFT OUTER JOIN	ma_torihiki torihiki_1
					  ON torihiki_1.cd_torihiki = niuke.cd_torihiki
					  AND torihiki_1.flg_mishiyo = @shiyoMishiyoFlg
					-- �w����}�X�^
					LEFT OUTER JOIN ma_konyu konyu
					  ON konyu.cd_hinmei = niuke.cd_hinmei
					  AND konyu.cd_torihiki = niuke.cd_torihiki
					  AND konyu.flg_mishiyo = @shiyoMishiyoFlg
					-- �P�ʃ}�X�^�i�[���P�ʁj
					LEFT OUTER JOIN	ma_tani tani
					  ON tani.cd_tani = konyu.cd_tani_nonyu
					  AND tani.flg_mishiyo = @shiyoMishiyoFlg
					-- �P�ʃ}�X�^�i�[���P�ʁj
					LEFT OUTER JOIN	ma_tani tani_hasu
					  ON tani_hasu.cd_tani = konyu.cd_tani_nonyu_hasu
					  AND tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					-- ���o�ɋ敪
					LEFT OUTER JOIN ma_kbn_nyushukko nyushukko
					  ON nyushukko.kbn_nyushukko = niuke.kbn_nyushukko
						
 
 /* ��2017/02/20 Q&B�T�|�[�gNo.41�Ή��ɂ��폜��
    				SELECT
    					DISTINCT						-- �׎�g����(���тȂ�)
						--�\������
						ISNULL(t_niu.flg_kakutei,@zeroToFlg) flg_kakutei							-- �m��(�׎�g����)
						,ISNULL(m_bunrui.nm_bunrui, '') nm_bunrui									-- �i����
						,t_niu.cd_hinmei															-- �i���R�[�h
						,ISNULL(m_hinmei.nm_hinmei_en, '') AS nm_hinmei_en							-- �i��(�p��)
						,ISNULL(m_hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja							-- �i��(���{��)
						,ISNULL(m_hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh							-- �i��(������)
						,ISNULL(m_hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji				-- �׎p
						,ISNULL(m_kbn_nyushukko.nm_kbn_nyushukko,@initBlank) AS nm_kbn_nyushukko	-- ���ɋ敪		-- EXCEL�o�͗p(��ʂł͖��g�p)
						,ISNULL(m_torihiki.nm_torihiki,@initBlank) AS nm_torihiki					-- �����
						,ISNULL(m_kbn_hokan.nm_hokan_kbn,@initBlank) AS nm_hokan_kbn				-- �i�ʏ��
						,t_niu.tm_nonyu_yotei														-- �\�莞��
						,t_niu.su_nonyu_yotei														-- �\��C/S��
						,t_niu.su_nonyu_yotei_hasu													-- �\��[��
						--��\������
						,ISNULL(t_niu.kbn_nyushukko,0) AS kbn_nyushukko								-- ���o�ɋ敪
						,t_niu.cd_torihiki															-- �����R�[�h
						,m_hinmei.kbn_hokan															-- �ۊǋ敪
						,m_hinmei.biko																-- ���l(�i���}�X�^)
						,t_niu.no_niuke																-- �׎�ԍ�
						,@zeroToFlg flg_nonyu														-- �[���\���g�����L���t���O
						,t_niu.cd_niuke_basho														-- �׎�ꏊ�R�[�h
						,@zeroToFlg flg_jisseki														-- ���їL���t���O
						,m_konyu.su_iri																-- ����
						,@zeroToFlg flg_kakutei_nonyu												-- �m��t���O(�[���\���g����)
						,m_hinmei.dd_shomi															-- �ܖ�����
						,m_konyu.cd_tani_nonyu														-- �[���P�ʃR�[�h
						,m_tani.nm_tani																-- �[���P�ʖ�
						,m_hinmei.kbn_zei															-- �ŋ敪
						,m_hinmei.kbn_hin															-- �i�敪
						,m_konyu.cd_torihiki2														-- �����R�[�h2
						,m_konyu.tan_nonyu															-- �[���P��
						,m_bunrui.cd_bunrui
						,m_konyu.cd_tani_nonyu_hasu													-- �[���P�ʃR�[�h(�[��)
						,m_tani_hasu.nm_tani AS nm_tani_hasu										-- �[���P�ʖ�(�[��)
						,t_niu.kbn_nyuko AS kbn_nyuko
						,t_niu.no_nonyu AS no_nonyu_yotei
						,NULL AS no_nonyu_yotei_disp
						,CASE
							WHEN ISNULL(t_niu.su_nonyu_jitsu,0) = 0 AND ISNULL(t_niu.su_nonyu_jitsu_hasu,0) = 0 THEN 0
							ELSE 1
						 END AS flg_niuke_jisseki 
					FROM tr_niuke t_niu
					INNER JOIN
						(
							SELECT
								MIN(t_n.no_niuke) AS no_niuke
								,t_n.dt_niuke
								,t_n.cd_hinmei
								,t_n.cd_torihiki
								,t_n.kbn_nyuko
							FROM tr_niuke t_n
							WHERE
								t_n.no_seq = 
								(
									SELECT
										MIN(no_seq)
									FROM tr_niuke
								)
								AND NOT EXISTS
								(
									SELECT
										*
									FROM tr_nonyu t_nyu
									WHERE
										t_nyu.cd_hinmei = t_n.cd_hinmei
										AND t_nyu.cd_torihiki = t_n.cd_torihiki
										--AND t_nyu.dt_nonyu = t_n.dt_nonyu
										AND t_nyu.flg_yojitsu = @jissekiYojitsuFlg
										AND t_nyu.no_nonyu = t_n.no_nonyu
										AND ((t_nyu.kbn_nyuko is null AND t_n.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_n.kbn_nyuko)
								)
							GROUP BY
								t_n.dt_niuke
								,t_n.cd_hinmei
								,t_n.cd_torihiki
								,t_n.kbn_nyuko
						) tr_nk
					ON t_niu.no_niuke = tr_nk.no_niuke
					AND t_niu.kbn_zaiko = @ryohinZaikoKbn
					AND t_niu.no_seq =	
					(
						SELECT
							MIN(no_seq) AS no_seq
						FROM tr_niuke
					)	
					INNER JOIN ma_hinmei m_hinmei
					ON t_niu.cd_hinmei = m_hinmei.cd_hinmei
					AND m_hinmei.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON m_hinmei.kbn_hin = m_bunrui.kbn_hin
					AND m_hinmei.cd_bunrui = m_bunrui.cd_bunrui
					AND m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_niuke m_niuke
					ON t_niu.cd_niuke_basho = m_niuke.cd_niuke_basho
					AND m_niuke.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_hokan m_kbn_hokan
					ON m_hinmei.kbn_hokan = m_kbn_hokan.cd_hokan_kbn
					AND m_kbn_hokan.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_torihiki m_torihiki
					ON t_niu.cd_torihiki = m_torihiki.cd_torihiki
					AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_nyushukko m_kbn_nyushukko
					ON t_niu.kbn_nyushukko = m_kbn_nyushukko.kbn_nyushukko
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_niu.cd_hinmei = m_konyu.cd_hinmei
					AND t_niu.cd_torihiki = m_konyu.cd_torihiki
					AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_tani m_tani
					ON m_konyu.cd_tani_nonyu = m_tani.cd_tani
					AND m_tani.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_tani m_tani_hasu
					ON m_konyu.cd_tani_nonyu_hasu = m_tani_hasu.cd_tani
					AND m_tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					WHERE	
						--t_niu.kbn_nyushukko IN ( @shiireNyushukoKbn, @sotoinyuNyushukoKbn, 0) -- NULL�p��0
						t_niu.kbn_nyushukko IN ( @shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn, 0) -- NULL�p��0
						AND @dt_niuke <= t_niu.dt_niuke AND t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
						AND t_niu.cd_niuke_basho =	@cd_niuke
						AND	t_niu.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)

						AND	NOT EXISTS	
						(
							SELECT
								*
							FROM tr_nonyu t_nyu
							WHERE
								t_nyu.cd_hinmei = t_niu.cd_hinmei
								AND t_nyu.cd_torihiki = t_niu.cd_torihiki
--								AND t_nyu.dt_nonyu = t_niu.dt_niuke
								AND t_nyu.dt_nonyu = t_niu.dt_nonyu
								AND t_nyu.flg_yojitsu =	@jissekiYojitsuFlg
								--AND t_nyu.kbn_nyuko = t_niu.kbn_nyuko
								AND ((t_nyu.kbn_nyuko is null AND t_niu.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_niu.kbn_nyuko)
						)

					UNION
				
					SELECT
						DISTINCT							-- �׎�g����(���т���)
						--�\������
						ISNULL(t_niu.flg_kakutei,@zeroToFlg) AS flg_kakutei
						,ISNULL(m_bunrui.nm_bunrui, '') AS nm_bunrui
						,t_niu.cd_hinmei
						,ISNULL(m_hinmei.nm_hinmei_en, '') AS nm_hinmei_en
						,ISNULL(m_hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
						,ISNULL(m_hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
						,ISNULL(m_hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						,ISNULL(m_kbn_nyushukko.nm_kbn_nyushukko,@initBlank) AS nm_kbn_nyushukko
						,ISNULL(m_torihiki.nm_torihiki,@initBlank) AS nm_torihiki
						,ISNULL(m_kbn_hokan.nm_hokan_kbn,@initBlank) AS nm_hokan_kbn
						,t_niu.tm_nonyu_yotei
						,t_niu.su_nonyu_yotei
						,t_niu.su_nonyu_yotei_hasu
						--��\������
						,ISNULL(t_niu.kbn_nyushukko, 0) AS kbn_nyushukko
						,t_niu.cd_torihiki
						,m_hinmei.kbn_hokan
						,m_hinmei.biko
						,t_niu.no_niuke
						,@oneToFlg flg_nonyu
						,t_niu.cd_niuke_basho
						,@oneToFlg flg_jisseki
						,m_konyu.su_iri
						,t_nyu.flg_kakutei flg_kakutei_nonyu
						,m_hinmei.dd_shomi
						,m_konyu.cd_tani_nonyu
						,m_tani.nm_tani
						,m_hinmei.kbn_zei
						,m_hinmei.kbn_hin
						,m_konyu.cd_torihiki2
						,m_konyu.tan_nonyu
						,m_bunrui.cd_bunrui
						,m_konyu.cd_tani_nonyu_hasu
						,m_tani_hasu.nm_tani AS nm_tani_hasu
						,t_niu.kbn_nyuko AS kbn_nyuko
						,t_niu.no_nonyu AS no_nonyu_yotei
						,t_niu.no_nonyu AS no_nonyu_yotei_disp
						,CASE
							WHEN ISNULL(t_niu.su_nonyu_jitsu,0) = 0 AND ISNULL(t_niu.su_nonyu_jitsu_hasu,0) = 0 THEN 0
							ELSE 1
						 END AS flg_niuke_jisseki 
					FROM tr_niuke t_niu
					INNER JOIN
					(
						SELECT
							MIN(t_n.no_niuke) AS no_niuke
							,t_n.dt_niuke
							,t_n.cd_hinmei
							,t_n.cd_torihiki
							,t_n.kbn_nyuko
						FROM tr_niuke t_n
						WHERE
							t_n.no_seq =
							(
								SELECT
									MIN(no_seq) AS no_seq
								FROM tr_niuke
							)				
						GROUP BY
							t_n.dt_niuke
							,t_n.cd_hinmei
							,t_n.cd_torihiki
							,t_n.kbn_nyuko
							,t_n.no_nonyu
					) tr_nk
					ON t_niu.no_niuke = tr_nk.no_niuke
					AND t_niu.kbn_zaiko = @ryohinZaikoKbn
					AND t_niu.no_seq =	
					(
						SELECT
							MIN(no_seq) AS no_seq
						FROM tr_niuke
					)
					INNER JOIN ma_hinmei m_hinmei
					ON t_niu.cd_hinmei = m_hinmei.cd_hinmei
					AND m_hinmei.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON m_hinmei.kbn_hin = m_bunrui.kbn_hin
					AND m_hinmei.cd_bunrui = m_bunrui.cd_bunrui
					AND m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_niuke m_niuke
					ON t_niu.cd_niuke_basho = m_niuke.cd_niuke_basho
					AND m_niuke.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_hokan m_kbn_hokan
					ON m_hinmei.kbn_hokan = m_kbn_hokan.cd_hokan_kbn
					AND m_kbn_hokan.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_torihiki m_torihiki
					ON t_niu.cd_torihiki = m_torihiki.cd_torihiki
					AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_nyushukko m_kbn_nyushukko
					ON t_niu.kbn_nyushukko = m_kbn_nyushukko.kbn_nyushukko
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_niu.cd_hinmei = m_konyu.cd_hinmei
					AND t_niu.cd_torihiki = m_konyu.cd_torihiki
					AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_tani m_tani
					ON m_konyu.cd_tani_nonyu = m_tani.cd_tani
					AND m_tani.flg_mishiyo = @shiyoMishiyoFlg
					INNER JOIN tr_nonyu t_nyu
					--ON t_niu.cd_hinmei = t_nyu.cd_hinmei
					--AND t_niu.cd_torihiki = t_nyu.cd_torihiki
					--AND t_niu.dt_niuke = t_nyu.dt_nonyu
					--AND t_nyu.flg_yojitsu = @jissekiYojitsuFlg
					ON t_niu.no_nonyu = t_nyu.no_nonyu
					AND t_niu.no_nonyu = t_nyu.no_nonyu_yotei
					LEFT OUTER JOIN ma_tani m_tani_hasu
					ON m_konyu.cd_tani_nonyu_hasu = m_tani_hasu.cd_tani
					AND m_tani_hasu.flg_mishiyo = @shiyoMishiyoFlg						
					WHERE
						t_niu.kbn_nyushukko IN ( @shiireNyushukoKbn, @addKbn, @sotoinyuNyushukoKbn, 0)
						AND @dt_niuke <= t_niu.dt_niuke AND t_niu.dt_niuke < (SELECT DATEADD(DD,1,@dt_niuke))
						AND t_niu.cd_niuke_basho = @cd_niuke
						AND t_niu.flg_kakutei IN (ABS(ABS(@flg_kakutei)-1),0,NULL)
						--AND EXISTS
						--(
						--	SELECT
						--		*
						--	FROM tr_nonyu t_nyu
						--	WHERE t_nyu.cd_hinmei =	t_niu.cd_hinmei
						--		AND	t_nyu.cd_torihiki = t_niu.cd_torihiki
						--		AND	t_nyu.dt_nonyu = t_niu.dt_niuke
						--		--AND	t_nyu.kbn_nyuko = t_niu.kbn_nyuko
						--		AND ((t_nyu.kbn_nyuko is null AND t_niu.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_niu.kbn_nyuko)
						--		AND EXISTS	
						--		(
						--			SELECT
						--				*
						--			FROM tr_nonyu t_no
						--			WHERE
						--				t_no.flg_yojitsu = @jissekiYojitsuFlg
						--				AND t_no.no_nonyu = t_nyu.no_nonyu
						--		)
						--)
					UNION
			
					SELECT
						DISTINCT							-- ���Y�Ǘ�/�����ޕϓ��\�ŗ��Ă��\��				
						--�\������
						@zeroToFlg flg_kakutei
						,m_bunrui.nm_bunrui
						,t_nyu.cd_hinmei
						,ISNULL(m_hinmei.nm_hinmei_en, '') AS nm_hinmei_en
						,ISNULL(m_hinmei.nm_hinmei_ja, '') AS nm_hinmei_ja
						,ISNULL(m_hinmei.nm_hinmei_zh, '') AS nm_hinmei_zh
						,ISNULL(m_hinmei.nm_nisugata_hyoji, '') AS nm_nisugata_hyoji
						,ISNULL(m_kbn_nyushukko.nm_kbn_nyushukko,@initBlank) AS nm_kbn_nyushukko	-- ���ɋ敪		-- EXCEL�o�͗p(��ʂł͖��g�p)
						-- ,@shiireName nm_kbn_nyushukko
						,ISNULL(m_torihiki.nm_torihiki,@initBlank) AS nm_torihiki
						,ISNULL(m_kbn_hokan.nm_hokan_kbn,@initBlank) AS nm_hokan_kbn
						,@initTime tm_nonyu_yotei
						,ISNULL(t_nyu.su_nonyu,@initZero) AS su_nonyu
						,ISNULL(t_nyu.su_nonyu_hasu,@initZero) AS su_nonyu_hasu
						--��\������
						,@shiireNyushukoKbn kbn_nyushukko
						,ISNULL(t_nyu.cd_torihiki,@initBlank) AS cd_torihiki
						,m_hinmei.kbn_hokan
						,m_hinmei.biko
						,'0' no_niuke
						,@oneToFlg flg_nonyu
						,m_hinmei.cd_niuke_basho
						,@zeroToFlg flg_jisseki
						,m_konyu.su_iri
						,t_nyu.flg_kakutei flg_kakutei_nonyu
						,m_hinmei.dd_shomi
						,m_konyu.cd_tani_nonyu
						,m_tani.nm_tani
						,m_hinmei.kbn_zei
						,m_hinmei.kbn_hin
						,m_konyu.cd_torihiki2
						,m_konyu.tan_nonyu
						,m_bunrui.cd_bunrui
						,m_konyu.cd_tani_nonyu_hasu
						,m_tani_hasu.nm_tani AS nm_tani_hasu
						,t_nyu.kbn_nyuko AS kbn_nyuko
						,t_nyu.no_nonyu AS no_nonyu_yotei
						,t_nyu.no_nonyu AS no_nonyu_yotei_disp
						, 0 AS flg_niuke_jisseki
					FROM tr_nonyu t_nyu
					INNER JOIN ma_hinmei m_hinmei
					ON t_nyu.cd_hinmei = m_hinmei.cd_hinmei
					AND	m_hinmei.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON m_hinmei.kbn_hin = m_bunrui.kbn_hin
					AND	m_hinmei.cd_bunrui = m_bunrui.cd_bunrui
					AND	m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_kbn_hokan m_kbn_hokan
					ON m_hinmei.kbn_hokan = m_kbn_hokan.cd_hokan_kbn
					AND	m_kbn_hokan.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_torihiki m_torihiki
					ON t_nyu.cd_torihiki = m_torihiki.cd_torihiki
					AND	m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_nyu.cd_hinmei = m_konyu.cd_hinmei
					AND	t_nyu.cd_torihiki = m_konyu.cd_torihiki
					AND	m_konyu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_tani m_tani
					ON m_konyu.cd_tani_nonyu = m_tani.cd_tani
					AND	m_tani.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN	ma_tani m_tani_hasu
					ON m_konyu.cd_tani_nonyu_hasu = m_tani_hasu.cd_tani
					AND	m_tani_hasu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_nyushukko m_kbn_nyushukko
					ON m_kbn_nyushukko.kbn_nyushukko = 1
					WHERE
						t_nyu.flg_yojitsu =	@yoteiYojitsuFlg
						AND @dt_niuke <= t_nyu.dt_nonyu AND t_nyu.dt_nonyu < (SELECT DATEADD(DD,1,@dt_niuke))
						AND m_hinmei.cd_niuke_basho = @cd_niuke
						AND NOT EXISTS 
						(
							--SELECT
							--	*
							--FROM tr_niuke t_niu
							--WHERE
							--	t_nyu.cd_hinmei = t_niu.cd_hinmei
							--	AND t_nyu.cd_torihiki = t_niu.cd_torihiki
							--	AND t_nyu.dt_nonyu = t_niu.dt_niuke
							--	AND t_nyu.no_nonyu = t_niu.no_nonyu
							--	--AND t_nyu.kbn_nyuko = t_niu.kbn_nyuko
							--	AND ((t_nyu.kbn_nyuko is null AND t_niu.kbn_nyuko is null) or t_nyu.kbn_nyuko = t_niu.kbn_nyuko)
							--	AND t_niu.no_seq =
							--	(
							--		SELECT
							--			MIN(no_seq) AS no_seq
							--		FROM tr_niuke
							--	)

							SELECT
								niu.*
							FROM tr_niuke niu
							INNER JOIN
								(

									SELECT
										jisseki.no_nonyu
										,jisseki.no_nonyu_yotei
									FROM tr_nonyu yotei
									INNER JOIN tr_nonyu jisseki
									ON yotei.no_nonyu = jisseki.no_nonyu_yotei
									AND yotei.flg_yojitsu = @yoteiYojitsuFlg
								) subqueryNonyu
							ON t_nyu.no_nonyu = subqueryNonyu.no_nonyu_yotei
							AND niu.no_nonyu = subqueryNonyu.no_nonyu
							AND niu.no_seq = (
												SELECT
													MIN(no_seq) AS no_seq
												FROM tr_niuke
											)
						)
			�� 2017/02/20 Q&B�T�|�[�gNo.41�Ή��ɂ��폜��*/
				) uni
	)
	-- ��ʂɕԋp����l���擾
	SELECT
		cnt	-- �s����
		,cte_row.flg_kakutei
		,cte_row.nm_bunrui
		,cte_row.cd_hinmei
		,cte_row.nm_hinmei_en
		,cte_row.nm_hinmei_ja
		,cte_row.nm_hinmei_zh
		,cte_row.nm_hinmei_vi
		,cte_row.nm_nisugata_hyoji
		,cte_row.nm_kbn_nyushukko
		,cte_row.nm_torihiki
		,cte_row.nm_hokan_kbn
		,cte_row.tm_nonyu_yotei
		,cte_row.su_nonyu_yotei
		,cte_row.su_nonyu_yotei_hasu
		--��\������			
		,cte_row.kbn_nyushukko
		,cte_row.cd_torihiki
		,cte_row.kbn_hokan
		,cte_row.biko
		,cte_row.no_niuke
		,cte_row.flg_nonyu
		,cte_row.cd_niuke_basho
		,cte_row.flg_jisseki
		,cte_row.su_iri
		,cte_row.wt_nonyu
		,cte_row.flg_kakutei_nonyu
		,cte_row.dd_shomi
		,cte_row.cd_tani_nonyu
		,cte_row.nm_tani
		,cte_row.kbn_zei
		,cte_row.kbn_hin
		,cte_row.cd_torihiki2
		,cte_row.tan_nonyu
		,cte_row.cd_tani_nonyu_hasu
		,cte_row.nm_tani_hasu
		,cte_row.kbn_nyuko
		,cte_row.no_nonyu_yotei
		,cte_row.no_nonyu_yotei_disp
		,cte_row.flg_niuke_jisseki
		,cte_row.no_nonyusho
	FROM
		(
			SELECT 
				MAX(RN) OVER() AS cnt
				,*
			FROM cte 
		) cte_row
	WHERE
		( 
			( 
			@isExcel = @false					-- �����݂̂̏ꍇ�͎w��s���𒊏o
			AND RN BETWEEN @start AND @end
			)
			OR @isExcel = @true					-- Excel�o�͂͑S�s�o��
		)
--	ORDER BY no_nonyu_yotei
	ORDER BY CASE WHEN no_nonyu_yotei_disp IS NULL THEN 1 ELSE 0 END, no_nonyu_yotei_disp
END
GO
