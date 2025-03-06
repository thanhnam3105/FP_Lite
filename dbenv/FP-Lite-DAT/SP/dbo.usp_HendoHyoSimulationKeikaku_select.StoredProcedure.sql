IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_HendoHyoSimulationKeikaku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_HendoHyoSimulationKeikaku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===================================================
-- Author:		tsujita.s
-- Create date: 2014.01.14
-- Last Update: 2015.06.10 tsujita.s
-- Description:	�ϓ��\�V�~�����[�V�����F
--              �v��쐬�{�^���������̈����擾����
-- ===================================================
CREATE PROCEDURE [dbo].[usp_HendoHyoSimulationKeikaku_select]
	 @con_cd_hinmei varchar(14)
	,@flg_shiyo smallint
	,@kbn_master_hin smallint
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		@con_cd_hinmei AS cd_hinmei
		,sl.cd_line AS cd_line
		,ml.cd_shokuba AS cd_shokuba
	FROM
		ma_seizo_line sl

	-- �ŗD�揇�ʂ̐������C���}�X�^
	INNER JOIN (
		SELECT cd_haigo
			,MIN(no_juni_yusen) AS no_juni_yusen
		FROM ma_seizo_line
		WHERE cd_haigo = @con_cd_hinmei
		AND flg_mishiyo = @flg_shiyo
		AND kbn_master = @kbn_master_hin
		GROUP BY cd_haigo
	) yusen
	ON sl.cd_haigo = yusen.cd_haigo
	AND sl.no_juni_yusen = yusen.no_juni_yusen

	-- ���C���}�X�^
	INNER JOIN ma_line ml
	ON ml.cd_line = sl.cd_line
	AND ml.flg_mishiyo = @flg_shiyo

	-- �E��}�X�^
	INNER JOIN ma_shokuba ms
	ON ms.cd_shokuba = ml.cd_shokuba
	AND ms.flg_mishiyo = @flg_shiyo

	WHERE kbn_master = @kbn_master_hin

END
GO
