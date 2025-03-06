using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 製造日報内訳情報を定義します。
  /// </summary>
  public class UchiwakeInfo
  {
	    /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public UchiwakeInfo() { }

        /// <summary>
        /// 製造日
        /// </summary>
        public DateTime dt_seizo { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 仕掛残在庫数
        /// </summary>
        public decimal su_zaiko { get; set; }

        /// <summary>
        /// 仕掛残使用数
        /// </summary>
        public decimal su_shiyo { get; set; }

        /// <summary>
        /// 使用予実按分トランシーケンス番号
        /// </summary>
        public string no_seq_shiyo_yojitsu_anbun { get; set; }

        /// <summary>
        /// 使用予実トランシーケンス番号
        /// </summary>
        public string no_seq_shiyo_yojitsu { get; set; }

        /// <summary>
        /// 製品ロット番号
        /// </summary>
        public string no_lot_seihin { get; set; }

        /// <summary>
        /// 親明細行ID
        /// </summary>
        public string id_row_parent { get; set; }

        /// <summary>
        /// 製品コード
        /// </summary>
        public string cd_seihin { get; set; }

        /// <summary>
        /// 仕掛品ロット番号
        /// </summary>
        public string no_lot_shikakari { get; set; }

        /// <summary>
        /// 検索時仕掛残使用数
        /// </summary>
        public decimal con_su_shiyo { get; set; }

        /// <summary>
        /// 保存時チェック用製造日
        /// </summary>
        public DateTime con_dt_seizo { get; set; }
  }
}