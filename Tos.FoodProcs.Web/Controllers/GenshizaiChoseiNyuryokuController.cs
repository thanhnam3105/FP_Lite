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
    public class GenshizaiChoseiNyuryokuController : ApiController
    {



        // GET api/GenshizaiChoseiNyuryoku
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_GenshizaiChoseiNyuryoku_select_Result> Get([FromUri]GenshizaiChoseiNyuryokuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiChoseiNyuryoku_select_Result> views;
            tr_shiyo_shikakari_zan current = GetSingleEntity(context, criteria.kbn_shiyo_jisseki_anbun, criteria.no_lot, criteria.no_seq_shiyo_yojitsu_anbun);

            var result = new StoredProcedureResult<usp_GenshizaiChoseiNyuryoku_select_Result>();

            var count = new ObjectParameter("count", 0);
            views = context.usp_GenshizaiChoseiNyuryoku_select(
                criteria.before_su_chosei
                , criteria.after_su_chosei
                , criteria.no_lot_seihin
                , count).ToList();

            result.d = views;
            result.__count = (int)count.Value;

            return result;
        }


        // POST api/GenshizaiChoseiNyuryoku
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<GenshizaiChoseiNyuryokuDataCriteria> value)
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
            DuplicateSets<tr_chosei, tr_shiyo_shikakari_zan> duplicates = new DuplicateSets<tr_chosei, tr_shiyo_shikakari_zan>();

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Created != null)
            {
                // 後勝ちで更新
                foreach (var created in value.Created)
                {
                    var no_lot_henko = "";
                    // 製品ロット番号有無の判定
                    if (created.no_lot_seihin != null && created.no_lot_seihin != "")
                    {
                        // 製品ロット番号有の場合

                        #region 2017/04/19 処理を外に出したのでコメントアウト
                        //tr_chosei data1 = SetDataTrChosei(created);
                        //tr_shiyo_shikakari_zan data2 = SetDataTrShiyoShikakariZan(created);

                        //// エンティティにシーケンス番号が無かった場合、シーケンス番号取得のストアドプロシージャを実行します。
                        //if (created.no_seq == null || created.no_seq == "")
                        //{
                        //    // シーケンス番号を取得します。
                        //    ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
                        //    String noSaiban = context.usp_cm_Saiban(
                        //        ActionConst.ChoseiSaibanKbn, ActionConst.ChoseiPrefixSaibanKbn, no_saiban_param).FirstOrDefault<String>();

                        //    // 取得したシーケンス番号を設定
                        //    data1.no_seq = noSaiban;
                        //    data2.no_lot = noSaiban;
                        //}

                        //// エンティティに使用予実按分シーケンスが無かった場合、使用予実按分シーケンス取得のストアドプロシージャを実行します。
                        //if (created.no_seq_shiyo_yojitsu_anbun == null || created.no_seq_shiyo_yojitsu_anbun == "")
                        //{
                        //    // シーケンス番号を取得します。
                        //    ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
                        //    usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select_Result result = context.usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select(
                        //        data1.no_lot_seihin).FirstOrDefault<usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select_Result>();

                        //    // 取得したシーケンス番号を設定
                        //    data2.no_seq_shiyo_yojitsu_anbun = result.no_seq;
                        //}

                        //// 既存エンティティを取得します。
                        //tr_chosei current1 = GetSingleEntity(context, created.no_seq);
                        //// 既存エンティティを取得します。
                        //tr_shiyo_shikakari_zan current2 = GetSingleEntity(context, created.kbn_shiyo_jisseki_anbun, created.no_lot, created.no_seq_shiyo_yojitsu_anbun);

                        //// 更新日にUTCシステム日付を設定
                        //created.dt_update = DateTime.UtcNow;

                        //// 既存エンティティが存在した場合は更新処理
                        //// 値が存在しない場合は新規作成
                        //if (current1 != null)
                        //{
                        //    // エンティティを更新します。
                        //    context.tr_chosei.ApplyOriginalValues(data1);
                        //    context.tr_chosei.ApplyCurrentValues(data1);
                        //    continue;
                        //}
                        //else
                        //{
                        //    // エンティティを追加します。
                        //    context.AddTotr_chosei(data1);
                        //}
                        //// 既存エンティティが存在した場合は更新処理
                        //// 値が存在しない場合は新規作成
                        //if (current2 != null)
                        //{
                        //    // エンティティを更新します。
                        //    context.tr_shiyo_shikakari_zan.ApplyOriginalValues(data2);
                        //    context.tr_shiyo_shikakari_zan.ApplyCurrentValues(data2);
                        //    continue;
                        //}
                        //else
                        //{
                        //    // エンティティを追加します。
                        //    context.AddTotr_shiyo_shikakari_zan(data2);
                        //}
                        #endregion

                        // エンティティの追加
                        no_lot_henko = CreateLotRow(created, context);
                    }
                    else
                    {
                        // 製品ロット番号無の場合

                        #region 2017/04/19 処理を外に出したのでコメントアウト
                        //tr_chosei data1 = SetDataTrChosei(created);
                        //// エンティティにシーケンス番号が無かった場合、シーケンス番号取得のストアドプロシージャを実行します。
                        //if (created.no_seq == null || created.no_seq == "")
                        //{
                        //    // シーケンス番号を取得します。
                        //    ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
                        //    String noSaiban = context.usp_cm_Saiban(
                        //        ActionConst.ChoseiSaibanKbn, ActionConst.ChoseiPrefixSaibanKbn, no_saiban_param).FirstOrDefault<String>();

                        //    // 取得したシーケンス番号を設定
                        //    data1.no_seq = noSaiban;
                        //}

                        //// 既存エンティティを取得します。
                        //tr_chosei current1 = GetSingleEntity(context, created.no_seq);

                        //// 更新日にUTCシステム日付を設定
                        //created.dt_update = DateTime.UtcNow;

                        //// 既存エンティティが存在した場合は更新処理
                        //// 値が存在しない場合は新規作成
                        //if (current1 != null)
                        //{
                        //    // エンティティを更新します。
                        //    context.tr_chosei.ApplyOriginalValues(data1);
                        //    context.tr_chosei.ApplyCurrentValues(data1);
                        //    continue;
                        //}
                        //else
                        //{
                        //    // エンティティを追加します。
                        //    context.AddTotr_chosei(data1);
                        //}
                        #endregion

                        // エンティティの追加
                        no_lot_henko = CreateRow(created, context);
                    }

                    // TOsVN - 20089 trung.nq - save change tr_henko_rireki 
                    // ------------- START - Insert to tr_henko_rireki---------------
                    tr_henko_rireki data = new tr_henko_rireki();
                    data.kbn_data = 1;
                    data.kbn_shori = 0;
                    data.dt_hizuke = created.dt_hizuke;
                    data.cd_hinmei = created.cd_hinmei;
                    data.su_henko = created.su_chosei;
                    data.su_henko_hasu = 0;
                    data.no_lot = no_lot_henko;
                    data.biko = null;
                    data.dt_update = DateTime.UtcNow;
                    data.cd_update = created.cd_update;

                    context.AddTotr_henko_rireki(data);
                    // -------------- END -----------------
                }
            }

            // 変更セットを元に更新対象のエンティティを削除後、追加します。
            if (value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    var no_lot_henko = "";
                    // 製品ロット番号有無の判定
                    if (updated.no_lot_seihin != null && updated.no_lot_seihin != "")
                    {
                        // 製品ロット番号が有の場合

                        #region 2017/04/19 コメントアウト
                        //tr_chosei data1 = SetDataTrChosei(updated);
                        //tr_shiyo_shikakari_zan data2 = SetDataTrShiyoShikakariZan(updated);


                        //// 既存エンティティを取得します。
                        //tr_chosei current1 = GetSingleEntity(context, updated.no_seq);
                        //tr_shiyo_shikakari_zan current2 = GetSingleEntity(context, updated.kbn_shiyo_jisseki_anbun, updated.no_lot, updated.no_seq_shiyo_yojitsu_anbun);

                        //// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                        //// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                        //if (current1 == null)
                        //{
                        //    duplicates.First.Updated.Add(new Duplicate<tr_chosei>(data1, current1));
                        //    continue;
                        //}

                        //// 更新日にUTCシステム日付を設定
                        //updated.dt_update = DateTime.UtcNow;

                        //// エンティティを更新します。
                        //context.tr_chosei.ApplyOriginalValues(data1);
                        //context.tr_chosei.ApplyCurrentValues(data1);

                        //// 既存エンティティが存在しない場合は登録処理
                        //// 値が存在する場合は更新処理
                        //if (current2 == null)
                        //{
                        //    data2.no_lot = data1.no_seq;
                        //    // エンティティに使用予実按分シーケンスが無かった場合、使用予実按分シーケンス取得のストアドプロシージャを実行します。
                        //    if (updated.no_seq_shiyo_yojitsu_anbun == null || updated.no_seq_shiyo_yojitsu_anbun == "")
                        //    {
                        //        // シーケンス番号を取得します。
                        //        ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
                        //        usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select_Result result = context.usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select(
                        //            data1.no_lot_seihin).FirstOrDefault<usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select_Result>();

                        //        // 取得したシーケンス番号を設定
                        //        data2.no_seq_shiyo_yojitsu_anbun = result.no_seq;
                        //    }
                        //    // エンティティを追加します。
                        //    context.AddTotr_shiyo_shikakari_zan(data2);
                        //}
                        //else {
                        //    // エンティティを更新します。
                        //    context.tr_shiyo_shikakari_zan.ApplyOriginalValues(data2);
                        //    context.tr_shiyo_shikakari_zan.ApplyCurrentValues(data2);
                        //}
                        #endregion

                        // エンティティの削除
                        DeleteLotRow(updated, context, duplicates);
                        // エンティティの追加
                        no_lot_henko = CreateLotRow(updated, context);
                    }
                    else
                    {
                        // 製品ロット番号無の場合

                        #region 2017/04/19 コメントアウト
                        //tr_chosei data1 = SetDataTrChosei(updated);


                        //// 既存エンティティを取得します。
                        //tr_chosei current1 = GetSingleEntity(context, updated.no_seq);

                        //// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                        //// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                        //if (current1 == null)
                        //{
                        //    duplicates.First.Updated.Add(new Duplicate<tr_chosei>(data1, current1));
                        //    continue;
                        //}

                        //// 更新日にUTCシステム日付を設定
                        //updated.dt_update = DateTime.UtcNow;

                        //// エンティティを更新します。
                        //context.tr_chosei.ApplyOriginalValues(data1);
                        //context.tr_chosei.ApplyCurrentValues(data1);
                        #endregion

                        // エンティティの削除
                        DeleteRow(updated, context, duplicates);
                        // エンティティの追加
                        no_lot_henko = CreateRow(updated, context);
                    }

                    // TOsVN - 20089 trung.nq - save change tr_henko_rireki 
                    // ------------- START - Insert to tr_henko_rireki---------------     
                    if (updated.cd_riyu != updated.cd_riyu_old || updated.cd_genka_center != updated.cd_genka_center_old
                        || updated.biko != updated.biko_old || updated.su_chosei != updated.su_chosei_old)
                    {
                        tr_henko_rireki data = new tr_henko_rireki();
                        data.kbn_data = 1;
                        data.kbn_shori = 1;
                        data.dt_hizuke = updated.dt_hizuke;
                        data.cd_hinmei = updated.cd_hinmei;
                        data.su_henko = updated.su_chosei;
                        data.su_henko_hasu = 0;
                        data.no_lot = no_lot_henko;

                        String biko = null;
                        if (updated.cd_riyu != updated.cd_riyu_old)
                        {
                            int ChoseiRiyuKbn = int.Parse(Properties.Resources.ChoseiRiyuKbn);
                            var nm_riyu = context.ma_riyu.Where(x => x.cd_riyu == updated.cd_riyu
                                                                && x.kbn_bunrui_riyu == ChoseiRiyuKbn).FirstOrDefault();
                            if (nm_riyu != null)
                            {
                                biko += "[1]: " + FoodProcsCommonUtility.changedNullToEmpty(nm_riyu.nm_riyu) + ", ";
                            }
                        }

                        if (updated.biko != updated.biko_old)
                        {
                            biko += "[2]: " + updated.biko + ", ";
                        }

                        if (updated.cd_genka_center_old != updated.cd_genka_center)
                        {
                            var nm_genka_center = context.vw_ma_genka_center_01.Where(x => x.cd_genka_center == updated.cd_genka_center
                                                                                        && x.flg_mishiyo == 0).FirstOrDefault();
                            if (nm_genka_center != null)
                            {
                                biko += "[3]: " + nm_genka_center.nm_genka_center + ", ";
                            }
                        }

                        if (biko != null) {
                            biko = biko.Substring(0, biko.Length - 2);
                        }
                        
                        data.biko = biko;
                        data.dt_update = DateTime.UtcNow;
                        data.cd_update = updated.cd_update;

                        context.AddTotr_henko_rireki(data);
                    }
                    // -------------- END -----------------
                }
            }

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    // 製品ロット番号有無の判定
                    if (deleted.no_lot_seihin != null && deleted.no_lot_seihin != "")
                    {
                        // 製品ロット番号が有の場合

                        #region 2017/04/19 処理を外に出したのでコメントアウト
                        //tr_chosei data1 = SetDataTrChosei(deleted);
                        //tr_shiyo_shikakari_zan data2 = SetDataTrShiyoShikakariZan(deleted);


                        //// 既存エンティティを取得します。
                        //tr_chosei current1 = GetSingleEntity(context, deleted.no_seq);
                        //// 既存エンティティを取得します。
                        //tr_shiyo_shikakari_zan current2 = GetSingleEntity(context, deleted.kbn_shiyo_jisseki_anbun, deleted.no_lot, deleted.no_seq_shiyo_yojitsu_anbun);

                        //// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                        //// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                        //if (current1 == null)
                        //{
                        //    duplicates.First.Deleted.Add(new Duplicate<tr_chosei>(data1, current1));
                        //    continue;
                        //}

                        //// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                        //// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                        //if (current2 == null)
                        //{
                        //    duplicates.Second.Deleted.Add(new Duplicate<tr_shiyo_shikakari_zan>(data2, current2));
                        //    continue;
                        //}


                        //// エンティティを削除します。
                        //context.DeleteObject(current1);
                        //context.DeleteObject(current2);
                        #endregion

                        // エンティティの削除
                        DeleteLotRow(deleted, context, duplicates);
                    }
                    else
                    {
                        // 製品ロット番号無の場合

                        #region 2017/04/19 処理を外に出したのでコメントアウト
                        //tr_chosei data1 = SetDataTrChosei(deleted);

                        //// 既存エンティティを取得します。
                        //tr_chosei current1 = GetSingleEntity(context, deleted.no_seq);

                        //// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                        //// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                        //if (current1 == null)
                        //{
                        //    duplicates.First.Deleted.Add(new Duplicate<tr_chosei>(data1, current1));
                        //    continue;
                        //}
                        //// エンティティを削除します。
                        //context.DeleteObject(current1);
                        #endregion

                        // エンティティの削除
                        DeleteRow(deleted, context, duplicates);
                    }

                    // TOsVN - 20089 trung.nq - save change tr_henko_rireki 
                    // ------------- START - Insert to tr_henko_rireki---------------
                    tr_chosei current = GetSingleEntity(context, deleted.no_seq);
                    tr_henko_rireki data = new tr_henko_rireki();
                    data.kbn_data = 1;
                    data.kbn_shori = 2;
                    data.dt_hizuke = deleted.dt_hizuke;
                    data.cd_hinmei = current.cd_hinmei;
                    data.su_henko = current.su_chosei;
                    data.su_henko_hasu = 0;
                    data.no_lot = current.no_seq;
                    data.biko = null;
                    data.dt_update = DateTime.UtcNow;
                    data.cd_update = deleted.cd_update;

                    context.AddTotr_henko_rireki(data);
                    // -------------- END -----------------
                }
            }

            // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
            // コンテントに競合したデータを設定します。
            if (duplicates.First.Created.Count > 0 || duplicates.First.Updated.Count > 0 || duplicates.First.Deleted.Count > 0 ||
                duplicates.Second.Created.Count > 0 || duplicates.Second.Updated.Count > 0 || duplicates.Second.Deleted.Count > 0)
            {
                // TODO: エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSets<tr_chosei, tr_shiyo_shikakari_zan>>(HttpStatusCode.Conflict, duplicates);
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

        /// <summary>
        /// 既存エンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="key1">検索キー</param>
        /// <returns>既存エンティティ</returns>
        private tr_chosei GetSingleEntity(FoodProcsEntities context, String key1)
        {
            var result = context.tr_chosei.SingleOrDefault(tr => tr.no_seq == key1);

            return result;
        }

        /// <summary>
        /// 既存エンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="key1">検索キー</param>
        /// <returns>既存エンティティ</returns>
        private tr_shiyo_shikakari_zan GetSingleEntity(FoodProcsEntities context, int key1, String key2, String key3)
        {
            var result = context.tr_shiyo_shikakari_zan.SingleOrDefault(tr => tr.kbn_shiyo_jisseki_anbun == key1 && tr.no_lot == key2 && tr.no_seq_shiyo_yojitsu_anbun == key3);

            return result;
        }

        /// <summary>
        /// 調整トランに更新する項目のセット
        /// </summary>
        private tr_chosei SetDataTrChosei(GenshizaiChoseiNyuryokuDataCriteria val)
        {

            tr_chosei data = new tr_chosei();
            data.no_seq = val.no_seq;
            data.cd_hinmei = val.cd_hinmei;
            data.dt_hizuke = val.dt_hizuke;
            data.cd_riyu = val.cd_riyu;
            data.su_chosei = val.su_chosei;
            data.biko = val.biko;
            data.cd_seihin = val.cd_seihin;
            data.dt_update = val.dt_update;
            data.cd_update = val.cd_update;
            data.cd_genka_center = val.cd_genka_center;
            data.cd_soko = val.cd_soko;
            data.nm_henpin = val.nm_henpin;
            data.no_niuke = val.no_niuke;
            data.kbn_zaiko = val.kbn_zaiko;
            data.cd_torihiki = val.cd_torihiki;
            data.no_lot_seihin = val.no_lot_seihin;

            return data;

        }

        /// <summary>
        /// 調整トランに更新する項目のセット
        /// </summary>
        private tr_shiyo_shikakari_zan SetDataTrShiyoShikakariZan(GenshizaiChoseiNyuryokuDataCriteria val)
        {

            tr_shiyo_shikakari_zan data = new tr_shiyo_shikakari_zan();
            data.kbn_shiyo_jisseki_anbun = val.kbn_shiyo_jisseki_anbun;
            data.no_lot = val.no_lot;
            data.no_seq_shiyo_yojitsu_anbun = val.no_seq_shiyo_yojitsu_anbun;
            data.no_seq_shiyo_yojitsu = val.no_seq_shiyo_yojitsu;
            data.su_shiyo = val.su_shiyo;

            return data;

        }

        /// <summary>
        /// 製品ロット番号有の場合の追加処理
        /// </summary>
        /// <param name="created">追加対象行データ</param>
        /// <param name="context">エンティティ</param>
        private string CreateLotRow(GenshizaiChoseiNyuryokuDataCriteria created, FoodProcsEntities context)
        {
            tr_chosei data1 = SetDataTrChosei(created);
            tr_shiyo_shikakari_zan data2 = SetDataTrShiyoShikakariZan(created);

            // エンティティにシーケンス番号が無かった場合、シーケンス番号取得のストアドプロシージャを実行します。
            if (created.no_seq == null || created.no_seq == "")
            {
                // シーケンス番号を取得します。
                ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
                String noSaiban = context.usp_cm_Saiban(
                    ActionConst.ChoseiSaibanKbn, ActionConst.ChoseiPrefixSaibanKbn, no_saiban_param).FirstOrDefault<String>();

                // 取得したシーケンス番号を設定
                data1.no_seq = noSaiban;
                data2.no_lot = noSaiban;
            }

            // エンティティに使用予実按分シーケンスが無かった場合、使用予実按分シーケンス取得のストアドプロシージャを実行します。
            if (created.no_seq_shiyo_yojitsu_anbun == null || created.no_seq_shiyo_yojitsu_anbun == "")
            {
                // シーケンス番号を取得します。
                ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
                usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select_Result result = context.usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select(
                    data1.no_lot_seihin).FirstOrDefault<usp_GenshizaiChoseiNyuryokuAnbunNoSeq_select_Result>();

                // 取得したシーケンス番号を設定
                data2.no_seq_shiyo_yojitsu_anbun = result.no_seq;
            }

            // 既存エンティティを取得します。
            tr_chosei current1 = GetSingleEntity(context, created.no_seq);
            // 既存エンティティを取得します。
            tr_shiyo_shikakari_zan current2 = GetSingleEntity(context, created.kbn_shiyo_jisseki_anbun, created.no_lot, created.no_seq_shiyo_yojitsu_anbun);

            // 更新日にUTCシステム日付を設定
            created.dt_update = DateTime.UtcNow;

            // 既存エンティティが存在した場合は更新処理
            // 値が存在しない場合は新規作成
            if (current1 != null)
            {
                // エンティティを更新します。
                context.tr_chosei.ApplyOriginalValues(data1);
                context.tr_chosei.ApplyCurrentValues(data1);
                //continue;
                return created.no_seq;
            }
            else
            {
                // エンティティを追加します。
                context.AddTotr_chosei(data1);
            }
            // 既存エンティティが存在した場合は更新処理
            // 値が存在しない場合は新規作成
            if (current2 != null)
            {
                // エンティティを更新します。
                context.tr_shiyo_shikakari_zan.ApplyOriginalValues(data2);
                context.tr_shiyo_shikakari_zan.ApplyCurrentValues(data2);
                //continue;
                return created.no_seq;
            }
            else
            {
                // エンティティを追加します。
                context.AddTotr_shiyo_shikakari_zan(data2);
            }
            return data1.no_seq;
        }

        /// <summary>
        /// 製品ロット番号無の場合の追加処理
        /// </summary>
        /// <param name="created">追加対象行データ</param>
        /// <param name="context">エンティティ</param>
        private string CreateRow(GenshizaiChoseiNyuryokuDataCriteria created, FoodProcsEntities context)
        {

            tr_chosei data1 = SetDataTrChosei(created);

            // シーケンス番号を取得します。
            ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
            String noSaiban = context.usp_cm_Saiban(
                ActionConst.ChoseiSaibanKbn, ActionConst.ChoseiPrefixSaibanKbn, no_saiban_param
            ).FirstOrDefault<String>();

            // 取得したシーケンス番号を設定
            data1.no_seq = noSaiban;

            // 更新日にUTCシステム日付を設定
            created.dt_update = DateTime.UtcNow;

            // エンティティを追加します。
            context.AddTotr_chosei(data1);

            return noSaiban;
        }

        /// <summary>
        /// 製品ロット番号有の場合の削除処理
        /// </summary>
        /// <param name="deleted">削除対象行データ</param>
        /// <param name="context">エンティティ</param>
        /// <param name="duplicates">同時実行制御エラーの結果を格納するDuplicateSet</param>
        private void DeleteLotRow(GenshizaiChoseiNyuryokuDataCriteria deleted, FoodProcsEntities context
                             , DuplicateSets<tr_chosei, tr_shiyo_shikakari_zan> duplicates)
        {
            tr_chosei data1 = SetDataTrChosei(deleted);
            tr_shiyo_shikakari_zan data2 = SetDataTrShiyoShikakariZan(deleted);


            // 既存エンティティを取得します。
            tr_chosei current1 = GetSingleEntity(context, deleted.no_seq);
            // 既存エンティティを取得します。
            tr_shiyo_shikakari_zan current2 = GetSingleEntity(context, deleted.kbn_shiyo_jisseki_anbun, deleted.no_lot, deleted.no_seq_shiyo_yojitsu_anbun);

            // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
            // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
            if (current1 == null)
            {
                duplicates.First.Deleted.Add(new Duplicate<tr_chosei>(data1, current1));
                //continue;
                return;
            }

            // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
            // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
            if (current2 == null)
            {
                duplicates.Second.Deleted.Add(new Duplicate<tr_shiyo_shikakari_zan>(data2, current2));
                //continue;
                return;
            }
            // エンティティを削除します。
            context.DeleteObject(current1);
            context.DeleteObject(current2);
        }

        /// <summary>
        /// 製品ロット番号無の場合の削除処理
        /// </summary>
        /// <param name="deleted">削除対象行データ</param>
        /// <param name="context">エンティティ</param>
        /// <param name="duplicates">同時実行制御エラーの結果を格納するDuplicateSet</param>
        private void DeleteRow(GenshizaiChoseiNyuryokuDataCriteria deleted, FoodProcsEntities context
                             , DuplicateSets<tr_chosei, tr_shiyo_shikakari_zan> duplicates)
        {
            tr_chosei data1 = SetDataTrChosei(deleted);

            // 既存エンティティを取得します。
            tr_chosei current1 = GetSingleEntity(context, deleted.no_seq);

            // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
            // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
            if (current1 == null)
            {
                duplicates.First.Deleted.Add(new Duplicate<tr_chosei>(data1, current1));
                //continue;
                return;
            }
            // エンティティを削除します。
            context.DeleteObject(current1);
        }
    }

}