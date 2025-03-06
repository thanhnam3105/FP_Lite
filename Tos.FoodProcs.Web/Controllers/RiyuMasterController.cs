using System;
using System.Collections.Generic;
using System.Data.Objects;
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
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class RiyuMasterController : ApiController
	{

        // POST api/ma_riyu
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_riyu> value)
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

            //// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<ma_riyu> duplicates = new DuplicateSet<ma_riyu>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_riyu> invalidations = new InvalidationSet<ma_riyu>();

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
                    // 重複チェック：理由コードが重複していないこと
                    validationMessage = ValidateDuplicatKey(context, created, createKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_riyu>(validationMessage, created, Resources.DuplicateKey));
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // 追加行内だけのキーをチェック用キーリストに追加
                    AddKey(createKeys, created);

                    
                    // 作成日、更新日にUTCシステム日付を設定
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

                    // エンティティを追加します。
                    context.AddToma_riyu(created);
                }
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip)
			{
                List<dynamic> keys = new List<dynamic>();   // 空のリスト

                // 後勝ちで更新
				foreach (var updated in value.Updated)
				{
                    // 既存エンティティを取得します。
                    ma_riyu current = GetSingleEntity(context, updated);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, updated.ts))
                    { 
                        duplicates.Updated.Add(new Duplicate<ma_riyu>(updated, current));
                        continue;
                    }

                    // 既存エンティティの値を設定
                    updated.cd_create = current.cd_create;
                    updated.dt_create = current.dt_create;
                    // 更新日にUTCシステム日付を設定
                    updated.dt_update = DateTime.UtcNow;

                    // エンティティを更新します。
                    context.ma_riyu.ApplyOriginalValues(updated);
                    context.ma_riyu.ApplyCurrentValues(updated);
				}
			}

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null && !flgSkip)
            {
                foreach (var deleted in value.Deleted)
                {
                    // 既存エンティティを取得します。
                    ma_riyu current = GetSingleEntity(context, deleted);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_riyu>(deleted, current));
                        continue;
                    }

                    // ★★ TODO ★★
                    // 整合性チェック：対象テーブルに該当データが存在する場合はエラー？
                    //validationMessage = Validate_tr_chosei(context, deleted);

                    // エンティティを削除します。
                    context.DeleteObject(current);
                }
            }

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
			if (invalidations.Count > 0)
			{
				// エンティティの型に応じたInvalidationSetを返します。
				return Request.CreateResponse<InvalidationSet<ma_riyu>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
            if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
            {
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_riyu>>(HttpStatusCode.Conflict, duplicates);
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
		/// <param name="key1">検索キー</param>
		/// <returns>既存エンティティ</returns>
        private ma_riyu GetSingleEntity(FoodProcsEntities context, ma_riyu entity)
		{
            var result = context.ma_riyu.SingleOrDefault(
                ma => ma.kbn_bunrui_riyu == entity.kbn_bunrui_riyu && ma.cd_riyu == entity.cd_riyu);

			return result;
		}

        /// <summary>
        /// TODO：実装イメージ
		/// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="ma">1レコード分の理由マスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="delKeys">削除対象のキーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String Validate_tr_chosei(FoodProcsEntities context, ma_riyu ma)
        {
            var master = (from m in context.tr_chosei
                          where m.cd_riyu == ma.cd_riyu
                          select m).FirstOrDefault();

            if (master != null)
            {
                // 調整トランに存在した場合、エラーとする
                return String.Format(Resources.MS0001, "調整トラン");
            }

            return String.Empty;
        }

		/// <summary>
        /// 理由コードが重複していないこと。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="riyu">1レコード分のコメントマスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="delKeys">既存行の削除対象キーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_riyu riyu,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            // 理由分類区分が一致する、かつ理由コードが一致する
            var master = (from m in context.ma_riyu
                          where m.cd_riyu == riyu.cd_riyu
                          && m.kbn_bunrui_riyu == riyu.kbn_bunrui_riyu
                          select m).FirstOrDefault();

            if (master != null)
            {
                // キーリストにない かつ 削除対象に存在する場合はエラーとしない
                if (!ContainsKey(keys, riyu) && ContainsKey(delKeys, riyu))
                {
                    return String.Empty;
                }
                return errMsg;
            }
            else if (ContainsKey(keys, riyu))
            {
                return errMsg;
            }

            return string.Empty;
        }

        /// <summary>
        /// 対象のキー(理由コード)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_riyu entity)
        {
            return keys.Find(k => k.cd_riyu == entity.cd_riyu) != null;
        }

		/// <summary>
		///  タイムスタンプの値を比較します。
		/// </summary>
		/// <param name="left">値1</param>
		/// <param name="right">値2</param>
		/// <returns>比較結果</returns>
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
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象のレコード</param>
        private static void AddKey(List<dynamic> keys, ma_riyu entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.cd_riyu = entity.cd_riyu;
            key.ts = entity.ts;
            keys.Add(key);
        }
	}
}