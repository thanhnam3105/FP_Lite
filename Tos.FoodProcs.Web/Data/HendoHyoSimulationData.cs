using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 原資材変動表データを定義します。
  /// </summary>
  public class HendoHyoSimulationData {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public HendoHyoSimulationData() { }

        /// <summary>
        /// 予実フラグ
        /// </summary>
        public short flg_yojitsu { get; set; }

        /// <summary>
        /// 納入番号
        /// </summary>
        public string no_nonyu { get; set; }

        /// <summary>
        /// 納入日
        /// </summary>
        public DateTime dt_nonyu { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 納入数
        /// </summary>
        public decimal su_nonyu { get; set; }

        /// <summary>
        /// 納入端数
        /// </summary>
        public decimal su_nonyu_hasu { get; set; }

        /// <summary>
        /// 取引先コード
        /// </summary>
        public string cd_torihiki { get; set; }

        /// <summary>
        /// 取引先コード２
        /// </summary>
        public string cd_torihiki2 { get; set; }

        /// <summary>
        /// 納入単価
        /// </summary>
        public decimal tan_nonyu { get; set; }

        /// <summary>
        /// 金額
        /// </summary>
        public decimal kin_kingaku { get; set; }

        /// <summary>
        /// 納入書番号
        /// </summary>
        public string no_nonyusho { get; set; }

        /// <summary>
        /// 税区分
        /// </summary>
        public short kbn_zei { get; set; }

        /// <summary>
        /// 伝送区分
        /// </summary>
        public short kbn_denso { get; set; }

        /// <summary>
        /// 確定フラグ
        /// </summary>
        public short flg_kakutei { get; set; }

        /// <summary>
        /// 製造日
        /// </summary>
        public DateTime? dt_seizo { get; set; }

        /// <summary>
        /// 個数
        /// </summary>
        public decimal su_ko { get; set; }

        /// <summary>
        /// 入数
        /// </summary>
        public decimal su_iri { get; set; }

        /// <summary>
        /// 単位コード
        /// </summary>
        public string cd_tani { get; set; }

  }
}