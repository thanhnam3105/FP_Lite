using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 原価計算関連(原価単価作成画面、原価一覧画面)の情報を定義します。
    /// </summary>
    public class GenkaKeisanCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GenkaKeisanCriteria()
        {
        }

        /// <summary>
        /// 検索条件：年月(開始)
        /// </summary>
        public DateTime dt_from { get; set; }

        /// <summary>
        /// 検索条件：年月(終了)
        /// </summary>
        public DateTime dt_to { get; set; }

        /// <summary>
        /// 検索条件：品区分
        /// </summary>
        public string kbn_hin { get; set; }

        /// <summary>
        /// 検索条件：分類
        /// </summary>
        public string cd_bunrui { get; set; }

        /// <summary>
        /// 検索条件：品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 検索条件：原価単価の最大値
        /// </summary>
        public decimal max_genka { get; set; }

        /// <summary>
        /// 検索条件：職場コード
        /// </summary>
        public string cd_shokuba { get; set; }

        /// <summary>
        /// 検索条件：ラインコード
        /// </summary>
        public string cd_line { get; set; }

        /// <summary>
        /// 検索条件：単価設定
        /// </summary>
        public short tanka_settei { get; set; }

        /// <summary>
        /// 検索条件：マスタ単価使用
        /// </summary>
        public short master_tanka { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// UTC時間で変換済みシステム日付
        /// </summary>
        public DateTime today { get; set; }

        /// <summary>
        /// EXCEL用：年月
        /// </summary>
        public string nengetsu { get; set; }

        /// <summary>
        /// EXCEL用：職場
        /// </summary>
        public string shokubaName { get; set; }

        /// <summary>
        /// EXCEL用：ライン
        /// </summary>
        public string lineName { get; set; }

        /// <summary>
        /// EXCEL用：分類
        /// </summary>
        public string bunrui { get; set; }

        /// <summary>
        /// EXCEL用：品名
        /// </summary>
        public string hinmei { get; set; }

        /// <summary>
        /// EXCEL用：単価設定
        /// </summary>
        public string tankaSettei { get; set; }

        /// <summary>
        /// EXCEL用：マスタ単価使用
        /// </summary>
        public string masterTanka { get; set; }

        /// <summary>
        /// EXCEL用：ログインユーザー名
        /// </summary>
        public string userName { get; set; }
    }
}