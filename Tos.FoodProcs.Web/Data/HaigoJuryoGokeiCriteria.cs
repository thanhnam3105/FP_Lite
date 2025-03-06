using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class HaigoJuryoGokeiCriteria
  {
	    /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public HaigoJuryoGokeiCriteria()
        {
        }

        /// <summary>
        /// 配合コード
        /// </summary>
        public string cd_haigo { get; set; }

        /// <summary>
        /// 版
        /// </summary>
        public short no_han { get; set; }

        /// <summary>
        /// 工程
        /// </summary>
        public short no_kotei { get; set; }

        /// <summary>
        /// 換算区分
        /// </summary>
        public string kbn_kanzan { get; set; }

        /// <summary>
        /// 配合合計重量
        /// </summary>
        public decimal wt_haigo_gokei { get; set; }
  }
}