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
	public class KaishaMasterController : ApiController
	{
		// POST api/ma_kaisha
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_kaisha> value)
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
			DuplicateSet<ma_kaisha> duplicates = new DuplicateSet<ma_kaisha>();
			// TODO: ここまで
			// TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_kaisha> invalidations = new InvalidationSet<ma_kaisha>();
			// TODO: ここまで

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null)
			{
				foreach (var updated in value.Updated)
				{
					// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = string.Empty;
					// TODO: ここまで

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        //invalidations.Add(new Invalidation<ma_kaisha>(validationMessage, updated, Resources.NotExsists));
                        // TODO: ここまで
						continue;
					}

					// TODO: 既存エンティティを取得します。
					ma_kaisha current = GetSingleEntity(context, updated.cd_kaisha);
					// TODO: ここまで

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
						duplicates.Updated.Add(new Duplicate<ma_kaisha>(updated, current));
						continue;
					}

                    updated.dt_update = DateTime.UtcNow;
                    // TODO: エンティティを更新します。
                    context.ma_kaisha.ApplyOriginalValues(updated);
                    context.ma_kaisha.ApplyCurrentValues(updated);
                    // TODO: ここまでTOs10s

				}
			}

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
			if (invalidations.Count > 0)
			{
				// TODO: エンティティの型に応じたInvalidationSetを返します。
				return Request.CreateResponse<InvalidationSet<ma_kaisha>>(HttpStatusCode.BadRequest, invalidations);
				// TODO: ここまで
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Updated.Count > 0)
			{
				// TODO: エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_kaisha>>(HttpStatusCode.Conflict, duplicates);
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
            //return Request.CreateResponse<InvalidationSet<ma_kaisha>>(HttpStatusCode.BadRequest, invalidations);
		}

		// TODO：既存エンティティを取得します。
		private ma_kaisha GetSingleEntity(FoodProcsEntities context, string cd_kaisha)
		{
            var result = context.ma_kaisha.SingleOrDefault(ma => ma.cd_kaisha == cd_kaisha);

			return result;
		}
		// TODO：ここまで

		// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        private string ValidateKey(FoodProcsEntities context, ma_kaisha kaisha)
        {
            var master = (from m in context.ma_kaisha
                          where m.cd_kaisha == kaisha.cd_kaisha
                          select m).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }
		// TODO：ここまで

		// タイムスタンプの値を比較します。
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