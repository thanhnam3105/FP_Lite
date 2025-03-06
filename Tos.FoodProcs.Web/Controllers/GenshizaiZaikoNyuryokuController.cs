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

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class GenshizaiZaikoNyuryokuController : ApiController
	{
        // GET api/GenshizaiZaikoNyuryoku
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_GenshizaiZaikoNyuryoku_select_Result> Get([FromUri]GenshizaiZaikoNyuryokuCriteria criteria) {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiZaikoNyuryoku_select_Result> views;
            views = context.usp_GenshizaiZaikoNyuryoku_select(
                criteria.con_dt_zaiko,
                criteria.con_kbn_hin,
                criteria.con_hin_bunrui,
                criteria.con_kurabasho,
                FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei),
                criteria.flg_shiyobun,
                criteria.flg_zaiko,
                criteria.hasu_floor_decimal,
                criteria.hasu_ceil_decimal,
                criteria.lang,
                criteria.shiyo_flag,
                criteria.mishiyo_flag,
                criteria.tani_kg,
                criteria.tani_L,
                criteria.genryo,
                criteria.shizai,
                criteria.jikagenryo,
                criteria.kbn_zaiko,
                criteria.cd_soko,
                ActionConst.kbn_zaiko_horyu
                ).AsEnumerable();
            return views;
        }

        // POST api/GenshizaiZaikoNyuryoku
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
        // BRC quang.l 2022/04/21 #1699 Start -->
        // public HttpResponseMessage Post([FromBody]ChangeSet<tr_zaiko> value)
        public HttpResponseMessage Post([FromBody]ChangeSet<ZaikoUpdObject> value)
        // BRC quang.l 2022/04/21 #1699 End <--
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

            //// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<tr_zaiko> duplicates = new DuplicateSet<tr_zaiko>();

            //// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            //InvalidationSet<tr_zaiko> invalidations = new InvalidationSet<tr_zaiko>();

			// 変更セットを元に追加対象のエンティティを追加します。
			if (value.Created != null)
			{
                // 後勝ちで更新
				foreach (var created in value.Created)
				{
                    // 既存エンティティを取得します。
                    tr_zaiko current = GetSingleEntity(context,
                        created.cd_hinmei, created.dt_hizuke, created.kbn_zaiko, created.cd_soko);

                    // BRC quang.l 2022/04/21 #1699 Start -->
                    // 更新用エンティティを取得します
                    tr_zaiko updEntity = GetSingleEntity(created);
                    // BRC quang.l 2022/04/21 #1699 End <--

                    // 更新日にUTCシステム日付を設定
                    created.dt_update = DateTime.UtcNow;

                    // 既存エンティティが存在した場合は更新処理
                    // 値が存在しない場合は新規作成
                    if (current != null)
                    {
                        // BRC quang.l 2022/04/21 #1699 Start -->
                        // エンティティを更新します。
                        //context.tr_zaiko.ApplyOriginalValues(created);
                        //context.tr_zaiko.ApplyCurrentValues(created);
                        context.tr_zaiko.ApplyOriginalValues(updEntity);
                        context.tr_zaiko.ApplyCurrentValues(updEntity);
                        // BRC quang.l 2022/04/21 #1699 End <--
                        continue;
                    }
                    else
                    {
                        // BRC quang.l 2022/04/21 #1699 Start -->
                        // エンティティを追加します。
                        //context.AddTotr_zaiko(created);
                        context.AddTotr_zaiko(updEntity);
                        // BRC quang.l 2022/04/21 #1699 End <--
                    }
				}
			}

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null)
			{
                // BRC quang.l 2022/04/21 #1699 Start -->
                //foreach (var updated in value.Updated)
                //{
                //    // 既存エンティティを取得します。
                //    tr_zaiko current = GetSingleEntity(context,
                //        updated.cd_hinmei, updated.dt_hizuke, updated.kbn_zaiko, updated.cd_soko);

                //    // 更新日にUTCシステム日付を設定
                //    updated.dt_update = DateTime.UtcNow;

                //    // 既存エンティティが存在した場合は更新処理
                //    // 値が存在しない場合は新規作成
                //    if (current != null)
                //    {
                //        // エンティティを更新します。
                //        context.tr_zaiko.ApplyOriginalValues(updated);
                //        context.tr_zaiko.ApplyCurrentValues(updated);
                //        continue;
                //    }
                //    else
                //    {
                //        // エンティティを追加します。
                //        context.AddTotr_zaiko(updated);
                //    }
                //}
                try
                {
                    foreach (var updated in value.Updated)
                    {
                        // 既存エンティティを取得します。
                        tr_zaiko current = GetSingleEntity(context,
                            updated.cd_hinmei, updated.dt_hizuke, updated.kbn_zaiko, updated.cd_soko);
                        
                        // 更新用エンティティを取得します
                        tr_zaiko updEntity = GetSingleEntity(updated);

                        // 既存エンティティが存在した場合は更新処理
                        // 値が存在しない場合は新規作成
                        if (current != null)
                        {
                            // ユーザー操作：新規
                            if (updated.dt_update == null)
                            {
                                // ユーザーにより編集されるか確認
                                if (updated.su_zaiko != 0 || (updated.tan_tana != updated.tan_tana_bef))
                                {
                                    // 排他チェック
                                    // 実在庫が0でない、または単価が検索時の値と異なる場合はユーザー入力あり行
                                    if (current.su_zaiko != 0 || current.tan_tana != updated.tan_tana_bef)
                                    {
                                        // DB保存情報：実在庫または単価が初期値でない場合
                                        // -> 新規保存時の同時操作につき排他エラーとする
                                        string errorMsg = String.Format(Resources.MS0823);
                                        InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                        ioe.Data.Add("key", "MS0823");
                                        throw ioe;
                                    }
                                    else
                                    {
                                        // DB保存情報：実在庫と単価が初期値の場合
                                        // -> 更新して問題なし

                                        // 更新日にUTCシステム日付を設定
                                        updEntity.dt_update = DateTime.UtcNow;

                                        // エンティティを更新します。
                                        context.tr_zaiko.ApplyOriginalValues(updEntity);
                                        context.tr_zaiko.ApplyCurrentValues(updEntity);
                                    }
                                }
                                else
                                {
                                    // 実在庫が0かつ単価が検索時の値と同じ場合はユーザー入力なし行
                                    // -> 更新しない
                                    continue;
                                }                                
                            }
                            // ユーザー操作：更新
                            else
                            {
                                // 排他チェック
                                if (updated.dt_update != current.dt_update)
                                {
                                    // 対象行のdt_updateがDBと一致しなかった場合
                                    // -> 排他エラーとする
                                    string errorMsg = String.Format(Resources.MS0823);
                                    InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                    ioe.Data.Add("key", "MS0823");
                                    throw ioe;
                                }
                                // 対象行のdt_updateがDBと一致する場合
                                else
                                {
                                    // 更新日にUTCシステム日付を設定
                                    updEntity.dt_update = DateTime.UtcNow;

                                    // エンティティを更新します。
                                    context.tr_zaiko.ApplyOriginalValues(updEntity);
                                    context.tr_zaiko.ApplyCurrentValues(updEntity);
                                }
                            }
                        }
                        else
                        {
                            // 更新日にUTCシステム日付を設定
                            updEntity.dt_update = DateTime.UtcNow;

                            // エンティティを追加します。
                            context.AddTotr_zaiko(updEntity);
                        }
                    }
                }
                catch (InvalidOperationException ioe)
                {
                    var errCode = ioe.Data["key"];
                    if (errCode != null)
                    {
                        return Request.CreateResponse(HttpStatusCode.BadRequest, ioe);
                    }
                    throw ioe;
                }
                // BRC quang.l 2022/04/21 #1699 End <--
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
            //if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
            if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0)
            {
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<tr_zaiko>>(HttpStatusCode.Conflict, duplicates);
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
		/// <param name="key1">検索キー：品名コード</param>
		/// <param name="key2">検索キー：日付</param>
		/// <param name="key3">検索キー：在庫区分</param>
		/// <param name="key4">検索キー：倉庫コード</param>
		/// <returns>既存データ</returns>
        private tr_zaiko GetSingleEntity(FoodProcsEntities context, String key1, DateTime key2, short key3, String key4)
		{
            var result = context.tr_zaiko.SingleOrDefault(tr => tr.cd_hinmei == key1
                                                            && tr.dt_hizuke == key2
                                                            && tr.kbn_zaiko == key3
                                                            && tr.cd_soko == key4);
			return result;
		}

        // BRC quang.l 2022/04/21 #1699 Start -->
        /// <summary>
        /// 更新エンティティを取得します。
        /// </summary>
        /// <param name="zaikoUpdObject">更新データ</param>
        /// <returns>更新データ</returns>
        private tr_zaiko GetSingleEntity(ZaikoUpdObject zaikoUpdObject)
        {
            tr_zaiko result = new tr_zaiko();

            result.cd_hinmei = zaikoUpdObject.cd_hinmei;
            result.dt_hizuke = zaikoUpdObject.dt_hizuke;
            result.su_zaiko = zaikoUpdObject.su_zaiko;
            result.dt_jisseki_zaiko = zaikoUpdObject.dt_jisseki_zaiko;
            result.dt_update = zaikoUpdObject.dt_update;
            result.cd_update = zaikoUpdObject.cd_update;
            result.tan_tana = zaikoUpdObject.tan_tana;
            result.kbn_zaiko = zaikoUpdObject.kbn_zaiko;
            result.cd_soko = zaikoUpdObject.cd_soko;
            
            return result;
        }
        // BRC quang.l 2022/04/21 #1699 End <--
    }
}