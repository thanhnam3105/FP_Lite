using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Controllers;

namespace Tos.FoodProcs.Web.Models
{
    /// <summary>
    /// 共通で使用する計画作成のモデルクラス
    /// <todo>
    /// 現状では、EntityFrameworkを使用して更新を行っていますが、
    /// 排他制御などで競合が多発する場合は、一括でストアドに置き換えてください。
    /// 処理の分割やクラス設計のベースとなるように作成しました。
    /// </todo>
    /// <history>
    ///     2016.11.22 BRC趙 新規作成
    /// </history>
    /// </summary>
    public class CommonKeikakuSakuseiModels
    {
        #region デフォルトコンストラクタ
        /// <summary>
        /// デフォルトコンストラクタ
        /// </summary>
        public CommonKeikakuSakuseiModels()
        {
        }
        #endregion

        #region 使用予実トラン再作成処理
        /// <summary>
        /// 使用予実トラン再作成処理
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="no_lot_shikakari">仕掛品ロット番号</param>
        public void updateShiyoYojitsu(FoodProcsEntities context, string no_lot_shikakari, short flg_yojitsu)
        {
            // 使用予実トラン削除処理を実行
            this.deleteShiyoYojitsu(context, no_lot_shikakari, flg_yojitsu);

            // 使用予実トラン追加処理を実行
            this.createShiyoYojitsu(context, no_lot_shikakari, flg_yojitsu);
        }
        #endregion

        #region 使用予実トラン作成処理
        /// <summary>
        /// 使用予実トラン作成処理
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="no_lot_shikakari">仕掛品ロット番号</param>
        public void createShiyoYojitsu(FoodProcsEntities context, string no_lot_shikakari, short flg_yojitsu)
        {
            /**
             * ローカル変数定義
             */
            // 仕掛品サマリ
            su_keikaku_shikakari summary = null;
            // 使用予実一覧
            List<tr_shiyo_yojitsu> shiyoYojitsuList = null;

            // 仕掛品サマリ情報を取得する。
            summary = (from su in context.su_keikaku_shikakari
                        where su.no_lot_shikakari == no_lot_shikakari
                        select su).SingleOrDefault();

            if (summary != null)
            {
                // 使用予実一覧（予定）を取得する。
                shiyoYojitsuList = this.getShiyoYojitsuList(context, summary, flg_yojitsu);

                foreach (tr_shiyo_yojitsu shiyoYojitsu in shiyoYojitsuList)
                {
                    // 使用予実トランを追加
                    context.usp_ShiyoYojitsu_insert(
                        shiyoYojitsu.flg_yojitsu
                        , shiyoYojitsu.cd_hinmei
                        , shiyoYojitsu.dt_shiyo
                        , shiyoYojitsu.no_lot_seihin
                        , shiyoYojitsu.no_lot_shikakari
                        , shiyoYojitsu.su_shiyo
                        , ActionConst.ShiyoYojitsuSeqNoSaibanKbn
                        , ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn
                    );
                }
            }
        }
        #endregion

        #region 使用予実トラン削除処理
        /// <summary>
        /// 使用予実トラン削除処理
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="no_lot_shikakari">仕掛品ロット番号</param>
        public void deleteShiyoYojitsu(FoodProcsEntities context, string no_lot_shikakari, short flg_yojitsu)
        {
            // 使用予実削除処理を実行する。
            context.usp_ShiyoYojitsu_delete(flg_yojitsu, no_lot_shikakari);
        }
        #endregion

