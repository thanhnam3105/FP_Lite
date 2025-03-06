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
	public class HaigoMasterController : ApiController
	{
		// POST api/ma_haigo_mei
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSets<ma_haigo_mei, ma_haigo_recipe, ma_seizo_line> value)
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
            DuplicateSets<ma_haigo_mei, ma_haigo_recipe, ma_seizo_line> duplicates =
                new DuplicateSets<ma_haigo_mei, ma_haigo_recipe, ma_seizo_line>();

            // 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSets<ma_haigo_mei, ma_haigo_recipe, ma_seizo_line> invalidations =
                new InvalidationSets<ma_haigo_mei, ma_haigo_recipe, ma_seizo_line>();

			// 変更セットを元に追加対象のエンティティを追加します。
			if (value.First.Created != null)
			{
				foreach (var created in value.First.Created)
				{
					// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
					validationMessage = ValidateKeyFirst(context, created);

					if (!String.IsNullOrEmpty(validationMessage))
					{
                        // バリデーションエラーの発生した列名を指定してInvalidationSetsを追加します。
                        invalidations.First.Add(new Invalidation<ma_haigo_mei>(validationMessage, created, Resources.Exists));
						continue;
					}

                    // UTC時刻をセット
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

					// エンティティを追加します。
					context.AddToma_haigo_mei(created);
				}
			}

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Second.Created != null)
            {
                foreach (var created in value.Second.Created)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKeySecond(context, created);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetsを追加します。
                        invalidations.Second.Add(new Invalidation<ma_haigo_recipe>(validationMessage, created, Resources.Exists));
                        continue;
                    }

                    // UTC時刻をセット
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

                    // エンティティを追加します。
                    context.AddToma_haigo_recipe(created);
                }
            }

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Third.Created != null)
            {
                foreach (var created in value.Third.Created)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateKeyThird(context, created);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetsを追加します。
                        invalidations.Third.Add(new Invalidation<ma_seizo_line>(validationMessage, created, Resources.Exists));
                        continue;
                    }

                    // UTC時刻をセット
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

                    // エンティティを追加します。
                    context.AddToma_seizo_line(created);
                }
            }

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.First.Updated != null)
			{
				foreach (var updated in value.First.Updated)
				{
					// 既存エンティティを取得します。
					ma_haigo_mei current = GetSingleEntityFirst(context, updated.cd_haigo, updated.no_han);

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArrayTs(current.ts, updated.ts))
					{
                        duplicates.First.Updated.Add(new Duplicate<ma_haigo_mei>(updated, current));

						continue;
					}
				}
			}

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
            if (invalidations.First.Count > 0 || invalidations.Second.Count > 0)
			{
				// エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSets<ma_haigo_mei, ma_haigo_recipe, ma_seizo_line>>(HttpStatusCode.BadRequest, invalidations);
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.First.Created.Count > 0 || duplicates.First.Updated.Count > 0 || duplicates.First.Deleted.Count > 0 ||
                duplicates.Second.Created.Count > 0 || duplicates.Second.Updated.Count > 0 || duplicates.Second.Deleted.Count > 0 ||
                duplicates.Third.Created.Count > 0 || duplicates.Third.Updated.Count > 0 || duplicates.Third.Deleted.Count > 0)
			{
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSets<ma_haigo_mei, ma_haigo_recipe, ma_seizo_line>>(HttpStatusCode.Conflict, duplicates);
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
                        // 変更セットを元に更新対象のエンティティを更新します。
                        if (value.First.Updated != null)
                        {
                            foreach (var updated in value.First.Updated)
                            {
                                if (updated.kbn_shiagari != ActionConst.manualKanzanKbn)
                                {
                                    // エンティティを更新します。
                                    // 引数の定義
                                    var wt_haigo_gokei = new ObjectParameter("wt_haigo_gokei", typeof(global::System.Decimal));
                                    //wt_haigo_gokei.Value = 100.000000m;   // 100.000000だとdecimal(9, 6)になってしまう
                                    wt_haigo_gokei.Value = 100000.000000m;  // decimal(12, 6)にする為に100000.000000を代入
                                    // ストアド実行
                                    // 配合重量計を取得
                                    context.usp_HaigoRecipeMaster_select(
                                        updated.cd_haigo
                                        , updated.no_han
                                        , updated.kbn_kanzan
                                        , wt_haigo_gokei
                                        , ActionConst.GenryoHinKbn
                                        , ActionConst.ShikakariHinKbn
                                        , ActionConst.JikaGenryoHinKbn
                                        , ActionConst.KgKanzanKbn
                                        , ActionConst.LKanzanKbn
                                    );
                                    // 取得した配合重量計を反映
                                    var wtHaigoGokei = Math.Floor((decimal)wt_haigo_gokei.Value * 1000) / 1000;
                                    updated.wt_haigo_gokei = wtHaigoGokei;
                                }
                                updated.dt_update = DateTime.UtcNow;
                                // update実行
                                context.usp_HaigoMaster_update(
                                    updated.cd_haigo
                                    , updated.nm_haigo_ja
                                    , updated.nm_haigo_en
                                    , updated.nm_haigo_zh
                                    , updated.nm_haigo_vi
                                    , updated.nm_haigo_ryaku
                                    , updated.ritsu_budomari
                                    , updated.wt_kihon
                                    , updated.ritsu_kihon
                                    , updated.flg_gassan_shikomi
                                    , updated.wt_saidai_shikomi
                                    , updated.no_han
                                    , updated.wt_haigo
                                    , updated.wt_haigo_gokei
                                    , updated.biko
                                    , updated.no_seiho
                                    , updated.cd_tanto_seizo
                                    , updated.dt_seizo_koshin
                                    , updated.cd_tanto_hinkan
                                    , updated.dt_hinkan_koshin
                                    , updated.dt_from
                                    , updated.kbn_kanzan
                                    , updated.ritsu_hiju
                                    , updated.flg_shorihin
                                    , updated.flg_tanto_hinkan
                                    , updated.flg_tanto_seizo
                                    , updated.kbn_shiagari
                                    , updated.cd_bunrui
                                    , updated.flg_mishiyo
                                    , updated.dt_create
                                    , updated.cd_create
                                    , updated.dt_update
                                    , updated.cd_update
                                    , updated.wt_kowake
                                    , updated.su_kowake
                                    , updated.flg_tenkai
                                    , updated.dd_shomi
                                    , updated.kbn_hokan
                                );
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
		/// <param name="cd_haigo">配合コード</param>
		/// <param name="no_han">版番号</param>
		/// <returns>既存エンティティ</returns>
		private ma_haigo_mei GetSingleEntityFirst(FoodProcsEntities context, string cd_haigo, decimal no_han )
		{
			var result = context.ma_haigo_mei.SingleOrDefault(ma => (ma.cd_haigo == cd_haigo
                                                                && ma.no_han == no_han));

			return result;
		}

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="haigo_mei">マスタ情報</param>
        /// <returns>結果：エラーの場合はメッセージを返却</returns>
		private string ValidateKeyFirst(FoodProcsEntities context, ma_haigo_mei haigo_mei)
		{
			var master = (from c in context.ma_haigo_mei
						  where c.cd_haigo == haigo_mei.cd_haigo
                          && c.no_han == haigo_mei.no_han
						  select c).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
		}

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="haigo_recipe">マスタ情報</param>
        /// <returns>結果：エラーの場合はメッセージを返却</returns>
        private string ValidateKeySecond(FoodProcsEntities context, ma_haigo_recipe haigo_recipe)
        {
            var master = (from c in context.ma_haigo_recipe
                          where c.cd_haigo == haigo_recipe.cd_haigo
                          && c.no_han == haigo_recipe.no_han
                          select c).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="seizo_line">マスタ情報</param>
        /// <returns>結果：エラーの場合はメッセージを返却</returns>
        private string ValidateKeyThird(FoodProcsEntities context, ma_seizo_line seizo_line)
        {
            var master = (from c in context.ma_seizo_line
                          where c.cd_haigo == seizo_line.cd_haigo
                          && c.kbn_master == seizo_line.kbn_master
                          && c.no_juni_yusen == seizo_line.no_juni_yusen
                          && c.cd_line == seizo_line.cd_line
                          select c).FirstOrDefault();

            return master != null ? Resources.MS0027 : string.Empty;
        }

		/// <summary>
		/// タイムスタンプの値を比較します。
		/// </summary>
		/// <param name="left">値1</param>
		/// <param name="right">値2</param>
		/// <returns>比較結果</returns>
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
	}
}