IF EXISTS (SELECT * FROM sysobjects WHERE id = object_id(N'udf_ChuiKankiShiyo') AND xtype IN (N'FN', N'IF', N'TF')) 
DROP FUNCTION [dbo].[udf_ChuiKankiShiyo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*****************************************************
機能  ：原料注意喚起マスタの喚起名称を取得する
ファイル名 ：udf_ChuiKankiShiyo
入力引数 ：@cd_hinmei, @kbn_chui, @flg_hyoji,@flg_mishiyo
出力引数 ：-
戻り値  ：@table_chui_kanki
作成日  ：2014.07.16 endo.y
更新日  ：2017.03.15 BRC kanehira.d　【海外対応】2.10課題管理台帳_単体テストNo.82
*****************************************************/
CREATE FUNCTION [dbo].[udf_ChuiKankiShiyo]
	(
    @cd_hinmei		VARCHAR(14)	-- 品名コード
    ,@kbn_chui		SMALLINT	-- 注意喚起区分
    ,@flg_hyoji		SMALLINT	-- 注意喚起表示あり
    ,@flg_mishiyo	SMALLINT	-- 未使用フラグ
    ,@kbn_hin		SMALLINT	-- 品区分
	)
-- 戻りテーブル

			
RETURNS @table_chui_kanki TABLE
    (
    --nm_kbn VARCHAR(50)
    --,nm_chui_kanki VARCHAR(max)
    nm_kbn NVARCHAR(50)
    ,nm_chui_kanki NVARCHAR(max)
    )
AS
	BEGIN
        -- 戻りテーブルへ注意喚起データを追加
DECLARE @kbnmei NVARCHAR(50)
DECLARE @str NVARCHAR(max)
			SELECT
			@kbnmei = kbn.nm_kbn_chui_kanki
			,@str = REPLACE(REPLACE((
					SELECT mck.nm_chui_kanki AS [data()]
					FROM ma_chui_kanki_genryo mckg
					INNER JOIN 
						(
							SELECT
								cd_chui_kanki
								,nm_chui_kanki
								,kbn_chui_kanki
							FROM ma_chui_kanki
							WHERE flg_mishiyo = @flg_mishiyo
						) mck
					ON mckg.cd_chui_kanki = mck.cd_chui_kanki 
					AND mck.kbn_chui_kanki = @kbn_chui
					AND mckg.flg_chui_kanki_hyoji = @flg_hyoji
					WHERE mckg.kbn_chui_kanki = @kbn_chui
					AND mckg.cd_hinmei = @cd_hinmei
					AND mckg.kbn_hin = @kbn_hin
					AND mckg.flg_mishiyo = @flg_mishiyo
					ORDER BY mckg.no_juni_yusen
					FOR XML PATH('a')),'</a>',','),'<a>','')
			FROM ma_kbn_chui_kanki kbn
			WHERE kbn.kbn_chui_kanki = @kbn_chui
			
		INSERT INTO @table_chui_kanki
			SELECT 
			@kbnmei AS nm_kbn
			,LEFT(@str,(LEN(@str)-1)) AS nm_chui_kanki

	RETURN
	END
GO
