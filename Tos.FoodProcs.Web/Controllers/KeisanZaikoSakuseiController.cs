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
    public class KeisanZaikoSakuseiController : ApiController
	{
        // POST api/KeisanZaikoSakuseiController
		/// <summary>
		/// クライアントから送信された条件を基に計算在庫を作成し、
        /// 対象品名コードの最低在庫未満のデータを抽出する。
        /// 抽出したデータを基にして納入予定を作成する。
		/// </summary>
		/// <param name="dtFrom">変動計算初日</param>
		/// <param name="dtTo">変動計算末日</param>
		/// <param name="hinCd">選択された品名コード</param>
		/// <param name="user">ユーザーコード</param>
		/// <param name="today">UTCシステム日付</param>
		// [Authorize(Roles="")]
        public HttpResponseMessage Post([FromUri]KeisanZaikoSakuseiCriteria criteria)
		{
			//string validationMessage = string.Empty;

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
                        // SET ARITHABORT：ONにすると、クエリ実行中にオーバーフローまたは 0 除算のエラーが発生した場合にクエリを終了する
                        // 　Management StudioではデフォルトONだが、Ado.netではOFFの為、この差異により実行プランが異なり
                        // 　その結果、処理速度に変化が発生することがある。
                        // ストアド内に直接「SET ARITHABORT ON」を記述してもOK？検証中(2014/10/07 tsujita)
                        //context.ExecuteStoreCommand("SET ARITHABORT ON");

                        // ↓の書き方は×　ExecuteNonQueryで落ちる(「クエリ構文が無効です」と言われる)
                        //var command = connection.CreateCommand();
                        //command.Transaction = transaction;
                        //command.CommandText = "SET ARITHABORT ON";
                        //command.ExecuteNonQuery();

                        short flg_shiyo = ActionConst.FlagFalse;             // 未使用フラグ：使用

                        // 計算在庫作成処理のストアドプロシージャを実行します。
                        context.usp_KeisanZaiko_create(
                            FoodProcsCommonUtility.changedNullToEmpty(criteria.hinCd)
                            , criteria.dtFrom
                            , criteria.dtTo
                            , criteria.user
                            , flg_shiyo
                            , ActionConst.YoteiYojitsuFlag
                            , ActionConst.JissekiYojitsuFlag
                            , ActionConst.GenryoHinKbn
                            , ActionConst.ShizaiHinKbn
                            , ActionConst.JikaGenryoHinKbn
                            , ActionConst.KgKanzanKbn
                            , ActionConst.LKanzanKbn
                            , criteria.today
                            , criteria.lang
                            , criteria.con_kbn_hin
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kurabasho)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_nm_hinmei)
                            , ActionConst.kbn_zaiko_ryohin
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