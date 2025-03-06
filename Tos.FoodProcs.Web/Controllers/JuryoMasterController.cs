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
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class JuryoMasterController : ApiController
	{
		// GET api/MasterColumn
		/// <summary>
		/// クライアントから送信された検索条件を基に検索処理を行います。
		/// </summary>
		/// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
		public StoredProcedureResult<usp_JuryoMaster_select_Result> Get([FromUri]JuryoMasterCriteria criteria)
		{
			FoodProcsEntities context = new FoodProcsEntities();
			List<usp_JuryoMaster_select_Result> views;
			var count = new ObjectParameter("count", 0);
			views = context.usp_JuryoMaster_select(criteria.kbn_jotai, criteria.kbn_hin, criteria.cd_hinmei,
				ActionConst.HanNoShokichi, short.Parse(Resources.KotaiJotaiKbn),
				short.Parse(Resources.EkitaiJotaiKbn), short.Parse(Resources.SonotaJotaiKbn),
                short.Parse(Resources.ShikakarihinJotaiKbn), ActionConst.GenryoHinKbn,
                ActionConst.ShikakariHinKbn, criteria.lang, criteria.skip, criteria.top).ToList();

			var result = new StoredProcedureResult<usp_JuryoMaster_select_Result>();

			result.d = views;
            if (views.Count == 0) {
                result.__count = 0;
            }
            else {
                result.__count = (int)views.ElementAt(0).cnt;
            }

			return result;
		}

        // POST api/ma_juryo
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<ma_juryo> value)
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
            DuplicateSet<ma_juryo> duplicates = new DuplicateSet<ma_juryo>();
			// TODO: ここまで
			// TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<ma_juryo> invalidations = new InvalidationSet<ma_juryo>();
			// TODO: ここまで

			// 変更セットを元に追加対象のエンティティを追加します。
			if (value.Created != null)
			{
                List<dynamic> keys = new List<dynamic>();
               
				foreach (var created in value.Created)
				{
					// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKey(context, created);
					// TODO: ここまで

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_juryo>(validationMessage, created, Resources.NotExsists));
                        // TODO: ここまで
						continue;
					}

                    if (String.IsNullOrEmpty(validationMessage) && ContainsKey(keys, created))
                    {
                        validationMessage = Resources.MS0027;
                        invalidations.Add(new Invalidation<ma_juryo>(validationMessage, created, Resources.NotExsists));
                    }
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

                    // TODO: ここまで
                    AddKey(keys, created);

					// TODO: エンティティを追加します。
                    context.AddToma_juryo(created);
					// TODO: ここまで
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null)
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

					// TODO: 既存エンティティを取得します。
                    ma_juryo current = GetSingleEntity(context, updated.kbn_jotai, updated.kbn_hin, updated.cd_hinmei);
					// TODO: ここまで

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
                        duplicates.Updated.Add(new Duplicate<ma_juryo>(updated, current));
						continue;
					}
                    updated.dt_update = DateTime.UtcNow;

                    // TODO: エンティティを更新します。
                    context.ma_juryo.ApplyOriginalValues(updated);
                    context.ma_juryo.ApplyCurrentValues(updated);
                    // TODO: ここまで
				}
			}

			// 変更セットを元に削除対象のエンティティを削除します。
			if (value.Deleted != null)
			{
				foreach (var deleted in value.Deleted)
				{
					// TODO: 既存エンティティを取得します。
                    ma_juryo current = GetSingleEntity(context, deleted.kbn_jotai, deleted.kbn_hin, deleted.cd_hinmei);
					// TODO: ここまで

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
					{
						duplicates.Deleted.Add(new Duplicate<ma_juryo>(deleted, current));
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
				return Request.CreateResponse<InvalidationSet<ma_juryo>>(HttpStatusCode.BadRequest, invalidations);
				// TODO: ここまで
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			{
				// TODO: エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_juryo>>(HttpStatusCode.Conflict, duplicates);
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

        // TODO: エンティティに対するキー情報を登録します。
        private static void AddKey(List<dynamic> keys, ma_juryo created)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.cd_hinmei = created.cd_hinmei;

            keys.Add(key);
        }
        // TODO：ここまで

        // TODO: 対象のキーを持つエンティティの存在チェックを行います。
        private static bool ContainsKey(List<dynamic> keys, ma_juryo created)
        {
            return keys.Find(k => k.cd_hinmei == created.cd_hinmei) != null;
        }
        // TODO：ここまで

		// TODO：既存エンティティを取得します。
        private ma_juryo GetSingleEntity(FoodProcsEntities context, short kbn_jotai, short kbn_hin, string cd_hinmei)
		{
            var result = context.ma_juryo.SingleOrDefault(ma => ( ma.kbn_jotai == kbn_jotai
                                                                        && ma.kbn_hin == kbn_hin
                                                                        && ma.cd_hinmei == cd_hinmei ));
			return result;
		}
		// TODO：ここまで

		// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        private string ValidateKey(FoodProcsEntities context, ma_juryo juryo)
        {
            var master = (from m in context.ma_juryo
                          where m.kbn_jotai == juryo.kbn_jotai
                                && m.kbn_hin == juryo.kbn_hin
                                && m.cd_hinmei == juryo.cd_hinmei
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