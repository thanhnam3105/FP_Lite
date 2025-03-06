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
    public class JikaGenryoLotTorikeshiDialogController : ApiController
    {
        // GET api/JikaGenryoLotTorikeshiDialog
        /// <summary>
        /// 
        /// </summary>
        /// <param name="criteria"></param>
        public IEnumerable<usp_JikaGenryoLotTorikeshiDialog_select_Result> Get([FromUri] JikaGenryoLotTorikeshiDialogCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            short kbn_hin = short.Parse(Properties.Resources.JikaGenryoHinKbn);
            return context.usp_JikaGenryoLotTorikeshiDialog_select(kbn_hin, criteria.cd_hinmei, criteria.no_lot_shikakari, criteria.no_kotei, criteria.no_tonyu)
                .OrderBy(p => p.dt_seizo)
                .ThenBy(p => p.no_lot_seihin)
                .AsEnumerable();
        }
    }
}