IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_HaigoRecipeYukoHan') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_HaigoRecipeYukoHan]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：配合レシピの有効版を取得する
ファイル名 ：udf_HaigoRecipeYukoHan
入力引数 ：@cd_haigo, @flg_mishiyo, @dt_from
出力引数 ：-
戻り値  ：@table_no_han_yuko
作成日  ：2013.11.07 kasahara.a
更新日  ：2016.12.13 motojima.m 中文対応
        ：2018.01.30 motojima.m ベトナム対応
*****************************************************/

CREATE FUNCTION [dbo].[udf_HaigoRecipeYukoHan]
	(
    @cd_haigo varchar(14) -- 配合コード
    ,@flg_mishiyo smallint -- 未使用フラグ
    ,@dt_from datetime -- 仕込日
	)
-- 戻りテーブル
RETURNS @table_no_han_yuko TABLE
    (
    cd_haigo varchar(14)
    ,no_han decimal(4, 0)
    ,dt_from datetime
    ,nm_haigo_ja nvarchar(50)
    --,nm_haigo_en varchar(50)
    ,nm_haigo_en nvarchar(50)
    ,nm_haigo_zh nvarchar(50)
	,nm_haigo_vi nvarchar(50)
	--,nm_haigo_ryaku varchar(50) NULL
	,nm_haigo_ryaku nvarchar(50) NULL
	,ritsu_budomari_mei decimal(5, 2) NULL
	,wt_kihon decimal(4, 0) NOT NULL
	,ritsu_kihon decimal(5, 2) NULL
	,flg_gassan_shikomi smallint NOT NULL
	,wt_saidai_shikomi decimal(12, 6) NULL
	,wt_haigo_gokei decimal(12, 6) NULL
	--,biko varchar(200) NULL
	,biko nvarchar(200) NULL
	,no_seiho varchar(20) NULL
	,cd_tanto_seizo varchar(10) NULL
	,dt_seizo_koshin datetime NULL
	,cd_tanto_hinkan varchar(10) NULL
	,dt_hinkan_koshin datetime NULL
	,kbn_kanzan varchar(10) NOT NULL
	,ritsu_hiju_mei decimal(6, 4) NULL
	,flg_shorihin smallint NOT NULL
	,flg_tanto_hinkan smallint NOT NULL
	,flg_tanto_seizo smallint NOT NULL
	,kbn_shiagari smallint NOT NULL
	,cd_bunrui varchar(10) NULL
	,flg_tenkai smallint NULL
	,flg_mishiyo smallint NULL
	,no_kotei decimal(4, 0)
	,no_tonyu decimal(4, 0)
	,kbn_hin smallint
	,cd_hinmei varchar(14)
	--,nm_hinmei varchar(50)
	,nm_hinmei nvarchar(50)
	,cd_mark varchar(2)
	,wt_shikomi decimal(12, 6)
	,wt_nisugata decimal(12, 6)
	,su_nisugata decimal(4, 0)
	,wt_kowake decimal(12, 6)
	,su_kowake decimal(4, 0)
	,cd_futai varchar(10)
	,ritsu_hiju_recipe decimal(6, 4)
	,ritsu_budomari_recipe decimal(5, 2)
	,su_settei decimal(8, 3)
	,su_settei_max decimal(8, 3)
	,su_settei_min decimal(8, 3)
	,wt_haigo decimal(12, 6)
    ,nm_hinmei_ja nvarchar(50)
    --,nm_hinmei_en varchar(50)
    ,nm_hinmei_en nvarchar(50)
    ,nm_hinmei_zh nvarchar(50)
	,nm_hinmei_vi nvarchar(50)
    --,nm_hinmei_ryaku varchar(50)
    ,nm_hinmei_ryaku nvarchar(50)
	,flg_kowake_systemgai smallint
    )
