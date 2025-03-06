IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiUkeharaiIchiran_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiUkeharaiIchiran_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================
-- Author:		<Author,,okayasu.m>
-- Create date: <Create Date,,2015.07.17>
-- Last Update: 2019.04.26 nakamura.r �E�ꖼ�ƃ��C�����𖾍ׂɒǉ�
-- Description:	<Description,,�����ގ󕥈ꗗ> 
-- =================================================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiUkeharaiIchiran_select]
	@kbn_hin	    	  smallint	    -- ���������F�i�敪
	,@cd_bunrui			  varchar(10)	-- ���������F����
	,@dt_hiduke_from	  datetime	    -- ���������F�J�n���t
	,@dt_hiduke_to		  datetime	    -- ���������F�I�����t
	,@cd_genshizai		  varchar(14)	-- ���������F�����ރR�[�h
	,@flg_mishiyobun	  smallint	    -- ���������F���g�p���܂ރt���O
	,@flg_shiyo			  smallint	    -- ���������F���g�p�t���O�F�g�p#0  
	,@flg_zaiko			  smallint	    -- ���������F�v�Z�݌�/���݌ɂ���t���O
	,@flg_today_jisseki	  smallint	    -- ���������F�����͎��т�\���t���O
	,@dt_today			  datetime	    -- ���������F�������t
	,@cd_kg				  varchar(2)	-- �萔�F�P�ʃR�[�h�FKg
	,@cd_li				  varchar(2)	-- �萔�F�P�ʃR�[�h�FLy
	,@flg_yojitsu_yotei   smallint      -- �\���t���O
	,@flg_yojitsu_jisseki smallint      -- �\���t���O
	,@flg_jisseki_kakutei smallint		-- ���ъm��t���O�D�m��
	,@kbn_genryo          smallint      -- �i�敪�i�����j
	,@kbn_shizai          smallint      -- �i�敪�i���ށj
	,@kbn_jikagenryo      smallint      -- �i�敪�i���ƌ����j
	--UNION�̏����敪
	,@NounyuYoteiKbn      smallint      -- �󕥋敪�i�[���\��j
	,@NounyuJissekiKbn    smallint      -- �󕥋敪�i�[�����сj
	,@ShiyoYoteiKbn       smallint      -- �󕥋敪�i�g�p�\��j
	,@ShiyoJissekiKbn     smallint      -- �󕥋敪�i�g�p���сj
	,@ChoseiKbn           smallint      -- �󕥋敪�i�������j
	,@seizoYoteiKbn       smallint		-- �󕥋敪�i�����\��j
	,@seizoJissekiKbn     smallint		-- �󕥋敪�i�������сj
	--JOIN�̏����敪
	,@choseiRiyuKbn       smallint      -- ���R�敪�i�������R)
	,@UkeharaiKbn		  smallint      -- ���������F�󕥋敪
	

AS 
BEGIN

IF @flg_today_jisseki = 1
BEGIN
	SET @dt_today = DATEADD(DAY, 1, @dt_today);
END;

WITH cte AS
(

	SELECT 
		wk_ichiran.cd_hinmei				AS cd_genshizai		-- ���� : �����ރR�[�h
		,wk_ichiran.nm_hinmei_ja			AS nm_genshizai_ja	-- ���� : �����ޖ�_���{��
		,wk_ichiran.nm_hinmei_en			AS nm_genshizai_en	-- ���� : �����ޖ�_�p��
		,wk_ichiran.nm_hinmei_zh			AS nm_genshizai_zh	-- ���� : �����ޖ�_������
		,wk_ichiran.nm_hinmei_vi			AS nm_genshizai_vi
		,wk_ichiran.dt_hiduke				AS dt_hiduke		-- ���� : ���t
		,wk_ichiran.flg_yojitsu				AS flg_yojitsu		-- ���� : �\���t���O
		,wk_ichiran.kbn_ukeharai			AS kbn_ukeharai		-- ���� : �󕥋敪
		,wk_ichiran.su_nyusyukko			AS su_nyusyukko		-- ���� : ���o�ɐ�
		,keisanzaiko.su_zaiko				AS su_keizan_zaiko  -- ���������F�v�Z�݌�/���݌ɂ���t���O
		,wk_ichiran.su_zaiko				AS su_zaiko			-- ���������F�v�Z�݌�/���݌ɂ���t���O
		,wk_ichiran.kbn_hin					AS kbn_hin			-- ���������F�i�敪
		,wk_ichiran.cd_bunrui				AS cd_bunrui		-- ���������F���ރR�[�h
		,wk_ichiran.flg_mishiyo				AS flg_mishiyo		-- ���������F���g�p�t���O
		,wk_ichiran.no_lot					AS no_lot			-- ���� : ���b�g�ԍ�
		,wk_ichiran.cd_seihin				AS cd_seihin		-- ���� : �R�[�h
		,wk_ichiran.nm_seihin_ja			AS nm_seihin_ja		-- ���� : �i��_���{��
		,wk_ichiran.nm_seihin_en			AS nm_seihin_en		-- ���� : �i��_�p��
		,wk_ichiran.nm_seihin_zh			AS nm_seihin_zh		-- ���� : �i��_������
		,wk_ichiran.nm_seihin_vi			AS nm_seihin_vi
		,ma_riyu.nm_riyu					AS nm_memo			-- ���� : ����
		,wk_ichiran.nm_shokuba				AS nm_shokuba		-- ���� : �E��
		,wk_ichiran.nm_line					AS nm_line			-- ���� : ���C��
		,ROW_NUMBER() OVER (ORDER BY wk_ichiran.cd_hinmei, wk_ichiran.dt_hiduke, wk_ichiran.kbn_ukeharai, wk_ichiran.no_lot) AS RN
	
FROM 
	(
		SELECT 
			 nonyu.cd_hinmei			AS cd_hinmei
			 ,nonyu.flg_yojitsu			AS flg_yojitsu
			 ,@NounyuYoteiKbn			AS kbn_ukeharai  ---�[���敪
			 ,hinmei.nm_hinmei_ja		AS nm_hinmei_ja	
			 ,hinmei.nm_hinmei_en		AS nm_hinmei_en	 
			 ,hinmei.nm_hinmei_zh		AS nm_hinmei_zh	
			 ,hinmei.nm_hinmei_vi		AS nm_hinmei_vi
			 ,nonyu.dt_nonyu			AS dt_hiduke 
			 -- �r�W�l�X���[��BIZ00009 
			 -- �����_�ȉ�2���@3���ȍ~�͐؂�̂�
			 ,CASE WHEN COALESCE(mk.cd_tani_nonyu, hinmei.cd_tani_shiyo) = @cd_kg 
						OR COALESCE(mk.cd_tani_nonyu, hinmei.cd_tani_shiyo) = @cd_li
					THEN ROUND(nonyu.su_nonyu * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri) 
						--+ (nonyu.su_nonyu_hasu / 1000 ), 2, 1)
						+ (nonyu.su_nonyu_hasu / 1000 ), 3, 1)
					ELSE ROUND(nonyu.su_nonyu * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri) 
						+ (nonyu.su_nonyu_hasu * COALESCE(mk.wt_nonyu, hinmei.wt_ko)), /*2*/3, 1)
					END su_nyusyukko   -- �[����
			 ,hinmei.kbn_hin			AS kbn_hin
			 ,hinmei.cd_bunrui			AS cd_bunrui
			 ,hinmei.flg_mishiyo		AS flg_mishiyo
			 ,zaiko.su_zaiko			AS su_zaiko
			 ,nonyu.no_nonyu			AS no_lot
			 ,NULL 						AS cd_seihin
			 ,NULL 						AS nm_seihin_ja
			 ,NULL 						AS nm_seihin_en
			 ,NULL 						AS nm_seihin_zh
			 ,NULL 						AS nm_seihin_vi
			 ,NULL						AS nm_shokuba
			 ,NULL						AS nm_line
		 FROM tr_nonyu nonyu
		 LEFT OUTER JOIN ma_hinmei hinmei
		 ON  nonyu.cd_hinmei = hinmei.cd_hinmei
		 LEFT OUTER JOIN
			(SELECT cd_hinmei
					,dt_hizuke
					,SUM(su_zaiko) su_zaiko
			 FROM tr_zaiko
			 GROUP BY cd_hinmei,dt_hizuke) zaiko
		 ON  nonyu.cd_hinmei = zaiko.cd_hinmei
		 AND nonyu.dt_nonyu = zaiko.dt_hizuke		    
		 -- �[���P�ʂ�ϊ�����ׂɍw����}�X�^������
		 LEFT OUTER JOIN (
		 	SELECT mkj.no_juni_yusen, mkj.cd_hinmei, mkj.cd_tani_nonyu, mkj.wt_nonyu, mkj.su_iri
		 	FROM ma_konyu mkj 
		 	WHERE mkj.flg_mishiyo = @flg_shiyo
		 ) mk
		 ON mk.cd_hinmei = nonyu.cd_hinmei
		 AND mk.no_juni_yusen = ( SELECT
									MIN(ko.no_juni_yusen) AS no_juni_yusen
								 FROM ma_konyu ko 
								 WHERE ko.flg_mishiyo = @flg_shiyo
								 AND ko.cd_hinmei = nonyu.cd_hinmei)
								 
		 WHERE flg_yojitsu = @flg_yojitsu_yotei		---�\��
		 AND hinmei.kbn_hin = @kbn_hin
		 AND hinmei.kbn_hin IN (@kbn_genryo, @kbn_shizai)
		 AND (@cd_bunrui IS NULL OR hinmei.cd_bunrui = @cd_bunrui)
		 AND (@cd_genshizai IS NULL OR nonyu.cd_hinmei = @cd_genshizai)
		 --�@�[���\��F�����ȍ~�i�����܂ށj�`���������Fto�܂�
		 AND nonyu.dt_nonyu BETWEEN @dt_hiduke_from AND @dt_hiduke_to
		 AND nonyu.dt_nonyu >= @dt_today ---�p�����[�^
		
		 UNION ALL
		 
		 SELECT 
			 nonyu.cd_hinmei			AS cd_hinmei
			 ,nonyu.flg_yojitsu			AS flg_yojitsu
			 ,@NounyuJissekiKbn			AS kbn_ukeharai  ---�[���敪
			 ,hinmei.nm_hinmei_ja		AS nm_hinmei_ja	
			 ,hinmei.nm_hinmei_en		AS nm_hinmei_en	 
			 ,hinmei.nm_hinmei_zh		AS nm_hinmei_zh	
			 ,hinmei.nm_hinmei_vi		AS nm_hinmei_vi
			 ,nonyu.dt_nonyu			AS dt_hiduke
			 -- �r�W�l�X���[��BIZ00009 
			  -- �����_�ȉ�2���@3���ȍ~�͐؂�̂�
			 ,CASE WHEN COALESCE(mk.cd_tani_nonyu, hinmei.cd_tani_shiyo) = @cd_kg 
						OR COALESCE(mk.cd_tani_nonyu, hinmei.cd_tani_shiyo) = @cd_li
					THEN ROUND(nonyu.su_nonyu * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri) 
						--+ (nonyu.su_nonyu_hasu / 1000 ), 2, 1)
						+ (nonyu.su_nonyu_hasu / 1000 ), 3, 1)
					ELSE ROUND(nonyu.su_nonyu * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri) 
						+ (nonyu.su_nonyu_hasu * COALESCE(mk.wt_nonyu, hinmei.wt_ko)), /*2*/3, 1)
					END su_nyusyukko   -- �[����
			 ,hinmei.kbn_hin			AS kbn_hin
			 ,hinmei.cd_bunrui			AS cd_bunrui
			 ,hinmei.flg_mishiyo		AS flg_mishiyo
			 ,zaiko.su_zaiko			AS su_zaiko
			 ,nonyu.no_nonyu			AS no_lot
			 ,NULL 						AS cd_seihin
			 ,NULL 						AS nm_seihin_ja
			 ,NULL 						AS nm_seihin_en
			 ,NULL 						AS nm_seihin_zh
			 ,NULL 						AS nm_seihin_vi
			 ,NULL						AS nm_shokuba
			 ,NULL						AS nm_line
		 FROM tr_nonyu nonyu
		 LEFT OUTER JOIN ma_hinmei hinmei
		 ON  nonyu.cd_hinmei = hinmei.cd_hinmei
		 LEFT OUTER JOIN 
			(SELECT cd_hinmei
					,dt_hizuke
					,SUM(su_zaiko) su_zaiko
			 FROM tr_zaiko
			 GROUP BY cd_hinmei,dt_hizuke) zaiko
		 ON  nonyu.cd_hinmei = zaiko.cd_hinmei
		 AND nonyu.dt_nonyu = zaiko.dt_hizuke
		  -- �[���P�ʂ�ϊ�����ׂɍw����}�X�^������
		 LEFT OUTER JOIN (
		 	SELECT mkj.no_juni_yusen, mkj.cd_hinmei, mkj.cd_tani_nonyu, mkj.wt_nonyu, mkj.su_iri
		 	FROM ma_konyu mkj 
		 	WHERE mkj.flg_mishiyo = @flg_shiyo
		 ) mk
		 ON mk.cd_hinmei = nonyu.cd_hinmei
		 AND mk.no_juni_yusen = ( SELECT
									MIN(ko.no_juni_yusen) AS no_juni_yusen
								 FROM ma_konyu ko 
								 WHERE ko.flg_mishiyo = @flg_shiyo
								 AND ko.cd_hinmei = nonyu.cd_hinmei)
								 
		 WHERE flg_yojitsu = @flg_yojitsu_jisseki		---����
		 AND hinmei.kbn_hin = @kbn_hin
		 AND hinmei.kbn_hin IN (@kbn_genryo, @kbn_shizai)
		 AND (@cd_bunrui IS NULL OR hinmei.cd_bunrui = @cd_bunrui)
		 AND (@cd_genshizai IS NULL OR nonyu.cd_hinmei = @cd_genshizai)
		 -- �[�����сF���������Ffrom �`�@�O���ȑO�܂�	
		 AND nonyu.dt_nonyu BETWEEN @dt_hiduke_from AND @dt_hiduke_to	 
		 AND nonyu.dt_nonyu < @dt_today ---�p�����[�^
		 
		 UNION ALL

		SELECT
			seihin.cd_hinmei			AS cd_hinmei
			,@flg_yojitsu_yotei			AS flg_yojitsu
			,@seizoYoteiKbn				AS kbn_ukeharai	-- �����\��
			,hinmei.nm_hinmei_ja		AS nm_hinmei_ja
			,hinmei.nm_hinmei_en		AS nm_hinmei_en
			,hinmei.nm_hinmei_zh		AS nm_hinmei_zh
			,hinmei.nm_hinmei_vi		AS nm_hinmei_vi
			,seihin.dt_seizo			AS dt_hiduke
			--,ROUND(seihin.su_seizo_yotei * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri), 2, 1)	AS su_nyusyukko	-- �����\�萔
			,ROUND(seihin.su_seizo_yotei * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri), 3, 1)	AS su_nyusyukko	-- �����\�萔
			,hinmei.kbn_hin				AS kbn_hin
			,hinmei.cd_bunrui			AS cd_bunrui
			,hinmei.flg_mishiyo			AS flg_mishiyo
			,zaiko.su_zaiko				AS su_zaiko
			,seihin.no_lot_seihin		AS no_lot
			,NULL						AS cd_seihin
			,NULL						AS nm_seihin_ja
			,NULL						AS nm_seihin_en
			,NULL						AS nm_seihin_zh
			,NULL						AS nm_seihin_vi
			,NULL						AS nm_shokuba
			,NULL						AS nm_line
		FROM tr_keikaku_seihin seihin
		LEFT OUTER JOIN ma_hinmei hinmei
		ON seihin.cd_hinmei = hinmei.cd_hinmei
		LEFT OUTER JOIN
			(SELECT cd_hinmei
					,dt_hizuke
					,SUM(su_zaiko) su_zaiko
			 FROM tr_zaiko
			 GROUP BY cd_hinmei,dt_hizuke) zaiko
		ON seihin.cd_hinmei = zaiko.cd_hinmei
		AND seihin.dt_seizo = zaiko.dt_hizuke
		-- �[���P�ʂ�ϊ�����ׂɍw����}�X�^������
		LEFT OUTER JOIN
			(
				SELECT mkj.no_juni_yusen, mkj.cd_hinmei, mkj.cd_tani_nonyu, mkj.wt_nonyu, mkj.su_iri
				FROM ma_konyu mkj
				WHERE mkj.flg_mishiyo = @flg_shiyo
			) mk
		ON seihin.cd_hinmei = mk.cd_hinmei
		AND mk.no_juni_yusen = (
									SELECT
										MIN(ko.no_juni_yusen) AS no_juni_yusen
									FROM ma_konyu ko
									WHERE
										ko.flg_mishiyo = @flg_shiyo
										AND ko.cd_hinmei = seihin.cd_hinmei
								)
		WHERE
			hinmei.kbn_hin = @kbn_hin
			AND hinmei.kbn_hin = @kbn_jikagenryo
			AND (@cd_bunrui IS NULL OR hinmei.cd_bunrui = @cd_bunrui)
			AND (@cd_genshizai IS NULL OR seihin.cd_hinmei = @cd_genshizai)
			--�@�����\��F�����ȍ~�i�����܂ށj�`���������Fto�܂�
			AND seihin.dt_seizo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
			AND seihin.dt_seizo >= @dt_today ---�p�����[�^

		UNION ALL

		SELECT
			seihin.cd_hinmei			AS cd_hinmei
			,@flg_yojitsu_jisseki		AS flg_yojitsu
			,@seizoJissekiKbn			AS kbn_ukeharai	-- ��������
			,hinmei.nm_hinmei_ja		AS nm_hinmei_ja
			,hinmei.nm_hinmei_en		AS nm_hinmei_en
			,hinmei.nm_hinmei_zh		AS nm_hinmei_zh
			,hinmei.nm_hinmei_vi		AS nm_hinmei_vi
			,seihin.dt_seizo			AS dt_hiduke
			--,ROUND(seihin.su_seizo_jisseki * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri), 2, 1)	AS su_nyusyukko	-- �������ѐ�
			,ROUND(seihin.su_seizo_jisseki * COALESCE(mk.wt_nonyu, hinmei.wt_ko) * COALESCE(mk.su_iri, hinmei.su_iri), 3, 1)	AS su_nyusyukko	-- �������ѐ�
			,hinmei.kbn_hin				AS kbn_hin
			,hinmei.cd_bunrui			AS cd_bunrui
			,hinmei.flg_mishiyo			AS flg_mishiyo
			,zaiko.su_zaiko				AS su_zaiko
			,seihin.no_lot_seihin		AS no_lot
			,NULL						AS cd_seihin
			,NULL						AS nm_seihin_ja
			,NULL						AS nm_seihin_en
			,NULL						AS nm_seihin_zh
			,NULL						AS nm_seihin_vi
			,NULL						AS nm_shokuba
			,NULL						AS nm_line
		FROM tr_keikaku_seihin seihin
		LEFT OUTER JOIN ma_hinmei hinmei
		ON seihin.cd_hinmei = hinmei.cd_hinmei
		LEFT OUTER JOIN 
			(SELECT cd_hinmei
					,dt_hizuke
					,SUM(su_zaiko) su_zaiko
			 FROM tr_zaiko
			 GROUP BY cd_hinmei,dt_hizuke) zaiko
		ON seihin.cd_hinmei = zaiko.cd_hinmei
		AND seihin.dt_seizo = zaiko.dt_hizuke
		-- �[���P�ʂ�ϊ�����ׂɍw����}�X�^������
		LEFT OUTER JOIN
			(
				SELECT mkj.no_juni_yusen, mkj.cd_hinmei, mkj.cd_tani_nonyu, mkj.wt_nonyu, mkj.su_iri
				FROM ma_konyu mkj
				WHERE mkj.flg_mishiyo = @flg_shiyo
			) mk
		ON seihin.cd_hinmei = mk.cd_hinmei
		AND mk.no_juni_yusen = (
									SELECT
										MIN(ko.no_juni_yusen) AS no_juni_yusen
									FROM ma_konyu ko
									WHERE
										ko.flg_mishiyo = @flg_shiyo
										AND ko.cd_hinmei = seihin.cd_hinmei
								)
		WHERE
			hinmei.kbn_hin = @kbn_hin
			AND hinmei.kbn_hin = @kbn_jikagenryo
			AND (@cd_bunrui IS NULL OR hinmei.cd_bunrui = @cd_bunrui)
			AND (@cd_genshizai IS NULL OR seihin.cd_hinmei = @cd_genshizai)
			AND seihin.flg_jisseki = @flg_jisseki_kakutei
			--�@�����\��F�����ȍ~�i�����܂ށj�`���������Fto�܂�
			AND seihin.dt_seizo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
			AND seihin.dt_seizo < @dt_today ---�p�����[�^
					

		 UNION ALL
		 
		  SELECT 
			 shiyo.cd_hinmei			AS cd_hinmei
			 ,shiyo.flg_yojitsu			AS flg_yojitsu
			 ,@ShiyoYoteiKbn			AS kbn_ukeharai  ---�g�p�敪
			 ,hinmei.nm_hinmei_ja		AS nm_hinmei_ja	
			 ,hinmei.nm_hinmei_en		AS nm_hinmei_en	 
			 ,hinmei.nm_hinmei_zh		AS nm_hinmei_zh	
			 ,hinmei.nm_hinmei_vi		AS nm_hinmei_vi
			 ,shiyo.dt_shiyo 			AS dt_hiduke
			 --,CEILING(shiyo.su_shiyo * 100) / 100 	AS su_nyusyukko  
			 ,CEILING(shiyo.su_shiyo * 1000) / 1000 	AS su_nyusyukko  
			 ,hinmei.kbn_hin			AS kbn_hin
			 ,hinmei.cd_bunrui			AS cd_bunrui
			 ,hinmei.flg_mishiyo		AS flg_mishiyo
			 ,zaiko.su_zaiko			AS su_zaiko
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN shiyo.no_lot_shikakari
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN shiyo.no_lot_seihin
			 END no_lot
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN shikakari.cd_shikakari_hin
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN seihin.cd_hinmei
			 END cd_seihin
			 
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_ja
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_ja
			 END nm_seihin_ja
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_en
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_en
			 END nm_seihin_en
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_zh
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_zh
			 END nm_seihin_zh
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_vi
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_vi
			 END nm_seihin_vi
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN shokuba_shikakari.nm_shokuba
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN shokuba_seihin.nm_shokuba
			 END nm_shokuba
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN line_shikakari.nm_line
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN line_seihin.nm_line
			 END nm_line
		 FROM tr_shiyo_yojitsu shiyo
		 LEFT OUTER JOIN ma_hinmei hinmei
		 ON  shiyo.cd_hinmei = hinmei.cd_hinmei
		 LEFT OUTER JOIN 
			(SELECT cd_hinmei
					,dt_hizuke
					,SUM(su_zaiko) su_zaiko
			 FROM tr_zaiko
			 GROUP BY cd_hinmei,dt_hizuke) zaiko
		 ON  shiyo.cd_hinmei = zaiko.cd_hinmei
		 AND shiyo.dt_shiyo = zaiko.dt_hizuke
		 LEFT OUTER JOIN su_keikaku_shikakari shikakari 
		 ON shiyo.no_lot_shikakari = shikakari.no_lot_shikakari
		 LEFT OUTER JOIN ma_haigo_mei haigomei
		 ON shikakari.cd_shikakari_hin = haigomei.cd_haigo
		 -- �z�����V�s���L���Ȃ��̖̂��O���P���邽�߂Ɋ֐����g�p����
		 AND haigomei.no_han = (SELECT TOP 1 no_han
				 FROM udf_HaigoRecipeYukoHan(shikakari.cd_shikakari_hin, @flg_shiyo, shikakari.dt_seizo)
				 )
		 LEFT OUTER JOIN tr_keikaku_seihin seihin
		 on shiyo.no_lot_seihin = seihin.no_lot_seihin
		 LEFT OUTER JOIN ma_hinmei hin_seihin
		 ON hin_seihin.cd_hinmei = seihin.cd_hinmei
		 LEFT OUTER JOIN ma_shokuba shokuba_seihin
		 ON seihin.cd_shokuba = shokuba_seihin.cd_shokuba
		 LEFT OUTER JOIN ma_line line_seihin
		 ON seihin.cd_shokuba = line_seihin.cd_shokuba
		 AND seihin.cd_line = line_seihin.cd_line
		 LEFT OUTER JOIN ma_shokuba shokuba_shikakari
		 ON shikakari.cd_shokuba = shokuba_shikakari.cd_shokuba
		 LEFT OUTER JOIN ma_line line_shikakari
		 ON shikakari.cd_shokuba = line_shikakari.cd_shokuba
		 AND shikakari.cd_line = line_shikakari.cd_line
		 WHERE flg_yojitsu = @flg_yojitsu_yotei ---�\��
		 AND hinmei.kbn_hin = @kbn_hin
		 AND (@cd_bunrui IS NULL OR hinmei.cd_bunrui = @cd_bunrui)
		 AND (@cd_genshizai IS NULL OR shiyo.cd_hinmei= @cd_genshizai)
		  --�@�g�p�\��F�����ȍ~�i�����܂ށj�`���������Fto�܂�
		 AND shiyo.dt_shiyo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
		 AND shiyo.dt_shiyo >= @dt_today ---�p�����[�^
		
		 UNION ALL
		 
		  SELECT 
			 shiyo.cd_hinmei			AS cd_hinmei
			 ,shiyo.flg_yojitsu			AS flg_yojitsu
			 ,@ShiyoJissekiKbn			AS kbn_ukeharai  ---�g�p�敪
			 ,hinmei.nm_hinmei_ja		AS nm_hinmei_ja	
			 ,hinmei.nm_hinmei_en		AS nm_hinmei_en	 
			 ,hinmei.nm_hinmei_zh		AS nm_hinmei_zh	
			 ,hinmei.nm_hinmei_vi		AS nm_hinmei_vi
			 ,shiyo.dt_shiyo 			AS dt_hiduke
			 --,CEILING(shiyo.su_shiyo * 100) / 100 	AS su_nyusyukko  
			 ,CEILING(shiyo.su_shiyo * 1000) / 1000 	AS su_nyusyukko  
			 ,hinmei.kbn_hin			AS kbn_hin
			 ,hinmei.cd_bunrui			AS cd_bunrui
			 ,hinmei.flg_mishiyo		AS flg_mishiyo
			 ,zaiko.su_zaiko			AS su_zaiko
			,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN shiyo.no_lot_shikakari
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN shiyo.no_lot_seihin
			 END no_lot
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN shikakari.cd_shikakari_hin
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN seihin.cd_hinmei
			 END cd_seihin
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_ja
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_ja
			 END nm_seihin_ja
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_en
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_en
			 END nm_seihin_en
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_zh
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_zh
			 END nm_seihin_zh
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN haigomei.nm_haigo_vi
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN hin_seihin.nm_hinmei_vi
			 END nm_seihin_vi
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN shokuba_shikakari.nm_shokuba
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN shokuba_seihin.nm_shokuba
			 END nm_shokuba
			 ,CASE 
			 WHEN hinmei.kbn_hin IN (@kbn_genryo, @kbn_jikagenryo) THEN line_shikakari.nm_line
			 WHEN hinmei.kbn_hin = @kbn_shizai THEN line_seihin.nm_line
			 END nm_line
		 FROM tr_shiyo_yojitsu shiyo
		 LEFT OUTER JOIN ma_hinmei hinmei
		 ON  shiyo.cd_hinmei = hinmei.cd_hinmei
		 LEFT OUTER JOIN 
			(SELECT cd_hinmei
					,dt_hizuke
					,SUM(su_zaiko) su_zaiko
			 FROM tr_zaiko
			 GROUP BY cd_hinmei,dt_hizuke) zaiko
		 ON  shiyo.cd_hinmei = zaiko.cd_hinmei
		 AND shiyo.dt_shiyo = zaiko.dt_hizuke
		 LEFT OUTER JOIN su_keikaku_shikakari shikakari 
		 on shiyo.no_lot_shikakari = shikakari.no_lot_shikakari
		 LEFT OUTER JOIN ma_haigo_mei haigomei 
		 on shikakari.cd_shikakari_hin = haigomei.cd_haigo
		  -- �z�����V�s���L���Ȃ��̖̂��O���P���邽�߂Ɋ֐����g�p����
		 AND haigomei.no_han = (SELECT TOP 1 no_han
				 FROM udf_HaigoRecipeYukoHan(shikakari.cd_shikakari_hin, @flg_shiyo, shikakari.dt_seizo)
				 )
		 LEFT OUTER JOIN tr_keikaku_seihin seihin 
		 on shiyo.no_lot_seihin = seihin.no_lot_seihin
		 LEFT OUTER JOIN ma_hinmei hin_seihin
		 on hin_seihin.cd_hinmei = seihin.cd_hinmei
		 LEFT OUTER JOIN ma_shokuba shokuba_seihin
		 ON seihin.cd_shokuba = shokuba_seihin.cd_shokuba
		 LEFT OUTER JOIN ma_line line_seihin
		 ON seihin.cd_shokuba = line_seihin.cd_shokuba
		 AND seihin.cd_line = line_seihin.cd_line
		 LEFT OUTER JOIN ma_shokuba shokuba_shikakari
		 ON shikakari.cd_shokuba = shokuba_shikakari.cd_shokuba
		 LEFT OUTER JOIN ma_line line_shikakari
		 ON shikakari.cd_shokuba = line_shikakari.cd_shokuba
		 AND shikakari.cd_line = line_shikakari.cd_line
		 WHERE flg_yojitsu = @flg_yojitsu_jisseki ---����
		 AND hinmei.kbn_hin = @kbn_hin
		 AND (@cd_bunrui IS NULL OR hinmei.cd_bunrui = @cd_bunrui)
		 AND (@cd_genshizai IS NULL OR shiyo.cd_hinmei= @cd_genshizai)
		 -- �g�p���сF���������Ffrom �`�@�O���ȑO�܂�
		 AND shiyo.dt_shiyo BETWEEN @dt_hiduke_from AND @dt_hiduke_to
		 AND shiyo.dt_shiyo < @dt_today ---�p�����[�^
		 
		 UNION ALL
		 
		 SELECT 
			  chosei.cd_hinmei			AS cd_hinmei
			 ,NULL						AS flg_yojitsu
			 ,@ChoseiKbn				AS kbn_ukeharai  ---�����敪
			 ,hinmei.nm_hinmei_ja		AS nm_hinmei_ja	
			 ,hinmei.nm_hinmei_en		AS nm_hinmei_en	 
			 ,hinmei.nm_hinmei_zh		AS nm_hinmei_zh	
			 ,hinmei.nm_hinmei_vi		AS nm_hinmei_vi
			 ,chosei.dt_hizuke			AS dt_hiduke
			 --,CEILING(su_chosei * 100) / 100	AS su_nyusyukko  
			 ,CEILING(su_chosei * 1000) / 1000	AS su_nyusyukko  
			 ,hinmei.kbn_hin			AS kbn_hin
			 ,hinmei.cd_bunrui			AS cd_bunrui
			 ,hinmei.flg_mishiyo		AS flg_mishiyo
			 ,zaiko.su_zaiko			AS su_zaiko
			 ,chosei.no_seq				AS no_lot
			 ,chosei.cd_seihin			AS cd_seihin
			 ,hin_seihin.nm_hinmei_ja	AS nm_seihin_ja 
			 ,hin_seihin.nm_hinmei_en	AS nm_seihin_en 
			 ,hin_seihin.nm_hinmei_zh	AS nm_seihin_zh 
			 ,hin_seihin.nm_hinmei_vi	AS nm_seihin_vi
			 ,NULL						AS nm_shokuba
			 ,NULL						AS nm_line
		 FROM tr_chosei chosei
		 LEFT OUTER JOIN ma_hinmei hinmei
		 ON  chosei.cd_hinmei = hinmei.cd_hinmei
		 LEFT OUTER JOIN 
			(SELECT cd_hinmei
					,dt_hizuke
					,SUM(su_zaiko) su_zaiko
			 FROM tr_zaiko
			 GROUP BY cd_hinmei,dt_hizuke) zaiko
		 ON  chosei.cd_hinmei = zaiko.cd_hinmei
		 AND chosei.dt_hizuke = zaiko.dt_hizuke
		 LEFT OUTER JOIN ma_hinmei hin_seihin
		 --ON  chosei.cd_hinmei = hin_seihin.cd_hinmei
		 ON  chosei.cd_seihin = hin_seihin.cd_hinmei
		 WHERE 
		 hinmei.kbn_hin = @kbn_hin
		 AND (@cd_bunrui IS NULL OR hinmei.cd_bunrui = @cd_bunrui)
		 AND (@cd_genshizai IS NULL OR chosei.cd_hinmei= @cd_genshizai)
		  -- �������F���������Ffrom �`�@���������Fto�܂�
		AND chosei.dt_hizuke BETWEEN @dt_hiduke_from AND @dt_hiduke_to
		
	) wk_ichiran

---�������̏ꍇ�ɂ́A�����g�����̗��R�R�[�h���o�͂���---
LEFT OUTER JOIN tr_chosei chosei_riyu
ON wk_ichiran.no_lot = chosei_riyu.no_seq

LEFT OUTER JOIN ma_riyu
ON chosei_riyu.cd_riyu = ma_riyu.cd_riyu
AND ma_riyu.kbn_bunrui_riyu = @choseiRiyuKbn

---���������̌v�Z�݌ɂ��m�F����ׂɍ݌ɐ����擾����---
LEFT OUTER JOIN 
(
	SELECT 
		cd_hinmei,
		su_zaiko,
		dt_hizuke
	FROM tr_zaiko_keisan
	WHERE dt_hizuke BETWEEN @dt_hiduke_from AND @dt_hiduke_to
) keisanzaiko
ON keisanzaiko.cd_hinmei = wk_ichiran.cd_hinmei
AND keisanzaiko.dt_hizuke = wk_ichiran.dt_hiduke

---��������---
WHERE 
	-- ���g�p���܂ނɃ`�F�b�N���Ȃ��ꍇ:�g�p�̂ݒ��o
	(@flg_mishiyobun = 1 OR  --ture�ɂȂ������_�Ŏ������ɐi�܂Ȃ�
				 (wk_ichiran.flg_mishiyo = @flg_shiyo))  ---�t���O�g�p
	--�v�Z�݌�/���݌ɂ���݂̂Ƀ`�F�b�N���L��ꍇ
	AND (@flg_zaiko = 0 OR  --ture�ɂȂ������_�Ŏ������ɐi�܂Ȃ�
				 (wk_ichiran.su_zaiko IS NOT NULL OR keisanzaiko.su_zaiko IS NOT NULL))
	AND (@UkeharaiKbn IS NULL OR wk_ichiran.kbn_ukeharai = @UkeharaiKbn) 
)

	SELECT
		cnt
        ,cte_row.cd_genshizai	
		,cte_row.nm_genshizai_ja
		,cte_row.nm_genshizai_en
		,cte_row.nm_genshizai_zh
		,cte_row.nm_genshizai_vi
		,cte_row.dt_hiduke
		,cte_row.flg_yojitsu		
		,cte_row.kbn_ukeharai		
		,cte_row.su_nyusyukko		
		,cte_row.su_keizan_zaiko  
		,cte_row.su_zaiko			
		,cte_row.kbn_hin			
		,cte_row.cd_bunrui		
		,cte_row.flg_mishiyo		
		,cte_row.no_lot			
		,cte_row.cd_seihin		
		,cte_row.nm_seihin_ja		
		,cte_row.nm_seihin_en		
		,cte_row.nm_seihin_zh
		,cte_row.nm_seihin_vi
		,cte_row.nm_memo
		,cte_row.nm_shokuba
		,cte_row.nm_line		
	FROM
		(
			SELECT 
				MAX(RN) OVER() cnt
				,*
			FROM cte
		) cte_row	
	
	ORDER BY cte_row.cd_genshizai, cte_row.dt_hiduke, cte_row.kbn_ukeharai, cte_row.no_lot,cte_row.nm_shokuba,cte_row.nm_line
END







GO
