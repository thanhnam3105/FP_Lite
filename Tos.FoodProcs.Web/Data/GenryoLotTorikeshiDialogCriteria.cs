using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class GenryoLotTorikeshiDialogCriteria
    {
        public GenryoLotTorikeshiDialogCriteria()
        {
        }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei {
            get;
            set;
        }
        public string no_lot_shikakari
        {
            get;
            set;
        }
        public decimal no_kotei
        {
            set;
            get;
        }
        public decimal no_tonyu
        {
            set;
            get;
        }
    }
}