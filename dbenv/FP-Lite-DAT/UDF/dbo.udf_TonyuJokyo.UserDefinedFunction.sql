IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_TonyuJokyo') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_TonyuJokyo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：投入状況取得処理
ファイル名 ：udf_ShizaiShiyoYukoHan
入力引数 ：@cd_hinmei, @flg_mishiyo, @dt_hizuke
出力引数 ：-
戻り値  ：@table_no_han_yuko
作成日  ：2013.11.07 kasahara.a
更新日  ：
*****************************************************/
CREATE FUNCTION [dbo].[udf_TonyuJokyo]
	(
    @cd_panel varchar(14) -- パネルコード
    ,@cd_shokuba varchar(10) -- 職場コード
    ,@FlagFalse VARCHAR(1)
    ,@KbnSeikiHasuSeiki VARCHAR(1)
	)
-- 戻りテーブル
RETURNS @table_tonyu_jokyo TABLE
    (
    cd_line varchar(10)
    ,nm_line nvarchar(50)
    ,cd_haigo varchar(14)
    ,nm_haigo nvarchar(50)
    ,no_kotei decimal(4, 0)
    ,su_yotei_disp decimal(4, 0)
    ,su_kai_disp decimal(4, 0)
    ,su_yotei decimal(4, 0)
    ,su_yotei_hasu decimal(4, 0)
    ,su_kai decimal(4, 0)
    ,su_kai_hasu decimal(4, 0)
    ,no_tonyu decimal(4, 0)
    ,mark varchar(2)
    ,cd_hinmei varchar(14)
    ,nm_hinmei nvarchar(50)
    ,wt_kihon decimal(4, 0)
    ,no_lot_seihin varchar(14)
    ,kbn_seikihasu smallint
    ,kbn_jokyo smallint
    ,dt_seizo datetime
    ,dt_yotei_seizo datetime
    )
AS
BEGIN

/*-----------------------------------------
    投入状況の確認
-----------------------------------------*/
DECLARE @seizoDate DATETIME
DECLARE @haigoCode VARCHAR(14)

SELECT
    @seizoDate = tj.dt_seizo
    ,@haigoCode = tj.cd_haigo
FROM tr_tonyu_jokyo tj
LEFT OUTER JOIN ma_panel p
ON tj.cd_panel = p.cd_panel
AND tj.cd_shokuba = p.cd_shokuba
WHERE
    tj.cd_panel = @cd_panel
    AND tj.cd_shokuba = @cd_shokuba

/*-----------------------------------------
    投入状況のを取得しINSERTする
-----------------------------------------*/
-- 戻りテーブルへ有効版データを追加
INSERT INTO @table_tonyu_jokyo
SELECT
    tj.cd_line
    ,l.nm_line
    ,tj.cd_haigo
    ,tj.nm_haigo
    ,tj.no_kotei
    ,CASE WHEN tj.kbn_seikihasu = @KbnSeikiHasuSeiki
        THEN tj.su_yotei
        ELSE tj.su_yotei_hasu
        END AS su_yotei_disp
    ,CASE WHEN tj.kbn_seikihasu = @KbnSeikiHasuSeiki
        THEN tj.su_kai
        ELSE tj.su_kai_hasu
        END AS su_kai_disp
    ,tj.su_yotei
    ,tj.su_yotei_hasu
    ,tj.su_kai
    ,tj.su_kai_hasu
    ,tj.no_tonyu
    ,m.mark
    ,hmp.cd_hinmei
    ,hmp.nm_hinmei
    ,hmp.wt_kihon
    ,tj.no_lot_seihin
    ,tj.kbn_seikihasu
    ,tj.kbn_jokyo
    ,tj.dt_seizo
    ,tj.dt_yotei_seizo
FROM udf_HaigoRecipeYukoHan(@haigoCode, @FlagFalse, @seizoDate) hmp
LEFT OUTER JOIN tr_tonyu_jokyo tj
ON hmp.cd_haigo = tj.cd_haigo
AND hmp.no_kotei = tj.no_kotei
AND hmp.no_tonyu = (CASE WHEN tj.no_tonyu = 0 THEN tj.no_tonyu + 1 ELSE tj.no_tonyu END)
LEFT OUTER JOIN ma_line l
ON tj.cd_line = l.cd_line
LEFT OUTER JOIN ma_mark m
ON hmp.cd_mark = m.cd_mark
WHERE
    tj.cd_panel = @cd_panel
    AND tj.cd_shokuba = @cd_shokuba

RETURN
END
GO
