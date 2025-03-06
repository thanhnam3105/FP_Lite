IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_ShiyoYojitsuAnbunTran_delete') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================================================
-- Author     :	tsujita.s
-- Create date: 2015.07.08
-- Last Update: 2015.07.09 tsujita.s
-- Description: �g�p�\�����g�����̍폜�����F�d�|�i���b�g�ԍ��ňꊇ�폜
-- =======================================================================
CREATE PROCEDURE [dbo].[usp_ShiyoYojitsuAnbunTran_delete]
	@no_lot_shikakari	varchar(14)	-- �폜�����F�d�|�i���b�g�ԍ�
	,@no_lot_seihin		varchar(14)	-- �폜�����F���i���b�g�ԍ�
AS
BEGIN

	-- ���i���b�g�ԍ������݂���ꍇ�F�������񂩂�̍폜��
	IF LEN(@no_lot_seihin) > 0
	BEGIN
		-- ���i���b�g�ԍ�����d�|�i���b�g�ԍ����擾���A�֘A������g���������ׂč폜����
		DELETE
			tr_sap_shiyo_yojitsu_anbun
		WHERE
			no_lot_shikakari IN (
				SELECT no_lot_shikakari
				FROM vw_tr_sap_shiyo_yojitsu_anbun_02
				WHERE no_lot_seihin = @no_lot_seihin
				GROUP BY no_lot_shikakari

				--SELECT
				--	shikakari.no_lot_shikakari
				--FROM
				--	tr_sap_shiyo_yojitsu_anbun seihin
				--LEFT JOIN tr_sap_shiyo_yojitsu_anbun shikakari
				--ON seihin.no_lot_shikakari = shikakari.no_lot_shikakari
				--WHERE
				--	seihin.no_lot_seihin = @no_lot_seihin
				--GROUP BY shikakari.no_lot_shikakari
			)
	END
	ELSE BEGIN
		-- �d�����񂩂�̍폜���F�d�|�i���b�g�ԍ��ňꊇ�폜
		DELETE
			tr_sap_shiyo_yojitsu_anbun
		WHERE
			no_lot_shikakari = @no_lot_shikakari
	END

END
GO
