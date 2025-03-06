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
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class ShiyoJissekiIkkatsuDensoController : ApiController
	{
        // POST api/ShiyoJissekiIkkatsuDenso
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
        /// <param name="startDate">伝送開始日</param>
        /// <param name="endDate">伝送終了日</param>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="user">ユーザーID</param>
		public HttpResponseMessage Post([FromUri]DateTime startDate, DateTime endDate, string lang, string user)
		{
            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;
            // TODO：タイムアウト時間変更(0=無限)
            //context.CommandTimeout = 0;

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
                        // 使用実績一括伝送 更新処理のストアドプロシージャを実行します。
                        context.usp_ShiyoJiossekiIkkatsuDenso_update(
                            startDate
                            , endDate
                            , ActionConst.densoJotaiKbnDensomachi
                            , ActionConst.densoJotaiKbnMidenso
                        );

                        context.SaveChanges();
                        transaction.Commit();
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
                        // 楽観排他制御 (データベース上の timestamp 列による多ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                        return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                    }
                    catch (Exception e)
                    {
                        Logger.App.Error(Resources.ServiceErrorForClient, e);
                        Exception serviceError = new Exception(Resources.ServiceErrorForClient, e);
                        return Request.CreateResponse(HttpStatusCode.BadRequest, serviceError);
                    }
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK);
		}
	}
}