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
using Newtonsoft.Json.Linq;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiUkeharaiIchiranController : ApiController
    {
        // GET api/GenshizaiUkeharaiIchiranController
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        /// 
        public StoredProcedureResult<usp_GenshizaiUkeharaiIchiran_select_Result> Get([FromUri]GenshizaiUkeharaiIchiranCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            List<usp_GenshizaiUkeharaiIchiran_select_Result> list;
            var count = new ObjectParameter("count", 0);
            list = context.usp_GenshizaiUkeharaiIchiran_select(
                criteria.kbn_hin,
                criteria.cd_bunrui,
                criteria.dt_hiduke_from,
                criteria.dt_hiduke_to,
                criteria.cd_genshizai,
                criteria.flg_mishiyobun,
                criteria.flg_shiyo,
                criteria.flg_zaiko,
                criteria.flg_today_jisseki,
                criteria.dt_today,
                criteria.cd_kg,
                criteria.cd_li,
                criteria.flg_yojitsu_yotei,
                criteria.flg_yojitsu_jisseki,
                criteria.flg_jisseki_kakutei,
                criteria.kbn_genryo,
                criteria.kbn_shizai,
                criteria.kbn_jikagenryo,
                criteria.NounyuYoteiKbn,
                criteria.NounyuJissekiKbn,
                criteria.ShiyoYoteiKbn,
                criteria.ShiyoJissekiKbn,
                criteria.ChoseiKbn,
                criteria.seizoYoteiKbn,
                criteria.seizoJissekiKbn,
                criteria.choseiRiyuKbn,
                criteria.ukeharaiKbn

                ).ToList();

            var result = new StoredProcedureResult<usp_GenshizaiUkeharaiIchiran_select_Result>();

            int resultCount = list.Count();
              result.__count = resultCount;

            int maxCount = (int)criteria.maxCount;
            if (resultCount > maxCount)
            {
                // 上限数を超えていた場合
                int deleteCount = resultCount - (maxCount + 1); // 削除数
                list.RemoveRange(maxCount + 1, deleteCount);
                result.d = list.AsEnumerable();
            }
            else
            {
                result.d = list.AsEnumerable();
            }

            return result;
        }
    }

}