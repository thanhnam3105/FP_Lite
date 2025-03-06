using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 警告リスト作成画面の検索情報を定義します。
    /// </summary>
    public class KeikokuListSakuseiCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public KeikokuListSakuseiCriteria()
        {
        }

        /// <summary>
        /// 検索条件：日付
        /// </summary>
        public DateTime con_hizuke { get; set; }

        /// <summary>
        /// 検索条件：品区分
        /// </summary>
        public string con_kubun { get; set; }

        /// <summary>
        /// 検索条件：品分類
        /// </summary>
        public string con_bunrui { get; set; }

        /// <summary>
        /// 検索条件：庫場所
        /// </summary>
        public string con_kurabasho { get; set; }

        /// <summary>
        /// 検索条件：品名/品名コード
        /// </summary>
        public string con_hinmei { get; set; }

        /// <summary>
        /// 検索条件：警告条件
        /// </summary>
        public short con_keikoku_list { get; set; }

        /// <summary>
        /// 検索条件：最大在庫も警告
        /// </summary>
        public short con_zaiko_max_flg { get; set; }

        /// <summary>
        /// 検索条件：終了日
        /// </summary>
        public DateTime con_dt_end { get; set; }

        /// <summary>
        /// 検索条件：全ての原資材を表示
        /// </summary>
        public short all_genshizai { get; set; }

        /// <summary>
        /// 検索条件：納入リードタイムを加味する
        /// </summary>
        public short flg_leadtime { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// UTC時間で変換済みシステム日付
        /// </summary>
        public DateTime today { get; set; }

        /// <summary>
        /// EXCEL用：品区分名
        /// </summary>
        public string hinKubunName { get; set; }

        /// <summary>
        /// EXCEL用：分類名
        /// </summary>
        public string hinBunruiName { get; set; }

        /// <summary>
        /// EXCEL用：庫場所名
        /// </summary>
        public string kurabashoName { get; set; }

        /// <summary>
        /// EXCEL用：警告リスト
        /// </summary>
        public string keikokuList { get; set; }

        /// <summary>
        /// EXCEL用：前日在庫－当日使用
        /// </summary>
        public string zenjitsuZaiko { get; set; }

        /// <summary>
        /// EXCEL用：最大在庫も警告
        /// </summary>
        public string keikokuMax { get; set; }

        /// <summary>
        /// EXCEL用：全ての原資材を表示
        /// </summary>
        public string allGenshizaiDisp { get; set; }

        /// <summary>
        /// EXCEL用：納入リードタイムを加味する
        /// </summary>
        public string leadtimeKami { get; set; }

        /// <summary>
        /// EXCEL用：ログインユーザー名
        /// </summary>
        public string userName { get; set; }

        /// <summary>
        /// EXCEL用：日付の区切り範囲
        /// </summary>
        public int splitDays { get; set; }
    }
}