using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class SeihinKeikakuObject
    {
        public SeihinKeikakuObject()
        {
        }
        public SeihinKeikakuObject(GekkanSeihinKeikakuCriteria criteria)
        {
            seihinLotNo = criteria.no_lot_seihin;
            seizoDate = criteria.dt_seizo;
            shokubaCode = criteria.cd_shokuba;
            lineCode = criteria.cd_line;
            hinmeiCode = criteria.cd_hinmei;
            seizoYoteiSu = criteria.su_seizo_yotei;
            seizoJissekiSu  = criteria.su_seizo_yotei;
            //jissekiFlag 
            //densoKubun 
            //densoFlag 
            //udpateDate 
            
        }
        public String seihinLotNo { set; get; }
        public DateTime seizoDate { set; get; }
        public String shokubaCode { set;get; }
        public String lineCode { set;get; }
        public String hinmeiCode { set;get; }
        public Decimal seizoYoteiSu { set; get; }
        public Decimal seizoJissekiSu { set; get; }
        public String jissekiFlag { set; get; }
        public String densoKubun { set; get; }
        public String densoFlag { set; get; }
        public String udpateDate { set; get; }

    }
}