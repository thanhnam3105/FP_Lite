IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LotNoBetsuZaikoShosai_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosai_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
�@�\        �F���b�gNo.�ʍ݌ɏڍ׌�������  �����������s���܂��B
�t�@�C����  �Fusp_LotNoBetsuZaikoShosai_select
���͈��� �@ �F@no_niuke, @cd_hinmei,�@@dt_niuke
              , @kbn_zaiko, @jissekiYojitsuFlg, @shiyoMishiyoFlg
              , @shiireNyushukkoKbn, @sotoinyuNyushukkoKbn
              , @horyuNyushukkoKbn, @ryohinNyushukkoKbn, @zaikuHennyu
              , @zaikuHenshutsu, @horyu, @ryohin, @skip, @top@, isExcel
�o�͈��� �@ �F@count
�߂�l   �@ �F
�쐬��   �@ �F2013.09.18 ADMAX kunii.h
�X�V��   �@ �F2015.09.10 ADMAX kakuta.y �����Ѝw���Ή�
�X�V��   �@ �F2015.10.05 MJ    ueno.k   ����[�����̉׎���͉׎���ѓ�(�[����)���o��  
�X�V��   �@ �F2015.10.16 MJ    ueno.k   �׎���ѓ��A�����̎��ԃI�t�Z�b�g�C���B�݋�ύX���̕������Ή�
�X�V��   �@ �F2015.12.21 ADMAX s.shibao �����̎擾����i���}�X�^���猴���ލw����}�X�^�ɕύX
�X�V��   �@ �F2016.07.12 BRC   motojima.m �����̎擾���@���C��
�X�V��   �@ �F2016.12.13 BRC   motojima.m �����Ή�
*****************************************************/
CREATE PROCEDURE [dbo].[usp_LotNoBetsuZaikoShosai_select] 
	@no_niuke				 VARCHAR(14)
	, @cd_hinmei			 VARCHAR(14)
	, @dt_niuke				 DATETIME
	, @kbn_zaiko			 SMALLINT
	, @jissekiYojitsuFlg	 SMALLINT
	, @shiyoMishiyoFlg		 SMALLINT
	, @shiireNyushukkoKbn	 SMALLINT
	, @sotoinyuNyushukkoKbn	 SMALLINT
	, @horyuNyushukkoKbn	 SMALLINT
	, @ryohinNyushukkoKbn	 SMALLINT
	--, @zaikuHennyu		 VARCHAR(30)
	, @zaikuHennyu			 NVARCHAR(30)
	--, @zaikuHenshutsu		 VARCHAR(30)
	, @zaikuHenshutsu		 NVARCHAR(30)
	--, @horyu				 VARCHAR(30)
	, @horyu				 NVARCHAR(30)
	--, @ryohin				 VARCHAR(30)
	, @ryohin				 NVARCHAR(30)
	, @skip					 DECIMAL(10)
	, @top					 DECIMAL(10)
	, @isExcel				 SMALLINT
	, @count				 INT OUTPUT
	, @tm_offset			 INT
