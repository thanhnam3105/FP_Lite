using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 品名マスタ検索情報を定義します。
  /// </summary>
    public class HaigoRecipeMasterCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public HaigoRecipeMasterCriteria()
        {
        }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public String lang { get; set; }

        /// <summary>
        /// 配合コード
        /// </summary>
        public String cd_haigo { get; set; }

        /// <summary>
        /// 配合名
        /// </summary>
        public String nm_haigo { get; set; }

        /// <summary>
        /// 分類名
        /// </summary>
        public String nm_bunrui { get; set; }

        /// <summary>
        /// 合計配合重量
        /// </summary>
        public decimal wt_haigo_gokei { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public decimal wt_kowake { get; set; }

        /// <summary>
        /// 小分数
        /// </summary>
        public decimal su_kowake { get; set; }

        /// <summary>
        /// 基本重量
        /// </summary>
        public string wt_kihon { get; set; }

        /// <summary>
        /// 版番号
        /// </summary>
        public decimal no_han { get; set; }

        /// <summary>
        /// 工程番号
        /// </summary>
        public decimal no_kotei { get; set; }

        /// <summary>
        /// 製法番号
        /// </summary>
        public string no_seiho { get; set; }

        /// <summary>
        /// 備考
        /// </summary>
        public string biko { get; set; }

        /// <summary>
        /// 有効開始日付
        /// </summary>
        public string dt_from { get; set; }

        /// <summary>
        /// 品管担当者名
        /// </summary>
        public string nm_tanto_hinkan { get; set; }

        /// <summary>
        /// 品管更新日
        /// </summary>
        public string dt_hinkan_koshin { get; set; }

        /// <summary>
        /// 製造担当者名
        /// </summary>
        public string nm_tanto_seizo { get; set; }

        /// <summary>
        /// 製造更新日
        /// </summary>
        public string dt_seizo_koshin { get; set; }

        /// <summary>
        /// 未使用表示：あり(1)/なし(0)
        /// </summary>
        public string flg_mishiyo { get; set; }

        /// <summary>
        /// 現地の当日日付
        /// </summary>
        public DateTime local_today { get; set; }
    }
}