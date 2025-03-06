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
    public class NonyuIraishoListController : ApiController
    {
        // GET api/tr_nonyu
        /// <summary>
        /// クライアントから送信された条件を基に採番処理を行います。
        /// </summary>
        /// <param name="saibanKbn">採番区分</param>
        /// <param name="prefix">プレフィックス番号</param>
        /// <returns>納入書発注番号</returns>
        public String Get(String saibanKbn, String prefix)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            ObjectParameter no_saiban_param = new ObjectParameter("no_saiban", 0);
            String noSaiban = context.usp_cm_Saiban(saibanKbn, prefix, no_saiban_param).FirstOrDefault<String>();

            return noSaiban;
        }

        // GET
        /// <summary>
        /// クライアントから送信された条件を基に取引先情報を取得します。
        /// </summary>
        /// <param name="codes">検索条件コード</param>
        /// <param name="flgHin">品名選択のみフラグ</param>
        /// <param name="flgYotei">「予定なしも出力」フラグ</param>
        /// <returns>取引先情報</returns>
        public IEnumerable<usp_NonyuIraishoList_torihiki_select_Result> Get([FromUri]NonyuIraishoPdfCountCriteria criteria,
            String codes, short flgHin, short flgYotei)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_NonyuIraishoList_torihiki_select_Result> results;
            short mishiyoFlgShiyo = ActionConst.FlagFalse;

            // 検索処理の実行
            results = context.usp_NonyuIraishoList_torihiki_select(
                codes
                ,criteria.dateFrom
                ,criteria.dateTo
                ,criteria.sysdate
                ,flgYotei
                ,flgHin
                ,mishiyoFlgShiyo
                ,ActionConst.YoteiYojitsuFlag
                ,ActionConst.JissekiYojitsuFlag
            ).AsEnumerable();

            // 並び替え(取引先コードの昇順)
            results = results.OrderBy(key => key.cd_torihiki);

            return results;
        }

        // GET api/vw_tr_nonyu_01
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        /// <param name="skip">SKIP件数</param>
        /// <returns>検索結果</returns>
        public IEnumerable<usp_NonyuIraishoList_select_Result> Get([FromUri]NonyuIraishoPdfCountCriteria criteria, int skip) {
            // 変数宣言
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_NonyuIraishoList_select_Result> view;
            short mishiyoFlgShiyo = ActionConst.FlagFalse;

            // 検索処理の実行
            view = context.usp_NonyuIraishoList_select(
                criteria.dateFrom,
                criteria.dateTo,
                criteria.sysdate,
                ActionConst.YoteiYojitsuFlag,
                ActionConst.JissekiYojitsuFlag,
                mishiyoFlgShiyo,
                criteria.torihikiCode,
                ChangedNullToEmpty(criteria.hinCode)
                ,ActionConst.KgKanzanKbn
                ,ActionConst.LKanzanKbn
            ).AsEnumerable();

            // 「クエリの結果を複数回列挙できません」対策
            List<usp_NonyuIraishoList_select_Result> list
                = view.ToList<usp_NonyuIraishoList_select_Result>();
            IEnumerable<usp_NonyuIraishoList_select_Result> result;

            if (list.Count > skip)
            {
                // SKIP処理
                result = list.Skip(skip);
            }
            else
            {
                result = list.AsEnumerable();
            }

            return result;
        }
        
        /// <summary>「null」が文字列で入っていた場合、空文字に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        private string ChangedNullToEmpty(string value)
        {
            if (value == "null")
            {
                value = "";
            }
            return value;
        }
    }
}