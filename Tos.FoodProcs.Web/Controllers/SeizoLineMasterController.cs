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
	public class SeizoLineMasterController : ApiController
	{
		// POST api/ma_seizo_line
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_seizo_line> value)
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
			DuplicateSet<ma_seizo_line> duplicates = new DuplicateSet<ma_seizo_line>();
			// TODO: ここまで
			// TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_seizo_line> invalidations = new InvalidationSet<ma_seizo_line>();
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
                List<dynamic> keys = new List<dynamic>();
				foreach (var created in value.Created)
				{

                    // 重複チェック：理由コードが重複していないこと
                    validationMessage = ValidateDuplicatKey(context, created, keys, deleteKeys);

					// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    //validationMessage = ValidateKey(context, created);
					// TODO: ここまで

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_seizo_line>(validationMessage, created, Resources.NotExsists));
                        // TODO: ここまで
						continue;
					}
                    AddKey(keys, created);
					// TODO: エンティティを追加します。
					context.AddToma_seizo_line(created);
					// TODO: ここまで
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null)
			{
				foreach (var updated in value.Updated)
				{
					// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = null;//ValidateKey(context, updated);
					// TODO: ここまで

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        //invalidations.Add(new Invalidation<ma_seizo_line>(validationMessage, updated, Resources.NotExsists));
                        // TODO: ここまで
						continue;
					}

					// TODO: 既存エンティティを取得します。
                    ma_seizo_line current = GetSingleEntity(context, updated.kbn_master, updated.cd_haigo, updated.no_juni_yusen, updated.cd_line);
					// TODO: ここまで

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
						duplicates.Updated.Add(new Duplicate<ma_seizo_line>(updated, current));
						continue;
					}

                    // TODO: エンティティを更新します。
                    context.ma_seizo_line.ApplyOriginalValues(updated);
                    context.ma_seizo_line.ApplyCurrentValues(updated);
                    // TODO: ここまで
				}
			}

			// 変更セットを元に削除対象のエンティティを削除します。
			if (value.Deleted != null)
			{
				foreach (var deleted in value.Deleted)
				{
					// TODO: 既存エンティティを取得します。
                    ma_seizo_line current = GetSingleEntity(context, deleted.kbn_master, deleted.cd_haigo, deleted.no_juni_yusen, deleted.cd_line);
					// TODO: ここまで

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
					{
						duplicates.Deleted.Add(new Duplicate<ma_seizo_line>(deleted, current));
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
				return Request.CreateResponse<InvalidationSet<ma_seizo_line>>(HttpStatusCode.BadRequest, invalidations);
				// TODO: ここまで
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				// TODO: エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_seizo_line>>(HttpStatusCode.Conflict, duplicates);
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
		private ma_seizo_line GetSingleEntity(FoodProcsEntities context, short kbn_master, string cd_haigo, short no_yusen, string cd_line)
		{
            var result = context.ma_seizo_line.SingleOrDefault(ma => ( ma.kbn_master == kbn_master
                                                                        && ma.cd_haigo == cd_haigo
                                                                        && ma.no_juni_yusen == no_yusen
                                                                        && ma.cd_line == cd_line ));

			return result;
		}
		// TODO：ここまで

		// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        private string ValidateKey(FoodProcsEntities context, ma_seizo_line seizo_line)
        {
            var master = (from m in context.ma_seizo_line
                          where m.kbn_master == seizo_line.kbn_master
                                && m.cd_haigo == seizo_line.cd_haigo
                                && m.no_juni_yusen == seizo_line.no_juni_yusen
                                //&& m.cd_line == seizo_line.cd_line
                          select m).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }
		// TODO：ここまで

        /// <summary>
        /// 風袋コードが重複していないこと。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="entity">対象のエンティティ</param>
        /// <param name="keys">更新対象のキーリスト</param>
        /// <param name="delKeys">既存行の削除対象キーリスト</param>
        /// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_seizo_line entity,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            var master = (from m in context.ma_seizo_line
                          where m.kbn_master == entity.kbn_master
                                && m.cd_haigo == entity.cd_haigo
                                && m.no_juni_yusen == entity.no_juni_yusen
                          //&& m.cd_line == seizo_line.cd_line
                          select m).FirstOrDefault();

            if (master != null)
            {
                // キーリストにない かつ 削除対象に存在する場合はエラーとしない
                if (!ContainsKey(keys, entity) && ContainsKey(delKeys, entity))
                {
                    return String.Empty;
                }
                return errMsg;
            }
            else if (ContainsKey(keys, entity))
            {
                return errMsg;
            }

            return string.Empty;
        }

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

        /// <summary>
        /// エンティティに対するキー情報を登録します。
        /// </summary>
        /// <param name="keys">キー情報</param>
        /// <param name="created">エンティティ</param>
        private static void AddKey(List<dynamic> keys, ma_seizo_line created)
        {
            // 比較対象のキー値をセット				
            dynamic key = new JObject();
            key.kbn_master = created.kbn_master;
            key.cd_haigo = created.cd_haigo;
            key.no_juni_yusen = created.no_juni_yusen;

            keys.Add(key);
        }

        /// <summary>
        /// 対象のキーを持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キー情報</param>
        /// <param name="created">エンティティ</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_seizo_line created)
        {
            var re = keys.Find(k => k.kbn_master == created.kbn_master
                                && k.cd_haigo == created.cd_haigo
                                && k.no_juni_yusen == created.no_juni_yusen
                                //&& k.cd_futai == created.cd_futai
                                ) != null;
            return re;
        }

	}
}