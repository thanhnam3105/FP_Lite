using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 原資材・仕掛品使用一覧の検索情報を定義します。
  /// </summary>
  public class GenshizaiShikakarihinShiyoIchiranCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GenshizaiShikakarihinShiyoIchiranCriteria() { }

        /// <summary>
        /// 品区分
        /// </summary>
        public short kbn_hin { get; set; }

        /// <summary>
        /// 分類
        /// </summary>
        public string bunrui { get; set; }

        /// <summary>
        /// 名称
        /// </summary>
        public string hinmei { get; set; }

        /// <summary>
        /// 有効日付
        /// </summary>
        public DateTime? dt_from { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// システムUTC日付
        /// </summary>
        public DateTime today { get; set; }

        /// <summary>
        /// 検索最大件数
        /// </summary>
        public int? maxCount { get; set; }

        /// <summary>
        /// 区分／コード一覧．未使用フラグ．未使用
        /// </summary>
        public bool shiyoMishiyoFlag { get; set; }
  }
}