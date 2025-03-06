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
	public class ShizaiShiyoMasterController : ApiController
    {

        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<vw_ma_shiyo_01> Get(string cd_hinmei, decimal no_han, short top)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            ma_shiyo_h header = GetSingleEntityHeader(context, cd_hinmei, (no_han - 1));
            List<ma_shiyo_b> bodys = GetEntityBodys(context, cd_hinmei, (no_han - 1));
            

            var result = new StoredProcedureResult<vw_ma_shiyo_01>();


            // 新規版番号をセットする
            vw_ma_shiyo_01 row = null;
            List<vw_ma_shiyo_01> resultList = new List<vw_ma_shiyo_01>();
            foreach (ma_shiyo_b body in bodys) {
                ma_hinmei hin = (from ma in context.ma_hinmei
                                 where ma.cd_hinmei == body.cd_shizai
                                 select ma).SingleOrDefault();
                if (hin != null)
                {
                    ma_tani tani = (from ma in context.ma_tani
                                    where ma.cd_tani == hin.cd_tani_shiyo
                                    select ma).SingleOrDefault();
                    // 資材が未使用でない場合のみ
                    if (hin.flg_mishiyo == int.Parse(Resources.FlagFalse)
                            && tani.flg_mishiyo == int.Parse(Resources.FlagFalse))
                    {
                        row = new vw_ma_shiyo_01();
                        row.cd_hinmei = cd_hinmei;
                        row.no_han = no_han;
                        row.cd_shizai = body.cd_shizai;
                        row.nm_hinmei_ja = hin.nm_hinmei_ja;
                        row.nm_hinmei_en = hin.nm_hinmei_en;
                        row.nm_hinmei_zh = hin.nm_hinmei_zh;
                        row.nm_hinmei_vi = hin.nm_hinmei_vi;
                        row.nm_nisugata_hyoji = hin.nm_nisugata_hyoji;
                        row.cd_tani_shiyo = hin.cd_tani_shiyo;
                        row.nm_tani = tani.nm_tani;
                        row.su_shiyo = body.su_shiyo;
                        row.kbn_hin = hin.kbn_hin;
                        row.flg_mishiyo = header.flg_mishiyo;
                        row.hinmei_flg_mishiyo = hin.flg_mishiyo;
                        row.tani_flg_mishiyo = tani.flg_mishiyo;
                        resultList.Add(row);
                    }
                }
            }

            result.d = resultList;
            if (resultList.Count == 0)
            {
                result.__count = 0;
            }
            else
            {
                result.__count = resultList.Count();
            }

            return result;
        }

		// POST api/ma_shiyo_b, ma_shiyo_h, ma_shiyo_h
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSets<ma_shiyo_b, ma_shiyo_h, ma_shiyo_h> value)
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
            DuplicateSets<ma_shiyo_b, ma_shiyo_h, ma_shiyo_h> duplicates
                        = new DuplicateSets<ma_shiyo_b, ma_shiyo_h, ma_shiyo_h>();

			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSets<ma_shiyo_b, ma_shiyo_h, ma_shiyo_h> invalidations
                        = new InvalidationSets<ma_shiyo_b, ma_shiyo_h, ma_shiyo_h>();

            // ユーザー情報を取得する
            UserController user = new UserController();
            UserInfo userInfo = user.Get();

            // 重複チェック用：既存行のキーリスト
            List<dynamic> updateKeys = new List<dynamic>();
            List<dynamic> deleteKeys = new List<dynamic>();
            if (value.First.Updated != null)
            {
                foreach (var updated in value.First.Updated)
                {
                    AddKey(updateKeys, updated);
                }
            }
            if (value.First.Deleted != null)
            {
                foreach (var deleted in value.First.Deleted)
                {
                    AddKey(deleteKeys, deleted);
                }
            }



            // コピーデータの新規登録
            if (value.Third.Created != null)
            {
                if (value.Third.Created.Count() > 0)
                {
                    var header = value.Third.Created[0];

                    // ヘッダーデータの作成
                    header.dt_create = DateTime.UtcNow;
                    header.dt_update = DateTime.UtcNow;
                    header.cd_create = userInfo.Code;
                    header.cd_update = userInfo.Code;
                    header.ts = null;

                    // エンティティを追加します。
                    context.AddToma_shiyo_h(header);
                }
            }

            // 【削除】資材使用削除
            if (value.Third.Deleted != null)
            {
                foreach (var deleted in value.Third.Deleted)
                {
                    foreach (var header in GetEntityHeaders(context, deleted.cd_hinmei))
                    {
                        // ヘッダーエンティティを削除します。
                        context.DeleteObject(header);
                        foreach (var body in GetEntityBodys(context, header.cd_hinmei, header.no_han))
                        {
                            // ボディエンティティを削除します。
                            context.DeleteObject(body);
                        }
                    }
                }
            }

            // 【新規作成】変更セットを元に追加対象のエンティティを追加します。
            if (value.First.Created != null)
            {
                List<dynamic> keys = new List<dynamic>();
                foreach (var created in value.First.Created)
                {
                    // 重複チェック：資材コードが重複していないこと
                    validationMessage = ValidateDuplicatKey(context, created, keys, deleteKeys);

                    // マスタに存在しないかチェックを行う（整合性チェック）。
                    //validationMessage = ValidateKeyBody(context, created.cd_hinmei, created.no_han, created.cd_shizai);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // マスタに存在するエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.First.Add(new Invalidation<ma_shiyo_b>(validationMessage, created, Resources.Exists));
                        continue;
                    }
                    // １版でない時、資材マスタヘッダの存在チェックを行う。
                    if (created.no_han > 1
                        && GetSingleEntityHeader(context, created.cd_hinmei, short.Parse(Resources.HanNoShokichi)) == null)
                    {
                        // マスタに存在しないエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.First.Add(new Invalidation<ma_shiyo_b>(
                            String.Format(Resources.MS0049, Resources.ShizaiShiyoData), created, Resources.NotExsists));
                        continue;
                    }

                    AddKey(keys, created);
                    // UTC時刻をセット
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
                    // 作成者、更新者にログインユーザーIDをセット
                    created.cd_create = userInfo.Code;
                    created.cd_update = userInfo.Code;

                    // エンティティを追加します。
                    context.AddToma_shiyo_b(created);
                }
            }
            if (value.Second.Created != null)
            {
                foreach (var created in value.Second.Created)
                {
                    // マスタに存在しないかチェックを行う（整合性チェック）
                    validationMessage = ValidateKeyHeader(context, created.cd_hinmei, created.no_han);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // マスタに存在するエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Second.Add(new Invalidation<ma_shiyo_h>(validationMessage, created, Resources.Exists));
                        continue;
                    }
                    // 同じ有効日付が他の版に存在しないこと
                    //validationMessage = ValidateKeyHeaderFromDate(context, created.cd_hinmei, created.no_han, created.dt_from);
                    //if (!String.IsNullOrEmpty(validationMessage))
                    //{
                    //    // TODO: マスタに存在するエラーの発生した列名を指定してInvalidationSetを追加します。
                    //    invalidations.Second.Add(new Invalidation<ma_shiyo_h>(validationMessage, created, Resources.Exists));
                    //    // TODO: ここまで
                    //    continue;
                    //}

                    // UTC時刻をセット
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
                    // 作成者、更新者にログインユーザーIDをセット
                    created.cd_create = userInfo.Code;
                    created.cd_update = userInfo.Code;

                    // エンティティを追加します。
                    context.AddToma_shiyo_h(created);
                }
            }

            // 【更新】変更セットを元に更新対象のエンティティを更新します。
            if (value.First.Updated != null)
            {
                foreach (var updated in value.First.Updated)
                {
                    // ヘッダマスタに存在するかチェックを行う（整合性チェック)
                    ma_shiyo_b bodyCurrent = GetSingleEntityBody(context, updated.cd_hinmei, updated.no_han, updated.cd_shizai);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (bodyCurrent == null || !CompareByteArray(bodyCurrent.ts, updated.ts))
                    {
                        duplicates.First.Updated.Add(new Duplicate<ma_shiyo_b>(updated, bodyCurrent));
                        continue;
                    }
                    // 資材マスタヘッダの存在チェックを行う。
                    if (GetSingleEntityHeader(context, updated.cd_hinmei, updated.no_han) == null)
                    {
                        // マスタに存在しないエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.First.Add(new Invalidation<ma_shiyo_b>(
                            String.Format(Resources.MS0049, Resources.ShizaiShiyoData), updated, Resources.NotExsists));
                        continue;
                    }

                    // UTC時刻をセット
                    updated.dt_update = DateTime.UtcNow;
                    updated.cd_update = userInfo.Code;
                    // 既存データより作成日と作成者をセット
                    updated.cd_create = bodyCurrent.cd_create;
                    updated.dt_create = bodyCurrent.dt_create;

                    // エンティティを更新します。
                    context.ma_shiyo_b.ApplyCurrentValues(updated);
                }
            }
			if (value.Second.Updated != null)
			{
				foreach (var updated in value.Second.Updated)
				{
					// ヘッダマスタに存在するかチェックを行う（整合性チェック)。
                    ma_shiyo_h headerCurrent = GetSingleEntityHeader(context, updated.cd_hinmei, updated.no_han);

					// 既存データが無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (headerCurrent == null || !CompareByteArray(headerCurrent.ts, updated.ts))
					{
                        duplicates.Second.Updated.Add(new Duplicate<ma_shiyo_h>(updated, headerCurrent));
						continue;
                    }
                    //validationMessage = ValidateKeyHeaderFromDate(context, updated.cd_hinmei, updated.no_han, updated.dt_from);
                    //// 同じ有効日付が他の版に存在しないこと
                    //if (!String.IsNullOrEmpty(validationMessage))
                    //{
                    //    // TODO: マスタに存在するエラーの発生した列名を指定してInvalidationSetを追加します。
                    //    invalidations.Second.Add(new Invalidation<ma_shiyo_h>(validationMessage, updated, Resources.Exists));
                    //    // TODO: ここまで
                    //    continue;
                    //}

                    // UTC時刻をセット
                    updated.cd_update = userInfo.Code;
                    updated.dt_update = DateTime.UtcNow;
                    // 既存データより作成日と作成者をセット
                    updated.cd_create = headerCurrent.cd_create;
                    updated.dt_create = headerCurrent.dt_create;

                    // エンティティを更新します。
                    context.ma_shiyo_h.ApplyCurrentValues(updated);
				}
            }

            // 【削除】変更セットを元に削除対象のエンティティを削除します。
            if (value.First.Deleted != null)
            {
                foreach (var deleted in value.First.Deleted)
                {
                    // 既存エンティティを取得します。
                    ma_shiyo_b current = GetSingleEntityBody(context, deleted.cd_hinmei, deleted.no_han, deleted.cd_shizai);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.First.Deleted.Add(new Duplicate<ma_shiyo_b>(deleted, current));
                        continue;
                    }
                    // エンティティを削除します。
                    context.DeleteObject(current);
                }
            }
            if (value.Second.Deleted != null)
			{
                foreach (var deleted in value.Second.Deleted)
				{
                    // 既存エンティティを取得します。
                    ma_shiyo_h current = GetSingleEntityHeader(context, deleted.cd_hinmei, deleted.no_han);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Second.Deleted.Add(new Duplicate<ma_shiyo_h>(deleted, current));
                        continue;
                    }
                    // エンティティを削除します。
                    context.DeleteObject(current);
				}
			}

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
            if (invalidations.First.Count > 0 || invalidations.Second.Count > 0 || invalidations.Third.Count > 0)
			{
				// エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSets<ma_shiyo_b, ma_shiyo_h, ma_shiyo_h>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
            if (duplicates.First.Created.Count > 0 || duplicates.First.Updated.Count > 0 || duplicates.First.Deleted.Count > 0 ||
                duplicates.Second.Created.Count > 0 || duplicates.Second.Updated.Count > 0 || duplicates.Second.Deleted.Count > 0)
			{
				// エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSets<ma_shiyo_b, ma_shiyo_h, ma_shiyo_h>>(HttpStatusCode.Conflict, duplicates);
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
		/// 既存ヘッダーエンティティを取得します。
		/// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="cd_hinmei">品名コード</param>
		/// <param name="no_han">版番号</param>
		/// <returns>既存ヘッダーエンティティ</returns>
        private ma_shiyo_h GetSingleEntityHeader(FoodProcsEntities context, string cd_hinmei, decimal no_han)
		{
            ma_shiyo_h result = null;
            if (Nullable.Equals<decimal>(null, no_han) || no_han.CompareTo(decimal.Zero) <= 0)
            {
                result = context.ma_shiyo_h.FirstOrDefault(ma => (ma.cd_hinmei == cd_hinmei));
            }
            else
            {
                result = context.ma_shiyo_h.SingleOrDefault(ma => (ma.cd_hinmei == cd_hinmei
                                                                   && ma.no_han == no_han));
            }
			return result;
		}

        /// <summary>
        /// 既存ボディエンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="cd_hinmei">品名コード</param>
        /// <param name="no_han">版番号</param>
        /// <param name="cd_shizai">資材コード</param>
        /// <returns>既存ボディエンティティ</returns>
        private ma_shiyo_b GetSingleEntityBody(FoodProcsEntities context, string cd_hinmei, decimal no_han, string cd_shizai)
        {
            ma_shiyo_b result = null;
            if ((Nullable.Equals<decimal>(null, no_han) || no_han.CompareTo(decimal.Zero) <= 0) && cd_shizai == null)
            {
                result = context.ma_shiyo_b.FirstOrDefault(ma => (ma.cd_hinmei == cd_hinmei));
            }
            else
            {
                result = context.ma_shiyo_b.SingleOrDefault(ma => (ma.cd_hinmei == cd_hinmei
                                                                   && ma.no_han == no_han
                                                                   && ma.cd_shizai == cd_shizai));
            }
            return result;
        }

        /// <summary>
        /// 既存ヘッダーエンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="cd_hinmei">品名コード</param>
        /// <returns>既存ヘッダーエンティティList</returns>
        private List<ma_shiyo_h> GetEntityHeaders(FoodProcsEntities context, string cd_hinmei)
        {
            return context.ma_shiyo_h.Where(ma => (ma.cd_hinmei == cd_hinmei)).ToList();
        }

        /// <summary>
        /// 既存ボディエンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="cd_hinmei">品名コード</param>
        /// <param name="no_han">版番号</param>
        /// <returns>既存ボディエンティティLis</returns>
        private List<ma_shiyo_b> GetEntityBodys(FoodProcsEntities context, string cd_hinmei, decimal no_han)
        {
            List<ma_shiyo_b> resultList = null;
            if (Nullable.Equals<decimal>(null, no_han) || no_han.CompareTo(decimal.Zero) <= 0)
            {
                resultList = context.ma_shiyo_b.Where(ma => (ma.cd_hinmei == cd_hinmei)).ToList();
            }
            else
            {
                resultList = context.ma_shiyo_b.Where(ma => (ma.cd_hinmei == cd_hinmei
                                                                && ma.no_han == no_han)).ToList();
            }
            return resultList;
        }

		/// <summary>
		/// ヘッダーマスタに存在しないチェック（整合性チェック）
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="cd_hinmei">品名コード(資材コード)</param>
		/// <param name="no_han">版番号</param>
		/// <returns>メッセージ文言</returns>
        private string ValidateKeyHeader(FoodProcsEntities context, string cd_hinmei, decimal no_han)
        {
            var master = (from m in context.ma_shiyo_h
                          where m.cd_hinmei == cd_hinmei
                                && m.no_han == no_han
                          select m).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }

        /// <summary>
        /// ボディマスタに存在しないチェック（整合性チェック）
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="cd_hinmei">品名コード(製品コード)</param>
        /// <param name="no_han">版番号</param>
        /// <param name="cd_shizai">資材コード</param>
        /// <returns>メッセージ文言</returns>
        private string ValidateKeyBody(FoodProcsEntities context, string cd_hinmei, decimal no_han, string cd_shizai)
        {
            var master = (from m in context.ma_shiyo_b
                          where m.cd_hinmei == cd_hinmei
                                && m.no_han == no_han
                                && m.cd_shizai == cd_shizai
                          select m).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }

        /// <summary>
        /// 資材コードが重複していないこと。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="entity">対象のエンティティ</param>
        /// <param name="keys">更新対象のキーリスト</param>
        /// <param name="delKeys">既存行の削除対象キーリスト</param>
        /// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateDuplicatKey(FoodProcsEntities context, ma_shiyo_b entity,
            List<dynamic> keys, List<dynamic> delKeys)
        {
            String errMsg = Resources.MS0027;    // エラーメッセージ

            // 既存データをチェック
            var master = (from m in context.ma_shiyo_b
                          where m.cd_hinmei == entity.cd_hinmei
                              && m.no_han == entity.no_han
                              && m.cd_shizai == entity.cd_shizai
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


        // TODO: 同じ有効日付が他の版に存在しないこと。
        private string ValidateKeyHeaderFromDate(FoodProcsEntities context, string cd_hinmei, decimal no_han, DateTime dt_from)
        {
            var master = (from m in context.ma_shiyo_h
                          where m.cd_hinmei == cd_hinmei
                                && m.dt_from == dt_from
                          select m).FirstOrDefault();
            if (master != null && master.no_han == no_han) {
                return string.Empty;
            }
            return master != null ? Resources.MS0691 : string.Empty;
        }
        // TODO：ここまで

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
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象のレコード</param>
        private static void AddKey(List<dynamic> keys, ma_shiyo_b entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.cd_hinmei = entity.cd_hinmei;
            key.no_han = entity.no_han;
            key.cd_shizai = entity.cd_shizai;
            keys.Add(key);
        }
        /// <summary>
        /// 対象のキーを持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キー情報</param>
        /// <param name="created">エンティティ</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_shiyo_b created)
        {
            var re = keys.Find(k => k.cd_hinmei == created.cd_hinmei
                                && k.no_han == created.no_han
                                && k.cd_shizai == created.cd_shizai
                                && k.cd_shizai == created.cd_shizai) != null;
            return re;
        }

	}
}