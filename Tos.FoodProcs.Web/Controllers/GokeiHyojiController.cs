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
    public class GokeiHyojiController : ApiController
	{
        // GET api/GokeiHyoji
        /// <summary>
        /// 合計表示：クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_GokeiHyoji_select_Result> Get([FromUri]GokeiHyojiCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GokeiHyoji_select_Result> views;
            views = context.usp_GokeiHyoji_select(
                criteria.cd_shokuba
                ,criteria.cd_line
                ,ActionConst.FlagTrue
                ,ActionConst.FlagFalse
                ,criteria.dt_hiduke_from
                ,criteria.dt_hiduke_to
                ,criteria.dt_hiduke_today
                ,criteria.top).ToList();

            var result = new StoredProcedureResult<usp_GokeiHyoji_select_Result>();

            result.d = views;
            result.__count = ((List<usp_GokeiHyoji_select_Result>)views).Count;

            return result;
        }
	}
}