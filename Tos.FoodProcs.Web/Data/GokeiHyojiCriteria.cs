using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 検索情報を定義します。
  /// </summary>
  public class GokeiHyojiCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GokeiHyojiCriteria() { }

        /// <summary>
        /// 職場コード
        /// </summary>
        public string cd_shokuba { get; set; }

        /// <summary>
        /// ラインコード
        /// </summary>
        public string cd_line { get; set; }

        /// <summary>
        /// 理由区分
        /// </summary>
        public string flg_jisseki { get; set; }

        /// <summary>
        /// 検索日（当日）
        /// </summary>
        public DateTime dt_hiduke_today { get; set; }

        /// <summary>
        /// 検索日（FROM）
        /// </summary>
        public DateTime dt_hiduke_from { get; set; }

        /// <summary>
        /// 検索日（TO）
        /// </summary>
        public DateTime dt_hiduke_to { get; set; }
      
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