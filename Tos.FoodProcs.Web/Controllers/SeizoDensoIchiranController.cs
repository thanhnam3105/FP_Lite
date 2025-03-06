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

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class SeizoDensoIchiranController : ApiController
    {
        // GET api/ShiyoryoKeisan
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_SeizoDensoIchiran_select_Result> Get([FromUri]SeizoDensoIchiranCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            List<usp_SeizoDensoIchiran_select_Result> views;
            String put_char = ActionConst.SeihinLotPrefixSaibanKbn + ActionConst.sapPutOnChar;

            if (ActionConst.YoteiYojitsuFlag.Equals(criteria.flg_yojitsu))
            {
                ///// 予定(計画)の場合
                views = context.usp_SeizoKeikakuDensoIchiran_select(
                    criteria.dt_denso_from,
                    criteria.dt_denso_to,
                    criteria.dt_seizo_from,
                    criteria.dt_seizo_to,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_hinmei),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.no_lot_seihin),
                    criteria.chk_denso,
                    criteria.chk_seizo,
                    put_char,
                    ActionConst.FlagFalse
                ).ToList();
            }
            else
            {
                ///// 実績の場合
                views = context.usp_SeizoJissekiDensoIchiran_select(
                    criteria.dt_denso_from,
                    criteria.dt_denso_to,
                    criteria.dt_seizo_from,
                    criteria.dt_seizo_to,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_hinmei),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.no_lot_seihin),
                    criteria.chk_denso,
                    criteria.chk_seizo,
                    put_char,
                    ActionConst.FlagFalse
                ).ToList();
            }

            var result = new StoredProcedureResult<usp_SeizoDensoIchiran_select_Result>();

            int cnt = views.Count;
            int top = (int)criteria.top;
            result.__count = cnt;
            if (cnt > top)
            {
                // 検索結果が上限数を超えている場合、最初の500件のみ抽出
                result.d = views.GetRange(0, top);
            }
            else
            {
                result.d = views;
            }
            
            return result;
        }
    }
}