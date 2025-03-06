using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 変動表シミュレーション検索情報を定義します。
    /// </summary>
    public class HendoHyoSimulationCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public HendoHyoSimulationCriteria()
        {
        }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string con_cd_hinmei { get; set; }

        /// <summary>
        /// 日付
        /// </summary>
        public DateTime con_dt_hizuke { get; set; }

        /// <summary>
        /// 取得対象一日フラグ
        /// </summary>
        public string flg_one_day { get; set; }

        /// <summary>
        /// 予実フラグ：予定
        /// </summary>
        public short flg_yojitsu_yo { get; set; }

        /// <summary>
        /// 予実フラグ：実績
        /// </summary>
        public short flg_yojitsu_ji { get; set; }

        /// <summary>
        /// UTCシステム日付
        /// </summary>
        public DateTime today { get; set; }
    }
}