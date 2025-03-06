using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

    /// <summary>
    /// 製造実績選択ダイアログの検索情報を定義します。
    /// </summary>
    public class SeizoJissekiSentakuDialogCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public SeizoJissekiSentakuDialogCriteria()
        {
        }

        /// <summary>
        /// 開始日
        /// </summary>
        public DateTime dt_from { get; set; }

        /// <summary>
        /// 終了日
        /// </summary>
        public DateTime dt_to { get; set; }

        /// <summary>
        /// 仕掛品コード
        /// </summary>
        public string cd_haigo { get; set; }

        /// <summary>
        /// 言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// ユーザー
        /// </summary>
        public string user { get; set; }
    }
}