using System;
using System.Collections.Generic;
using System.Data.Objects;
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
	public class CommentMasterController : ApiController
	{
		// POST api/ma_comment
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_comment> value)
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
			DuplicateSet<ma_comment> duplicates = new DuplicateSet<ma_comment>();

            // 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_comment> invalidations = new InvalidationSet<ma_comment>();

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
                List<dynamic> commentKeys = new List<dynamic>();   // コメントコードの重複チェック用：追加対象キーリスト

                foreach (var created in value.Created)
                {
                    // シーケンス番号を取得します。
                    ObjectParameter no_saiban_param = new ObjectParameter("no_saiban", 0);
                    String noSaiban = context.usp_cm_Saiban(
                        ActionConst.CommentSaibanKbn, ActionConst.CommentPrefixSaibanKbn, no_saiban_param).FirstOrDefault<String>();

                    // 取得したシーケンス番号を設定
                    created.no_seq = noSaiban;

                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    //validationMessage = ValidateKey(context, created);
                    //if (!String.IsNullOrEmpty(validationMessage))
                    //{
                    //    // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                    //    invalidations.Add(new Invalidation<ma_comment>(validationMessage, created, Resources.Keys));
                    //    continue;
                    //}

                    // 重複チェック
                    validationMessage = ValidateDuplicatKey(context, created, commentKeys, updateKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_comment>(validationMessage, created, Resources.Keys));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // キーリストに追加
                    AddKey(commentKeys, created);


                    // エンティティを追加します。
                    context.AddToma_comment(created);
                }
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip)
			{
                List<dynamic> keys = new List<dynamic>();   // 空のリスト

                foreach (var updated in value.Updated)
				{
					// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateExistKeys(context, updated);
                    //validationMessage = ValidateKey(context, updated);
					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_comment>(validationMessage, updated, Resources.Keys));
						continue;
					}
                    // 重複チェック
                    validationMessage = ValidateDuplicatKey(context, updated, keys, updateKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_comment>(validationMessage, updated, Resources.Keys));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // キーリストに追加
                    //AddKey(commentKeys, created);

					// 既存エンティティを取得します。
                    ma_comment current = GetSingleEntity(context, updated.no_seq);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null)
					{
						duplicates.Updated.Add(new Duplicate<ma_comment>(updated, current));
						continue;
					}

                    // エンティティを更新します。
                    context.ma_comment.ApplyOriginalValues(updated);
                    context.ma_comment.ApplyCurrentValues(updated);
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
                        invalidations.Add(new Invalidation<ma_comment>(validationMessage, deleted, Resources.Keys));
                        continue;
                    }

					// 既存エンティティを取得します。
                    ma_comment current = GetSingleEntity(context, deleted.no_seq);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null)
					{
						duplicates.Deleted.Add(new Duplicate<ma_comment>(deleted, current));
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
				return Request.CreateResponse<InvalidationSet<ma_comment>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				var jsonFormatter = GlobalConfiguration.Configuration.Formatters.JsonFormatter;
				jsonFormatter.SerializerSettings.DateFormatHandling = Newtonsoft.Json.DateFormatHandling.MicrosoftDateFormat;

				HttpResponseMessage message = new HttpResponseMessage(HttpStatusCode.Conflict);
				// エンティティの型に応じたDuplicateSetを返します。
				message.Content = new ObjectContent<DuplicateSet<ma_comment>>(duplicates, jsonFormatter);
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
		/// <param name="no_seq">検索キー</param>
		/// <returns>既存エンティティ</returns>
        private ma_comment GetSingleEntity(FoodProcsEntities context, String no_seq)
		{
			var result = context.ma_comment.SingleOrDefault(ma => (ma.no_seq == no_seq));

			return result;
		}

		/// <summary>
        /// コメントコードが重複していないこと。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="comment">1レコード分のコメントマスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="upKeys">既存行の更新対象キーリスト</param>
		/// <param name="delKeys">既存行の削除対象キーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_comment comment,
            List<dynamic> keys, List<dynamic> upKeys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            var master = (from m in context.ma_comment
                          where m.cd_comment == comment.cd_comment
                          && m.no_seq != comment.no_seq
                          select m).FirstOrDefault();

            // キーリストが渡されている場合、取得した情報/入力された情報がキーリストに存在するかをチェックする
            dynamic index = null;

            // 新規追加行のキーリスト
            if (keys.Count > 0)
            {
                if (ContainsKey(keys, comment))
                {
                    return errMsg;
                }
            }

            // 更新対象のキーリスト
            if (upKeys.Count > 0)
            {
                // マスタ検索結果が存在していた場合：先にマスタ情報でキーリストをチェック
                if (master != null)
                {
                    // マスタ結果がキーリストに存在するかどうか
                    index = upKeys.Find(k => k.cd_comment == master.cd_comment);
                    if (index != null)
                    {
                        // 存在するかつコメントコードが同じだった場合、メッセージを返す
                        if (index.cd_comment == comment.cd_comment)
                        {
                            return errMsg;
                        }
                        // コメントコードが違う場合、画面で編集されているので重複エラーとしない

                        // 入力情報でキーリストをチェック
                        index = upKeys.Find(k => k.cd_comment == comment.cd_comment);
                        if (index != null)
                        {
                            if (index.no_seq != comment.no_seq)
                            {
                                return errMsg;
                            }
                            // 同じシーケンス番号は自分なので、エラーとしない
                        }
                    }
                    else
                    {
                        // 入力情報でキーリストをチェック
                        index = upKeys.Find(k => k.cd_comment == comment.cd_comment);
                        if (index != null)
                        {
                            if (index.no_seq != comment.no_seq)
                            {
                                return errMsg;
                            }
                            // 同じシーケンス番号は自分なので、エラーとしない
                        }
                        else
                        {
                            // 更新対象キーリストに存在しない場合、削除対象のキーリストに存在するかをチェック
                            if (!ContainsKey(delKeys, master))
                            {
                                // 削除対象のキーリストにも存在しない場合はエラー
                                return errMsg;
                            }
                            // 削除対象のキーリストに存在した場合はエラーとしない
                        }
                    }
                }
                // マスタ検索結果が存在しない場合：入力情報でキーリストをチェック
                else
                {
                    index = upKeys.Find(k => k.cd_torihiki == comment.cd_comment);
                    if (index != null)
                    {
                        if (index.no_seq != comment.no_seq)
                        {
                            return errMsg;
                        }
                        // 同じシーケンス番号は自分なので、エラーとしない
                    }
                }
            }
            else
            {
                // マスタ検索結果が存在し、マスタのコメントコードが削除対象キーリストに存在しなければ重複エラー
                if (master != null && !ContainsKey(delKeys, master))
                {
                    return errMsg;
                }
            }

            return string.Empty;
        }

        /// <summary>
        /// 対象のキー(コメントコード)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_comment entity)
        {
            return keys.Find(k => k.cd_comment == entity.cd_comment) != null;
        }

		/// <summary>
		/// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="comment">コメントマスタデータ</param>
		/// <returns>正常：空文字　エラー：メッセージ</returns>
        private string ValidateKey(FoodProcsEntities context, ma_comment comment)
        {
            var master = (from c in context.ma_comment
                          where c.cd_comment == comment.cd_comment
                                && c.no_seq != comment.no_seq
                          select c).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }

        /// <summary>
        /// 整合性チェック：データが存在すること
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="comment">コメントマスタデータ</param>
        /// <returns>正常：空文字　エラー：メッセージ</returns>
        private string ValidateExistKeys(FoodProcsEntities context, ma_comment comment)
        {
            var master = (from c in context.ma_comment
                          where c.no_seq == comment.no_seq
                          select c).FirstOrDefault();

            // 存在しない場合、メッセージを返します
            return master == null ? Resources.NoFileDataMessage : string.Empty;
        }

        /// <summary>
        /// エンティティに対するキー情報を登録します。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象のレコード</param>
        private static void AddKey(List<dynamic> keys, ma_comment entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.no_seq = entity.no_seq;
            key.cd_comment = entity.cd_comment;
            keys.Add(key);
        }
	}
}