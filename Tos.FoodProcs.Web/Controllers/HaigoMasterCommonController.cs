using System;
using System.Linq;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class HaigoMasterCommonController : ApiController
    {
        // GET api/HaigoMasterCommonController
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_ma_haigo_mei_01_Result> Get([FromUri]HaigoMasterCommon criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            StoredProcedureResult<usp_ma_haigo_mei_01_Result> result = new StoredProcedureResult<usp_ma_haigo_mei_01_Result>();

            result.d = context.usp_ma_haigo_mei_01(
                                                criteria.cd_haigo
                                                , criteria.sysDate
                                                , ActionConst.ShikakariHinKbn   // 区分／コード一覧.品区分.仕掛品
                                                , ActionConst.FlagFalse         // 区分／コード一覧.未使用フラグ.使用
                                                ).ToList();
            return result;
        }
	}

    public class HaigoMasterCommon
    {
        public string cd_haigo { get; set; }// 任意の配合コード
        public DateTime sysDate { get; set; }// システム日付(比較対象のdt_fromと同様に時刻は10:00固定)
    }
}