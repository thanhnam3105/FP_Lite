using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using System.Net.Http.Formatting;
using System.Data.Objects;
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers {

    [Authorize]
    [LoggingExceptionFilter]
    public class GenryoLotTorokuController : ApiController
    {
        // GET api/GenryoLotToroku
        /// <summary>
        /// 
        /// </summary>
        /// <param name="criteria"></param>
        /// 
        public StoredProcedureResult<usp_GenryoLotToroku_select_Result> Get([FromUri] GenryoLotTorokuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            DateTime dt_hiduke = new DateTime(criteria.dt_hiduke.Year, criteria.dt_hiduke.Month, criteria.dt_hiduke.Day);
			context.CommandTimeout = 0;
            if (criteria.flg_lost_focus == true)
            {
                List<usp_GenryoLotToroku_select_03_Result> tmp;
                tmp = context.usp_GenryoLotToroku_select_03(
                                                        dt_hiduke,
                                                        criteria.cd_hinmei,
                                                        criteria.no_lot,
                                                        criteria.no_tonyu).Distinct().ToList();
                List<usp_GenryoLotToroku_select_Result> views = new List<usp_GenryoLotToroku_select_Result>();

                if(tmp.Count() > 0){
                    usp_GenryoLotToroku_select_Result item = new usp_GenryoLotToroku_select_Result() { 
                        no_lot = tmp[0].no_lot,
                        no_niuke = tmp[0].no_niuke
                    };
                    views.Add(item);
                }

                var result = new StoredProcedureResult<usp_GenryoLotToroku_select_Result>();
                result.d = views;
                result.__count = views.Count();

                return result;
            }
            else
            {
                List<usp_GenryoLotToroku_select_Result> views;
                if (criteria.flg_registered == false)
                {
                    views = context.usp_GenryoLotToroku_select_01(
                                                        dt_hiduke,
                                                        criteria.cd_hinmei,
                                                        criteria.no_lot,
                                                        ActionConst.GenryoHinKbn,
                                                        ActionConst.ShikakariHinKbn,
                                                        ActionConst.JikaGenryoHinKbn).Distinct().ToList();
                }
                else
                {
                    views = context.usp_GenryoLotToroku_select_02(
                                                        dt_hiduke,
                                                        criteria.cd_hinmei,
                                                        criteria.no_lot).ToList();
                }
                var returnValue = new List<usp_GenryoLotToroku_select_Result>();
                for (int i = 0; i < views.Count(); i++)
                {
                    var item = views[i];
                    var temp = new List<usp_GenryoLotToroku_select_Result>();
                    string no_lot = item.no_lot != null ? item.no_lot : "";
                    string no_niuke = item.no_niuke != null ? item.no_niuke : "";
                    for (int j = i+1; j < views.Count(); j++)
                    {
                        if (isSame(item, views[j]))
                        {
                            string[] arr = no_niuke.Split(',');
                            int index = Array.FindIndex(arr, s => s.Equals(views[j].no_niuke));
                            if ((index < 0 || index > arr.Length) && views[j].no_niuke != null)
                            {
                                no_lot += "," + views[j].no_lot;
                                no_niuke += "," + views[j].no_niuke;
                                if (no_lot[0] == ',')
                                {
                                    no_lot = no_lot.Remove(0, 1);
                                }
                                if (no_niuke[0] == ',')
                                {
                                    no_niuke = no_niuke.Remove(0, 1);
                                }    
                            }
                            temp.Add(views[j]);
                        }
                    }
                    for (int j = 0; j < temp.Count(); j++)
                        views.Remove(temp[j]);
                    //if (String.IsNullOrEmpty(item.no_lot))
                    if (String.IsNullOrEmpty(no_lot))
                        item.no_lot = no_niuke;
                    else
                        item.no_lot = no_lot;
                    item.no_niuke = no_niuke;
                    
                    returnValue.Add(item);
                }
                var result = new StoredProcedureResult<usp_GenryoLotToroku_select_Result>();
                result.d = returnValue.OrderBy(v => v.no_kotei).ThenBy(v => v.no_tonyu);
                result.__count = returnValue.Count();

                return result;
            }
            
        }

        private bool isSame(usp_GenryoLotToroku_select_Result a, usp_GenryoLotToroku_select_Result b) {
            if (a.no_kotei == b.no_kotei && a.no_tonyu == b.no_tonyu && a.cd_hinmei == b.cd_hinmei &&
                a != b && ((a.flg_henko != 1 && b.flg_henko != 1) || (a.flg_henko == 1 && b.flg_henko == 1)))
                return true;
            return false;
        }

        // POST api/GenryoLotToroku
        /// <summary>
        /// 
        /// </summary>
        /// <param name="value"></param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody] ChangeSet<GenryoLotTorokuPostCriteria> value)
        {
            string validationMessage = string.Empty;
            if (value == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }
            FoodProcsEntities context = new FoodProcsEntities();
            context.ContextOptions.LazyLoadingEnabled = false;
            using (IDbConnection connection = context.Connection)
            {
                context.Connection.Open();
                using (IDbTransaction transaction = context.Connection.BeginTransaction())
                {
                    try
                    {
                        if (value.Created != null)
                        {
                            for (int i = 0; i < value.Created.Count(); i++)
                            {
                                var item = value.Created[i];
                                createToTrLot(context, item);
                            }
                        }
                        if (value.Updated != null)
                        {
                            for (int i = 0; i < value.Updated.Count(); i++)
                            {
                                var item = value.Updated[i];
                                deleteFromTrLot(context, item.no_lot_shikakari, item.no_kotei, item.no_tonyu, item.cd_hinmei_old);
                                createToTrLot(context, item);
                            }
                        }

                        context.SaveChanges();
                        transaction.Commit();
                    }
                    catch (Exception ex) {
                        transaction.Rollback();
                        Exception serviceError = new Exception(Resources.ServiceErrorForClient, ex);
                        return Request.CreateResponse(HttpStatusCode.BadRequest, serviceError);
                    }
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK);
        }

        private tr_lot_trace setDataTrLotTrace(FoodProcsEntities context, GenryoLotTorokuPostCriteria data)
        {
            ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);
            String noSaiban = context.usp_cm_Saiban(
                ActionConst.GenryoLotChoseiSeqNoSaibanKbn, ActionConst.GenryoLotChoseiSeqNoPrefixSaibanKbn, no_saiban_param).FirstOrDefault<String>();
            tr_lot_trace result = new tr_lot_trace();
            result.no_seq = noSaiban;
            result.no_lot_shikakari = data.no_lot_shikakari;
            result.no_kotei = data.no_kotei;
            result.no_tonyu = data.no_tonyu;
            result.cd_hinmei = data.cd_hinmei;
            result.kbn_hin = data.kbn_hin;
            result.no_niuke = data.no_niuke;
            if(data.flg_henko == true)
                result.flg_henko = 1;
            else
                result.flg_henko = null;
            result.dt_update = DateTime.UtcNow;
            result.cd_update = User.Identity.Name;
            result.dt_create = DateTime.UtcNow;
            result.cd_create = User.Identity.Name;
            result.biko = data.biko;
            return result;
        }

        private void deleteFromTrLot(FoodProcsEntities context, string no_lot_shikakari, decimal no_kotei, decimal no_tonyo, string cd_hinmei)
        {
            var result = context.tr_lot_trace.Where(tr => tr.no_lot_shikakari == no_lot_shikakari &&
                                                          tr.no_kotei == no_kotei &&
                                                          tr.no_tonyu == no_tonyo &&
                                                          tr.cd_hinmei == cd_hinmei).ToList();
            for (int i = 0; i < result.Count(); i++)
            {
                context.tr_lot_trace.DeleteObject(result[i]);
            }
        }

        private void createToTrLot(FoodProcsEntities context, GenryoLotTorokuPostCriteria item)
        {
            string[] no_niuke = item.no_niuke == null ? null : item.no_niuke.Split(',');
            if (no_niuke != null)
            {
                for (int idx = 0; idx < no_niuke.Length; idx++)
                {
                    item.no_niuke = no_niuke[idx];
                    var newData = setDataTrLotTrace(context, item);
                    context.AddTotr_lot_trace(newData);
                }
            }
            else
            {
                var newData = setDataTrLotTrace(context, item);
                context.AddTotr_lot_trace(newData);
            }
        }
    }
}