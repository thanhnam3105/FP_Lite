using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class ShikakarihinShikomiKeikakuCriteria
  {
	    /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public ShikakarihinShikomiKeikakuCriteria() { }

        /// <summary>
        /// 職場コード
        /// </summary>
        public string cd_shokuba { get; set; }
        
        /// <summary>
        /// 職場名
        /// </summary>
        public string nm_shokuba { get; set; }

        /// <summary>
        /// ラインコード
        /// </summary>
        public string cd_line { get; set; }

        /// <summary>
        /// ライン名
        /// </summary>
        public string nm_line { get; set; }

        /// <summary>
        /// 検索日
        /// </summary>
        public DateTime dt_hiduke { get; set; }
        
        /// <summary>
        /// 確定フラグ
        /// </summary>
        public string flg_kakutei { get; set; }

        /// <summary>
        /// 未確定フラグ
        /// </summary>
        public string flg_mikakutei { get; set; }

        /// <summary>
        /// 仕込みチェック(ラジオボタン）
        /// </summary>
        public string isShikomi { get; set; }

        /// <summary>
        /// 使用チェック(ラジオボタン）
        /// </summary>
        public string isShiyo { get; set; }

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