using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 納入予定/実績伝送一覧の検索情報を定義します。
  /// </summary>
  public class NonyuDensoIchiranCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public NonyuDensoIchiranCriteria(){}

        /// <summary>
        /// 伝送日（FROM）
        /// </summary>
        public DateTime dt_denso_from { get; set; }

        /// <summary>
        /// 伝送日（TO）
        /// </summary>
        public DateTime dt_denso_to { get; set; }

        /// <summary>
        /// 納入日（FROM）
        /// </summary>
        public DateTime dt_nonyu_from { get; set; }

        /// <summary>
        /// 納入日（TO）
        /// </summary>
        public DateTime dt_nonyu_to { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 納入番号
        /// </summary>
        public string no_nonyu { get; set; }

        /// <summary>
        /// 伝送日付チェックボックス
        /// </summary>
        public short chk_denso { get; set; }

        /// <summary>
        /// 納入日付チェックボックス
        /// </summary>
        public short chk_nonyu { get; set; }

        /// <summary>
        /// 納入番号の頭に付与するPrefix
        /// </summary>
        public string put_char { get; set; }

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