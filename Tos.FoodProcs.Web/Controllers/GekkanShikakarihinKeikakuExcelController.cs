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
    public class GekkanShikakarihinKeikakuExcelController : ApiController
    {
        // HTTP:GET出力
        public HttpResponseMessage Get([FromUri]GekkanShikakarihinKeikakuCriteria criteria, string lang, DateTime today,
            string userName, string strSeihin, string strOyaShikakari, string strShikakari)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();

                // 検索実行
                IEnumerable<usp_GekkanShikakarihinKeikaku_select_Result> views;
                var count = new ObjectParameter("count", 0);
                views = context.usp_GekkanShikakarihinKeikaku_select(
                    criteria.cd_shokuba
                    , criteria.dt_hiduke_from
                    , criteria.dt_hiduke_to
                    , criteria.cd_hinmei_search == string.Empty || criteria.cd_hinmei_search == null ? ActionConst.FlagFalse : ActionConst.FlagTrue
                    , criteria.cd_hinmei_search
                    , criteria.no_lot_search
                    , short.Parse(criteria.select_lot_search == Resources.SelectLotNashi ? Resources.FlagTrue : Resources.FlagFalse)
                    , short.Parse(criteria.select_lot_search == Resources.SelectLotOya ? Resources.FlagTrue : Resources.FlagFalse)
                    , short.Parse(criteria.select_lot_search == Resources.SelectLotSeihin ? Resources.FlagTrue : Resources.FlagFalse)
                    , short.Parse(criteria.select_lot_search == Resources.SelectLotShikakari ? Resources.FlagTrue : Resources.FlagFalse)
                    , criteria.skip
                    , criteria.top
                    , ActionConst.FlagTrue // Excelかどうか
                    , ActionConst.FlagTrue // 判定用フラグ
                , count).ToList();

                //// ファイル名の指定
                string templateName = "gekkanShikakarihinKeikaku";
                string excelname = Resources.GekkanShikakarihinKeikakuExcelName; // 出力ファイル名
                //// TODO:ここまで

                //// pathの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, lang);

                ///// テンプレートを読み込み、必要な情報をマッピングしてクライアントへ返却
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
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet; ;
                        sheet.NumberingFormats = new NumberingFormats();
                        
                        // カンマ区切り、小数点以下3桁
                        NumberingFormat splitComma3 = new NumberingFormat();
                        splitComma3.NumberFormatId = UInt32Value.FromUInt32(4);
                        splitComma3.FormatCode = StringValue.FromString("#,##0.000");
                        sheet.NumberingFormats.AppendChild<NumberingFormat>(splitComma3);
                        // 書式設定の追加
                        UInt32 indexSpCom3 = (UInt32)SetCellFormats(sheet, splitComma3);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // ヘッダー行をセット
                        // 検索日：製造期間
                        string searchDate = criteria.dt_hiduke_from.ToString(FoodProcsCommonUtility.formatDateSelect(lang))
                                          + " " + ActionConst.Hyphen + " "
                                          + criteria.dt_hiduke_to.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        ExcelUtilities.UpdateValue(wbPart, ws, "C2", searchDate, 0, true);
                        // 職場
                        ExcelUtilities.UpdateValue(wbPart, ws, "C3", criteria.nm_shokuba, 0, true);
                        // 仕掛品コード
                        ExcelUtilities.UpdateValue(wbPart, ws, "C4", criteria.cd_hinmei_search, 0, true);
                        // 仕掛品
                        ExcelUtilities.UpdateValue(wbPart, ws, "C5", criteria.cd_hinmei, 0, true);

                        // ロット
                        string selectLot = Resources.Nashi; // デフォルト「なし」
                        if (criteria.select_lot_search == ActionConst.LotSeihin)
                        {
                            // 製品の場合
                            selectLot = strSeihin;
                        }
                        else if (criteria.select_lot_search == ActionConst.LotOyaShikakari)
                        {
                            // 親仕掛品の場合
                            selectLot = strOyaShikakari;
                        }
                        else if (criteria.select_lot_search == ActionConst.LotShikakari)
                        {
                            // 仕掛品の場合
                            selectLot = strShikakari;
                        }
                        ExcelUtilities.UpdateValue(wbPart, ws, "C6", selectLot, 0, true);

                        // ロット番号：ロットが「なし」の場合は空白
                        if (Resources.Nashi.Equals(selectLot))
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "C7", "", 0, true);
                        }
                        else
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "C7", criteria.no_lot_search, 0, true);
                        }
                        
                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, "C9", today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "C10", userName, 0, true);
                        
                        // 名称を整える
                        templateFile = String.Format(templateFile, criteria.nm_shokuba);

                        // 明細行開始ポイント
                        int index = 13;
                        
                        // シートデータへ値をマッピング
                        foreach (usp_GekkanShikakarihinKeikaku_select_Result item in views)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.id.ToString(), 0, false);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.dt_hitsuyo_tukihi.ToString("dd"), 0, true);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.dt_hitsuyo_yobi.ToString(ActionConst.DatetimeFormatYobi), 0, true);
                            String yobiData = item.dt_hitsuyo_yobi.ToString(ActionConst.DatetimeFormatYobi);
                            if (lang == "zh")
                            {
                                // 中国語の曜日は画面のフォーマットに合わせ『一,二,三,四,五,六,日』のみを表示します。
                                yobiData = yobiData.Replace("周", "");
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, yobiData, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index,
                                                (item.dt_seizo != null ? item.dt_seizo.Value.ToString(FoodProcsCommonUtility.formatDateSelect(lang)) : item.dt_seizo.ToString()), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.cd_hinmei, 0, true);
                            // 多言語対応を考慮する
                            if (lang == Resources.LangJa)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_haigo_ja, 0, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_shikakari_ja, 0, true);
                            }
                            else if (lang == Resources.LangZh)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_haigo_zh, 0, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_shikakari_zh, 0, true);
                            }
                            else if (lang == Resources.LangVi)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_haigo_vi, 0, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_shikakari_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_haigo_en, 0, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_shikakari_en, 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index,
                                                (item.flg_gassan_shikomi == ActionConst.FlagTrue ? Resources.GassanMark : string.Empty), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.nm_tani, 0, true);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "J" + index, item.wt_hitsuyo, indexSpCom3, lang);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "K" + index, item.wt_shikomi_keikaku, indexSpCom3, lang);
                            ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.cd_line, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.nm_line, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.no_lot_shikakari, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, item.no_lot_shikakari_oya, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, item.no_lot_seihin, 0, true);

                            // 行のポインタを一つカウントアップ
                            index++;


                        }
                        ws.Save();
                    }

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.gekkanShikakarihinKeikakuCookie, Resources.CookieValue);
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

        /// <summary>書式設定を追加します。</summary>
        /// <param name="sheet">シート情報</param>
        /// <param name="fmtVal">設定したい書式ID</param>
        /// <returns>書式番号</returns>
        private int SetCellFormats(Stylesheet sheet, NumberingFormat fmtVal)
        {
            CellFormat fmt = new CellFormat();
            fmt.NumberFormatId = fmtVal.NumberFormatId;
            int fmtIndex = sheet.CellFormats.Count();
            sheet.CellFormats.InsertAt<CellFormat>(fmt, fmtIndex);
            return fmtIndex;
        }
    }
}