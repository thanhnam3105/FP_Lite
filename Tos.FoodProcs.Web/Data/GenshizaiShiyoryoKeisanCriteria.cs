using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 原料/資材使用量計算画面の検索情報を定義します。
    /// </summary>
    public class GenshizaiShiyoryoKeisanCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GenshizaiShiyoryoKeisanCriteria()
        {
        }

        /// <summary>
        /// 検索条件：日付
        /// </summary>
        public DateTime con_hizuke { get; set; }

        /// <summary>
        /// 検索条件：分類
        /// </summary>
        public string con_bunrui { get; set; }

        /// <summary>
        /// 検索条件：職場
        /// </summary>
        public string con_shokuba { get; set; }

        /// <summary>
        /// 検索条件：品区分
        /// </summary>
        public short hinKubun { get; set; }

        /// <summary>
        /// 検索条件：予実フラグ：予定/実績
        /// </summary>
        public short flg_yojitsu { get; set; }

        /// <summary>
        /// 検索条件：現地とUTC時間の時差
        /// </summary>
        public int utc { get; set; }

        /// <summary>
        /// EXCEL用：品区分名
        /// </summary>
        public string hinKubunName { get; set; }

        /// <summary>
        /// EXCEL用：分類名
        /// </summary>
        public string bunruiName { get; set; }

        /// <summary>
        /// EXCEL用：職場名
        /// </summary>
        public string shokubaName { get; set; }

        /// <summary>
        /// EXCEL用：ログインユーザー名
        /// </summary>
        public string userName { get; set; }
    }
}