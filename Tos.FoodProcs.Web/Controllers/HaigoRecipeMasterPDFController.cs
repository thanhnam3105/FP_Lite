using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web;
using System.Web.Http;
using System.IO;
using System.Xml.Linq;
using System.Text;
using Tos.FoodProcs.Web.Utilities;
using Tos.FoodProcs.Web.Services;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Logging;
using System.Web.Http.OData.Query;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 配合レシピ登録：PDFFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class HaigoRecipeMasterPDFController : ApiController
    {
        
        // Entity取得
        private FoodProcsEntities context = new FoodProcsEntities();

        public HttpResponseMessage Get([FromUri]HaigoRecipeMasterCriteria criteria, string uuid, string nm_login)
        {
            System.Globalization.CultureInfo customCulture = (System.Globalization.CultureInfo)System.Threading.Thread.CurrentThread.CurrentCulture.Clone();
            customCulture.NumberFormat.NumberDecimalSeparator = ".";
            customCulture.NumberFormat.NumberGroupSeparator = ",";
            System.Threading.Thread.CurrentThread.CurrentCulture = customCulture;

            try
            {
                // URLの指定
                //Request #480 TOsVN(nt.toan) START
                //var jasperService = new JasperService(PDFUtilities.getJasperURL());
                // アクセス権の譲渡
                //var credentials = new NetworkCredential(PDFUtilities.getJasperUser(), PDFUtilities.getJasperpass());
                //jasperService.Credentials = credentials;
                //Request #480 TOsVN(nt.toan) END

                // 表示する項目を取得し、jrxmlのデータソースとなるXML生成を行います
                // entityにアクセスします
                FoodProcsEntities context = new FoodProcsEntities();
                IEnumerable<usp_HaigoRecipeMaster_select_02_Result> results =
                    GetEntity(criteria.cd_haigo, criteria.no_han, criteria.no_kotei);

                // 機能選択：単位区分を取得
                string kbnTani = ActionConst.kbn_tani_Kg_L;
                var cn_kbnTani = (from ma in context.cn_kino_sentaku
                                  where ma.kbn_kino == ActionConst.kbn_kino_kbn_tani
                                  select ma).FirstOrDefault();
                if (cn_kbnTani != null)
                {
                    kbnTani = cn_kbnTani.kbn_kino_naiyo.ToString();
                }

                // 機能選択から運転登録表示切替区分を取得する
                short kbnPlc = (from tr in context.cn_kino_sentaku
                                where tr.kbn_kino == ActionConst.kbn_plc_hyoji
                                select tr.kbn_kino_naiyo).FirstOrDefault();

                string kanzan_kg = ActionConst.KanzanNameKg;
                string kanzan_Li = ActionConst.KanzanNameLi;
                // 単位区分が「LB・GAL」の場合
                if (ActionConst.kbn_tani_LB_GAL.Equals(kbnTani))
                {
                    kanzan_kg = ActionConst.KanzanNameLb;
                    kanzan_Li = ActionConst.KanzanNameGal;
                }

                // データソースxmlを作成します
                string reportname = "mixtureReciptResistor";
                
                // 運転登録表示区分が1の場合
                if (kbnPlc == ActionConst.plc_hyoji_true)
                {
                    // 出力するxmlファイルのパスを変更する
                    reportname += "_plc";
                }

                string xmlname = reportname + "_" + uuid;

                // xmlnameと並列にノードを作る場合、var nodes で作成する
                XElement root = new XElement("root");

                // ヘッダー情報を作成
                root.Add(new XElement("cd_haigo", criteria.cd_haigo));
                root.Add(new XElement("nm_haigo", ChangedNullToEnSpace(criteria.nm_haigo)));
                root.Add(new XElement("nm_kbn_hin", Resources.ShikakariHin));
                root.Add(new XElement("nm_bunrui", ChangedNullToEnSpace(criteria.nm_bunrui)));
                root.Add(new XElement("wt_saidai_shikomi", SetCommmaSplit(criteria.wt_haigo_gokei, 6)));
                root.Add(new XElement("chomi_label", SetCommmaSplit(criteria.wt_kowake, 6)));
                root.Add(new XElement("chomi_maisu", SetCommmaSplit(criteria.su_kowake, 0)));
                root.Add(new XElement("no_han", criteria.no_han));
                root.Add(new XElement("no_kotei", criteria.no_kotei));
                root.Add(new XElement("no_seiho", ChangedNullToEnSpace(criteria.no_seiho)));
                root.Add(new XElement("biko", criteria.biko));
                root.Add(new XElement("dt_from", criteria.dt_from));
                root.Add(new XElement("nm_tanto_hinkan", ChangedNullToEnSpace(criteria.nm_tanto_hinkan)));
                root.Add(new XElement("dt_hinkan_koshin", ChangedNullToEnSpace(criteria.dt_hinkan_koshin)));
                root.Add(new XElement("nm_tanto_seizo", ChangedNullToEnSpace(criteria.nm_tanto_seizo)));
                root.Add(new XElement("dt_seizo_koshin", ChangedNullToEnSpace(criteria.dt_seizo_koshin)));

                // ユーザー情報を取得する
                UserController user = new UserController();
                UserInfo userInfo = user.Get();
                if (ActionConst.kbn_tani_LB_GAL == userInfo.kbn_tani)
                {
                    root.Add(new XElement("nm_tani", "LB"));
                }
                else
                {
                    root.Add(new XElement("nm_tani", "Kg"));
                }

                // 出力者
                root.Add(new XElement("nm_login", ChangedNullToEnSpace(nm_login)));
                // 出力日
                string today = criteria.local_today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(criteria.lang));
                root.Add(new XElement("output_day", today));
                // 未使用フラグ：使用の場合は空白、未使用の場合は「未使用」
                if (criteria.flg_mishiyo == Resources.FlagFalse)
                {
                    root.Add(new XElement("flg_mishiyo", Resources.Shiyo));
                }
                else
                {
                    root.Add(new XElement("flg_mishiyo", Resources.Mishiyo));
                }
                foreach (usp_HaigoRecipeMaster_select_02_Result list in results)
                {
                    string nmKbnKanzan = kanzan_kg;  // デフォルト：Kg
                    if (ActionConst.LKanzanKbn.Equals(list.kbn_kanzan))
                    {
                        // 換算区分が「11：L」の場合
                        nmKbnKanzan = kanzan_Li;
                    }

                    var nodes = new XElement("nodes",
                        new XElement("no_tonyu", list.no_tonyu),
                        new XElement("cd_hinmei", list.cd_hinmei),
                        new XElement("nm_hinmei", ChangedNullToEnSpace(list.nm_hinmei)),
                        new XElement("nm_hinmei_mix", list.cd_hinmei + System.Environment.NewLine + ChangedNullToEnSpace(list.nm_hinmei)),
                        new XElement("mark", ChangedNullToEnSpace(list.mark)),
                        new XElement("wt_haigo", SetCommmaSplit(list.wt_shikomi, 6)),
                        //new XElement("nm_tani_shiyo", ChangedNullToEnSpace(list.nm_tani_shiyo)),
                        new XElement("nm_tani_shiyo", ChangedNullToEnSpace(nmKbnKanzan)),
                        new XElement("wt_nisugata", SetCommmaSplit(list.wt_nisugata, 6)),
                        new XElement("su_nisugata", SetCommmaSplit(list.su_nisugata, 0)),
                        new XElement("wt_kowake", SetCommmaSplit(list.wt_kowake, 6)),
                        new XElement("su_kowake", SetCommmaSplit(list.su_kowake, 0)),
                        new XElement("ritsu_budomari", list.ritsu_budomari),
                        new XElement("ritsu_hiju", list.ritsu_hiju),
                        new XElement("su_settei", SetCommmaSplit(list.su_settei, 3)),
                        new XElement("su_settei_max", SetCommmaSplit(list.su_settei_max, 3)),
                        new XElement("su_settei_min", SetCommmaSplit(list.su_settei_min, 3)),
                        new XElement("nm_futai", ChangedNullToEnSpace(list.nm_futai)),
                        new XElement("nm_plc", ChangedNullToEnSpace(list.nm_komoku))
                    );
                    root.Add(nodes);
                }

                /// save xml
                xmlname = xmlname + ".xml";
                string savepath = PDFUtilities.createSaveXMLPath(xmlname);
                root.Save(savepath);

                /// 出力要求用のXML作成
                //Request #480 TOsVN(nt.toan) START
                //string requestXML = PDFUtilities.createRequestXML(reportname, xmlname, criteria.lang);
                string linkAPIDownloadPDF = PDFUtilities.GetLinkAPI(reportname, xmlname, criteria.lang);
                //Request #480 TOsVN(nt.toan) END

                /// Jasper Server への POST(SOAP)
                //Request #480 TOsVN(nt.toan) START
                //jasperService.runReport(requestXML);
                //var attachment = jasperService.ResponseSoapContext.Attachments;
                //Request #480 TOsVN(nt.toan) END

                /// JasperServerからのRESPONSE				
                /// PDFファイルが返却されるので、Streamに入れる
                MemoryStream responseStream = new MemoryStream();
                //Request #480 TOsVN(nt.toan) START
                responseStream = PDFUtilities.GetStreamFromUrl(linkAPIDownloadPDF);
                //if (attachment.Count > 0)
                //{
                //    var attach = attachment[0];
                //    var attachStream = attach.Stream;
                //    attachStream.CopyTo(responseStream);
                //}
                //else
                //{
                    // jasper からのレスポンスなし
                    //using (FileStream fs = File.OpenRead(PDFUtilities.getErrorFile(lang)))
                    //{
                    //    fs.CopyTo(responseStream);
                    //}
                //}
                //Request #480 TOsVN(nt.toan) END
                responseStream.Position = 0;

                /// レポートの取得
                string pdfName = Resources.HaigoRecipeMasterPdf + ".pdf";
                // レスポンスを生成して返します
                return FileDownloadUtility.CreatePDFFileResponse(responseStream, pdfName);
            }
            catch (Exception e)
            {
                // 例外用PDFを返却
                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
                MemoryStream responseStream = new MemoryStream();
                // pathの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                using (FileStream fs = File.OpenRead(PDFUtilities.getErrorFile(serverpath, criteria.lang)))
                {
                    fs.CopyTo(responseStream);
                }
                var errorReportname = "ServerError.pdf";
                // レスポンスを生成して返します
                return FileDownloadUtility.CreateErrorFileResponse(responseStream.ToArray(), errorReportname);
            }
        }

        /// <summary>
        /// 明細データを取得します。
        /// </summary>
        /// <param name="cd_haigo">配合コード</param>
        /// <param name="no_han">版番号</param>
        /// <param name="no_kotei">工程番号</param>
        /// <returns>明細データ</returns>
        private IEnumerable<usp_HaigoRecipeMaster_select_02_Result> GetEntity(
            string cd_haigo, decimal no_han, decimal no_kotei)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HaigoRecipeMaster_select_02_Result> views;
            views = context.usp_HaigoRecipeMaster_select_02(
                    cd_haigo,
                    no_han,
                    no_kotei,
                    ActionConst.HanNoShokichi
                ).AsEnumerable();

            return views;
        }
 
        /// <summary>nullまたは空文字の場合、半角スペースに変換します。</summary>
        /// <param name="value">判定したい値</param>
        /// <returns>判定結果</returns>
        private String ChangedNullToEnSpace(object value)
        {
            // nullまたは空文字の場合、半角スペースに変換する
            if (value == null || value.ToString() == "")
            {
                return " ";
            }
            return value.ToString();
        }

        /// <summary>3桁カンマ区切り＋小数点以下を指定の桁数で固定した値を返却します。</summary>
        /// <param name="value">カンマ区切りにする値</param>
        /// <param name="cnt">小数点以下の桁数</param>
        /// <returns>変換後の値</returns>
        private String SetCommmaSplit(object value, int cnt)
        {
            string result = " ";
            if (value != null)
            {
                decimal target = (decimal)value;

                // 小数点以下の桁数は画面の仕様によって増やしていく
                switch (cnt)
                {
                    case 2:
                        // 3桁カンマ区切り＋小数点以下2桁
                        result = String.Format("{0:#,0.00}", target);
                        break;
                    case 3:
                        // 3桁カンマ区切り＋小数点以下3桁
                        result = String.Format("{0:#,0.000}", target);
                        break;
                    case 6:
                        // 3桁カンマ区切り＋小数点以下6桁
                        result = String.Format("{0:#,0.000000}", target);
                        break;
                    default:
                        // 3桁カンマ区切り＋小数点以下0桁
                        result = String.Format("{0:#,0}", target);
                        break;
                }
            }

            return result;
        }
   }
}