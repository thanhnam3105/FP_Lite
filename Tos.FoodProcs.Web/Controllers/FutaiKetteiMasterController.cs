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
using System.Data.Objects;
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers {


    

	[Authorize]
	[LoggingExceptionFilter]
	public class FutaiKetteiMasterController : ApiController {

		// GET api/MasterColumn
		/// <summary>
		/// クライアントから送信された検索条件を基に検索処理を行います。
		/// </summary>
		/// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_FutaiKetteiMaster_select_Result> Get([FromUri]FutaiKetteiMasterCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            List<usp_FutaiKetteiMaster_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_FutaiKetteiMaster_select(
                criteria.kbn_jotai
                , criteria.cd_hinmei
                , ActionConst.HanNoShokichi
                , ActionConst.KotaiJotaiKbn
                , ActionConst.EkitaiJotaiKbn
                , ActionConst.SonotaJotaiKbn
                , ActionConst.FlagFalse
                , ActionConst.GenryoHinKbn
                , criteria.skip
                , criteria.top
                , criteria.kbn_hin
                , ActionConst.ShikakariHinKbn
            ).ToList();

            var result = new StoredProcedureResult<usp_FutaiKetteiMaster_select_Result>();

            result.d = views;
            if (views.Count == 0)
            {
                result.__count = 0;
            }
            else
            {
                result.__count = (int)views.ElementAt(0).cnt;
            }

            return result;
        }
		// POST api/ma_futai_kettei
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_futai_kettei> value) {
			string validationMessage = string.Empty;
            bool flgSkip = false;   // 処理をスキップするかどうか
		
			// パラメータのチェックを行います。
			if (value == null) {
				return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
			}

			FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
		
			// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
			DuplicateSet<ma_futai_kettei> duplicates = new DuplicateSet<ma_futai_kettei>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_futai_kettei> invalidations = new InvalidationSet<ma_futai_kettei>();

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

			// 【新規登録】変更セットを元に追加対象のエンティティを追加します。
			if (value.Created != null) {
                List<dynamic> keys = new List<dynamic>();
                //List<dynamic> createKeys = new List<dynamic>();   // 重複チェック用：追加対象キーリスト
				foreach (var created in value.Created) {
                    // 品名コードチェック
                    if (created.cd_hinmei == null) {
                            created.cd_hinmei = "";
                    }

                    // 重複チェック：理由コードが重複していないこと
                    validationMessage = ValidateDuplicatKey(context, created, keys, deleteKeys);

                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    //validationMessage = ValidateKey(context, created);
					if (!String.IsNullOrEmpty(validationMessage)) {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_futai_kettei>(validationMessage, created, Resources.NotExsists));
						continue;
					}

					if (String.IsNullOrEmpty(validationMessage) && ContainsKey(keys, created)) {
                        validationMessage = Resources.MS0027;
                        invalidations.Add(new Invalidation<ma_futai_kettei>(validationMessage, created, Resources.DuplicateKey));
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
					}
					// ここまで								
					AddKey(keys, created);

					// エンティティを追加します。
					context.AddToma_futai_kettei(created);
				}
			}
			// 【更新】変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip) {
				foreach (var updated in value.Updated) {
                    // 品名コードチェック
                    if (updated.cd_hinmei == null) {
                            updated.cd_hinmei = "";
                    }
					// 既存エンティティを取得します。
                    ma_futai_kettei current = GetSingleEntity(
                        context, updated.kbn_jotai, updated.kbn_hin, updated.cd_hinmei, updated.cd_futai);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts)) {
						duplicates.Updated.Add(new Duplicate<ma_futai_kettei>(updated, current));
						continue;
					}

                    // Tエンティティを更新します。
                    context.ma_futai_kettei.ApplyOriginalValues(updated);
                    context.ma_futai_kettei.ApplyCurrentValues(updated);
				}
			}
			// 【削除】セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null && !flgSkip)
            {
                foreach (var deleted in value.Deleted)
                {
                    // 品名コードチェック
                    if (deleted.cd_hinmei == null)
                    {
                        deleted.cd_hinmei = "";
                    }

                    // 既存エンティティを取得します。
                    ma_futai_kettei current = GetSingleEntity(
                        context, deleted.kbn_jotai, deleted.kbn_hin, deleted.cd_hinmei, deleted.cd_futai);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_futai_kettei>(deleted, current));
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
				return Request.CreateResponse<InvalidationSet<ma_futai_kettei>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				// エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_futai_kettei>>(HttpStatusCode.BadRequest, duplicates);
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
		/// <param name="kbn_jotai">状態区分</param>
		/// <param name="kbn_hin">品区分</param>
		/// <param name="cd_hinmei">品名コード</param>
		/// <param name="cd_futai">風袋コード</param>
		/// <returns>既存エンティティ</returns>
		private ma_futai_kettei GetSingleEntity(FoodProcsEntities context,
                short kbn_jotai, short kbn_hin, string cd_hinmei, string cd_futai) {
            var result = context.ma_futai_kettei.SingleOrDefault(ma => ma.kbn_jotai == kbn_jotai
                                                                        && ma.kbn_hin == kbn_hin
                                                                        && ma.cd_hinmei == cd_hinmei
                                                                        && ma.cd_futai == cd_futai);
			return result;
		}

        /*
        /// <summary>
        /// 風袋決定マスタに存在するかどうか
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="futai">対象のエンティティ</param>
        /// <returns>チェック結果</returns>
        private string ValidateKey(FoodProcsEntities context, ma_futai_kettei futai) {
            var master = (from m in context.ma_futai_kettei
                            where m.kbn_jotai == futai.kbn_jotai
                                && m.cd_hinmei == futai.cd_hinmei
                                && m.cd_futai == futai.cd_futai
                            select m).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }
        */

        /// <summary>
        /// 風袋コードが重複していないこと。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="entity">対象のエンティティ</param>
        /// <param name="keys">更新対象のキーリスト</param>
        /// <param name="delKeys">既存行の削除対象キーリスト</param>
        /// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_futai_kettei entity,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            var master = (from m in context.ma_futai_kettei
                          where m.kbn_jotai == entity.kbn_jotai
                              && m.cd_hinmei == entity.cd_hinmei
                              && m.cd_futai == entity.cd_futai
                              && m.kbn_hin == entity.kbn_hin
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

		/// <summary>
		/// エンティティに対するキー情報を登録します。
		/// </summary>
		/// <param name="keys">キー情報</param>
		/// <param name="created">エンティティ</param>
		private static void AddKey(List<dynamic> keys, ma_futai_kettei created) {
			// 比較対象のキー値をセット				
			dynamic key = new JObject();
			key.kbn_jotai = created.kbn_jotai;
			key.kbn_hin = created.kbn_hin;
			key.cd_hinmei = created.cd_hinmei;
			key.cd_futai = created.cd_futai;

			keys.Add(key);
		}

		/// <summary>
		/// 対象のキーを持つエンティティの存在チェックを行います。
		/// </summary>
		/// <param name="keys">キー情報</param>
		/// <param name="created">エンティティ</param>
		/// <returns>チェック結果</returns>
		private static bool ContainsKey(List<dynamic> keys, ma_futai_kettei created) {
			var re = keys.Find(k => k.kbn_jotai == created.kbn_jotai
                                && k.kbn_hin == created.kbn_hin
                                && k.cd_hinmei == created.cd_hinmei
                                && k.cd_futai == created.cd_futai) != null;
            return re;
		}
	}
}