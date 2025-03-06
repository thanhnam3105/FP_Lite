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
	public class TorihikisakiMasterController : ApiController
	{
		// POST api/ma_torihiki
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_torihiki> value)
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
		
			// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
			DuplicateSet<ma_torihiki> duplicates = new DuplicateSet<ma_torihiki>();

            // 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_torihiki> invalidations = new InvalidationSet<ma_torihiki>();

			// 変更セットを元に追加対象のエンティティを追加します。
			if (value.Created != null)
			{
				foreach (var created in value.Created)
				{
					// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKey(context, created);

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_torihiki>(validationMessage, created, Resources.NotExsists));
						continue;
					}
					
					// 新規作成時の取引先コード取得します。
                    string cd_target = created.cd_torihiki;

                    // 取引先コードの小文字を大文字に変換を行います。
                    created.cd_torihiki = cd_target.ToUpper();

					// エンティティを追加します。
					context.AddToma_torihiki(created);
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null)
			{
				foreach (var updated in value.Updated)
				{
					// 既存エンティティを取得します。
					ma_torihiki current = GetSingleEntity(context, updated.cd_torihiki);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
						duplicates.Updated.Add(new Duplicate<ma_torihiki>(updated, current));
						continue;
					}

                    // 既存データから登録日をコピー
                    updated.dt_create = current.dt_create;

                    // エンティティを更新します。
                    context.ma_torihiki.ApplyOriginalValues(updated);
                    context.ma_torihiki.ApplyCurrentValues(updated);
				}
			}

			// 変更セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    // 他マスタに存在する場合はエラー
                    validationMessage = ValidateMaKonyu(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_torihiki>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }

                    // 既存エンティティを取得します。
                    ma_torihiki current = GetSingleEntity(context, deleted.cd_torihiki);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_torihiki>(deleted, current));
                        continue;
                    }

                    // 削除用のストアドプロシージャを実行します。
                    context.DeleteObject(current);
                }
            }

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
			if (invalidations.Count > 0)
			{
				// エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSet<ma_torihiki>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				// エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_torihiki>>(HttpStatusCode.Conflict, duplicates);
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
		/// <param name="cd_torihiki">取引先マスタ情報</param>
		/// <returns>既存エンティティ</returns>
		private ma_torihiki GetSingleEntity(FoodProcsEntities context, string cd_torihiki)
		{
            var result = context.ma_torihiki.SingleOrDefault(ma => ma.cd_torihiki == cd_torihiki);

			return result;
		}

		/// <summary>
		/// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="torihiki">取引先マスタ情報</param>
		/// <returns>チェック結果</returns>
        private string ValidateKey(FoodProcsEntities context, ma_torihiki torihiki)
        {
            var master = (from m in context.ma_torihiki
                          where m.cd_torihiki == torihiki.cd_torihiki
                          select m).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }

        /// <summary>
        /// 整合性チェック：原資材購入先マスタ(ma_konyu)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="ma">対象のエンティティ</param>
        /// <returns>チェック結果</returns>
        private string ValidateMaKonyu(FoodProcsEntities context, ma_torihiki ma)
        {
            var master = (from m in context.ma_konyu
                          where m.cd_torihiki == ma.cd_torihiki
                          select m).FirstOrDefault();

            // 存在する場合、メッセージを返します
            string errMsg = getValidateErrorMassage(Resources.GenshizaiKonyusakiMaster, ma.cd_torihiki);
            return master != null ? errMsg : string.Empty;
        }

        /// <summary>
        /// 整合性チェックのエラーメッセージを返却します。
        /// フォーマット・・・MS0001 + スペース + コード： + 該当のコード
        /// </summary>
        /// <param name="tableName">対象のテーブル名</param>
        /// <param name="code">該当データのコード</param>
        /// <returns>エラーメッセージ</returns>
        private string getValidateErrorMassage(string tableName, string code)
        {
            return String.Format(Resources.MS0001, tableName)
                + ActionConst.StringSpace + ActionConst.StringSpace
                + Resources.Code + ActionConst.Colon + code;
        }

		/// <summary>
		/// タイムスタンプの値を比較します。
		/// </summary>
		/// <param name="left">比較値1</param>
		/// <param name="right">比較値2</param>
		/// <returns>チェック結果</returns>
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