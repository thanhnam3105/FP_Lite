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
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class KurabashoMasterController : ApiController
	{
		// POST api/ma_kura
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_kura> value)
		{
			FoodProcsEntities context = new FoodProcsEntities();
			string validationMessage = string.Empty;
            bool flgSkip = false;   // 処理をスキップするかどうか
		
			// パラメータのチェックを行います。
			if (value == null)
			{
				return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
			}

            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
		
			// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
			DuplicateSet<ma_kura> duplicates = new DuplicateSet<ma_kura>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_kura> invalidations = new InvalidationSet<ma_kura>();

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
                    // 重複チェック：庫場所コードが重複していないこと
                    validationMessage = ValidateDuplicatKey(context, created, createKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_kura>(validationMessage, created, Resources.DuplicateKey));
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // 追加行内だけのキーをチェック用キーリストに追加
                    AddKey(createKeys, created);

                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
					// エンティティを追加します。
                    context.AddToma_kura(created);
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip)
			{
				foreach (var updated in value.Updated)
				{
					// 既存エンティティを取得します。
                    ma_kura current = GetSingleEntity(context, updated.cd_kura);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
						duplicates.Updated.Add(new Duplicate<ma_kura>(updated, current));
						continue;
					}

                    updated.dt_create = current.dt_create;
                    updated.cd_create = current.cd_create;
                    updated.dt_update = DateTime.UtcNow;
                    // エンティティを更新します。
                    context.ma_kura.ApplyOriginalValues(updated);
                    context.ma_kura.ApplyCurrentValues(updated);
				}
			}

			// 変更セットを元に削除対象のエンティティを削除します。
			if (value.Deleted != null && !flgSkip)
			{
				foreach (var deleted in value.Deleted)
				{
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    // 登録がない場合はエラー
                    validationMessage = ValidateExistKeys(context, deleted);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_kura>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }

                    // 他マスタに存在する場合はエラー
                    // ma_hinmei存在チェック
                    validationMessage = ValidateMaHinmei(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_kura>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }

                    // 既存エンティティを取得します。
                    ma_kura current = GetSingleEntity(context, deleted.cd_kura);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
					{
						duplicates.Deleted.Add(new Duplicate<ma_kura>(deleted, current));
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
				return Request.CreateResponse<InvalidationSet<ma_kura>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				var jsonFormatter = GlobalConfiguration.Configuration.Formatters.JsonFormatter;
				jsonFormatter.SerializerSettings.DateFormatHandling = Newtonsoft.Json.DateFormatHandling.MicrosoftDateFormat;

				HttpResponseMessage message = new HttpResponseMessage(HttpStatusCode.Conflict);
				// エンティティの型に応じたDuplicateSetを返します。
				message.Content = new ObjectContent<DuplicateSet<ma_kura>>(duplicates, jsonFormatter);
				return message;
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
		/// <param name="cd_kura">検索キー：庫場所コード</param>
		/// <returns>既存エンティティ</returns>
        private ma_kura GetSingleEntity(FoodProcsEntities context, string cd_kura)
		{
			var result = context.ma_kura.SingleOrDefault(
                ma => (ma.cd_kura == cd_kura));

			return result;
		}

        /// <summary>
        /// マスタ存在チェック：データが存在していること
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="ma">庫場所マスタ</param>
        /// <returns>チェック結果</returns>
        private string ValidateExistKeys(FoodProcsEntities context, ma_kura ma)
        {
            var master = (from c in context.ma_kura
                          where c.cd_kura == ma.cd_kura
                          select c).FirstOrDefault();

            // 存在しない場合、メッセージを返します
            return master != null ? string.Empty :
                String.Format(Resources.ValidationDataNotFoundMessage, Resources.KurabashoCode, ma.cd_kura);
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

        /// <summary>
        /// エンティティに対するキー情報を登録します。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象のレコード</param>
        private static void AddKey(List<dynamic> keys, ma_kura entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.cd_kura = entity.cd_kura;
            keys.Add(key);
        }

		/// <summary>
        /// 庫場所コードが重複していないこと。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="riyu">1レコード分のコメントマスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="delKeys">既存行の削除対象キーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_kura ma,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            var master = (from m in context.ma_kura
                          where m.cd_kura == ma.cd_kura
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
        /// 対象のキー(庫場所コード)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_kura entity)
        {
            return keys.Find(k => k.cd_kura == entity.cd_kura) != null;
        }

        ////////// 整合性チェック：他マスタに存在する場合はエラー //////////
        /// <summary>
        /// 整合性チェック：品名マスタ(ma_hinmei)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="ma">庫場所マスタ</param>
        /// <returns>チェック結果</returns>
        private string ValidateMaHinmei(FoodProcsEntities context, ma_kura ma)
        {
            var master = (from m in context.ma_hinmei
                          where m.cd_kura == ma.cd_kura
                          select m).FirstOrDefault();

            // 存在する場合、メッセージを返します
            string errMsg = getValidateErrorMassage(Resources.HinmeiMaster, ma.cd_kura);
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
        ////////// 整合性チェック：ここまで //////////
	}
}