using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 品名ダイアログの検索情報を定義します。
  /// </summary>
  public class HinmeiDialogCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
	public HinmeiDialogCriteria()
        {
        }

        /// <summary>
        /// 品区分
        /// </summary>
        public short? kbn_hin { get; set; }

        /// <summary>
        /// 品名
        /// </summary>
        public string nm_hinmei { get; set; }

        /// <summary>
        /// 分類
        /// </summary>
        public string cd_bunrui { get; set; }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public short? flg_mishiyo_fukumu { get; set; }

        /// <summary>
        /// 言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// 計画系用：ラインコード
        /// </summary>
        public string lineCode { get; set; }

        /// <summary>
        /// 計画系用：職場コード
        /// </summary>
        public string shokubaCode { get; set; }

        /// <summary>
        /// 計画系用：製造日
        /// </summary>
        public DateTime seizoDate { get; set; }
  }
}