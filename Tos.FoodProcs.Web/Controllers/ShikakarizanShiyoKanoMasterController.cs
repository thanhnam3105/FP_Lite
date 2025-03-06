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
    public class ShikakarizanShiyoKanoMasterController : ApiController
	{
        // POST api/ma_shikakari_zan_shiyo
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<ma_shikakari_zan_shiyo> value)
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
            DuplicateSet<ma_shikakari_zan_shiyo> duplicates = new DuplicateSet<ma_shikakari_zan_shiyo>();
			// TODO: ここまで
			// TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<ma_shikakari_zan_shiyo> invalidations = new InvalidationSet<ma_shikakari_zan_shiyo>();
			// TODO: ここまで

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

                        // 変更セットを元に削除対象のエンティティを削除します。
                        if (value.Deleted != null)
                        {
                            foreach (var deleted in value.Deleted)
                            {
                                // TODO: 既存エンティティを取得します。
                                ma_shikakari_zan_shiyo current = GetSingleEntity(context, deleted.cd_hinmei, deleted.no_juni_hyoji);
                                // TODO: ここまで

                                // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                                // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                                if (current == null || !CompareByteArray(current.ts, deleted.ts))
                                {
                                    duplicates.Deleted.Add(new Duplicate<ma_shikakari_zan_shiyo>(deleted, current));
                                    break;
                                }

                                // エンティティを削除します。
                                context.DeleteObject(current);
                            }
                            context.SaveChanges();
                        }

                        // 変更セットを元に更新対象のエンティティを更新します。
                        if (value.Updated != null && !flgSkip)
                        {
                            foreach (var updated in value.Updated)
                            {
                                // TODO: 既存エンティティを取得します。
                                ma_shikakari_zan_shiyo current = GetSingleEntity(context, updated.cd_hinmei, updated.no_juni_hyoji);
                                // TODO: ここまで

                                // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                                // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                                if (current == null || !CompareByteArray(current.ts, updated.ts))
                                {
                                    duplicates.Updated.Add(new Duplicate<ma_shikakari_zan_shiyo>(updated, current));
                                    break;
                                }

                                //// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                                // 製品重複チェック
                                validationMessage = ValidateDuplicatSeihin(context, updated, false, value);
                                if (!String.IsNullOrEmpty(validationMessage))
                                {
                                    invalidations.Add(new Invalidation<ma_shikakari_zan_shiyo>(validationMessage, updated, Resources.DuplicateKey + "_2"));
                                    // エラーが発生した時点で処理終了。エラーを画面に返す。
                                    flgSkip = true;
                                    break;
                                }
                                //// TODO: ここまで

                                current.cd_seihin = updated.cd_seihin;
                                current.flg_mishiyo = updated.flg_mishiyo;
                                current.cd_update = updated.cd_update;
                                current.dt_update = DateTime.UtcNow;

                                // TODO: エンティティを更新します。
                                context.ma_shikakari_zan_shiyo.ApplyOriginalValues(current);
                                context.ma_shikakari_zan_shiyo.ApplyCurrentValues(current);
                                context.SaveChanges();
                                // TODO: ここまで
                            }
                        }

                        // 変更セットを元に追加対象のエンティティを追加します。
                        if (value.Created != null && !flgSkip)
                        {
                            foreach (var created in value.Created)
                            {
                                // TODO: 既存エンティティを取得します。
                                ma_shikakari_zan_shiyo current = GetSingleEntity(context, created.cd_hinmei, created.no_juni_hyoji);
                                // TODO: ここまで

                                // 既に既存行がある場合はエラーを表示する
                                if (current != null)
                                {
                                    invalidations.Add(new Invalidation<ma_shikakari_zan_shiyo>(validationMessage, created, Resources.Exists));
                                    // エラーが発生した時点で処理終了。エラーを画面に返す。
                                    flgSkip = true;
                                    break;
                                }

                                // 製品重複チェック
                                validationMessage = ValidateDuplicatSeihin(context, created, true, value);
                                if (!String.IsNullOrEmpty(validationMessage))
                                {
                                    invalidations.Add(new Invalidation<ma_shikakari_zan_shiyo>(validationMessage, created, Resources.DuplicateKey + "_2"));
                                    // エラーが発生した時点で処理終了。エラーを画面に返す。
                                    flgSkip = true;
                                    break;
                                }

                                created.dt_create = DateTime.UtcNow;
                                created.dt_update = DateTime.UtcNow;

                                // TODO: エンティティを追加します。
                                context.AddToma_shikakari_zan_shiyo(created);
                                context.SaveChanges();
                                // TODO: ここまで
                            }
                        }

                        // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
                        // エラー情報を返します；。
                        if (invalidations.Count > 0)
                        {
                            transaction.Rollback();
                            // TODO: エンティティの型に応じたInvalidationSetを返します。
                            return Request.CreateResponse<InvalidationSet<ma_shikakari_zan_shiyo>>(HttpStatusCode.BadRequest, invalidations);
                            // TODO: ここまで
                        }

                        // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
                        // コンテントに競合したデータを設定します。
                        if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
                        {
                            transaction.Rollback();
                            // TODO: エンティティの型に応じたDuplicateSetを返します。
                            return Request.CreateResponse<DuplicateSet<ma_shikakari_zan_shiyo>>(HttpStatusCode.Conflict, duplicates);
                            // TODO: ここまで
                        }

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
        private ma_shikakari_zan_shiyo GetSingleEntity(FoodProcsEntities context, string cd_hinmei, int no_juni_hyoji)
		{
            var result = context.ma_shikakari_zan_shiyo.SingleOrDefault(ma => ma.cd_hinmei == cd_hinmei
                                                                            && ma.no_juni_hyoji == no_juni_hyoji);

			return result;
		}

        /// <summary>
        /// 品名コードと製品コードに紐付く仕掛残使用可能マスタのレコードを取得します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="cd_hinmei">品名コード</param>
        /// <param name="cd_seihin">製品コード</param>
        /// <returns>List<ma_shikakari_zan_shiyo></returns>
        private List<ma_shikakari_zan_shiyo> GetEntities(FoodProcsEntities context, string cd_hinmei, string cd_seihin)
        {
            var results = (from zan in context.ma_shikakari_zan_shiyo
                           where zan.cd_hinmei == cd_hinmei
                                && zan.cd_seihin == cd_seihin
                           select zan).ToList();
            return results;
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
        /// 品コード・製品コードが重複していないこと。
        /// 更新処理が Deleted -> Updated -> Created であることが前提のチェック
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="val">1レコード分の仕掛残使用可能マスタ情報</param>
        /// <param name="isCreated">新規登録時true/それ以外false</param>
        /// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatSeihin(FoodProcsEntities context, ma_shikakari_zan_shiyo val, bool isCreated, ChangeSet<ma_shikakari_zan_shiyo> value)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            List<ma_shikakari_zan_shiyo> list = GetEntities(context, val.cd_hinmei, val.cd_seihin);
            ma_shikakari_zan_shiyo record = list.FirstOrDefault();

            if (isCreated && list.Count() > 0)
            {
                // 新規作成で重複するデータがある場合はエラー
                return errMsg;
            }
            else if (!isCreated)
            {
                // 更新処理の場合

                switch (list.Count)
                {
                    case 0:
                        // 旧製品コードから新製品コードへ更新
                        return string.Empty;
                    case 1:
                        // キーが同じなら更新処理へ、違う場合はエラー
                        bool isValid = record.no_juni_hyoji == val.no_juni_hyoji;
                        return isValid ? string.Empty : checkChengeSet(val, record, value);
                    default:
                        // 複数件取得できた場合
                        return errMsg;
                }
            }

            return string.Empty;
        }


        private String checkChengeSet(ma_shikakari_zan_shiyo val, ma_shikakari_zan_shiyo dbVal, ChangeSet<ma_shikakari_zan_shiyo> value)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ
            List<ma_shikakari_zan_shiyo> updList = (from u in value.Updated
                                                    where u.cd_hinmei == dbVal.cd_hinmei
                                                       && u.no_juni_hyoji == dbVal.no_juni_hyoji
                                                    select u).ToList();
            List<ma_shikakari_zan_shiyo> delList = (from d in value.Deleted
                                                    where d.cd_hinmei == dbVal.cd_hinmei
                                                       && d.no_juni_hyoji == dbVal.no_juni_hyoji
                                                    select d).ToList();

            if (delList.Count() > 0)
            {
                // 削除予定なら更新可能
                return string.Empty;
            }
            else if (updList.Count() == 0)
            {
                // 削除予定でなく更新予定でもない場合はエラー
                return errMsg;
            }
            else if (updList.Count() > 0)
            {
                // 更新予定の場合
                foreach (var l in updList)
                {
                    if (val.cd_seihin == l.cd_seihin)
                    {
                        // 製品コードの更新でない場合は重複してしまうのでエラー
                        return errMsg;
                    }
                }
            }

            return string.Empty;
        }
	}
}
