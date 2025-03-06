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
    public class KeikokuListSakuseiController : ApiController
	{
        // GET api/KeikokuListSakuseiController
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_KeikokuListSakusei_select_Result> Get([FromUri]KeikokuListSakuseiCriteria criteria) {
            FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
            // TODO：タイムアウト時間変更(0=無限)
            context.CommandTimeout = 0;

            // 終了日が1970/1/1以下の場合、nullとする
            DateTime minDate = DateTime.Parse("1970/01/01");
            DateTime? endDate = criteria.con_dt_end;
            if (endDate < minDate)
            {
                endDate = null;
            }

            IEnumerable<usp_KeikokuListSakusei_select_Result> views;
            views = context.usp_KeikokuListSakusei_select(
                    criteria.con_hizuke,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kubun),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kurabasho),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei),
                    criteria.con_keikoku_list,
                    criteria.con_zaiko_max_flg,
                    criteria.lang,
                    criteria.today,
                    ActionConst.FlagFalse,
                    ActionConst.YoteiYojitsuFlag,
                    ActionConst.JissekiYojitsuFlag,
                    ActionConst.GenryoHinKbn,
                    ActionConst.ShizaiHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    endDate,
                    criteria.all_genshizai,
                    criteria.flg_leadtime,
                    ActionConst.KgKanzanKbn,
                    ActionConst.LKanzanKbn
                ).AsEnumerable();
            
            return views;
        }

        /// <summary>
        /// 納入リードタイムを加味した計算在庫の計算処理を行う。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        /// <param name="userCode">ログインユーザーコード</param>
        /// <returns>処理結果</returns>
        public HttpResponseMessage Post([FromUri]KeikokuListSakuseiCriteria criteria, string userCode)
		{
			FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
            // TODO：タイムアウト時間変更(0=無限)
            context.CommandTimeout = 0;

            // トランザクションを開始し、エンティティの変更をデータベースに反映します。
			// 更新処理に失敗した場合、例外が発生し、トランザクションは暗黙的にロールバックされます。
			// 個別でチェック処理を行いロールバックを行う場合には明示的に
			// IDbTransaction インタフェースの Rollback メソッドを呼び出します。
			using (IDbConnection connection = context.Connection)
			{
				context.Connection.Open();
				using (IDbTransaction transaction = context.Connection.BeginTransaction())
				{
                    try
                    {
                        short flg_shiyo = ActionConst.FlagFalse;             // 未使用フラグ：使用

                        // 納入トランを削除して、計算在庫を再計算
                        context.usp_KeikokuList_NonyuLeadZaiko(
                            criteria.con_hizuke
                            , criteria.con_dt_end
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kubun)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kurabasho)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei)
                            , criteria.lang
                            , userCode
                            , flg_shiyo
                            , ActionConst.YoteiYojitsuFlag
                            , ActionConst.JissekiYojitsuFlag
                            , ActionConst.GenryoHinKbn
                            , ActionConst.ShizaiHinKbn
                            , ActionConst.JikaGenryoHinKbn
                            , ActionConst.KgKanzanKbn
                            , ActionConst.LKanzanKbn
                            , criteria.today
                            , ActionConst.kbn_zaiko_ryohin
                        );

                        //context.SaveChanges();
                        transaction.Commit();
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
                        // 楽観排他制御 (データベース上の timestamp 列による多ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                        return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                    }
                    catch (Exception oex)
                    {
                        Logger.App.Error(Resources.ServiceErrorForClient, oex);
                        transaction.Commit();
                        Exception serviceError = new Exception(Resources.ServiceErrorForClient, oex);
                        return Request.CreateResponse(HttpStatusCode.BadRequest, serviceError);
                    }
				}
			}
			return Request.CreateResponse(HttpStatusCode.OK);
		}
	}
}