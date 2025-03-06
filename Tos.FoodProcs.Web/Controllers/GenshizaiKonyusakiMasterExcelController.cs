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
    /// 原資材購入先マスタExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiKonyusakiMasterExcelController : ApiController
    {
        // HTTP:GET 選択言語がjaの場合の出力
        public HttpResponseMessage Get(ODataQueryOptions<vw_ma_konyu_02> options, String lang, String hinCode, String hinName,
            String userName, DateTime today)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();
                IQueryable results = options.ApplyTo(context.vw_ma_konyu_02.AsQueryable());

                short kbnHasu = ActionConst.kbn_tani_nonyu_hasu;
                var Hasu = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == kbnHasu
                                select ma).FirstOrDefault();
                string templateName;
                if (Hasu.kbn_kino_naiyo == ActionConst.tani_nonyu_hasu_shiyo)
                {
                    // データソースxmlを作成します
                    templateName = "genshizaiKonyusakiMaster_hasuAri";
                }
                else
                {
                    // データソースxmlを作成します
                    templateName = "genshizaiKonyusakiMaster";
                }

                // ファイル名の指定
                //string templateName = "genshizaiKonyusakiMaster"; // return形式 "_lang.xlsx" 
                string excelname = Resources.GenshizaiKonyusakiMasterExcel; // 出力ファイル名 拡張子は不要
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
                        UInt32 indexSpCom4 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma4, ActionConst.idSplitComma4);
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);
                        UInt32 indexSpCom6 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma6, ActionConst.idSplitComma6);
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // 数値以外：下詰め、折り返し
                        UInt32 fmtString = FoodProcsCommonUtility.ExcelCellFormatAlign(sheet);
                        
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        // 検索条件
                        // 原資材コード
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", FoodProcsCommonUtility.changedNullToEmpty(hinCode), 0, true);
                        // 原資材名
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", FoodProcsCommonUtility.changedNullToEmpty(hinName), 0, true);

                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", userName, 0, true);

                        // 明細行開始ポイント
                        int index = 9;

                        // シートデータへ値をマッピング
                        foreach (vw_ma_konyu_02 item in results)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.cd_hinmei, 0, true);

                            // 多言語対応を考慮する
                            // 原資材名
                            if (Resources.LangJa.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_hinmei_ja, 0, true);
                            }
                            else if (Resources.LangZh.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_hinmei_zh, 0, true);
                            }
                            else if (Resources.LangVi.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_hinmei_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_hinmei_en, 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.no_juni_yusen.ToString(), 0, false);
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.cd_torihiki, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_torihiki, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_nisugata_hyoji, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.tani_nonyu, 0, true);

                            if (Hasu.kbn_kino_naiyo != ActionConst.tani_nonyu_hasu_shiyo)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.tan_nonyu.ToString(), indexSpCom4, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "I" + index, item.tan_nonyu_new, indexSpCom4, lang);

                                // 新単価切替日：nullの場合は空白を設定する
                                String newTanNonyuDate = GetNewNonyuTankaDate(item, lang);
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, newTanNonyuDate, 0, true);

                                ExcelUtilities.changeNullToBlank(wbPart, ws, "K" + index, item.su_hachu_lot_size, indexSpCom2, lang);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "L" + index, item.wt_nonyu, indexSpCom6, lang);
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.su_iri.ToString(), indexSpNoCom, false);
                                ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.su_leadtime.ToString(), 0, false);
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, item.cd_torihiki2, 0, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, item.nm_torihiki2, 0, true);

                                // 未使用フラグ
                                if (short.Parse(Resources.FlagFalse) == item.flg_mishiyo)
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, Resources.Shiyo, 0, true);
                                }
                                else
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, Resources.Mishiyo, 0, true);
                                }
                            }
                            else {
                                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.tani_nonyu_hasu, 0, true);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "I" + index, item.tan_nonyu, indexSpCom4, lang);
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.tan_nonyu_new.ToString(), indexSpCom4, false);

                                // 新単価切替日：nullの場合は空白を設定する
                                String newTanNonyuDate = GetNewNonyuTankaDate(item, lang);
                                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, newTanNonyuDate, 0, true);

                                ExcelUtilities.changeNullToBlank(wbPart, ws, "L" + index, item.su_hachu_lot_size, indexSpCom2, lang);
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.wt_nonyu.ToString(), indexSpCom6, false);
                                ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.su_iri.ToString(), indexSpNoCom, false);
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, item.su_leadtime.ToString(), 0, false);
                                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, item.cd_torihiki2, 0, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.nm_torihiki2, 0, true);

                                // 未使用フラグ
                                if (short.Parse(Resources.FlagFalse) == item.flg_mishiyo)
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, Resources.Shiyo, 0, true);
                                }
                                else
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, Resources.Mishiyo, 0, true);
                                }
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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.genshizaiKonyusakiMasterCookie, Resources.CookieValue);
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

        /// <summary>新単価切替日を取得します。
        /// nullの場合は空文字を設定します。
        /// 値がある場合はyyyy/MM/ddにフォーマットします。</summary>
        /// <param name="value">新単価切替日</param>
        /// <returns>新単価切替日</returns>
        private String GetNewNonyuTankaDate(vw_ma_konyu_02 item, string lang)
        {
            String result = "";
            if (item.dt_tanka_new != null)
            {
                //int addHours = 9;   // UTC用9h+
                DateTime valDate = (DateTime)item.dt_tanka_new;
                //result = valDate.AddHours(addHours).ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                result = valDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
            }
            return result;
        }
    }
}