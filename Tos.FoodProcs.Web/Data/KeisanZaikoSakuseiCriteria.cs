using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 計算在庫作成画面の検索情報を定義します。
    /// </summary>
    public class KeisanZaikoSakuseiCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public KeisanZaikoSakuseiCriteria()
        {
        }

        /// <summary>
        /// 検索条件：開始日付
        /// </summary>
        public DateTime dtFrom { get; set; }

        /// <summary>
        /// 検索条件：終了日付
        /// </summary>
        public DateTime dtTo { get; set; }

        /// <summary>
        /// 検索条件：品名コード
        /// </summary>
        public string hinCd { get; set; }

        /// <summary>
        /// 検索条件：ログインユーザーコード
        /// </summary>
        public string user { get; set; }

        /// <summary>
        /// UTCシステム日付
        /// </summary>
        public DateTime today { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// 検索条件：品区分
        /// </summary>
        public short con_kbn_hin { get; set; }

        /// <summary>
        /// 検索条件：品分類
        /// </summary>
        public string con_bunrui { get; set; }

        /// <summary>
        /// 検索条件：庫場所
        /// </summary>
        public string con_kurabasho { get; set; }

        /// <summary>
        /// 検索条件：品名
        /// </summary>
        public string con_nm_hinmei { get; set; }
    }
}