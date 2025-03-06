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
    public class GekkanSeihinKeikakuJissekiController : ApiController
	{
        // GET api/MasterColumn
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">POST された HTTP リクエストの クエリ に設定された値</param>
        public HttpResponseMessage Post([FromBody]ChangeSet<GekkanSeihinKeikakuCriteria> value)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;

            // 渡された値から、ロットを取得してセット
            string lot = string.Empty;
            string updateLot = string.Empty;
            foreach (var data in value.Created)
            {
                updateLot = data.no_lot_seihin;
                // 新規の場合、次へ
                if (updateLot == null)
                {
                    continue;
                }

                // ロットをセット
                if (lot == string.Empty)
                {
                    lot += updateLot;
                }
                else
                {
                    lot += "," + updateLot;
                }
            }

            // 全て新規の場合、リターン
            if (lot == string.Empty)
            {
                return Request.CreateResponse(HttpStatusCode.NoContent);
            }

            // ストアド用に値を判定
            IEnumerable<usp_GekkanSeihinKeikakuJisseki_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_GekkanSeihinKeikakuJisseki_select(
                lot
                ,short.Parse(Resources.FlagTrue)
                ,count).ToList();

            var result = new StoredProcedureResult<usp_GekkanSeihinKeikakuJisseki_select_Result>();
            result.d = views;

            int _cnt = ((List<usp_GekkanSeihinKeikakuJisseki_select_Result>)views).Count;
            // 取得件数が0件以上の場合
            if (_cnt > 0)
            {
                result.__count = _cnt;
                return Request.CreateResponse<StoredProcedureResult<usp_GekkanSeihinKeikakuJisseki_select_Result>>(HttpStatusCode.BadRequest, result);
                
            }
            // 取得件数が0件の場合
            else
            {
                return Request.CreateResponse(HttpStatusCode.NoContent);
            }

        }
	}
}