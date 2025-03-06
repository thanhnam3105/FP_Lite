DROP PROCEDURE [dbo].[usp_NiukeIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*****************************************************
�@�\        �F�׎�ꗗ�@�׎�\�����������
�t�@�C����  �Fusp_NiukeIchiran_select
���͈���    �F@shiyoMishiyoFlg,�@@shiireNyushukkoKbn
              , @sotoinyuNyushukkoKbn, @dateRadio
              , @dt_niuke_st , @dt_niuke_ed
              , @dt_nonyu_st , @dt_nonyu_ed
              , @cd_niuke_basho, @cd_torihiki 
              , @cd_hinmei, @flg_shonin
              , @no_nohinsho, @no_zeikan_shorui
              , @isExcel, @skip, @top
�o�͈���    �F
�߂�l      �F
�쐬��      �F2013.10.23  ADMAX kunii.h
�X�V��      �F2014.02.04  ADMAX kakuta.y	-- ���t�͈͂�ύX�A�[���g�����ɂ݂̂�����т��擾
            �F2015.02.13  ADMAX tsujita.s	-- �[���g�����̒[�����擾
            �F2015.08.10  ADMAX taira.s		-- ���������ɉ׎���ѓ�,���t�I��,���F�󋵂�ǉ��B
												�擾���ڂɔ[�i���ԍ�,�Ŋ֏���No.��ǉ��B
			�F2015.08.21  ADMAX taira.s		-- ���������ɔ[�i���ԍ�,�Ŋ֏���No.��ǉ��B
			�F2015.09.29  MJ	ueno.k 		-- �擾���ڂɕi���}�X�^.���g�p�t���O��ǉ��B
			�F2016.12.19  BRC	motojima.m 	-- �����Ή�
			:2017.04.17  BRC	yokota.t	-- �y�׎�ꗗ��ʁz���o�ɋ敪9�i�ǉ��j�̃f�[�^���擾����悤�ύX
			:2018.11.02  TOS	nakamura.r	-- �׎���͂ɕ\������āA�׎�ꗗ�ɕ\������Ȃ��o�O���C��
			:2019.01.07  TOS	nakamura.r	-- ���ю擾�̂��߂̔[���g�����̌��������Ɏ����R�[�h��ǉ�
			:2019.08.27  TOS	nakamura.r	-- �׎�����׎���ѓ��ɕύX���邱�Ƃɔ����C��
			:2019.09.15  TOS	echigo.r	-- �قȂ���t�ŕ��[���Ă��A�������׎�\��Ɖ׎���т��R�Â��ĕ\�������悤�C��
			:2019.11.19  BRC	kanehira	-- tm_nonyu_yotei��[���\����Ŏ擾����悤�ɏC��
			:2020.01.08  TOS    wang.w      -- ���l��̒ǉ�
			:2022.04.19  BRC    yanagita.y  -- �^�C���A�E�g�Ή�(#1761)
*****************************************************/
CREATE PROCEDURE [dbo].[usp_NiukeIchiran_select] 
	@shiyoMishiyoFlg        SMALLINT		-- ���g�p�t���O/�g�p
	,@shiireNyushukkoKbn	SMALLINT		-- ���o�ɋ敪/�d��
	,@sotoinyuNyushukkoKbn	SMALLINT		-- ���o�ɋ敪/�O�ړ�
	,@tsuikaNyushukkoKbn	SMALLINT		-- ���o�ɋ敪/�ǉ�
	,@dateRadio				SMALLINT		-- ��������/���t�I��
	,@dt_niuke_st			DATETIME		-- ��������/�׎���i�J�n�j
	,@dt_niuke_ed			DATETIME		-- ��������/�׎���i�I�����j
	,@dt_nonyu_st			DATETIME		-- ��������/�׎���ѓ��i�J�n�j
	,@dt_nonyu_ed			DATETIME		-- ��������/�׎���ѓ��i�I�����j
	,@cd_niuke_basho		VARCHAR(10)	    -- ��������/�׎�ꏊ
	,@cd_torihiki			VARCHAR(13)	    -- ��������/�����
	,@cd_hinmei				VARCHAR(14)	    -- ��������/�i��
	,@flg_shonin			SMALLINT		-- ��������/���F��
	--,@no_nohinsho			VARCHAR(16)	    -- ��������/�[�i���ԍ�
	,@no_nohinsho			NVARCHAR(16)	-- ��������/�[�i���ԍ�
	--,@no_zeikan_shorui	VARCHAR(16)	    -- ��������/�Ŋ֏���No.
	,@no_zeikan_shorui		NVARCHAR(16)	-- ��������/�Ŋ֏���No.
	,@isExcel			    SMALLINT		-- �G�N�Z���o�͔���p
	,@skip				    DECIMAL(10)		-- ���������n�_
	,@top					DECIMAL(10)		-- �����������
	,@yoteiYojitsuFlg		NUMERIC(1)		-- �敪�^�R�[�h�ꗗ�D�\���t���O�D�\��
	,@jissekiYojitsuFlg		NUMERIC(1)		-- �敪�^�R�[�h�ꗗ�D�\���t���O�D�\��
WITH RECOMPILE
AS
BEGIN
	
	DECLARE
		@start	DECIMAL(10)
		,@end   DECIMAL(10)
		,@true  BIT
		,@false BIT
	
	SET @start = @skip + 1
	SET @end   = @skip + @top
    SET @true  = 1
    SET @false = 0;
    
	WITH cte AS
		(
			SELECT
				*
				--,ROW_NUMBER() OVER (ORDER BY uni.dt_niuke, uni.cd_niuke_basho, uni.cd_hinmei) AS RN
				,ROW_NUMBER() OVER (ORDER BY uni.dt_niuke, uni.cd_niuke_basho,uni.cd_torihiki,uni.cd_bunrui,uni.cd_hinmei) AS RN				
			FROM
				(
					SELECT
						ISNULL ( t_niu.flg_shonin	, 0 ) AS flg_shonin
						--,ISNULL ( ISNULL(t_nou_yotei.dt_nonyu, t_niu.dt_niuke)	, '' ) AS dt_niuke
						,ISNULL ( ISNULL(t_nou_yotei.dt_nonyu, t_niu.tm_nonyu_yotei)	, '' ) AS dt_niuke
						,ISNULL ( ma_niu.nm_niuke, '' ) AS nm_niuke
						,ISNULL ( ma_niu.cd_niuke_basho, '' ) AS cd_niuke_basho
						,ISNULL ( t_niu.cd_hinmei, '' ) AS cd_hinmei
						,ISNULL ( ma_hin.nm_hinmei_ja, '' ) AS nm_hinmei_ja
						,ISNULL ( ma_hin.nm_hinmei_en, '' ) AS nm_hinmei_en
						,ISNULL ( ma_hin.nm_hinmei_zh, '' ) AS nm_hinmei_zh
						,ISNULL ( ma_hin.nm_hinmei_vi, '' ) AS nm_hinmei_vi
						,ISNULL ( ma_hin.nm_nisugata_hyoji, '' ) AS nm_nisugata_hyoji
						,ISNULL ( ma_tori.nm_torihiki, '' ) AS nm_torihiki
						,ISNULL ( ma_tori.cd_torihiki, '' ) AS cd_torihiki
						,ISNULL ( t_niu.tm_nonyu_yotei, '' ) AS tm_nonyu_yotei
						,ISNULL ( t_niu.su_nonyu_yotei, 0 ) AS su_nonyu_yotei
						,ISNULL ( t_niu.su_nonyu_yotei_hasu, 0 ) AS su_nonyu_yotei_hasu
						,ISNULL ( t_niu.dt_nonyu, '' ) AS dt_nonyu
						,ISNULL ( t_niu.tm_nonyu_jitsu, '' ) AS tm_nonyu_jitsu
						,ISNULL ( t_niu.su_nonyu_jitsu, 0 ) AS su_nonyu_jitsu
						,ISNULL ( t_niu.su_nonyu_jitsu_hasu, 0 ) AS su_nonyu_hasuu_jitsu
						,ISNULL ( t_niu.no_lot, 0 ) AS no_lot
						,ISNULL ( ma_hkn.nm_hokan_kbn, '' ) AS nm_hokan_kbn
						,ISNULL ( t_niu.kbn_nyushukko, '' ) AS kbn_nyushukko
						,m_bunrui.cd_bunrui
						,ISNULL ( m_konyu.cd_tani_nonyu, ma_hin.cd_tani_nonyu ) AS cd_tani_nonyu
						,ISNULL ( t_niu.no_nohinsho, '' ) AS no_nohinsho
						,ISNULL ( t_niu.no_zeikan_shorui, '' ) AS no_zeikan_shorui
						,t_niu.no_niuke AS no_niuke
						,t_niu.kbn_zaiko AS kbn_zaiko
						,t_niu.no_seq AS no_seq
						,ma_hin.flg_mishiyo
						,ISNULL ( t_niu.biko, '' ) AS biko
					FROM tr_niuke t_niu
					LEFT OUTER JOIN ma_niuke ma_niu
					ON t_niu.cd_niuke_basho = ma_niu.cd_niuke_basho
					AND ma_niu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_hinmei ma_hin
					ON t_niu.cd_hinmei = ma_hin.cd_hinmei
					AND ma_hin.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_hokan ma_hkn
					ON ma_hin.kbn_hokan = ma_hkn.cd_hokan_kbn
					AND ma_hkn.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_torihiki ma_tori
					ON t_niu.cd_torihiki = ma_tori.cd_torihiki
					AND ma_tori.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON ma_hin.kbn_hin = m_bunrui.kbn_hin
						AND ma_hin.cd_bunrui = m_bunrui.cd_bunrui
						AND m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_niu.cd_hinmei = m_konyu.cd_hinmei
						AND t_niu.cd_torihiki = m_konyu.cd_torihiki
					LEFT OUTER JOIN tr_nonyu t_nou_jiseki
					ON t_niu.no_nonyu = t_nou_jiseki.no_nonyu
						AND t_nou_jiseki.flg_yojitsu = 1
					LEFT OUTER JOIN tr_nonyu t_nou_yotei
					ON t_nou_jiseki.no_nonyu_yotei = t_nou_yotei.no_nonyu
						AND t_nou_yotei.flg_yojitsu = 0
					WHERE
						t_niu.kbn_nyushukko IN (@shiireNyushukkoKbn, @sotoinyuNyushukkoKbn, @tsuikaNyushukkoKbn)
						AND (
							(@dateRadio = 1
							--AND ISNULL(t_nou_yotei.dt_nonyu,t_niu.dt_niuke) >= @dt_niuke_st 
							--AND ISNULL(t_nou_yotei.dt_nonyu,t_niu.dt_niuke) < DATEADD(DD,1,@dt_niuke_ed))
							AND ISNULL(t_nou_yotei.dt_nonyu,t_niu.tm_nonyu_yotei) >= @dt_niuke_st 
							AND ISNULL(t_nou_yotei.dt_nonyu,t_niu.tm_nonyu_yotei) < DATEADD(DD,1,@dt_niuke_ed))
							OR
							(@dateRadio = 2
							AND t_niu.dt_nonyu >= @dt_nonyu_st
							AND t_niu.dt_nonyu < DATEADD(DD,1,@dt_nonyu_ed))
						)											
						AND ((ISNULL(@cd_niuke_basho, '') = '' AND t_niu.cd_niuke_basho LIKE( '%' + @cd_niuke_basho + '%' ))
						OR ((ISNULL(@cd_niuke_basho, '') <> '' AND t_niu.cd_niuke_basho = @cd_niuke_basho)))			
						AND ((ISNULL(@cd_torihiki, '') = '' AND t_niu.cd_torihiki LIKE( '%' + @cd_torihiki + '%' )) 
						OR ((ISNULL(@cd_torihiki, '') <> '' AND t_niu.cd_torihiki = @cd_torihiki)))			
						AND ((ISNULL(@cd_hinmei, '') = '' AND t_niu.cd_hinmei LIKE( '%' + @cd_hinmei + '%' )) 
						OR ((ISNULL(@cd_hinmei, '') <> '' AND t_niu.cd_hinmei = @cd_hinmei)))
						AND (
							(@flg_shonin = 1
							AND ISNULL(t_niu.flg_shonin, 0) = 0)
							OR
							(@flg_shonin = 2
							AND ISNULL(t_niu.flg_shonin, 0) = 1)
							OR
							(@flg_shonin = 3
							AND ISNULL(t_niu.flg_shonin, 0) in (0, 1))
						)
						AND ((ISNULL(@no_nohinsho, '') = '') 
						OR ((ISNULL(@no_nohinsho, '') <> '' AND t_niu.no_nohinsho LIKE( '%' + @no_nohinsho + '%' ))))
						AND ((ISNULL(@no_zeikan_shorui, '') = '') 
						OR ((ISNULL(@no_zeikan_shorui, '') <> '' AND t_niu.no_zeikan_shorui LIKE( '%' + @no_zeikan_shorui + '%' ))))					
						AND t_niu.dt_niuke IS NOT NULL

					UNION ALL

					SELECT
						0
						,ISNULL  ( t_nyu.dt_nonyu, '' ) AS dt_niuke
						,ISNULL ( ma_niu.nm_niuke, '' ) AS nm_niuke
						,ISNULL ( ma_niu.cd_niuke_basho, '' ) AS cd_niuke_basho
						,ISNULL ( t_nyu.cd_hinmei, '' ) AS cd_hinmei
						,ISNULL ( ma_hin.nm_hinmei_ja, '' ) AS nm_hinmei_ja
						,ISNULL ( ma_hin.nm_hinmei_en, '' ) AS nm_hinmei_en
						,ISNULL ( ma_hin.nm_hinmei_zh, '' ) AS nm_hinmei_zh
						,ISNULL ( ma_hin.nm_hinmei_vi, '' ) AS nm_hinmei_vi
						,ISNULL ( ma_hin.nm_nisugata_hyoji, '' ) AS nm_nisugata_hyoji
						,ISNULL ( ma_tori.nm_torihiki, '' ) AS nm_torihiki
						,ISNULL ( ma_tori.cd_torihiki, '' ) AS cd_torihiki
						,NULL tm_nonyu_yotei
						,ISNULL (t_nyu.su_nonyu, 0 ) AS su_nonyu_yotei
						--,0 AS su_nonyu_yotei_hasu
						,ISNULL (t_nyu.su_nonyu_hasu, 0 ) AS su_nonyu_yotei_hasu
						,NULL AS dt_nonyu
						,NULL tm_nonyu_jitsu
						,ISNULL(t_nyu_jitsu.su_nonyu,0) AS su_nonyu_jitsu
						--,CASE t_nyu.flg_yojitsu
						--	WHEN @yoteiYojitsuFlg THEN 0
						--	ELSE ISNULL(t_nyu.su_nonyu_hasu, 0)
						--END AS su_nonyu_hasuu_jitsu
						,ISNULL(t_nyu_jitsu.su_nonyu_hasu,0) AS su_nonyu_hasuu_jitsu
						,NULL AS no_lot
						,ISNULL ( ma_hkn.nm_hokan_kbn, '' ) AS nm_hokan_kbn
						,@shiireNyushukkoKbn AS kbn_nyushukko
						,m_bunrui.cd_bunrui
						,ISNULL ( m_konyu.cd_tani_nonyu, ma_hin.cd_tani_nonyu ) AS cd_tani_nonyu
						,''
						,''
						,''
						,0
						,0
						,ma_hin.flg_mishiyo
						,'' AS biko
					FROM tr_nonyu t_nyu
					LEFT OUTER JOIN ma_hinmei ma_hin
					ON t_nyu.cd_hinmei = ma_hin.cd_hinmei
					AND ma_hin.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_niuke ma_niu
					ON ma_hin.cd_niuke_basho = ma_niu.cd_niuke_basho
					AND ma_niu.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_kbn_hokan ma_hkn
					ON ma_hin.kbn_hokan = ma_hkn.cd_hokan_kbn
					AND ma_hkn.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_torihiki ma_tori
					ON t_nyu.cd_torihiki = ma_tori.cd_torihiki
					AND ma_tori.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN tr_nonyu t_nyu_jitsu
					ON t_nyu.cd_hinmei = t_nyu_jitsu.cd_hinmei
					AND t_nyu.no_nonyu = t_nyu_jitsu.no_nonyu
					AND t_nyu.dt_nonyu = t_nyu_jitsu.dt_nonyu
					AND t_nyu.cd_torihiki = t_nyu_jitsu.cd_torihiki
					AND t_nyu_jitsu.flg_yojitsu = @jissekiYojitsuFlg
					LEFT OUTER JOIN ma_bunrui m_bunrui
					ON ma_hin.kbn_hin = m_bunrui.kbn_hin
						AND ma_hin.cd_bunrui = m_bunrui.cd_bunrui
						AND m_bunrui.flg_mishiyo = @shiyoMishiyoFlg
					LEFT OUTER JOIN ma_konyu m_konyu
					ON t_nyu.cd_hinmei = m_konyu.cd_hinmei
						AND t_nyu.cd_torihiki = m_konyu.cd_torihiki
					WHERE
						t_nyu.dt_nonyu >= @dt_niuke_st 
						AND t_nyu.dt_nonyu < DATEADD(DD,1,@dt_niuke_ed)
						AND ((ISNULL(@cd_niuke_basho, '') = '' AND ma_hin.cd_niuke_basho LIKE( '%' + @cd_niuke_basho + '%' )) OR ((ISNULL(@cd_niuke_basho, '') <> '' AND ma_hin.cd_niuke_basho = @cd_niuke_basho)))
						AND ((ISNULL(@cd_torihiki, '') = '' AND t_nyu.cd_torihiki LIKE( '%' + @cd_torihiki + '%' )) OR ((ISNULL(@cd_torihiki, '') <> '' AND t_nyu.cd_torihiki = @cd_torihiki)))	
						AND ((ISNULL(@cd_hinmei, '') = '' AND t_nyu.cd_hinmei LIKE( '%' + @cd_hinmei + '%' )) OR ((ISNULL(@cd_hinmei, '') <> '' AND t_nyu.cd_hinmei = @cd_hinmei)))	
						AND t_nyu.cd_hinmei LIKE ( '%' + @cd_hinmei + '%' )
						AND NOT EXISTS
							(
								SELECT
									*
								FROM tr_niuke t_niu
								WHERE
									t_niu.no_nonyu = t_nyu.no_nonyu
									AND t_niu.kbn_nyushukko IN (@shiireNyushukkoKbn, @sotoinyuNyushukkoKbn, @tsuikaNyushukkoKbn) 
							)
						AND t_nyu.flg_yojitsu = @yoteiYojitsuFlg
						AND @dateRadio = 1		--��������/���t�I�����\����w��̂�						
						AND 
							CASE 
								WHEN @no_nohinsho = '' THEN 1 
								ELSE 0 
							END = 1
						AND 
							CASE 
								WHEN @no_zeikan_shorui = '' THEN 1 
								ELSE 0 
							END = 1
						AND 
							CASE 
								WHEN @flg_shonin = 2 THEN 0 
								ELSE 1 
							END = 1
				) uni
		)	
	
	SELECT
		cnt
		,cte_row.flg_shonin
        ,cte_row.dt_niuke
        ,cte_row.dt_nonyu AS dt_niuke_jisseki_mei
		,cte_row.nm_niuke
		,cte_row.cd_niuke_basho
		,cte_row.cd_hinmei
		,cte_row.nm_hinmei_ja
		,cte_row.nm_hinmei_en
		,cte_row.nm_hinmei_zh
		,cte_row.nm_hinmei_vi
		,cte_row.nm_nisugata_hyoji
		,cte_row.nm_torihiki
		,cte_row.cd_torihiki
		,cte_row.tm_nonyu_yotei
		,cte_row.dt_niuke AS dt_niuke_yotei
		,cte_row.su_nonyu_yotei
		,cte_row.su_nonyu_yotei_hasu
		,cte_row.dt_nonyu
		,cte_row.tm_nonyu_jitsu
		,cte_row.su_nonyu_jitsu
		,cte_row.su_nonyu_hasuu_jitsu
		,cte_row.no_lot
		,cte_row.nm_hokan_kbn
		,cte_row.kbn_nyushukko
		,cte_row.cd_tani_nonyu
		,cte_row.no_nohinsho
		,cte_row.no_zeikan_shorui
		,cte_row.no_niuke
		,cte_row.kbn_zaiko
		,cte_row.no_seq
		,cte_row.flg_mishiyo
		,cte_row.biko
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
			OR 
			(
				@isExcel = @true
			)
		)
	--ORDER BY 1,3,4
END






GO
