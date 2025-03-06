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
    public class YukoHaigoMeiSeizoLineController : ApiController
	{
        // GET api/MasterColumn
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_YukoHaigoMeiSeizoLine_select_Result> Get([FromUri]YukoHaigoMeiCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド実行
            IEnumerable<usp_YukoHaigoMeiSeizoLine_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_YukoHaigoMeiSeizoLine_select(
                criteria.cd_hinmei
                ,criteria.dt_seizo
                ,criteria.flg_mishiyo
                ,criteria.kbn_master
                ,criteria.cd_line
                ,ActionConst.SeihinHinKbn
                ,ActionConst.JikaGenryoHinKbn
            ).ToList();

            var result = new StoredProcedureResult<usp_YukoHaigoMeiSeizoLine_select_Result>();

            result.d = views;
            result.__count = ((List<usp_YukoHaigoMeiSeizoLine_select_Result>)views).Count;

            return result;
        }
	}
}