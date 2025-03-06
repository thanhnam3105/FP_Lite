using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Controllers;

namespace Tos.FoodProcs.Web.Models
{
    /// <summary>
    /// 仕掛品サマリ作成モデルクラス
    /// 仕掛品サマリの登録・更新・削除時に使用します。
    /// <todo>
    /// 現状では、EntityFrameworkを使用して更新を行っていますが、
    /// 排他制御などで競合が多発する場合は、一括でストアドに置き換えてください。
    /// 処理の分割やクラス設計のベースとなるように作成しました。
    /// </todo>
    /// <history>
    ///     2016.11.22 BRC趙 新規作成
    /// </history>
    /// </summary>
    public class ShikakariSummarySakuseiModels
    {
        // 共通の計画作成モデルクラス
        private CommonKeikakuSakuseiModels keikakuSakusei = null;

        #region デフォルトコンストラクタ
        /// <summary>
        /// デフォルトコンストラクタ
        /// </summary>
        public ShikakariSummarySakuseiModels()
        {
            // 共通の計画作成モデルのインスタンス生成
            keikakuSakusei = new CommonKeikakuSakuseiModels();
        }
        #endregion

        #region 仕掛品サマリ再作成処理
        /// <summary>
        /// 仕掛品サマリ再作成処理
        /// 仕掛品ロット番号を元に仕掛品サマリと使用予実トランを作成します。
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="no_lot_shikakari">仕掛品ロット番号</param>
        public void updateSummary(FoodProcsEntities context, string no_lot_shikakari)
        {
            // 仕掛品サマリ削除処理を実行する。
            this.deleteSummay(context, no_lot_shikakari);

            // 仕掛品サマリ作成処理を実行する。
            this.createSummay(context, no_lot_shikakari);
        }
        #endregion

        #region 仕掛品サマリ作成処理
        /// <summary>
        /// 仕掛品サマリ作成処理
        /// </summary>
        /// <param name="context"></param>
        /// <param name="no_lot_shikakari"></param>
        public void createSummay(FoodProcsEntities context, string no_lot_shikakari)
        {
            /**
             * ローカル変数定義
             */
            // 仕掛品サマリ
            su_keikaku_shikakari summary = null;

            // 仕掛品サマリ情報を取得する。
            summary = this.getShikakariSummary(context, no_lot_shikakari);

            if (summary != null)
            {
                // 仕掛品サマリを追加処理を実行する。
                context.usp_SeihinKeikaku_Summary_update(
                    summary.dt_seizo
                    , summary.cd_shikakari_hin
                    , summary.cd_shokuba
                    , summary.cd_line
                    , summary.wt_hitsuyo
                    , summary.wt_shikomi_keikaku
                    , summary.wt_shikomi_jisseki
                    , summary.wt_zaiko_keikaku
                    , summary.wt_zaiko_jisseki
                    , summary.wt_shikomi_zan
                    , summary.wt_haigo_keikaku
                    , summary.wt_haigo_keikaku_hasu
                    , summary.su_batch_keikaku
                    , summary.su_batch_keikaku_hasu
                    , summary.ritsu_keikaku
                    , summary.ritsu_keikaku_hasu
                    , summary.wt_haigo_jisseki
                    , summary.wt_haigo_jisseki_hasu
                    , summary.su_batch_jisseki
                    , summary.su_batch_jisseki_hasu
                    , summary.ritsu_jisseki
                    , summary.ritsu_jisseki_hasu
                    , summary.su_label_sumi
                    , summary.flg_label
                    , summary.su_label_sumi_hasu
                    , summary.flg_label_hasu
                    , summary.flg_keikaku
                    , summary.flg_jisseki
                    , summary.flg_shusei
                    , summary.no_lot_shikakari
                    , summary.flg_shikomi
                    );
            }
        }
        #endregion

        #region 仕掛品サマリ削除処理
        /// <summary>
        /// 仕掛品サマリ削除処理
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="no_lot_shikakari">仕掛品ロット番号</param>
        public void deleteSummay(FoodProcsEntities context, string no_lot_shikakari)
        {
            // 仕掛品サマリを削除する。
            context.usp_SeihinKeikaku_SummaryLot_delete(no_lot_shikakari);
        }
        #endregion

