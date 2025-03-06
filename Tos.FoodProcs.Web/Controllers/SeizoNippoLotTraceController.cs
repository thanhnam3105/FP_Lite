using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Controllers;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class SeizoNippoLotTraceController : ApiController
	{
        /// GET api/SeizoNippoLotTrace
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        /// <returns></returns>
        public StoredProcedureResult<usp_SeizoNippo_select_02_Result> Post([FromBody]ChangeSet<SeizoNippoCriteria> value)
        {
            FoodProcsEntities context = new FoodProcsEntities();            

            IEnumerable<usp_SeizoNippo_select_02_Result> views = null;
            List<usp_SeizoNippo_select_02_Result> lst_views = new List<usp_SeizoNippo_select_02_Result>();

            // 変更セットを元に更新対象のエンティティを更新します。
            if (value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    views = context.usp_SeizoNippo_select_02(updated.no_lot_seihin, updated.flg_jisseki).ToList();
                    lst_views.AddRange(views);
                }
            }

            var result = new StoredProcedureResult<usp_SeizoNippo_select_02_Result>();

            result.d = lst_views.Where(m => !string.IsNullOrEmpty(m.no_lot_seihin) && !string.IsNullOrEmpty(m.no_lot_shikakari) && m.dt_seizo.HasValue);
            result.__count = lst_views.Where(m => !string.IsNullOrEmpty(m.no_lot_seihin) && !string.IsNullOrEmpty(m.no_lot_shikakari) && m.dt_seizo.HasValue).Count();

            return result;
        }
        
	}
}