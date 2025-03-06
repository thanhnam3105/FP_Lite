using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class GenryoLotTorokuPostCriteria
    {
        public string no_lot_shikakari{ set; get; }
        public decimal no_kotei { set; get; }
        public decimal no_tonyu { set; get; }
        public string cd_hinmei { set; get; }
        public string cd_hinmei_old { set; get; }
        public short kbn_hin { set; get; }
        public string no_niuke { set; get; }
        public bool flg_henko { set; get; }
        public DateTime dt_seizo { set; get; }
        public string cd_shikakari_hin { set; get; }
        public string biko { set; get; }
    }
}