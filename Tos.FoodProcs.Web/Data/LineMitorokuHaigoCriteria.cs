using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class LineMitorokuHaigoCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public LineMitorokuHaigoCriteria()
        {
        }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public short flg_mishiyo { get; set; }

        /// <summary>
        /// マスタ区分
        /// </summary>
        public short kbn_master { get; set; }

        /// <summary>
        /// 検索版
        /// </summary>
        public short searchHan { get; set; }

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