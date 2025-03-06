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
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class SeizoJissekiSentakuController : ApiController
    {
        // GET api/SeizoJissekiSentaku
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_SeizoJissekiSentaku_nodata_select_Result> Get(
            [FromUri]SeizoJissekiSentakuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_SeizoJissekiSentaku_nodata_select_Result> views;
            short flg_mikakutei = ActionConst.FlagFalse;
            short flg_kakutei = ActionConst.FlagTrue;
            short flg_shiyo = ActionConst.FlagFalse;

            // 検索用ストアドプロシージャの実行
            views = context.usp_SeizoJissekiSentaku_nodata_select(
                criteria.dt_shikomi,
                criteria.cd_haigo,
                criteria.su_shikomi,
                flg_mikakutei,
                flg_kakutei,
                flg_shiyo,
                criteria.kbn_jotai_denso,
                criteria.kbn_anbun_seizo,
                criteria.no_lot_shikakari
            ).AsEnumerable();

            // 「クエリの結果を複数回列挙できません」対策
            List<usp_SeizoJissekiSentaku_nodata_select_Result> list
                = views.ToList<usp_SeizoJissekiSentaku_nodata_select_Result>();
            var result = new StoredProcedureResult<usp_SeizoJissekiSentaku_nodata_select_Result>();

            int maxCount = (int)criteria.top;
            int resultCount = list.Count();
            result.__count = resultCount;
            
            if (resultCount > maxCount)
            {
                // 上限数を超えていた場合
                int deleteCount = resultCount - (maxCount + 1); // 削除数
                list.RemoveRange(maxCount + 1, deleteCount);
                result.d = list.AsEnumerable();
            }
            else
            {
                result.d = list.AsEnumerable();
            }

            return result;
        }

        // POST api/tr_sap_shiyo_yojitsu_anbun
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        //  ※トランだが、先勝ちで更新
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<SeizoJissekiSentakuCriteria> value)
        {
            string validationMessage = string.Empty;
            string shikakariLotNo = string.Empty;   // 一括更新用
            bool errFlg = false;    // チェックエラー発生時true

            // パラメータのチェックを行います。
            if (value == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;

            //// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<tr_sap_shiyo_yojitsu_anbun> duplicates = new DuplicateSet<tr_sap_shiyo_yojitsu_anbun>();
            // 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<SeizoJissekiSentakuCriteria> invalidations = new InvalidationSet<SeizoJissekiSentakuCriteria>();

            // 重複チェック用：既存行のキーリスト：按分区分「製造」のみ
            List<dynamic> updateKeys = new List<dynamic>();
            List<dynamic> deleteKeys = new List<dynamic>();
            if (value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    if (ActionConst.shiyoJissekiAnbunKubunSeizo.Equals(updated.kbn_shiyo_jisseki_anbun))
                    {
                        AddKey(updateKeys, updated);
                    }
                }
            }
            if (value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    if (ActionConst.shiyoJissekiAnbunKubunSeizo.Equals(deleted.kbn_shiyo_jisseki_anbun))
                    {
                        AddKey(deleteKeys, deleted);
                    }
                }
            }

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Created != null)
            {

                List<dynamic> createKeys = new List<dynamic>();   // 重複チェック用：追加対象キーリスト

                foreach (var created in value.Created)
                {
                    tr_sap_shiyo_yojitsu_anbun data = SetCriteriaToAnbunData(created, context);
                    shikakariLotNo = created.no_lot_shikakari;

                    // 先勝ちとするためのチェック処理
                    if (!ValidateExistAnbunTran(context, created))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<SeizoJissekiSentakuCriteria>(
                            Resources.OptimisticConcurrencyError, created, Resources.Exists));
                        errFlg = true;
                        break;
                    }

                    // 重複チェック(製造のみ)：ひとつの仕掛品ロット内で同製品ロット番号が重複していないこと
                    if (ActionConst.shiyoJissekiAnbunKubunSeizo.Equals(created.kbn_shiyo_jisseki_anbun))
                    {
                        validationMessage = ValidateNoLotSeihin(context, data, createKeys, updateKeys, deleteKeys);
                        if (!String.IsNullOrEmpty(validationMessage))
                        {
                            // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                            invalidations.Add(new Invalidation<SeizoJissekiSentakuCriteria>(
                                validationMessage, created, Resources.DuplicateItem));
                            //continue;
                            // エラーが発生した時点で処理終了。エラーを画面に返す。
                            errFlg = true;
                            break;
                        }
                        // 優先順位用のキーリストに追加します。
                        AddKey(createKeys, created);
                    }


                    //製品ロット番号の採番処理をします。
                    String pLotSaiban = null;
                    if (created.kbn_shiyo_jisseki_anbun == ActionConst.shiyoJissekiAnbunKubunZan)
                    {
                        pLotSaiban = FoodProcsCommonUtility.executionSaiban(
                            ActionConst.SeihinLotSaibanKbn, ActionConst.SeihinLotPrefixSaibanKbn, context);
                        
                    }
                    else 
                    {
                        pLotSaiban = created.no_lot_seihin;
                    }

                    //予実按分トランにインサートします。
                    AddYojitsuAnbun(context, created, pLotSaiban);

                    //変更後の使用実績按分区分が「残」の時
                    if (created.kbn_shiyo_jisseki_anbun == ActionConst.shiyoJissekiAnbunKubunZan)
                    {

                        //製品計画トランにインサートします。
                        AddSeihinKeikaku(context, created, pLotSaiban);
                    }
                }
            }

            // 変更セットを元に更新対象のエンティティを更新します。
            if (!errFlg && value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    // 既存エンティティを取得します。
                    tr_sap_shiyo_yojitsu_anbun current = GetSingleEntity(context, updated.no_seq);
                    tr_sap_shiyo_yojitsu_anbun upData = SetCriteriaToAnbunData(updated, context);
                    shikakariLotNo = updated.no_lot_shikakari;
                    var beforeAnbunKbn = current.kbn_shiyo_jisseki_anbun;

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, updated.ts))
                    {
                        duplicates.Updated.Add(new Duplicate<tr_sap_shiyo_yojitsu_anbun>(upData, current));
                        errFlg = true;
                        break;
                    }

                    // 重複チェック(製造のみ)：ひとつの仕掛品ロット内で同製品ロット番号が重複していないこと
                    if (ActionConst.shiyoJissekiAnbunKubunSeizo.Equals(updated.kbn_shiyo_jisseki_anbun))
                    {
                        validationMessage = ValidateNoLotSeihin(context, upData, new List<dynamic>(), updateKeys, deleteKeys);
                        if (!String.IsNullOrEmpty(validationMessage))
                        {
                            invalidations.Add(new Invalidation<SeizoJissekiSentakuCriteria>(
                                validationMessage, updated, Resources.DuplicateItem));
                            //continue;
                            // エラーが発生した時点で処理終了。エラーを画面に返す。
                            errFlg = true;
                            break;
                        }
                    }

                    //製品ロット番号の採番処理をします。
                    String pLotSaiban = null;
                    if (!(updated.kbn_shiyo_jisseki_anbun == ActionConst.shiyoJissekiAnbunKubunChosei) && String.IsNullOrEmpty(updated.no_lot_seihin))
                    {
                        pLotSaiban = FoodProcsCommonUtility.executionSaiban(
                            ActionConst.SeihinLotSaibanKbn, ActionConst.SeihinLotPrefixSaibanKbn, context);
                    }
                    else
                    {
                        pLotSaiban = updated.no_lot_seihin;
                    }

                    //製品ロット番号を格納します。
                    upData.no_lot_seihin = pLotSaiban;


                    // エンティティを更新します。
                    context.tr_sap_shiyo_yojitsu_anbun.ApplyOriginalValues(upData);
                    context.tr_sap_shiyo_yojitsu_anbun.ApplyCurrentValues(upData);

                    //変更前の仕様実績按分区分が「残」の時
                    if (beforeAnbunKbn == ActionConst.shiyoJissekiAnbunKubunZan)
                    {

                        //変更後の使用実績按分区が「残」の時
                        if (updated.kbn_shiyo_jisseki_anbun == ActionConst.shiyoJissekiAnbunKubunZan)
                        {
                            //既存データを取得します。
                            tr_keikaku_seihin CurrentSeihin = GetCurrentSeihinKeikaku(context, updated.no_lot_seihin);


                            //品名マスタの入数、個重量、比重を取得します。

                            ma_hinmei HinmeiMaster = GetHinmeiMaster(updated.cd_hinmei, context);

                            decimal? irisu = HinmeiMaster.su_iri ?? (decimal?)1.00;
                            decimal? kojyuryo = HinmeiMaster.wt_ko ?? (decimal?)1.00;
                            decimal? hijyu = HinmeiMaster.ritsu_hiju ?? (decimal?)1.00;

                            //配合名マスタの歩留を取得します。
                            usp_YukoHaigoMei_select_Result GetHaigoMaster = GetHaigomeiMaster(updated, context);
                            decimal? Budomari = GetHaigoMaster.ritsu_budomari_mei ?? (decimal?)1.00;

                            //製造実績数の計算をします。
                            //decimal? Kekka = updated.su_shiyo_shikakari / (irisu * kojyuryo / hijyu / Budomari * 100);
                            decimal? Kekka = updated.su_shiyo_shikakari / (irisu * kojyuryo);

                            CurrentSeihin.su_seizo_jisseki = (decimal?)Math.Floor((double)Kekka);

                            //更新日付をセットします。

                            CurrentSeihin.dt_update = DateTime.UtcNow;

                            //エンティティを更新します。

                            context.tr_keikaku_seihin.ApplyOriginalValues(CurrentSeihin);
                            context.tr_keikaku_seihin.ApplyCurrentValues(CurrentSeihin);
                        }
                        else { 
                        //変更後の使用実績按分区分が「製造」「調整」の時

                            //既存データの取得とエンティティの削除
                            trDelete(updated, context);
                        }
                    }                    
                    else { 
                    //変更前の使用実績按分区分が「製造」「調整」の時
                        //変更後の使用実績按分区分が「残」の時
                        if (updated.kbn_shiyo_jisseki_anbun == ActionConst.shiyoJissekiAnbunKubunZan)
                        {


                            //製品計画トランへインサートします。
                            AddSeihinKeikaku(context, updated, pLotSaiban);
                        }
                    }
                }
            }

            // 変更セットを元に削除対象のエンティティを削除します。
            if (!errFlg && value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    // 既存エンティティを取得します。
                    tr_sap_shiyo_yojitsu_anbun current = GetSingleEntity(context, deleted.no_seq);
                    shikakariLotNo = deleted.no_lot_shikakari;
                    var anbunKbn = current.kbn_shiyo_jisseki_anbun;

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        tr_sap_shiyo_yojitsu_anbun data = SetCriteriaToAnbunData(deleted, context);
                        duplicates.Deleted.Add(new Duplicate<tr_sap_shiyo_yojitsu_anbun>(data, current));
                        continue;
                    }

                    // エンティティを削除します。
                    context.DeleteObject(current);

                    //変更前の使用実績按分区分が「残」の時
                    if (anbunKbn == ActionConst.shiyoJissekiAnbunKubunZan)
                    {

                        //既存データの取得とエンティティの削除
                        trDelete(deleted, context);
  
                    }
                }
            }

            // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
            // エラー情報を返します；。
            if (invalidations.Count > 0)
            {
                // エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSet<SeizoJissekiSentakuCriteria>>(HttpStatusCode.BadRequest, invalidations);
            }

            // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
            // コンテントに競合したデータを設定します。
            if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
            {
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<tr_sap_shiyo_yojitsu_anbun>>(HttpStatusCode.Conflict, duplicates);
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
                        if (!string.IsNullOrEmpty(shikakariLotNo))
                        {
                            // 仕掛品ロット番号で、関連する按分データを未伝送に一括更新
                            context.usp_SeizoJissekiSentaku_update(
                                shikakariLotNo
                                , ActionConst.densoJotaiKbnMidenso
                                , ActionConst.densoJotaiKbnMisakusei
                            );
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
        /// PKで既存エンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="key1">シーケンス番号</param>
        /// <returns>既存エンティティ</returns>
        private tr_sap_shiyo_yojitsu_anbun GetSingleEntity(FoodProcsEntities context, String key1)
        {
            var result = context.tr_sap_shiyo_yojitsu_anbun.SingleOrDefault(tr => tr.no_seq == key1);

            return result;
        }

        /// <summary>
        /// Criteriaからtr_sap_shiyo_yojitsu_anbunの明細データを作成する
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="criteria">Criteria</param>
        private tr_sap_shiyo_yojitsu_anbun SetCriteriaToAnbunData(SeizoJissekiSentakuCriteria criteria, FoodProcsEntities context)
        {
            tr_sap_shiyo_yojitsu_anbun data = new tr_sap_shiyo_yojitsu_anbun();

            //製品ロット番号の採番処理をします。
            //String pLotSaiban = null;
            //if (criteria.kbn_shiyo_jisseki_anbun == ActionConst.shiyoJissekiAnbunKubunZan)
            //{
            //    pLotSaiban = FoodProcsCommonUtility.executionSaiban(
            //        ActionConst.SeihinLotSaibanKbn, ActionConst.SeihinLotPrefixSaibanKbn, context);
            //    data.no_lot_seihin = pLotSaiban;
            //}
            //else
            //{
            //    data.no_lot_seihin = criteria.no_lot_seihin;
            //}

            
            data.no_seq = criteria.no_seq;
            data.no_lot_shikakari = criteria.no_lot_shikakari;
            data.kbn_shiyo_jisseki_anbun = criteria.kbn_shiyo_jisseki_anbun;
            data.dt_shiyo_shikakari = criteria.dt_shiyo_shikakari;
            data.su_shiyo_shikakari = criteria.su_shiyo_shikakari;
            data.cd_riyu = criteria.cd_riyu;
            data.cd_genka_center = criteria.cd_genka_center;
            data.cd_soko = criteria.cd_soko;
            data.kbn_jotai_denso = criteria.kbn_jotai_denso;
            data.ts = criteria.ts;
            data.no_lot_seihin = criteria.no_lot_seihin;
            return data;
        }
        /// <summary>
        /// 製品計画トランの明細データを作成する
        /// </summary>
        /// <param name="criteria"></param>
        /// <returns></returns>
        private tr_keikaku_seihin SetCriteriaToSehinKeikaku(SeizoJissekiSentakuCriteria criteria)
        {
            tr_keikaku_seihin zan = new tr_keikaku_seihin();
            //zan.no_lot_seihin = ;
            zan.dt_seizo = criteria.dt_shiyo_shikakari;
            //zan.cd_shokuba = ;
            //zan.cd_line = ;
            zan.cd_hinmei = criteria.cd_hinmei;
            //zan.su_seizo_jisseki = ;
            zan.flg_jisseki =  ActionConst.FlagTrue;
            zan.kbn_denso = ActionConst.densoJotaiKbnMidenso;
            zan.flg_denso = ActionConst.FlagFalse;
            zan.dt_update = DateTime.UtcNow;
            zan.dt_shomi = criteria.dt_shiyo_shikakari.AddDays((double)(criteria.dd_shomi - 1));
            return zan;
        }
        /// <summary>
        /// 使用予実按分トランにデータがあるかどうかのチェック。すでにいる場合は競合データとして処理する。
        /// </summary>
        /// <param name="context">エンティティの変更セット</param>
        /// <param name="data">明細データCriteria</param>
        /// <returns>チェック結果：エラーの場合メッセージを返却</returns>
        private bool ValidateExistAnbunTran(FoodProcsEntities context, SeizoJissekiSentakuCriteria data)
        {
            List<tr_sap_shiyo_yojitsu_anbun> tran = (
                from tr in context.tr_sap_shiyo_yojitsu_anbun
                where tr.no_lot_shikakari == data.no_lot_shikakari
                select tr).ToList<tr_sap_shiyo_yojitsu_anbun>();

            // 初期表示時に按分トランから取得したレコード数とDBのレコード数が一致しない場合
            // 他ユーザーがすでに編集しているとしてエラーにする。
            int cnt = tran.Count;
            if (cnt != data.recordCount)
            {
                return false;
            }

            // 存在する場合、メッセージを返します
            return true;
        }

        /// <summary>
        /// タイムスタンプの値を比較します。
        /// </summary>
        /// <param name="left">値1</param>
        /// <param name="right">値2</param>
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
        /// 対象のキー(製品ロット番号)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKey(List<dynamic> keys, tr_sap_shiyo_yojitsu_anbun entity)
        {
            return keys.Find(k => k.no_lot_seihin == entity.no_lot_seihin) != null;
        }

        /// <summary>
        /// 対象のキー(製品ロット番号とシーケンス番号)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static bool ContainsKeyLotAndSeq(List<dynamic> keys, tr_sap_shiyo_yojitsu_anbun entity)
        {
            return keys.Find(k => k.no_lot_seihin == entity.no_lot_seihin && k.no_seq == entity.no_seq) != null;
        }

        /// <summary>
        /// エンティティに対するキー情報を登録します。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象のレコード</param>
        private static void AddKey(List<dynamic> keys, SeizoJissekiSentakuCriteria entity)
        {
            // 比較対象のキー値をセット
            dynamic key = new JObject();
            key.no_seq = entity.no_seq;
            key.no_lot_seihin = entity.no_lot_seihin;
            keys.Add(key);
        }

        /// <summary>
        /// 製品ロット番号が重複していないこと
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="entity">1レコード分のデータ</param>
        /// <param name="keys">更新対象のキーリスト</param>
        /// <param name="upKeys">既存行の更新対象キーリスト</param>
        /// <param name="delKeys">既存行の削除対象キーリスト</param>
        /// <returns>チェック結果：エラーの場合、エラーメッセージを返却</returns>
        private String ValidateNoLotSeihin(FoodProcsEntities context, tr_sap_shiyo_yojitsu_anbun entity,
            List<dynamic> keys, List<dynamic> upKeys, List<dynamic> delKeys)
        {
            String errMsg = String.Format(Resources.MS0045, Resources.SeihinLotNumber);    // エラーメッセージ

            tr_sap_shiyo_yojitsu_anbun anbun = null;
            if (entity.no_seq != null)
            {
                // 既存行の場合：自分以外を取得
                anbun = (from tr in context.tr_sap_shiyo_yojitsu_anbun
                         where tr.no_lot_shikakari == entity.no_lot_shikakari
                                && tr.no_lot_seihin == entity.no_lot_seihin
                         && tr.no_seq != entity.no_seq
                         select tr).FirstOrDefault();
            }
            else
            {
                anbun = (from tr in context.tr_sap_shiyo_yojitsu_anbun
                         where tr.no_lot_shikakari == entity.no_lot_shikakari
                                && tr.no_lot_seihin == entity.no_lot_seihin
                         select tr).FirstOrDefault();
            }

            // キーリストが渡されている場合、取得した情報/入力された情報がキーリストに存在するかをチェックする
            dynamic index = null;

            // 新規追加行のキーリスト
            // 【追加行にすでに同一製品ロット番号が存在する】
            if (keys.Count > 0)
            {
                if (ContainsKey(keys, entity))
                {
                    return errMsg;
                }
            }

            // 更新対象のキーリスト
            if (upKeys.Count > 0)
            {
                // DB検索結果が存在していた場合：先にDB情報でキーリストをチェック
                if (anbun != null)
                {
                    // 結果がキーリストに存在するかどうか
                    index = upKeys.Find(k => k.no_seq == anbun.no_seq);
                    if (index != null)
                    {
                        // 存在するかつ製品ロット番号が同じだった場合、メッセージを返す
                        // 【DBにすでに同一製品ロット番号が存在する】
                        if (index.no_lot_seihin == entity.no_lot_seihin)
                        {
                            return errMsg;
                        }
                        // 製品ロット番号が違う場合、画面で編集されているので重複エラーとしない

                        // 入力情報でキーリストをチェック
                        index = upKeys.Find(k => k.no_lot_seihin == entity.no_lot_seihin);
                        if (index != null)
                        {
                            if (index.no_seq != entity.no_seq)
                            {
                                return errMsg;
                            }
                            // 同じシーケンスは自分なので、エラーとしない
                        }
                    }
                    else
                    {
                        if (!ContainsKey(delKeys, anbun))
                        {
                            // DB検索結果が更新対象キーリストに存在しない かつ 削除対象のキーリストに存在しない場合はエラー
                            return errMsg;
                        }
                        else
                        {
                            // 入力情報でキーリストをチェック
                            index = upKeys.Find(k => k.no_lot_seihin == entity.no_lot_seihin);
                            if (index != null)
                            {
                                if (index.no_seq != entity.no_seq)
                                {
                                    return errMsg;
                                }
                                // 同じシーケンスは自分なので、エラーとしない
                            }
                        }
                    }
                }
                // DB検索結果が存在しない場合：入力情報でキーリストをチェック
                else
                {
                    index = upKeys.Find(k => k.no_lot_seihin == entity.no_lot_seihin);
                    if (index != null)
                    {
                        if (index.no_seq != entity.no_seq)
                        {
                            return errMsg;
                        }
                        // 同じシーケンスは自分なので、エラーとしない
                    }
                }
            }
            else
            {
                // DB検索結果が存在し、DBの製品ロット番号が削除対象キーリストに存在しなければ重複エラー
                if (anbun != null && !ContainsKeyLotAndSeq(delKeys, anbun))
                {
                    return errMsg;
                }
                // 削除対象キーリストに存在すればDBからは削除される製品ロット番号なので、エラーとしない
            }

            return string.Empty;

        }

        /// <summary>
        /// 対象のキー(製品ロット番号)を持つエンティティの存在チェックを行います。
        /// </summary>
        /// <param name="keys">キーリスト</param>
        /// <param name="entity">チェック対象の追加レコード</param>
        /// <returns>チェック結果</returns>
        private static usp_YukoHaigoMei_select_Result GetHaigomeiMaster(SeizoJissekiSentakuCriteria criteria, FoodProcsEntities context)
        {
            // 検索用ストアドプロシージャの実行
            var views = context.usp_YukoHaigoMei_select(
                criteria.cd_haigo,
                criteria.dt_shiyo_shikakari,
                ActionConst.FlagFalse
            ).FirstOrDefault();

            return views;
        }

        /// <summary>
        ///  製造ラインマスタを取得します。
        /// </summary>
        /// <param name="cd_haigo">配合コード</param>
        /// <param name="context">エンティティ情報</param>
        /// <returns>優先順位番号が最小値のもの</returns>
        private static ma_seizo_line GetSeizoLineMaster(string cd_haigo, FoodProcsEntities context)
        {
            // 製造ラインマスタ取得
            ma_seizo_line saisho = (from ma in context.ma_seizo_line
                                    where ma.cd_haigo == cd_haigo
                                    && ma.kbn_master == ActionConst.HaigoMasterKbn
                                    orderby ma.no_juni_yusen
                                    select ma).FirstOrDefault();

            return saisho;
        }
        /// <summary>
        /// 任意のラインコードに紐づく製造ラインマスタを取得します。
        /// </summary>
        /// <param name="cd_line">職場コード</param>
        /// <param name="context">エンティティ情報</param>
        /// <returns>任意のラインコードに紐づく製造ラインマスタ</returns>
        private static ma_line GetShokubaCode(string cd_line, FoodProcsEntities context)
        {
            ma_line lineMaster = (from ma in context.ma_line
                                  where ma.cd_line == cd_line
                                  select ma).FirstOrDefault();
            return lineMaster;
        }

        /// <summary>
        /// 品名マスタを取得します。
        /// </summary>
        /// <param name="cd_hinmei">品名コード</param>
        /// <param name="context">エンティティ情報</param>
        /// <returns>任意の品名コードに紐づく品名マスタ</returns>
        private static ma_hinmei GetHinmeiMaster(string cd_hinmei, FoodProcsEntities context)
        {
            ma_hinmei HinMaster = (from ma in context.ma_hinmei
                                      where ma.cd_hinmei == cd_hinmei
                                      select ma).FirstOrDefault();
            return HinMaster;
        
        }

        /// <summary>
        /// 任意の製品ロット番号に紐づく製品計画トランを取得します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="no_lot_seihin">製品ロット番号</param>
        /// <returns>任意の製品ロット番号に紐づく製品計画トラン</returns>
        private tr_keikaku_seihin GetCurrentSeihinKeikaku (FoodProcsEntities context, String no_lot_seihin)
        {

            tr_keikaku_seihin current = (from tr in context.tr_keikaku_seihin
                                   where tr.no_lot_seihin == no_lot_seihin
                                   select tr).FirstOrDefault();
            return current;
        }

        /// <summary>
        /// 任意の製品ロットNo.に紐づく調整トランを取得します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="no_lot_seihin">製品ロットNo.</param>
        /// <returns>任意の製品ロットNo.に紐づく調整トラン</returns>
        private tr_chosei GetCurrentChosei(FoodProcsEntities context, String no_seq)
        {

            tr_chosei current = (from tr in context.tr_chosei
                                         where tr.no_seq == no_seq
                                         select tr).FirstOrDefault();
            return current;
        }

        /// <summary>
        /// 任意の製品ロット番号に紐づく仕掛残使用量トランを取得します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="no_seq_shiyo_yojitsu_anbun">使用予実按分シーケンス</param>
        /// <returns>任意の使用予実按分シーケンスに紐づく仕掛残使用量トラン</returns>
        private tr_shiyo_shikakari_zan GetCurrentShiyoShikakariZan(FoodProcsEntities context, String no_seq_shiyo_yojitsu_anbun)
        {

            tr_shiyo_shikakari_zan current = (from tr in context.tr_shiyo_shikakari_zan
                                              where tr.no_seq_shiyo_yojitsu_anbun == no_seq_shiyo_yojitsu_anbun
                                              select tr).FirstOrDefault();
            return current;
        }

        /// <summary>
        /// 任意の製品ロット番号に紐づく使用予実トランを取得します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="no_lot_seihin">製品ロット番号</param>
        /// <returns>任意の製品ロット番号に紐づく使用予実トラン</returns>
        private tr_shiyo_yojitsu GetCurrentShiyoYojitsu(FoodProcsEntities context, String no_lot_seihin)
        {

            tr_shiyo_yojitsu current = (from tr in context.tr_shiyo_yojitsu
                                              where tr.no_lot_seihin == no_lot_seihin 
                                        select tr).FirstOrDefault();
            return current;
        }

        /// <summary>
        /// 使用予実按分トランへのインサート
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="criteria">画面情報</param>
        /// <param name="pLotSaiban">製品ロット番号</param>
        private void AddYojitsuAnbun(FoodProcsEntities context, SeizoJissekiSentakuCriteria criteria, string pLotSaiban)
        {
            tr_sap_shiyo_yojitsu_anbun data = SetCriteriaToAnbunData(criteria, context);

            //製品ロット番号を格納します。
            data.no_lot_seihin = pLotSaiban;

            // シーケンス番号を取得します。
            String noSaiban = FoodProcsCommonUtility.executionSaiban(
                        ActionConst.ShiyoYojitsuAnbunSeqNoSaibanKbn, ActionConst.ShiyoYojitsuAnbunSeqNoPrefixSaibanKbn, context);
            data.no_seq = noSaiban;

            // エンティティを追加します。
            context.AddTotr_sap_shiyo_yojitsu_anbun(data);

        }
        
        
       /// <summary>
        /// 製品計画トランへのインサート
       /// </summary>
       /// <param name="context">エンティティ情報</param>
       /// <param name="criteria">画面情報</param>
       /// <param name="pLotSaiban">製品ロット番号</param>
        private void AddSeihinKeikaku(
            FoodProcsEntities context, SeizoJissekiSentakuCriteria criteria, string pLotSaiban)

        {
            
            tr_keikaku_seihin zan = SetCriteriaToSehinKeikaku(criteria);
            
            //製造ラインマスタ．優先順位番号が最小値のものを取得します。
            ma_seizo_line SeizoLineMaster = GetSeizoLineMaster(criteria.cd_haigo, context);

            //製造ラインマスタ．優先順位番号が最小値のもののラインコードに紐づく職場コードを取得します。

            ma_line LineMaster = GetShokubaCode(SeizoLineMaster.cd_line, context);

            //格納処理を行います。
            zan.cd_shokuba = LineMaster.cd_shokuba;
            zan.cd_line = SeizoLineMaster.cd_line;


            //製品ロット番号を格納します。
            
            zan.no_lot_seihin = pLotSaiban;

            //品名マスタの入数、個重量、比重を取得します。

            ma_hinmei HinmeiMaster = GetHinmeiMaster(criteria.cd_hinmei, context);

            decimal? irisu = HinmeiMaster.su_iri ?? (decimal?)1.00;
            decimal? kojyuryo = HinmeiMaster.wt_ko ?? (decimal?)1.00;
            decimal? hijyu = HinmeiMaster.ritsu_hiju ?? (decimal?)1.00;

            //配合名マスタの歩留を取得します。
            usp_YukoHaigoMei_select_Result GetHaigoMaster = GetHaigomeiMaster(criteria, context);
            decimal? Budomari = GetHaigoMaster.ritsu_budomari_mei ?? (decimal?)1.00;

            //製造実績数の計算をします。
            //decimal? Kekka = criteria.su_shiyo_shikakari / (irisu * kojyuryo / hijyu / Budomari * 100);
            decimal? Kekka = criteria.su_shiyo_shikakari / (irisu * kojyuryo);

            zan.su_seizo_jisseki = (decimal?)Math.Floor((double)Kekka);

            // エンティティを追加します。
            context.AddTotr_keikaku_seihin(zan);
        }
      
        /// <summary>
        /// 調整トラン、仕掛残使用量トラン、仕掛残使用予実トラン、製品計画トランの削除
        /// </summary>
        /// <param name="criteria">画面情報</param>
        /// <param name="context">エンティティ情報</param>
        private void trDelete(SeizoJissekiSentakuCriteria criteria, FoodProcsEntities context)
        {
            context.usp_SeizoJissekiSentaku_delete(criteria.con_no_lot_seihin, criteria.no_seq);
        }
    }
}