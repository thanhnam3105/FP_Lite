IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_TantoshaMaster_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_TantoshaMaster_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,kobayashi.y>
-- Create date: <Create Date,,2013.07.29>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_TantoshaMaster_delete]
	@cd_tanto VARCHAR(10)
	
AS
BEGIN

/*******************************
	担当者マスタ　更新
*******************************/
DELETE FROM ma_tanto
WHERE cd_tanto = @cd_tanto

END
GO
