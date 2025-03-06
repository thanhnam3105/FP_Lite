using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiKonyuDialogController : ApiController {
        // GET api/GenshizaiKonyuDialog
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_GenshizaiKonyuDialog_select_Result> Get([FromUri]GenshizaiKonyuDialogCriteria criteria) {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiKonyuDialog_select_Result> views;
            views = context.usp_GenshizaiKonyuDialog_select(
                criteria.cd_hinmei,
                criteria.flg_mishiyo,
                ChangedNullToEmpty(criteria.nm_torihiki)
                ).AsEnumerable();
            return views;
        }

        /// <summary>nullの場合、空文字に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        private string ChangedNullToEmpty(string value)
        {
            if (String.IsNullOrEmpty(value) || value == "null")
            {
                value = "";
            }
            return value;
        }
    }
}