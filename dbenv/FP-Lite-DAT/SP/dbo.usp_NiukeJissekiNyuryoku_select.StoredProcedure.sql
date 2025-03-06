IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NiukeJissekiNyuryoku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\		�F�׎���ѓ��́@
�t�@�C����	�Fusp_NiukeJissekiNyuryoku_select
���͈���	�F@no_niuke, @cd_hinmei, @cd_torihiki
              , @dt_nonyu, @shiyoMishiyoFlg, @yoteiYojitsuFlg
�o�͈���	�F	
�߂�l		�F
�쐬��		�F2013.10.04  ADMAX kakuta.y
�X�V��		�F
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeJissekiNyuryoku_select] 
	@no_niuke			VARCHAR(14)	-- �׎���͂���̈���
	,@cd_hinmei			VARCHAR(14)	-- �i���R�[�h(�����ޕϓ��\�\�茟���p)
	,@cd_torihiki		VARCHAR(13)	-- �����R�[�h(�����ޕϓ��\�\�茟���p)
	,@dt_nonyu			DATETIME	-- �[����(�׎���͂ł̌�������.�׎���B�����ޕϓ��\�\�茟���p)
	,@shiyoMishiyoFlg	SMALLINT	-- �R�[�h�ꗗ.���g�p�t���O.�g�p
	,@yoteiYojitsuFlg	SMALLINT	-- �R�[�h�ꗗ.�\���t���O.�\��

AS
BEGIN

	IF @no_niuke IS NOT NULL
	BEGIN

		-- �׎���͂ō쐬�����f�[�^�̏ꍇ
		SELECT	
			m_niu.nm_niuke													-- �׎�ꏊ
			,t_niu.dt_niuke													-- �׎��
			,m_tani.nm_tani													-- �[���P��(�\)
			,t_niu.cd_hinmei												-- �i���R�[�h
			,m_hin.nm_hinmei_ja												-- �i��(���{��)
			,m_hin.nm_hinmei_en												-- �i��(�p��)
			,m_hin.nm_hinmei_zh												-- �i��(������)
			,m_hin.nm_hinmei_vi
			,ISNULL(m_hin.nm_nisugata_hyoji,'') AS nm_nisugata_hyoji		-- �׎p(�\)
			,t_niu.cd_torihiki												-- �����R�[�h
			,m_torihiki.nm_torihiki											-- ����於
			,m_hokan.nm_hokan_kbn											-- �i�ʏ��
			,t_niu.tm_nonyu_yotei											-- �\��
			,ISNULL(m_bunrui.nm_bunrui,'') AS nm_bunrui						-- �i����
			,m_hin.dd_shomi													-- �ܖ�����
			,t_niu.su_nonyu_yotei											-- �[����(�\)
			,t_niu.su_nonyu_yotei_hasu										-- �[���[��(�\)
			,t_niu.tm_nonyu_jitsu											-- ����
			,t_niu.su_nonyu_jitsu											-- �[����(��)
			,t_niu.su_nonyu_jitsu_hasu										-- �[���[��(��)
			,t_niu.kin_kuraire												-- ���z
			,t_niu.dt_seizo													-- ������
			,t_niu.dt_kigen													-- �ܖ�����
			,ISNULL(t_niu.no_lot, '') AS no_lot								-- ���b�gNo.
			,ISNULL(t_niu.no_denpyo, '') AS no_denpyo						-- �`�[No.
			,ISNULL(t_niu.biko,'') AS biko									-- ���l
			,ISNULL(t_niu.cd_hinmei_maker,'') AS cd_hinmei_maker			-- �i���R�[�h(14��)
			,ISNULL(t_niu.nm_kuni,'') AS nm_kuni							-- ����
			,ISNULL(t_niu.cd_maker,'') AS cd_maker							-- ���[�J�[�R�[�h(GLN)
			,ISNULL(t_niu.nm_maker,'') AS nm_maker							-- ���[�J�[��
			,ISNULL(t_niu.cd_maker_kojo,'') AS cd_maker_kojo				-- ���[�J�[�H��R�[�h
			,ISNULL(t_niu.nm_maker_kojo,'') AS nm_maker_kojo				-- ���[�J�[�H�ꖼ
			,ISNULL(t_niu.nm_hyoji_nisugata, '') AS	nm_hyoji_nisugata_niuke	-- �׎p(��)
			,ISNULL(t_niu.nm_tani_nonyu, '') AS nm_tani_nonyu				-- �[���P��(��)
			,t_niu.dt_nonyu													-- �[����
			,t_niu.dt_label_hakko											-- ���x�����s����
			-- ��\������
			,m_hin.su_iri													-- ����
			,m_hin.kbn_zei													-- �ŋ敪
			,t_niu.flg_kakutei												-- �m��t���O
			,ISNULL(m_konyu.cd_torihiki2, '') AS cd_torihiki2				-- �����R�[�h2
			,ISNULL(m_konyu.cd_tani_nonyu, '') AS cd_tani_nonyu				-- �[���P�ʃR�[�h
			,m_hin.kbn_hin													-- �i�敪
			,t_niu.no_nonyu													-- �[���ԍ�
		FROM tr_niuke t_niu
		LEFT OUTER JOIN ma_hinmei m_hin
		ON m_hin.cd_hinmei = t_niu.cd_hinmei
		AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_bunrui m_bunrui
		ON m_hin.cd_bunrui = m_bunrui.cd_bunrui
		AND m_hin.kbn_hin = m_bunrui.kbn_hin
		LEFT OUTER JOIN ma_niuke m_niu
		ON t_niu.cd_niuke_basho = m_niu.cd_niuke_basho
		AND m_niu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_torihiki
		ON t_niu.cd_torihiki = m_torihiki.cd_torihiki
		AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_konyu m_konyu
		ON m_konyu.cd_hinmei = t_niu.cd_hinmei
		AND m_konyu.cd_torihiki = t_niu.cd_torihiki
		AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tani
		ON m_tani.cd_tani = m_konyu.cd_tani_nonyu
		WHERE
			t_niu.no_seq =
			(
				SELECT
					MIN(no_seq) 
				FROM tr_niuke
			)
			AND t_niu.no_niuke = @no_niuke
	END
	
	ELSE
	BEGIN
	
		DECLARE @initStr	VARCHAR
		DECLARE @initNum	SMALLINT
		DECLARE @initDeci	DECIMAL(2,1)
		DECLARE @initTime	DATETIME
	
		SET @initStr	= ''
		SET @initNum	= 0
		SET @initDeci	= 0.0
		SET @initTime	= '00:00:00.000'
	
		-- �����ޕϓ��\�ō쐬�����\��ŁA�׎���уf�[�^�����݂��Ȃ��ꍇ
		SELECT	
			m_niu.nm_niuke												-- �׎�ꏊ��
			,t_nonyu.dt_nonyu dt_niuke									-- �׎��,�[����
			,m_tani.nm_tani												-- �P�ʖ�
			,t_nonyu.cd_hinmei											-- �i���R�[�h
			,m_hin.nm_hinmei_ja											-- �i��(���{��)
			,m_hin.nm_hinmei_en											-- �i��(�p��)
			,m_hin.nm_hinmei_zh											-- �i��(������)
			,m_hin.nm_hinmei_vi
			,m_hin.nm_nisugata_hyoji									-- �׎p�\���p
			,t_nonyu.cd_torihiki										-- �����R�[�h
			,m_torihiki.nm_torihiki										-- ����於
			,m_hokan.nm_hokan_kbn										-- �i�ʏ��
			,@initTime tm_nonyu_yotei									-- �[���\�莞��
			,@initStr nm_bunrui											-- ���ޖ�
			,m_hin.dd_shomi												-- �ܖ�����
			,t_nonyu.su_nonyu su_nonyu_yotei							-- �[����
			,@initDeci su_nonyu_yotei_hasu								-- �[���\��[��
			,@initTime tm_nonyu_jitsu									-- ���[������
			,@initDeci su_nonyu_jitsu									-- ���[����
			,@initDeci su_nonyu_jitsu_hasu								-- ���[���[��
			,@initDeci kin_kuraire										-- ���z
			,@initTime dt_seizo											-- ������
			,@initTime dt_kigen											-- �ܖ�����
			,@initStr no_lot											-- ���b�gNo.
			,@initStr no_denpyo											-- �`�[No.
			,@initStr biko												-- ���l
			,t_nonyu.cd_hinmei cd_hinmei_maker							-- �i���R�[�h(14)
			,@initStr nm_kuni											-- ����
			,@initStr cd_maker											-- ���[�J�[�R�[�h(GLN)
			,@initStr nm_maker											-- ���[�J�[��
			,@initStr cd_maker_kojo										-- ���[�J�[�H��R�[�h
			,@initStr nm_maker_kojo										-- ���[�J�[��
			,@initStr nm_hyoji_nisugata_niuke							-- �׎p(��)
			,@initStr nm_tani_nonyu										-- �[���P��(��)
			,@initTime dt_nonyu											-- �[����
			,@initTime dt_label_hakko									-- ���x��������
			-- ��\��
			,m_hin.su_iri												-- ����(��\��)
			,m_hin.kbn_zei												-- �ŋ敪
			,t_nonyu.flg_kakutei										-- �m��t���O
			,ISNULL(m_konyu.cd_torihiki2, @initStr) AS cd_torihiki2		-- �����R�[�h2
			,ISNULL(m_konyu.cd_tani_nonyu, @initStr) AS cd_tani_nonyu	-- �[���P�ʃR�[�h
			,m_hin.kbn_hin												-- �i�敪
			,t_nonyu.no_nonyu											-- �[���ԍ�
		FROM tr_nonyu t_nonyu
		LEFT OUTER JOIN ma_hinmei m_hin
		ON t_nonyu.cd_hinmei = m_hin.cd_hinmei
		AND m_hin.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_bunrui m_bunrui
		ON m_hin.cd_bunrui = m_bunrui.cd_bunrui
		AND m_hin.kbn_hin = m_bunrui.kbn_hin
		LEFT OUTER JOIN ma_niuke m_niu
		ON m_hin.cd_niuke_basho = m_niu.cd_niuke_basho
		AND m_niu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_kbn_hokan m_hokan
		ON m_hin.kbn_hokan = m_hokan.cd_hokan_kbn
		AND m_hokan.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_torihiki m_torihiki
		ON t_nonyu.cd_torihiki = m_torihiki.cd_torihiki
		AND m_torihiki.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_konyu m_konyu
		ON m_konyu.cd_hinmei = t_nonyu.cd_hinmei
		AND m_konyu.cd_torihiki = t_nonyu.cd_torihiki
		AND m_konyu.flg_mishiyo = @shiyoMishiyoFlg
		LEFT OUTER JOIN ma_tani m_tani
		ON m_tani.cd_tani = m_konyu.cd_tani_nonyu
		WHERE
			t_nonyu.flg_yojitsu	= @yoteiYojitsuFlg
			AND t_nonyu.cd_hinmei = @cd_hinmei
			AND t_nonyu.cd_torihiki = @cd_torihiki
			AND @dt_nonyu <= t_nonyu.dt_nonyu 
			AND t_nonyu.dt_nonyu < (SELECT DATEADD(DD,1,@dt_nonyu))	
	END
END
GO
