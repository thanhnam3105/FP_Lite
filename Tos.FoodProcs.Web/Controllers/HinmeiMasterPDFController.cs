using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web.Http.OData;
using System.Web.Http.OData.Query;
using System.Web;
using System.Web.Http;
using System.IO;
using System.Xml.Linq;
using System.Text;
using Tos.FoodProcs.Web.Utilities;
using Tos.FoodProcs.Web.Services;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 品名マスタ登録画面：PDFFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class HinmeiMasterPDFController : ApiController
    {
        // 定数：改行判定用の指定バイト数
        /// <summary>定数：32バイト(全角16文字)</summary>
        private static int BYTE_VAL = 32;

        // Entity取得
        private FoodProcsEntities context = new FoodProcsEntities();

        public HttpResponseMessage Get([FromUri]HinmeiMasterIchiranCriteria criteria, string userName, string uuid, string browseCurrency)
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
                FoodProcsEntities context = new FoodProcsEntities();
                IEnumerable<usp_HinmeiMasterPdf_select_Result> results;
                results = GetEntity(criteria);

                /// 機能選択コントロール
                // 固定日区分
                short kbnKotei = ActionConst.kbn_dt_kotei;
                var Kotei = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == kbnKotei
                            select ma).FirstOrDefault();
                // 納入単位（端数）区分
                short kbnHasu = ActionConst.kbn_tani_nonyu_hasu;
                var Hasu = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == kbnHasu
                            select ma).FirstOrDefault();
                // ロケーション区分
                short kbnLocation = ActionConst.kbn_location;
                var Location = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == kbnLocation
                            select ma).FirstOrDefault();

                short koteiKbn = Kotei.kbn_kino_naiyo;
                short hasuKbn = Hasu.kbn_kino_naiyo;
                short locationKbn = Location.kbn_kino_naiyo;

                // データソースxmlを作成します
                string reportname = "hinmeiMaster";
                string xmlname = reportname + "_" + uuid;
                // xmlnameと並列にノードを作る場合、var nodes で作成する
                XElement root = new XElement("root");
                // 明細情報を作成
                // 出力日
                root.Add(new XElement("output_day", criteria.local_today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(criteria.lang))));
                // 出力者
                root.Add(new XElement("user", userName));
                foreach (usp_HinmeiMasterPdf_select_Result item in results)
                {
                    root.Add(new XElement("cd_hinmei", item.cd_hinmei));
                    root.Add(new XElement("nm_hinmei_ja", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_hinmei_ja, BYTE_VAL)));
                    root.Add(new XElement("nm_hinmei_en", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_hinmei_en, BYTE_VAL)));
                    root.Add(new XElement("nm_hinmei_zh", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_hinmei_zh, BYTE_VAL)));
                    root.Add(new XElement("nm_hinmei_vi", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_hinmei_vi, BYTE_VAL)));
                    root.Add(new XElement("nm_hinmei_ryaku",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_hinmei_ryaku, BYTE_VAL)));
                    root.Add(new XElement("nm_kbn_hin", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_kbn_hin, BYTE_VAL)));
                    root.Add(new XElement("nm_nisugata_hyoji",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_nisugata_hyoji, BYTE_VAL)));
                    root.Add(new XElement("wt_nisugata_naiyo", SetCommmaSplit(item.wt_nisugata_naiyo, 6)));
                    root.Add(new XElement("su_iri", SetCommmaSplit(item.su_iri, 0)));
                    root.Add(new XElement("wt_ko", SetCommmaSplit(item.wt_ko, 6)));

                    // 換算区分：単位区分によって表示を変更する
                    //root.Add(new XElement("nm_kbn_kanzan", ChangedNullToEnSpace(item.nm_kbn_kanzan)));
                    string nmKbnKanzan = FoodProcsCommonUtility.GetKanzanKubunName(context, item.kbn_kanzan);
                    root.Add(new XElement("nm_kbn_kanzan", nmKbnKanzan));

                    root.Add(new XElement("tani_nonyu", ChangedNullToEnSpace(item.tani_nonyu)));
                    root.Add(new XElement("tani_shiyo", ChangedNullToEnSpace(item.tani_shiyo)));
                    root.Add(new XElement("ritsu_hiju", SetCommmaSplit(item.ritsu_hiju, 4)));
                    root.Add(new XElement("tan_ko", SetCommmaSplit(item.tan_ko, 4)));
                    root.Add(new XElement("currency", browseCurrency));
                    root.Add(new XElement("nm_bunrui", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_bunrui, BYTE_VAL)));
                    root.Add(new XElement("dd_shomi", ChangedNullToEnSpace(item.dd_shomi)));
                    root.Add(new XElement("dd_kaifugo_shomi", ChangedNullToEnSpace(item.dd_kaifugo_shomi)));
                    root.Add(new XElement("dd_kaitogo_shomi", ChangedNullToEnSpace(item.dd_kaitogo_shomi)));
                    root.Add(new XElement("nm_hokan", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_hokan, BYTE_VAL)));
                    root.Add(new XElement("nm_kaifugo_hokan",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_kaifugo_hokan, BYTE_VAL)));
                    root.Add(new XElement("nm_kaitogo_hokan",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_kaitogo_hokan, BYTE_VAL)));
                    root.Add(new XElement("nm_kbn_jotai",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_kbn_jotai, BYTE_VAL)));
                    root.Add(new XElement("nm_zei", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_zei, BYTE_VAL)));
                    root.Add(new XElement("ritsu_budomari", SetCommmaSplit(item.ritsu_budomari, 2)));
                    root.Add(new XElement("su_zaiko_min", SetCommmaSplit(item.su_zaiko_min, 6)));
                    root.Add(new XElement("su_zaiko_max", SetCommmaSplit(item.su_zaiko_max, 6)));
                    root.Add(new XElement("nm_niuke", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_niuke, BYTE_VAL)));
                    root.Add(new XElement("dd_leadtime", ChangedNullToEnSpace(item.dd_leadtime)));
                    root.Add(new XElement("flg_mishiyo", GetMishiyoFlag(item.flg_mishiyo)));
                    root.Add(new XElement("dt_create", GetUtcDate(item.dt_create, criteria.lang)));
                    root.Add(new XElement("dt_update", GetUtcDate(item.dt_update, criteria.lang)));
                    root.Add(new XElement("cd_hanbai_1", ChangedNullToEnSpace(item.cd_hanbai_1)));
                    root.Add(new XElement("nm_torihiki1",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_torihiki1, BYTE_VAL)));
                    root.Add(new XElement("cd_hanbai_2", ChangedNullToEnSpace(item.cd_hanbai_2)));
                    root.Add(new XElement("nm_torihiki2",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_torihiki2, BYTE_VAL)));
                    root.Add(new XElement("cd_haigo", ChangedNullToEnSpace(item.cd_haigo)));
                    root.Add(new XElement("nm_haigo", GetHaigoName(criteria.lang, item)));
                    root.Add(new XElement("cd_jan", ChangedNullToEnSpace(item.cd_jan)));
                    root.Add(new XElement("su_batch_dekidaka", SetCommmaSplit(item.su_batch_dekidaka, 2)));
                    root.Add(new XElement("su_palette", SetCommmaSplit(item.su_palette, 0)));
                    root.Add(new XElement("kin_romu", SetCommmaSplit(item.kin_romu, 4)));
                    root.Add(new XElement("kin_keihi_cs", SetCommmaSplit(item.kin_keihi_cs, 4)));
                    root.Add(new XElement("nm_kbn_kuraire",
                        FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_kbn_kuraire, BYTE_VAL)));
                    root.Add(new XElement("tan_nonyu", SetCommmaSplit(item.tan_nonyu, 4)));
                    //root.Add(new XElement("flg_tenkai", GetTenkaiFlag((short)item.flg_tenkai)));
                    root.Add(new XElement("cd_seizo", ChangedNullToEnSpace(item.cd_seizo)));
                    root.Add(new XElement("nm_seizo", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_seizo, BYTE_VAL)));
                    root.Add(new XElement("cd_maker_hin", ChangedNullToEnSpace(item.cd_maker_hin)));
                    root.Add(new XElement("su_hachu_lot_size", SetCommmaSplit(item.su_hachu_lot_size, 2)));
                    root.Add(new XElement("nm_kura", FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(item.nm_kura, BYTE_VAL)));
                    root.Add(new XElement("line_toroku", GetLineToroku(criteria)));
                    root.Add(new XElement("biko", ChangedNullToEnSpace(item.biko)));
                    root.Add(new XElement("kbn_kotei", ChangedNullToEnSpace(koteiKbn)));
                    root.Add(new XElement("dd_kotei", ChangedNullToEnSpace(item.dd_kotei)));
                    root.Add(new XElement("kbn_hasu", ChangedNullToEnSpace(hasuKbn)));
                    root.Add(new XElement("nm_tani_hasu", ChangedNullToEnSpace(item.nm_tani_nonyu_hasu)));
                    root.Add(new XElement("kbn_location", ChangedNullToEnSpace(locationKbn)));
                    root.Add(new XElement("location", ChangedNullToEnSpace(item.location)));
                    root.Add(new XElement("flg_trace_taishogai", GetTaishogaiFlag(item.kbn_hin, item.flg_trace_taishogai)));
                }

                /// save xml
                xmlname = xmlname + ".xml";
                string savepath = PDFUtilities.createSaveXMLPath(xmlname);
                root.Save(savepath);

                /// 出力要求用のXML作成
                /// //Request #480 TOsVN(nt.toan) START
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
                //string today = DateTime.Now.ToString("yyyyMMdd_HHmmss");
                //reportname = reportname + "_" + today + ".pdf";
                string pdfName = Resources.HinmeiMasterIchiranExcel + ".pdf";

                // レスポンスを生成して返します
                return FileDownloadUtility.CreatePDFFileResponse(responseStream, pdfName);
            }
            //catch (HttpResponseException ex)
            //{
            //    Logger.App.Error("http response exception", ex);
            //    throw ex;
            //}
            //catch (Exception e)
            //{
            //    Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
            //    MemoryStream responseStream = new MemoryStream();
            //    // pathの取得
            //    string serverpath = HttpContext.Current.Server.MapPath(".");
            //    using (FileStream fs = File.OpenRead(PDFUtilities.getErrorFile(serverpath, lang)))
            //    {
            //        fs.CopyTo(responseStream);
            //    }
            //    var errorReportname = "ServerError.pdf";
            //    // レスポンスを生成して返します
            //    return FileDownloadUtility.CreateErrorFileResponse(responseStream.ToArray(), errorReportname);
            //}
            catch (HttpResponseException ex)
            {
                throw ex;
            }
            catch (Exception e)
            {
                // エラー時：エラー用のPDFを出力する
                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
                MemoryStream responseStream = new MemoryStream();
                // pathの取得
                string serverpath = PDFUtilities.getJasperURL();
                var errorReportname = "ServerError.pdf";
                // レスポンスを生成して返します
                return FileDownloadUtility.CreatePDFFileResponse(responseStream, errorReportname);

                //throw new HttpResponseException(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>明細データを取得します。</summary>
        /// <param name="criteria">検索条件</param>
        /// <returns>取得した明細データ</returns>
        private IEnumerable<usp_HinmeiMasterPdf_select_Result> GetEntity(
            HinmeiMasterIchiranCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HinmeiMasterPdf_select_Result> views;
            views = context.usp_HinmeiMasterPdf_select(
                criteria.con_hinmei,
                criteria.kbnUriagesaki,
                criteria.kbnSeizomoto,
                criteria.flgShiyo,
                criteria.hanNo
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
                    case 4:
                        // 3桁カンマ区切り＋小数点以下4桁
                        result = String.Format("{0:#,0.0000}", target);
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

        /// <summary>未使用フラグの区分値による区分内容を返します。</summary>
        /// <param name="flgMishiyo">未使用フラグ</param>
        /// <returns>区分内容</returns>
        private String GetMishiyoFlag(short? flgMishiyo)
        {
            if (!flgMishiyo.HasValue || flgMishiyo == short.Parse(Resources.FlagFalse))
            {
                return Resources.Shiyo;
            }
            return Resources.Mishiyo;
        }

        /// <summary>対象外フラグの区分値による区分内容を返します。</summary>
        /// <param name="flgMishiyo">対象外フラグ</param>
        /// <returns>区分内容</returns>
        private String GetTaishogaiFlag(short? kbnHin, short? flgTaishogai)
        {
            string label = " ";
            if (kbnHin.ToString() == Resources.JikaGenryoHinKbn || kbnHin.ToString() == Resources.GenryoHinKbn)
            {
                label = (!flgTaishogai.HasValue || flgTaishogai == short.Parse(Resources.FlagFalse)) ? Resources.Taisho : Resources.Taishogai;
            }

            return label;
        }

        /// <summary>展開フラグの区分値による区分内容を返します。</summary>
        /// <param name="flgTenaki">展開フラグ</param>
        /// <returns>区分内容</returns>
        //private String GetTenkaiFlag(short flgTenaki)
        //{
        //    if (flgTenaki == short.Parse(Resources.FlagTrue))
        //    {
        //        return Resources.Suru;
        //    }
        //    return Resources.Shinai;
        //}

        /// <summary>ライン登録の有無を返します。</summary>
        /// <param name="hinCode">品名コード</param>
        /// <returns>ライン登録の有無</returns>
        private String GetLineToroku(HinmeiMasterIchiranCriteria criteria)
        {
            short masterKbn = ActionConst.HinmeiMasterKbn;
            var ma_seizo_line = (from ma in context.ma_seizo_line
                           where ma.cd_haigo == criteria.con_hinmei
                           && ma.kbn_master == masterKbn
                           && ma.flg_mishiyo == criteria.flgShiyo
                           select ma).FirstOrDefault();
           
            if (ma_seizo_line != null)
            {
                return Resources.Ari;
            }
            return Resources.Nashi;
        }

        /// <summary>多言語対応済みの配合名を返します。</summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="item">検索結果</param>
        /// <returns>多言語に対応した配合名</returns>
        private String GetHaigoName(String lang, usp_HinmeiMasterPdf_select_Result item)
        {
            string nmHaigo;
            if (Resources.LangJa.Equals(lang))
            {
                nmHaigo = item.nm_haigo_ja;  // 日本語
            }
            else if (Resources.LangZh.Equals(lang))
            {
                nmHaigo = item.nm_haigo_zh;  // 中国語
            }
            else if (Resources.LangVi.Equals(lang))
            {
                nmHaigo = item.nm_haigo_vi;  // 中国語
            }
            else
            {
                nmHaigo = item.nm_haigo_en;  // 英語
            }

            return FoodProcsCommonUtility.ChangedNullToEnSpaceAndCheckByte(nmHaigo, BYTE_VAL);
        }

        /// <summary>UTC用に9時間足した日付に変換した値を返します。</summary>
        /// <param name="hinCode">品名コード</param>
        /// <returns>ライン登録の有無</returns>
        private String GetUtcDate(object targetDate, string lang)
        {
            string result = " ";
            if (targetDate != null) {
                DateTime date = (DateTime)targetDate;
                // 9h+
                result = date.AddHours(9).ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
            }
            return result;
        }
    }
}