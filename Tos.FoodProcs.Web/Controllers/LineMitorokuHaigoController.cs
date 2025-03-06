using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.OData;
using System.Web.Http.OData.Query;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using System.Net.Http.Formatting;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class LineMitorokuHaigoController : ApiController
	{
        
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_LineMitorokuHaigo_select_Result> Get([FromUri]LineMitorokuHaigoCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_LineMitorokuHaigo_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_LineMitorokuHaigo_select(
                criteria.flg_mishiyo, 
                criteria.kbn_master,
                criteria.searchHan, 
                criteria.skip, 
                criteria.top, 
                count).ToList();

            var result = new StoredProcedureResult<usp_LineMitorokuHaigo_select_Result>();

            result.d = views;
            result.__count = (int)count.Value;

            return result;
        }
	}
}