using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 検索情報を定義します。
  /// </summary>
  public class LabelInsatsuCriteria
  {
	    /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public LabelInsatsuCriteria() { }

        /// <summary>
        /// 仕掛品ロット番号
        /// </summary>
        public string no_lot_shikakari { get; set; }

        /// <summary>
        /// 状態区分
        /// </summary>
        public string kbn_jotai { get; set; }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public string flg_mishiyo { get; set; }
    }
}