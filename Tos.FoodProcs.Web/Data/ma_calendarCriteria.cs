using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class ma_calendarCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public ma_calendarCriteria()
        {
        }

        /// <summary>
        /// 年度
        /// </summary>
        public string dt_nendo { get; set; }

        /// <summary>
        /// 会社コード
        /// </summary>
        public string cd_kaisha { get; set; }

        /// <summary>
        /// 工場コード
        /// </summary>
        public string cd_kojo { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }
  }
}