using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class ShikomiJuryoContainer
    {

        // コンストラクタ
        public ShikomiJuryoContainer()
        {
        }
        //画面の情報
        // 仕込重量
        public decimal shikomiJuryo { get; set; }
        // 正規倍率
        public decimal bairitsu { get; set; }
        // 端数倍率
        public decimal bairitsuHasu { get; set; }
        // 正規バッチ数
        public decimal batchSu { get; set; }
        // 端数バッチ数
        public decimal batchSuHasu { get; set; }

        // マスタ属性
        // 基本倍率（配合名マスタ）
        public decimal kihonBairitsu { get; set; }
        // 合計配合重量（配合マスタ名）
        public decimal gokeiHaigoJuryo { get; set; }

    }
}