using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 品名マスタ検索情報を定義します。
  /// </summary>
    public class HinmeiMasterIchiranCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public HinmeiMasterIchiranCriteria()
        {
        }

        /// <summary>
        /// 検索条件：品区分
        /// </summary>
        public short con_kbn_hin { get; set; }

        /// <summary>
        /// 検索条件：分類
        /// </summary>
        public String con_bunrui { get; set; }

        /// <summary>
        /// 検索条件：保管区分
        /// </summary>
        public String con_kbn_hokan { get; set; }

        /// <summary>
        /// 検索条件：品名
        /// </summary>
        public String con_hinmei { get; set; }

        /// <summary>
        /// 検索条件：未使用表示：あり(1)/なし(0)
        /// </summary>
        public short mishiyo_hyoji { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public String lang { get; set; }

        /// <summary>
        /// 取引先区分：売上先
        /// </summary>
        public short kbnUriagesaki { get; set; }

        /// <summary>
        /// 取引先区分：製造元
        /// </summary>
        public short kbnSeizomoto { get; set; }

        /// <summary>
        /// 未使用フラグ：使用
        /// </summary>
        public short flgShiyo { get; set; }

        /// <summary>
        /// 版番号
        /// </summary>
        public decimal hanNo { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// 現地の当日日付
        /// </summary>
        public DateTime local_today { get; set; }
    }
}