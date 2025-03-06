using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class NenkanCalendarCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public NenkanCalendarCriteria()
        {
        }

        /// <summary>
        /// 年度
        /// </summary>
        public string yy_nendo { get; set; }

        /// <summary>
        /// ユーザーコード
        /// </summary>
        public string cd_user { get; set; }

        /// <summary>
        /// 会社コード
        /// </summary>
        public string cd_kaisha { get; set; }

        /// <summary>
        /// 工場コード
        /// </summary>
        public string cd_kojo { get; set; }

        /// <summary>
        /// 年度開始月
        /// </summary>
        public short dt_nendo_start { get; set; }

        /// <summary>
        /// 言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// 標準時間と現地時間の差分
        /// </summary>
        public int? add_hh { get; set; }
  }
}