AS
BEGIN

	DECLARE @start DECIMAL(10)
	DECLARE	@end   DECIMAL(10)
	DECLARE @true  BIT
	DECLARE @false BIT
	DECLARE @minSeqNo DECIMAL(8, 0)
	DECLARE @tm_minusoffset INT
			
	SET @start = @skip + 1
	SET @end   = @skip + @top
    SET @true  = 1
    SET @false = 0
    SET @tm_minusoffset = 0 - @tm_offset
	
	SELECT @minSeqNo = MIN(minS.no_seq) FROM tr_niuke minS;
	
	BEGIN
	
		WITH cte AS
		(
		
			SELECT
				ROW_NUMBER() OVER (ORDER BY t_niu.no_niuke, t_niu.kbn_zaiko, t_niu.no_seq) AS RN
--				, CONVERT(DATETIME,CONVERT(VARCHAR,ISNULL(t_niu.dt_niuke,''),111) + ' ' + 
--				LEFT((CONVERT(VARCHAR(8),ISNULL(t_niu.tm_nonyu_jitsu,''), 108)), 5))	dt_nitiji	--����
				,
				DATEADD(HOUR,@tm_minusoffset,
					CONVERT(DATETIME,CONVERT(VARCHAR,ISNULL(t_niu.dt_niuke,''),111) + ' ' + 
					LEFT((CONVERT(VARCHAR(8),ISNULL(DATEADD(HOUR,@tm_offset,t_niu.tm_nonyu_jitsu),''), 108)), 5)) 
				) dt_nitiji
				, ISNULL(t_niu.dt_niuke, '')											niuke
				, ISNULL(t_niu.tm_nonyu_jitsu, '')										tm_nonyu
--				, ISNULL(LEFT(DATENAME(weekday, t_niu.tm_nonyu_jitsu), 1), '')			yobi_nonyu	--�j��
				,CASE
					WHEN t_niu.no_seq = @minSeqNo THEN 
						ISNULL(LEFT(DATENAME(weekday, t_niu.dt_nonyu), 1), '')			--�׎���ѓ��̗j��
					ELSE 
						ISNULL(LEFT(DATENAME(weekday, t_niu.dt_niuke), 1), '')			--�׎���̗j��
				END
				AS yobi_nonyu 
				, (CASE		
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @horyuNyushukkoKbn  AND t_niu.kbn_zaiko = 1 ) OR
						   (ISNULL( t_niu.kbn_nyushukko, '') = @ryohinNyushukkoKbn AND t_niu.kbn_zaiko = 2 ) THEN @ZaikuHenshutsu
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @horyuNyushukkoKbn  AND t_niu.kbn_zaiko = 2 ) OR
						   (ISNULL( t_niu.kbn_nyushukko, '') = @ryohinNyushukkoKbn AND t_niu.kbn_zaiko = 1 ) THEN @ZaikuHennyu
					  ELSE ISNULL( ma_nyu.nm_kbn_nyushukko, '' ) END 
				  )												nm_kbn_nyushukko					--���o�ɋ敪
				, (CASE 
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @horyuNyushukkoKbn  AND t_niu.kbn_zaiko = 1 ) OR
						   (ISNULL( t_niu.kbn_nyushukko, '') = @ryohinNyushukkoKbn AND t_niu.kbn_zaiko = 2 )THEN @Horyu
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @horyuNyushukkoKbn  AND t_niu.kbn_zaiko = 2 ) OR
						   (ISNULL( t_niu.kbn_nyushukko, '') = @ryohinNyushukkoKbn AND t_niu.kbn_zaiko = 1 ) THEN @Ryohin
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @shiireNyushukkoKbn ) OR
						   (ISNULL( t_niu.kbn_nyushukko, '') = @sotoinyuNyushukkoKbn ) THEN ISNULL(ma_tori.nm_torihiki,'')
					  ELSE '' END )								nm_torihiki					-- ���o�ɐ�
				, ISNULL(t_niu.su_nonyu_jitsu,0)				su_nonyu_jitsu				-- ����C/S��
				, ISNULL(t_niu.su_nonyu_jitsu_hasu,0)			su_nonyu_jitsu_hasu			-- ���ɒ[��
				, ISNULL(t_niu.su_shukko, 0)					su_shukko					-- �o��C/S��
				, ISNULL(t_niu.su_shukko_hasu,0)				su_shukko_hasu				-- �o�ɒ[��
				, ISNULL(t_niu.su_kakozan,0)					su_kakozan					-- ���H�cC/S��
				, ISNULL(t_niu.su_kakozan_hasu,0)				su_kakozan_hasu				-- ���H�c�[��
				, ISNULL(t_niu.su_zaiko, 0)					    su_zaiko					-- �݌�C/S��
				, ISNULL(t_niu.su_zaiko_hasu,0)				    su_zaiko_hasu				-- �݌ɒ[��
				, ISNULL(t_niu.biko,'')						    biko						-- ���l
				, ISNULL(t_niu.dt_niuke, '')				    dt_niuke					-- �׎���i��\���j
				, t_niu.no_seq									no_seq                      -- �V�[�P���X�ԍ�
				, ISNULL( ma_niu.nm_niuke, '')					nm_niuke					-- �׎�ꏊ���i��\�����ځj
				, max_no.max_seqno								max_seqno					-- �ŐV�̃V�[�P���X�ԍ��i��\�����ځj
				, ISNULL(t_niu.kbn_zaiko,'')					kbn_zaiko					-- �݌ɋ敪�i��\�����ځj
				, ISNULL(t_niu.kbn_nyushukko,'')				kbn_nyushukko				-- ���o�ɋ敪�i��\�����ځj
				, CONVERT(varchar,ISNULL(t_nyu.flg_kakutei,0))	flg_kakutei					-- �m��t���O�i��\�����ځj
				, ISNULL(ma_hin.nm_nisugata_hyoji, '')			nm_nisugata_hyoji			-- �׎p�\���i��\�����ځj
				, ISNULL(t_nyu.cd_torihiki, '' )				cd_torihiki					-- �����R�[�h�i��\�����ځj
				, ISNULL(t_niu.tm_nonyu_jitsu, '')              tm_nonyu_jitsu              -- ���[�������i��\�����ځj          
				, ISNULL(t_niu.kbn_nyushukko,'')			    kbn_nyushukko_other			-- ���o�ɋ敪�y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.kbn_zaiko,'')					kbn_zaiko_other				-- �݌ɋ敪�y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_nonyu_jitsu,0)				su_nonyu_jitsu_other		-- ����C/S���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_nonyu_jitsu_hasu,0)		su_nonyu_jitsu_hasu_other	-- ���ɒ[���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_shukko, 0)					su_shukko_other				-- �o��C/S���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_shukko_hasu,0)				su_shukko_hasu_other		-- �o�ɒ[���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_kakozan,0)					su_kakozan_other			-- ���H�cC/S���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_kakozan_hasu,0)			su_kakozan_hasuu_other		-- ���H�c�[���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_zaiko, 0)					su_zaiko_other				-- �݌�C/S���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.su_zaiko_hasu,0)				su_zaiko_hasu_other			-- �݌ɒ[���y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL(tn_other.no_seq, 0)					no_seq_other				-- �V�[�P���X�ԍ��y�ʍ݌ɋ敪�i��\�����ځj�z
				, ISNULL ( m_konyu.cd_tani_nonyu, ma_hin.cd_tani_nonyu ) AS cd_tani_nonyu
				, (CASE 
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @horyuNyushukkoKbn  AND @kbn_zaiko = 1 )
						   THEN
							(CASE WHEN ma_hin.cd_tani_nonyu = '4' OR ma_hin.cd_tani_nonyu = '11'
								THEN
									--�[���P�ʂ�Kg�EL�̏ꍇz
									((t_niu.su_shukko * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_shukko_hasu / 1000)) * -1
						   		ELSE
						   			--�[���P�ʂ�Kg�EL�ȊO�̏ꍇ
						   			((t_niu.su_shukko * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_shukko_hasu * ma_hin.wt_ko)) * -1
							END) 
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @ryohinNyushukkoKbn AND @kbn_zaiko = 2 )
						   THEN
							(CASE WHEN ma_hin.cd_tani_nonyu = '4' OR ma_hin.cd_tani_nonyu = '11'
								THEN
									--�[���P�ʂ�Kg�EL�̏ꍇz
									((t_niu.su_shukko * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_shukko_hasu / 1000)) * 1
						   		ELSE
						   			--�[���P�ʂ�Kg�EL�ȊO�̏ꍇ
						   			((t_niu.su_shukko * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_shukko_hasu * ma_hin.wt_ko)) * 1
							END) 
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @horyuNyushukkoKbn  AND @kbn_zaiko = 2 ) 
						   THEN
							(CASE WHEN ma_hin.cd_tani_nonyu = '4' OR ma_hin.cd_tani_nonyu = '11'
								THEN
									--�[���P�ʂ�Kg�EL�̏ꍇ
									((t_niu.su_nonyu_jitsu * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_nonyu_jitsu_hasu / 1000)) * -1
						   		ELSE
						   			--�[���P�ʂ�Kg�EL�ȊO�̏ꍇ
						   			((t_niu.su_nonyu_jitsu * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_nonyu_jitsu_hasu * ma_hin.wt_ko)) * -1
							END) 
					  WHEN (ISNULL( t_niu.kbn_nyushukko, '') = @ryohinNyushukkoKbn AND @kbn_zaiko = 1 ) 
						   THEN
							(CASE WHEN ma_hin.cd_tani_nonyu = '4' OR ma_hin.cd_tani_nonyu = '11'
								THEN
									--�[���P�ʂ�Kg�EL�̏ꍇ
									((t_niu.su_nonyu_jitsu * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_nonyu_jitsu_hasu / 1000)) * 1
						   		ELSE
						   			--�[���P�ʂ�Kg�EL�ȊO�̏ꍇ
						   			((t_niu.su_nonyu_jitsu * m_konyu.su_iri * ma_hin.wt_ko) + (t_niu.su_nonyu_jitsu_hasu * ma_hin.wt_ko)) * 1
							END) 
					  ELSE 0 END )	AS su_moto_chosei	-- �����
				, 0					AS su_chosei		-- ������
				,CASE
					WHEN t_niu.no_seq = @minSeqNo THEN 
						ISNULL(t_niu.dt_nonyu, '')
--						DATEADD(HOUR,@tm_minusoffset,
--							CONVERT(DATETIME,CONVERT(VARCHAR,ISNULL(t_niu.dt_nonyu,''),111) + ' ' + 
--							LEFT((CONVERT(VARCHAR(8),ISNULL(DATEADD(HOUR,@tm_offset,t_niu.tm_nonyu_jitsu),''), 108)), 5)) 
--						)
--						CONVERT(DATETIME,CONVERT(VARCHAR,ISNULL(t_niu.dt_nonyu,''),111) + ' ' + 
--						LEFT((CONVERT(VARCHAR(8),ISNULL(t_niu.tm_nonyu_jitsu,''), 108)), 5)) --�[������������쐬
					ELSE 
						ISNULL(t_niu.dt_niuke, '')
--						DATEADD(HOUR,@tm_minusoffset,
--							CONVERT(DATETIME,CONVERT(VARCHAR,ISNULL(t_niu.dt_niuke,''),111) + ' ' + 
--							LEFT((CONVERT(VARCHAR(8),ISNULL(DATEADD(HOUR,@tm_offset,t_niu.tm_nonyu_jitsu),''), 108)), 5))
--						)
--						CONVERT(DATETIME,CONVERT(VARCHAR,ISNULL(t_niu.dt_niuke,''),111) + ' ' + 
--						LEFT((CONVERT(VARCHAR(8),ISNULL(t_niu.tm_nonyu_jitsu,''), 108)), 5)) --�׎����������쐬
				END
				AS dt_niuke_jisseki
				--�q��
				, t_niu.cd_niuke_basho
				, CASE WHEN t_niu.kbn_nyushukko IN (11, 12) THEN 
						CASE WHEN deleteRow.no_seq IS NOT NULL THEN 1 ELSE 0 END
					ELSE 1 
				END AS flg_delete

			FROM
				tr_niuke t_niu

			LEFT JOIN
				tr_nonyu t_nyu
			ON
			--	t_niu.cd_hinmei   = t_nyu.cd_hinmei
			--AND
			--	t_niu.dt_niuke    = t_nyu.dt_nonyu
			--AND
			--	t_niu.cd_torihiki = t_nyu.cd_torihiki
			--AND
				t_niu.no_seq =
				(SELECT
					MIN ( t_niu.no_seq )
				FROM
					tr_niuke t_niu
				)
			AND
				t_nyu.flg_yojitsu    = @jissekiYojitsuFlg
			AND
				t_nyu.no_nonyu		 = t_niu.no_nonyu

			LEFT JOIN 
				(
					SELECT
						data.no_niuke
						, data.kbn_zaiko
						, data.cd_niuke_basho
						, data.no_seq
					FROM tr_niuke data
					WHERE
						data.no_niuke  = @no_niuke
						AND data.no_seq IN ( SELECT
												niuke.no_seq
											FROM tr_niuke niuke
											WHERE
												niuke.no_niuke  = @no_niuke
												AND NOT EXISTS (
													SELECT
														niuke1.no_niuke
													FROM tr_niuke niuke1
													WHERE
														niuke1.no_niuke  = @no_niuke
														AND niuke.no_seq < niuke1.no_seq
														AND niuke.cd_niuke_basho = niuke1.cd_niuke_basho_before
												)
												AND NOT EXISTS (
													SELECT
														niuke2.no_niuke
													FROM tr_niuke niuke2
													WHERE
														niuke2.no_niuke  = @no_niuke
														AND niuke.no_seq < niuke2.no_seq
														AND niuke.cd_niuke_basho = niuke2.cd_niuke_basho
												)
											) 
				) deleteRow
			ON t_niu.no_niuke = deleteRow.no_niuke
			AND t_niu.kbn_zaiko = deleteRow.kbn_zaiko
			AND t_niu.cd_niuke_basho = deleteRow.cd_niuke_basho
			AND t_niu.no_seq = deleteRow.no_seq

			LEFT JOIN
				ma_kbn_zaiko ma_zaiko
			ON
				t_niu.kbn_zaiko      = ma_zaiko.kbn_zaiko
			LEFT JOIN
				ma_kbn_nyushukko ma_nyu
			ON
				t_niu.kbn_nyushukko  = ma_nyu.kbn_nyushukko
			LEFT JOIN
				ma_niuke ma_niu
			ON
				t_niu.cd_niuke_basho = ma_niu.cd_niuke_basho
			AND
				ma_niu.flg_mishiyo   = @shiyoMishiyoFlg
			LEFT JOIN
				ma_torihiki ma_tori
			ON
				t_niu.cd_torihiki    = ma_tori.cd_torihiki
			AND
				ma_tori.flg_mishiyo  = @shiyoMishiyoFlg
			LEFT JOIN
				ma_hinmei ma_hin
			ON
				t_niu.cd_hinmei      = ma_hin.cd_hinmei
			AND
				ma_hin.flg_mishiyo   = @shiyoMishiyoFlg
				
			LEFT JOIN 
				ma_konyu m_konyu
			ON 
				t_niu.cd_hinmei = m_konyu.cd_hinmei
			AND 
				t_niu.cd_torihiki = m_konyu.cd_torihiki

			LEFT JOIN
				tr_niuke tn_other
			ON
				t_niu.no_niuke       = tn_other.no_niuke
			AND
				t_niu.no_seq         = tn_other.no_seq
			AND
				t_niu.cd_niuke_basho = tn_other.cd_niuke_basho
			AND
				t_niu.kbn_zaiko <> tn_other.kbn_zaiko,
				(SELECT
					MAX ( tr_niu.no_seq ) max_seqno
					, tr_niu.dt_niuke
				FROM
					tr_niuke tr_niu
				WHERE
						tr_niu.no_niuke  = @no_niuke
					AND
						tr_niu.cd_hinmei = @cd_hinmei
					AND
	--					tr_niu.dt_niuke >= @dt_niuke
						(
							(tr_niu.dt_niuke >= @dt_niuke
							AND
							tr_niu.no_seq <> @minSeqNo
							)
							OR
							(tr_niu.dt_nonyu >= @dt_niuke
							AND 
							tr_niu.no_seq = @minSeqNo
							)
						)
				AND
					tr_niu.kbn_zaiko = @kbn_zaiko
				GROUP BY
					tr_niu.dt_niuke
					
				) max_no
				
			WHERE
				t_niu.no_niuke  = @no_niuke
			AND
				t_niu.cd_hinmei = @cd_hinmei
			AND
--				t_niu.dt_niuke >= @dt_niuke
				(
					(t_niu.dt_niuke >= @dt_niuke
					AND
					t_niu.no_seq <> @minSeqNo
					)
					OR
					(t_niu.dt_nonyu >= @dt_niuke
					AND 
					t_niu.no_seq = @minSeqNo
					)
				)
			AND
				t_niu.kbn_zaiko = @kbn_zaiko
			AND t_niu.dt_niuke = max_no.dt_niuke
		)
	
		SELECT
			dt_nitiji
			, niuke
			, tm_nonyu
			, yobi_nonyu
			, nm_kbn_nyushukko
			, nm_torihiki
			, su_nonyu_jitsu
			, su_nonyu_jitsu_hasu
			, su_shukko
			, su_shukko_hasu
			, su_kakozan
			, su_kakozan_hasu
			, su_zaiko
			, su_zaiko_hasu
			, biko
			, dt_niuke
			, no_seq
			, nm_niuke
			, max_seqno
			, kbn_zaiko
			, kbn_nyushukko
			, flg_kakutei
			, nm_nisugata_hyoji
			, cd_torihiki
			, tm_nonyu_jitsu
			, kbn_nyushukko_other
			, kbn_zaiko_other
			, su_nonyu_jitsu_other
			, su_nonyu_jitsu_hasu_other
			, su_shukko_other
			, su_shukko_hasu_other
			, su_kakozan_other
			, su_kakozan_hasuu_other
			, su_zaiko_other
			, su_zaiko_hasu_other
			, no_seq_other
			, cd_tani_nonyu
			, su_moto_chosei
			, su_chosei
			, cnt
			, dt_niuke_jisseki
			, cd_niuke_basho
			, flg_delete
		FROM(
				SELECT 
					MAX(RN) OVER() cnt
					,*
				FROM
					cte
			)  cte_row	
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
		ORDER BY 
				no_seq
				, kbn_nyushukko
	END
END
GO
