using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 製造計画/実績伝送一覧の検索情報を定義します。
  /// </summary>
  public class SeizoDensoIchiranCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public SeizoDensoIchiranCriteria(){}

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
        public DateTime dt_seizo_from { get; set; }

        /// <summary>
        /// 製造日（TO）
        /// </summary>
        public DateTime dt_seizo_to { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 製品ロット番号
        /// </summary>
        public string no_lot_seihin { get; set; }

        /// <summary>
        /// 伝送日付チェックボックス
        /// </summary>
        public short chk_denso { get; set; }

        /// <summary>
        /// 製造日付チェックボックス
        /// </summary>
        public short chk_seizo { get; set; }

        /// <summary>
        /// 製品ロット番号の頭に付与するPrefix
        /// </summary>
        public string lot_put_char { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// 予実フラグ(予定：0 実績：1)
        /// </summary>
        public short flg_yojitsu { get; set; }
  }
}