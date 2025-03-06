IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_tr_henko_rireki_update') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_tr_henko_rireki_update]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,trung.nq>
-- Create date: <Create Date,,2021.06.21>
-- Description:	<Description,,>
-- Update dateÅF
-- =============================================
CREATE PROCEDURE [dbo].[usp_tr_henko_rireki_update]
     @kbn_data		DECIMAL(2,0)
    ,@kbn_shori		DECIMAL(2,0)
    ,@dt_hizuke		DATETIME  
    ,@cd_hinmei		VARCHAR(14)     
	,@su_henko		DECIMAL(16,6)
	,@su_henko_hasu	DECIMAL(12,6)
	,@no_lot		VARCHAR(14)
	,@biko			NVARCHAR(200)
	,@cd_update		VARCHAR(10)
AS

BEGIN    
    BEGIN    
        INSERT INTO tr_henko_rireki(
			 kbn_data
			,kbn_shori
			,dt_hizuke
			,cd_hinmei
			,su_henko
			,su_henko_hasu
			,no_lot
			,biko
			,dt_update
			,cd_update
        )
        VALUES (
             @kbn_data		
			,@kbn_shori		
			,@dt_hizuke		
			,@cd_hinmei		
			,@su_henko		
			,@su_henko_hasu	
			,@no_lot		
			,@biko	
			,GETUTCDATE()		
			,@cd_update		            
        )
    END

END
GO
