IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeihinKeikaku_Shiyo_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeihinKeikaku_Shiyo_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,sueyoshi.y>
-- Create date: <Create Date,,2013.10.30>
-- Last Update: 2014.07.28 tsujita.s
-- Description:	<Description,,使用予実トラン>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeihinKeikaku_Shiyo_update]
    --@no_seq	VARCHAR(4, 0) -- シーケンス番号
    @flg_yojitsu SMALLINT -- 予実フラグ
    ,@cd_hinmei VARCHAR(14) -- 品名コード
    ,@dt_shiyo DATETIME -- 使用日
    ,@no_lot_seihin VARCHAR(14) -- 製品ロット番号
    ,@no_lot_shikakari VARCHAR(14) -- 仕掛品ロット番号
    ,@su_shiyo DECIMAL(30,6) -- 使用数
    ,@kbn_saiban VARCHAR(2) -- 採番区分(使用予実)
    ,@kbn_prefix VARCHAR(1) -- プリフィックス(使用予実)
    ,@data_key_tr_shikakari VARCHAR(14) -- 仕掛品トランデータキー

AS

BEGIN

    BEGIN
        -- 採番取得
        DECLARE @no VARCHAR(14)
        
        EXEC dbo.usp_cm_Saiban @kbn_saiban, @kbn_prefix, @no_saiban = @no OUTPUT
    END

    BEGIN
    
        INSERT INTO 
            tr_shiyo_yojitsu (
				no_seq
				,flg_yojitsu
				,cd_hinmei
				,dt_shiyo
				,no_lot_seihin
				,no_lot_shikakari
				,su_shiyo
				,data_key_tr_shikakari
			)
        VALUES (
			@no
			,@flg_yojitsu
			,@cd_hinmei
			,@dt_shiyo
			,@no_lot_seihin
			,@no_lot_shikakari
			,@su_shiyo
			,@data_key_tr_shikakari
		)
    END
END
GO
