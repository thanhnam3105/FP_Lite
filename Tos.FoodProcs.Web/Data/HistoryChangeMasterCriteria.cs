using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 原資材変動表検索情報を定義します。
  /// </summary>
    public class HistoryChangeMasterCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public HistoryChangeMasterCriteria()
        {
        }

        /// <summary>
        /// 数据区分
        /// </summary>
        public decimal? kbn_data { get; set; }

        /// <summary>
        /// 処理区分
        /// </summary>
        public decimal? kbn_shori { get; set; }

        /// <summary>
        /// 日期（开始）
        /// </summary>
        public DateTime? dt_hiduke_from { get; set; }

        /// <summary>
        /// 日期（结束）
        /// </summary>
        public DateTime? dt_hiduke_to { get; set; }

        /// <summary>
        /// 品名编号
        /// </summary>
        public String cd_hinmei { get; set; }

        /// <summary>
        /// 更新日（开始）
        /// </summary>
        public DateTime? dt_update_from { get; set; }

        /// <summary>
        /// 更新日（结束）
        /// </summary>
        public DateTime? dt_update_to { get; set; }

        /// <summary>
        /// 担当者
        /// </summary>
        public String cd_nm_tanto { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }
    }
}