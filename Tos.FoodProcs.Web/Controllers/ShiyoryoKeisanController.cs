using System;
using System.Collections.Generic;
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
    public class ShiyoryoKeisanController : ApiController
    {
        // GET api/ShiyoryoKeisan
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_GenshizaiShiyoryoKeisan_select_Result> Get([FromUri]GenshizaiShiyoryoKeisanCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiShiyoryoKeisan_select_Result> views;
            views = context.usp_GenshizaiShiyoryoKeisan_select(
                criteria.con_hizuke,
                FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui),
                criteria.hinKubun,
                criteria.flg_yojitsu,
                ActionConst.FlagFalse,
                ActionConst.GenryoHinKbn,
                ActionConst.ShizaiHinKbn,
                ActionConst.JikaGenryoHinKbn,
                ActionConst.LKanzanKbn,
                criteria.utc
            ).AsEnumerable();
            return views;
        }

        // POST api/tr_kuradashi
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<tr_kuradashi> value)
        {
            string validationMessage = string.Empty;
            // パラメータのチェックを行います。
            if (value == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Created != null)
            {
                // 後勝ちで更新
                foreach (var created in value.Created)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateExists(context, created);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // データが存在したら、更新処理
                        tr_kuradashi current = GetSingleEntity(context, created.dt_hizuke, created.cd_hinmei);
                        created.dt_update = DateTime.UtcNow;
                        created.dt_create = current.dt_create;
                        created.cd_create = current.cd_create;

                        // エンティティの更新処理
                        context.tr_kuradashi.ApplyOriginalValues(created);
                        context.tr_kuradashi.ApplyCurrentValues(created);
                    }
                    else
                    {
                        // 値が存在しなかったら、新規作成
                        // エンティティを追加します。
                        created.dt_update = DateTime.UtcNow;
                        created.dt_create = DateTime.UtcNow;
                        context.AddTotr_kuradashi(created);
                    }
                }
            }

            // 変更セットを元に更新対象のエンティティを更新します。
            if (value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateNotExists(context, updated);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // データを新規作成
                        updated.dt_update = DateTime.UtcNow;
                        updated.dt_create = DateTime.UtcNow;
                        updated.cd_create = updated.cd_create;
                        context.AddTotr_kuradashi(updated);
                    }
                    else
                    {
                        // 既存エンティティを取得します。
                        tr_kuradashi current = GetSingleEntity(context, updated.dt_hizuke, updated.cd_hinmei);
                        updated.dt_update = DateTime.UtcNow;
                        updated.dt_create = current.dt_create;
                        updated.cd_create = current.cd_create;

                        // エンティティを更新します。
                        context.tr_kuradashi.ApplyOriginalValues(updated);
                        context.tr_kuradashi.ApplyCurrentValues(updated);
                    }
                }
            }

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
                        context.SaveChanges();
                        transaction.Commit();
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
                        // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                        return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                    }
                }
            }

            return Request.CreateResponse(HttpStatusCode.OK);
        }

        /// <summary>
        /// 既存エンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="key1">検索キー：日付</param>
        /// <param name="key2">検索キー：品名コード</param>
        /// <returns>既存エンティティ</returns>
        private tr_kuradashi GetSingleEntity(FoodProcsEntities context, DateTime key1, string key2)
        {
            var result = context.tr_kuradashi.SingleOrDefault(tr => tr.dt_hizuke == key1
                                                              && tr.cd_hinmei == key2);

            return result;
        }

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ非存在チェック) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="entity">庫出トラン</param>
        /// <returns>存在したらfalse</returns>
        private string ValidateExists(FoodProcsEntities context, tr_kuradashi entity)
        {
            var tran = (from t in context.tr_kuradashi
                        where t.dt_hizuke == entity.dt_hizuke
                              && t.cd_hinmei == entity.cd_hinmei
                        select t).FirstOrDefault();

            // 存在したらfalse
            return tran == null ? string.Empty :
                String.Format(Resources.ValidationDataNotFoundMessage, "", entity.cd_hinmei);
        }

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ存在チェック) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="entity">庫出トラン</param>
        /// <returns>存在しなかったらfalse</returns>
        private string ValidateNotExists(FoodProcsEntities context, tr_kuradashi entity)
        {
            var tran = (from t in context.tr_kuradashi
                        where t.dt_hizuke == entity.dt_hizuke
                              && t.cd_hinmei == entity.cd_hinmei
                        select t).FirstOrDefault();

            // 存在しなかったらfalse
            return tran != null ? string.Empty :
                String.Format(Resources.ValidationDataNotFoundMessage, "", entity.cd_hinmei);
        }
    }
}