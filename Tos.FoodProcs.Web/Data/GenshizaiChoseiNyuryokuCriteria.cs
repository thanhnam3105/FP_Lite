using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

    /// <summary>
    /// 原価計算関連(原価単価作成画面、原価一覧画面)の情報を定義します。
    /// </summary>
    public class GenshizaiChoseiNyuryokuCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GenshizaiChoseiNyuryokuCriteria()
        {
        }

        /// <summary>
        /// 検索条件：(変更前)調整数
        /// </summary>
        public decimal before_su_chosei { get; set; }

        /// <summary>
        /// 検索条件：(変更後)調整数
        /// </summary>
        public decimal after_su_chosei { get; set; }

        /// <summary>
        /// 検索条件：製品ロット№
        /// </summary>
        public string no_lot_seihin { get; set; }


        /// <summary>
        /// 検索条件：ロット№
        /// </summary>
        public string no_lot { get; set; }


        /// <summary>
        /// 検索条件：使用予実按分シーケンス
        /// </summary>
        public string no_seq_shiyo_yojitsu_anbun { get; set; }


        /// <summary>
        /// 検索条件：使用実績按分区分
        /// </summary>
        public short kbn_shiyo_jisseki_anbun { get; set; }



    }
}