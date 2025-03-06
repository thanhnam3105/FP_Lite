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
    public class ShikakariZanIchiranDialogController : ApiController
	{
        // GET api/HinmeiDialog
        /// <summary>
        /// 【品名ダイアログ：品区分が「仕掛品」のときの検索処理】
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        /// <returns>検索結果</returns>
        public StoredProcedureResult<usp_ShikakariZanIchiranDialog_select_Result> Get([FromUri]ShikakariZanIchiranDialogCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド実行
            IEnumerable<usp_ShikakariZanIchiranDialog_select_Result> views;
            views = context.usp_ShikakariZanIchiranDialog_select(
                criteria.cd_hinmei
                , criteria.seizo_date_start
                , criteria.seizo_date_end
                , criteria.lang
            ).ToList();

            var result = new StoredProcedureResult<usp_ShikakariZanIchiranDialog_select_Result>();
            result.d = views;
            result.__count = ((List<usp_ShikakariZanIchiranDialog_select_Result>)views).Count;

            //// 検索結果が取得最大件数を超えていた場合
            //int maxCount = (int)criteria.top;
            //if (result.__count > maxCount)
            //{
            //    // 取得最大数以上の結果は削除する
            //    result.d = views.Take(maxCount);
            //}
            //else
            //{
            //    result.d = views;
            //}

            return result;
        }
	}
    public class ShikakariZanIchiranDialogCriteria {

        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public ShikakariZanIchiranDialogCriteria() { }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }


        /// <summary>
        /// 開始日
        /// </summary>
        public DateTime seizo_date_start { get; set; }


        /// <summary>
        /// 終了日
        /// </summary>
        public DateTime seizo_date_end { get; set; }

        /// <summary>
        /// 言語
        /// </summary>
        public String lang { get; set; }



    }
}