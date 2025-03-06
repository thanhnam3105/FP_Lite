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

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class SeizoNippoUchiwakeController : ApiController {

        // GET api/SeizoNippo
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_SeizoNippoUchiwake_select_Result> Get([FromUri]UchiwakeInfo criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_SeizoNippoUchiwake_select_Result> views;

            var result = new StoredProcedureResult<usp_SeizoNippoUchiwake_select_Result>();

            views = context.usp_SeizoNippoUchiwake_select(
                criteria.cd_hinmei
                , criteria.no_lot_seihin
                , ActionConst.shiyoJissekiAnbunKubunSeizo
                , ActionConst.shiyoJissekiAnbunKubunZan
                , ActionConst.FlagFalse
                ).ToList();

            result.d = views;
            return result;
        }
	}
}