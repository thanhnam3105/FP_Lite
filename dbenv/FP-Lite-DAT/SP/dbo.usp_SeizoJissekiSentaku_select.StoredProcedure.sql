IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'usp_SeizoJissekiSentaku_select') AND type IN (N'P', N'PC')) 
DROP PROCEDURE [dbo].[usp_SeizoJissekiSentaku_select]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =================================================================================											
-- Author:		<Author,,inamori.h>									
-- Create date: <Create Date,,2015.12.17>											
-- Description:	<Description,,�������ёI�����> 										
-- �d�|�c�݌ɐ��`�F�b�N:���͂����d�|�i�g�p�ʂ��d�|�c�g�p�ʃg�����̍��v�g�p��											
-- ��������Ă��Ȃ����`�F�b�N���邽�߂̏���											
--											
-- =================================================================================											
CREATE PROCEDURE [dbo].[usp_SeizoJissekiSentaku_select]											
	@after_su_shiyo_shikakari	DECIMAL(12,6)	-- ����:�ύX��d�|�i�g�p��								
	,@no_lot_seihin		VARCHAR(14)	            -- ���ׁF���i���b�gNo							
	,@anbunKubnZan		VARCHAR(1)              -- ���ׁF�g�p���ш��敪								
AS											
BEGIN											
											
SELECT											
	shiyosuSum.no_lot_seihin										
FROM											
(																					
	SELECT										
		ISNULL(anbunZan.su_shiyo_sum, 0) AS su_shiyo_sum									
		,anbun.no_lot_seihin									
		,anbun.su_shiyo_shikakari									
	FROM tr_sap_shiyo_yojitsu_anbun anbun										
	LEFT OUTER JOIN 										
	(										
		SELECT									
			SUM(zan.su_shiyo) AS su_shiyo_sum								
			,zan.no_seq_shiyo_yojitsu_anbun								
		FROM tr_shiyo_shikakari_zan zan									
		INNER JOIN tr_sap_shiyo_yojitsu_anbun yojitsuAnbun									
		ON zan.no_seq_shiyo_yojitsu_anbun = yojitsuAnbun.no_seq									
		WHERE									
			yojitsuAnbun.kbn_shiyo_jisseki_anbun = @anbunKubnZan								
		GROUP BY zan.no_seq_shiyo_yojitsu_anbun									
	) anbunZan										
	ON anbun.no_seq = anbunZan.no_seq_shiyo_yojitsu_anbun										
	WHERE 										
		anbun.kbn_shiyo_jisseki_anbun = @anbunKubnZan									
)shiyosuSum											
WHERE 											
	shiyosuSum.no_lot_seihin = @no_lot_seihin										
	AND (										
			shiyosuSum.su_shiyo_shikakari - shiyosuSum.su_shiyo_sum 								
										  - shiyosuSum.su_shiyo_shikakari	
										  + @after_su_shiyo_shikakari	
		)>= 0									
											
											
											
END
GO
