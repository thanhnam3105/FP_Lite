using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 原資材変動表検索情報を定義します。
  /// </summary>
    public class GenshizaiHendoHyoCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GenshizaiHendoHyoCriteria()
        {
        }

        /// <summary>
        /// 品コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 日付/開始日
        /// </summary>
        public DateTime dt_hizuke { get; set; }

        /// <summary>
        /// 日付/終了日
        /// </summary>
        public DateTime dt_hizuke_to { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// 当日日付
        /// </summary>
        public DateTime today { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }
    }
}