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
	public class BunruiMasterController : ApiController
	{
		// POST api/ma_bunrui
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_bunrui> value)
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
			DuplicateSet<ma_bunrui> duplicates = new DuplicateSet<ma_bunrui>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_bunrui> invalidations = new InvalidationSet<ma_bunrui>();

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
                    // 重複チェック：分類コードが重複していないこと
                    validationMessage = ValidateDuplicatKey(context, created, createKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_bunrui>(validationMessage, created, Resources.DuplicateKey));
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // 追加行内だけのキーをチェック用キーリストに追加
                    AddKey(createKeys, created);

                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
					// エンティティを追加します。
                    context.AddToma_bunrui(created);
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip)
			{
				foreach (var updated in value.Updated)
				{
					// 既存エンティティを取得します。
                    ma_bunrui current = GetSingleEntity(context, updated.kbn_hin, updated.cd_bunrui);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
						duplicates.Updated.Add(new Duplicate<ma_bunrui>(updated, current));
						continue;
					}

                    // 既存データの作成日を設定
                    updated.dt_create = current.dt_create;
                    // 更新日にUTC日付を設定
                    updated.dt_update = DateTime.UtcNow;
                    // エンティティを更新します。
                    context.ma_bunrui.ApplyOriginalValues(updated);
                    context.ma_bunrui.ApplyCurrentValues(updated);
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
                        invalidations.Add(new Invalidation<ma_bunrui>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }

                    // 他マスタに存在する場合はエラー
                    // ma_haigo_mei存在チェック
                    validationMessage = ValidateMaHaigoMei(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_bunrui>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }
                    // ma_hinmei存在チェック
                    validationMessage = ValidateMaHinmei(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_bunrui>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }
					// 既存エンティティを取得します。
                    ma_bunrui current = GetSingleEntity(context, deleted.kbn_hin, deleted.cd_bunrui);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
					{
						duplicates.Deleted.Add(new Duplicate<ma_bunrui>(deleted, current));
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
				return Request.CreateResponse<InvalidationSet<ma_bunrui>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				var jsonFormatter = GlobalConfiguration.Configuration.Formatters.JsonFormatter;
				jsonFormatter.SerializerSettings.DateFormatHandling = Newtonsoft.Json.DateFormatHandling.MicrosoftDateFormat;

				HttpResponseMessage message = new HttpResponseMessage(HttpStatusCode.Conflict);
				// エンティティの型に応じたDuplicateSetを返します。
				message.Content = new ObjectContent<DuplicateSet<ma_bunrui>>(duplicates, jsonFormatter);
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
		/// <param name="kbn_hin">検索キー：品区分</param>
		/// <param name="cd_bunrui">検索キー：分類コード</param>
		/// <returns>既存エンティティ</returns>
        private ma_bunrui GetSingleEntity(FoodProcsEntities context, short kbn_hin, string cd_bunrui)
		{
			var result = context.ma_bunrui.SingleOrDefault(
                ma => (ma.kbn_hin == kbn_hin && ma.cd_bunrui == cd_bunrui));

			return result;
		}

        /// <summary>
        /// マスタ存在チェック：同一データが存在していないこと
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="bunrui">分類マスタ</param>
        /// <returns>チェック結果</returns>
        private string ValidateKey(FoodProcsEntities context, ma_bunrui bunrui)
        {
            var master = (from c in context.ma_bunrui
                          where c.kbn_hin == bunrui.kbn_hin
                                && c.cd_bunrui == bunrui.cd_bunrui
                          select c).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }

        /// <summary>
        /// マスタ存在チェック：データが存在していること
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="bunrui">分類マスタ</param>
        /// <returns>チェック結果</returns>
        private string ValidateExistKeys(FoodProcsEntities context, ma_bunrui bunrui)
        {
            var master = (from c in context.ma_bunrui
                          where c.kbn_hin == bunrui.kbn_hin
                                && c.cd_bunrui == bunrui.cd_bunrui
                          select c).FirstOrDefault();

            // 存在しない場合、メッセージを返します
            return master != null ? string.Empty :
                String.Format(Resources.ValidationDataNotFoundMessage, Resources.BunruiCode, bunrui.cd_bunrui);
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
        private static void AddKey(List<dynamic> keys, ma_bunrui entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.cd_bunrui = entity.cd_bunrui;
            keys.Add(key);
        }

		/// <summary>
        /// 分類コードが重複していないこと。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="riyu">1レコード分のコメントマスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="delKeys">既存行の削除対象キーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_bunrui ma,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            var master = (from m in context.ma_bunrui
                          where m.kbn_hin == ma.kbn_hin
                          && m.cd_bunrui == ma.cd_bunrui
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
        /// 対象のキー(分類コード)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_bunrui entity)
        {
            return keys.Find(k => k.cd_bunrui == entity.cd_bunrui) != null;
        }

        ////////// 整合性チェック：他マスタに存在する場合はエラー //////////
        /// <summary>
        /// 整合性チェック：配合名マスタ(ma_haigo_mei)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="bunrui">分類マスタ</param>
        /// <returns>チェック結果</returns>
        private string ValidateMaHaigoMei(FoodProcsEntities context, ma_bunrui bunrui)
        {
            var hinkbn = Convert.ToInt16(ActionConst.ShikakariHinKbn);
            var master = (from m in context.ma_haigo_mei
                          where bunrui.kbn_hin == hinkbn
                                && m.cd_bunrui == bunrui.cd_bunrui
                          select m).FirstOrDefault();

            // 存在する場合、メッセージを返します
            string errMsg = getValidateErrorMassage(Resources.HaigoMeiMaster, bunrui.cd_bunrui);
            return master != null ? errMsg : string.Empty;
        }

        /// <summary>
        /// 整合性チェック：品名マスタ(ma_hinmei)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="bunrui">分類マスタ</param>
        /// <returns>チェック結果</returns>
        private string ValidateMaHinmei(FoodProcsEntities context, ma_bunrui bunrui)
        {
            var master = (from m in context.ma_hinmei
                          where m.kbn_hin == bunrui.kbn_hin
                                && m.cd_bunrui == bunrui.cd_bunrui
                          select m).FirstOrDefault();

            // 存在する場合、メッセージを返します
            string errMsg = getValidateErrorMassage(Resources.HinmeiMaster, bunrui.cd_bunrui);
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