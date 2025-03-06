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

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class HaigoRecipeMasterController : ApiController
	{

        public StoredProcedureResult<usp_HaigoRecipeMasterJuryoCheck_select_Result>
            Get([FromUri] String cd_hinmei, short kbn_hin, short kbn_jotai_sonota,
                            short kbn_jotai_shikakari, short kbn_hin_genryo, short kbn_hin_shikakari)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HaigoRecipeMasterJuryoCheck_select_Result> views;
            views = context.usp_HaigoRecipeMasterJuryoCheck_select(
                cd_hinmei,
                kbn_hin,
                kbn_jotai_sonota,
                kbn_jotai_shikakari,
                kbn_hin_genryo,
                kbn_hin_shikakari
            ).ToList();

            var result = new StoredProcedureResult<usp_HaigoRecipeMasterJuryoCheck_select_Result>();
            result.d = views;

            return result;
        }    
        
        // POST api/ma_haigo_mei
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSets<ma_haigo_recipe, ma_haigo_mei> value)
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
			DuplicateSets<ma_haigo_recipe, ma_haigo_mei> duplicates = new DuplicateSets<ma_haigo_recipe, ma_haigo_mei>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSets<ma_haigo_recipe, ma_haigo_mei> invalidations = new InvalidationSets<ma_haigo_recipe, ma_haigo_mei>();

			// 変更セットを元に追加対象のエンティティを追加します。
            if (value.First.Created != null)
            {
                foreach (var created in value.First.Created)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKeyFirst(context, created, "Created");

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.First.Add(new Invalidation<ma_haigo_recipe>(validationMessage, created, Resources.Exists));
                        continue;
                    }

                    // UTC時刻をセット
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;
                    // nullの値に0を設定する
                    ma_haigo_recipe saveCreated = setRecipeValue(created);

                    // エンティティを追加します。
                    context.AddToma_haigo_recipe(saveCreated);
                }
            }

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Second.Created != null)
            {
                foreach (var created in value.Second.Created)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKeySecond(context, created, "Created");

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Second.Add(new Invalidation<ma_haigo_mei>(validationMessage, created, Resources.Exists));
                        continue;
                    }
                    else
                    {
                        // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                        validationMessage = ValidateKeyDate(context, created);
                        if (!String.IsNullOrEmpty(validationMessage))
                        {
                            // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                            invalidations.Second.Add(new Invalidation<ma_haigo_mei>(validationMessage, created, Resources.MS0622));
                            continue;
                        }
                    }

                    // UTC時刻をセット
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

                    // エンティティを追加します。
                    context.AddToma_haigo_mei(created);
                }
            }

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.First.Updated != null)
			{
				foreach (var updated in value.First.Updated)
				{
					// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKeyFirst(context, updated, "Updated");

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.First.Add(new Invalidation<ma_haigo_recipe>(validationMessage, updated, Resources.NotExsists));
						continue;
					}

					// 既存エンティティを取得します。
					ma_haigo_recipe current = GetSingleEntityFirst(context, updated);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArrayTs(current.ts, updated.ts))
                    {
                        duplicates.First.Updated.Add(new Duplicate<ma_haigo_recipe>(updated, current));
                        continue;
                    }

                    // UTC時刻をセット
                    updated.dt_update = DateTime.UtcNow;
                    // nullの値に0を設定する
                    ma_haigo_recipe saveUpdated = setRecipeValue(updated);

                    // エンティティを更新します。
                    context.ma_haigo_recipe.ApplyCurrentValues(saveUpdated);
				}
			}

            // 変更セットを元に更新対象のエンティティを更新します。
            if (value.Second.Updated != null)
            {
                foreach (var updated in value.Second.Updated)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKeySecond(context, updated, "Updated");

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Second.Add(new Invalidation<ma_haigo_mei>(validationMessage, updated, Resources.NotExsists));
                        continue;
                    }
                    else
                    {
                        // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                        validationMessage = ValidateKeyDate(context, updated);
                        if (!String.IsNullOrEmpty(validationMessage))
                        {
                            // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                            invalidations.Second.Add(new Invalidation<ma_haigo_mei>(validationMessage, updated, Resources.MS0622));
                            continue;
                        }
                    }

                    // 既存エンティティを取得します。
                    ma_haigo_mei current = GetSingleEntitySecond(context, updated);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArrayTs(current.ts, updated.ts))
                    {
                        duplicates.Second.Updated.Add(new Duplicate<ma_haigo_mei>(updated, current));
                        continue;
                    }

                    // UTC時刻をセット
                    updated.dt_update = DateTime.UtcNow;

                    // エンティティを更新します。
                    context.ma_haigo_mei.ApplyCurrentValues(updated);
                }
            }

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.First.Deleted != null)
            {
                foreach (var deleted in value.First.Deleted)
                {
                    // 既存エンティティを取得します。
                    ma_haigo_recipe current = GetSingleEntityFirst(context, deleted);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArrayTs(current.ts, deleted.ts))
                    {
                        duplicates.First.Deleted.Add(new Duplicate<ma_haigo_recipe>(deleted, current));
                        continue;
                    }
                    
                    // エンティティを削除します。
                    context.DeleteObject(current);
                }
            }

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.Second.Deleted != null)
            {
                foreach (var deleted in value.Second.Deleted)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    // 1版の場合のみ整合性チェック
                    if (deleted.no_han == 1)
                    {
                        //validationMessage = ValidateKeyDeleted(context, deleted);
                        validationMessage = ValidateMasterTable(context, deleted);
                    }
                    else
                    {
                        validationMessage = null;
                    }

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Second.Add(new Invalidation<ma_haigo_mei>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }

                    // 既存エンティティを取得します。
                    ma_haigo_mei current = GetSingleEntitySecond(context, deleted);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArrayTs(current.ts, deleted.ts))
                    {
                        duplicates.Second.Deleted.Add(new Duplicate<ma_haigo_mei>(deleted, current));
                        continue;
                    }
                }
            }

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
            if (invalidations.First.Count > 0 || invalidations.Second.Count > 0)
            {
                // エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSets<ma_haigo_recipe, ma_haigo_mei>>(HttpStatusCode.BadRequest, invalidations);
            }

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
            if (duplicates.First.Created.Count > 0 || duplicates.First.Updated.Count > 0 || duplicates.First.Deleted.Count > 0 ||
                duplicates.Second.Created.Count > 0 || duplicates.Second.Updated.Count > 0 || duplicates.Second.Deleted.Count > 0)
            {
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSets<ma_haigo_recipe, ma_haigo_mei>>(HttpStatusCode.Conflict, duplicates);
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
                        // 変更セットを元に削除対象のエンティティを削除します。
                        if (value.Second.Deleted != null)
                        {
                            foreach (var deleted in value.Second.Deleted)
                            {
                                // 削除用のストアドプロシージャを実行します。
                                if (deleted.no_han == 1)
                                {
                                    context.usp_HaigoMaster_delete(deleted.cd_haigo);
                                    context.usp_HaigoRecipeMaster_delete(deleted.cd_haigo);
                                    context.usp_SeizoLineMaster_delete(deleted.cd_haigo, ActionConst.HaigoMasterKbn);
                                }
                                if (deleted.no_han != 1)
                                {
                                    context.usp_HaigoMaster_delete_han(deleted.cd_haigo, deleted.no_han);
                                    context.usp_HaigoRecipeMaster_delete_han(deleted.cd_haigo, deleted.no_han);
                                }
                            }
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

		/// <summary>
		/// 既存エンティティを取得します。
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="haigo_recipe">検索条件</param>
		/// <returns>既存エンティティ：配合レシピマスタ</returns>
        private ma_haigo_recipe GetSingleEntityFirst(FoodProcsEntities context, ma_haigo_recipe haigo_recipe)
        {
            var result = context.ma_haigo_recipe.SingleOrDefault(ma => (ma.no_han == haigo_recipe.no_han
                                                                    && ma.cd_haigo == haigo_recipe.cd_haigo
                                                                    && ma.no_seq == haigo_recipe.no_seq
                                                                  ));
            return result;
        }

		/// <summary>
		/// 既存エンティティを取得します。
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="haigo_recipe">検索条件</param>
		/// <returns>既存エンティティ：配合名マスタ</returns>
        private ma_haigo_mei GetSingleEntitySecond(FoodProcsEntities context, ma_haigo_mei haigo_mei)
        {
            var result = context.ma_haigo_mei.SingleOrDefault(ma => (ma.cd_haigo == haigo_mei.cd_haigo
                                                                && ma.no_han == haigo_mei.no_han
                                                                ));
            return result;
        }

		/// <summary>
		/// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="haigo_recipe">検索条件</param>
		/// <param name="CRUD">処理種別</param>
		/// <returns>チェック結果</returns>
        private string ValidateKeyFirst(FoodProcsEntities context, ma_haigo_recipe haigo_recipe, String CRUD)
        {
            var master = (from c in context.ma_haigo_recipe
                          where c.cd_haigo == haigo_recipe.cd_haigo
                          && c.no_han == haigo_recipe.no_han
                          && c.no_seq == haigo_recipe.no_seq
                          select c).FirstOrDefault();

            if (CRUD == "Created")
            {
                return master != null ? Resources.MS0027 : string.Empty;
            }
            else if (CRUD == "Updated")
            {
                return master == null ? Resources.MS0027 : string.Empty;
            }
            else
            {
                return master != null ? Resources.MS0027 : string.Empty;
            }
        }

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
		/// <param name="haigo_mei">検索条件</param>
		/// <param name="CRUD">処理種別</param>
		/// <returns>チェック結果</returns>
        private string ValidateKeySecond(FoodProcsEntities context, ma_haigo_mei haigo_mei, String CRUD)
        {
            var master = (from c in context.ma_haigo_mei
                          where c.cd_haigo == haigo_mei.cd_haigo
                          && c.no_han == haigo_mei.no_han
                          select c).FirstOrDefault();

            if (CRUD == "Created")
            {
                return master != null ? Resources.MS0027 : string.Empty;
            }
            else if (CRUD == "Updated")
            {
                return master == null ? Resources.MS0027 : string.Empty;
            }
            else
            {
                return master != null ? Resources.MS0027 : string.Empty;
            }
        }

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="haigo_mei">検索条件</param>
        /// <returns>チェック結果</returns>
        private string ValidateKeyDate(FoodProcsEntities context, ma_haigo_mei haigo_mei)
        {
            var master = (from c in context.ma_haigo_mei
                          where c.cd_haigo == haigo_mei.cd_haigo
                          && c.dt_from == haigo_mei.dt_from
                          && c.no_han != haigo_mei.no_han
                          select c).FirstOrDefault();

                return master != null ? Resources.MS0622 : string.Empty;
        }

        /// <summary>
        /// 削除時の整合性チェック (マスタ存在チェックなど) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="haigo_mei">検索条件</param>
        /// <returns>チェック結果</returns>
        private string ValidateKeyDeleted(FoodProcsEntities context, ma_haigo_mei haigo_mei)
        {
            // 戻り値を定義
            var status = new ObjectParameter("status", 0);
            var table = new ObjectParameter("table", 0);
            // ストアド実行
            var result = context.usp_Haigo_delete_chk(haigo_mei.cd_haigo, status, table);
            // 戻り値からメッセージを判断
            return (int)status.Value == 0 ? string.Empty : String.Format(Resources.MS0001, table.Value);
        }

		/// <summary>
        /// 整合性チェック：対象のテーブルに存在する場合は削除不可
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="ma">対象のエンティティ</param>
		/// <returns>チェック結果</returns>
        private String ValidateMasterTable(FoodProcsEntities context, ma_haigo_mei ma)
        {
            string condition = ma.cd_haigo;

            /////// 風袋決定マスタ(ma_futai_kettei) ///////
            var maFutaiKettei = (from m in context.ma_futai_kettei
                                 where m.cd_hinmei == condition
                                 select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maFutaiKettei != null)
            {
                return getValidateErrorMassage(Resources.FutaiKetteiMaster, condition);
            }

            /////// 品名マスタ(ma_hinmei) ///////
            var maHinmei = (from m in context.ma_hinmei
                                 where m.cd_haigo == condition
                                 select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maHinmei != null)
            {
                return getValidateErrorMassage(Resources.HinmeiMaster, condition);
            }

            /////// 重量マスタ(ma_juryo) ///////
            var maJuryo = (from m in context.ma_juryo
                           where m.cd_hinmei == condition
                           select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maJuryo != null)
            {
                return getValidateErrorMassage(Resources.JuryoMaster, condition);
            }

            // エラーなし：空文字を返却
            return string.Empty;
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

        /// <summary>
        /// タイムスタンプの値を比較します。
        /// </summary>
        /// <param name="left">値1</param>
        /// <param name="right">値2</param>
        /// <returns>チェック結果</returns>
		private bool CompareByteArrayTs(byte[] left, byte[] right)
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
        /// 値がnullの場合は0を設定する
        /// </summary>
        /// <param name="model">変更対象の明細情報</param>
        /// <returns>設定後の明細情報</returns>
        private ma_haigo_recipe setRecipeValue(ma_haigo_recipe model)
        {
            ///// 値がnullの場合は0を設定する
            // 配合重量
            if (model.wt_shikomi == null)
            {
                model.wt_shikomi = 0;
            }
            // 荷姿数
            if (model.wt_nisugata == null)
            {
                model.wt_nisugata = 0;
            }
            // 小分数
            if (model.wt_kowake == null)
            {
                model.wt_kowake = 0;
            }

            return model;
        }

   }

}