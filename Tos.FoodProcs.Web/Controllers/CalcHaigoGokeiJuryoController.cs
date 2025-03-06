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
	public class CalcHaigoGokeiJuryoController : ApiController
	{
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_HaigoJuryoGokei_select_Result> Get([FromUri]HaigoJuryoGokeiCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HaigoJuryoGokei_select_Result> views;
            views = context.usp_HaigoJuryoGokei_select(
                criteria.cd_haigo, 
                criteria.no_han,
                criteria.no_kotei, 
                criteria.kbn_kanzan, 
                criteria.wt_haigo_gokei,
                ActionConst.GenryoHinKbn, 
                ActionConst.ShikakariHinKbn, 
                ActionConst.JikaGenryoHinKbn,
                ActionConst.KgKanzanKbn, 
                ActionConst.LKanzanKbn
                ).ToList();
            var result = new StoredProcedureResult<usp_HaigoJuryoGokei_select_Result>();
            return views;
        }
	}
}