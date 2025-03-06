IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_NonyuIraishoList_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_NonyuIraishoList_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===============================================
-- Author:		tsujita.s
-- Create date: 2013.09.11
-- Last Update: 2015.02.19
-- Description:	�[���˗������X�g
--    �f�[�^���o����
-- ===============================================
CREATE PROCEDURE [dbo].[usp_NonyuIraishoList_select]
	@hizuke_from			datetime		-- ���t�F�n�_
	,@hizuke_to				datetime		-- ���t�F�I�_
	,@today					datetime		-- UTC���Ԃŕϊ��ς݃V�X�e�����t
	,@flg_yotei				smallint		-- �萔�F�\���t���O�F�\��
	,@flg_jisseki			smallint		-- �萔�F�\���t���O�F����
	,@flg_mishiyo			smallint		-- �萔�F���g�p�t���O�F�g�p
	,@con_torihiki			varchar(13)		-- ���������F�����R�[�h
	,@param_hin				varchar(1000)	-- ���������F�I�����ꂽ�i���R�[�h
	,@tani_kg				varchar(2)		-- �萔�F�P�ʁFKg
	,@tani_li				varchar(2)		-- �萔�F�P�ʁFL
AS
BEGIN

	SET NOCOUNT ON

	-- =================================
	--  �I�����ꂽ�i���R�[�h������ꍇ
	-- =================================
	IF @param_hin <> ''
	BEGIN
		SELECT
		 tr.flg_yojitsu AS flg_yojitsu
		 ,tr.no_nonyu AS no_nonyu
		 ,tr.cd_hinmei AS cd_hinmei
		 ,ma_hin.nm_hinmei_ja AS nm_hinmei_ja
		 ,ma_hin.nm_hinmei_en AS nm_hinmei_en
		 ,ma_hin.nm_hinmei_zh AS nm_hinmei_zh
		 ,ma_hin.nm_hinmei_vi AS nm_hinmei_vi
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,ma_tan.nm_tani AS nm_tani
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,tr.dt_nonyu AS dt_nonyu

		 --,COALESCE(floor(tr.su_nonyu), 0) AS su_nonyu
		 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
		 ,dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,tr.su_nonyu AS su_nonyu_db
		 ,tr.su_nonyu_hasu AS su_nonyu_hasu
		 ,tr.cd_torihiki AS cd_torihiki
		 ,tr.cd_torihiki2 AS cd_torihiki2
		 ,tr.tan_nonyu AS tan_nonyu
		 ,tr.kin_kingaku AS kin_kingaku
		 ,tr.no_nonyusho AS no_nonyusho
		 ,tr.kbn_zei AS kbn_zei
		 ,tr.kbn_denso AS kbn_denso
		 ,tr.flg_kakutei AS flg_kakutei
		 ,tr.dt_seizo AS dt_seizo
		 -- �d��
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0) * COALESCE(floor(tr.su_nonyu), 0) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM
			tr_nonyu tr

		-- �i���}�X�^
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = tr.cd_hinmei

		-- �����ލw����}�X�^
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = tr.cd_hinmei
		AND ma_ko.cd_torihiki = tr.cd_torihiki
		--AND ma_ko.flg_mishiyo = @flg_mishiyo

		-- �P�ʃ}�X�^
		LEFT JOIN ma_tani ma_tan
		ON ma_tan.cd_tani = ma_ko.cd_tani_nonyu

		-- ���ރ}�X�^
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			tr.dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
		AND (
			(tr.dt_nonyu < @today AND tr.flg_yojitsu = @flg_jisseki)
			OR
			(tr.dt_nonyu >= @today AND tr.flg_yojitsu = @flg_yotei)
		)
		AND tr.cd_torihiki = @con_torihiki
		AND tr.cd_hinmei
			IN (SELECT id FROM udf_SplitCommaValue(@param_hin))
		--AND tr.su_nonyu > 0
		ORDER BY
			tr.cd_hinmei, tr.dt_nonyu
	END

	-- =================================
	--  �I�����ꂽ�i���R�[�h���Ȃ��ꍇ
	-- =================================
	ELSE BEGIN
		SELECT
		 tr.flg_yojitsu AS flg_yojitsu
		 ,tr.no_nonyu AS no_nonyu
		 ,tr.cd_hinmei AS cd_hinmei
		 ,ma_hin.nm_hinmei_ja AS nm_hinmei_ja
		 ,ma_hin.nm_hinmei_en AS nm_hinmei_en
		 ,ma_hin.nm_hinmei_zh AS nm_hinmei_zh
		 ,ma_hin.nm_hinmei_vi AS nm_hinmei_vi
		 ,ma_ko.nm_nisugata_hyoji AS nm_nisugata_hyoji
		 ,ma_tan.nm_tani AS nm_tani
		 ,ma_bun.nm_bunrui AS nm_bunrui
		 ,tr.dt_nonyu AS dt_nonyu

		 --,COALESCE(floor(tr.su_nonyu), 0) AS su_nonyu
		 -- �[���P�ʂ�Kg�܂���L�̏ꍇ�́A�[���𐳋K���ɉ��Z����
		 ,dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
			tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS su_nonyu

		 ,tr.su_nonyu AS su_nonyu_db
		 ,tr.su_nonyu_hasu AS su_nonyu_hasu
		 ,tr.cd_torihiki AS cd_torihiki
		 ,tr.cd_torihiki2 AS cd_torihiki2
		 ,tr.tan_nonyu AS tan_nonyu
		 ,tr.kin_kingaku AS kin_kingaku
		 ,tr.no_nonyusho AS no_nonyusho
		 ,tr.kbn_zei AS kbn_zei
		 ,tr.kbn_denso AS kbn_denso
		 ,tr.flg_kakutei AS flg_kakutei
		 ,tr.dt_seizo AS dt_seizo
		 -- �d��
		 --,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0) * COALESCE(floor(tr.su_nonyu), 0) AS juryo
		 ,COALESCE(ma_ko.wt_nonyu, 0) * COALESCE(ma_ko.su_iri, 0)
			* dbo.udf_NonyuHasuKanzan(ma_ko.cd_tani_nonyu, ma_hin.cd_tani_nonyu,
					tr.su_nonyu, tr.su_nonyu_hasu, @tani_kg, @tani_li) AS juryo
		FROM
			tr_nonyu tr

		-- �i���}�X�^
		LEFT JOIN ma_hinmei ma_hin
		ON ma_hin.cd_hinmei = tr.cd_hinmei

		-- �����ލw����}�X�^
		LEFT JOIN ma_konyu ma_ko
		ON ma_ko.cd_hinmei = tr.cd_hinmei
		AND ma_ko.cd_torihiki = tr.cd_torihiki
		--AND ma_ko.flg_mishiyo = @flg_mishiyo

		-- �P�ʃ}�X�^
		LEFT JOIN ma_tani ma_tan
		ON ma_tan.cd_tani = ma_ko.cd_tani_nonyu

		-- ���ރ}�X�^
		LEFT JOIN ma_bunrui ma_bun
		ON ma_bun.cd_bunrui = ma_hin.cd_bunrui
		AND ma_bun.kbn_hin = ma_hin.kbn_hin

		WHERE
			tr.dt_nonyu BETWEEN @hizuke_from AND @hizuke_to
		AND (
			(tr.dt_nonyu < @today AND tr.flg_yojitsu = @flg_jisseki)
			OR
			(tr.dt_nonyu >= @today AND tr.flg_yojitsu = @flg_yotei)
		)
		AND tr.cd_torihiki = @con_torihiki
		--AND tr.su_nonyu > 0
		ORDER BY
			tr.cd_hinmei, tr.dt_nonyu
	END


END
GO
