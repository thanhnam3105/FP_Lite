IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_ShizaiShiyoYukoHan') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_ShizaiShiyoYukoHan]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：資材使用マスタの有効版を取得する
ファイル名 ：udf_ShizaiShiyoYukoHan
入力引数 ：@cd_hinmei, @flg_mishiyo, @dt_hizuke
出力引数 ：-
戻り値  ：@table_no_han_yuko
作成日  ：2013.11.07 kasahara.a
更新日  ：
*****************************************************/
CREATE FUNCTION [dbo].[udf_ShizaiShiyoYukoHan]
	(
    @cd_hinmei varchar(14) -- 品名コード
    ,@flg_mishiyo smallint -- 未使用フラグ
    ,@dt_hizuke datetime -- 仕込日
	)
-- 戻りテーブル
RETURNS @table_no_han_yuko TABLE
    (
    cd_hinmei varchar(14)
    ,dt_from datetime
    ,no_han decimal(4, 0)
    ,flg_mishiyo smallint
    ,cd_shizai varchar(14)
    ,su_shiyo decimal(12, 6)
    )
AS
	BEGIN
        -- 戻りテーブルへ有効版データを追加
		INSERT INTO @table_no_han_yuko
        SELECT
            h.cd_hinmei
            ,h.dt_from
            ,h.no_han
            ,h.flg_mishiyo
            ,b.cd_shizai
            ,b.su_shiyo
        FROM
        -- 有効日付が版番号間で同一の場合、最大の版番号を取得する
        (
            SELECT
                yuko.cd_hinmei
                ,yuko.dt_from
                ,h.flg_mishiyo
                ,MAX(h.no_han) AS no_han
            FROM
            -- 品名毎の最大の有効日付を取得する
            (
                SELECT
                    cd_hinmei
                    ,MAX(dt_from) AS dt_from
                FROM
                ma_shiyo_h
                WHERE
                    cd_hinmei = @cd_hinmei
                    AND flg_mishiyo = @flg_mishiyo
                    AND dt_from <= @dt_hizuke
                GROUP BY cd_hinmei
            ) yuko
            LEFT OUTER JOIN ma_shiyo_h h
            ON yuko.cd_hinmei = h.cd_hinmei
            AND yuko.dt_from = h.dt_from
            GROUP BY 
                yuko.cd_hinmei
                ,yuko.dt_from
                ,h.flg_mishiyo
        ) h
        LEFT OUTER JOIN ma_shiyo_b b
        ON h.cd_hinmei = b.cd_hinmei
        AND h.no_han = b.no_han

	RETURN
	END
GO
