IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoLineMaster_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoLineMaster_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,okada.k>
-- Create date: <Create Date,,2013.05.30>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_SeizoLineMaster_delete]
	@cd_haigo varchar(14)
	,@kbn_master smallint
AS
BEGIN

	DELETE FROM ma_seizo_line
	WHERE 
		cd_haigo = @cd_haigo
		AND kbn_master = @kbn_master

END
GO
