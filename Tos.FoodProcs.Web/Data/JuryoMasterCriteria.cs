using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 重量マスタ検索情報を定義します。
  /// </summary>
  public class JuryoMasterCriteria {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
	public JuryoMasterCriteria() {
        }

        /// <summary>
        /// 状態区分
        /// </summary>
        public short? kbn_jotai { get; set; }

        /// <summary>
        /// 品区分
        /// </summary>
        public short? kbn_hin { get; set; }

        /// <summary>
        /// 品コード
        /// </summary>
        public string cd_hinmei { get; set; }

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
  }
}