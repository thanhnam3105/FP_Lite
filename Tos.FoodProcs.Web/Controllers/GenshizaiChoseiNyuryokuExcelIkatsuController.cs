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
    /// 原資材調整入力ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiChoseiNyuryokuExcelIkatsuController : ApiController
    {
        // HTTP:GET 
        public HttpResponseMessage Get(ODataQueryOptions<vw_tr_chosei_01> options, string lang, string hinKubun,
            string userName, int UTC, DateTime today)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();
                IQueryable results = options.ApplyTo(context.vw_tr_chosei_01.AsQueryable());

                // ファイル名の指定
                string templateName = "genshizaiChoseiNyuryoku_kikanSentaku"; // return形式 "_lang.xlsx"

                // 出力ファイル名 拡張子は不要
                string excelname = Resources.GenshizaiChoseiNyuryokuExcelIkatsu;

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

                        // 書式設定の追加
                        // カンマ区切り、小数点以下3桁
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        // 数値以外：下詰め、折り返し
                        UInt32 fmtString = FoodProcsCommonUtility.ExcelCellFormatAlign(sheet);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        //int addHours = 9;   // UTC用9h+

                        // ----------------- Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        // 検索条件
                        // 検索日付（開始日　～　終了日）
                        //開始日
                        string searchDateStartString = options.RawValues.Filter.Split(' ')[2].Substring(9, 19);
                        DateTime searchDateStart = DateTime.ParseExact(searchDateStartString, "yyyy-MM-ddTHH:mm:ss", null);
                        string dtFrom = searchDateStart.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        //終了日
                        string searchDateEndString = options.RawValues.Filter.Split(' ')[6].Substring(9, 19);
                        DateTime searchDateEnd = DateTime.ParseExact(searchDateEndString, "yyyy-MM-ddTHH:mm:ss", null);
                        string dtTo = searchDateEnd.ToString(FoodProcsCommonUtility.formatDateSelect(lang));

                        string hizuke = dtFrom + ActionConst.StringSpace + ActionConst.WaveDash + ActionConst.StringSpace + dtTo;
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", hizuke, 0, true);

                        // 品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", hinKubun, 0, true);

                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", userName, 0, true);

                        // 明細行開始ポイント
                        int index = 9;

                        // シートデータへ値をマッピング
                        foreach (vw_tr_chosei_01 item in results)
                        {
                            string dtHizuke = item.dt_hizuke.Value.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, dtHizuke, 0, true);

                            // 最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_hinmei, 0, true);

                            // 原資材名と製品名：多言語対応を考慮する
                            string nm_hinmei = item.nm_hinmei_en;
                            string nm_seihin = item.nm_seihin_en;
                            if (Resources.LangJa.Equals(lang))
                            {
                                nm_hinmei = item.nm_hinmei_ja;
                                nm_seihin = item.nm_seihin_ja;
                            }
                            else if (Resources.LangZh.Equals(lang))
                            {
                                nm_hinmei = item.nm_hinmei_zh;
                                nm_seihin = item.nm_seihin_zh;
                            }
                            else if (Resources.LangVi.Equals(lang))
                            {
                                nm_hinmei = item.nm_hinmei_vi;
                                nm_seihin = item.nm_seihin_vi;
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, nm_hinmei, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, nm_seihin, 0, true);

                            // 品区分
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_kbn_hin, 0, true);
                            // 荷姿
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_nisugata, 0, true);
                            // 使用単位
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.tani_shiyo, 0, true);
                            // 調整数
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.su_chosei.ToString(), indexSpCom3, false);
                            // 調整理由
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.nm_riyu, fmtString, true);
                            // 備考
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.biko, fmtString, true);
                            // 原価発生部署
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.nm_genka_center, 0, true);
                            // 倉庫
                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.nm_soko, 0, true);                           
                            // 製品コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.cd_seihin, 0, true);
                            // 更新者
                            ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.nm_update, 0, true);
                            // 更新日付
                            string dt_update = item.dt_update.AddHours(-(UTC)).ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
                            ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, dt_update, 0, true);

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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.GenshizaichoseinyuryokuExcelIkatsuDialogCookie, Resources.CookieValue);
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
    }
}