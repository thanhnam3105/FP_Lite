using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// カレンダーマスタ検索情報を定義します。
  /// </summary>
  public class GekkanSeihinKeikakuCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GekkanSeihinKeikakuCriteria(){}

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
        /// 理由区分
        /// </summary>
        public string cd_riyu { get; set; }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public string flg_mishiyo { get; set; }

        /// <summary>
        ///  品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 製造予定数
        /// <summary>
        public decimal su_seizo_yotei { get; set; }

        /// <summary>
        /// 製造予定数 
        /// <summary>
        public decimal su_seizo_yotei_old { get; set; }

        /// <summary>
        /// 検索日（FROM）
        /// </summary>
        public DateTime dt_hiduke_from { get; set; }

        /// <summary>
        /// 検索日（TO）
        /// </summary>
        public DateTime dt_hiduke_to { get; set; }

        /// <summary>
        /// 製造日
        /// </summary>
        public DateTime dt_seizo { get; set; }

        /// <summary>
        /// 製品ロット番号
        /// </summary>
        public string no_lot_seihin { get; set; }

        /// <summary>
        /// データキー
        /// </summary>
        public string data_key { get; set; }

        /// <summary>
        /// 実績確認値
        /// </summary>
        public string henkozumi_data { get; set; }

        /// <summary>
        /// 休日フラグ
        /// </summary>
        public string flg_kyujitsu { get; set; }

        /// <summary>
        /// 全ラインフラグ
        /// </summary>
        public string isAllLine { get; set; }

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
        /// バッチ数
        /// <summary>
        public decimal su_batch_keikaku { get; set; }

        /// <summary>
        /// 更新日時
        /// <summary>
        public DateTime dt_update { get; set; }
  }
}