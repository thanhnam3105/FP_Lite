using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class ShikakarihinShikomiKeikakuUchiwakeCriteria
  {
	    /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public ShikakarihinShikomiKeikakuUchiwakeCriteria() { }

        /// <summary>
        /// 職場コード
        /// </summary>
        public string cd_shokuba { get; set; }
        
        /// <summary>
        /// ラインコード
        /// </summary>
        public string cd_line { get; set; }

        /// <summary>
        /// 仕掛品コード
        /// </summary>
        public string cd_shikakari_hin { get; set; }

        /// <summary>
        /// 仕掛品ロット番号
        /// </summary>
        public string no_lot_shikakari { get; set; }

        /// <summary>
        /// 製造日
        /// </summary>
        public DateTime dt_seizo { get; set; }
        
        /// <summary>
        /// 確定フラグ
        /// </summary>
        public string flg_kakutei { get; set; }

        /// <summary>
        /// 未確定フラグ
        /// </summary>
        public string flg_mikakutei { get; set; }

        /// <summary>
        /// 仕込フラグ
        /// </summary>
        public string flg_shikomi { get; set; }

    }
}