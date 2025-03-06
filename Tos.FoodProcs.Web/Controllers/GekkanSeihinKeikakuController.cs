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
using System.Data.SqlClient;
using System.Web.Security;
using System.Data.Objects;
using Tos.FoodProcs.Web.Models;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class GekkanSeihinKeikakuController : ApiController
    {
        // GET api/GekkanSeihinKeikaku
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_GekkanSeihinKeikaku_select_Result> Get([FromUri]GekkanSeihinKeikakuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド用に値を判定
            IEnumerable<usp_GekkanSeihinKeikaku_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_GekkanSeihinKeikaku_select(
                criteria.cd_shokuba
                , criteria.cd_line
                , short.Parse(criteria.cd_riyu)
                , short.Parse(criteria.flg_mishiyo)
                , criteria.dt_hiduke_from
                , criteria.dt_hiduke_to
                , ActionConst.FlagFalse // 全ライン出力
                , ActionConst.FlagFalse // エクセル出力かどうか
                , ActionConst.FlagTrue
                , ActionConst.FlagFalse
                , criteria.skip, criteria.top, count).ToList();

            var result = new StoredProcedureResult<usp_GekkanSeihinKeikaku_select_Result>();

            result.d = views;

            int _cnt = ((List<usp_GekkanSeihinKeikaku_select_Result>)views).Count;
            // 取得件数が0件以上の場合
            if (_cnt > 0)
            {
                result.__count = (int)views.ElementAt<usp_GekkanSeihinKeikaku_select_Result>(0).cnt;
            }
            // 取得件数が0件の場合
            else
            {
                result.__count = ((List<usp_GekkanSeihinKeikaku_select_Result>)views).Count;
            }

            return result;
        }

        // POST api/GekkanSeihinKeikaku
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<GekkanSeihinKeikakuCriteria> value)
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
                        // 使用予実再作成対象仕掛品ロット番号格納辞書
                        Dictionary<string, string> shiyoShikakariDic = new Dictionary<string, string>();

                        // 変更セットを元に削除対象のエンティティを追加します。
                        // 削除を最初に行う（削除対象データがSummaryの対象とならないように）
                        if (value.Deleted != null)
                        {
                            foreach (var line in value.Deleted)
                            {
                                tr_keikaku_seihin seihin_now = (from tr in context.tr_keikaku_seihin
                                                                   where tr.no_lot_seihin == line.no_lot_seihin
                                                                   select tr).AsEnumerable().FirstOrDefault();

                                // 排他チェック
                                // if ((seihin_now == null) || (seihin_now.dt_update != line.dt_update))
                                if ((String.IsNullOrEmpty(line.cd_riyu)) &&
                                    ((seihin_now == null) || (seihin_now.dt_update != line.dt_update)))
                                {
                                    // 休日理由が設定されていない場合、且つ
                                    // 対象のレコードが存在しない場合、または対象行のdt_updateがDBと一致しなかった場合、エラーとする
                                    string errorMsg = String.Format(Resources.MS0823);
                                    InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                    ioe.Data.Add("key", "MS0823");
                                    throw ioe;
                                }

                                // 実績チェック
                                if (!string.IsNullOrEmpty(line.no_lot_seihin))
                                {
                                    // チェックエラー時はInvalidOperationExceptionがthrowされる
                                    FoodProcsCommonUtility.checkKeikakuJissekiFlag(context, line.no_lot_seihin, "", "", line.dt_seizo, Resources.NonyuIraishoPdfDelete);
                                }                               
                                
                                //// 対象の仕掛品の変更前データを取得する。
                                //tr_keikaku_shikakari updateSeihinShikakari = (from tr in context.tr_keikaku_shikakari
                                //                                              where tr.no_lot_seihin == line.no_lot_seihin
                                //                                              select tr).AsEnumerable().FirstOrDefault();

                                //if (updateSeihinShikakari != null)
                                //{

                                //    IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> lotLists;
                                //    lotLists = context.usp_ShikakarihinKeikakuDelete_select(updateSeihinShikakari.no_lot_shikakari, updateSeihinShikakari.data_key);

                                //    foreach (var val in lotLists)
                                //    {

                                //        // 対象の仕掛品の変更前データを取得する。
                                //        su_keikaku_shikakari updateSeihinFlg = (from tr in context.su_keikaku_shikakari
                                //                                                where tr.no_lot_shikakari == val.no_lot_shikakari
                                //                                                select tr).AsEnumerable().FirstOrDefault();

                                //        //if (updateSeihinFlg.flg_shikomi == 1)
                                //        if (updateSeihinFlg != null && updateSeihinFlg.flg_shikomi == 1)
                                //        {
                                //            string errorMsg = String.Format(
                                //            Resources.MS0743, Resources.NonyuIraishoPdfDelete, line.no_lot_seihin);
                                //            InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                //            ioe.Data.Add("key", "MS0743");
                                //            throw ioe;
                                //        }
                                //    }
                                //}

                                IEnumerable<tr_keikaku_shikakari> shikakariList = (from tr in context.tr_keikaku_shikakari
                                                                                   where tr.no_lot_seihin == line.no_lot_seihin
                                                                                   select tr).AsEnumerable();

                                // サマリ再作成対象の仕掛品ロット番号を設定
                                foreach (tr_keikaku_shikakari shikakari in shikakariList)
                                {
                                    if (!shiyoShikakariDic.ContainsKey(shikakari.no_lot_shikakari))
                                    {
                                        shiyoShikakariDic.Add(shikakari.no_lot_shikakari, shikakari.no_lot_shikakari);
                                    }
                                }

                                ///// UPDATE対象の仕掛品サマリデータを先に取得
                                //IEnumerable<usp_SeihinKeikaku_Summary_select_Result> summaryList =
                                //    context.usp_SeihinKeikaku_Summary_select(line.no_lot_seihin);

                                ///// 製品ロット番号から製品計画トラン・仕掛品計画トラン・仕掛品計画サマリ、ライン休日トラン削除
                                context.usp_SeihinKeikaku_Lot_delete(
                                    line.no_lot_seihin, line.cd_line, line.dt_seizo, line.cd_riyu, ActionConst.FlagTrue);

                                ///// ライン休日トラン削除 理由コードの有無は関係なく削除ロジックを通す
                                context.usp_SeihinKeikaku_line_kyujitsu_update(
                                    line.cd_line, line.dt_seizo, null, null, Resources.KyujitsuRiyuKbn);

                                /////// 他に合算データが存在した場合の仕掛品サマリの更新
                                //foreach (var sumData in summaryList)
                                //{
                                //    // 他に合算データが存在しない場合はusp_SeihinKeikaku_Lot_deleteで削除されているのでcurrentはnullになる
                                //    var current = context.su_keikaku_shikakari.SingleOrDefault(su => su.no_lot_shikakari == sumData.no_lot_shikakari);
                                //    if (current != null)
                                //    {
                                //        // レシピ展開オブジェクトの作成
                                //        RecipeTenkaiObject sumObj = new RecipeTenkaiObject();
                                //        sumObj.haigoCode = sumData.cd_shikakari_hin;
                                //        // 必要重量：削除した仕掛品トランデータの計画仕込重量の分、サマリの計画仕込重量から引いた値
                                //        sumObj.hitsuyoJuryo = (Decimal)sumData.wt_shikomi_keikaku;

                                //        ///// バッチ数の再計算処理
                                //        BairitsuObject bObj = null;
                                //        // 配合名マスタの情報を取得する。必ず1件
                                //        IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                                //            context.usp_RecipeTenkai_ma_haigo_mei_select(sumData.cd_shikakari_hin, line.dt_seizo, ActionConst.FlagFalse);
                                //        foreach (var val in views)
                                //        {
                                //            bObj = FoodProcsCalculator.makeBairitsuObject(sumObj, (Decimal)val.wt_haigo_gokei, (Decimal)val.ritsu_kihon);
                                //        }

                                //        // 仕掛品サマリの更新
                                //        //current.wt_shikomi_keikaku = sumObj.hitsuyoJuryo;
                                //        //current.wt_hitsuyo = sumObj.hitsuyoJuryo;
                                //        //current.su_batch_keikaku = bObj.batchSu;
                                //        //current.su_batch_keikaku_hasu = bObj.batchSuHasu;
                                //        //context.su_keikaku_shikakari.ApplyOriginalValues(current);
                                //        //context.su_keikaku_shikakari.ApplyCurrentValues(current);
                                //        // 計算しなおした倍率データを元に、仕掛品サマリを更新
                                //        context.usp_KeikakuSummary_update(
                                //            current.dt_seizo, current.cd_shikakari_hin, current.cd_shokuba, current.cd_line, current.no_lot_shikakari,
                                //            sumObj.hitsuyoJuryo, sumObj.hitsuyoJuryo, bObj.batchSu, bObj.batchSuHasu);

                                //    }
                                //}


                                // TOsVN - 20089 trung.nq - save change tr_henko_rireki 
                                // ------------- START ----------------
                                // context.usp_tr_henko_rireki_update(0, 2, line.dt_seizo, line.cd_hinmei, line.su_seizo_yotei, 0, line.no_lot_seihin, null, User.Identity.Name);
                                // -------------- END -----------------
                                if (!String.IsNullOrEmpty(line.cd_hinmei))
                                {
                                    // 製品を削除した場合、変更履歴に登録する(=休日理由の削除は履歴に登録しない)
                                    context.usp_tr_henko_rireki_update(0, 2, line.dt_seizo, line.cd_hinmei, line.su_seizo_yotei, 0, line.no_lot_seihin, null, User.Identity.Name);
                                }
                            }
                        }

                        // 変更セットを元に追加対象のエンティティを追加します。
                        if (value.Created != null)
                        {
                            RecipeTenkaiDAO dao = new RecipeTenkaiDAO(context);
                            Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic =
                                new Dictionary<ShikakariGassanKey, RecipeTenkaiObject>();

                            foreach (var line in value.Created)
                            {
                                // 製品計画の登録データ作成
                                SeihinKeikakuObject seihin = new SeihinKeikakuObject(line);

                                String noLotSeihin = line.no_lot_seihin;
                                String noShikakariLot = null;
                                string shikakariDataKey = null;

                                // 排他チェック
                                if (!String.IsNullOrEmpty(noLotSeihin))  // 新規の場合はスキップ
                                {
                                    tr_keikaku_seihin seihin_now = (from tr in context.tr_keikaku_seihin
                                                                       where tr.no_lot_seihin == noLotSeihin
                                                                       select tr).AsEnumerable().FirstOrDefault();

                                    if ((seihin_now == null) || (seihin_now.dt_update != line.dt_update))
                                    {
                                        // 更新対象のレコードが存在しない場合、または更新対象行のdt_updateがDBと一致しなかった場合、エラーとする
                                        string errorMsg = String.Format(Resources.MS0823);
                                        InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                        ioe.Data.Add("key", "MS0823");
                                        throw ioe;
                                    }
                                }

                                // 実績チェック
                                if (!string.IsNullOrEmpty(noLotSeihin))
                                {
                                    // チェックエラー時はInvalidOperationExceptionがthrowされる
                                    //FoodProcsCommonUtility.checkKeikakuJissekiFlag(context, noLotSeihin, "", "", line.dt_seizo);
                                    FoodProcsCommonUtility.checkKeikakuJissekiFlag(context, noLotSeihin, "", "", line.dt_seizo, Resources.NonyuIraishoPdfChange);

                                    tr_keikaku_shikakari shikakari = (from tr in context.tr_keikaku_shikakari
                                                                         where tr.no_lot_seihin == noLotSeihin
                                                                         select tr).AsEnumerable().FirstOrDefault();

                                    if (shikakari != null)
                                    {
                                    
                                        noShikakariLot = shikakari.no_lot_shikakari;
                                        shikakariDataKey = shikakari.data_key;

                                    }
                                }

                                //　レシピ展開 method start
                                List<RecipeTenkaiObject> recipeList = new List<RecipeTenkaiObject>();
                                // 倍率オブジェクトは品名ごとに変わるのでこのタイミングで作成
                                List<BairitsuObject> bairitsuList = new List<BairitsuObject>();

                                IEnumerable<usp_RecipeTenkai_Result> hinmeiViews = null;
                                IEnumerable<usp_SeihinKeikaku_Shizai_select_Result> shizaiViews = null;

                                String hinmeiCode = line.cd_hinmei;
                                String haigoCode = null;
                                int kaisoSu;
                                // 画面で「ｃ/ｓか展開するか」でc/sを選択した場合
                                if (Resources.GekkanSeihinKeikakuHenkozumiCSKbn.Equals(line.henkozumi_data))
                                {
                                    // 製品ロット番号から製品計画トラン
                                    //context.usp_SeihinKeikaku_SeihinLot_delete(noLotSeihin);
                                    // 月間製品計画トランへの更新
                                    context.usp_SeihinKeikaku_update(
                                        seihin.seihinLotNo, seihin.seizoDate, seihin.shokubaCode, seihin.lineCode,
                                        seihin.hinmeiCode, Convert.ToDecimal(seihin.seizoYoteiSu),
                                        ActionConst.FlagFalse, ActionConst.FlagFalse, ActionConst.FlagFalse, line.su_batch_keikaku);
                                }
                                // 品名コードが入っている且つ理由コードが解除ではない
                                else if (!String.IsNullOrEmpty(hinmeiCode) && !Resources.RiyuKaijoKbn.Equals(line.cd_riyu))
                                {
                                    // 新規データの判断基準（製品ロット番号が付番されているか）
                                    if (String.IsNullOrEmpty(noLotSeihin))
                                    {
                                        // 製品ロット番号を取得
                                        noLotSeihin = FoodProcsCommonUtility.executionSaiban(
                                            ActionConst.SeihinLotSaibanKbn, ActionConst.SeihinLotPrefixSaibanKbn, context);
                                        seihin.seihinLotNo = noLotSeihin;
                                    }

                                    // 画面の品名コードより品名マスタ、配合名マスタ、資材使用マスタ検索
                                    hinmeiViews = context.usp_SeihinKeikaku_FromItem_select(
                                        hinmeiCode, line.su_seizo_yotei, line.cd_shokuba, line.cd_line, line.dt_seizo, ActionConst.FirstKaiso,
                                        ActionConst.FlagFalse, ActionConst.FlagFalse, ActionConst.HaigoMasterKbn, ActionConst.FlagFalse);

                                    // 職場コード、ラインコードチェック　どちらかが存在しない場合はエラーとする
                                    var hinmeiViewList = hinmeiViews.ToList<usp_RecipeTenkai_Result>();
                                    foreach (var chkVal in hinmeiViewList)
                                    {
                                        if (string.IsNullOrEmpty(chkVal.cd_line) || string.IsNullOrEmpty(chkVal.cd_shokuba))
                                        {
                                            // 展開した仕掛品のラインコードまたは職場コードが存在しなかった場合、エラーとする
                                            DateTime dtSeizo = (DateTime)chkVal.dt_seizo;
                                            dtSeizo = dtSeizo.AddHours(9);
                                            string errorMsg = String.Format(
                                                Resources.MS0707, dtSeizo.ToString(ActionConst.DateFormat), chkVal.cd_hinmei);
                                            //throw new Exception(errorMsg);
                                            InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                            ioe.Data.Add("key", "MS0707");
                                            throw ioe;
                                        }
                                    }

                                    shizaiViews = context.usp_SeihinKeikaku_Shizai_select(
                                        hinmeiCode, line.su_seizo_yotei, line.cd_shokuba, line.dt_seizo, ActionConst.FlagFalse);
                                    if (shizaiViews != null)
                                    {
                                        // 資材の使用予実トラン作成
                                        FoodProcsCalculator.calcShiyoYozitsuForShizai(shizaiViews, recipeList, noLotSeihin);
                                    }

                                    // hinmeiViewsは一件のみ
                                    RecipeTenkaiObject data;
                                    foreach (var recipe in hinmeiViewList)
                                    {
                                        // 一階層目の仕掛品の展開フラグ(自動立案フラグ)が立っていれば展開処理を行う。
                                        // 展開フラグ(自動立案フラグ)が立っていない場合は処理を終了する。(製品計画のみ立てる)
                                        if (recipe.haigo_flg_tenkai == ActionConst.FlagTrue)
                                        {
                                            // 品名情報より仕掛品トランのデータ作成
                                            data = new RecipeTenkaiObject(recipe);
                                            data.seihinLotNo = noLotSeihin;

                                            // 仕掛品計画トランのデータキーを取得
                                            if (shikakariDataKey == null)
                                            {
                                                //string shikakariDataKey = FoodProcsCommonUtility.executionSaiban(
                                                shikakariDataKey = FoodProcsCommonUtility.executionSaiban(
                                                        ActionConst.ShikakarihinKeikakuSaibanKbn, ActionConst.ShikakarihinKeikakuPrefixSaibanKbn, context);
                                            }
                                            data.dataKey = shikakariDataKey;

                                            // 一階層目の計算
                                            // 倍率オブジェクトも一緒に作成
                                            FoodProcsCalculator.calcSeizoDataFirstRow(data, bairitsuList);
                                            recipeList.Add(data);
                                            // サマリデータ作成
                                            // String noShikakariLot = dao.makeSummaryData(dic, data, Convert.ToInt16(data.gassanShikomiFlag), null);
                                            if (noShikakariLot == null)
                                            {
                                                noShikakariLot = dao.makeSummaryData(dic, data, Convert.ToInt16(data.gassanShikomiFlag), noShikakariLot);
                                            }
                                            else
                                            {
                                                // 合算用辞書だけ作成しておく。
                                                dao.makeSummaryOfHikitsugi(dic, data);
                                            }
                                            
                                            if (String.IsNullOrEmpty(noShikakariLot))
                                            {
                                                // 仕掛品ロット番号を付与
                                                noShikakariLot = FoodProcsCommonUtility.executionSaiban(
                                                    ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
                                            }
                                            data.shikakariLotNo = noShikakariLot;

                                            // 配合データをレシピ展開してListにadd
                                            kaisoSu = (int)recipe.su_kaiso;
                                            haigoCode = recipe.cd_haigo;
                                            dao.selectHaigo(line.cd_hinmei, haigoCode, kaisoSu, line.dt_seizo, DateTime.Today, line.cd_shokuba,
                                                line.cd_line, noLotSeihin, noShikakariLot, recipeList, dic, bairitsuList, shikakariDataKey);
                                        }
                                    }

                                    // 製品ロット番号から製品計画トラン・仕掛品計画トラン・仕掛品計画サマリ(一部)削除
                                    context.usp_SeihinKeikaku_Lot_delete(noLotSeihin, null, null, null, ActionConst.FlagFalse);

                                    // 月間製品計画トランへの更新
                                    context.usp_SeihinKeikaku_update(seihin.seihinLotNo, seihin.seizoDate, seihin.shokubaCode, seihin.lineCode,
                                        seihin.hinmeiCode, Convert.ToDecimal(seihin.seizoYoteiSu),
                                        ActionConst.FlagFalse, ActionConst.FlagFalse, ActionConst.FlagFalse, line.su_batch_keikaku);

                                    // 仕掛品計画トラン、使用予実トランへの更新
                                    foreach (var shikakari in recipeList)
                                    {
                                        // 配合レシピの品名コードがNULLのものは品名マスタのデータのため除外
                                        if (!String.IsNullOrEmpty(shikakari.recipeHinmeiCode))
                                        {
                                            // 品区分で登録先を変える
                                            if (shikakari.recipeHinKubun == ActionConst.GenryoHinKbn.ToString()
                                                || shikakari.recipeHinKubun == ActionConst.JikaGenryoHinKbn.ToString())
                                            {
                                                //// 使用予実(原料)
                                                //context.usp_SeihinKeikaku_Shiyo_update(ActionConst.YoteiYojitsuFlag, shikakari.recipeHinmeiCode, shikakari.seizoDate,
                                                //    shikakari.seihinLotNo, shikakari.shikakariLotNo, Convert.ToDecimal(shikakari.keikakuShikomiJuryo),
                                                //    ActionConst.ShiyoYojitsuSeqNoSaibanKbn, ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn, shikakari.dataKey);
                                            }
                                            // TODO：一階層目は「0」が固定で返却される為、条件に「0」を入れる
                                            else if (shikakari.recipeHinKubun == ActionConst.ShikakariHinKbn.ToString()
                                                || shikakari.recipeHinKubun == "0")
                                            {
                                                // 仕掛トラン(仕掛品）
                                                context.usp_SeihinKeikaku_Shikakari_update(shikakari.dataKey, shikakari.seizoDate, shikakari.seizoDate
                                                    , shikakari.seihinLotNo, shikakari.shikakariLotNo, shikakari.oyaShikakariLotNo, shikakari.shokubaCode
                                                    , shikakari.lineCode, shikakari.recipeHinmeiCode, Convert.ToDecimal(shikakari.keikakuShikomiJuryo)
                                                    , null, shikakari.kaisoSu, null, null, null, null, null
                                                    , shikakari.hinmeiCode, Convert.ToDecimal(shikakari.hitsuyoJuryo), shikakari.oyaDataKey);
                                            }
                                        }
                                        else if (shikakari.recipeHinKubun == ActionConst.ShizaiHinKbn.ToString())
                                        {
                                            // 資材の登録処理
                                            context.usp_SeihinKeikaku_Shiyo_update(ActionConst.YoteiYojitsuFlag, shikakari.shizaiCode,
                                                shikakari.seizoDate, shikakari.seihinLotNo, null, Convert.ToDecimal(shikakari.keikakuShikomiJuryo),
                                                ActionConst.ShiyoYojitsuSeqNoSaibanKbn, ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn, null);
                                        }
                                    }

                                    //// サマリのデータ登録
                                    //// 想定時には登録対象行全行の計算終了後行う
                                    //foreach (RecipeTenkaiObject summary in dic.Values)
                                    //{
                                    //    // サマリデータの作成
                                    //    var sumList = (from tr in context.tr_keikaku_shikakari
                                    //                   where tr.no_lot_seihin == summary.shikakariLotNo
                                    //                   select tr);
                                    //    decimal hitsuyoJuryo = 0;
                                    //    decimal shikomiJuryo = 0;
                                    //    foreach (var sumData in sumList)
                                    //    {
                                    //        hitsuyoJuryo += (decimal)sumData.wt_hitsuyo;
                                    //        shikomiJuryo += (decimal)sumData.wt_shikomi_keikaku;
                                    //    }
                                    //    summary.hitsuyoJuryo = hitsuyoJuryo;
                                    //    summary.keikakuHaigoJuryo = shikomiJuryo;

                                    //    BairitsuObject bObj = null;
                                    //    // 配合名マスタの情報を取得する。必ず1件
                                    //    //string recipeHaigoCode = summary.recipeHaigoCode;
                                    //    string recipeHaigoCode = summary.recipeHinmeiCode;
                                    //    IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                                    //        context.usp_RecipeTenkai_ma_haigo_mei_select(recipeHaigoCode, summary.seizoDate, ActionConst.FlagFalse);
                                    //    foreach (var val in views)
                                    //    {
                                    //        bObj = FoodProcsCalculator.makeBairitsuObject(summary, (Decimal)val.wt_haigo_gokei, (Decimal)val.ritsu_kihon);
                                    //    }
                                    //    // 登録前に削除処理（同一の仕掛ロット番号を持ったデータが存在する可能性があるため）
                                    //    // 上記の削除では検索できないデータ
                                    //    context.usp_SeihinKeikaku_SummaryLot_delete(summary.shikakariLotNo);

                                    //    // 登録処理
                                    //    context.usp_SeihinKeikaku_Summary_update(
                                    //        summary.seizoDate, summary.recipeHinmeiCode, summary.shokubaCode, summary.lineCode
                                    //        , Convert.ToDecimal(summary.hitsuyoJuryo), Convert.ToDecimal(summary.keikakuShikomiJuryo)
                                    //        , null, null, null, null
                                    //        , Convert.ToDecimal(bObj.keikakuHaigoJuryo), Convert.ToDecimal(bObj.keikakuHaigoJuryoHasu), Convert.ToDecimal(bObj.batchSu)
                                    //        , Convert.ToDecimal(bObj.batchSuHasu), Convert.ToDecimal(bObj.bairitsu), Convert.ToDecimal(bObj.bairitsuHasu)
                                    //        , null, null, null, null, null, null
                                    //        , ActionConst.CalcDefaultNumber, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumber
                                    //        , ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort
                                    //        , ActionConst.CalcDefaultNumberShort, summary.shikakariLotNo, ActionConst.CalcDefaultNumberShort);
                                    //}
                                }

                                if (!String.IsNullOrEmpty(line.cd_riyu))
                                {
                                    // 「*」の場合は休日削除処理
                                    //if (Resources.RiyuKaijoKbn.Equals(line.cd_riyu))
                                    //{
                                    //}
                                    // ライン休日トラン登録
                                    String userCode = User.Identity.Name;
                                    context.usp_SeihinKeikaku_line_kyujitsu_update(
                                        line.cd_line, line.dt_seizo, line.cd_riyu, userCode, Resources.RiyuKaijoKbn);
                                }

                                // TOsVN - 20089 trung.nq - save change tr_henko_rireki 
                                // ------------- START ----------------
                                // if (line.su_seizo_yotei != line.su_seizo_yotei_old)
                                if (String.IsNullOrEmpty(line.cd_riyu) &&
                                    line.su_seizo_yotei != line.su_seizo_yotei_old)
                                {
                                    // 休日理由が設定されていない、且つ製造予定数が変更されている場合に変更履歴を登録する
                                    if (line.su_seizo_yotei_old != 0)
                                    {
                                        context.usp_tr_henko_rireki_update(0, 1, line.dt_seizo, line.cd_hinmei, line.su_seizo_yotei, 0, noLotSeihin, null, User.Identity.Name);
                                    }
                                    else
                                    {
                                        context.usp_tr_henko_rireki_update(0, 0, line.dt_seizo, line.cd_hinmei, line.su_seizo_yotei, 0, noLotSeihin, null, User.Identity.Name);
                                    }
                                }
                                // -------------- END -----------------
                            }
                            
                            // サマリのデータ登録
                            // 想定時には登録対象行全行の計算終了後行う
                            foreach (RecipeTenkaiObject summary in dic.Values)
                            {
                                //// サマリデータの作成
                                //var sumList = (from tr in context.tr_keikaku_shikakari
                                //               where tr.no_lot_shikakari == summary.shikakariLotNo
                                //               //where tr.dt_seizo == summary.seizoDate
                                //               //&& tr.cd_shikakari_hin == summary.recipeHinmeiCode
                                //               //&& tr.cd_shokuba == summary.shokubaCode
                                //               //&& tr.cd_line == summary.lineCode
                                //               select tr).AsEnumerable();
                                //decimal hitsuyoJuryo = 0;
                                //decimal shikomiJuryo = 0;
                                //foreach (var sumData in sumList)
                                //{
                                //    if (sumData.wt_hitsuyo != null)
                                //    {
                                //        hitsuyoJuryo += (decimal)sumData.wt_hitsuyo;
                                //    }

                                //    if (sumData.wt_shikomi_keikaku != null)
                                //    {
                                //        shikomiJuryo += (decimal)sumData.wt_shikomi_keikaku;
                                //    }

                                //    summary.hitsuyoJuryo = hitsuyoJuryo;
                                //    summary.keikakuShikomiJuryo = shikomiJuryo;

                                //}

                                //BairitsuObject bObj = null;
                                //// 配合名マスタの情報を取得する。必ず1件
                                ////string recipeHaigoCode = summary.recipeHaigoCode;
                                //string recipeHaigoCode = summary.recipeHinmeiCode;
                                //IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                                //    context.usp_RecipeTenkai_ma_haigo_mei_select(recipeHaigoCode, summary.seizoDate, ActionConst.FlagFalse);
                                //foreach (var val in views)
                                //{
                                //    bObj = FoodProcsCalculator.makeBairitsuObject(summary, (Decimal)val.wt_haigo_gokei, (Decimal)val.ritsu_kihon);
                                //}
                                //// 登録前に削除処理（同一の仕掛ロット番号を持ったデータが存在する可能性があるため）
                                //// 上記の削除では検索できないデータ
                                //context.usp_SeihinKeikaku_SummaryLot_delete(summary.shikakariLotNo);

                                //// 登録処理
                                //context.usp_SeihinKeikaku_Summary_update(
                                //    summary.seizoDate, summary.recipeHinmeiCode, summary.shokubaCode, summary.lineCode
                                //    , Convert.ToDecimal(summary.hitsuyoJuryo), Convert.ToDecimal(summary.keikakuShikomiJuryo)
                                //    , null, null, null, null
                                //    , Convert.ToDecimal(bObj.keikakuHaigoJuryo), Convert.ToDecimal(bObj.keikakuHaigoJuryoHasu), Convert.ToDecimal(bObj.batchSu)
                                //    , Convert.ToDecimal(bObj.batchSuHasu), Convert.ToDecimal(bObj.bairitsu), Convert.ToDecimal(bObj.bairitsuHasu)
                                //    , null, null, null, null, null, null
                                //    , ActionConst.CalcDefaultNumber, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumber
                                //    , ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort
                                //    , ActionConst.CalcDefaultNumberShort, summary.shikakariLotNo, ActionConst.CalcDefaultNumberShort);

                                // サマリ再作成対象の仕掛品ロット番号を設定
                                if (!shiyoShikakariDic.ContainsKey(summary.shikakariLotNo))
                                {
                                    shiyoShikakariDic.Add(summary.shikakariLotNo, summary.shikakariLotNo);
                                }
                            }
                        }

                        // 共通計画作成モデルクラスのインスタンスを生成する。
                        CommonKeikakuSakuseiModels keikakuModel = new CommonKeikakuSakuseiModels();

                        // 仕掛品サマリ作成モデルクラスのインスタンスを生成する。
                        ShikakariSummarySakuseiModels summaryModel = new ShikakariSummarySakuseiModels();

                        // contextが保持しているtr_keikaku_shikakariをDBの最新情報でリフレッシュする。
                        context.Refresh(RefreshMode.StoreWins, context.tr_keikaku_shikakari);

                        foreach (string no_lot_shikakari in shiyoShikakariDic.Keys)
                        {
                            // 仕掛品サマリ再作成処理を実行する。
                            summaryModel.updateSummary(context, no_lot_shikakari);
                        }

                        // コンテキストが保持している仕掛品サマリをDBと同期
                        context.Refresh(RefreshMode.StoreWins, context.su_keikaku_shikakari);

                        foreach (string no_lot_shikakari in shiyoShikakariDic.Keys)
                        {
                            // 使用予実トラン再作成処理を実行する。
                            keikakuModel.updateShiyoYojitsu(context, no_lot_shikakari, ActionConst.YoteiYojitsuFlag);
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
                    catch (InvalidOperationException ioe)
                    {
                        var errCode = ioe.Data["key"];
                        if (errCode != null)
                        {
                            //if (errCode == "MS0707")  // コードで処理を分岐する場合、コメントアウトを外す
                            //{
                            // MS0707：展開途中の仕掛品に製造可能ラインがなかった場合のエラー
                            // MS0743：計画内に実績が１つでも存在した場合のエラー
                            return Request.CreateResponse(HttpStatusCode.BadRequest, ioe);
                            //}
                        }
                        throw ioe;
                    }
                    catch (Exception ex)
                    {
                        Exception serviceError = new Exception(Resources.ServiceErrorForClient, ex);
                        return Request.CreateResponse(HttpStatusCode.BadRequest, serviceError);
                    }
                }
            }

            return Request.CreateResponse(HttpStatusCode.OK);
        }
    }
}