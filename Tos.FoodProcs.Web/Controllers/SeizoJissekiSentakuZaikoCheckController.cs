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
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class SeizoJissekiSentakuZaikoCheckController : ApiController
    {
        /// <summary>
        /// 仕掛残在庫数チェック：使用実績按分区分#残の時
        /// </summary>
        /// <param name="su_shiyo_shikakari">仕掛品使用数</param>
        /// <param name="no_lot_seihin">製品番号</param>
        /// <param name="kbn_shiyo_jisseki_anbun">使用実績按分区分</param>
        /// <returns>チェック結果</returns>
        public usp_SeizoJissekiSentaku_select_Result Get(
            [FromUri]checkZaikoSu criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            usp_SeizoJissekiSentaku_select_Result views;

            // 検索用ストアドプロシージャの実行
            views = context.usp_SeizoJissekiSentaku_select(
                 criteria.after_su_shiyo_shikakari
                , criteria.no_lot_seihin
                , criteria.kbn_shiyo_jisseki_anbun
            ).FirstOrDefault();

            return views;
        }
    }

    public class checkZaikoSu
    {
        public decimal after_su_shiyo_shikakari { get; set; }
        public string no_lot_seihin { get; set; }
        public string kbn_shiyo_jisseki_anbun { get; set; }
    }
}