        #region 仕掛品サマリ取得処理
        /// <summary>
        /// 仕掛品サマリ取得処理
        /// 仕掛品計画トランから仕掛品ロット番号をキーにサマリを作成する。
        /// </summary>
        /// <param name="context">コンテキスト</param>
        /// <param name="no_lot_shikakari">仕掛品ロット番号</param>
        /// <param name="haigoMasterDic">配合マスタ一覧</param>
        /// <returns></returns>
        public su_keikaku_shikakari getShikakariSummary(FoodProcsEntities context, string no_lot_shikakari)
        {
            /**
             * ローカル変数定義
             */
            // 返却用仕掛品サマリ
            su_keikaku_shikakari summary = null;
            // 倍率オブジェクト
            BairitsuObject baritshObj = null;
            // 配合マスタ
            ma_haigo_mei koHaigo = null;
            // 仕込量
            decimal wt_shikomi = 0;
            // 必要量
            decimal wt_hitsuyo = 0;

            // 仕掛品一覧取得
            List<tr_keikaku_shikakari> shikakariList = (from tr in context.tr_keikaku_shikakari
                                                        where tr.no_lot_shikakari == no_lot_shikakari
                                                        select tr).ToList();

            if (shikakariList != null && shikakariList.Count > 0)
            {

                foreach (tr_keikaku_shikakari shikakari in shikakariList)
                {
                    // 計画配合量を合算する。
                    if (shikakari.wt_shikomi_keikaku != null && shikakari.wt_shikomi_keikaku != 0)
                    {
                        wt_shikomi = wt_shikomi + (decimal)shikakari.wt_shikomi_keikaku;
                    }

                    // 必要量を合算する。
                    if (shikakari.wt_hitsuyo != null && shikakari.wt_hitsuyo != 0)
                    {
                        wt_hitsuyo = wt_hitsuyo + (decimal)shikakari.wt_hitsuyo;
                    }
                }

                // 最新版の配合名マスタを取得する。
                koHaigo = keikakuSakusei.getHaigoMaster(context, shikakariList[0].cd_shikakari_hin, shikakariList[0].dt_seizo);

                // 計画倍率・計画バッチ数を取得する。
                baritshObj = this.createBairitsuObject(wt_shikomi, koHaigo.wt_haigo_gokei, koHaigo.ritsu_kihon);

                // サマリのインスタンスを生成する。
                summary = new su_keikaku_shikakari();
                // 製造日
                summary.dt_seizo = shikakariList[0].dt_seizo;
                // 仕掛品コード
                summary.cd_shikakari_hin = shikakariList[0].cd_shikakari_hin;
                // 職場コード
                summary.cd_shokuba = shikakariList[0].cd_shokuba;
                // ラインコード
                summary.cd_line = shikakariList[0].cd_line;
                // 必要量
                summary.wt_hitsuyo = wt_hitsuyo;
                // 計画仕込重量
                summary.wt_shikomi_keikaku = baritshObj.keikakuShikomiJuryo;
                // 実績仕込重量
                summary.wt_shikomi_jisseki = null;
                // 計画在庫重量
                summary.wt_zaiko_keikaku = null;
                // 実績在庫重量
                summary.wt_zaiko_jisseki = null;
                // 前日残仕込重量
                summary.wt_shikomi_zan = null;
                // 計画配合量
                summary.wt_haigo_keikaku = 0;
                // 計画配合量（端数）
                summary.wt_haigo_keikaku_hasu = 0;
                // 計画バッチ数
                summary.su_batch_keikaku = baritshObj.batchSu;
                // 計画バッチ数（端数）
                summary.su_batch_keikaku_hasu = baritshObj.batchSuHasu;
                // 計画倍率
                summary.ritsu_keikaku = baritshObj.bairitsu;
                // 計画倍率（端数）
                summary.ritsu_keikaku_hasu = baritshObj.bairitsuHasu;
                // 実績配合量
                summary.wt_haigo_jisseki = null;
                // 実績配合量（端数）
                summary.wt_haigo_jisseki_hasu = null;
                // 実績バッチ数
                summary.su_batch_jisseki = null;
                // 実績バッチ数（端数）
                summary.su_batch_jisseki_hasu = null;
                // 実績倍率
                summary.ritsu_jisseki = null;
                // 実績倍率（端数）
                summary.ritsu_jisseki_hasu = null;
                // ラベル済み数
                summary.su_label_sumi = 0;
                // ラベルフラグ
                summary.flg_label = 0;
                // ラベル済み数（端数）
                summary.su_label_sumi_hasu = 0;
                // ラベルフラグ（端数）
                summary.flg_label_hasu = 0;
                // 計画フラグ
                summary.flg_keikaku = 0;
                // 仕込実績フラグ
                summary.flg_jisseki = 0;
                // 修正フラグ
                summary.flg_shusei = 0;
                // 仕掛品ロット番号
                summary.no_lot_shikakari = no_lot_shikakari;
                // 仕込計画確定フラグ
                summary.flg_shikomi = 0;

            }

            // 作成した仕掛品サマリを返却する。
            return summary;
        }
        #endregion

