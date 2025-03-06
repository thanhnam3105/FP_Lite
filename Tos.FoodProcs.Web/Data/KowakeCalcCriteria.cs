using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class KowakeCalcCriteria
    {
        /// <summary>
        /// デフォルトコンストラクタ
        /// </summary>
        public KowakeCalcCriteria(decimal? wtShikomi, decimal wtNisugata, decimal? wtKowake, string nmTani)
        {
            shikomiJuryo = wtShikomi;       // 仕込重量
            soJuryo = 0;                    // 総重量
            nisugataJuryo = wtNisugata;     // 荷姿重量
            nisugataSu = 0;                 // 荷姿数
            kowakeJuryo = wtKowake;         // 小分重量
            kowakeJuryo1 = 0;               // 小分重量1
            kowakeSu1 = 0;                  // 小分数1
            kowakeJuryo2 = 0;               // 小分重量2
            kowakeSu2 = 0;                  // 小分数2
            nmtani = nmTani;                // 単位名
            cdFutai1 = String.Empty;        // 風袋コード(小分重量1)
            nmFutai1 = String.Empty;        // 風袋名(小分重量1)
            cdFutai2 = String.Empty;        // 風袋コード(小分重量2)
            nmFutai2 = String.Empty;        // 風袋名(小分重量2)
        }

        /// <summary>
        /// 仕込重量
        /// </summary>
        public decimal? shikomiJuryo { get; set; }

        /// <summary>
        /// 総重量
        /// </summary>
        public decimal? soJuryo { get; set; }

        /// <summary>
        /// 荷姿重量
        /// </summary>
        public decimal nisugataJuryo { get; set; }

        /// <summary>
        /// 荷姿数
        /// </summary>
        public decimal? nisugataSu { get; set; }

        /// <summary>
        /// 小分重量
        /// </summary>
        public decimal? kowakeJuryo { get; set; }

        /// <summary>
        /// 小分重量1
        /// </summary>
        public decimal? kowakeJuryo1 { get; set; }

        /// <summary>
        /// 小分数1
        /// </summary>
        public decimal? kowakeSu1 { get; set; }

        /// <summary>
        /// 小分重量2
        /// </summary>
        public decimal? kowakeJuryo2 { get; set; }

        /// <summary>
        /// 小分数2
        /// </summary>
        public decimal? kowakeSu2 { get; set; }

        /// <summary>
        /// 単位名
        /// </summary>
        public string nmtani { get; set; }

        /// <summary>
        /// 風袋コード(小分重量1)
        /// </summary>
        public string cdFutai1 { get; set; }

        /// <summary>
        /// 風袋名(小分重量1)
        /// </summary>
        public string nmFutai1 { get; set; }

        /// <summary>
        /// 風袋コード(小分重量2)
        /// </summary>
        public string cdFutai2 { get; set; }

        /// <summary>
        /// 風袋名(小分重量2)
        /// </summary>
        public string nmFutai2 { get; set; }
    }
}