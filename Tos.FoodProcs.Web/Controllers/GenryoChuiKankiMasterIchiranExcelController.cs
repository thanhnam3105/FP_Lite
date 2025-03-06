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

using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Tos.FoodProcs.Web.Properties;


namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 原料注意喚起マスタ一覧：ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenryoChuiKankiMasterIchiranExcelController : ApiController
    {

        // HTTP:GET
        public HttpResponseMessage Get(ODataQueryOptions<vw_ma_chui_kanki_genryo_02> options,
            string lang, string userName, DateTime today)
        {
            // ブラウザ言語　（上で言語指定している。エラーなら下の処理を有効にする。）
            //String lang = criteria.lang;

            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();

                // ファイル名の指定
                string templateName = "genryoChuiKankiMasterIchiran"; // return形式 "_lang.xlsx" 
                string excelname = Resources.GenryoChuiKankiMasterIchiranExcel; // 出力ファイル名 拡張子は不要
                // TODO:ここまで

                // pathの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, lang);
                string FlagTrue = Resources.FlagTrue;

                /// テンプレートを読み込み、必要な情報をマッピングしてクライアントへ返却
                byte[] byteArray = File.ReadAllBytes(templateFile);
                using (MemoryStream mem = new MemoryStream())
                {
                    mem.Write(byteArray, 0, (int)byteArray.Length);
                    using (SpreadsheetDocument spDoc = SpreadsheetDocument.Open(mem, true))
                    {
                        // 定義記述
                        string NmSheet = "Sheet1";
                        WorkbookPart wbPart = spDoc.WorkbookPart;
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet;

                        // 定数
                        string NonyuSuryo = Resources.NonyuSuryo;
                        string ShiyoSuryo = Resources.ShiyoSuryo;
                        string KeishoSama = Resources.KeishoSama;
                        string KeishoOnchu = Resources.KeishoOnchu;
                        string KeishoNashi = Resources.KeishoNashi;
                        string Mishiyo = Resources.Mishiyo;
                        string Ari = Resources.Ari;

                        // 書式設定の追加
                        // 数値以外：下詰め、折り返し
                        UInt32 fmtString = FoodProcsCommonUtility.ExcelCellFormatAlign(sheet);

                        // ヘッダー行をセット
                        // 検索条件
                        // 出力日時
                        string outputDate = today.ToString(FoodProcsCommonUtility.formatDateSelect(lang)) + " " + today.ToString("HH:mm:ss");
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", outputDate, 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", userName, 0, true);

                        // 明細行開始ポイント
                        int index = 6;

                        // シートデータへ値をマッピング
                        IQueryable results = options.ApplyTo(context.vw_ma_chui_kanki_genryo_02.AsQueryable());
                        foreach (vw_ma_chui_kanki_genryo_02 item in results)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            // 品区分
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.nm_kbn_hin.ToString(), 0, true);
                            // 品名コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_hinmei, 0, true);
                            // 品名：多言語対応
                            string hinmei = GetName(lang, item.nm_hinmei_ja, item.nm_hinmei_en, item.nm_hinmei_zh, item.nm_hinmei_vi);
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, hinmei, fmtString, true);
                            // 優先順位
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.no_juni_yusen.ToString(), 0, true);
                            // 注意喚起区分
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_kbn_chui_kanki, 0, true);
                            // 注意喚起名
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.cd_chui_kanki, 0, true);
                            // 注意喚起名
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_chui_kanki, 0, true);
                            // 注意喚起チェック
                            if (ActionConst.FlagFalse == item.flg_chui_kanki_hyoji)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, "", 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, Ari, 0, true);
                            }
                            
                            // 未使用フラグ：使用の場合は空白、未使用の場合は「未使用」
                            if (ActionConst.FlagFalse == item.flg_mishiyo)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, "", 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, Mishiyo, 0, true);
                            }

                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        ws.Save();
                        // TODO:ここまで
                    }

                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.genryoChuikankiMasterCookie, Resources.CookieValue);
                }

            }
            catch (HttpResponseException e)
            {
                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
                try
                {
                    // エラー用EXCELファイルの取得
                    string serverpath = HttpContext.Current.Server.MapPath("..");
                    string templateFile = ExcelUtilities.getTemplateFile("Error", serverpath, lang);
                    byte[] byteArray = File.ReadAllBytes(templateFile);
                    MemoryStream errorStream = new MemoryStream();
                    errorStream.Write(byteArray, 0, (int)byteArray.Length);
                    // レスポンスを生成して返します
                    return FileDownloadUtility.CreateExcelFileResponse(errorStream.ToArray(), "Error.xlsx");
                }
                catch (Exception)
                {
                    ///// エラー用のEXCELテンプレートが無い場合など
                    MemoryStream errorStream = new MemoryStream();
                    // 空っぽのデータでレスポンスを生成して返却
                    return FileDownloadUtility.CreateExcelFileResponse(errorStream.ToArray(), "error.xlsx");
                }
            }
        }
        /// <summary>
        /// 多言語対応の名称を返却する
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="name_ja">名称_日本語</param>
        /// <param name="name_en">名称_英語</param>
        /// <param name="name_zh">名称_中国語</param>
        /// <returns>名称</returns>
        private string GetName(string lang, string name_ja, string name_en, string name_zh, string name_vi)
        {
            string result_name = name_en;
            if (Resources.LangJa.Equals(lang))
            {
                result_name = name_ja;
            }
            else if (Resources.LangZh.Equals(lang))
            {
                result_name = name_zh;
            }
            else if (Resources.LangVi.Equals(lang))
            {
                result_name = name_vi;
            }

            return result_name;
        }

    }
}