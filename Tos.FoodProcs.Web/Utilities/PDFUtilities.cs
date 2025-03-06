using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Services;

namespace Tos.FoodProcs.Web.Utilities
{
    public static class PDFUtilities
    {
        //16017: trinh.bd Download PDF for version 7.2 [use API]
        //---------------------START----------------------------
        //[*] YOU MUST SETTING

        //private const string jasperURL = "http://10.200.0.21:8080/jasperserver/";
        private const string jasperURL = "http://192.168.0.98:8080/jasperserver/";
        // 認証用の記述(user, pass)
        private const string user = "jasperadmin";
        private const string pass = "jasperadmin";

        //Link jasperserver
        //private const string jasperRest = "rest_v2/";
        private const string jasperRest = "rest_v2/reports";
        //[*]{0}: Name report jrxml on JasperSoft Server; {1}: language[ja,en,zh]; {2}: extens download file
        //プロパティのパスを記載（reportsのrは小文字）
        //private const string reportJrxml = "reports/reports/FPLite/01_FPLite/{0}_{1}{2}";
        private const string reportJrxml = "/reports/FP_LITE/FP_Lite_Vietnamese_Ver2/{0}_{1}{2}";
        //[*]{3}: xml file
        //private const string xmlURL = "?net.sf.jasperreports.xml.source=http://10.200.0.21:8080/xmldata/{3}";
        private const string xmlURL = "?net.sf.jasperreports.xml.source=http://192.168.0.98:8080/xmldata/{3}";
        //{4}: user JasperSoft Server; {5} : password JasperSoft Server
        private const string strAccount = "&j_username={4}&j_password={5}";
        //Demo link API
        //http://192.168.0.98:8090/jasperserver/rest_v2/reports/Reports/FPLiteRoyal/01_FPLite/{0}_{1}{2}.pdf?net.sf.jasperreports.xml.source=http://192.168.0.145:8080/xmldata/{3}&j_username={4}&j_password={5}

        //---------------------END------------------------------

        // jasperRepository
        // for cloud【TOs内テストSV・Azureテスト・本番】
        private const string jasperRepository = "services/repository";

        // データソースXML格納用パス
        /* TODO：接続先の環境に合わせて以下を変更してください。*/
        // for VMWare【開発環境】
        //private const string xmldatapath = "C:\\inetpub\\wwwroot\\xmldata";
        // for local
        //private const string xmldatapath = "D:\\Tomcat 6.0\\webapps\\xmldata";
        // for cloud【TOs内テストSV・Azureテスト・本番】
        //private const string xmldatapath = "C:\\Jaspersoft\\jasperreports-server-cp-7.2.0\\apache-tomcat\\webapps\\xmldata";
        private const string xmldatapath = "C:\\Jaspersoft\\jasperreports-server-cp-8.2.0\\apache-tomcat\\webapps\\xmldata";
        /// JasperServerへのアドレスを返却する
        public static string getJasperURL()
        {
            //return jasperURL + jasperRepository;
            return Properties.Settings.Default.jasperURL + jasperRepository;
        }

        /// <summary>
        /// JasperServerへのリクエスト用XMLを生成します
        /// </summary>
        /// <param name="reportname">Name jrxml file on JasperSoft Server</param>
        /// <param name="lang">PDF言語</param>
        /// <param name="xmldataname">Name xml file report</param>
        /// <returns>string</returns>
        public static string GetLinkAPI(string reportname, string xmldataname, string lang)
        {
            var linkAPI = Properties.Settings.Default.jasperURL +
                            jasperRest
                            + Properties.Settings.Default.reportJrxml
                            + Properties.Settings.Default.xmlURL
                            + strAccount;

            // 言語によって選択されるフォーマット
            return string.Format(linkAPI, reportname, lang, Properties.Resources.pdfExtens, xmldataname, user, pass);
        }

        /// <summary>
        /// JasperServer use API download file
        /// </summary>
        /// <param name="linkAPI">Link API download</param>
        /// <returns>Stream</returns>
        public static MemoryStream GetStreamFromUrl(string linkAPI)
        {

            byte[] pdfFile = null;
            MemoryStream memoryStream = null;

            try
            {
                using (var wc = new System.Net.WebClient())
                {
                    pdfFile = wc.DownloadData(linkAPI);
                }
                memoryStream = new MemoryStream(pdfFile);
            }
            catch (Exception ex)
            {
            }

            return memoryStream;
        }

        /// <summary>
        /// エラーファイルのテンプレートディレクトリを返却する
        /// </summary>
        /// <param name="str">エラーファイル名</param>
        /// <returns>ディレクトリ</returns>
        public static string getErrorFile(string path, string lang)
        {
            string name = "ReportServerError.pdf";
            if (lang == "ja")
            {
                return path + "\\Templates" + "\\" + name;
                                         
            }
            else if (lang == "zh")
            {
                return path + "\\Templates" + "\\" + name;
            }
            else
            {
                return path + "\\Templates" + "\\" + name;
            }
        }

        /// <summary>
        /// JasperServerの参照するxmldatasourceのディレクトリを指定します。
        /// </summary>
        /// <param name="str">データソース用のXML名</param>
        /// <returns>xmlpath</returns>
        public static string createSaveXMLPath(string str)
        {
            return Properties.Settings.Default.xmldatapath + "\\" + str;
        }

    }
}