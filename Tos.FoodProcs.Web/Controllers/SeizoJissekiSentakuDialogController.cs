using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using System.Net.Http.Formatting;
using System.Data.SqlClient;
using System.Web.Security;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class SeizoJissekiSentakuDialogController : ApiController
	{
        // GET api/SeizoJissekiSentakuDialog
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        /// <returns>検索結果</returns>
        public StoredProcedureResult<usp_SeizoJissekiSentakuDialog_select_Result> Get(
            [FromUri]SeizoJissekiSentakuDialogCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド実行
            IEnumerable<usp_SeizoJissekiSentakuDialog_select_Result> views;
            short flg_kakutei = ActionConst.FlagTrue;
            short flg_shiyo = ActionConst.FlagFalse;
            views = context.usp_SeizoJissekiSentakuDialog_select(
                criteria.dt_from
                , criteria.dt_to
                , criteria.cd_haigo
                , flg_kakutei
                , flg_shiyo
            ).ToList();

            var result = new StoredProcedureResult<usp_SeizoJissekiSentakuDialog_select_Result>();

            result.__count = ((List<usp_SeizoJissekiSentakuDialog_select_Result>)views).Count;

            // 検索結果が取得最大件数を超えていた場合
            int maxCount = (int)criteria.top;
            if (result.__count > maxCount)
            {
                // 取得最大数以上の結果は削除する
                result.d = views.Take(maxCount);
            }
            else
            {
                result.d = views;
            }

            return result;
        }
	}
}