        #region 使用予実一覧作成処理
        /// <summary>
        /// 使用予実一覧作成処理
        /// 仕掛品サマリから使用されている原料・自家原料の一覧を取得します。
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="summary">仕掛品サマリ</param>
        /// <param name="flg_yojitsu">予実フラグ</param>
        /// <returns></returns>
        public List<tr_shiyo_yojitsu> getShiyoYojitsuList(FoodProcsEntities context, su_keikaku_shikakari summary, short flg_yojitsu)
        {
            /**
             * ローカル変数定義
             */
            // 使用予実一覧
            List<tr_shiyo_yojitsu> shiyoYojitsuList = null;
            // 配合名マスタ
            ma_haigo_mei haigo = null;
            // 配合レシピ
            IEnumerable<ma_haigo_recipe> recipeList = null;

            // 仕込量
            decimal wt_shikomi = 0m;

            // 仕込量の予定・実績を判定
            if (flg_yojitsu == ActionConst.YoteiYojitsuFlag && summary.wt_shikomi_keikaku != null)
            {
                wt_shikomi = (decimal)summary.wt_shikomi_keikaku;
            }
            else if (flg_yojitsu == ActionConst.JissekiYojitsuFlag && summary.wt_shikomi_jisseki != null)
            {
                wt_shikomi = (decimal)summary.wt_shikomi_jisseki;
            }

            // 配合名マスタを取得する。
            haigo = this.getHaigoMaster(context, summary.cd_shikakari_hin, summary.dt_seizo);

            // 配合レシピ（原料・自家原料）を取得
            recipeList = (from ma in context.ma_haigo_recipe
                            where ma.cd_haigo == haigo.cd_haigo
                            && ma.no_han == haigo.no_han
                            && (ma.kbn_hin == ActionConst.GenryoHinKbn || ma.kbn_hin == ActionConst.JikaGenryoHinKbn)
                            select ma).AsEnumerable();

            if (recipeList != null)
            {
                // 使用予実一覧のインスタンス生成
                shiyoYojitsuList = new List<tr_shiyo_yojitsu>();

                foreach (ma_haigo_recipe recipe in recipeList)
                {
                    // 使用予実トラン
                    tr_shiyo_yojitsu shiyoYojitsu = null;
                    // 使用数
                    decimal su_shiyo = 0;

                    // 使用数を取得する。
                    su_shiyo = this.getShiyoSu(wt_shikomi, recipe.wt_shikomi, haigo.wt_haigo_gokei, recipe.ritsu_budomari);


                    // 使用予実トランのインスタンスを生成
                    shiyoYojitsu = new tr_shiyo_yojitsu();

                    // 予実フラグ
                    shiyoYojitsu.flg_yojitsu = flg_yojitsu;
                    // 品名コード
                    shiyoYojitsu.cd_hinmei = recipe.cd_hinmei;
                    // 使用日
                    shiyoYojitsu.dt_shiyo = summary.dt_seizo;
                    // 製品ロット番号
                    shiyoYojitsu.no_lot_seihin = null;
                    // 仕掛品ロット番号
                    shiyoYojitsu.no_lot_shikakari = summary.no_lot_shikakari;
                    // 使用数
                    shiyoYojitsu.su_shiyo = su_shiyo;
                    // 仕掛品データキー
                    shiyoYojitsu.data_key_tr_shikakari = null;

                    // 作成した使用予実トランを一覧に追加
                    shiyoYojitsuList.Add(shiyoYojitsu);
                }
            }

            // 結果を返却する。
            return shiyoYojitsuList;
        }
        #endregion

        #region 使用数取得処理
        /// <summary>
        /// 使用数取得処理
        /// </summary>
        /// <param name="wt_shikomi_keikaku">サマリの計画仕込量</param>
        /// <param name="wt_shikomi_recipe">レシピ仕込量</param>
        /// <param name="wt_haigo_gokei">配合合計重量</param>
        /// <returns>使用数</returns>
        public decimal getShiyoSu(decimal? wt_shikomi_keikaku, decimal? wt_shikomi_recipe, decimal? wt_haigo_gokei, decimal? ritsu_budomari)
        {
            /**
             * ローカル変数定義
             */
            // 使用数
            decimal su_shiyo = 0m;
            // 計画仕込重量
            decimal keikakuShikomiJuryo = 0m;
            // レシピの仕込重量
            decimal recipeShikomiJuryo = 0m;
            // 配合重量合計
            decimal haigoGokeiJuryo = 0m;
            // 歩留率
            decimal budomari = 1m;

            if (wt_shikomi_keikaku != null)
            {
                keikakuShikomiJuryo = (decimal)wt_shikomi_keikaku;
            }

            if (wt_shikomi_recipe != null)
            {
                recipeShikomiJuryo = (decimal)wt_shikomi_recipe;
            }

            if (ritsu_budomari != null && ritsu_budomari != 0)
            {
                budomari = (decimal)ritsu_budomari;
            }

            if (wt_haigo_gokei != null && wt_haigo_gokei != 0)
            {
                // 合計配合重量を設定
                haigoGokeiJuryo = (decimal)wt_haigo_gokei;

                // 使用量算出
                su_shiyo = keikakuShikomiJuryo * (recipeShikomiJuryo / haigoGokeiJuryo) * (ActionConst.persentKanzan / budomari);

                // 使用量は小数第4位を切り上げ
                su_shiyo = Math.Ceiling(Math.Floor(su_shiyo * 10000m) / 10m) / 1000m;
            }

            // 使用数を返却
            return su_shiyo;
        }
        #endregion

