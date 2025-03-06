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
    public class GenshizaiZaikoNyuryokuZaikoRetrasmitController : ApiController
    {
        // GET api/GenshizaiZaikoNyuryokuZaikoRetrasmit
        /// <summary>
        /// 次の２つの操作を行う。
        /// 　１：クライアントから送信された検索条件(日付)を基に前回在庫伝送データを削除。
        /// 　２：在庫伝送バッチのコードを引数指定して、バッチ起動SPを起動。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public HttpResponseMessage Post([FromUri]GenshizaiZaikoNyuryokuZaikoRetrasmitCriteria criteria)
        {
            // パラメータチェック
            if (criteria == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            /* トランザクションの貼り方にミスがあるのでコメントアウト */
            //FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            //context.ContextOptions.LazyLoadingEnabled = false;

            // トランザクションを開始し、エンティティの変更をデータベースに反映します。
            // 削除処理に失敗した場合、例外が発生し、トランザクションは暗黙的にロールバックされます。
            // 個別でチェック処理を行いロールバックを行う場合には明示的に
            // IDbTransaction インタフェースの Rollback メソッドを呼び出します。
            //context.usp_GetsumatsuZaikoDensoTaishoZen_delete(criteria.con_dt_zaiko);
            //using (IDbConnection connection = context.Connection)
            //{
            //    context.Connection.Open();
            //    using (IDbTransaction transaction = context.Connection.BeginTransaction())
            //    {
            //        try
            //        {
            //            context.SaveChanges();
            //            transaction.Commit();
            //        }
            //        catch (OptimisticConcurrencyException oex)
            //        {
            //            // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
            //            // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
            //            Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
            //            return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
            //        }
            //    }
            //}
            //削除完了
            //return Request.CreateResponse(HttpStatusCode.OK);            

            FoodProcsEntities context = new FoodProcsEntities();
            context.Connection.Open();
            // トランザクションを開始する
            using (IDbTransaction transaction = context.Connection.BeginTransaction())
            {
                try
                {
                    ///* 前回在庫送信データ削除処理 */
                    //context.usp_GetsumatsuZaikoDensoTaishoZen_delete(criteria.con_dt_zaiko);

                    // 伝送対象データ抽出
                    context.usp_sap_getsumatsu_zaiko_denso_taisho_create(
                            criteria.kbnCreate,
                            criteria.kbnUpdate,
                            criteria.kbnDelete,
                            criteria.flgTrue,
                            criteria.flgFalse,
                            criteria.kbnGenryo,
                            criteria.kbnShizai,
                            criteria.kbnJikagen,
                            criteria.kbnZaiko,
                            criteria.con_dt_zaiko
                        );

                    /* DBのこれまでの変更を確定する */
                    transaction.Commit();
                }
                catch (OptimisticConcurrencyException oex)
                {
                    // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
                    // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                    Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                    return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                }
                catch (Exception ex)
                {
                    // SP正常起動の失敗他
                    Logger.App.Error(Properties.Resources.ServiceError, ex);
                    return Request.CreateErrorResponse(HttpStatusCode.InternalServerError, Properties.Resources.ServiceErrorForClient);
                }
            }
            //処理完了
            return Request.CreateResponse(HttpStatusCode.OK);
        }

    }
}