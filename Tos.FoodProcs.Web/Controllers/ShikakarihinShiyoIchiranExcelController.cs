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
using System.Data.Objects;


namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// <画面名>ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class ShikakarihinShiyoIchiranExcelController : ApiController
    {
        // HTTP:GET 選択言語がjaの場合の出力
        public HttpResponseMessage Get([FromUri]ShikakarihinShiyoIchiranCriteria criteria, string lang, int UTC, string userName)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();


                IEnumerable<usp_ShikakarihinShiyoIchiran_select_Result> views;
                var count = new ObjectParameter("count", 0);
                views = context.usp_ShikakarihinShiyoIchiran_select(
                    criteria.dt_shikomi_search,
                    criteria.shikakariCode,
                    criteria.no_han,
                    criteria.skip,
                    criteria.top,
                    bool.Parse("true")
                ).ToList();

                // ファイル名の指定
                string templateName = "shikakarihinShiyoIchiran"; // return形式 "_lang.xlsx" 
                string excelname = Resources.ShikakarihinShiyoIchiran; // 出力ファイル名 拡張子は不要
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
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet;

                        // ======= 数値フォーマット作成 =======
                        sheet.NumberingFormats = new NumberingFormats();
                        // カンマ区切り、小数点以下6桁
                        NumberingFormat splitComma6 = new NumberingFormat();
                        splitComma6.NumberFormatId = UInt32Value.FromUInt32(6);
                        splitComma6.FormatCode = StringValue.FromString("#,##0.000000");
                        sheet.NumberingFormats.AppendChild<NumberingFormat>(splitComma6);
                        // カンマ区切り、小数点なし(金額)
                        NumberingFormat splitNoComma = new NumberingFormat();
                        splitNoComma.NumberFormatId = UInt32Value.FromUInt32(3);
                        splitNoComma.FormatCode = StringValue.FromString("#,##0");
                        sheet.NumberingFormats.AppendChild<NumberingFormat>(splitNoComma);
                        // ======= 数値フォーマット作成：ここまで =======

                        // 書式設定の追加
                        UInt32 indexSpCom6 = (UInt32)SetCellFormats(sheet, splitComma6);
                        UInt32 indexSpNoCom = (UInt32)SetCellFormats(sheet, splitNoComma);
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行（検索条件）をセット
                        // 仕込日
                        DateTime searchDate = (criteria.dt_shikomi_search).AddHours(-(UTC));
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", searchDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                        // 仕掛品コード
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", criteria.shikakariCode, 0, true);
                        // 仕掛品名
                        ExcelUtilities.UpdateValue(wbPart, ws, "B4", criteria.shikakariName, 0, true);

                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", DateTime.Now.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B7", userName, 0, true);

                        // 変数宣言
                        int index = 10; // 明細行開始ポイント
                        string kakuteiText;
                        string labelText;
                        string hasuText;
                        int addHours = 9;
                        // シートデータへ値をマッピング
                        foreach (usp_ShikakarihinShiyoIchiran_select_Result item in views)
                        {
                            kakuteiText = item.flg_keikaku == int.Parse(Resources.FlagTrue) ? Resources.Kakutei : string.Empty;
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, kakuteiText, 0, true);

                            if (item.dt_shikomi != null)
                            {
                                DateTime shikomiDate = (DateTime)item.dt_shikomi.AddHours(addHours);
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, shikomiDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, "", 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_shokuba_shikomi.ToString(), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_line_shikomi.ToString(), 0, true);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "E" + index, item.wt_shikomi_keikaku, indexSpCom6, lang);
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.no_lot_shikakari.ToString(), 0, true);
                            labelText = item.flg_label == int.Parse(Resources.FlagTrue) ? Resources.LabelHakkouAri : string.Empty;
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, labelText, 0, true);
                            hasuText = item.flg_label_hasu == int.Parse(Resources.FlagTrue) ? Resources.LabelHakkouAri : string.Empty;
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, hasuText, 0, true);
                            if (item.dt_seihin_seizo != null)
                            {
                                DateTime seizoDate = (DateTime)item.dt_seihin_seizo;
                                seizoDate = seizoDate.AddHours(addHours);
                                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, seizoDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, "", 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.nm_shokuba_seizo.ToString(), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.nm_line_seizo.ToString(), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.cd_hinmei.ToString(), 0, true);
                            if (lang == "ja")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.nm_hinmei_ja, 0, true);
                            }
                            else if (lang == "zh")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.nm_hinmei_zh, 0, true);
                            }
                            else if (lang == "vi")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.nm_hinmei_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.nm_hinmei_en, 0, true);
                            }
                            SetNumberValue(wbPart, ws, "N" + index, item.su_seizo_yotei.ToString(), indexSpNoCom);
                            ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, item.no_lot_seihin.ToString(), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, item.cd_shikakari_hin.ToString(), 0, true);
                            if (lang == "ja")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.nm_haigo_ja, 0, true);
                            }
                            else if (lang == "zh")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.nm_haigo_zh, 0, true);
                            }
                            else if (lang == "vi")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.nm_haigo_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.nm_haigo_en, 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, item.no_lot_shikakari_oya.ToString(), 0, true);

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
                    return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
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

        /// <summary>数値系項目のマッピング処理。nullの場合は空白を設定します。</summary>
        /// <param name="wbPart">ワークブック</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="cellNo">設定するセル番号</param>
        /// <param name="item">設定する値</param>
        /// <param name="fmt">書式番号</param>
        private void SetNumberValue(WorkbookPart wbPart, Worksheet ws, String cellNo, String item, UInt32 fmt)
        {
            String value = item;
            bool isStr = false;
            if (String.IsNullOrEmpty(value))
            {
                value = "";
                isStr = true;
                fmt = 0;
            }
            ExcelUtilities.UpdateValue(wbPart, ws, cellNo, value, fmt, isStr);
        }
        /// <summary>書式設定を追加します。</summary>
        /// <param name="sheet">スタイルシート</param>
        /// <param name="fmtVal">設定したい書式</param>
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