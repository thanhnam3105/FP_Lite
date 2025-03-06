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
    /// 仕込計画表ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class ShikomiKeikakuHyoExcelController : ApiController
    {
        // HTTP:GET 選択言語がjaの場合の出力
        public HttpResponseMessage Get([FromUri]ShikakarihinShikomiKeikakuCriteria criteria,
            string lang, int UTC, string userName, DateTime outputDate)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();
                
                
                IEnumerable<usp_ShikomiKeikakuHyoExcel_select_Result> views;
                var count = new ObjectParameter("count", 0);
                views = context.usp_ShikomiKeikakuHyoExcel_select(
                    criteria.cd_shokuba
                    , criteria.cd_line
                    , criteria.dt_hiduke
                    , short.Parse(criteria.flg_kakutei)
                    , short.Parse(criteria.flg_mikakutei)
                    , short.Parse(Resources.FlagTrue)
                    , short.Parse(Resources.FlagFalse)
                ).ToList();


                // ファイル名の指定
                string templateName = "shikomiKeikakuHyo"; // return形式 "_lang.xlsx" 
                string excelname = Resources.ShikomiKeikakuHyo; // 出力ファイル名 拡張子は不要
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

                        // 書式設定の追加
                        sheet.NumberingFormats = new NumberingFormats();
                        // カンマ区切り、小数点以下なし
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // カンマ区切り、小数点以下2桁
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);
                        // カンマ区切り、小数点以下3桁
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        // カンマ区切り、小数点以下6桁
                        UInt32 indexSpCom6 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma6, ActionConst.idSplitComma6);
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }
                        

                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行（検索条件）をセット
                        // 検索日
                        DateTime searchDate = (criteria.dt_hiduke).AddHours(-(UTC));
                        ExcelUtilities.UpdateValue(wbPart, ws, "C2", searchDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                        // 職場名
                        ExcelUtilities.UpdateValue(wbPart, ws, "C3", criteria.nm_shokuba, 0, true);
                        // ライン名
                        ExcelUtilities.UpdateValue(wbPart, ws, "C4", criteria.nm_line, 0, true);
                        // 確定選択
                        string kakuteiSentaku = criteria.flg_kakutei == Resources.FlagTrue ? Resources.SelectConditionExcel: Resources.NoSelectConditionExcel;
                        ExcelUtilities.UpdateValue(wbPart, ws, "C5", kakuteiSentaku, 0, true);
                        // 未確定選択
                        string mikakuteiSentaku = criteria.flg_mikakutei == Resources.FlagTrue ? Resources.SelectConditionExcel : Resources.NoSelectConditionExcel;
                        ExcelUtilities.UpdateValue(wbPart, ws, "C6", mikakuteiSentaku, 0, true);
                        
                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, "C8", outputDate.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "C9", userName, 0, true);

                        // 変数宣言
                        int index = 13; // 明細行開始ポイント
                        string kakuteiText;
                        string labelFragText;

                        // シートデータへ値をマッピング
                        foreach (usp_ShikomiKeikakuHyoExcel_select_Result item in views)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            // 行番号
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.row.ToString() , 0, false);
                            // 確定
                            kakuteiText = item.flg_shikomi == int.Parse(Resources.FlagTrue) ? Resources.Kakutei : string.Empty;
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, kakuteiText, 0, true);
                            // ライン名
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_line, 0, true);
                            // 仕掛品名：多言語対応を考慮する
                            string nm_haigo = item.nm_haigo_en;
                            if (Resources.LangJa.Equals(lang))
                            {
                                nm_haigo = item.nm_haigo_ja;
                            }
                            else if (Resources.LangZh.Equals(lang))
                            {
                                nm_haigo = item.nm_haigo_zh;
                            }
                            else if (Resources.LangVi.Equals(lang))
                            {
                                nm_haigo = item.nm_haigo_vi;
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, FoodProcsCommonUtility.changedNullToEmpty(nm_haigo), 0, true);
                            // 使用単位
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_tani, 0, true);
                            // 必要量
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "F" + index, item.wt_hitsuyo, indexSpCom3, lang);
                            // 仕込量
                            // ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.wt_shikomi_keikaku.ToString(), indexSpCom6, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "G" + index, item.wt_shikomi_keikaku, indexSpCom3, lang);
                            // 倍率(正規)
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "H" + index, item.ritsu_keikaku, indexSpCom2, lang);
                            // 倍率(端数)
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "I" + index, item.ritsu_keikaku_hasu, indexSpCom2, lang);
                            // バッチ数(正規)
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "J" + index, item.su_batch_keikaku, indexSpNoCom, lang);
                            // バッチ数(端数)
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "K" + index, item.su_batch_keikaku_hasu, indexSpNoCom, lang);
                            // 当仕掛残
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "L" + index, item.wt_zan_shikakari, indexSpCom3, lang);
                            // ラベル合計(正規)
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "M" + index, item.su_label_sumi, indexSpNoCom, lang);
                            // ラベル合計(端数)
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "N" + index, item.su_label_sumi_hasu, indexSpNoCom, lang);
                            // ラベル(正規)
                            labelFragText = item.flg_label == int.Parse(Resources.FlagTrue) ? Resources.Ari : string.Empty;
                            ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, labelFragText, 0, true);
                            // ラベル(端数)
                            labelFragText = item.flg_label_hasu == int.Parse(Resources.FlagTrue) ? Resources.Ari : string.Empty;
                            ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, labelFragText, 0, true);
                            // 仕掛品ロット番号
                            ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.no_lot_shikakari, 0, true);
  
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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.InsatsuSentakuDialogCookie, Resources.CookieValue);
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