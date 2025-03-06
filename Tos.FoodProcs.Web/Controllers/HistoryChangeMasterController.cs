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
using System.Data.Objects;
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers {

	[Authorize]
	[LoggingExceptionFilter]
	public class HistoryChangeMasterController : ApiController {

        // GET api/HistoryChangeMaster
		/// <summary>
		/// クライアントから送信された検索条件を基に検索処理を行います。
		/// </summary>
		/// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_HistoryChange_select_Result> Get([FromUri]HistoryChangeMasterCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
			// タイムアウト時間変更(0=無限)
			context.CommandTimeout = 0;
            IEnumerable<usp_HistoryChange_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_HistoryChange_select(
                criteria.kbn_data 
                , criteria.kbn_shori
                , criteria.dt_hiduke_from 
                , criteria.dt_hiduke_to
                , criteria.cd_hinmei
                , criteria.dt_update_from
                , criteria.dt_update_to
                , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_nm_tanto)
                , criteria.skip 
                , criteria.top 
                , 0
                , count).ToList();

            var result = new StoredProcedureResult<usp_HistoryChange_select_Result>();

            result.d = views;

            int _cnt = ((List<usp_HistoryChange_select_Result>)views).Count;
            // 取得件数が0件以上の場合
            if (_cnt > 0)
            {
                result.__count = (int)views.ElementAt<usp_HistoryChange_select_Result>(0).cnt;
            }
            // 取得件数が0件の場合
            else
            {
                result.__count = ((List<usp_HistoryChange_select_Result>)views).Count;
            }

            return result;
        }

        // GET api/HistoryChangeMaster
		/// <summary>
		/// クライアントから送信された検索条件を基に品名マスタ情報を取得します。
		/// </summary>
		/// <param name="con_hinmeiCode">検索条件/品名コード</param>
        public IEnumerable<vw_ma_hinmei_03> Get(string con_hinmeiCode)
        {
            DateTime sysdate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day);
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<vw_ma_hinmei_03> result;
            result = context.vw_ma_hinmei_03.Where(x => x.cd_hinmei == con_hinmeiCode
                                                    && (x.kbn_hin == ActionConst.SeihinHinKbn
                                                        || x.kbn_hin == ActionConst.GenryoHinKbn
                                                        || x.kbn_hin == ActionConst.ShizaiHinKbn
                                                        || x.kbn_hin == ActionConst.JikaGenryoHinKbn)).AsEnumerable();
            
            return result;
        }	
	}
}