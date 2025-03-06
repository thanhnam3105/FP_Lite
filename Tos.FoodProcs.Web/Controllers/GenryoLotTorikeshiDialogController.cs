using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class GenryoLotTorikeshiDialogController : ApiController
    {
        // GET api/GenryoLotTorikeshiDialog
        /// <summary>
        /// 
        /// </summary>
        /// <param name="criteria"></param>
        public IEnumerable<usp_GenryoLotTorikeshiDialog_select_Result> Get([FromUri] GenryoLotTorikeshiDialogCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            short kbn_hin = short.Parse(Properties.Resources.GenryoHinKbn);
            decimal no_seq = Decimal.Parse(Properties.Resources.No_seq);
            return context.usp_GenryoLotTorikeshiDialog_select(kbn_hin, criteria.cd_hinmei, no_seq, criteria.no_lot_shikakari, criteria.no_kotei, criteria.no_tonyu)
                .OrderBy(p => p.dt_niuke)
                .ThenBy(p => p.dt_nonyu)
                .AsEnumerable();
        }
    }
}