        #region 倍率オブジェクト生成処理
        /// <summary>
        /// 倍率オブジェクト生成処理
        /// 計画倍率・バッチ数、仕込量を算出します。
        /// </summary>
        /// <param name="wt_hitsuyo">必要量</param>
        /// <param name="wt_haigo_gokei">配合量合計</param>
        /// <param name="ritsu_kihon">基本倍率</param>
        /// <returns>倍率オブジェクト</returns>
        public BairitsuObject createBairitsuObject(decimal? wt_hitsuyo, decimal? wt_haigo_gokei, decimal? ritsu_kihon)
        {
            // 倍率オブジェクトのインスタンスを生成
            BairitsuObject obj = new BairitsuObject();
            // 計画仕込量
            decimal wt_shikomi_keikaku = 0;
            // 仕込量（正規）※計算途中で使用する。
            decimal wt_shikomi = 0;
            // 仕込量（端数）※計算途中で使用する。
            decimal wt_shikomi_hasu = 0;
            // 計画バッチ数
            decimal su_batch_keikaku = 0;
            // 計画バッチ数（端数）
            decimal su_batch_keikaku_hasu = 1;
            // 計画倍率
            decimal ritsu_keikaku = 0;
            // 計画倍率（端数）
            decimal ritsu_keikaku_hasu = 0;
            // 必要量
            decimal hitsuyoJuryo = 0;
            // 合計配合量
            decimal gokeiHaigoJuryo = 0;
            // 基本倍率
            decimal kihonBairistsu = 0;


            // 引数入力チェック
            if (wt_hitsuyo != null)
            {
                hitsuyoJuryo = (decimal)wt_hitsuyo;
            }

            if (wt_haigo_gokei != null)
            {
                gokeiHaigoJuryo = (decimal)wt_haigo_gokei;
            }

            if (ritsu_kihon != null)
            {
                kihonBairistsu = (decimal)ritsu_kihon;
            }

            // 計画バッチ数を取得
            su_batch_keikaku = Math.Floor(hitsuyoJuryo / (gokeiHaigoJuryo * kihonBairistsu));

            // 仕込量（正規）を算出
            wt_shikomi = Math.Ceiling((gokeiHaigoJuryo * kihonBairistsu * su_batch_keikaku) * 1000) / 1000;
            // 仕込量（端数）を算出
            wt_shikomi_hasu = Math.Ceiling((hitsuyoJuryo - wt_shikomi) * 1000) / 1000;

            // 計画倍率を設定
            ritsu_keikaku = kihonBairistsu;
            // 計画倍率（端数）を取得（倍率は2桁表示）
            ritsu_keikaku_hasu = Math.Ceiling((wt_shikomi_hasu / gokeiHaigoJuryo) * 100) / 100;

            // 端数倍率と正規倍率が一致した場合
            if (ritsu_keikaku_hasu == ritsu_keikaku)
            {
                // 端数バッチ数を正規バッチ数の上乗せ
                su_batch_keikaku = su_batch_keikaku + su_batch_keikaku_hasu;

                // 端数バッチ数に0を設定
                su_batch_keikaku_hasu = 0;

                // 端数倍率に0を設定
                ritsu_keikaku_hasu = 0;
            }

            // 正規バッチ数が0になる場合
            if (su_batch_keikaku == 0)
            {
                // 正規バッチ数に端数バッチ数の値を設定
                su_batch_keikaku = su_batch_keikaku_hasu;

                // 正規倍率に端数倍率を設定
                ritsu_keikaku = ritsu_keikaku_hasu;

                // 端数バッチ数を0に設定
                su_batch_keikaku_hasu = 0;

                // 端数倍率を0に設定
                ritsu_keikaku_hasu = 0;
            }


            // 計画仕込量を設定
            wt_shikomi_keikaku = gokeiHaigoJuryo * (su_batch_keikaku * ritsu_keikaku + su_batch_keikaku_hasu * ritsu_keikaku_hasu);
            // 小数第4位で切り上げ
            wt_shikomi_keikaku = Math.Ceiling(wt_shikomi_keikaku * 1000) / 1000;

            // 倍率オブジェクト生成
            // 正規倍率
            obj.bairitsu = ritsu_keikaku;
            // 端数倍率
            obj.bairitsuHasu = ritsu_keikaku_hasu;
            // 正規バッチ数
            obj.batchSu = su_batch_keikaku;
            // 端数バッチ数
            obj.batchSuHasu = su_batch_keikaku_hasu;
            // 計画配合重量
            obj.keikakuHaigoJuryo = wt_shikomi;
            // 計画配合重量（端数）
            obj.keikakuHaigoJuryoHasu = wt_shikomi_hasu;
            // 計画仕込量
            obj.keikakuShikomiJuryo = wt_shikomi_keikaku;

            // 作成した倍率オブジェクトを返却
            return obj;
        }
        #endregion
    }
}