        #region 配合名マスタ取得処理
        /// <summary>
        /// 配合名マスタ取得処理
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="cd_haigo">配合コード</param>
        /// <param name="date">基準日</param>
        /// <returns></returns>
        public ma_haigo_mei getHaigoMaster(FoodProcsEntities context, string cd_haigo, DateTime date)
        {
            // 配合マスタ
            ma_haigo_mei haigo = null;
            List<usp_YukoHaigoMeiCommon_select_Result> yukoHaigo = null;
            
            // レシピ内の配合マスタを取得する。
            //haigo = (from ma in context.ma_haigo_mei
                        //where ma.cd_haigo == cd_haigo
                        //&& ma.flg_mishiyo == ActionConst.FlagFalse
                        //&& ma.dt_from <= date
                        //select ma).OrderByDescending(ma => ma.no_han).Take(1).SingleOrDefault();

            yukoHaigo = context.usp_YukoHaigoMeiCommon_select(
                cd_haigo
                ,ActionConst.FlagFalse
                ,date).ToList();

            haigo = new ma_haigo_mei();

            haigo.cd_haigo = yukoHaigo[0].cd_haigo;
            haigo.nm_haigo_ja = yukoHaigo[0].nm_haigo_ja;
            haigo.nm_haigo_en = yukoHaigo[0].nm_haigo_en;
            haigo.nm_haigo_zh = yukoHaigo[0].nm_haigo_zh;
            haigo.nm_haigo_vi = yukoHaigo[0].nm_haigo_vi;
            haigo.nm_haigo_ryaku = yukoHaigo[0].nm_haigo_ryaku;
            haigo.ritsu_budomari = yukoHaigo[0].ritsu_budomari;
            haigo.wt_kihon = yukoHaigo[0].wt_kihon;
            haigo.ritsu_kihon = yukoHaigo[0].ritsu_kihon;
            haigo.flg_gassan_shikomi = yukoHaigo[0].flg_gassan_shikomi;
            haigo.wt_saidai_shikomi = yukoHaigo[0].wt_saidai_shikomi;
            haigo.no_han = yukoHaigo[0].no_han;
            haigo.wt_haigo = yukoHaigo[0].wt_haigo;
            haigo.wt_haigo_gokei = yukoHaigo[0].wt_haigo_gokei;
            haigo.biko = yukoHaigo[0].biko;
            haigo.no_seiho = yukoHaigo[0].cd_haigo;
            haigo.cd_tanto_seizo = yukoHaigo[0].cd_tanto_seizo;
            haigo.dt_seizo_koshin = yukoHaigo[0].dt_seizo_koshin;
            haigo.cd_tanto_hinkan = yukoHaigo[0].cd_tanto_hinkan;
            haigo.dt_hinkan_koshin = yukoHaigo[0].dt_hinkan_koshin;
            haigo.dt_from = yukoHaigo[0].dt_from;
            haigo.kbn_kanzan = yukoHaigo[0].kbn_kanzan;
            haigo.ritsu_hiju = yukoHaigo[0].ritsu_hiju;
            haigo.flg_shorihin = yukoHaigo[0].flg_shorihin;
            haigo.flg_tanto_hinkan = yukoHaigo[0].flg_tanto_hinkan;
            haigo.flg_tanto_seizo = yukoHaigo[0].flg_tanto_seizo;
            haigo.kbn_shiagari = yukoHaigo[0].kbn_shiagari;
            haigo.cd_bunrui = yukoHaigo[0].cd_bunrui;
            haigo.flg_mishiyo = yukoHaigo[0].flg_mishiyo;
            haigo.dt_create = yukoHaigo[0].dt_create;
            haigo.cd_create = yukoHaigo[0].cd_create;
            haigo.dt_update = yukoHaigo[0].dt_update;
            haigo.cd_update = yukoHaigo[0].cd_update;
            haigo.wt_kowake = yukoHaigo[0].wt_kowake;
            haigo.su_kowake = yukoHaigo[0].su_kowake;
            haigo.flg_tenkai = yukoHaigo[0].flg_tenkai;
            haigo.ts = yukoHaigo[0].ts;
            haigo.dd_shomi = yukoHaigo[0].dd_shomi;
            haigo.kbn_hokan = yukoHaigo[0].kbn_hokan;

            // 取得した配合マスタを返却する。
            return haigo;
        }
        #endregion

        #region 製造可能ラインマスタ取得処理
        /// <summary>
        /// 製造可能ラインマスタ取得処理
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="cd_haigo">配合コード</param>
        /// <returns>製造可能ラインマスタ</returns>
        public ma_seizo_line getSeizoLine(FoodProcsEntities context, string cd_haigo)
        {
            // 製造ラインマスタ
            ma_seizo_line seizoLineMaster = null;

            // 製造ラインマスタを取得する
            seizoLineMaster = (from ma in context.ma_seizo_line
                               where ma.cd_haigo == cd_haigo
                               && ma.kbn_master == ActionConst.HaigoMasterKbn
                               && ma.flg_mishiyo == ActionConst.FlagFalse
                               select ma).OrderBy(ma => ma.no_juni_yusen).Take(1).SingleOrDefault();

            // 取得した製造ラインマスタを返却
            return seizoLineMaster;
        }
        #endregion

        #region ラインマスタ取得処理
        /// <summary>
        /// ラインマスタ取得処理
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="cd_line">ラインコード</param>
        /// <returns>ラインマスタ</returns>
        public ma_line getLineMaster(FoodProcsEntities context, string cd_line)
        {
            // ラインマスタ
            ma_line lineMaster = null;

            // ラインマスタを取得する。
            lineMaster = (from ma in context.ma_line
                          where ma.cd_line == cd_line
                          select ma).SingleOrDefault();

            // 取得したラインマスタを返却
            return lineMaster;
        }
        #endregion
    }
}