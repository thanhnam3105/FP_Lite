using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class YukoHaigoMeiCriteria
  {
	    /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public YukoHaigoMeiCriteria() { }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public short flg_mishiyo { get; set; }

        /// <summary>
        ///  品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 製造日
        /// </summary>
        public DateTime dt_seizo { get; set; }

        /// <summary>
        /// ラインコード
        /// </summary>
        public string cd_line { get; set; }

        /// <summary>
        /// マスター区分
        /// </summary>
        public short kbn_master { get; set; }
  }
}