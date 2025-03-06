using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web.Http;
using System.IO;
using System.Xml.Linq;
using System.Text;
using Tos.FoodProcs.Web.Utilities;
using Tos.FoodProcs.Web.Services;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using System.Web.Http.OData.Query;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>帳票用明細：セッター・ゲッタークラス</summary>
    class NonyuInfo
    {
        public string holiday { get; set; }
        public string date { get; set; }
        public string change { get; set; }
        public string suryo { get; set; }
    }
    /// <summary>帳票用ヘッダー：セッター・ゲッタークラス</summary>
    class NonyuHeaderInfo
    {
        public string hachuNo { get; set; }
        public string dateFrom { get; set; }
        public string dateTo { get; set; }
        public string loginKaishaCode { get; set; }
        public string loginKojoCode { get; set; }
        public string renrakusaki { get; set; }
        public string renrakusakiTel { get; set; }
        public string renrakusakiFax { get; set; }
        public string nohinsaki { get; set; }
        public string nohinsakiAddress { get; set; }
        public string torihikisaki { get; set; }
        public string keishikiKubun { get; set; }
        public string comment { get; set; }
        public string kaishaName { get; set; }
        public string tantosha { get; set; }
        public string keisho { get; set; }
        public string torihikisakiFax { get; set; }
    }

    /// <summary>
    /// 納入依頼書リスト：PDFFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class NonyuIraishoListPDFController : ApiController
    {
        // 定数：XMLノード名
        /// <summary>定数：XMLノード名：root</summary>
        private string ROOT = "root";
        /// <summary>定数：XMLノード名：pageBreak</summary>
        private string PAGE_BREAK = "pageBreak";
        /// <summary>定数：XMLノード名：nodes</summary>
        private string NODES = "nodes";
        
        // 合計行用のグローバル的な変数
        /// <summary>合計行：数量</summary>
        private decimal TotalSuryo = 0;
        /// <summary>合計行：重量</summary>
        private decimal TotalJuryo = 0;
        /// <summary>検索結果のレコード数</summary>
        private int ResultCount = 0;

        // 発注番号取得時の判定用ブレイクキー
        /// <summary>発注番号取得時の判定用：取引先コード</summary>
        private string TorihikiCode = "";
        /// <summary>発注番号取得時の判定用：荷受コード</summary>
        private string NiukeCode = "";

        /// <summary>UTC用9h足した定数</summary>
        private int AddHours = 9;

        // Entity取得
        private FoodProcsEntities context = new FoodProcsEntities();
        
        /// <param name="criteria">検索情報</param>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="uuid">ユニークID</param>
        /// <param name="printType">印刷種別</param>
        /// <param name="maxPages">出力できる最大ページ数</param>
        /// <param name="maxColumn">1ページに出力する列数</param>
        public HttpResponseMessage Get([FromUri]NonyuIraishoPdfCriteria criteria,
            string lang, string uuid, string printType, int maxPages, int maxColumn)
        {
            System.Globalization.CultureInfo customCulture = (System.Globalization.CultureInfo)System.Threading.Thread.CurrentThread.CurrentCulture.Clone();
            customCulture.NumberFormat.NumberDecimalSeparator = ".";
            customCulture.NumberFormat.NumberGroupSeparator = ",";
            System.Threading.Thread.CurrentThread.CurrentCulture = customCulture;

            try
            {
                // 作成開始日～31日分の日付を取得する
                List<NonyuInfo> dateList = GetHeaderDate(criteria.dateFrom, criteria.dateTo, criteria.lang, criteria.langCountry);

                // パラメーターを帳票用ヘッダーのセッター・ゲッタークラスに設定
                NonyuHeaderInfo headerInfo = SetNonyuHeaderInfo(criteria, lang);

                // URLの指定
                //Request #480 TOsVN(nt.toan) START
                //var jasperService = new JasperService(PDFUtilities.getJasperURL());
                // アクセス権の譲渡
                //var credentials = new NetworkCredential(PDFUtilities.getJasperUser(), PDFUtilities.getJasperpass());
                //jasperService.Credentials = credentials;
                //Request #480 TOsVN(nt.toan) END

                // 表示する項目を取得し、jrxmlのデータソースとなるXML生成を行います

                // データソースxmlを作成します
                string reportname = "nonyuIraisho";
                if (maxColumn == 2)
                {
                    // 1ページに出力する列数が2(A4縦)の場合、2列用のテンプレートを使用する
                    reportname = reportname + "_tate";
                }
                string xmlname = reportname + "_" + uuid;
                XElement root = new XElement(ROOT);

			    // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			    context.ContextOptions.LazyLoadingEnabled = false;

                // 明細情報の取得
                IEnumerable<usp_NonyuIraishoListPdf_select_Result> results;
                results = GetMeisai(criteria, printType);
                // 並び替え
                results = OrderByResult(results);

                // 出力日の設定
                root.Add(new XElement("output_day", criteria.local_today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang))));

                // 明細XML作成処理
                root = CreateMeisaiXml(root, results, headerInfo, dateList, lang, criteria, printType, maxPages, maxColumn);

                /// save xml
                xmlname = xmlname + ".xml";
                string savepath = PDFUtilities.createSaveXMLPath(xmlname);
                root.Save(savepath);

                /// 出力要求用のXML作成
                /// //Request #480 TOsVN(nt.toan) START
                //string requestXML = PDFUtilities.createRequestXML(reportname, xmlname, lang);
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
                    // PDFUtilitiesにgetErrorFile無し。コメントアウトしておきます。2013.09.24
                    // jasper からのレスポンスなし
                    //using (FileStream fs = File.OpenRead(PDFUtilities.getErrorFile(lang))) {
                    //    fs.CopyTo(responseStream);
                    //}
                //}
                //Request #480 TOsVN(nt.toan) END
                responseStream.Position = 0;

                /// レポートの取得
                string pdfName = Resources.NonyuIraishoPdf + ".pdf";

			    // トランザクションを開始し、エンティティの変更をデータベースに反映します。
			    // 更新処理に失敗した場合、例外が発生し、トランザクションは暗黙的にロールバックされます。
			    // 個別でチェック処理を行いロールバックを行う場合には明示的に
			    // IDbTransaction インタフェースの Rollback メソッドを呼び出します。
                using (IDbConnection connection = context.Connection)
                {
                    context.Connection.Open();
                    using (IDbTransaction transaction = context.Connection.BeginTransaction())
                    {
                        try
                        {
                            context.SaveChanges();
                            transaction.Commit();
                        }
                        catch (OptimisticConcurrencyException oex)
                        {
                            // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
                            // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                            Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                            return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                        }
                    }
                }
                
                // レスポンスを生成して返します
                return FileDownloadUtility.CreatePDFFileResponse(responseStream, pdfName);
            }
            catch (HttpResponseException ex)
            {
                Logger.App.Error("http response exception", ex);
                throw ex;
            }
            catch (Exception e)
            {
                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
                MemoryStream responseStream = new MemoryStream();
                // pathの取得
                //string serverpath = PDFUtilities.Current.Server.MapPath(".");
                string serverpath = PDFUtilities.getJasperURL();
                //using (FileStream fs = File.OpenRead(PDFUtilities.getErrorFile(serverpath, lang)))
                //{
                //    fs.CopyTo(responseStream);
                //}
                var errorReportname = "ServerError.pdf";
                // レスポンスを生成して返します
                //return FileDownloadUtility.CreateErrorFileResponse(responseStream.ToArray(), errorReportname);                
                return FileDownloadUtility.CreatePDFFileResponse(responseStream, errorReportname);
            }
        }


        /// <summary>帳票用ヘッダー：セッター・ゲッタークラスにパラメーターを設定します。</summary>
        /// <param name="criteria">ヘッダー情報</param>
        /// <returns>帳票用ヘッダー情報</returns>
        private NonyuHeaderInfo SetNonyuHeaderInfo(NonyuIraishoPdfCriteria criteria, string lang) {

            // UTCで日付が前日になっているので、日にちを1日進める
            //DateTime dtFrom = criteria.dateFrom.AddDays(1);
            //DateTime dtTo = criteria.dateTo.AddDays(1);
            // UTC関係なく10時固定となったため、日にちを進める必要はなくなりました(2015.02.19)
            DateTime dtFrom = criteria.dateFrom;
            DateTime dtTo = criteria.dateTo;

            // 帳票用ヘッダー情報の設定
            NonyuHeaderInfo headerInfo = new NonyuHeaderInfo();
            headerInfo.hachuNo = ChangedNullToEmpty(criteria.hachuNo);
            headerInfo.dateFrom = dtFrom.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
            headerInfo.dateTo = dtTo.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
            headerInfo.loginKaishaCode = ChangedNullToEmpty(criteria.cdLoginKaisha);
            headerInfo.loginKojoCode = ChangedNullToEmpty(criteria.cdLoginKojo);
            headerInfo.renrakusaki = ChangedNullToEmpty(criteria.renrakusaki);
            headerInfo.renrakusakiTel = ChangedNullToEmpty(criteria.renTel);
            headerInfo.renrakusakiFax = ChangedNullToEmpty(criteria.renFax);
            headerInfo.nohinsaki = ChangedNullToEmpty(criteria.nohinsaki);
            headerInfo.nohinsakiAddress = ChangedNullToEmpty(criteria.nohinsakiAdd);
            headerInfo.torihikisaki = ChangedNullToEmpty(criteria.torihikisaki);
            headerInfo.keishikiKubun = ChangedNullToEmpty(criteria.kbnKeishiki);
            headerInfo.comment = ChangedNullToEmpty(criteria.comment);
            headerInfo.kaishaName = ChangedNullToEmpty(criteria.kaishaName);
            return headerInfo;
        }

        /// <summary>ヘッダー情報を設定します。</summary>
        /// <param name="pageBreak">1ページ分の帳票XML</param>
        /// <param name="headerInfo">ヘッダー情報</param>
        /// <param name="pageCount">現在のページ数</param>
        /// <returns>ヘッダー情報を設定した1ページ分の帳票XML</returns>
        private XElement SetHeaderXml(XElement pageBreak, NonyuHeaderInfo headerInfo, int pageCount)
        {
            pageBreak.Add(new XElement("hachuNo", headerInfo.hachuNo));
            pageBreak.Add(new XElement("searchDateFrom", headerInfo.dateFrom));
            pageBreak.Add(new XElement("searchDateTo", headerInfo.dateTo));
            pageBreak.Add(new XElement("kaishaName", headerInfo.kaishaName));
            pageBreak.Add(new XElement("renrakusaki", headerInfo.renrakusaki));
            pageBreak.Add(new XElement("renrakusakiTel", headerInfo.renrakusakiTel));
            pageBreak.Add(new XElement("renrakusakiFax", headerInfo.renrakusakiFax));
            pageBreak.Add(new XElement("nohinsaki", headerInfo.nohinsaki));
            pageBreak.Add(new XElement("nohinsakiAdd", headerInfo.nohinsakiAddress));
            pageBreak.Add(new XElement("torihikisaki", headerInfo.torihikisaki));
            pageBreak.Add(new XElement("tantosha", headerInfo.tantosha));
            pageBreak.Add(new XElement("keisho", headerInfo.keisho));
            pageBreak.Add(new XElement("torihikisakiFax", headerInfo.torihikisakiFax));
            pageBreak.Add(new XElement("keishikiKbn", headerInfo.keishikiKubun));
            pageBreak.Add(new XElement("comment", headerInfo.comment));  // フッター部分に表示

            return pageBreak;
        }

        /// <summary>作成開始日～31日分の日付をカレンダーマスタから取得します。</summary>
        /// <param name="dateFrom">開始日</param>
        /// <param name="dateTo">終了日</param>
        /// <returns>日付リスト</returns>
        private List<NonyuInfo> GetHeaderDate(DateTime dateFrom, DateTime dateTo, string lang, string langCountry)
        {
            //DateTime dtFrom = dateFrom.AddDays(1);
            //DateTime dtTo = dateTo.AddDays(1);
            string dateFormat;
            // 多言語対応
            if (lang == Resources.LangJa || lang == Resources.LangZh || langCountry == Resources.LangEnUs)
            {
                dateFormat = Resources.MonthDay; // MM/dd(曜日)にする
            }
            else
            {
                dateFormat = Resources.DayMonth;// dd/MM(曜日)にする
            }

            List<NonyuInfo> dateList = new List<NonyuInfo>();
            IEnumerable<ma_calendar> master = (from ma in context.ma_calendar
                               where ma.dt_hizuke >= dateFrom
                               && ma.dt_hizuke <= dateTo
                               select ma).AsEnumerable();
            foreach (ma_calendar cal in master)
            {
                NonyuInfo entity = new NonyuInfo();
                DateTime hizuke = cal.dt_hizuke.AddHours(9);    // +9h
                entity.date = hizuke.ToString(dateFormat) + " "; // 月/日(曜日)
                // 休日フラグが「休日(true)」なら○を設定する
                if (ActionConst.FlagTrue.Equals(cal.flg_kyujitsu))
                {
                    entity.holiday = ActionConst.FlgKyujitsuPdf + " ";
                }
                else
                {
                    entity.holiday = " ";
                }
                dateList.Add(entity);
            }
            return dateList;
        }

        /// <summary>0列目の作成処理</summary>
        /// <param name="pageBreak">1ページ分の帳票XML</param>
        /// <param name="headerInfo">ヘッダー情報</param>
        /// <param name="niukeCode">荷受場所コード</param>
        /// <param name="torihikiCode">取引先コード</param>
        /// <param name="dateList">31日分の日付情報</param>
        /// <param name="pageCount">現在のページ数</param>
        /// <param name="printType">印刷種別</param>
        /// <returns>0列目の作成が終わった1ページ分の帳票XML</returns>
        private XElement CreateFirstRow(XElement pageBreak, NonyuHeaderInfo headerInfo,
            string niukeCode, string torihikiCode, List<NonyuInfo> dateList, int pageCount, string printType)
        {
            // 取引先コードまたは荷受場所コードが変わっていれば、ヘッダー情報を取得しなおす
            if (TorihikiCode != torihikiCode || NiukeCode != niukeCode)
            {
                //if (String.IsNullOrEmpty(headerInfo.hachuNo) || pageCount > 1)
                if ((ActionConst.NonyuIraishoPrintTypeAllPrint.Equals(printType)
                    || ActionConst.NonyuIraishoPrintTypeSelectAllPrint.Equals(printType)) || pageCount > 1)
                {
                    // 印刷種別が「指定印刷」時のみ、1ページ目は画面の発注番号を使用するので採番処理は不要
                    headerInfo.hachuNo = GetHachuNumber(torihikiCode, headerInfo);
                }
                // 取引先情報の設定
                headerInfo = SetTorihikiInfo(torihikiCode, headerInfo);
                // 納品先情報の設定
                SetNohinsakiInfo(niukeCode, headerInfo);
            }
            // ヘッダー情報XMLの作成
            pageBreak = SetHeaderXml(pageBreak, headerInfo, pageCount);

            // フォーマット(項目名、日付列＋明細列5つ)を作成
            pageBreak = CreateFormatDetail(pageBreak, dateList, pageCount);

            return pageBreak;
        }

        /// <summary>明細データ取得処理</summary>
        /// <param name="criteria">検索条件</param>
        /// <param name="printType">印刷種別</param>
        /// <returns>検索結果</returns>
        private IEnumerable<usp_NonyuIraishoListPdf_select_Result> GetMeisai(
            NonyuIraishoPdfCriteria criteria, string printType)
        {
            short yotei = 0;
            short mishiyoFlgShiyo = ActionConst.FlagFalse;
            string torihikisakiCode = ChangedNullToEmpty(criteria.torihikiCode);

            // 印刷種別が「指定印刷」の場合
            if (!ActionConst.NonyuIraishoPrintTypeAllPrint.Equals(printType)
                && !ActionConst.NonyuIraishoPrintTypeSelectAllPrint.Equals(printType))
            {
                // 画面．検索条件/取引先コードを設定する
                torihikisakiCode = criteria.torihikisaki;
            }

            // 「予定なしの品目も出力する」にチェックが入っていた場合
            if (criteria.yotei)
            {
                yotei = 1;
            }

            // 明細情報の取得処理
            IEnumerable<usp_NonyuIraishoListPdf_select_Result> result;
            result = context.usp_NonyuIraishoListPdf_select(
                criteria.dateFrom,
                criteria.dateTo,
                criteria.sysdate,
                yotei,
                ActionConst.YoteiYojitsuFlag,
                ActionConst.JissekiYojitsuFlag,
                mishiyoFlgShiyo,
                torihikisakiCode,
                ChangedNullToEmpty(criteria.hinCode),
                ActionConst.KgKanzanKbn,
                ActionConst.LKanzanKbn
            ).AsEnumerable();

            return result;
        }

        /// <summary>
        /// 並び替え処理。引数のデータを次の順に並び替える。
        /// 取引先コード＞荷受場所コード＞分類コード＞品名コード
        /// </summary>
        /// <param name="data">検索結果</param>
        /// <returns>並び替え結果</returns>
        private IEnumerable<usp_NonyuIraishoListPdf_select_Result> OrderByResult(
            IEnumerable<usp_NonyuIraishoListPdf_select_Result> data)
        {
            IEnumerable<usp_NonyuIraishoListPdf_select_Result> result;
            
            // レコード数を取得
            List<usp_NonyuIraishoListPdf_select_Result> list
                = data.ToList<usp_NonyuIraishoListPdf_select_Result>();
            ResultCount = list.Count;

            // 並び替え(取引先コード＞荷受場所コード＞分類コード＞品名コード)
            result = list.OrderBy(key1 => key1.cd_torihiki).ThenBy(
                key2 => key2.cd_niuke_basho).ThenBy(key3 => key3.cd_bunrui).ThenBy(key4 => key4.cd_hinmei);

            return result;
        }

        /// <summary>明細XML作成処理</summary>
        /// <param name="root">XML情報</param>
        /// <param name="result">検索結果</param>
        /// <param name="headerInfo">ヘッダー情報</param>
        /// <param name="dateList">日付リスト</param>
        /// <param name="lang">言語情報</param>
        /// <param name="criteria">検索情報</param>
        /// <param name="printType">印刷種別</param>
        /// <param name="maxPages">出力できる最大ページ数</param>
        /// <param name="maxColumn">1ページに出力する列数</param>
        /// <returns>明細XML</returns>
        private XElement CreateMeisaiXml(XElement root, IEnumerable<usp_NonyuIraishoListPdf_select_Result> result,
            NonyuHeaderInfo headerInfo, List<NonyuInfo> dateList, string lang, NonyuIraishoPdfCriteria criteria,
            string printType, int maxPages, int maxColumn)
        {
            int pageCount = 1;
            int rowCount = 0;
            bool newPageFlg = false;
            bool startPageFlg = true;
            string beforeTorihikiCode = ""; // 比較用変数：取引コード
            string beforeHinmeiCode = "";   // 比較用変数：品名コード
            int dataCount = 0;  // 現在の明細行数
            XElement pageBreak = new XElement(PAGE_BREAK);

            foreach (usp_NonyuIraishoListPdf_select_Result data in result)
            {
                // ★ページ数の上限チェック
                if (pageCount > maxPages)
                {
                    break;
                }

                // ページ始めの初期処理
                if (startPageFlg)
                {
                    rowCount = 1;

                    string niukeCode = data.cd_niuke_basho;
                    if (!String.IsNullOrEmpty(criteria.niukeCode))
                    {   // 画面で指定された荷受場所コードがある場合、それを使用する
                        niukeCode = criteria.niukeCode;
                    }

                    // 0列目の作成
                    pageBreak = CreateFirstRow(
                        pageBreak, headerInfo, niukeCode, data.cd_torihiki, dateList, pageCount, printType);
                    // 明細ヘッダーの設定
                    pageBreak = SetMeisaiHeaderXML(lang, pageBreak, data, rowCount, pageCount);

                    TorihikiCode = data.cd_torihiki;
                    NiukeCode = niukeCode;
                    beforeTorihikiCode = data.cd_torihiki;
                    beforeHinmeiCode = data.cd_hinmei;
                    startPageFlg = false;
                }

                // 品コードが変わった場合、次の列へ
                if (!beforeHinmeiCode.Equals(data.cd_hinmei))
                {
                    // 合計行の設定
                    pageBreak = SetMeisaiTotalXML(pageBreak, rowCount, pageCount);
                    TotalSuryo = 0;
                    TotalJuryo = 0;

                    // 列カウントが最終列だった場合、改ページ
                    if (rowCount == maxColumn)
                    {
                        newPageFlg = true;
                    }
                    else
                    {
                        // 次の列へ
                        rowCount++;
                        beforeHinmeiCode = data.cd_hinmei;
                        // 明細ヘッダーの設定
                        pageBreak = SetMeisaiHeaderXML(lang, pageBreak, data, rowCount, pageCount);
                    }
                }
                // 明細情報作成処理
                pageBreak = SetMeisaiNodesXML(pageBreak, data, rowCount, pageCount, criteria.lang, criteria.langCountry);

                // 作成画面で「分類毎に改頁する」にチェックが入っていた場合
                // ただし、最終レコードの場合は判定しない
                if (criteria.bunrui && ResultCount > (dataCount + 1))
                {
                    usp_NonyuIraishoListPdf_select_Result nextData = result.ElementAt(dataCount + 1);
                    if (data.cd_bunrui != nextData.cd_bunrui)
                    {
                        // 次の明細で分類コードが変わる場合、改ページする
                        newPageFlg = true;
                    }
                }

                // 次の明細をチェック
                if (!newPageFlg)
                {
                    newPageFlg = CheckNextMeisai(result, data,
                        beforeTorihikiCode, criteria.niukeCode, criteria.bunrui, dataCount);
                }

                // 改ページ処理
                if (newPageFlg)
                {
                    // 合計行の設定
                    pageBreak = SetMeisaiTotalXML(pageBreak, rowCount, pageCount);
                    TotalSuryo = 0;
                    TotalJuryo = 0;

                    // 改ページ処理
                    root.Add(pageBreak);
                    pageCount++;
                    newPageFlg = false;
                    startPageFlg = true;
                    pageBreak = new XElement(PAGE_BREAK);
                }
                dataCount++;
            }

            // 初期処理フラグがtrueの場合は改ページ処理でrootへの設定が終わっているのでこの処理は不要
            if (!startPageFlg)
            {
                // 合計行の設定
                pageBreak = SetMeisaiTotalXML(pageBreak, rowCount, pageCount);
                // 明細XMLをrootに設定
                root.Add(pageBreak);
            }

            return root;
        }

        /// <summary>明細情報をXMLノードに設定します。</summary>
        /// <param name="pageBreak">1ページ分の帳票XML</param>
        /// <param name="result">明細情報</param>
        /// <param name="row">現在の列番号</param>
        /// <param name="pageCount">現在のページ数</param>
        /// <returns>明細情報を設定した1ページ分の帳票XML</returns>
        private XElement SetMeisaiNodesXML(XElement pageBreak, usp_NonyuIraishoListPdf_select_Result result, int row, int pageCount, string lang, string langCountry) {
            var nodes = pageBreak.Elements(NODES).Attributes("page" + pageCount);
            foreach (XAttribute node in nodes)
            {
                var data = node.Parent;
                String dateVal = data.Element("date").Value;
                if (!String.IsNullOrEmpty(dateVal))
                {
                    dateVal = dateVal.Replace(" ", ""); // 空白除去
                    if (dateVal != "")
                    {
                        String xmlDate = data.Element("date").Value.Substring(0, 5);        // MM/ddまたはdd/MMにする
                        DateTime hizuke = (DateTime)result.dt_hizuke;
                        String resultDate;
                        // 多言語対応
                        if (lang == Resources.LangJa || lang == Resources.LangZh || langCountry == Resources.LangEnUs)
                        {
                            resultDate = hizuke.AddHours(AddHours).ToString(Resources.MonthDay).Substring(0, 5); // MM/ddにする
                        }
                        else
                        {
                            resultDate = hizuke.AddHours(AddHours).ToString(Resources.DayMonth).Substring(0, 5); // dd/MMにする                            
                        }                         
                        // 日付が一致する行へデータを入れる
                        if (xmlDate.Equals(resultDate))
                        {
                            // 「数量（重量）」
                            //String strSuryo = String.Format("{0:#,0}", result.su_nonyu); // 3桁カンマ区切り
                            String strSuryo = String.Format("{0:#,0.00}", result.su_nonyu); // 3桁カンマ区切り＋小数点以下2桁固定
                            String strJuryo = String.Format("{0:#,0.000}", result.juryo);    // 3桁カンマ区切り＋小数点以下3桁固定
                            String suryo = strSuryo + ActionConst.NonyuIraishoPdfBracketStart + strJuryo + ActionConst.NonyuIraishoPdfBracketEnd;
                            String change = Resources.NonyuIraishoPdfChange;    // デフォルト値：変更
                            // 合計
                            TotalSuryo += result.su_nonyu == null ? 0 : (decimal)result.su_nonyu;
                            TotalJuryo += result.juryo == null ? 0 : (decimal)result.juryo;

                            // 変更情報の判定処理
                            if (result.su_nonyu == result.su_nonyu_wo)
                            {
                                // トラン納入数 = ワーク納入数の場合：空白
                                change = "    ";
                            }
                            else if (result.su_nonyu > 0 && result.su_nonyu_wo == 0)
                            {
                                // トラン納入数が0以上(null以外)かつワーク納入数が0(null)の場合：追加
                                change = Resources.NonyuIraishoPdfAddition;
                                // ワーク追加処理
                                AddNonyuWorkTable(hizuke, result.cd_hinmei, result.cd_torihiki, (decimal)result.su_nonyu);
                            }
                            else if (result.su_nonyu == 0 && result.su_nonyu_wo > 0)
                            {
                                // トラン納入数が0(null)かつワーク納入数が0以上(null以外)の場合：取消
                                change = Resources.NonyuIraishoPdfCancel;
                                // ワーク削除処理
                                DeleteNonyuWorkTable(hizuke, result.cd_hinmei, result.cd_torihiki);
                            }
                            else
                            {
                                // 上記以外は「変更」
                                // ワーク削除処理
                                DeleteNonyuWorkTable(hizuke, result.cd_hinmei, result.cd_torihiki);
                                // ワーク追加処理
                                decimal nonyuSu = 0;
                                if (result.su_nonyu != null)
                                {
                                    nonyuSu = (decimal)result.su_nonyu;
                                }
                                AddNonyuWorkTable(hizuke, result.cd_hinmei, result.cd_torihiki, nonyuSu);
                            }

                            // ノードへの設定処理
                            data.Element("change" + row).SetValue(change);
                            data.Element("suryo" + row).SetValue(suryo);

                            // 次の明細情報へ
                            break;
                        }
                    }
                }
            }
            
            return pageBreak;
        }

        /// <summary>明細のヘッダー情報をXMLノードに設定します。</summary>
        /// <param name="lang">言語</param>
        /// <param name="pageBreak">1ページ分の帳票XML</param>
        /// <param name="result">明細情報</param>
        /// <param name="row">現在の列番号</param>
        /// <param name="pageCount">現在のページ数</param>
        /// <returns>ヘッダー情報を設定した1ページ分の帳票XML</returns>
        private XElement SetMeisaiHeaderXML(String lang, XElement pageBreak, usp_NonyuIraishoListPdf_select_Result result, int row, int pageCount) {
            // 品名コード部分
            String hinCode = GetFormatHinmeiCode(result.cd_hinmei, result.nonyu_tani, result.shiyo_tani);
            // 多言語対応した品名
            String hinmei = GetManyLanguagesName(lang, result.nm_hinmei_en, result.nm_hinmei_ja, result.nm_hinmei_zh, result.nm_hinmei_vi);

            // ヘッダーの設定処理
            pageBreak.Add(new XElement("hinmeiCode" + row, hinCode));
            pageBreak.Add(new XElement("hinmei" + row, hinmei));
            pageBreak.Add(new XElement("nisugata" + row, result.nm_nisugata_hyoji));
            pageBreak.Add(new XElement("bunrui" + row, result.nm_bunrui));

            return pageBreak;
        }

        /// <summary>明細ヘッダーの品名コード部分をフォーマット通りに整えて返却します。
        /// 　【フォーマット】品名コード　単位：納入単位(使用単位)
        /// </summary>
        /// <param name="hinCode">品名コード</param>
        /// <param name="nonyuTani">納入単位</param>
        /// <param name="shiyoTani">使用単位</param>
        /// <returns>フォーマットした明細ヘッダーの品名コード部分</returns>
        private String GetFormatHinmeiCode(String hinCode, String nonyuTani, String shiyoTani)
        {
            String str = hinCode + "  " + Resources.NonyuIraishoPdfItemNameTani + nonyuTani
                + ActionConst.NonyuIraishoPdfBracketStart + shiyoTani + ActionConst.NonyuIraishoPdfBracketEnd;
            return str;
        }

        /// <summary>明細の合計行に情報を設定し、XMLノードに設定します。</summary>
        /// <param name="pageBreak">1ページ分の帳票XML</param>
        /// <param name="row">現在の列番号</param>
        /// <param name="pageCount">現在のページ数</param>
        /// <returns>合計行を設定した1ページ分の帳票XML</returns>
        private XElement SetMeisaiTotalXML(XElement pageBreak, int row, int pageCount)
        {
            var nodes = pageBreak.Elements(NODES).Attributes("page" + pageCount);
            if (nodes.Count() > 0)
            {
                var totalNode = nodes.LastOrDefault().Parent;

                if (TotalSuryo > 0)
                {
                    //String suryo = String.Format("{0:#,0}", (Int32)TotalSuryo);    // 3桁カンマ区切り
                    String suryo = String.Format("{0:#,0.00}", TotalSuryo);    // 3桁カンマ区切り＋小数点以下2桁固定
                    String juryo = String.Format("{0:#,0.000}", TotalJuryo);  // 3桁カンマ区切り＋小数点以下3桁固定
                    String totalStr = suryo + ActionConst.NonyuIraishoPdfBracketStart + "  " + juryo + ActionConst.NonyuIraishoPdfBracketEnd;
                    totalNode.Element("suryo" + row).SetValue(totalStr);
                }
                else
                {
                    // 納入予定数がない場合、合計欄は空欄にする
                    totalNode.Element("suryo" + row).SetValue(" ");
                }
            }
            return pageBreak;
        }

        /// <summary>フォーマット(項目名、日付列＋明細列5つ)を作成します。</summary>
        /// <param name="pageBreak">1ページ分の帳票XML</param>
        /// <param name="dateList">31日分の日付情報</param>
        /// <param name="pageCount">現在のページ</param>
        /// <returns>フォーマット済みの1ページ分の帳票XML</returns>
        private XElement CreateFormatDetail(XElement pageBreak, List<NonyuInfo> dateList, int pageCount) {
            List<NonyuInfo> list = new List<NonyuInfo>();
            // 項目名の後ろに日付情報を追加する
            list.AddRange(dateList);

            // 項目列＋明細列５つを作成
            foreach (NonyuInfo info in list)
            {
                var nodes = new XElement(NODES,
                    new XElement("holiday", info.holiday),
                    new XElement("date", info.date),
                    new XElement("change1", " "),
                    new XElement("suryo1", " "),
                    new XElement("change2", " "),
                    new XElement("suryo2", " "),
                    new XElement("change3", " "),
                    new XElement("suryo3", " "),
                    new XElement("change4", " "),
                    new XElement("suryo4", " "),
                    new XElement("change5", " "),
                    new XElement("suryo5", " ")
                );
                nodes.SetAttributeValue("page" + pageCount, pageCount); // valueは使用しないので適当なものをセット
                pageBreak.Add(nodes);
            }
            // 合計行
            var totalRow = new XElement(NODES,
                new XElement("holiday", " "),
                new XElement("date", " "),
                new XElement("change1", " "),
                new XElement("suryo1", " "),
                new XElement("change2", " "),
                new XElement("suryo2", " "),
                new XElement("change3", " "),
                new XElement("suryo3", " "),
                new XElement("change4", " "),
                new XElement("suryo4", " "),
                new XElement("change5", " "),
                new XElement("suryo5", " ")
            );
            totalRow.SetAttributeValue("page" + pageCount, pageCount); // valueは使用しないので適当なものをセット
            pageBreak.Add(totalRow);

            return pageBreak;
        }

        /// <summary>ヘッダーの取引先情報を取得します。</summary>
        /// <param name="code">取引先コード</param>
        /// <param name="headerInfo">ヘッダー情報</param>
        /// <returns>取得した取引先情報を設定したヘッダー情報</returns>
        private NonyuHeaderInfo SetTorihikiInfo(String code, NonyuHeaderInfo headerInfo)
        {
            var ma_torihiki = (from ma in context.ma_torihiki
                           where ma.cd_torihiki == code
                           select ma).FirstOrDefault();

            string torihikisaki = " ";
            string tantosha = " ";
            string keisho = " ";
            string torihikisakiFax = " ";
            string keishikiKubun = " ";
            // マスタが取得できた場合、マスタの値を設定する
            if (ma_torihiki != null)
            {
                // 取引先名
                torihikisaki = ma_torihiki.nm_torihiki;
                // 担当者名
                if (!String.IsNullOrEmpty(ma_torihiki.nm_tanto_1))
                {
                    tantosha = ma_torihiki.nm_tanto_1;
                }
                // 敬称
                if (ma_torihiki.kbn_keisho_nonyusho == ActionConst.SamaKeishoKbn)
                {
                    keisho = Resources.KeishoSama;   // 様
                }
                else if (ma_torihiki.kbn_keisho_nonyusho == ActionConst.OnchuKeishoKbn)
                {
                    keisho = Resources.KeishoOnchu;  // 御中
                }
                // 取引先FAX
                if (!String.IsNullOrEmpty(ma_torihiki.no_fax))
                {
                    torihikisakiFax = ma_torihiki.no_fax;
                }
                // 納入書形式区分
                if (ma_torihiki.kbn_keishiki_nonyusho == ActionConst.NonyuSuryoNonyushoKeishikiKbn)
                {
                    keishikiKubun = Resources.NonyuSuryo;    // 納入数量
                }
                else if (ma_torihiki.kbn_keishiki_nonyusho == ActionConst.ShiyoSuryoNonyushoKeishikiKbn)
                {
                    keishikiKubun = Resources.ShiyoSuryo;   // 使用数量
                }
            }
            headerInfo.torihikisaki = torihikisaki;
            headerInfo.tantosha = tantosha;
            headerInfo.keisho = keisho;
            headerInfo.torihikisakiFax = torihikisakiFax;
            headerInfo.keishikiKubun = ActionConst.NonyuIraishoPdfBracketStart
                + keishikiKubun + ActionConst.NonyuIraishoPdfBracketEnd;

            return headerInfo;
        }

        /// <summary>ヘッダーの納品先情報を取得します。</summary>
        /// <param name="code">荷受場所コード</param>
        /// <param name="headerInfo">ヘッダー情報</param>
        /// <returns>取得した納品先情報を設定したヘッダー情報</returns>
        private NonyuHeaderInfo SetNohinsakiInfo(String code, NonyuHeaderInfo headerInfo)
        {
            var ma_niuke = (from ma in context.ma_niuke
                           where ma.cd_niuke_basho == code
                           select ma).FirstOrDefault();

            string nohinsaki = " ";
            string address = " ";
            // マスタが取得できた場合、マスタの値を設定する
            if (ma_niuke != null)
            {
                // 荷受場所
                nohinsaki = ma_niuke.nm_niuke;
                // 納品先住所
                address = ma_niuke.nm_jusho_1 + ma_niuke.nm_jusho_2 + ma_niuke.nm_jusho_3;
                // 空白(全半角スペース、タブ)除去
                System.Text.RegularExpressions.Regex r =
                    new System.Text.RegularExpressions.Regex(@"[ 　\t]");
                address = r.Replace(address, "");
            }
            headerInfo.nohinsaki = nohinsaki;
            headerInfo.nohinsakiAddress = address;

            return headerInfo;
        }

        /// <summary>発注番号を取得します。</summary>
        /// <param name="torihikiCode">取引先コード</param>
        /// <param name="headerInfo">ヘッダー情報</param>
        /// <returns>発注番号</returns>
        private String GetHachuNumber(String torihikiCode, NonyuHeaderInfo headerInfo)
        {
            String hachuNo = "";
            String createDate = headerInfo.dateFrom.ToString().Replace("/", "").Substring(0, 6);
            ObjectParameter no_saiban_param = new ObjectParameter("no_saiban", 0);

            // 採番テーブルから発注番号を取得
            String noSaiban = context.usp_cm_Saiban(
                ActionConst.HachuSaibanKbn, ActionConst.HachuPrefixSaibanKbn, no_saiban_param).FirstOrDefault<String>();

            // ログイン工場コード - 取引先コード - 作成開始日の年月 - 採番した番号
            hachuNo = headerInfo.loginKojoCode + ActionConst.Hyphen + torihikiCode + ActionConst.Hyphen + createDate + ActionConst.Hyphen + noSaiban;

            return hachuNo;
        }

        /// <summary>次の明細をチェックし、条件が一致した場合は改ページフラグをONにする。
        /// 次の明細がない場合は判定しないのでfalseを返す。
        /// </summary>
        /// <param name="sortData">１取引コード分の明細情報</param>
        /// <param name="data">現在の明細情報</param>
        /// <param name="beforeToriCd">現在見ている取引先コード</param>
        /// <param name="niukeCode">作成画面で指定した荷受場所コード</param>
        /// <param name="bunrui">「分類毎に改頁する」フラグ</param>
        /// <param name="dataCount">現在の明細行数</param>
        /// <returns>改ページフラグ</returns>
        private bool CheckNextMeisai(IEnumerable<usp_NonyuIraishoListPdf_select_Result> sortData,
            usp_NonyuIraishoListPdf_select_Result data, string beforeToriCd, string niukeCode, bool bunrui, int dataCount)
        {
            // 次のレコードをチェック
            // ただし、最終レコードの場合は判定しない
            if (sortData.Count() > (dataCount + 1))
            {
                usp_NonyuIraishoListPdf_select_Result nextData = sortData.ElementAt(dataCount + 1);

                // 次の明細で取引先コードが変わる場合、改ページする
                if (!beforeToriCd.Equals(nextData.cd_torihiki))
                {
                    return true;
                }

                // 荷受場所コードが指定されていない場合
                if (String.IsNullOrEmpty(niukeCode))
                {
                    if (NiukeCode != nextData.cd_niuke_basho)
                    {
                        // 荷受場所コードが変わった場合、改ページする
                        return true;
                    }
                }

                // 作成画面で「分類毎に改頁する」にチェックが入っていた場合
                if (bunrui)
                {
                    if (data.cd_bunrui != nextData.cd_bunrui)
                    {
                        // 次の明細で分類コードが変わる場合、改ページする
                        return true;
                    }
                }
            }
            return false;
        }

        /// <summary>納入ワークテーブルの追加処理を行います。</summary>
        /// <param name="nonyuDate">納入日</param>
        /// <param name="hinmeiCode">品名コード</param>
        /// <param name="torihikiCode">取引先コード</param>
        /// <param name="nonyu">納入数</param>
        private void AddNonyuWorkTable(DateTime nonyuDate, string hinmeiCode, string torihikiCode, decimal nonyu)
        {
            wk_nonyu data = new wk_nonyu();
            data.dt_nonyu = nonyuDate;
            data.cd_hinmei = hinmeiCode;
            data.cd_torihiki = torihikiCode;
            data.su_nonyu = nonyu;

            // 追加処理の実行
            context.AddTowk_nonyu(data);
        }

        /// <summary>納入ワークテーブルの削除処理を行います。</summary>
        /// <param name="nonyuDate">納入日</param>
        /// <param name="hinmeiCode">品名コード</param>
        /// <param name="torihikiCode">取引先コード</param>
        private void DeleteNonyuWorkTable(DateTime nonyuDate, string hinmeiCode, string torihikiCode)
        {
            wk_nonyu data = GetSingleEntity(nonyuDate, hinmeiCode, torihikiCode);
            if (data != null)
            {
                // 削除処理の実行
                context.DeleteObject(data);
            }
        }

        /// <summary>既存エンティティを取得します。</summary>
        /// <param name="nonyuDate">納入日</param>
        /// <param name="hinmeiCode">品名コード</param>
        /// <param name="torihikiCode">取引先コード</param>
        /// <returns>取得した納入予実ワーク情報</returns>
        private wk_nonyu GetSingleEntity(DateTime nonyuDate, string hinmeiCode, string torihikiCode)
		{
			var result = context.wk_nonyu.SingleOrDefault(wk => (wk.dt_nonyu == nonyuDate
                                                            && wk.cd_hinmei == hinmeiCode
                                                            && wk.cd_torihiki == torihikiCode));
			return result;
		}

        /// <summary>
        /// 多言語対応した名称を返却します。デフォルトは英語。
        /// 引数の順序：言語、英語名、日本語名、中国名
        /// </summary>
        /// <param name="lang">言語</param>
        /// <param name="name_en">英名</param>
        /// <param name="name_ja">日本語名</param>
        /// <param name="name_zh">中国名</param>
        /// <returns>ブラウザ言語に対応した品名</returns>
        private string GetManyLanguagesName(string lang, string name_en, string name_ja, string name_zh, string name_vi)
        {
            String str = name_en;
            if (lang == "ja")
            {
                str = name_ja;
            }
            else if (lang == "zh")
            {
                str = name_zh;
            }
            else if (lang == "vi")
            {
                str = name_vi;
            }
            return str;
        }
        
        /// <summary>nullの場合、空文字に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        private string ChangedNullToEmpty(string value)
        {
            if (String.IsNullOrEmpty(value) || value == "null")
            {
                value = " ";
            }
            return value;
        }
    }
}