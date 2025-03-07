IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_GenshizaiKonyuDialog_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_GenshizaiKonyuDialog_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================
-- Author:		higashiya.s
-- Create date: 2013.08.05
-- Last Update: 2016.12.13 motojima.m
-- Description:	原資材購入先マスタセレクタ：データ抽出処理
-- =======================================================
CREATE PROCEDURE [dbo].[usp_GenshizaiKonyuDialog_select]
	 @cd_hinmei varchar(14)
	,@flg_mishiyo smallint
	--,@con_torihiki varchar(100)
	,@con_torihiki nvarchar(100)

AS
BEGIN

-- ==============
-- データ抽出処理
-- ==============
SELECT
	 ma_konyu.cd_hinmei     AS cd_hinmei
	,ma_konyu.no_juni_yusen AS juni_yusen
	,ma_konyu.cd_torihiki   AS cd_torihiki_butsu
	,TORIHIKI_1.nm_torihiki AS nm_torihiki_butsu
	,ma_konyu.cd_torihiki2  AS cd_torihiki_sho
	,TORIHIKI_2.nm_torihiki AS nm_torihiki_sho
FROM
	ma_konyu
	LEFT OUTER JOIN
		ma_torihiki TORIHIKI_1
	ON
		ma_konyu.cd_torihiki = TORIHIKI_1.cd_torihiki
	AND TORIHIKI_1.flg_mishiyo = @flg_mishiyo
	LEFT OUTER JOIN
		ma_torihiki TORIHIKI_2
	ON
		ma_konyu.cd_torihiki2 = TORIHIKI_2.cd_torihiki
	AND TORIHIKI_2.flg_mishiyo = @flg_mishiyo
WHERE
	ma_konyu.cd_hinmei = @cd_hinmei
AND ma_konyu.flg_mishiyo = @flg_mishiyo

-- 検索条件/取引先名に入力があった場合、
-- 物流と商流どちらかの取引先コードまたは取引先名をあいまい検索する
AND ( LEN(@con_torihiki) = 0
	OR ma_konyu.cd_torihiki LIKE '%' + @con_torihiki + '%'
	OR ma_konyu.cd_torihiki2 LIKE '%' + @con_torihiki + '%'
	OR TORIHIKI_1.nm_torihiki LIKE '%' + @con_torihiki + '%'
	OR TORIHIKI_2.nm_torihiki LIKE '%' + @con_torihiki + '%' )

ORDER BY
	ma_konyu.no_juni_yusen

END
GO
