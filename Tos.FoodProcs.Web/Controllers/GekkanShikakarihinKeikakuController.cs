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
    public class GekkanShikakarihinKeikakuController : ApiController
    {
        // GET api/GekkanShikakarihinKeikaku
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_GekkanShikakarihinKeikaku_select_Result> Get([FromUri]GekkanShikakarihinKeikakuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド用に値を判定
            IEnumerable<usp_GekkanShikakarihinKeikaku_select_Result> views;
            var count = new ObjectParameter("count", 0);

            // 引数の設定：デバッグしやすいよう、一度変数に設定する
            short flgTrue = ActionConst.FlagTrue;
            short flgFalse = ActionConst.FlagFalse;
            short isHinmeiSearch = criteria.cd_hinmei_search == string.Empty || criteria.cd_hinmei_search == null ? flgFalse : flgTrue;
            short isSelectLotNashi = criteria.select_lot_search == Resources.SelectLotNashi ? flgTrue : flgFalse;
            short isSelectLotOya = criteria.select_lot_search == Resources.SelectLotOya ? flgTrue : flgFalse;
            short isSelectLotSeihin = criteria.select_lot_search == Resources.SelectLotSeihin ? flgTrue : flgFalse;
            short isSelectLotShikakari = criteria.select_lot_search == Resources.SelectLotShikakari ? flgTrue : flgFalse;

            views = context.usp_GekkanShikakarihinKeikaku_select(
                criteria.cd_shokuba
                ,criteria.dt_hiduke_from
                ,criteria.dt_hiduke_to
                ,isHinmeiSearch
                ,criteria.cd_hinmei_search
                ,criteria.no_lot_search
                ,isSelectLotNashi
                ,isSelectLotOya
                ,isSelectLotSeihin
                ,isSelectLotShikakari
                ,criteria.skip
                ,criteria.top
                ,flgFalse // Excelかどうか
                ,flgTrue　// 判定用フラグ
            ,count).ToList();

            var result = new StoredProcedureResult<usp_GekkanShikakarihinKeikaku_select_Result>();

            result.d = views;

            int _cnt = ((List<usp_GekkanShikakarihinKeikaku_select_Result>)views).Count;
            // 取得件数が0件以上の場合
            if (_cnt > 0)
            {
                result.__count = (int)views.ElementAt<usp_GekkanShikakarihinKeikaku_select_Result>(0).cnt;
            }
            // 取得件数が0件の場合
            else
            {
                result.__count = ((List<usp_GekkanShikakarihinKeikaku_select_Result>)views).Count;
            }

            return result;
        }

        // POST api/GekkanShikakarihinKeikaku
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        //public HttpResponseMessage Post([FromBody]ChangeSet<GekkanSeihinKeikakuCriteria> value)
        public HttpResponseMessage Post([FromBody]ChangeSet<GekkanShikakarihinKeikakuCriteria> value)
        
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
                                IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> lotLists;
                                lotLists = context.usp_ShikakarihinKeikakuDelete_select(line.no_lot_shikakari, line.data_key);
                                foreach (var val in lotLists)
                                {
                                    // 対象の仕掛品の変更前データを取得する。
                                    su_keikaku_shikakari deleteSuShikakari = (from tr in context.su_keikaku_shikakari
                                                                                where tr.no_lot_shikakari == val.no_lot_shikakari
                                                                                select tr).AsEnumerable().FirstOrDefault();

                                    //if ((deleteSuShikakari.flg_shikomi == 1 || deleteSuShikakari.flg_jisseki == 1)
                                    //if (deleteSuShikakari != null
                                    //   && (deleteSuShikakari.flg_shikomi == 1 || deleteSuShikakari.flg_jisseki == 1))
                                    if (deleteSuShikakari != null && deleteSuShikakari.flg_jisseki == 1)
                                    {
                                        string errorMsg = String.Format(
                                        Resources.MS0743, Resources.NonyuIraishoPdfDelete, deleteSuShikakari.no_lot_shikakari);
                                        InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                        ioe.Data.Add("key", "MS0743");
                                        throw ioe;
                                    }

                                    // 仕掛品ロット番号辞書に設定する。
                                    if (!shiyoShikakariDic.ContainsKey(val.no_lot_shikakari))
                                    {
                                        shiyoShikakariDic.Add(val.no_lot_shikakari, val.no_lot_shikakari);
                                    }
                                }

                                // 計画削除処理を実行する。
                                this.DeleteKeikaku(line, context);

                                context.SaveChanges();

                                #region メソッドとして分離したためコメントアウトした。 2016/09/09 BRC趙
                                //// 削除対象のデータを取得
                                //IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> targetDate;
                                //targetDate = context.usp_ShikakarihinKeikakuDelete_select(line.no_lot_shikakari, line.data_key);

                                //foreach (var data in targetDate)
                                //{
                                //    // 仕掛品計画トラン・仕掛品計画サマリ・使用予実トランの削除
                                //    // 仕掛品計画サマリは、厳密には更新(対象分、計画仕込重量を引く)、更新の結果計画仕込重量が0になった場合はレコード削除する。
                                //    IEnumerable<usp_ShikakarihinKeikaku_delete_Result> returnWtShikomi;
                                //    returnWtShikomi = context.usp_ShikakarihinKeikaku_delete(
                                //        data.no_lot_shikakari, data.cd_shikakari_hin, data.cd_shokuba, data.cd_line, data.dt_seizo
                                //        , data.wt_shikomi_keikaku, data.data_key);

                                //    // 更新後の仕掛品計画サマリの計画仕込重量を取得する。必ず1件
                                //    foreach (var wtShikomi in returnWtShikomi)
                                //    {
                                //        // 計画仕込重量が存在する(0以上)場合、倍率データの再計算と再設定を行う
                                //        if (wtShikomi.wt_shikomi_keikaku > 0)
                                //        {
                                //            BairitsuObject bObj = null;
                                //            RecipeTenkaiObject summary = new RecipeTenkaiObject();
                                //            // 更新後の仕掛品計画サマリの計画仕込重量を設定
                                //            summary.hitsuyoJuryo = (decimal)wtShikomi.wt_shikomi_keikaku;

                                //            // 配合名マスタの情報を取得する。必ず1件
                                //            IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                                //                context.usp_RecipeTenkai_ma_haigo_mei_select(data.cd_shikakari_hin, data.dt_seizo, ActionConst.FlagFalse);
                                //            foreach (var val in views)
                                //            {
                                //                // 倍率データの再計算
                                //                bObj = FoodProcsCalculator.makeBairitsuObject(summary, (Decimal)val.wt_haigo_gokei, (Decimal)val.ritsu_kihon);
                                //            }
                                //            // 計算しなおした倍率データを元に、仕掛品サマリを更新
                                //            context.usp_ShikakariKeikakuSummaryDelete_update(
                                //                data.dt_seizo, data.cd_shikakari_hin, data.cd_shokuba, data.cd_line, data.no_lot_shikakari,
                                //                bObj.keikakuHaigoJuryo, bObj.keikakuHaigoJuryoHasu, bObj.bairitsu, bObj.bairitsuHasu, bObj.batchSu, bObj.batchSuHasu);
                                //        }
                                //    }
                                //}
                                #endregion
                            }
                        }

                        // 変更セットを元に追加対象のエンティティを追加します。
                        // 後勝ちで更新
                        if (value.Created != null)
                        {
                            // 【処理内容】
                            // 仕掛品トランの更新はDELETE→INSERTだが、仕掛ロット番号は変えない
                            // 修正時、製品との紐付きが切れる（製品ロット番号をNULLで更新）
                            // 親仕掛ロット番号をNULLで更新（子の場合は親から独立する）
                            // ただし、親を修正した場合の、展開先（子供）の親仕掛ロットはNULLにしない
                            // 合算フラグが立っていた場合は合算処理を行う

                            RecipeTenkaiDAO dao = new RecipeTenkaiDAO(context);
                            Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic =
                                new Dictionary<ShikakariGassanKey, RecipeTenkaiObject>();

                            foreach (var line in value.Created)
                            {
                                //Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic = new Dictionary<ShikakariGassanKey, RecipeTenkaiObject>();
                                String noLotSeihin = line.no_lot_seihin;
                                String noShikakariLot = null;
                                string oyaDataKey = null;
                                string seihinCd = null;

                                String deleteData = "";
                                //　レシピ展開 
                                List<RecipeTenkaiObject> recipeList = new List<RecipeTenkaiObject>();
                                // 倍率オブジェクトは行ごとに変わるのでこのタイミングで作成
                                List<BairitsuObject> bairitsuList = new List<BairitsuObject>();

                                #region 変更項目により、更新ではなく、旧データ削除し新規登録とする。
                                if (line.data_key != null)
                                {
                                    //String deleteData = "";
                                    IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> lotLists;
                                    lotLists = context.usp_ShikakarihinKeikakuDelete_select(line.no_lot_shikakari, line.data_key);
                                    deleteData = "";
                                    foreach (var val in lotLists)
                                    {
                                        // 対象の仕掛品の変更前データを取得する。
                                        su_keikaku_shikakari suShikakari = (from tr in context.su_keikaku_shikakari
                                                                            where tr.no_lot_shikakari == val.no_lot_shikakari
                                                                            select tr).AsEnumerable().FirstOrDefault();

                                        // 実績チェック：チェックエラー時はInvalidOperationExceptionがthrowされる
                                        //FoodProcsCommonUtility.checkKeikakuJissekiFlag(
                                        //context, "", val.no_lot_shikakari, val.data_key, line.dt_seizo);

                                        //if (suShikakari.flg_shikomi == 1 || suShikakari.flg_jisseki == 1)
                                        //if (suShikakari != null 
                                        //    && (suShikakari.flg_shikomi == 1 || suShikakari.flg_jisseki == 1))
                                        if (suShikakari != null && suShikakari.flg_jisseki == 1)
                                        {
                                            string errorMsg = String.Format(
                                            Resources.MS0743, Resources.NonyuIraishoPdfChange, suShikakari.no_lot_shikakari);
                                            InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                            ioe.Data.Add("key", "MS0743");
                                            throw ioe;
                                        }

                                        // 削除用のデーキーをカンマ区切りで一変数にする
                                        deleteData += "," + val.data_key;

                                        if (!shiyoShikakariDic.ContainsKey(val.no_lot_shikakari))
                                        {
                                            shiyoShikakariDic.Add(val.no_lot_shikakari, val.no_lot_shikakari);
                                        }

                                    }

                                    // 対象の仕掛品の変更前データを取得する。
                                    tr_keikaku_shikakari oldShikakari = (from tr in context.tr_keikaku_shikakari
                                                                         where tr.data_key == line.data_key
                                                                         select tr).AsEnumerable().FirstOrDefault();

                                    oyaDataKey = oldShikakari.data_key_oya;

                                    seihinCd = oldShikakari.cd_hinmei;

                                    // 仕掛品コード、製造日、ラインコード、職場コードのいずれか変更する場合は、
                                    // 過去のデータの削除し、新規作成をする。
                                    if (line.cd_hinmei != oldShikakari.cd_shikakari_hin
                                        || line.dt_seizo != oldShikakari.dt_seizo
                                        || line.cd_line != oldShikakari.cd_line
                                        || line.cd_shokuba != oldShikakari.cd_shokuba)
                                    //|| line.wt_hitsuyo != oldShikakari.wt_hitsuyo)
                                    {
                                        // 旧レコード情報を作成する。（画面情報ベース）
                                        GekkanShikakarihinKeikakuCriteria copyLine = this.CopyLine(line);
                                        // 変更されている可能性のある項目をDB情報に書き換える
                                        // 仕掛品コード
                                        copyLine.cd_hinmei = oldShikakari.cd_hinmei;
                                        // 製造日
                                        copyLine.dt_seizo = oldShikakari.dt_seizo;
                                        // ラインコード
                                        copyLine.cd_line = oldShikakari.cd_line;
                                        // 職場コード
                                        copyLine.cd_shokuba = oldShikakari.cd_shokuba;

                                        // 元の計画を削除する。
                                        this.DeleteKeikaku(copyLine, context);

                                        // 新規データとして扱うために、仕掛品ロット番号にNULLを設定する。
                                        line.no_lot_shikakari = null;
                                        line.data_key = null;
                                    }
                                }
                                #endregion

                                String haigoCode = line.cd_hinmei;
                                if (!String.IsNullOrEmpty(haigoCode))
                                {
                                    #region 入力チェック処理を処理上部へ移動したためコメントアウトした。2016年09月23日
                                    //String deleteData = "";
                                    //if (!String.IsNullOrEmpty(line.no_lot_shikakari))
                                    //{
                                    //    IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> lotLists;
                                    //    lotLists = context.usp_ShikakarihinKeikakuDelete_select(line.no_lot_shikakari, line.data_key);
                                    //    deleteData = "";
                                    //    foreach (var val in lotLists)
                                    //    {
                                    //        // 対象の仕掛品の変更前データを取得する。
                                    //        su_keikaku_shikakari suShikakari = (from tr in context.su_keikaku_shikakari
                                    //                                             where tr.no_lot_shikakari == val.no_lot_shikakari
                                    //                                             select tr).AsEnumerable().FirstOrDefault();

                                    //        // 実績チェック：チェックエラー時はInvalidOperationExceptionがthrowされる
                                    //        //FoodProcsCommonUtility.checkKeikakuJissekiFlag(
                                    //            //context, "", val.no_lot_shikakari, val.data_key, line.dt_seizo);

                                    //        //if (suShikakari.flg_shikomi == 1 || suShikakari.flg_jisseki == 1)
                                    //        if (suShikakari != null 
                                    //            && (suShikakari.flg_shikomi == 1 || suShikakari.flg_jisseki == 1))
                                    //        {
                                    //            string errorMsg = String.Format(
                                    //            Resources.MS0743, Resources.NonyuIraishoPdfChange, suShikakari.no_lot_shikakari);
                                    //            InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                    //            ioe.Data.Add("key", "MS0743");
                                    //            throw ioe;
                                    //        }
                                    //    }
                                    //}
                                    #endregion

                                    // 展開オブジェクトの作成
                                    RecipeTenkaiObject data = new RecipeTenkaiObject();

                                    // 展開部分
                                    #region tenkai
                                    // レシピリストに加える
                                    data.seizoDate = line.dt_seizo;
                                    data.hitsuyoDate = line.dt_hitsuyo;
                                    data.shokubaCode = line.cd_shokuba;
                                    data.lineCode = line.cd_line;
                                    data.keikakuShikomiJuryo = line.wt_shikomi_keikaku;  // 月間仕掛品の場合は画面の項目がそのまま
                                    //data.hitsuyoJuryo = line.wt_hitsuyo;
                                    data.hitsuyoJuryo = line.wt_shikomi_keikaku;
                                    data.seihinLotNo = line.no_lot_seihin;
                                    data.oyaShikakariLotNo = line.no_lot_shikakari_oya;
                                    data.shikakariLotNo = line.no_lot_shikakari;
                                    data.recipeHinmeiCode = line.cd_hinmei;
                                    data.haigoGokeiJyuryo = line.wt_haigo_gokei.ToString();
                                    data.kihonBairitsu = line.ritsu_kihon.ToString();
                                    data.oyaDataKey = oyaDataKey;
                                    data.hinmeiCode = seihinCd;

                                    // 仕掛品計画トランのデータキーを取得
                                    //data.dataKey = line.data_key;
                                    if (String.IsNullOrEmpty(line.data_key))
                                    {
                                        // 新規で採番する。
                                        // string  dataKey = FoodProcsCommonUtility.executionSaiban(
                                        data.dataKey = FoodProcsCommonUtility.executionSaiban(
                                                ActionConst.ShikakarihinKeikakuSaibanKbn, ActionConst.ShikakarihinKeikakuPrefixSaibanKbn, context);
                                    }
                                    else
                                    {
                                        // 既存のデータキーを使用する。
                                        data.dataKey = line.data_key;
                                    }
                                    //    data.dataKey = dataKey;

                                    // 仕込合算フラグ
                                    if (line.flg_gassan_shikomi == null)
                                    {
                                        data.gassanShikomiFlag = ActionConst.FlagFalse.ToString();
                                    }
                                    else
                                    {
                                        data.gassanShikomiFlag = line.flg_gassan_shikomi.ToString();
                                    }

                                    // 仕掛ロット番号があった場合修正なので
                                    // 仕掛ロットを親仕掛ロットにもつデータも削除する。
                                    // ストアドで再帰的に処理を行いたいがｃ＃で対応
                                    //if (!String.IsNullOrEmpty(line.no_lot_shikakari))
                                    //{
                                    //    // 仕掛ロットを親仕掛ロットにもつデータを抽出
                                    //    //IEnumerable<usp_ShikakarihinKeikaku_DeleteLot_select_Result> lotLists =
                                    //    //    context.usp_ShikakarihinKeikaku_DeleteLot_select(line.no_lot_shikakari);
                                    //    IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> lotLists;
                                    //    lotLists = context.usp_ShikakarihinKeikakuDelete_select(line.no_lot_shikakari, line.data_key);
                                    //    String deleteData = ""; // = line.data_key; //line.no_lot_shikakari;
                                    //    foreach (var val in lotLists)
                                    //    {
                                    //        deleteData += "," + val.data_key; //val.no_lot_shikakari;
                                    //    }
                                    //    // 仕掛品計画トランと使用予実トランの削除
                                    //    context.usp_ShikakarihinKeikaku_Lot_delete(
                                    //        deleteData, null, line.no_lot_shikakari, data.seihinLotNo);
                                    //}

                                    // 倍率リストを作成
                                    BairitsuObject bObj = FoodProcsCalculator.makeBairitsuObject(data,
                                        Convert.ToDecimal(data.haigoGokeiJyuryo), Convert.ToDecimal(data.kihonBairitsu));
                                    bairitsuList.Add(bObj);


                                    // サマリデータ作成
                                    //String noShikakariLot = dao.makeSummaryData(
                                    if (data.shikakariLotNo == null)
                                    {
                                        // 新規の場合は合算対象が存在する場合はその仕掛品ロット番号を取得する。
                                        noShikakariLot = dao.makeSummaryData(
                                            dic, data, Convert.ToInt16(data.gassanShikomiFlag), data.shikakariLotNo);
                                    }
                                    else
                                    {
                                        // 更新の場合は既存仕掛品ロット番号を引き継ぐ
                                        noShikakariLot = data.shikakariLotNo;
                                        dao.makeSummaryOfHikitsugi(dic, data);
                                    }

                                    if (String.IsNullOrEmpty(data.shikakariLotNo))
                                    {
                                        if (String.IsNullOrEmpty(noShikakariLot))
                                        {
                                            // 仕掛品ロット番号を付与
                                            noShikakariLot = FoodProcsCommonUtility.executionSaiban(
                                                ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
                                        }
                                        data.shikakariLotNo = noShikakariLot;
                                    }

                                    // 仕掛品ロット番号を付与してから一行目を作成
                                    recipeList.Add(data);

                                    // 配合名マスタの仕掛フラグを参照し、展開フラグを取得
                                    // ＜参照処理＞


                                    // 仕掛品
                                    dao.selectHaigo(data.hinmeiCode, haigoCode, 0, data.seizoDate, data.hitsuyoDate, data.shokubaCode
                                        , data.lineCode, data.seihinLotNo, noShikakariLot, recipeList, dic, bairitsuList, data.dataKey);

                                    #endregion
                                    // 仕掛品ロット番号とデータkeyから仕掛品計画トラン・使用予実トラン削除（サマリは複数仕掛ロット№が発生するので直前で削除）
                                    //context.usp_ShikakarihinKeikaku_Lot_delete(line.data_key, noShikakariLot);

                                    // ★TODO
                                    if (!String.IsNullOrEmpty(line.no_lot_shikakari))
                                    {
                                        // 仕掛ロットを親仕掛ロットにもつデータを抽出
                                        //IEnumerable<usp_ShikakarihinKeikaku_DeleteLot_select_Result> lotLists =
                                        //    context.usp_ShikakarihinKeikaku_DeleteLot_select(line.no_lot_shikakari);
                                        //IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> lotLists;
                                        //lotLists = context.usp_ShikakarihinKeikakuDelete_select(line.no_lot_shikakari, line.data_key);
                                        //String deleteData = ""; // = line.data_key; //line.no_lot_shikakari;
                                        //foreach (var val in lotLists)
                                        //{
                                        //    deleteData += "," + val.data_key; //val.no_lot_shikakari;
                                        //}
                                        // 仕掛品計画トランと使用予実トランの削除
                                        context.usp_ShikakarihinKeikaku_Lot_delete(
                                            deleteData, null, line.no_lot_shikakari, data.seihinLotNo);
                                    }

                                    // 仕掛品計画トラン、使用予実トランへの更新
                                    foreach (var shikakari in recipeList)
                                    {
                                        // 品区分で登録先を変える
                                        if (shikakari.recipeHinKubun == ActionConst.GenryoHinKbn.ToString())
                                        {
                                            //// 使用予実(原料)
                                            //context.usp_SeihinKeikaku_Shiyo_update(ActionConst.YoteiYojitsuFlag, shikakari.recipeHinmeiCode, shikakari.seizoDate,
                                            //    //    shikakari.seihinLotNo, shikakari.shikakariLotNo, Convert.ToDecimal(shikakari.keikakuShikomiJuryo),
                                            //    //    null, shikakari.shikakariLotNo, Convert.ToDecimal(shikakari.keikakuShikomiJuryo),
                                            //    shikakari.seihinLotNo, shikakari.shikakariLotNo, Convert.ToDecimal(shikakari.keikakuShikomiJuryo),
                                            //    ActionConst.ShiyoYojitsuSeqNoSaibanKbn, ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn, shikakari.dataKey);
                                        }
                                        // 品区分が仕掛品、またはnull(画面から入力された仕掛品)の場合
                                        // ・・・recipeListの一行目に関して、新規で追加した仕掛品の品区分は結果がnullになる為、nullも仕掛品として扱う。
                                        // （展開処理されたデータは必ず何かしらの品区分が入るはず）
                                        else if (shikakari.recipeHinKubun == ActionConst.ShikakariHinKbn.ToString()
                                            || string.IsNullOrEmpty(shikakari.recipeHinKubun))
                                        {
                                            // 画面から入力された仕掛品は、親仕掛ロットをnullにする(親から独立する)
                                            //if (string.IsNullOrEmpty(shikakari.recipeHinKubun))
                                            //{
                                                //shikakari.oyaShikakariLotNo = null;
                                            //}

                                            // 製品ロッドナンバーがない場合
                                            if (string.IsNullOrEmpty(shikakari.seihinLotNo))
                                            {
                                                shikakari.seihinLotNo = null;
                                            }

                                            // 仕掛トラン(仕掛品）
                                            context.usp_SeihinKeikaku_Shikakari_update(shikakari.dataKey, shikakari.seizoDate, shikakari.hitsuyoDate, shikakari.seihinLotNo
                                                , shikakari.shikakariLotNo, shikakari.oyaShikakariLotNo, shikakari.shokubaCode, shikakari.lineCode
                                                , shikakari.recipeHinmeiCode, Convert.ToDecimal(shikakari.keikakuShikomiJuryo), null
                                                , shikakari.kaisoSu, null, null, null, null, null
                                                , shikakari.hinmeiCode, Convert.ToDecimal(shikakari.hitsuyoJuryo), shikakari.oyaDataKey);
                                            //, ActionConst.ShikakarihinKeikakuSaibanKbn, ActionConst.ShikakarihinKeikakuPrefixSaibanKbn);
                                        }
                                    }
                                    //// サマリのデータ登録
                                    //// 想定時には登録対象行全行の計算終了後行う
                                    //foreach (RecipeTenkaiObject summary in dic.Values)
                                    //{
                                    //    // 仕掛計画サマリデータ削除（update/insertと迷ったけど他の画面と処理を合わせる）
                                    //    //context.usp_ShikakarihinKeikaku_SummaryLot_delete(line.no_lot_shikakari);
                                    //    context.usp_ShikakarihinKeikaku_SummaryLot_delete(summary.shikakariLotNo);

                                    //    // 配合名マスタの情報を取得する。必ず1件
                                    //    IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                                    //        //context.usp_RecipeTenkai_ma_haigo_mei_select(summary.recipeHaigoCode, summary.seizoDate, Convert.ToInt16(Resources.FlagFalse));
                                    //        context.usp_RecipeTenkai_ma_haigo_mei_select(summary.recipeHinmeiCode, summary.seizoDate, Convert.ToInt16(Resources.FlagFalse));
                                    //    foreach (var val in views)
                                    //    {
                                    //        FoodProcsCalculator.calcSummaryData(summary, val);
                                    //    }

                                    //    context.usp_SeihinKeikaku_Summary_update(summary.seizoDate, summary.recipeHinmeiCode, summary.shokubaCode, summary.lineCode
                                    //        , Convert.ToDecimal(summary.hitsuyoJuryo), Convert.ToDecimal(summary.keikakuShikomiJuryo), null, null, null, null
                                    //        , Convert.ToDecimal(summary.keikakuHaigoJuryo), Convert.ToDecimal(summary.keikakuHaigoJuryoHasu), Convert.ToDecimal(summary.keikakuBatchSu)
                                    //        , Convert.ToDecimal(summary.keikakuBatchSuHasu), Convert.ToDecimal(summary.keikakuBairitsu), Convert.ToDecimal(summary.keikakuBairitsuHasu)
                                    //        , null, null, null, null, null, null
                                    //        , ActionConst.CalcDefaultNumber, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumber
                                    //        , ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort
                                    //        , ActionConst.CalcDefaultNumberShort, summary.shikakariLotNo, ActionConst.CalcDefaultNumberShort); 
                                    //}
                                }
                            }

                            // contextが保持しているtr_keikaku_shikakariをDBの最新情報でリフレッシュする。
                            context.Refresh(RefreshMode.StoreWins, context.tr_keikaku_shikakari);

                            ShikakariSummarySakuseiModels summaryModel = new ShikakariSummarySakuseiModels();

                            Dictionary<string, string> shikakariLotNoDic = new Dictionary<string, string>();

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

                                ////BairitsuObject bObj = null;
                                ////// 配合名マスタの情報を取得する。必ず1件
                                //////string recipeHaigoCode = summary.recipeHaigoCode;
                                ////string recipeHaigoCode = summary.recipeHinmeiCode;
                                ////IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                                ////    context.usp_RecipeTenkai_ma_haigo_mei_select(recipeHaigoCode, summary.seizoDate, ActionConst.FlagFalse);
                                ////foreach (var val in views)
                                ////{
                                ////    bObj = FoodProcsCalculator.makeBairitsuObject(summary, (Decimal)val.wt_haigo_gokei, (Decimal)val.ritsu_kihon);
                                ////}

                                //// 仕掛計画サマリデータ削除（update/insertと迷ったけど他の画面と処理を合わせる）
                                ////context.usp_ShikakarihinKeikaku_SummaryLot_delete(line.no_lot_shikakari);
                                //context.usp_ShikakarihinKeikaku_SummaryLot_delete(summary.shikakariLotNo);

                                //// 配合名マスタの情報を取得する。必ず1件
                                //IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                                //    //context.usp_RecipeTenkai_ma_haigo_mei_select(summary.recipeHaigoCode, summary.seizoDate, Convert.ToInt16(Resources.FlagFalse));
                                //    context.usp_RecipeTenkai_ma_haigo_mei_select(summary.recipeHinmeiCode, summary.seizoDate, Convert.ToInt16(Resources.FlagFalse));
                                //foreach (var val in views)
                                //{
                                //    FoodProcsCalculator.calcSummaryData(summary, val);
                                //}

                                //// 登録処理
                                //context.usp_SeihinKeikaku_Summary_update(summary.seizoDate, summary.recipeHinmeiCode, summary.shokubaCode, summary.lineCode
                                //    , Convert.ToDecimal(summary.hitsuyoJuryo), Convert.ToDecimal(summary.keikakuShikomiJuryo), null, null, null, null
                                //    , Convert.ToDecimal(summary.keikakuHaigoJuryo), Convert.ToDecimal(summary.keikakuHaigoJuryoHasu), Convert.ToDecimal(summary.keikakuBatchSu)
                                //    , Convert.ToDecimal(summary.keikakuBatchSuHasu), Convert.ToDecimal(summary.keikakuBairitsu), Convert.ToDecimal(summary.keikakuBairitsuHasu)
                                //    , null, null, null, null, null, null
                                //    , ActionConst.CalcDefaultNumber, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumber
                                //    , ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort, ActionConst.CalcDefaultNumberShort
                                //    , ActionConst.CalcDefaultNumberShort, summary.shikakariLotNo, ActionConst.CalcDefaultNumberShort);

                                if (!shikakariLotNoDic.ContainsKey(summary.shikakariLotNo))
                                {
                                    shikakariLotNoDic.Add(summary.shikakariLotNo, summary.shikakariLotNo);

                                    // 仕掛品サマリ更新処理を実行する。
                                    summaryModel.updateSummary(context, summary.shikakariLotNo);

                                    // 使用予実再作成用の仕掛品ロット番号辞書に設定する。
                                    if (!shiyoShikakariDic.ContainsKey(summary.shikakariLotNo))
                                    {
                                        shiyoShikakariDic.Add(summary.shikakariLotNo, summary.shikakariLotNo);
                                    }
                                }
                            }

                        }

                        // コンテキストが保持する仕掛品サマリをDBと同期する。
                        context.Refresh(RefreshMode.StoreWins, context.su_keikaku_shikakari);

                        // 共通計画作成モデルクラスのインスタンスを生成する。
                        CommonKeikakuSakuseiModels keikakuModel = new CommonKeikakuSakuseiModels();

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

        /// <summary>
        /// 計画削除処理
        /// 対象の行情報と紐付く仕掛品トラン、使用予実トランを削除、仕掛品サマリを更新する。
        /// </summary>
        /// <param name="line">行情報（仕掛品計画情報）</param>
        /// <param name="context">コンテキスト</param>
        private void DeleteKeikaku(GekkanShikakarihinKeikakuCriteria line, FoodProcsEntities context)
        {

            // 削除対象のデータを取得
            IEnumerable<usp_ShikakarihinKeikakuDelete_select_Result> targetData;
            targetData = context.usp_ShikakarihinKeikakuDelete_select(line.no_lot_shikakari, line.data_key);

            foreach (var data in targetData)
            {
                // 仕掛品計画トラン・仕掛品計画サマリ・使用予実トランの削除
                // 仕掛品計画サマリは、厳密には更新(対象分、計画仕込重量を引く)、更新の結果計画仕込重量が0になった場合はレコード削除する。
                IEnumerable<usp_ShikakarihinKeikaku_delete_Result> returnWtShikomi;
                returnWtShikomi = context.usp_ShikakarihinKeikaku_delete(
                    data.no_lot_shikakari, data.cd_shikakari_hin, data.cd_shokuba, data.cd_line, data.dt_seizo
                    , data.wt_shikomi_keikaku, data.data_key);

                // 更新後の仕掛品計画サマリの計画仕込重量を取得する。必ず1件
                foreach (var wtShikomi in returnWtShikomi)
                {
                    // 計画仕込重量が存在する(0以上)場合、倍率データの再計算と再設定を行う
                    if (wtShikomi.wt_shikomi_keikaku > 0)
                    {
                        BairitsuObject bObj = null;
                        RecipeTenkaiObject summary = new RecipeTenkaiObject();
                        // 更新後の仕掛品計画サマリの計画仕込重量を設定
                        summary.hitsuyoJuryo = (decimal)wtShikomi.wt_shikomi_keikaku;

                        // 配合名マスタの情報を取得する。必ず1件
                        IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> views =
                            context.usp_RecipeTenkai_ma_haigo_mei_select(data.cd_shikakari_hin, data.dt_seizo, ActionConst.FlagFalse);
                        foreach (var val in views)
                        {
                            // 倍率データの再計算
                            bObj = FoodProcsCalculator.makeBairitsuObject(summary, (Decimal)val.wt_haigo_gokei, (Decimal)val.ritsu_kihon);
                        }
                        // 計算しなおした倍率データを元に、仕掛品サマリを更新
                        context.usp_ShikakariKeikakuSummaryDelete_update(
                            data.dt_seizo, data.cd_shikakari_hin, data.cd_shokuba, data.cd_line, data.no_lot_shikakari,
                            bObj.keikakuHaigoJuryo, bObj.keikakuHaigoJuryoHasu, bObj.bairitsu, bObj.bairitsuHasu, bObj.batchSu, bObj.batchSuHasu);
                    }
                }

            }
        }

        /// <summary>
        /// 行情報コピー処理
        /// 行情報を新規インスタンスで生成します。各項目には引数の行情報の項目が設定されます。
        /// </summary>
        /// <param name="line"></param>
        /// <returns></returns>
        private GekkanShikakarihinKeikakuCriteria CopyLine(GekkanShikakarihinKeikakuCriteria line)
        {
            // コピー行情報のインスタンスを生成
            GekkanShikakarihinKeikakuCriteria copyLine = new GekkanShikakarihinKeikakuCriteria();

            #region 各項目設定
            // 仕掛品コード
            copyLine.cd_hinmei = line.cd_hinmei;
            // 検索用仕掛品コード
            copyLine.cd_hinmei_search = line.cd_hinmei_search;
            // ラインコード
            copyLine.cd_line = line.cd_line;
            // 職場コード
            copyLine.cd_shokuba = line.cd_shokuba;
            // データキー
            copyLine.data_key = line.data_key;
            // 検索用日付（開始日）
            copyLine.dt_hiduke_from = line.dt_hiduke_from;
            // 検索用日付（終了日）
            copyLine.dt_hiduke_to = line.dt_hiduke_to;
            // 製造日
            copyLine.dt_seizo = line.dt_seizo;
            // 仕込合算フラグ
            copyLine.flg_gassan_shikomi = line.flg_gassan_shikomi;
            // 未使用フラグ
            copyLine.flg_mishiyo = line.flg_mishiyo;
            // Excelフラグ
            copyLine.isExcel = line.isExcel;
            // ライン名称
            copyLine.nm_line = line.nm_line;
            // 職場名称
            copyLine.nm_shokuba = line.nm_shokuba;
            // 検索用ロット番号
            copyLine.no_lot_search = line.no_lot_search;
            // 製品ロット番号
            copyLine.no_lot_seihin = line.no_lot_seihin;
            // 仕掛品ロット番号
            copyLine.no_lot_shikakari = line.no_lot_shikakari;
            // 親仕掛品ロット番号
            copyLine.no_lot_shikakari_oya = line.no_lot_shikakari_oya;
            // 基本倍率
            copyLine.ritsu_kihon = line.ritsu_kihon;
            // 検索用選択ロット種別
            copyLine.select_lot_search = line.select_lot_search;
            // 検索用スキップ数
            copyLine.skip = line.skip;
            // 検索用トップ
            copyLine.top = line.top;
            // 合計配合量
            copyLine.wt_haigo_gokei = line.wt_haigo_gokei;
            // 必要量
            copyLine.wt_hitsuyo = line.wt_hitsuyo;
            // 計画仕込量
            copyLine.wt_shikomi_keikaku = line.wt_shikomi_keikaku;
            #endregion

            // 結果を返却する。
            return copyLine;
        }
    }
}