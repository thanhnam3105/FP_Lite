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

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class HakariMasterController : ApiController
	{
        // POST api/ma_hakari
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_hakari> value)
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
		
            // TODO: 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<ma_hakari> duplicates = new DuplicateSet<ma_hakari>();
            // TODO: ここまで
            // TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<ma_hakari> invalidations = new InvalidationSet<ma_hakari>();
            // TODO: ここまで

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Created != null)
            {
                foreach (var created in value.Created)
                {
                    // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateNotExistKeys(context, created);
                    // TODO: ここまで

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_hakari>(validationMessage, created, Resources.NotExsists));
                        // TODO: ここまで
                        continue;
                    }

                    // TODO: エンティティを追加します。
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
                    context.AddToma_hakari(created);
                    // TODO: ここまで
                }
            }

            // 変更セットを元に更新対象のエンティティを更新します。
            if (value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateExistKeys(context, updated);
                    // TODO: ここまで

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_hakari>(validationMessage, updated, Resources.NotExsists));
                        // TODO: ここまで
                        continue;
                    }
                    // TODO: ここまで

                    // TODO: 既存エンティティを取得します。
                    ma_hakari current = GetSingleEntity(context, updated.cd_hakari);
                    // TODO: ここまで

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, updated.ts))
                    {                    
                        duplicates.Updated.Add(new Duplicate<ma_hakari>(updated, current));
                        continue;
                    }

                    // TODO: エンティティを更新します。
                    updated.dt_update = DateTime.UtcNow;
                    updated.dt_create = current.dt_create;
                    updated.cd_create = current.cd_create;
                    context.ma_hakari.ApplyOriginalValues(updated);
                    context.ma_hakari.ApplyCurrentValues(updated);
                    // TODO: ここまで
                }
            }

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    // 登録がない場合はエラー
                    validationMessage = ValidateExistKeys(context, deleted);
                    // TODO: ここまで

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_hakari>(validationMessage, deleted, Resources.UnDeletableRecord));
                        // TODO: ここまで
                        continue;
                    }

                    // 他マスタに存在する場合はエラー
                    // ma_panel存在チェック
                    validationMessage = ValidateMaPanel(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_hakari>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }
                    // tr_hakari_check存在チェック
                    validationMessage = ValidateTrHakariCheck(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_hakari>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }
                    // tr_kowake存在チェック
                    validationMessage = ValidateTrKowake(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_hakari>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }
                    // tr_zan_jiseki存在チェック
                    validationMessage = ValidateTrZanJiseki(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_hakari>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }
                    // TODO: ここまで

                    // TODO: 既存エンティティを取得します。
                    ma_hakari current = GetSingleEntity(context, deleted.cd_hakari);
                    // TODO: ここまで

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_hakari>(deleted, current));
                        continue;
                    }

                    // エンティティを削除します。
                    context.DeleteObject(current);
                }
            }


            // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
            // エラー情報を返します；。
            if (invalidations.Count > 0)
            {
                // TODO: エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSet<ma_hakari>>(HttpStatusCode.BadRequest, invalidations);
                // TODO: ここまで
            }

            // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
            // コンテントに競合したデータを設定します。
            if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
            {
                // TODO: エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_hakari>>(HttpStatusCode.Conflict, duplicates);
                // TODO: ここまで
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

        // TODO：既存エンティティを取得します。
        private ma_hakari GetSingleEntity(FoodProcsEntities context, string cd_hakari)
        {
            var result = context.ma_hakari.SingleOrDefault(ma => ma.cd_hakari == cd_hakari);

            return result;
        }
        // TODO：ここまで

        // TODO: エンティティに対する、マスタ非存在チェックを行います。
        private string ValidateNotExistKeys(FoodProcsEntities context, ma_hakari hakari)
        {
            var master = (from c in context.ma_hakari
                          where c.cd_hakari == hakari.cd_hakari
                          select c).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return master != null ? Resources.MS0027 : string.Empty;
        }
        // TODO：ここまで

        // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        private string ValidateExistKeys(FoodProcsEntities context, ma_hakari hakari)
        {
            var master = (from c in context.ma_hakari
                          where c.cd_hakari == hakari.cd_hakari
                          select c).FirstOrDefault();

            // 存在しない場合、メッセージを返します
            return master != null ? string.Empty :
                String.Format(Resources.ValidationDataNotFoundMessage, "秤コード", hakari.cd_hakari);
        }

        // TODO: エンティティに対する、マスタ非存在チェックを行います。
        // 他マスタに存在する場合はエラー
        // ma_panel 
        private string ValidateMaPanel(FoodProcsEntities context, ma_hakari hakari)
        {
            var master = (from m in context.ma_panel
                          where m.cd_hakari_1 == hakari.cd_hakari
                          || m.cd_hakari_2 == hakari.cd_hakari
                          select m).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return master != null ? String.Format(Resources.MS0001,"パネコン")  : string.Empty;
                      }
        // tr_hakari_check
        private string ValidateTrHakariCheck(FoodProcsEntities context, ma_hakari hakari)
        {
            var master = (from t in context.tr_hakari_check
                          where t.cd_hakari == hakari.cd_hakari
                          select t).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return master != null ? String.Format(Resources.MS0001, "秤点検") : string.Empty;
        }

        //　tr_kowake
        private string ValidateTrKowake(FoodProcsEntities context, ma_hakari hakari)
        {
            var master = (from t in context.tr_kowake
                          where t.cd_hakari == hakari.cd_hakari
                          select t).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return master != null ? String.Format(Resources.MS0001, "小分実績") : string.Empty;
        }
        //　tr_zan_jiseki
        private string ValidateTrZanJiseki(FoodProcsEntities context, ma_hakari hakari)
        {
            var master = (from t in context.tr_zan_jiseki
                          where t.cd_hakari == hakari.cd_hakari
                          select t).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return master != null ? String.Format(Resources.MS0001, "残実績") : string.Empty;
        }
        // TODO：ここまで

        
        // タイムスタンプの値を比較します。
        private bool CompareByteArray(byte[] left, byte[] right)
        {
            if (left.Length != right.Length)
            {
                return false;
            }
            for (int i = 0; i < left.Length; i++)
            {
                if (left[i] != right[i])
                {
                    return false;
                }
            }
            return true;
        }
	}
}