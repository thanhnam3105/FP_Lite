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
    public class SokoMasterController : ApiController
	{
        // POST api/ZanTran
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_soko> value)
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
		
			// TODO: 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<ma_soko> duplicates = new DuplicateSet<ma_soko>();
			// TODO: ここまで
			// TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<ma_soko> invalidations = new InvalidationSet<ma_soko>();
			// TODO: ここまで

            // 重複チェック用：既存行のキーリスト
            List<dynamic> updateKeys = new List<dynamic>();
            List<dynamic> deleteKeys = new List<dynamic>();
            if (value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    AddKey(updateKeys, updated);
                }
            }
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
                    // 重複チェック：原価コードが重複していないこと
                    validationMessage = ValidateDuplicatKey(context, created, createKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_soko>(validationMessage, created, Resources.DuplicateKey));
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // 追加行内だけのキーをチェック用キーリストに追加
                    AddKey(createKeys, created);

                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

					// TODO: エンティティを追加します。
                    context.AddToma_soko(created);
					// TODO: ここまで
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip)
			{
				foreach (var updated in value.Updated)
				{
					// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = null;
					// TODO: ここまで

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        // TODO: ここまで
                        continue;
					}

                    updated.dt_update = DateTime.UtcNow;

					// TODO: 既存エンティティを取得します。
                    ma_soko current = GetSingleEntity(context, updated.cd_soko);
					// TODO: ここまで

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
                        duplicates.Updated.Add(new Duplicate<ma_soko>(updated, current));
						continue;
					}
                    updated.dt_create = current.dt_create;

                    // TODO: エンティティを更新します。
                    context.ma_soko.ApplyOriginalValues(updated);
                    context.ma_soko.ApplyCurrentValues(updated);
                    // TODO: ここまで
				}
			}

			// 変更セットを元に削除対象のエンティティを削除します。
			if (value.Deleted != null && !flgSkip)
			{
				foreach (var deleted in value.Deleted)
				{
                    // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateMasterTable(context, deleted);
                    // TODO: ここまで

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_soko>(validationMessage, deleted, Resources.UnDeletableRecord));
                        // TODO: ここまで
                        continue;
                    }

					// TODO: 既存エンティティを取得します。
                    ma_soko current = GetSingleEntity(context, deleted.cd_soko);
					// TODO: ここまで

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
					{
                        duplicates.Deleted.Add(new Duplicate<ma_soko>(deleted, current));
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
                return Request.CreateResponse<InvalidationSet<ma_soko>>(HttpStatusCode.BadRequest, invalidations);
				// TODO: ここまで
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				// TODO: エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_soko>>(HttpStatusCode.Conflict, duplicates);
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
        private ma_soko GetSingleEntity(FoodProcsEntities context, string cd_soko)
		{
            var result = context.ma_soko.SingleOrDefault(ma => ma.cd_soko == cd_soko);

			return result;
		}
		// TODO：ここまで

		// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        private string ValidateKey(FoodProcsEntities context, ma_soko soko)
        {
            var master = (from m in context.ma_soko
                          where m.cd_soko == soko.cd_soko
                          select m).FirstOrDefault();
            return master != null ? Resources.MS0027 : string.Empty;
        }

        /// <summary>
        /// 整合性チェック：対象のテーブルに存在する場合は削除不可
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="ma">対象のエンティティ</param>
        /// <returns>チェック結果</returns>
        private String ValidateMasterTable(FoodProcsEntities context, ma_soko ma)
        {
            /////// ラインマスタ(ma_line) ///////
            var maLocation = (from m in context.ma_location
                          where m.cd_soko == ma.cd_soko
                          select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maLocation != null)
            {
                return getValidateErrorMassage(Resources.LineMaster, ma.cd_soko);
            }

            // エラーなし：空文字を返却
            return string.Empty;
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

		// TODO：ここまで

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

        /// <summary>
        /// エンティティに対するキー情報を登録します。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象のレコード</param>
        private static void AddKey(List<dynamic> keys, ma_soko entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.cd_soko = entity.cd_soko;
            keys.Add(key);
        }

		/// <summary>
        /// 原価コードが重複していないこと。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="riyu">1レコード分のコメントマスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="delKeys">既存行の削除対象キーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_soko ma,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            var master = (from m in context.ma_soko
                          where m.cd_soko == ma.cd_soko
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
        /// 対象のキー(原価コード)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_soko entity)
        {
            return keys.Find(k => k.cd_soko == entity.cd_soko) != null;
        }
	}
}
