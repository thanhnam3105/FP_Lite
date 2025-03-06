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
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class ShikakarihinShiyoIchiranController : ApiController {
        
                // GET api/MasterColumn
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_ShikakarihinShiyoIchiran_select_Result> Get(
                                        [FromUri]ShikakarihinShiyoIchiranCriteria criteria)
        {

            FoodProcsEntities context = new FoodProcsEntities();
            List<usp_ShikakarihinShiyoIchiran_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_ShikakarihinShiyoIchiran_select(
                criteria.dt_shikomi_search,
                criteria.shikakariCode,
                criteria.no_han, 
                criteria.skip, 
                criteria.top,
                bool.Parse("false")
                ).ToList();

            var result = new StoredProcedureResult<usp_ShikakarihinShiyoIchiran_select_Result>();

            result.d = views;
            if (views.Count == 0)
            {
                result.__count = 0;
            }
            else
            {
                result.__count = (int)views.ElementAt(0).cnt;
            }

            return result;
        }
	}
}