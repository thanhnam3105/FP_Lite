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
using System.Globalization;


namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 変動表シミュレーションExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class HendoHyoSimulationExcelController : ApiController
    {
        /// <summary>セル番地（納入数/製造数）：C8</summary>
        private const string ITEM_HEAD_NONYU = "B15";

        // HTTP:GET 選択言語がjaの場合の出力
        public HttpResponseMessage Get(
            [FromUri]HendoHyoSimulationCriteria criteria,
            String lang,
            String hdCdGenshizai,
            String hdNmGenshizai,
            String cdSeihin,
            String nmSeihin,
            String seizoYotei,
            String afterChange,
            String nmGenshizai,
            String taniShiyo,
            String zaikoMin,
            decimal befWtShiyo,
            decimal aftWtShiyo,
            String strSeizoYotei,
            String strAfterChange,
            String userName,
            DateTime outputDate,
            DateTime today,
            String itemHeadNonyu) {
            try {
                FoodProcsEntities context = new FoodProcsEntities();
                IEnumerable<usp_HendoHyoSimulation_select_Result> selectResult;
                selectResult = context.usp_HendoHyoSimulation_select(
                    criteria.con_cd_hinmei,
                    criteria.con_dt_hizuke,
                    criteria.flg_one_day,
                    criteria.flg_yojitsu_yo,
                    criteria.flg_yojitsu_ji,
                    ActionConst.KgKanzanKbn,
                    ActionConst.LKanzanKbn,
                    ActionConst.FlagFalse,
                    ActionConst.kbn_zaiko_ryohin,
                    today
                ).AsEnumerable();

                // テンプレートファイル名：return形式 "_lang.xlsx"
                string templateName = "hendoHyoSimulation";
                // 出力ファイル名：拡張子不要
                string excelName = Resources.HendoHyoSimulationExcel;
                // パスの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                // テンプレートファイル名：パス・多言語対応指定
                string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, lang);

                // テンプレートファイルを読み込み、必要な情報をマッピングしてクライアントへ返却
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
                        if (lang != Properties.Resources.LangVi)
                        {
                            sheet.NumberingFormats = new NumberingFormats();
                        }
                        // カンマ区切り、小数点以下2桁
                        /*UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);*/
                        // カンマ区切り、小数点以下3桁
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // ヘッダー行出力
                        // 検索条件/検索日付
                        string searchDate = criteria.con_dt_hizuke.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        ExcelUtilities.UpdateValue(wbPart, ws, "C2", searchDate, 0, true);
                        // 検索条件/製品コード
                        ExcelUtilities.UpdateValue(wbPart, ws, "C3", cdSeihin, 0, true);
                        // 検索条件/製品名
                        ExcelUtilities.UpdateValue(wbPart, ws, "C4", nmSeihin, 0, true);
                        // 検索条件/製造予定
                        ExcelUtilities.UpdateValue(wbPart, ws, "C5", strSeizoYotei, 0, true);
                        // 検索条件/変更後
                        ExcelUtilities.UpdateValue(wbPart, ws, "C6", strAfterChange, 0, true);
                        // 検索条件ヘッダー/原資材コード
                        ExcelUtilities.UpdateValue(wbPart, ws, "A7", hdCdGenshizai, 0, true);
                        // 検索条件/原資材コード
                        ExcelUtilities.UpdateValue(wbPart, ws, "C7", criteria.con_cd_hinmei, 0, true);
                        // 検索条件ヘッダー/原資材名
                        ExcelUtilities.UpdateValue(wbPart, ws, "A8", hdNmGenshizai, 0, true);
                        // 検索条件/原資材名
                        ExcelUtilities.UpdateValue(wbPart, ws, "C8", nmGenshizai, 0, true);
                        // 検索条件/使用単位
                        ExcelUtilities.UpdateValue(wbPart, ws, "C9", taniShiyo, 0, true);
                        // 検索条件/最低在庫
                        ExcelUtilities.UpdateValue(wbPart, ws, "C10", FoodProcsCommonUtility.changedNullToEmpty(zaikoMin), 0, true);
                        // 出力日時
                        ExcelUtilities.UpdateValue(wbPart, ws, "C12", outputDate.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "C13", userName, 0, true);

                        // 明細ヘッダー/納入数：自家原料の場合は製造数になる
                        ExcelUtilities.UpdateValue(wbPart, ws, ITEM_HEAD_NONYU, itemHeadNonyu, 0, true);

                        // 明細出力行インデックス(初期値に開始行数を設定)
                        int index = 16;

                        // 明細行出力
                        foreach (usp_HendoHyoSimulation_select_Result item in selectResult)
                        {
                            // 明細/日
                            if (lang == Resources.LangJa || lang == Resources.LangZh || CultureInfo.CurrentUICulture.Name == "en-US")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, String.Format("{0:MM/dd}", item.dt_hizuke), 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, String.Format("{0:dd/MM}", item.dt_hizuke), 0, true);
                            }
                            // 明細/納入数
                            //SetNumberValue(wbPart, ws, "B" + index, item.before_su_nonyu.ToString(), indexSpCom2);
                            //SetNumberValue(wbPart, ws, "B" + index, item.before_su_nonyu.ToString(), indexSpCom3);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "B" + index, item.before_su_nonyu, indexSpCom3, lang);
                            // 明細/変更前使用量
                            decimal after_shiyo = item.before_wt_shiyo != null ? (decimal)item.before_wt_shiyo : 0;
                            //after_shiyo = FoodProcsCommonUtility.decimalCeiling(after_shiyo, 2);
                            //SetNumberValue(wbPart, ws, "C" + index, after_shiyo.ToString(), indexSpCom2);
                            //SetNumberValue(wbPart, ws, "C" + index, after_shiyo.ToString(), indexSpCom3);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "C" + index, after_shiyo, indexSpCom3, lang);
                            // 検索条件/検索日付当日の場合
                            if (item.dt_hizuke == criteria.con_dt_hizuke)
                            {
                                // 明細/変更後使用量
                                decimal before_wt_shiyo = item.before_wt_shiyo != null ? (decimal)item.before_wt_shiyo : 0;
                                //before_wt_shiyo = TruncateSpCom2(before_wt_shiyo);
                                //before_wt_shiyo = FoodProcsCommonUtility.decimalCeiling(before_wt_shiyo, 2);
                                //SetNumberValue(wbPart, ws, "D" + index, (before_wt_shiyo - befWtShiyo + aftWtShiyo).ToString(), indexSpCom2);
                                //SetNumberValue(wbPart, ws, "D" + index, (before_wt_shiyo - befWtShiyo + aftWtShiyo).ToString(), indexSpCom3);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "D" + index, (before_wt_shiyo - befWtShiyo + aftWtShiyo), indexSpCom3, lang);
                            }
                            // 明細/変更前在庫量
                            //string befZaiko = calcZaiko((decimal)item.before_wt_zaiko).ToString();
                            string befZaiko = item.before_wt_zaiko.ToString();
                            //ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, befZaiko, indexSpCom2, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, befZaiko, indexSpCom3, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "E" + index, item.before_wt_zaiko, indexSpCom3, lang);
                            if (item.dt_hizuke >= criteria.con_dt_hizuke)
                            {
                                // 検索条件/検索日付以降の場合

                                // 明細/変更後在庫量
                                //decimal before_wt_zaiko = calcZaiko((decimal)item.before_wt_zaiko);
                                decimal before_wt_zaiko = item.before_wt_zaiko != null ? (decimal)item.before_wt_zaiko : 0;
                                //before_wt_zaiko = calcZaiko(before_wt_zaiko);
                                decimal afZaiko = before_wt_zaiko + befWtShiyo - aftWtShiyo;
                                //string afZaikoStr = TruncateSpCom2(afZaiko).ToString();
                                //ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, afZaikoStr, indexSpCom2, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, afZaiko.ToString(), indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "F" + index, afZaiko, indexSpCom3, lang);
                            }
                            else
                            {
                                // 検索条件/検索日付より過去日の場合

                                // 明細/変更後在庫量
                                //ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, befZaiko, indexSpCom2, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, befZaiko, indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "F" + index, item.before_wt_zaiko, indexSpCom3, lang);
                            }

                            // 明細出力行インデックスのカウントアップ
                            index++;
                        }
                        // ワークシートの保存
                        ws.Save();
                    }

                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    // レポートの取得
                    string reportname = excelName + ".xlsx";
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.hendoHyoSimulationCookie, Resources.CookieValue);
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

        /// <summary>数値系項目のマッピング処理。nullまたは0の場合は空白を設定します。</summary>
        /// <param name="wbPart">ワークブック</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="cellNo">設定するセル番号</param>
        /// <param name="item">設定する値</param>
        /// <param name="fmt">書式番号</param>
        private void SetNumberValue(WorkbookPart wbPart, Worksheet ws, String cellNo, String item, UInt32 fmt)
        {
            String value = item;
            bool isStr = false;
            if (String.IsNullOrEmpty(value) || decimal.Parse(value) == 0)
            {
                value = "";
                isStr = true;
                fmt = 0;
            }
            /*else
            {
                value = TruncateSpCom2(decimal.Parse(value)).ToString();
            }*/
            ExcelUtilities.UpdateValue(wbPart, ws, cellNo, value, fmt, isStr);
        }
        /*
        /// <summary>
        /// 小数点以下2桁にする。3桁目以降は切り捨て。
        /// </summary>
        /// <param name="value">値</param>
        /// <returns>変換後の値</returns>
        private decimal TruncateSpCom2(decimal value)
        {
            decimal val = FoodProcsCommonUtility.decimalTruncate(value, 2);
            return val;
        }*/
        /*
        /// <summary>
        /// 在庫数の計算処理。
        /// 画面の四捨五入に合わせた処理を行う。
        /// </summary>
        /// <param name="value">値</param>
        /// <returns>在庫数</returns>
        private decimal calcZaiko(decimal value)
        {
            decimal val = FoodProcsCommonUtility.decimalRound(value, 2);
            return val;
        }*/
    }
}