AS
	BEGIN
        -- 戻りテーブルへ有効版データを追加
		INSERT INTO @table_no_han_yuko
        SELECT
            yuko.cd_haigo
            ,yuko.no_han
            ,yuko.dt_from
            ,hai.nm_haigo_ja
			,hai.nm_haigo_en
			,hai.nm_haigo_zh
			,hai.nm_haigo_vi
			,hai.nm_haigo_ryaku
			,hai.ritsu_budomari AS ritsu_budomari_mei
			,hai.wt_kihon
			,hai.ritsu_kihon
			,hai.flg_gassan_shikomi
			,hai.wt_saidai_shikomi
			,hai.wt_haigo_gokei
			,hai.biko
			,hai.no_seiho
			,hai.cd_tanto_seizo
			,hai.dt_seizo_koshin
			,hai.cd_tanto_hinkan
			,hai.dt_hinkan_koshin
			,hai.kbn_kanzan
			,hai.ritsu_hiju AS ritsu_hiju_mei
			,hai.flg_shorihin
			,hai.flg_tanto_hinkan
			,hai.flg_tanto_seizo
			,hai.kbn_shiagari
			,hai.cd_bunrui
			,hai.flg_tenkai
            ,hai.flg_mishiyo
            ,re.no_kotei
            ,re.no_tonyu
            ,re.kbn_hin
            ,re.cd_hinmei
            ,re.nm_hinmei
            ,re.cd_mark
            ,re.wt_shikomi
            ,re.wt_nisugata
            ,re.su_nisugata
            ,re.wt_kowake
            ,re.su_kowake
            ,re.cd_futai
            ,re.ritsu_hiju AS ritsu_hiju_recipe
            ,re.ritsu_budomari AS ritsu_budomari_recipe
            ,re.su_settei
            ,re.su_settei_max
            ,re.su_settei_min
            ,re.wt_haigo
            ,hin.nm_hinmei_ja
            ,hin.nm_hinmei_en
            ,hin.nm_hinmei_zh
			,hin.nm_hinmei_vi
            ,nm_hinmei_ryaku
			,re.flg_kowake_systemgai
            
        FROM
        -- 配合毎の最大の有効日付を取得する
        (
            select
                yuko.cd_haigo
                ,yuko.dt_from
                ,MAX(hai.no_han) AS no_han
            from
            (
                SELECT
                    cd_haigo
                    ,MAX(dt_from) AS dt_from
                FROM dbo.ma_haigo_mei
                WHERE
                    cd_haigo = CASE WHEN @cd_haigo IS NULL OR @cd_haigo = '' THEN ''
                                    ELSE @cd_haigo END
                    AND flg_mishiyo = @flg_mishiyo
                    AND dt_from <= CASE WHEN @dt_from IS NULL OR @dt_from = '' THEN ''
                                        ELSE @dt_from END
                GROUP BY cd_haigo
            ) yuko
            LEFT OUTER JOIN dbo.ma_haigo_mei hai
            ON yuko.cd_haigo = hai.cd_haigo
            AND yuko.dt_from = hai.dt_from
            GROUP BY yuko.cd_haigo, yuko.dt_from
            union
            select
                yuko.cd_haigo
                ,yuko.dt_from
                ,hai.no_han
            from
            (
                -- 配合コード、有効日付が指定されない時の取得データ
                SELECT
                    cd_haigo
                    ,dt_from
                FROM dbo.ma_haigo_mei
                WHERE
                    cd_haigo = CASE WHEN @cd_haigo IS NULL OR @cd_haigo = '' THEN cd_haigo
                                    ELSE '' END
                    AND flg_mishiyo = CASE WHEN @flg_mishiyo IS NULL THEN flg_mishiyo
                                    ELSE '' END
                    AND dt_from <= CASE WHEN @dt_from IS NULL OR @dt_from = '' THEN dt_from
                                        ELSE '' END
            ) yuko
            LEFT OUTER JOIN dbo.ma_haigo_mei hai
            ON yuko.cd_haigo = hai.cd_haigo
            AND yuko.dt_from = hai.dt_from
        ) yuko
        LEFT OUTER JOIN dbo.ma_haigo_mei hai
        ON yuko.cd_haigo = hai.cd_haigo
        AND yuko.no_han = hai.no_han
        LEFT OUTER JOIN dbo.ma_haigo_recipe re
        ON yuko.cd_haigo = re.cd_haigo
        AND yuko.no_han = re.no_han
		LEFT OUTER JOIN 
		(
			SELECT
				mh.cd_hinmei
				,mh.nm_hinmei_ja
				,mh.nm_hinmei_en
				,mh.nm_hinmei_zh
				,mh.nm_hinmei_vi
				,mh.nm_hinmei_ryaku
				,mh.flg_mishiyo
			FROM ma_hinmei mh
		) hin
		ON re.cd_hinmei = hin.cd_hinmei
        order by cd_haigo
	RETURN
	END



GO
