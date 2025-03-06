using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 納入依頼書PDFカウント用データ検索情報を定義します。
  /// </summary>
  public class NonyuIraishoPdfCountCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
	public NonyuIraishoPdfCountCriteria()
        {
        }

        /// <summary>
        /// 印刷種別：全件印刷/全印刷/指定印刷
        /// </summary>
        public string printType { get; set; }

        /// <summary>
        /// 「予定なしの品目も出力する」
        /// </summary>
        public bool yotei { get; set; }

        /// <summary>
        /// 「分類毎に改頁する」
        /// </summary>
        public bool bunrui { get; set; }

        /// <summary>
        /// 納品先コード
        /// </summary>
        public string niukeCode { get; set; }

        /// <summary>
        /// 検索日付From
        /// </summary>
        public DateTime dateFrom { get; set; }

        /// <summary>
        /// 検索日付To
        /// </summary>
        public DateTime dateTo { get; set; }

        /// <summary>
        /// 選択された取引先コード(1件)
        /// </summary>
        public string torihikisaki { get; set; }

        /// <summary>
        /// システム日付
        /// </summary>
        public DateTime sysdate { get; set; }

        /// <summary>
        /// 選択された品名コード
        /// </summary>
        public string hinCode { get; set; }

        /// <summary>
        /// 選択された取引コード
        /// </summary>
        public string torihikiCode { get; set; }
  }
}