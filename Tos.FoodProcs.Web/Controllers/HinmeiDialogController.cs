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
    public class HinmeiDialogController : ApiController
	{
        // GET api/HinmeiDialog
        /// <summary>
        /// 【品名ダイアログ：品区分が「仕掛品」のときの検索処理】
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        /// <returns>検索結果</returns>
        public StoredProcedureResult<usp_HinmeiDialogShikakari_select_Result> Get([FromUri]HinmeiDialogCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド実行
            IEnumerable<usp_HinmeiDialogShikakari_select_Result> views;
            views = context.usp_HinmeiDialogShikakari_select(
                ActionConst.FlagFalse
                ,ActionConst.ShikakariHinKbn
                ,Resources.ShikakariHin
                ,criteria.flg_mishiyo_fukumu
                ,ChangedNullToEmpty(criteria.nm_hinmei)
                ,ChangedNullToEmpty(criteria.cd_bunrui)
            ).ToList();

            var result = new StoredProcedureResult<usp_HinmeiDialogShikakari_select_Result>();

            result.__count = ((List<usp_HinmeiDialogShikakari_select_Result>)views).Count;

            // 検索結果が取得最大件数を超えていた場合
            int maxCount = (int)criteria.top;
            if (result.__count > maxCount)
            {
                // 取得最大数以上の結果は削除する
                result.d = views.Take(maxCount);
            }
            else
            {
                result.d = views;
            }

            return result;
        }

        // GET api/HinmeiDialog
        /// <summary>
        /// 【品名ダイアログ：計画系の検索処理】
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        /// <param name="keikakuType">製品計画の場合は1、仕掛品計画の場合は2</param>
        /// <returns>検索結果</returns>
        public StoredProcedureResult<usp_HinmeiDialogKeikaku_select_Result> Get(
            [FromUri]HinmeiDialogCriteria criteria, short keikakuType)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド実行
            IEnumerable<usp_HinmeiDialogKeikaku_select_Result> views;
            views = context.usp_HinmeiDialogKeikaku_select(
                criteria.seizoDate
                ,criteria.lineCode
                ,criteria.shokubaCode
                ,criteria.kbn_hin
                ,ChangedNullToEmpty(criteria.nm_hinmei)
                ,criteria.flg_mishiyo_fukumu
                ,ActionConst.FlagFalse
                ,ActionConst.HinmeiMasterKbn
                ,ActionConst.HaigoMasterKbn
                ,criteria.lang
                ,keikakuType
                ,ChangedNullToEmpty(criteria.cd_bunrui)
            ).ToList();

            var result = new StoredProcedureResult<usp_HinmeiDialogKeikaku_select_Result>();

            result.__count = ((List<usp_HinmeiDialogKeikaku_select_Result>)views).Count;

            // 検索結果が取得最大件数を超えていた場合
            int maxCount = (int)criteria.top;
            if (result.__count > maxCount)
            {
                // 取得最大数以上の結果は削除する
                result.d = views.Take(maxCount);
            }
            else
            {
                result.d = views;
            }

            return result;
        }

        /// <summary>nullの場合、空文字に変更します。</summary>
        /// <param name="value">判定したい文字列</param>
        /// <returns>判定後の文字列</returns>
        private String ChangedNullToEmpty(string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                value = "";
            }
            return value;
        }
	}
}