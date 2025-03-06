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

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class GenkaTankaSakuseiController : ApiController {

		// POST api/GenkaTankaSakusei
		/// <summary>
		/// クライアントから送信された作成条件を基に原価単価の作成処理を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromUri]GenkaKeisanCriteria criteria) {
			string validationMessage = string.Empty;
			InvalidationSet<tr_keikaku_seihin> invalidations = new InvalidationSet<tr_keikaku_seihin>();

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
                        // 作成処理の実行
                        context.usp_GenkaTanka_create(
                            criteria.dt_from
                            , criteria.dt_to
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.kbn_hin)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_bunrui)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_hinmei)
                            , ActionConst.YoteiYojitsuFlag
                            , ActionConst.JissekiYojitsuFlag
                            , ActionConst.KgKanzanKbn
                            , ActionConst.LKanzanKbn
                            , ActionConst.FlagFalse
                            , ActionConst.TanaoroshiTankaKbn
                            , ActionConst.NonyuTankaKbn
                            , ActionConst.RomuhiTankaKbn
                            , ActionConst.KeihiTankaKbn
                            , ActionConst.CsTankaTankaKbn
                            , ActionConst.SeihinHinKbn
                            , ActionConst.JikaGenryoHinKbn
                            , criteria.max_genka
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
                }
            }
			return Request.CreateResponse(HttpStatusCode.OK);
		}
	}
}