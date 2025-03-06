using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class HaigoMasterIchiranCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public HaigoMasterIchiranCriteria()
        {
        }

        /// <summary>
        /// 品区分
        /// </summary>
        public short kbn_hin { get; set; }

        /// <summary>
        /// マスタ区分
        /// </summary>
        public short kbn_master { get; set; }

        /// <summary>
        /// 日付初期値
        /// </summary>
        //public string dt_shokichi { get; set; }
        public DateTime dt_shokichi { get; set; }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public short flg_mishiyo { get; set; }

        /// <summary>
        /// 分類コード
        /// </summary>
        public String cd_bunrui { get; set; }

        /// <summary>
        /// 配合名
        /// </summary>
        public String nm_haigo { get; set; }

        /// <summary>
        /// 言語
        /// </summary>
        public String lang { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        ///// <summary>
        ///// 当日日付
        ///// </summary>
        //public DateTime sysDate { get; set; }

        /// <summary>
        /// 有効日付
        /// </summary>
        public DateTime dt_from { get; set; }
  }
}