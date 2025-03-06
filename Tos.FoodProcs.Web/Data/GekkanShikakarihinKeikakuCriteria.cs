using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class GekkanShikakarihinKeikakuCriteria
  {
	  /// <summary>
      /// 検索情報を定義するクラスのインスタンスを初期化します。
      /// </summary>
      public GekkanShikakarihinKeikakuCriteria() { }

        /// <summary>
        /// 職場コード
        /// </summary>
        public string cd_shokuba { get; set; }

        /// <summary>
        /// 職場名
        /// </summary>
        public string nm_shokuba { get; set; }

        /// <summary>
        /// ラインコード
        /// </summary>
        public string cd_line { get; set; }

        /// <summary>
        /// ライン名
        /// </summary>
        public string nm_line { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public string flg_mishiyo { get; set; }

        /// <summary>
        /// 検索日（FROM）
        /// </summary>
        public DateTime dt_hiduke_from { get; set; }

        /// <summary>
        /// 検索日（TO）
        /// </summary>
        public DateTime dt_hiduke_to { get; set; }

        /// <summary>
        /// 検索仕掛品コード
        /// </summary>
        public string cd_hinmei_search { get; set; }

        /// <summary>
        /// 検索ロット
        /// </summary>
        public string no_lot_search { get; set; }

        /// <summary>
        /// 検索対象ロット
        /// </summary>
        public string select_lot_search { get; set; }

        /// <summary>
        /// 仕込計画数
        /// <summary>
        public decimal wt_shikomi_keikaku { get; set; }

        /// <summary>
        /// 製造日
        /// </summary>
        public DateTime dt_seizo { get; set; }

        /// <summary>
        /// 必要日
        /// </summary>
        public DateTime dt_hitsuyo { get; set; }

        /// <summary>
        /// 製品ロット番号
        /// </summary>
        public string no_lot_seihin { get; set; }

        /// <summary>
        /// 仕掛ロット番号
        /// </summary>
        public string no_lot_shikakari { get; set; }
        
        /// <summary>
        /// 仕掛親ロット番号
        /// </summary>
        public string no_lot_shikakari_oya { get; set; }

        /// <summary>
        /// 必要量
        /// </summary>
        public decimal wt_hitsuyo { get; set; }

        /// <summary>
        /// 基本倍率
        /// </summary>
        public decimal ritsu_kihon { get; set; }

        /// <summary>
        /// 合計配合重量
        /// </summary>
        public decimal wt_haigo_gokei { get; set; }

        /// <summary>
        /// data key
        /// </summary>
        public string data_key { get; set; }

        /// <summary>
        /// エクセルフラグ
        /// </summary>
        public string isExcel { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// 仕込合算フラグ
        /// </summary>
        public short? flg_gassan_shikomi { get; set; }
  }
}