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
	public class GenshizaiKonyusakiMasterController : ApiController
	{
		// POST api/ma_konyu
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_konyu> value)
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
			DuplicateSet<ma_konyu> duplicates = new DuplicateSet<ma_konyu>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_konyu> invalidations = new InvalidationSet<ma_konyu>();

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
                List<dynamic> yusenKeys = new List<dynamic>();   // 優先順位の重複チェック用：追加対象キーリスト
                List<dynamic> createKeys = new List<dynamic>();   // 取引先コードの重複チェック用：追加対象キーリスト

                foreach (var created in value.Created)
				{
					// ===== 重複チェック ==========
                    // キー項目
                    validationMessage = ValidateKey(context, created, yusenKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_konyu>(validationMessage, created, Resources.DuplicateKey));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // 優先順位用のキーリストに追加
                    AddYusenKey(yusenKeys, created);

                    // 同原資材内で取引先が重複していないこと
                    validationMessage = ValidateTorihikiCode(context, created, createKeys, updateKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_konyu>(validationMessage, created, Resources.DuplicateItem));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // 追加行内だけのキーをチェック用キーリストに追加
                    AddKey(createKeys, created);
					// ===== 重複チェック：ここまで ==========

                    // 納入単位のマスタ存在チェック
                    validationMessage = ValidateNonyuTani(context, created);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_konyu>(validationMessage, created, Resources.NotExsists));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        break;
                    }
                    
                    // 新規作成時の取引先コード(物流)、取引先コード（商流）を取得します。
                    string cd_target = created.cd_torihiki;
                    string cd_target2 = created.cd_torihiki2;

                    // 取引先コードの小文字を大文字に変換を行います。
                    if (cd_target != null)
                    {
                        created.cd_torihiki = cd_target.ToUpper();
                    }
                    if (cd_target2 != null)
                    {
                        created.cd_torihiki2 = cd_target2.ToUpper();
                    }
                    // エンティティを追加します。
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
                    context.AddToma_konyu(created);
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null && !flgSkip)
			{
                List<dynamic> keys = new List<dynamic>();   // 重複チェック用：取引先キーリスト

                // 後勝ちで更新
				foreach (var updated in value.Updated)
				{
                    // 既存エンティティを取得します。
                    ma_konyu current = GetSingleEntity(context, updated.cd_hinmei, updated.no_juni_yusen);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts))
					{
                        duplicates.Updated.Add(new Duplicate<ma_konyu>(updated, current));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
					// 重複チェック：同原資材内で取引先が重複していないこと
                    validationMessage = ValidateTorihikiCode(context, updated, new List<dynamic>(), updateKeys, deleteKeys);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_konyu>(validationMessage, updated, Resources.DuplicateItem));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }
                    // 更新行内だけのキー重複チェック
                    AddKey(keys, updated);

                    // 納入単位のマスタ存在チェック
                    validationMessage = ValidateNonyuTani(context, updated);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_konyu>(validationMessage, updated, Resources.NotExsists));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        flgSkip = true;
                        break;
                    }

                    // 更新時の取引先コード(物流)、取引先コード（商流）を取得します。
                    string cd_target = updated.cd_torihiki;
                    string cd_target2 = updated.cd_torihiki2;

                    // 取引先コードの小文字を大文字に変換を行います。
                    if (cd_target != null)
                    {
                        updated.cd_torihiki = cd_target.ToUpper();
                    }
                    if (cd_target2 != null)
                    {
                        updated.cd_torihiki2 = cd_target2.ToUpper();
                    }

                    // エンティティを更新します。
                    updated.dt_update = DateTime.UtcNow;
                    updated.dt_create = current.dt_create;
                    updated.cd_create = current.cd_create;
                    context.ma_konyu.ApplyOriginalValues(updated);
                    context.ma_konyu.ApplyCurrentValues(updated);
				}
			}

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null && !flgSkip)
            {
                foreach (var deleted in value.Deleted)
                {

                    // 既存エンティティを取得します。
                    ma_konyu current = GetSingleEntity(context, deleted.cd_hinmei, deleted.no_juni_yusen);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null)
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_konyu>(deleted, current));
                        //continue;
                        // エラーが発生した時点で処理終了。エラーを画面に返す。
                        break;
                    }

                    // ★★ TODO ★★ 設計書(CRUD図)が完成次第、実装する
                    // 整合性チェック：削除時、対象テーブルに該当データが存在する場合はエラー
                    //validationMessage = ValidateMaHaigoMei(context, deleted);
                    //if (!String.IsNullOrEmpty(validationMessage))
                    //{
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        //invalidations.Add(new Invalidation<ma_konyu>(validationMessage, deleted, Resources.UnDeletableRecord));
                        //continue;
                    //}

                    // エンティティを削除します。
                    context.DeleteObject(current);
                }
            }

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
			if (invalidations.Count > 0)
			{
				// エンティティの型に応じたInvalidationSetを返します。
				return Request.CreateResponse<InvalidationSet<ma_konyu>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Updated.Count > 0)
			{
				// エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_konyu>>(HttpStatusCode.Conflict, duplicates);
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
		/// <param name="context">エンティティ情報</param>
		/// <param name="cd_hinmei">原資材コード</param>
		/// <param name="no_yusen">優先順</param>
		/// <returns>取得結果</returns>
		private ma_konyu GetSingleEntity(FoodProcsEntities context, String cd_hinmei, short no_yusen)
		{
            var result = context.ma_konyu.SingleOrDefault(
                ma => ma.cd_hinmei == cd_hinmei && ma.no_juni_yusen == no_yusen);

			return result;
		}

		/// <summary>
		/// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="konyu">1レコード分の原資材購入先マスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateKey(FoodProcsEntities context, ma_konyu konyu, List<dynamic> keys, List<dynamic> delKeys)
        {
            var master = (from m in context.ma_konyu
                          where m.cd_hinmei == konyu.cd_hinmei
                          && m.no_juni_yusen == konyu.no_juni_yusen
                          select m).FirstOrDefault();

            if (master != null)
            {
                // キーリストにない かつ 削除対象に存在する場合はエラーとしない
                if (!ContainsKey(keys, konyu) && ContainsKey(delKeys, konyu))
                {
                    return String.Empty;
                }
                return Resources.MS0027;
            }
            else if (ContainsKey(keys, konyu))
            {
                return Resources.MS0027;
            }

            return String.Empty;
        }

		/// <summary>
		/// エンティティに対する納入単位のマスタ存在チェックを行います。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="konyu">1レコード分の原資材購入先マスタ情報</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateNonyuTani(FoodProcsEntities context, ma_konyu konyu)
        {
            short flg_mishiyo = short.Parse(Resources.FlagFalse);
            var master = (from m in context.ma_tani
                          where m.cd_tani == konyu.cd_tani_nonyu
                          && m.flg_mishiyo == flg_mishiyo
                          select m).FirstOrDefault();

            // 存在しない場合、メッセージを返します
            return master == null ? String.Format(Resources.MS0049, Resources.NonyuTani) : string.Empty;
        }

		/// <summary>
        /// 取引先コードが重複していないこと。
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="konyu">1レコード分の原資材購入先マスタ情報</param>
		/// <param name="keys">更新対象のキーリスト</param>
		/// <param name="upKeys">既存行の更新対象キーリスト</param>
		/// <param name="delKeys">既存行の削除対象キーリスト</param>
		/// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateTorihikiCode(FoodProcsEntities context, ma_konyu konyu,
            List<dynamic> keys, List<dynamic> upKeys, List<dynamic> delKeys)
        {
            String errMsg = String.Format(Resources.MS0045, Resources.TorihikisakiCode);    // エラーメッセージ

            var master = (from m in context.ma_konyu
                          where m.cd_hinmei == konyu.cd_hinmei
                                && m.cd_torihiki == konyu.cd_torihiki
                                && m.no_juni_yusen != konyu.no_juni_yusen
                          select m).FirstOrDefault();

            // キーリストが渡されている場合、取得した情報/入力された情報がキーリストに存在するかをチェックする
            dynamic index = null;

            // 新規追加行のキーリスト
            if (keys.Count > 0)
            {
                if (ContainsKeyTorihikisaki(keys, konyu))
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
                    index = upKeys.Find(k => k.no_juni_yusen == master.no_juni_yusen);
                    if (index != null)
                    {
                        // 存在するかつ取引先コードが同じだった場合、メッセージを返す
                        if (index.cd_torihiki == konyu.cd_torihiki)
                        {
                            return errMsg;
                        }
                        // 取引先コードが違う場合、画面で編集されているので重複エラーとしない

                        // 入力情報でキーリストをチェック
                        index = upKeys.Find(k => k.cd_torihiki == konyu.cd_torihiki);
                        if (index != null)
                        {
                            if (index.no_juni_yusen != konyu.no_juni_yusen)
                            {
                                return errMsg;
                            }
                            // 同じ優先順位は自分なので、エラーとしない
                        }
                    }
                    else
                    {
                        if (!ContainsKey(delKeys, master))
                        {
                            // マスタ結果が更新対象キーリストに存在しない かつ 削除対象のキーリストに存在しない場合はエラー
                            return errMsg;
                        }
                        else
                        {
                            // 入力情報でキーリストをチェック
                            index = upKeys.Find(k => k.cd_torihiki == konyu.cd_torihiki);
                            if (index != null)
                            {
                                if (index.no_juni_yusen != konyu.no_juni_yusen)
                                {
                                    return errMsg;
                                }
                                // 同じ優先順位は自分なので、エラーとしない
                            }
                            //else
                            //{
                            //    // 更新対象キーリストに存在しない場合、削除対象のキーリストに存在するかをチェック
                            //    if (!ContainsKey(delKeys, master))
                            //    {
                            //        // 削除対象のキーリストにも存在しない場合はエラー
                            //        return errMsg;
                            //    }
                            //    // 削除対象のキーリストに存在した場合はエラーとしない
                            //}
                        }
                    }
                }
                // マスタ検索結果が存在しない場合：入力情報でキーリストをチェック
                else
                {
                    index = upKeys.Find(k => k.cd_torihiki == konyu.cd_torihiki);
                    if (index != null)
                    {
                        if (index.no_juni_yusen != konyu.no_juni_yusen)
                        {
                            return errMsg;
                        }
                        // 同じ優先順位は自分なので、エラーとしない
                    }
                }
            }
            else
            {
                // マスタ検索結果が存在し、マスタの優先順位が削除対象キーリストに存在しなければ重複エラー
                if (master != null && !ContainsKey(delKeys, master))
                {
                    return errMsg;
                }
            }

            return string.Empty;
        }

        //// TODO：他テーブルに存在する場合はエラー(2013.10.23時点：CRUD図作成中のため未実装)
		/// <summary>
        /// XXXXテーブル 
		/// </summary>
		/// <param name="context">エンティティ情報</param>
		/// <param name="konyu">1レコード分の原資材購入先マスタ情報</param>
		/// <returns>チェック結果</returns>
        private String ValidateMaHaigoMei(FoodProcsEntities context, ma_konyu konyu)
        {
            String tbl = null;
            //var tbl = (from m in context.ma_haigo_mei
            //              where bunrui.kbn_hin == hinkbn
            //                    && m.cd_bunrui == bunrui.cd_bunrui
            //              select m).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return tbl != null ? String.Format(Resources.MS0001, "★パラメーター") : string.Empty;
        }

        /// <summary>
        /// 対象のキー(優先順位)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, ma_konyu entity)
        {
            return keys.Find(k => k.no_juni_yusen == entity.no_juni_yusen) != null;
        }

        /// <summary>
        /// 対象のキー(取引先コード)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKeyTorihikisaki(List<dynamic> keys, ma_konyu entity)
        {
            return keys.Find(k => k.cd_torihiki == entity.cd_torihiki) != null;
        }

        /// <summary>
		///  タイムスタンプの値を比較します。
		/// </summary>
		/// <param name="left">タイムスタンプ1</param>
		/// <param name="right">タイムスタンプ2</param>
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
        /// 優先順位のキー情報を登録します。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">エンティティ</param>
        private static void AddYusenKey(List<dynamic> keys, ma_konyu entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.no_juni_yusen = entity.no_juni_yusen;
            keys.Add(key);
        }

        /// <summary>
        /// エンティティに対するキー情報を登録します。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象のレコード</param>
        private static void AddKey(List<dynamic> keys, ma_konyu entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.no_juni_yusen = entity.no_juni_yusen;
            key.cd_torihiki = entity.cd_torihiki;
            keys.Add(key);
        }
	}
}