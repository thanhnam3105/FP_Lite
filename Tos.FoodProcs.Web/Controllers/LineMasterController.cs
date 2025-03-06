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
using System.Data.Objects;
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class LineMasterController : ApiController
	{
		// POST api/ma_line
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_line> value)
		{
			string validationMessage = string.Empty;
            bool flgSkip = false;   // 処理をスキップするかどうか
		
			// パラメータのチェックを行います。
			if (value == null)
			{
				return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
			}

			FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
		
			// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
			DuplicateSet<ma_line> duplicates = new DuplicateSet<ma_line>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_line> invalidations = new InvalidationSet<ma_line>();

            // 重複チェック用：既存行のキーリスト
            List<dynamic> deleteKeys = new List<dynamic>();
            if (value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    AddKey(deleteKeys, deleted);
                }
            }

			// 変更セットを元に追加対象のエンティティを追加します。
			if (value.Created != null)
			{
                List<dynamic> createKeys = new List<dynamic>();   // 重複チェック用：追加対象キーリスト

				foreach (var created in value.Created)
				{
					// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateDuplicatKey(context, created, createKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_line>(validationMessage, created, Resources.DuplicateKey));
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    AddKey(createKeys, created);

                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
					// エンティティを追加します。
                    context.AddToma_line(created);
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip)
			{
				foreach (var updated in value.Updated)
				{
					// 既存エンティティを取得します。
					ma_line current = GetSingleEntity(context, updated.cd_line);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
						duplicates.Updated.Add(new Duplicate<ma_line>(updated, current));
						continue;
					}

                    updated.dt_update = DateTime.UtcNow;
                    // エンティティを更新します。
                    context.ma_line.ApplyOriginalValues(updated);
                    context.ma_line.ApplyCurrentValues(updated);
				}
			}

			// 変更セットを元に削除対象のエンティティを削除します。
			if (value.Deleted != null && !flgSkip)
			{
				foreach (var deleted in value.Deleted)
				{
					// 既存エンティティを取得します。
					ma_line current = GetSingleEntity(context, deleted.cd_line);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
					{
						duplicates.Deleted.Add(new Duplicate<ma_line>(deleted, current));
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
				// エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSet<ma_line>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				// エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_line>>(HttpStatusCode.Conflict, duplicates);
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
        /// エンティティに対するキー情報を登録します。
        /// </summary>
        /// <param name="keys">キー情報</param>
        /// <param name="created">対象のエンティティ</param>
        private static void AddKey(List<dynamic> keys, ma_line created)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.cd_line = created.cd_line;

            keys.Add(key);
        }

        /// <summary>
        /// 対象のキーを持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キー情報</param>
        /// <param name="created">対象のエンティティ</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_line created)
        {
            return keys.Find(k => k.cd_line == created.cd_line) != null;
        }

		/// <summary>
		/// 既存エンティティを取得します。
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="cd_line">ラインコード</param>
		/// <returns>既存エンティティ</returns>
		private ma_line GetSingleEntity(FoodProcsEntities context, string cd_line)
		{
			var result = context.ma_line.SingleOrDefault(ma => ma.cd_line == cd_line);

			return result;
		}

		/// <summary>
        /// ラインコードが重複していないこと。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="riyu">1レコード分のコメントマスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="delKeys">既存行の削除対象キーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_line ma,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            var master = (from m in context.ma_line
                          where m.cd_line == ma.cd_line
                          select m).FirstOrDefault();

            if (master != null)
            {
                // キーリストにない かつ 削除対象に存在する場合はエラーとしない
                if (!ContainsKey(keys, ma) && ContainsKey(delKeys, ma))
                {
                    return String.Empty;
                }
                return errMsg;
            }
            else if (ContainsKey(keys, ma))
            {
                return errMsg;
            }

            return string.Empty;
        }

		/// <summary>
		/// タイムスタンプの値を比較します。
		/// </summary>
		/// <param name="left">比較値1</param>
		/// <param name="right">比較値2</param>
		/// <returns>チェック結果</returns>
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