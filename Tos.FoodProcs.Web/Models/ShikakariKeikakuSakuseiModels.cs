using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Controllers;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Models
{
    /// <summary>
    /// 仕掛品計画作成モデルクラス
    /// 仕掛品計画トランの登録・更新・削除時に使用します。
    /// <todo>
    /// 現状では、EntityFrameworkを使用して更新を行っていますが、
    /// 排他制御などで競合が多発する場合は、一括でストアドに置き換えてください。
    /// 処理の分割やクラス設計のベースとなるように作成しました。
    /// </todo>
    /// <history>
    ///     2016.11.22 BRC趙 新規作成
    /// </history>
    /// </summary>
    public class ShikakariKeikakuSakuseiModels
    {
        // 共通の計画作成モデルクラス
        private CommonKeikakuSakuseiModels keikakuSakusei = null;

        #region デフォルトコンストラクタ
        /// <summary>
        /// デフォルトコンストラクタ
        /// </summary>
        public ShikakariKeikakuSakuseiModels()
        {
            // 共通の計画作成モデルのインスタンス生成
            keikakuSakusei = new CommonKeikakuSakuseiModels();
        }
        #endregion

        #region 仕掛品計画トラン取得処理（製品計画ベース）
        /// <summary>
        /// 仕掛品取得処理
        /// 製品計画から仕掛品計画トランを作成します。
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="seihinKeikaku">製品計画トラン</param>
        /// <param name="gassanKeyDic">合算キー辞書</param>
        /// <returns></returns>
        public tr_keikaku_shikakari getShikakariKeikaku(FoodProcsEntities context, tr_keikaku_seihin seihinKeikaku
            , Dictionary<ShikakariGassanKey, string> gassanKeyDic)
        {
            /**
             * ローカル変数定義
             */
            // 仕掛品計画トラン
            tr_keikaku_shikakari shikakariKeikaku = null;
            // 製品マスタ（品名マスタ）
            ma_hinmei seihinMaster = null;
            // 配合名マスタ
            ma_haigo_mei haigoMaster = null;
            // 製造可能ラインマスタ
            ma_seizo_line seizoLineMaster = null;
            // ラインマスタ
            ma_line lineMaster = null;
            // 仕掛品ロット番号
            string no_lot_shikakari = null;
            // データキー
            string data_key = null;
            // 必要量
            decimal wt_hitsuyo = 0m;
            // 計画仕込量
            decimal wt_shikomi_keikaku = 0m;

            // 製品情報を取得
            seihinMaster = (from ma in context.ma_hinmei
                                where ma.cd_hinmei == seihinKeikaku.cd_hinmei
                                  && ma.flg_mishiyo == ActionConst.FlagFalse
                                  && ma.flg_testitem == ActionConst.FlagFalse
                                select ma).Single();

            // 配合名マスタ取得
            haigoMaster = keikakuSakusei.getHaigoMaster(context, seihinMaster.cd_haigo, seihinKeikaku.dt_seizo);

            // 製造可能ラインマスタ取得（ラインコード取得用）
            seizoLineMaster = keikakuSakusei.getSeizoLine(context, haigoMaster.cd_haigo);

            if (seizoLineMaster == null || string.IsNullOrEmpty(seizoLineMaster.cd_line))
            {
                // 仕掛品のラインコードが存在しなかった場合、エラーとする
                DateTime dtSeizo = (DateTime)seihinKeikaku.dt_seizo;
                dtSeizo = dtSeizo.AddHours(9);
                string errorMsg = String.Format(
                    Resources.MS0707, dtSeizo.ToString(ActionConst.DateFormat), seihinKeikaku.cd_hinmei);
                //throw new Exception(errorMsg);
                InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                ioe.Data.Add("key", "MS0707");
                throw ioe;
            }

            // ラインマスタ取得
            lineMaster = keikakuSakusei.getLineMaster(context, seizoLineMaster.cd_line);

            if (lineMaster == null || string.IsNullOrEmpty(lineMaster.cd_shokuba))
            {
                // 仕掛品の職場コードが存在しなかった場合、エラーとする
                DateTime dtSeizo = (DateTime)seihinKeikaku.dt_seizo;
                dtSeizo = dtSeizo.AddHours(9);
                string errorMsg = String.Format(
                    Resources.MS0707, dtSeizo.ToString(ActionConst.DateFormat), seihinKeikaku.cd_hinmei);
                //throw new Exception(errorMsg);
                InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                ioe.Data.Add("key", "MS0707");
                throw ioe;
            }

            // 仕掛品ロット番号取得
            no_lot_shikakari = this.getNoLotShikakari(context, gassanKeyDic, haigoMaster.flg_gassan_shikomi, haigoMaster.cd_haigo
                , seihinKeikaku.dt_seizo, lineMaster.cd_shokuba, seizoLineMaster.cd_line);

            // データキーを取得
            data_key = FoodProcsCommonUtility.executionSaiban(
                                        ActionConst.ShikakarihinKeikakuSaibanKbn
                                        , ActionConst.ShikakarihinKeikakuPrefixSaibanKbn
                                        , context);

            // 必要量を取得
            wt_hitsuyo = this.getHitsuyoJuryo(seihinKeikaku.su_seizo_yotei, seihinMaster.su_iri, seihinMaster.wt_ko
                , seihinMaster.ritsu_budomari, seihinMaster.kbn_kanzan, haigoMaster.kbn_kanzan);

            // 計画仕込量を取得
            wt_shikomi_keikaku = this.getHaigoJuryo(wt_hitsuyo, haigoMaster.ritsu_budomari);

            // 仕掛品計画トラン作成
            shikakariKeikaku = new tr_keikaku_shikakari();
            // データキー
            shikakariKeikaku.data_key = data_key;
            // 製造日
            shikakariKeikaku.dt_seizo = seihinKeikaku.dt_seizo;
            // 必要日
            shikakariKeikaku.dt_hitsuyo = seihinKeikaku.dt_seizo;
            // 製品ロット番号
            shikakariKeikaku.no_lot_seihin = seihinKeikaku.no_lot_seihin;
            // 仕掛品ロット番号
            shikakariKeikaku.no_lot_shikakari = no_lot_shikakari;
            // 親仕掛品ロット番号
            shikakariKeikaku.no_lot_shikakari_oya = string.Empty;
            // 職場コード
            shikakariKeikaku.cd_shokuba = lineMaster.cd_shokuba;
            // ラインコード
            shikakariKeikaku.cd_line = seizoLineMaster.cd_line;
            // 仕掛品コード
            shikakariKeikaku.cd_shikakari_hin = haigoMaster.cd_haigo;
            // 計画仕込量
            shikakariKeikaku.wt_shikomi_keikaku = wt_shikomi_keikaku;
            // 実績仕込量
            shikakariKeikaku.wt_shikomi_jisseki = 0;
            // 階層
            shikakariKeikaku.su_kaiso_shikomi = 1;
            // 更新日時
            shikakariKeikaku.dt_update = System.DateTime.Now;
            // 計画配合量
            shikakariKeikaku.wt_haigo_keikaku = null;
            // 実績配合量
            shikakariKeikaku.wt_haigo_jisseki = null;
            // 計画バッチ数
            shikakariKeikaku.su_batch_yotei = null;
            // 実績バッチ数
            shikakariKeikaku.su_batch_jisseki = 0;
            // 倍率
            shikakariKeikaku.ritsu_bai = 0;
            // 製品コード
            shikakariKeikaku.cd_hinmei = seihinKeikaku.cd_hinmei;
            // 必要量
            shikakariKeikaku.wt_hitsuyo = wt_hitsuyo;
            // 親データキー
            shikakariKeikaku.data_key_oya = null;

            // 仕掛品計画トランを返却
            return shikakariKeikaku;
        }
        #endregion

        #region 仕掛品リスト取得処理（レシピ展開）
        /// <summary>
        /// 仕掛品リスト取得処理
        /// 配合レシピの子配合のレシピを取得します。
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="shikakariList">仕掛品計画一覧</param>
        /// <param name="oyaShikakari">親仕掛品トラン</param>
        /// <param name="gassanKeyDic">合算キー辞書</param>
        public void getKeikakuShikakariList(FoodProcsEntities context, List<tr_keikaku_shikakari> shikakariList, tr_keikaku_shikakari oyaShikakari
            , Dictionary<ShikakariGassanKey, string> gassanKeyDic)
        {
            /**
             * ローカル変数定義
             */
            // 配合名マスタ
            ma_haigo_mei haigoMaster = null;
            // 子配合リスト
            IEnumerable<ma_haigo_recipe> recipeList = null;

            // 最新の配合マスタを取得
            haigoMaster = keikakuSakusei.getHaigoMaster(context, oyaShikakari.cd_shikakari_hin, oyaShikakari.dt_seizo);

            // 子配合リストを取得
            recipeList = (from ma in context.ma_haigo_recipe
                            where ma.cd_haigo == haigoMaster.cd_haigo
                            && ma.no_han == haigoMaster.no_han
                            && ma.kbn_hin == ActionConst.ShikakariHinKbn
                            select ma).AsEnumerable();

            // 取得したレシピ分展開する。
            foreach (ma_haigo_recipe recipe in recipeList)
            {
                // 仕掛品計画トランを取得
                tr_keikaku_shikakari shikakari = this.getShikakariKeikaku(context, oyaShikakari, gassanKeyDic, recipe, haigoMaster);

                // 仕掛計画リストに追加
                shikakariList.Add(shikakari);

                // 10階層未満の場合は配下の仕掛品を見に行く
                if (shikakari.su_kaiso_shikomi < 10)
                {
                    // レシピ展開を実施
                    this.getKeikakuShikakariList(context, shikakariList, shikakari, gassanKeyDic);
                }
            }

        }
        #endregion

        #region 仕掛品計画トラン取得処理（親仕掛品ベース）
        /// <summary>
        /// 仕掛品作成処理
        /// 親仕掛品トランとレシピ情報から子の仕掛計画トランを取得します。
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="oyaShikakari">親仕掛品トラン</param>
        /// <param name="gassanKeyDic">合算キー辞書</param>
        /// <param name="recipe">レシピ情報</param>
        /// <param name="oyaHaigo">親の配合マスタ情報</param>
        /// <returns></returns>
        public tr_keikaku_shikakari getShikakariKeikaku(FoodProcsEntities context, tr_keikaku_shikakari oyaShikakari,
            Dictionary<ShikakariGassanKey, string> gassanKeyDic, ma_haigo_recipe recipe, ma_haigo_mei oyaHaigo)
        {
            /**
             * ローカル変数定義
             */
            // 返却用仕掛品トラン
            tr_keikaku_shikakari shikakari = null;
            // 配合名マスタ
            ma_haigo_mei koHaigo = null;
            // データキー
            string data_key = null;
            // 仕掛品ロット番号
            string no_lot_shikakari = null;
            // 必要量
            decimal wt_hitsuyo = 0m;
            // 計画仕込量
            decimal wt_shikomi_keikaku = 0m;


            // 配合名マスタを取得する。
            koHaigo = keikakuSakusei.getHaigoMaster(context, recipe.cd_hinmei, oyaShikakari.dt_seizo);

            // データキーを採番
            data_key = FoodProcsCommonUtility.executionSaiban(
                                    ActionConst.ShikakarihinKeikakuSaibanKbn
                                    , ActionConst.ShikakarihinKeikakuPrefixSaibanKbn
                                    , context);

            // 必要量を取得します。
            wt_hitsuyo = this.getHitsuyoJuryo(
                oyaShikakari.wt_shikomi_keikaku
                , recipe.wt_shikomi
                , oyaHaigo.wt_haigo_gokei
                , recipe.ritsu_hiju
                , oyaHaigo.kbn_kanzan
                , koHaigo.kbn_kanzan);

            // 計画仕込量を取得します。
            wt_shikomi_keikaku = this.getHaigoJuryo(wt_hitsuyo, recipe.ritsu_budomari);

            // 仕掛品ロット番号を取得する。
            no_lot_shikakari = this.getNoLotShikakari(
                context
                , gassanKeyDic
                , koHaigo.flg_gassan_shikomi
                , koHaigo.cd_haigo
                , oyaShikakari.dt_seizo
                , oyaShikakari.cd_shokuba
                , oyaShikakari.cd_line);

            // 仕掛品計画トラン作成
            shikakari = new tr_keikaku_shikakari();
            // データキー
            shikakari.data_key = data_key;
            // 製造日
            shikakari.dt_seizo = oyaShikakari.dt_seizo;
            // 必要日
            shikakari.dt_hitsuyo = oyaShikakari.dt_hitsuyo;
            // 製品ロット番号
            shikakari.no_lot_seihin = oyaShikakari.no_lot_seihin;
            // 仕掛品ロット番号
            shikakari.no_lot_shikakari = no_lot_shikakari;
            // 親仕掛品ロット番号
            shikakari.no_lot_shikakari_oya = oyaShikakari.no_lot_shikakari;
            // 職場コード
            shikakari.cd_shokuba = oyaShikakari.cd_shokuba;
            // ラインコード
            shikakari.cd_line = oyaShikakari.cd_line;
            // 仕掛品コード
            shikakari.cd_shikakari_hin = koHaigo.cd_haigo;
            // 計画仕込量
            shikakari.wt_shikomi_keikaku = wt_shikomi_keikaku;
            // 実績仕込量
            shikakari.wt_shikomi_jisseki = 0;
            // 階層（親の階層に＋１する）
            shikakari.su_kaiso_shikomi = oyaShikakari.su_kaiso_shikomi + 1;
            // 更新日時
            shikakari.dt_update = System.DateTime.Now;
            // 計画配合重量（使用していないカラム）
            shikakari.wt_haigo_keikaku = null;
            // 実績配合重量（使用していないカラム）
            shikakari.wt_haigo_jisseki = null;
            // 計画バッチ数（使用していないカラム）
            shikakari.su_batch_yotei = null;
            // 実績バッチ数
            shikakari.su_batch_jisseki = 0;
            // 倍率（使用していないカラム）
            shikakari.ritsu_bai = 0;
            // 製品コード
            shikakari.cd_hinmei = oyaShikakari.cd_hinmei;
            // 必要量
            shikakari.wt_hitsuyo = wt_hitsuyo;
            // 親データキー
            shikakari.data_key_oya = oyaShikakari.data_key;

            // 作成した仕掛品計画トランを返却する。
            return shikakari;
        }
        #endregion

        #region 必要量取得処理（製品計画ベース）
        /// <summary>
        /// 必要量取得処理（製品に使用する仕掛品の必要量）
        /// 製造数と品名マスタ、配合マスタから必要量を取得します。
        /// </summary>
        /// <param name="su_seizo">[画面項目]製造数</param>
        /// <param name="su_iri">[品名マスタ]入数</param>
        /// <param name="wt_ko">[品名マスタ]個重量</param>
        /// <param name="ritsu_hiju">[品名マスタ]比重</param>
        /// <param name="kbn_kanzan_hin">[品名マスタ]換算区分</param>
        /// <param name="kbn_kanzan_haigo">[配合マスタ]換算区分</param>
        /// <returns>必要量</returns>
        public decimal getHitsuyoJuryo(decimal su_seizo, decimal? su_iri, decimal? wt_ko, decimal? ritsu_hiju
            , string kbn_kanzan_hin, string kbn_kanzan_haigo)
        {
            /**
             * ローカル変数定義
             */
            // 必要量
            decimal wt_hitsuyo = 0m;
            // 入数
            decimal iriSu = 0m;
            // 個重量
            decimal koJuryo = 0m;
            // 比重
            decimal hiju = 1m;

            if (su_iri != null)
            {
                iriSu = (decimal)su_iri;
            }

            if (wt_ko != null)
            {
                koJuryo = (decimal)wt_ko;
            }

            if (ritsu_hiju != null)
            {
                hiju = (decimal)ritsu_hiju;
            }

            if (kbn_kanzan_hin == kbn_kanzan_haigo)
            {
                hiju = 1m;
            }

            // 必要量＝[画面項目]製造数×[品名マスタ]入数×[品名マスタ]個重量÷[配合マスタ]比重
            wt_hitsuyo = su_seizo * iriSu * koJuryo / hiju;

            return wt_hitsuyo;
        }
        #endregion

        #region 必要量取得処理（親仕掛品ベース）
        /// <summary>
        /// 必要量取得処理（子仕掛品の必要量）
        /// 基本重量から必要量を取得します。
        /// </summary>
        /// <param name="wt_juryo">基本重量（親の仕込量）</param>
        /// <param name="wt_haigo">レシピ内の対象の仕掛品の配合量</param>
        /// <param name="wt_haigo_gokei">レシピの合計配合量</param>
        /// <returns></returns>
        public decimal getHitsuyoJuryo(decimal? wt_juryo, decimal? wt_haigo, decimal? wt_haigo_gokei, decimal? ritsu_hiju,
            string kbn_kanzan_oya, string kbn_kanzan_ko)
        {
            /**
             * ローカル変数定義
             */
            // 必要量
            decimal wt_hitsuyo = 0m;
            // 基本重量
            decimal juryo = 0m;
            // 配合重量
            decimal haigoJuryo = 0m;
            // 合計配合量
            decimal gokeiJuryo = 0m;
            // 比重
            decimal hiju = 1m;

            if (wt_juryo != null)
            {
                juryo = (decimal)wt_juryo;
            }

            if (wt_haigo != null)
            {
                haigoJuryo = (decimal)wt_haigo;
            }

            if (ritsu_hiju != null && ritsu_hiju != 0m)
            {
                hiju = (decimal)ritsu_hiju;
            }

            if (kbn_kanzan_oya == kbn_kanzan_ko)
            {
                hiju = 1m;
            }

            if (wt_haigo_gokei != null)
            {
                gokeiJuryo = (decimal)wt_haigo_gokei;
                // 必要量＝基本重量×（配合重量×合計配合重量）
                wt_hitsuyo = juryo * (haigoJuryo / gokeiJuryo) / hiju;
                // 必要量の小数第4位を切り上げ
                wt_hitsuyo = Math.Ceiling(wt_hitsuyo * 1000m) / 1000m;
            }

            // 結果を返却
            return wt_hitsuyo;
        }
        #endregion

        #region 配合重量取得処理
        /// <summary>
        /// 配合重量取得処理
        /// 必要量と歩留率から計画配合量を取得します。
        /// </summary>
        /// <param name="wt_hitsuyo"></param>
        /// <param name="ritsu_budomari"></param>
        /// <returns></returns>
        public decimal getHaigoJuryo(decimal? wt_hitsuyo, decimal? ritsu_budomari)
        {
            /**
             * ローカル変数定義
             */
            // 配合重量
            decimal wt_haigo = 0m;
            // 必要重量
            decimal hitsuyoJuryo = 0m;
            // 歩留率
            decimal budomari = 100m;

            if (wt_hitsuyo != null)
            {
                hitsuyoJuryo = (decimal)wt_hitsuyo;
            }

            if (ritsu_budomari != null && ritsu_budomari != 0m)
            {
                budomari = (decimal)ritsu_budomari;
            }

            // 配合重量を算出
            wt_haigo = hitsuyoJuryo * (ActionConst.persentKanzan / budomari);
            // 配合重量の小数第4位を切り上げ
            wt_haigo = Math.Ceiling(wt_haigo * 1000m) / 1000m;

            return wt_haigo;
        }
        #endregion

        #region 仕掛品ロット番号取得処理
        /// <summary>
        /// 仕掛品ロット番号取得処理
        /// 合算フラグや既存仕掛品トランなどを元に適切な仕掛品ロット番号を取得します。
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="gassanKeyDic">合算キー辞書</param>
        /// <param name="flg_gassan">合算フラグ</param>
        /// <param name="cd_shikakari_hin">仕掛品コード</param>
        /// <param name="dt_seizo">製造日</param>
        /// <param name="cd_shokuba">職場コード</param>
        /// <param name="cd_line">ラインコード</param>
        /// <returns></returns>
        public string getNoLotShikakari(FoodProcsEntities context, Dictionary<ShikakariGassanKey, string> gassanKeyDic, short flg_gassan, string cd_shikakari_hin,
            DateTime dt_seizo, string cd_shokuba, string cd_line)
        {
            // 仕掛品ロット番号
            string no_lot_shikakari = null;
            // 仕掛品サマリ一覧
            List<su_keikaku_shikakari> summaryList = null;
            // 新規合算キー
            ShikakariGassanKey newGassanKey = null;

            // 合算フラグがOFFのとき
            if (flg_gassan == ActionConst.FlagFalse)
            {
                // 新規で採番する。
                no_lot_shikakari = FoodProcsCommonUtility.executionSaiban(
                                ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
            }
            // 合算キーがONのとき
            else
            {
                // 既存の確定していない仕掛品計画を取得する。
                summaryList = (from tr in context.su_keikaku_shikakari
                                where tr.dt_seizo == dt_seizo
                                    && tr.cd_shikakari_hin == cd_shikakari_hin
                                    && tr.cd_shokuba == cd_shokuba
                                    && tr.cd_line == cd_line
                                    && tr.flg_jisseki == ActionConst.FlagFalse
                                    && tr.flg_shikomi == ActionConst.FlagFalse
                                select tr).ToList();

                // 既存の仕掛品トランに仕掛品が取得できなかった場合
                if (summaryList == null || summaryList.Count == 0)
                {
                    // 合算キーを取得する。
                    newGassanKey = this.getGassanKey(gassanKeyDic, dt_seizo, cd_shikakari_hin, cd_shokuba, cd_line);

                    // 今回登録分で既に同じ仕掛品を登録している場合は辞書にあるので使用する。
                    if (gassanKeyDic.ContainsKey(newGassanKey))
                    {
                        // 合算キー辞書から仕掛品ロット番号を取得する。
                        gassanKeyDic.TryGetValue(newGassanKey, out no_lot_shikakari);
                    }
                    // 辞書にない場合は新規採番する。
                    else
                    {
                        // 新規で採番する。
                        no_lot_shikakari = FoodProcsCommonUtility.executionSaiban(
                                        ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);

                        // 合算キーを設定する。
                        gassanKeyDic.Add(newGassanKey, no_lot_shikakari);
                    }
                }
                // 既存データが2件以上取得できた場合
                else if (summaryList.Count > 1)
                {
                    // 無条件で新規で採番する。
                    no_lot_shikakari = FoodProcsCommonUtility.executionSaiban(
                                    ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
                }
                // 既存データが1件だけ取得できる場合
                else
                {
                    // 取得した仕掛品ロット番号を使用する。
                    no_lot_shikakari = summaryList.FirstOrDefault().no_lot_shikakari;
                }
            }

            // 取得した仕掛品ロット番号を返す。
            return no_lot_shikakari;
        }
        #endregion

        #region 合算キー取得処理
        /// <summary>
        /// 合算キー取得処理
        /// 合算キー辞書に重複データが存在すれば、シーケンス番号を繰り上げて新規の合算キーを作成します。
        /// </summary>
        /// <param name="gassanKeyDic">合算キー辞書</param>
        /// <param name="dt_seizo">製造日</param>
        /// <param name="cd_shikakari_hin">仕掛品コード</param>
        /// <param name="cd_shokuba">職場コード</param>
        /// <param name="cd_line">ラインコード</param>
        /// <returns></returns>
        public ShikakariGassanKey getGassanKey(Dictionary<ShikakariGassanKey, string> gassanKeyDic, DateTime dt_seizo, string cd_shikakari_hin,
            string cd_shokuba, string cd_line)
        {
            // 合算キーの重複回避用
            //int no_seq = 0;

            //// 合算キーが重複しているか見ていく。
            //foreach (ShikakariGassanKey gassanKey in gassanKeyDic.Keys)
            //{
            //    if (gassanKey.seizoDate == dt_seizo
            //        && gassanKey.recipeHaigoCode == cd_shikakari_hin
            //        && gassanKey.shokubaCode == cd_shokuba
            //        && gassanKey.lineCode == cd_line)
            //    {
            //        no_seq = no_seq + 1;
            //    }
            //}

            ShikakariGassanKey newGassanKey = new ShikakariGassanKey(cd_shokuba, cd_line, cd_shikakari_hin, dt_seizo);

            return newGassanKey;
        }
        #endregion
    }
}