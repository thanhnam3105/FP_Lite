using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class ZaikoUpdObject
    {
        public ZaikoUpdObject() {}
        
        public String cd_hinmei { get; set; }
        
        public DateTime dt_hizuke { get; set; }
        
        public decimal? su_zaiko { get; set; }
        
        public DateTime? dt_jisseki_zaiko { get; set; }
        
        public DateTime? dt_update { get; set; }
        
        public String cd_update { get; set; }
        
        public decimal? tan_tana { get; set; }
        
        public short kbn_zaiko { get; set; }
        
        public String cd_soko { get; set; }
        
        public decimal? tan_tana_bef { get; set; }
    }
}