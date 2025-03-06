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
using Tos.FoodProcs.Web.Controllers;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Tos.FoodProcs.Web.Properties;
using System.Data.Objects;


namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 月間仕掛品計画ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Authorize]
    [LoggingExceptionFilter]
    public class HistoryChangeMasterExcelController : ApiController
    {
        // HTTP:GET出力
        public HttpResponseMessage Get([FromUri]HistoryChangeMasterCriteria criteria, [FromUri]HistoryChangeMasterLiteral literal, string lang, DateTime today,
                                        string userName, string nm_hinmei, int UTC, string col_riyu, string col_biko, string col_genka)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();
                context.ContextOptions.LazyLoadingEnabled = false;
                // TODO：タイムアウト時間変更(0=無限)
                context.CommandTimeout = 0;

                // 検索実行
                IEnumerable<usp_HistoryChange_select_Result> views;
                var count = new ObjectParameter("count", 0);
                views = context.usp_HistoryChange_select(
                    criteria.kbn_data
                    , criteria.kbn_shori
                    , criteria.dt_hiduke_from
                    , criteria.dt_hiduke_to
                    , criteria.cd_hinmei
                    , criteria.dt_update_from
                    , criteria.dt_update_to
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_nm_tanto)
                    , criteria.skip
                    , criteria.top
                    , 1
                    , count).ToList();

                // ファイル名の指定
                string templateName = "historyChangeMaster";
                string excelname = Resources.HistoryChangeExcelName /*+ "_" + today.ToString("yyyyMMdd")*/; // 出力ファイル名

                // TODO:ここまで

                // pathの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, lang);

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

                        // フォーマット作成とシートへのセット
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet;
                        sheet.NumberingFormats = new NumberingFormats();

                        // 書式設定の追加
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);
                        
                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // ヘッダー行をセット
                        // 検索日：製造期間
                        var kbn_data = "";
                        if (criteria.kbn_data == literal.ProductionPlan_num)
                        {
                            kbn_data = literal.ProductionPlan_text;
                        }
                        if (criteria.kbn_data == literal.adjusted_num)
                        {
                            kbn_data = literal.adjusted_text;
                        }

                        var kbn_shori = "";
                        if (criteria.kbn_shori == literal.New_num)
                        {
                            kbn_shori = literal.New_text;
                        }
                        if (criteria.kbn_shori == literal.Change_num)
                        {
                            kbn_shori = literal.Change_text;
                        }
                        if (criteria.kbn_shori == literal.Delete_num)
                        {
                            kbn_shori = literal.Delete_text;
                        }

                        string dt_hiduke_from = "";
                        if (criteria.dt_hiduke_from.ToString() != null && criteria.dt_hiduke_from.ToString() != "")
                        {
                            dt_hiduke_from = DateTime.Parse(criteria.dt_hiduke_from.ToString()).ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        }

                        string dt_hiduke_to = "";
                        if (criteria.dt_hiduke_to.ToString() != null && criteria.dt_hiduke_to.ToString() != "")
                        {
                            dt_hiduke_to = DateTime.Parse(criteria.dt_hiduke_to.ToString()).ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        }

                        string dt_hiduke = dt_hiduke_from
                                          + " " + ActionConst.WaveDash + " "
                                          + dt_hiduke_to;

                        string dt_update_from = "";
                        if (criteria.dt_update_from.ToString() != null && criteria.dt_update_from.ToString() != "")
                        {
                            dt_update_from = DateTime.Parse(criteria.dt_update_from.ToString()).ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        }

                        string dt_update_to = "";
                        if (criteria.dt_update_to.ToString() != null && criteria.dt_update_to.ToString() != "")
                        {
                            dt_update_to = DateTime.Parse(criteria.dt_update_to.ToString()).ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        }
                        string dt_update = dt_update_from
                                          + " " + ActionConst.WaveDash + " "
                                          + dt_update_to;


                        ExcelUtilities.UpdateValue(wbPart, ws, "C2", kbn_data, 0, true);

                        ExcelUtilities.UpdateValue(wbPart, ws, "C3", kbn_shori, 0, true);

                        ExcelUtilities.UpdateValue(wbPart, ws, "C4", dt_hiduke, 0, true);

                        ExcelUtilities.UpdateValue(wbPart, ws, "C5", dt_update, 0, true);

                        ExcelUtilities.UpdateValue(wbPart, ws, "C6", criteria.cd_hinmei, 0, true);

                        string nm_hinmei_text = nm_hinmei;
                        if (nm_hinmei == "null")
                        {
                            nm_hinmei_text = "";
                        }
                        ExcelUtilities.UpdateValue(wbPart, ws, "C7", nm_hinmei_text, 0, true);

                        string tanto = criteria.cd_nm_tanto;
                        if (criteria.cd_nm_tanto == "null")
                        {
                            tanto = "";
                        }
                        ExcelUtilities.UpdateValue(wbPart, ws, "C8", tanto, 0, true);

                        ExcelUtilities.UpdateValue(wbPart, ws, "C10", userName, 0, true);

                        ExcelUtilities.UpdateValue(wbPart, ws, "C11", today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);

                        //// 明細行開始ポイント
                        int index = 14;

                        SheetData sheetData = ws.GetFirstChild<SheetData>();
                        UInt32 rowDateNumber = GetRowIndex("C14");
                        Row rowDate = GetRow(sheetData, rowDateNumber);
                        Cell cellDate = rowDate.Elements<Cell>().Where(c => c.CellReference.Value == "C14").FirstOrDefault();
                        UInt32 styleCellDate = cellDate.StyleIndex;

                        UInt32 rowProductNumber = GetRowIndex("D14");
                        Row rowProduct = GetRow(sheetData, rowDateNumber);
                        Cell cellProduct = rowProduct.Elements<Cell>().Where(c => c.CellReference.Value == "D14").FirstOrDefault();
                        UInt32 styleCellProduct = cellProduct.StyleIndex;

                        // シートデータへ値をマッピング
                        foreach (usp_HistoryChange_select_Result item in views)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            String kbn_data_item = "";
                            if (item.kbn_data == literal.ProductionPlan_num)
                            {
                                kbn_data_item = literal.ProductionPlan_text;
                            }
                            if (item.kbn_data == literal.adjusted_num)
                            {
                                kbn_data_item = literal.adjusted_text;
                            }

                            String kbn_shori_item = "";
                            if (item.kbn_shori == literal.New_num)
                            {
                                kbn_shori_item = literal.New_text;
                            }
                            if (item.kbn_shori == literal.Change_num)
                            {
                                kbn_shori_item = literal.Change_text;
                            }
                            if (item.kbn_shori == literal.Delete_num)
                            {
                                kbn_shori_item = literal.Delete_text;
                            }

                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, FoodProcsCommonUtility.changedNullToEmpty(kbn_data_item), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, FoodProcsCommonUtility.changedNullToEmpty(kbn_shori_item), 0, true);

                            DateTime dt_hizuke = item.dt_hizuke.AddHours(-(UTC));
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, dt_hizuke.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), styleCellDate, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.cd_hinmei, styleCellProduct, true);

                            if (Resources.LangJa.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_ja), 0, true);
                            }
                            else if (Resources.LangZh.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_zh), 0, true);
                            }
                            else if (Resources.LangVi.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_vi), 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_en), 0, true);
                            }

                            String su_henko = "0.000";
                            if (item.su_henko.ToString() != null)
                            {
                                su_henko = float.Parse(item.su_henko).ToString();
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, su_henko, indexSpCom3, false);

                            String su_henko_hasu = "0.000";
                            if (item.su_henko_hasu.ToString() != null)
                            {
                                su_henko_hasu = float.Parse(item.su_henko_hasu).ToString();
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, su_henko_hasu, indexSpCom3, false);

                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.no_lot, 0, true);

                            DateTime dt_update_time = item.dt_update.AddHours(-(UTC));
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, dt_update_time.ToString(FoodProcsCommonUtility.formatDateTimeShortSelect(lang)), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.cd_update, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.nm_tanto, 0, true);

                            var biko = item.biko;
                            if (biko != null && biko != "")
                            {
                                biko = biko.Replace("[1]", col_riyu);
                                biko = biko.Replace("[2]", col_biko);
                                biko = biko.Replace("[3]", col_genka);
                            }
                            
                            ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, biko, 0, true);

                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        ws.Save();
                    }
                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.HistoryChangeMasterCookie, Resources.CookieValue);
                }
            }
            catch (Exception e)
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

        private static UInt32 GetRowIndex(string address)
        {
            string rowPart;
            UInt32 l;
            UInt32 result = 0;

            for (int i = 0; i < address.Length; i++)
            {
                if (UInt32.TryParse(address.Substring(i, 1), out l))
                {
                    rowPart = address.Substring(i, address.Length - i);
                    if (UInt32.TryParse(rowPart, out l))
                    {
                        result = l;
                        break;
                    }
                }
            }
            return result;
        }

        private static Row GetRow(SheetData wsData, UInt32 rowIndex)
        {
            var row = wsData.Elements<Row>().
            Where(r => r.RowIndex.Value == rowIndex).FirstOrDefault();
            if (row == null)
            {
                row = new Row();
                row.RowIndex = rowIndex;
                wsData.Append(row);
            }
            return row;
        }
    }

    public class HistoryChangeMasterLiteral 
    {
        public decimal ProductionPlan_num { get; set; }
        public String ProductionPlan_text { get; set; }
        public decimal adjusted_num { get; set; }
        public String adjusted_text { get; set; }
        public decimal New_num { get; set; }
        public String New_text { get; set; }
        public decimal Change_num { get; set; }
        public String Change_text { get; set; }
        public decimal Delete_num { get; set; }
        public String Delete_text { get; set; }
    }
}