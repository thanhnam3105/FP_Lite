using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 製造計画/実績伝送一覧の検索情報を定義します。
  /// </summary>
  public class GetsumatsuZaikoDensoIchiranCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
      public GetsumatsuZaikoDensoIchiranCriteria() { }

        /// <summary>
        /// 伝送日（FROM）
        /// </summary>
        public DateTime dt_denso_from { get; set; }

        /// <summary>
        /// 伝送日（TO）
        /// </summary>
        public DateTime dt_denso_to { get; set; }

        /// <summary>
        /// 製造日（FROM）
        /// </summary>
        public DateTime dt_zaiko_from { get; set; }

        /// <summary>
        /// 製造日（TO）
        /// </summary>
        public DateTime dt_zaiko_to { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 伝送日付チェックボックス
        /// </summary>
        public short chk_denso { get; set; }

        /// <summary>
        /// 製造日付チェックボックス
        /// </summary>
        public short chk_zaiko { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// 在庫区分(両方：0 良品：1 保留品：2)
        /// </summary>
        public short kbn_zaiko { get; set; }
  }
}