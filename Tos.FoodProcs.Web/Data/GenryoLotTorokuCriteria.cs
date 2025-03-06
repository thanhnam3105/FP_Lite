using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class GenryoLotTorokuCriteria
    {
        public GenryoLotTorokuCriteria() { 
        }
        public DateTime dt_hiduke { set; get; }

        public string no_lot { set; get; }

        public string cd_hinmei { set; get; }

        public int no_tonyu { set; get; }

        public string lang { set; get; }

        public bool flg_lost_focus { set; get; }

        public bool flg_registered { set; get; }
    }
}