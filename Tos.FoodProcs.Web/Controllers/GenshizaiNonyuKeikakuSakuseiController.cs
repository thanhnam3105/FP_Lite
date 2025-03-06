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
    public class GenshizaiNonyuKeikakuSakuseiController : ApiController
	{
        // POST api/GenshizaiNonyuKeikakuSakusei
		/// <summary>
		/// クライアントから送信された条件を基に計算在庫を作成し、
        /// 対象品名コードの最低在庫未満のデータを抽出する。
        /// 抽出したデータを基にして納入予定を作成する。
		/// </summary>
		/// <param name="dtFrom">変動計算初日</param>
		/// <param name="dtTo">変動計算末日</param>
		/// <param name="hinCd">選択された品名コード</param>
		/// <param name="user">ユーザーコード</param>
		/// <param name="leadtime">任意のリードタイム(納入日を設定する際に使用)</param>
		/// <param name="sysdate">UTCに変換済みのシステム日付</param>
		// [Authorize(Roles="")]
        public HttpResponseMessage Post(
            DateTime dtFrom, DateTime dtTo, string hinCd, string user, decimal leadtime, DateTime sysdate)
		{
			//string validationMessage = string.Empty;

            string skipCode = "";
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
                        string hinCode = FoodProcsCommonUtility.changedNullToEmpty(hinCd);
                        short flg_shiyo = ActionConst.FlagFalse;             // 未使用フラグ：使用
                        short flg_heijitsu = ActionConst.FlagFalse;          // 休日フラグ：平日
                        short flg_mikakutei = ActionConst.FlagFalse;         // 確定フラグ：未確定
                        short kbn_denso_taishogai = ActionConst.FlagFalse;   // KSYS伝送区分：伝送対象外

                        // 納入トランを削除して、計算在庫を再計算
                        //context.usp_GenshizaiNonyuKeikaku_KeisanZaiko(
                        //    hinCode
                        //    ,dtFrom
                        //    ,dtTo
                        //    ,user
                        //    ,flg_shiyo
                        //    ,ActionConst.YoteiYojitsuFlag
                        //    ,ActionConst.JissekiYojitsuFlag
                        //    ,ActionConst.GenryoHinKbn
                        //    ,ActionConst.ShizaiHinKbn
                        //    ,ActionConst.KgKanzanKbn
                        //    ,ActionConst.LKanzanKbn
                        //    ,sysdate
                        //);

                        // 納入計画作成処理
                        skipCode = context.usp_GenshizaiNonyuKeikakuSakusei_create(
                            dtFrom
                            , dtTo
                            , hinCode
                            , flg_shiyo
                            , flg_heijitsu
                            , ActionConst.YoteiYojitsuFlag
                            , ActionConst.JissekiYojitsuFlag
                            , ActionConst.NonyuSaibanKbn
                            , ActionConst.NonyuPrefixSaibanKbn
                            , kbn_denso_taishogai
                            , flg_mikakutei
                            , ActionConst.GenryoHinKbn
                            , ActionConst.ShizaiHinKbn
                            , user
                            , leadtime
                            , ActionConst.KgKanzanKbn
                            , ActionConst.LKanzanKbn
                            , sysdate
                        ).FirstOrDefault<String>();

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
                    catch (Exception e)
                    {
                        //return Request.CreateErrorResponse(HttpStatusCode.ExpectationFailed, e);
                        Exception serviceError = new Exception(Resources.ServiceErrorForClient, e);
                        return Request.CreateResponse(HttpStatusCode.BadRequest, serviceError);
                    }
                }
			}
			return Request.CreateResponse(HttpStatusCode.OK, skipCode);
		}

        /// <summary>
        /// 納入計画作成前に、計算在庫の再計算処理を行う。
        /// </summary>
        /// <param name="dtFrom">計算開始日</param>
        /// <param name="dtTo">計算終了日</param>
        /// <param name="hinCd">検索条件：品名コード</param>
        /// <param name="user">ログインユーザーID</param>
        /// <param name="sysdate">現地の当日日付</param>
        /// <returns>処理結果</returns>
        public HttpResponseMessage Post(DateTime dtFrom, DateTime dtTo, string hinCd, string user, DateTime today,
            DateTime dtHendoFrom, DateTime dtHendoTo)
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
                        string hinCode = FoodProcsCommonUtility.changedNullToEmpty(hinCd);
                        short flg_shiyo = ActionConst.FlagFalse;             // 未使用フラグ：使用
                        short flg_heijitsu = ActionConst.FlagFalse;          // 休日フラグ：平日
                        short flg_mikakutei = ActionConst.FlagFalse;         // 確定フラグ：未確定
                        short kbn_denso_taishogai = ActionConst.FlagFalse;   // KSYS伝送区分：伝送対象外

                        // 納入トランを削除して、計算在庫を再計算
                        context.usp_GenshizaiNonyuKeikaku_KeisanZaiko(
                            hinCode
                            ,dtFrom
                            ,dtTo
                            ,user
                            ,flg_shiyo
                            ,ActionConst.YoteiYojitsuFlag
                            ,ActionConst.JissekiYojitsuFlag
                            ,ActionConst.GenryoHinKbn
                            ,ActionConst.ShizaiHinKbn
                            ,ActionConst.KgKanzanKbn
                            ,ActionConst.LKanzanKbn
                            ,today
                            ,ActionConst.kbn_zaiko_ryohin
                            ,dtHendoFrom
                            ,dtHendoTo
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
                    catch (Exception e)
                    {
                        //return Request.CreateErrorResponse(HttpStatusCode.ExpectationFailed, e);
                        Exception serviceError = new Exception(Resources.ServiceErrorForClient, e);
                        return Request.CreateResponse(HttpStatusCode.BadRequest, serviceError);
                    }
				}
			}
			return Request.CreateResponse(HttpStatusCode.OK);
		}
    }
}