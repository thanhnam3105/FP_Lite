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
    /// 取引先マスタ一覧：ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class TorihikisakiMasterIchiranExcelController : ApiController
    {
        
        // HTTP:GET
        public HttpResponseMessage Get(ODataQueryOptions<vw_ma_torihiki_01> options, 
            short kbn_torihiki, string nm_torihiki, short flg_mishiyo, string lang, string userName, DateTime today)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();

                // ファイル名の指定
                string templateName = "torihikisakiMasterIchiran"; // return形式 "_lang.xlsx" 
                string excelname = Resources.TorihikisakiMasterIchiranExcel; // 出力ファイル名 拡張子は不要
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

                        // 定数
                        string NonyuSuryo = Resources.NonyuSuryo;
                        string ShiyoSuryo = Resources.ShiyoSuryo;
                        string KeishoSama = Resources.KeishoSama;
                        string KeishoOnchu = Resources.KeishoOnchu;
                        string KeishoNashi = Resources.KeishoNashi;
                        string Mishiyo = Resources.Mishiyo;

                        // ヘッダー行をセット
                        // 納入書形式区分
                        if (kbn_torihiki == ActionConst.ShiiresakiTorihikisakiKbn)
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B2", Resources.TorihikisakiShiiresaki, 0, true);
                        }
                        else if (kbn_torihiki == ActionConst.UriagemotoTorihikisakiKbn)
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B2", Resources.TorihikisakiUriagemoto, 0, true);
                        }
                        else if (kbn_torihiki == ActionConst.SeizomotoTorihikisakiKbn)
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B2", Resources.TorihikisakiSeizomoto, 0, true);
                        }
                        // 取引先名
                        if (nm_torihiki == "null")
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B3", "", 0, true);
                        }
                        else {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B3", nm_torihiki, 0, true);
                        }
                        // 未使用フラグ
                        if (flg_mishiyo == ActionConst.FlagTrue)
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B4", Resources.Ari, 0, true);
                        }
                        else if (flg_mishiyo == ActionConst.FlagFalse)
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B4", Resources.Nashi, 0, true);
                        }
                        // 出力日時
                        string outputDate = today.ToString(FoodProcsCommonUtility.formatDateSelect(lang)) + " " + today.ToString("HH:mm:ss");
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", outputDate, 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B7", userName, 0, true);

                        // 明細行開始ポイント
                        int index = 10;
                
                        // シートデータへ値をマッピング
                        IQueryable results = options.ApplyTo(context.vw_ma_torihiki_01.AsQueryable());
                        foreach (vw_ma_torihiki_01 item in results)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.cd_torihiki.ToString(), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_torihiki, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_torihiki_ryaku, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_busho, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_kbn_torihiki, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.no_yubin, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_jusho, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.no_tel, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.no_fax, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.e_mail, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.nm_tanto_1, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.nm_tanto_2, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.nm_tanto_3, 0, true);

                            // 納入書形式区分
                            if (item.kbn_keishiki_nonyusho == ActionConst.NonyuSuryoNonyushoKeishikiKbn)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, NonyuSuryo, 0, true);
                            }
                            else if (item.kbn_keishiki_nonyusho == ActionConst.ShiyoSuryoNonyushoKeishikiKbn)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, ShiyoSuryo, 0, true);
                            }

                            // 敬称区分
                            if (item.kbn_keisho_nonyusho == ActionConst.SamaKeishoKbn)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, KeishoSama, 0, true);
                            }
                            else if (item.kbn_keisho_nonyusho == ActionConst.OnchuKeishoKbn)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, KeishoOnchu, 0, true);
                            }
                            else if (item.kbn_keisho_nonyusho == ActionConst.NashiKeishoKbn)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, KeishoNashi, 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, item.biko, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.cd_maker, 0, true);

                            // 未使用フラグ：使用の場合は空白、未使用の場合は「未使用」
                            if (ActionConst.FlagFalse == item.flg_mishiyo)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, "", 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, Mishiyo, 0, true);
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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.torihikisakiMasterCookie, Resources.CookieValue);
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
    }
}