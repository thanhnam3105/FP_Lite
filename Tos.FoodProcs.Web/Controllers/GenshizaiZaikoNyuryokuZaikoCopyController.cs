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
    public class GenshizaiZaikoNyuryokuZaikoCopyController : ApiController
    {
        // GET api/GenshizaiZaikoNyuryokuZaikocopy
        /// <summary>
        /// クライアントから送信された検索条件を基にデータ抽出・更新を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public HttpResponseMessage Post([FromUri]GenshizaiZaikoNyuryokuCriteria criteria, string cd_update)
        {
            IEnumerable<usp_GenshizaiZaikoNyuryoku_select_Result> views;

            FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;

            //// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<tr_zaiko> duplicates = new DuplicateSet<tr_zaiko>();

            //更新対象データ抽出
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
                ).ToList();

            foreach (usp_GenshizaiZaikoNyuryoku_select_Result item in views){
                //検索プロシージャ上、在庫トランはLEFT JOINで結合している為、
                //レコードはあるが、実在庫数カラムのみがNULLの場合も条件にかかってしまう。
                //(サービス上このパターンはないはずだが、RDBテーブル構成上可能)
                //在庫トラン上、NULL許可していないキー項目でも同時にnullチェックを行い、
                //在庫トランがレコード単位でnullであることまでチェックする。
                if ((item.zaiko_hizuke == null) && (item.jitsu_zaiko_su == null))
                {
                    //エンティティ更新データセット                    
                    var updated = new Tos.FoodProcs.Web.Data.tr_zaiko();
                    updated.cd_hinmei = item.cd_hinmei;
                    updated.dt_hizuke = criteria.con_dt_zaiko;
                    updated.su_zaiko = item.su_keisan_zaiko <= 0 ? 0 : item.su_keisan_zaiko;    //計算在庫数を実在庫数にセット
                    updated.dt_jisseki_zaiko = DateTime.UtcNow;
                    updated.cd_update = cd_update;
                    updated.tan_tana = item.tan_tana;
                    updated.kbn_zaiko = criteria.kbn_zaiko;
                    //updated.cd_soko = criteria.cd_soko;
                    updated.cd_soko = item.cd_soko;

                    // 既存エンティティを取得します。
                    tr_zaiko current = GetSingleEntity(context,
                        updated.cd_hinmei, updated.dt_hizuke, updated.kbn_zaiko, updated.cd_soko);                   

                    // 更新日にUTCシステム日付を設定
                    updated.dt_update = DateTime.UtcNow;

                    // 既存エンティティが存在した場合は処理しない
                    // 値が存在しない場合は新規作成
                    if (current == null){
                        // エンティティを追加します。
                        context.AddTotr_zaiko(updated);
                    }else{
                        continue;
                    }
                }
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

            //更新完了
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
    }
}