IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_LineMaster_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_LineMaster_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,nakamura.r>
-- Create date: <Create Date,,2013.07.29>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineMaster_delete]
	@cd_line varchar(10)
AS
BEGIN

	DELETE FROM ma_line
	WHERE 
		cd_line = @cd_line

END
GO
