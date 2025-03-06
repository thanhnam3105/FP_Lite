using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 原資材変動表データを定義します。
  /// </summary>
  public class GenshizaiHendoHyoData {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
		public GenshizaiHendoHyoData () {}

        /// <summary>
        /// 品コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 日付
        /// </summary>
        public DateTime dt_hizuke { get; set; }

        /// <summary>
        /// 納入数量
        /// </summary>
        public decimal? su_nonyu_yotei { get; set; }

        /// <summary>
        /// 調整量
        /// </summary>
        public decimal? su_chosei { get; set; }

        /// <summary>
        /// 計算在庫数量
        /// </summary>
        public decimal? su_keisanzaiko { get; set; }

        /// <summary>
        /// 実在庫数量
        /// </summary>
        public decimal? su_jitsuzaiko { get; set; }

        /// <summary>
        /// 更新者
        /// </summary>
        public string cd_update { get; set; }

        /// <summary>
        /// 調整トラン更新フラグ
        /// </summary>
        public short flg_update_tr_chosei { get; set; }

        /// <summary>
        /// 納入トラン更新フラグ
        /// </summary>
        public short flg_update_tr_nonyu { get; set; }

        /// <summary>
        /// 計算在庫トラン更新フラグ
        /// </summary>
        public short flg_update_tr_zaiko_keisan { get; set; }

        /// <summary>
        /// 在庫トラン更新フラグ
        /// </summary>
        public short flg_update_tr_zaiko { get; set; }

        /// <summary>
        /// 調整トラン削除フラグ
        /// </summary>
        public short flg_delete_tr_chosei { get; set; }

        /// <summary>
        /// 納入トラン削除フラグ
        /// </summary>
        public short flg_delete_tr_nonyu { get; set; }

        /// <summary>
        /// 計算在庫トラン削除フラグ
        /// </summary>
        public short flg_delete_tr_zaiko_keisan { get; set; }

        /// <summary>
        /// 在庫トラン削除フラグ
        /// </summary>
        public short flg_delete_tr_zaiko { get; set; }

        /// <summary>
        /// 在庫トラン削除フラグ
        /// </summary>
        public decimal? su_ko { get; set; }

        /// <summary>
        /// 在庫トラン削除フラグ
        /// </summary>
        public decimal? su_iri { get; set; }

        /// <summary>
        /// 在庫トラン削除フラグ
        /// </summary>
        public string cd_tani { get; set; }

        /// <summary>
        /// 荷受場所コード(調整トラン、在庫トランの倉庫コード更新用)
        /// </summary>
        public string cd_niuke_basho { get; set; }

  }
}