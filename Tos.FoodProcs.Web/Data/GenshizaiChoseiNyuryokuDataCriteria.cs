using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    /// <summary>
    /// 原価計算関連(原価単価作成画面、原価一覧画面)の情報を定義します。
    /// </summary>
    public class GenshizaiChoseiNyuryokuDataCriteria
    {
        /// <summary>
        /// シーケンス番号
        /// </summary>
        public String no_seq { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public String cd_hinmei { get; set; }

        /// <summary>
        /// 日付
        /// </summary>
        public DateTime dt_hizuke { get; set; }

        /// <summary>
        /// 理由コード
        /// </summary>
        public String cd_riyu { get; set; }

        /// <summary>
        /// 理由コード
        /// </summary>
        public String cd_riyu_old { get; set; }

        /// <summary>
        /// 理由
        /// </summary>
        public String nm_riyu_text { get; set; }

        /// <summary>
        /// 調整数
        /// </summary>
        public Decimal su_chosei { get; set; }

        /// <summary>
        /// 調整数
        /// </summary>
        public Decimal su_chosei_old { get; set; }

        /// <summary>
        /// 備考
        /// </summary>
        public String biko { get; set; }

        /// <summary>
        /// 備考
        /// </summary>
        public String biko_old { get; set; }

        /// <summary>
        /// 製品コード
        /// </summary>
        public String cd_seihin { get; set; }

        /// <summary>
        /// 更新日時
        /// </summary>
        public DateTime dt_update { get; set; }

        /// <summary>
        /// 更新者
        /// </summary>
        public String cd_update { get; set; }

        /// <summary>
        /// 原価センターコード
        /// </summary>
        public String cd_genka_center { get; set; }

        /// <summary>
        /// 原価センターコード
        /// </summary>
        public String cd_genka_center_old { get; set; }

        /// <summary>
        /// 原価センター
        /// </summary>
        public String nm_genka_center_text { get; set; }

        /// <summary>
        /// 倉庫コード
        /// </summary>
        public String cd_soko { get; set; }

        /// <summary>
        /// 納品書番号
        /// </summary>
        public String no_nohinsho { get; set; }

        /// <summary>
        /// 返品理由
        /// </summary>
        public String nm_henpin { get; set; }

        /// <summary>
        /// 荷受番号
        /// </summary>
        public String no_niuke { get; set; }


        /// <summary>
        /// 在庫区分
        /// </summary>
        public short kbn_zaiko { get; set; }


        /// <summary>
        /// 取引先コード
        /// </summary>
        public String cd_torihiki { get; set; }

        /// <summary>
        /// 製品ロット
        /// </summary>
        public String no_lot_seihin { get; set; }


        /// <summary>
        /// 使用実績按分区分
        /// </summary>
        public short kbn_shiyo_jisseki_anbun { get; set; }

        /// <summary>
        /// ロット番号
        /// </summary>
        public String no_lot { get; set; }

        /// <summary>
        /// 使用予実按分シーケンス
        /// </summary>
        public String no_seq_shiyo_yojitsu_anbun { get; set; }

        /// <summary>
        /// 使用予実シーケンス
        /// </summary>
        public String no_seq_shiyo_yojitsu { get; set; }

        /// <summary>
        /// 使用量
        /// </summary>
        public Decimal su_shiyo { get; set; }

    }
}