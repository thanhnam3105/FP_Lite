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

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class NonyuYoteiListSakuseiController : ApiController
    {
        // GET api/NonyuYoteiListSakusei
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_NonyuYoteiListSakusei_select_Result> Get([FromUri]NonyuYoteiListSakuseiCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_NonyuYoteiListSakusei_select_Result> selectResult;
            // 検索用ストアドプロシージャの実行
            selectResult = context.usp_NonyuYoteiListSakusei_select(
                criteria.con_dt_nonyu,
                criteria.con_kbn_hin,
                criteria.con_cd_bunrui,
                criteria.con_kbn_hokan,
                criteria.con_cd_torihiki,
                criteria.flg_yojitsu_yo,
                criteria.flg_yojitsu_ji,
                criteria.flg_mishiyo,
                ActionConst.KgKanzanKbn,
                ActionConst.LKanzanKbn,
                ActionConst.kbn_zaiko_ryohin
                ).AsEnumerable();
            return selectResult;
        }

        // POST api/NonyuYoteiListSakusei
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        //public HttpResponseMessage Post([FromBody]ChangeSet<tr_nonyu> value)
        public HttpResponseMessage Post([FromBody]ChangeSet<NonyuYoteiListSakuseiCriteria> value)
        {
            // パラメータチェック
            if (value == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            FoodProcsEntities context = new FoodProcsEntities();

            // 同時実行制御エラーの結果を格納するDuplicateSetを定義
            DuplicateSet<tr_nonyu> duplicates = new DuplicateSet<tr_nonyu>();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;

            // 変更セットを元に削除対象のデータを削除
            if (value.Deleted != null)
            {
                foreach (var delCriteria in value.Deleted)
                {
                    tr_nonyu deleted = SetCriteriaToTrNonyu(delCriteria);
                    // 削除対象データ件数取得
                    long count = GetDelCount(context, deleted.no_nonyu);

                    if (count == 0)
                    {
                        // 削除対象データが存在しない場合

                        // 対象データが削除されたと判定し、競合データとして処理する
                        duplicates.Deleted.Add(new Duplicate<tr_nonyu>(deleted, null));
                        continue;
                    }

                    if (GetExistsDataActualDelivery(delCriteria.no_nonyu, delCriteria.cd_hinmei))
                    {
                        return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.MS0823);
                    }

                    // 削除用のストアドプロシージャを実行
                    context.usp_NonyuYoteiListSakusei_delete(deleted.no_nonyu);
                }
            }

            // 変更セットを元に追加対象のデータを追加
            if (value.Created != null)
            {
                foreach (var creCriteria in value.Created)
                {

                    //予定データの設定
                    tr_nonyu createdyotei = SetCriteriaToTrNonyuYotei(creCriteria);
                    //実績データの設定
                    tr_nonyu created = SetCriteriaToTrNonyu(creCriteria);

                    // 予定既存データ格納領域
                    //tr_nonyu currentyotei;
                    // 実績既存データ格納領域
                    tr_nonyu current;
                    
                    
                    // 予定・実績どちらにも納入番号が存在しない場合(新規追加行)
                    if (createdyotei.no_nonyu == null && created.no_nonyu == null)
                    {
                        // 追加用のストアドプロシージャを実行
                        context.usp_NonyuYoteiListSakusei_create(
                            Resources.NonyuSaibanKbn,
                            Resources.NonyuPrefixSaibanKbn,
                            //created.flg_yojitsu,
                            ActionConst.YoteiYojitsuFlag,
                            ActionConst.JissekiYojitsuFlag,
                            created.no_nonyu,
                            created.dt_nonyu,
                            created.cd_hinmei,
                            created.su_nonyu,
                            created.su_nonyu_hasu,
                            created.cd_torihiki,
                            created.cd_torihiki2,
                            created.tan_nonyu,
                            created.kin_kingaku,
                            created.no_nonyusho,
                            created.kbn_zei,
                            created.kbn_denso,
                            created.flg_kakutei,
                            created.dt_seizo,
                            createdyotei.dt_nonyu,
                            createdyotei.su_nonyu,
                            createdyotei.kbn_nyuko,
                            createdyotei.su_nonyu_hasu
                        );
                    }

                    //実績のみの新規追加の場合(予定は既に存在している)
                    else if (created.no_nonyu != null
                        && created.no_nonyu.Length > 0) {

                        current = GetExistsDataNoNonyu(
                            context,
                            createdyotei);
                        // 既存データより納入番号を取得
                        if (current == null) {
                            // 対象データが削除されたと判定し、競合データとして処理する
                            duplicates.Updated.Add(new Duplicate<tr_nonyu>(created, current));
                            continue;
                        }
                        created.no_nonyu = current.no_nonyu;
                        created.no_nonyu_yotei = current.no_nonyu;

                        if (GetExistsDataActualDelivery(created.no_nonyu, created.cd_hinmei))
                        {
                            return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.MS0823);
                        }

                        // エンティティ(実績データ)を追加します。
                        context.AddTotr_nonyu(created);
                    }
                    //予定は更新、実績は追加の場合
                    if (createdyotei.no_nonyu != null)
                    {
                        tr_nonyu yoteiData = GetExistsDataNonyuYotei(context, createdyotei.no_nonyu);
                        // 予定が存在すれば更新する
                        if (yoteiData != null)
                        {
                            yoteiData.cd_hinmei = createdyotei.cd_hinmei;
                            yoteiData.kbn_nyuko = createdyotei.kbn_nyuko;
                            yoteiData.dt_nonyu = createdyotei.dt_nonyu;
                            yoteiData.su_nonyu = createdyotei.su_nonyu;
                            yoteiData.su_nonyu_hasu = createdyotei.su_nonyu_hasu;
                            yoteiData.cd_torihiki = createdyotei.cd_torihiki;
                            yoteiData.cd_torihiki2 = createdyotei.cd_torihiki2;
                            // データの更新
                            context.tr_nonyu.ApplyOriginalValues(yoteiData);
                            context.tr_nonyu.ApplyCurrentValues(yoteiData);
                        }
                    }

                }
            }

            // 変更セットを元に更新対象のデータを更新
            if (value.Updated != null)
            {
                foreach (var upCriteria in value.Updated)
                {
                    //予定データの設定
                    tr_nonyu updatedyotei = SetCriteriaToTrNonyuYotei(upCriteria);
                    tr_nonyu updated = SetCriteriaToTrNonyu(upCriteria);
                    
                    //予定の更新の場合
                    if (ActionConst.FlagTrue.Equals(upCriteria.flg_edit_kbn_nyuko)) {
                        // 予実フラグ、納入番号をキーに既存データを取得
                        tr_nonyu current = GetExistsDataNoNonyu(
                            context,
                            updatedyotei);

                        if (current == null)
                        {
                            // 既存データが存在しない場合
                            // 対象データが削除されたと判定し、競合データとして処理する
                            duplicates.Updated.Add(new Duplicate<tr_nonyu>(updatedyotei, current));
                            continue;
                        }

                        //画面更新前に実績を作成された場合、エラーを表示する。
                        if (GetflgYojitsu(context, upCriteria.no_nonyu) == 1 && (upCriteria.flg_edit_kbn_nyuko == 1 && upCriteria.flg_edit_meisai == 0)) 
                        {
                            return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.MS0823);
                        }
                        // 予定データの更新
                        context.tr_nonyu.ApplyOriginalValues(updatedyotei);
                        context.tr_nonyu.ApplyCurrentValues(updatedyotei);
                    }

                    
                    // 予定以外に変更があれば実績の保存処理へ(予定のみの編集の場合、実績は保存しない)
                    if (ActionConst.FlagTrue.Equals(upCriteria.flg_edit_meisai))
                    {
                        // 予実フラグ、納入番号をキーに既存データを取得
                        tr_nonyu current = GetExistsDataNoNonyu(
                            context,
                            updated);

                        if (current == null)
                        {
                            // 既存データが存在しない場合

                            // 対象データが削除されたと判定し、競合データとして処理する
                            duplicates.Updated.Add(new Duplicate<tr_nonyu>(updated, current));
                            continue;
                        }
                        //tr_nonyu upCurrent = UpdateNonyuYotei(context, updated, upCriteria.dt_nonyu_yotei);
                        // 既存データ更新
                        context.tr_nonyu.ApplyOriginalValues(updated);
                        context.tr_nonyu.ApplyCurrentValues(updated);
                    }

                    // 予定データの更新
                    //tr_nonyu upCurrent = UpdateNonyuYotei(context, updated, upCriteria.dt_nonyu_yotei);
                }
            }

            // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
            // コンテントに競合したデータを設定します。
            if (duplicates.Created.Count > 0
                || duplicates.Updated.Count > 0
                || duplicates.Deleted.Count > 0)
            {

                // エンティティの型に応じたDuplicateSetを返却
                return Request.CreateResponse<DuplicateSet<tr_nonyu>>(HttpStatusCode.Conflict, duplicates);
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
                        // 楽観排他制御 (データベース上の timestamp 列による多ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                        return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                    }
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK);
        }

        /// <summary>
        /// 既存データ取得(キー：予実フラグ、納入番号)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="nonyu">明細情報</param>
        /// <returns>既存データ</returns>
        private tr_nonyu GetExistsDataNoNonyu(FoodProcsEntities context, tr_nonyu nonyu)
        {
            var result = (from t in context.tr_nonyu
                          where t.flg_yojitsu == nonyu.flg_yojitsu
                             && t.no_nonyu == nonyu.no_nonyu
                          select t).FirstOrDefault();
            return result;
        }

        /// <summary>
        /// 既存データ取得(キー：予実フラグ、納入日、品名コード、取引先コード)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="nonyu">明細情報</param>
        /// <returns>既存データ</returns>
        private tr_nonyu GetExistsDataOther(FoodProcsEntities context, tr_nonyu nonyu)
        {
            var result = (from t in context.tr_nonyu
                          where t.flg_yojitsu == nonyu.flg_yojitsu
                             && t.dt_nonyu == nonyu.dt_nonyu
                             && t.cd_hinmei == nonyu.cd_hinmei
                             && t.cd_torihiki == nonyu.cd_torihiki
                          select t).FirstOrDefault();
            return result;
        }

        /// <summary>
        /// 既存の予定データ取得(キー：予実フラグ(予定)、納入番号)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="nonyuNo">納入番号</param>
        /// <returns>既存データ</returns>
        private tr_nonyu GetExistsDataNonyuYotei(FoodProcsEntities context, string nonyuNo)
        {
            var result = (from t in context.tr_nonyu
                          where t.flg_yojitsu == ActionConst.YoteiYojitsuFlag
                             && t.no_nonyu == nonyuNo
                          select t).FirstOrDefault();
            return result;
        }

        /// <summary>
        /// 削除対象データ件数取得
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="no_nonyu">納入番号</param>
        /// <returns>既存データ</returns>
        private long GetDelCount(FoodProcsEntities context, String no_nonyu)
        {
            var result = context.tr_nonyu.LongCount(tr => tr.no_nonyu == no_nonyu);
            return result;
        }
        
        /// <summary>
        /// 再検索前に他画面にて実績追加されたデータ取得
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="no_nonyu">納入番号</param>
        /// <returns>既存データ</returns>
        private long GetflgYojitsu(FoodProcsEntities context, String no_nonyu)
        {
            var result = context.tr_nonyu.LongCount(tr => tr.no_nonyu == no_nonyu && tr.flg_yojitsu == ActionConst.JissekiYojitsuFlag);
            return result;
        }
        /*
        /// <summary>
        /// 予定データの更新：予定が存在すれば、入庫区分と納入予定日を更新する。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="nonyu">明細情報</param>
        /// <param name="dt_nonyu_yotei">納入予定日</param>
        private tr_nonyu UpdateNonyuYotei(FoodProcsEntities context, tr_nonyu nonyu, DateTime dt_nonyu_yotei)
        {
            tr_nonyu yoteiData = GetExistsDataNonyuYotei(context, nonyu.no_nonyu);
            // 予定が存在すれば更新する
            if (yoteiData != null)
            {
                DateTime date = dt_nonyu_yotei;
                if (date == null)
                {
                    // ありえないが、いちおうnullチェック
                    date = (DateTime)yoteiData.dt_nonyu;
                }

                yoteiData.kbn_nyuko = nonyu.kbn_nyuko;
                yoteiData.dt_nonyu = date;
                yoteiData.su_nonyu = nonyu.su_nonyu;
                // データの更新
                context.tr_nonyu.ApplyOriginalValues(yoteiData);
                context.tr_nonyu.ApplyCurrentValues(yoteiData);
            }

            // 実績は入庫区分を更新しない(NULL固定)
            nonyu.kbn_nyuko = null;
            return nonyu;
        }
        */
        /// <summary>
        /// Criteriaからtr_nonyuの実績データを作成する
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="nonyu">明細情報</param>
        private tr_nonyu SetCriteriaToTrNonyu(NonyuYoteiListSakuseiCriteria criteria)
        {
            tr_nonyu data = new tr_nonyu();
            data.flg_yojitsu = ActionConst.JissekiYojitsuFlag;
            data.no_nonyu = criteria.no_nonyu;
            data.dt_nonyu = criteria.dt_nonyu;
            data.cd_hinmei = criteria.cd_hinmei;
            data.su_nonyu = criteria.su_nonyu;
            data.su_nonyu_hasu = criteria.su_nonyu_hasu;
            data.cd_torihiki = criteria.cd_torihiki;
            data.cd_torihiki2 = criteria.cd_torihiki2;
            data.tan_nonyu = criteria.tan_nonyu;
            data.kin_kingaku = criteria.kin_kingaku;
            data.no_nonyusho = criteria.no_nonyusho;
            data.kbn_zei = criteria.kbn_zei;
            //data.kbn_denso = criteria.kbn_denso;
            data.flg_kakutei = criteria.flg_kakutei;
            //data.dt_seizo = criteria.dt_seizo;
            data.kbn_nyuko = criteria.kbn_nyuko;
            data.no_nonyu_yotei = criteria.no_nonyu_yotei;
            return data;
        }
        /// <summary>
        /// Criteriaからtr_nonyuの予定データを作成する
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="nonyu">明細情報</param>
        private tr_nonyu SetCriteriaToTrNonyuYotei(NonyuYoteiListSakuseiCriteria criteria)
        {
            tr_nonyu data = new tr_nonyu();
            data.flg_yojitsu = ActionConst.YoteiYojitsuFlag;
            data.no_nonyu = criteria.no_nonyu;
            data.dt_nonyu = criteria.dt_nonyu_yotei;
            data.cd_hinmei = criteria.cd_hinmei;
            data.su_nonyu = criteria.su_nonyu_yo;
            data.su_nonyu_hasu = criteria.su_nonyu_yo_hasu;
            data.cd_torihiki = criteria.cd_torihiki;
            data.cd_torihiki2 = criteria.cd_torihiki2;
            data.tan_nonyu = criteria.tan_nonyu;
            data.kin_kingaku = 0;
            data.no_nonyusho = criteria.no_nonyusho;
            data.kbn_zei = criteria.kbn_zei;
            //data.kbn_denso = criteria.kbn_denso;
            data.flg_kakutei = criteria.flg_kakutei;
            //data.dt_seizo = criteria.dt_seizo;
            data.kbn_nyuko = criteria.kbn_nyuko;
            return data;
        }

        /// <summary>
        /// GetExistsDataActualDelivery
        /// </summary>
        /// <param name="p_no_nonyu"></param>
        /// <param name="p_cd_hinmei"></param>
        /// <returns></returns>
        public bool GetExistsDataActualDelivery(string p_no_nonyu, string p_cd_hinmei)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            var data = (from niuke in context.tr_niuke
                          where niuke.no_nonyu == p_no_nonyu
                                 //&& niuke.cd_hinmei == p_cd_hinmei
                          select new 
                              {
                                  isExistsNiukeJisseki = (niuke.su_nonyu_jitsu ?? 0) + (niuke.su_nonyu_jitsu_hasu ?? 0) > 0 ? true : false
                              }).FirstOrDefault();
            var result = (data != null ? data.isExistsNiukeJisseki : false);
            return result;
        }
    }
}