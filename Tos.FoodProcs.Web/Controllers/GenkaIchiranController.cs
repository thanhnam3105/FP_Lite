using System;
using System.Collections.Generic;
using System.Data.Objects;
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
    public class GenkaIchiranController : ApiController
	{
        // GET api/GenkaIchiranController
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_GenkaIchiran_select_Result> Get([FromUri]GenkaKeisanCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;
            // TODO：タイムアウト時間変更(0=無限)
            context.CommandTimeout = 0;

            IEnumerable<usp_GenkaIchiran_select_Result> views;
            views = context.usp_GenkaIchiran_select(
                    criteria.dt_from
                    , criteria.dt_to
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_shokuba)
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_line)
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_bunrui)
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_hinmei)
                    , criteria.tanka_settei
                    , criteria.master_tanka
                    , ActionConst.YoteiYojitsuFlag
                    , ActionConst.JissekiYojitsuFlag
                    , ActionConst.FlagTrue
                    , ActionConst.FlagFalse
                    , ActionConst.TanaoroshiTankaKbn
                    , ActionConst.NonyuTankaKbn
                    , ActionConst.RomuhiTankaKbn
                    , ActionConst.KeihiTankaKbn
                    , ActionConst.CsTankaTankaKbn
                    , ActionConst.GenryoHinKbn
                    , ActionConst.ShizaiHinKbn
                ).AsEnumerable();


            // 「クエリの結果を複数回列挙できません」対策
            List<usp_GenkaIchiran_select_Result> list
                = views.ToList<usp_GenkaIchiran_select_Result>();
            var result = new StoredProcedureResult<usp_GenkaIchiran_select_Result>();

            int maxCount = (int)criteria.top;
            int resultCount = list.Count();
            result.__count = resultCount;
            
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