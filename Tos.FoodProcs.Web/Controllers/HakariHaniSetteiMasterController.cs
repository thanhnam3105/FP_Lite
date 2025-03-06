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
    public class HakariHaniSetteiMasterController : ApiController
	{

        // POST api/ma_range
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_range> value)
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

            //// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<ma_range> duplicates = new DuplicateSet<ma_range>();

			// 変更セットを元に追加対象のエンティティを追加します。
			if (value.Created != null)
			{
                foreach (var created in value.Created)
                {
                    // エンティティにシーケンス番号が無かった場合、シーケンス番号取得のストアドプロシージャを実行します。
                    if (created.no_seq == null || created.no_seq == "")
                    {
                        // シーケンス番号を取得します。
                        ObjectParameter no_saiban_param = new ObjectParameter("no_saiban", 0);
                        String noSaiban = context.usp_cm_Saiban(
                            ActionConst.HakariSaibanKbn, ActionConst.HakariPrefixSaibanKbn, no_saiban_param).FirstOrDefault<String>();

                        // 取得したシーケンス番号を設定
                        created.no_seq = noSaiban;
                    }

                    // 作成日、更新日にUTCシステム日付を設定
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

                    // エンティティを追加します。
                    context.AddToma_range(created);
                }
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null)
			{
                // 後勝ちで更新
				foreach (var updated in value.Updated)
				{
                    // 既存エンティティを取得します。
                    ma_range current = GetSingleEntity(context, updated.no_seq);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, updated.ts))
                    { 
                        duplicates.Updated.Add(new Duplicate<ma_range>(updated, current));
                        continue;
                    }

                    // 既存エンティティの値を設定
                    updated.cd_create = current.cd_create;
                    updated.dt_create = current.dt_create;
                    // 更新日にUTCシステム日付を設定
                    updated.dt_update = DateTime.UtcNow;

                    // エンティティを更新します。
                    context.ma_range.ApplyOriginalValues(updated);
                    context.ma_range.ApplyCurrentValues(updated);
				}
			}

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    // 既存エンティティを取得します。
                    ma_range current = GetSingleEntity(context, deleted.no_seq);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_range>(deleted, current));
                        continue;
                    }

                    // エンティティを削除します。
                    context.DeleteObject(current);
                }
            }

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
            if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
            {
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_range>>(HttpStatusCode.Conflict, duplicates);
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
		/// <param name="key1">検索キー</param>
		/// <returns>既存エンティティ</returns>
        private ma_range GetSingleEntity(FoodProcsEntities context, String key1)
		{
            var result = context.ma_range.SingleOrDefault(ma => ma.no_seq == key1);

			return result;
		}

		/// <summary>
		///  タイムスタンプの値を比較します。
		/// </summary>
		/// <param name="left">値1</param>
		/// <param name="right">値2</param>
		/// <returns>比較結果</returns>
		private bool CompareByteArray(byte[] left, byte[] right) {
			if (left.Length != right.Length) {
				return false;
			}
			for (int i = 0; i < left.Length; i++) {
				if (left[i] != right[i]) {
					return false;
				}
			}
			return true;
		}
	}
}