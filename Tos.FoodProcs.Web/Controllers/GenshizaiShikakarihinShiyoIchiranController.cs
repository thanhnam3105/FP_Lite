using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class GenshizaiShikakarihinShiyoIchiranController : ApiController
    {
        // GET api/GenshizaiShikakarihinShiyoIchiranController
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        public StoredProcedureResult<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> Get(
            [FromUri]GenshizaiShikakarihinShiyoIchiranCriteria criteria)
        {
            ///// 検索処理の実行
            IEnumerable<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> views;
            views = GetSelectResult(criteria);

            ///// 検索結果の作成
            var result = new StoredProcedureResult<usp_GenshizaiShikakarihinShiyoIchiran_select_Result>();

            // 「クエリの結果を複数回列挙できません」対策
            List<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> list
                = views.ToList<usp_GenshizaiShikakarihinShiyoIchiran_select_Result>();

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

        /// <summary>
        /// 検索処理の実行。
        /// 検索条件/品区分によって実行するストアドを変更する。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        private IEnumerable<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> GetSelectResult(
            GenshizaiShikakarihinShiyoIchiranCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
            // TODO：タイムアウト時間変更(0=無限)
            context.CommandTimeout = 0;

            IEnumerable<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> views;

            ///// 検索処理の実行
            if (ActionConst.ShizaiHinKbn.Equals(criteria.kbn_hin))
            {
                // 検索条件/品区分が「資材」だった場合
                views = context.usp_GenshizaiShikakarihinShiyoIchiran_shizai_select(
                    criteria.kbn_hin,
                    changedNullToEmpty(criteria.bunrui),
                    changedNullToEmpty(criteria.hinmei),
                    criteria.dt_from,
                    criteria.lang,
                    ActionConst.SeihinHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    //criteria.today
                    criteria.shiyoMishiyoFlag
                    ).ToList();
            }
            else if (ActionConst.ShikakariHinKbn.Equals(criteria.kbn_hin))
            {
                // 検索条件/品区分が「仕掛品」だった場合
                views = context.usp_GenshizaiShikakarihinShiyoIchiran_shikakari_select(
                    criteria.kbn_hin,
                    changedNullToEmpty(criteria.bunrui),
                    changedNullToEmpty(criteria.hinmei),
                    criteria.dt_from,
                    criteria.lang,
                    ActionConst.SeihinHinKbn,
                    ActionConst.ShikakariHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    //criteria.today
                    criteria.shiyoMishiyoFlag
                    ).ToList();
            }
            else
            {
                // 上記以外（検索条件/品区分が「原料」または「自家原料」）
                views = context.usp_GenshizaiShikakarihinShiyoIchiran_select(
                    criteria.kbn_hin,
                    changedNullToEmpty(criteria.bunrui),
                    changedNullToEmpty(criteria.hinmei),
                    criteria.dt_from,
                    criteria.lang,
                    ActionConst.SeihinHinKbn,
                    ActionConst.ShikakariHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    //criteria.today
                    criteria.shiyoMishiyoFlag
                    ).ToList();
            }

            return views;
        }

        /// <summary>nullの場合、空文字に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        private String changedNullToEmpty(String value)
        {
            if (String.IsNullOrEmpty(value) || value == "null")
            {
                value = "";
            }
            return value;
        }
	}
}