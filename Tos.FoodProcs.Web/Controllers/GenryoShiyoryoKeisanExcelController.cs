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
    /// 原料使用量計算画面：ExcelFile作成コントローラを定義します。
    /// →庫出依頼画面に名称変更(2014.11.10)
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenryoShiyoryoKeisanExcelController : ApiController
    {
        // 定数設定
        /// <summary>検索条件のセルX番地：B</summary>
        private const string COL_SEARCH = "B";

        // HTTP:GET
        public HttpResponseMessage Get([FromUri]GenshizaiShiyoryoKeisanCriteria criteria, String lang, DateTime outputDate)
        {
            try
            {
                // ファイル名の指定
                //string templateName = "genryoShiyoryoKeisan"; // return形式 "_lang.xlsx" 
                string templateName = "kuradashiIrai"; // return形式 "_lang.xlsx" 
                string excelname = Resources.GenryoShiyoryoKeisanExcel; // 出力ファイル名 拡張子は不要

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

                        ///// 書式設定の追加
                        sheet.NumberingFormats = new NumberingFormats();
                        // カンマ区切り、小数点以下3桁
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        // カンマ区切り、小数点なし
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // 数値以外：下詰め、折り返し
                        UInt32 fmtString = FoodProcsCommonUtility.ExcelCellFormatAlign(sheet);
                        Worksheet ws =  ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                         {
                             f.FontName = new FontName() { Val = Resources.DefaultFontName };
                         }
                        ///// ヘッダー行をセット
                        // 検索条件日付
                        ExcelUtilities.UpdateValue(wbPart, ws, COL_SEARCH + "2",
                            criteria.con_hizuke.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                        // 品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, COL_SEARCH + "3", criteria.hinKubunName, 0, true);
                        // 分類
                        ExcelUtilities.UpdateValue(wbPart, ws, COL_SEARCH + "4", criteria.bunruiName, 0, true);
                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, COL_SEARCH + "6",
                            outputDate.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, COL_SEARCH + "7", criteria.userName, 0, true);

                        // 明細行開始ポイント
                        int index = 10;

                        IEnumerable<usp_GenshizaiShiyoryoKeisan_select_Result> results;
                        results = GetEntity(criteria);
                        
                        ///// シートデータへ値をマッピング
                        foreach (usp_GenshizaiShiyoryoKeisan_select_Result item in results)
                        {
                            ///// 最後の項目(isString)は文字列でTrue, 数値でfalse を渡します

                            // 出庫日
                            DateTime shukkoDate = (DateTime)item.dt_shukko;
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index,
                                shukkoDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), fmtString, true);
                            // 原資材コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_hinmei, fmtString, true);
                            // 原資材名
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, getGenryoName(lang, item), fmtString, true);
                            // 荷姿
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_nisugata_hyoji, fmtString, true);
                            // 使用単位
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_tani, fmtString, true);

                            // 使用予定量、前日残、必要量の設定
                            decimal shiyo_yoteiryo =  FoodProcsCommonUtility.decimalTruncate((decimal)item.su_shiyo_sum, 3);
                            decimal zenjitsu_zan = FoodProcsCommonUtility.decimalTruncate((decimal)item.wt_shiyo_zan, 3);
                            decimal hitsuyoryo = FoodProcsCommonUtility.decimalTruncate(shiyo_yoteiryo - zenjitsu_zan, 3);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "F" + index, shiyo_yoteiryo, indexSpCom3, lang);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "G" + index, zenjitsu_zan, indexSpCom3, lang);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "H" + index, hitsuyoryo, indexSpCom3, lang);

                            // 庫出単位
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.nm_tani_kuradashi, fmtString, true);

                            // 庫出依頼数
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.su_kuradashi.ToString(), indexSpNoCom, false);
                            // 庫出依頼端数
                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.su_kuradashi_hasu.ToString(), indexSpNoCom, false);
                            // 確定
                            string kakuteiFlg = "";
                            if (item.flg_kakutei == ActionConst.FlagTrue)
                            {
                                kakuteiFlg = Resources.Kakutei;
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, kakuteiFlg, fmtString, true);
                            // ステータス
                            string status = Resources.MishiyoShort;
                            if (item.kbn_status == ActionConst.FlagTrue)
                            {
                                status = Resources.Sumi;
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, status, fmtString, true);
                            // 分類
                            ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.nm_bunrui, fmtString, true);

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
                   // return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.genryoShiyoKeisanCookie, Resources.CookieValue);
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

        /// <summary>
        /// 明細データを取得します。
        /// </summary>
        /// <param name="searchDate">検索条件/日付</param>
        /// <param name="searchBunrui">検索条件/分類</param>
        /// <param name="hinKubun">品区分：原料</param>
        /// <param name="flgYojitsu">予実フラグ</param>
        /// <returns>取得した検索結果</returns>
        private IEnumerable<usp_GenshizaiShiyoryoKeisan_select_Result> GetEntity(
            GenshizaiShiyoryoKeisanCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiShiyoryoKeisan_select_Result> views;
            views = context.usp_GenshizaiShiyoryoKeisan_select(
                criteria.con_hizuke,
                FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui),
                criteria.hinKubun,
                criteria.flg_yojitsu,
                ActionConst.FlagFalse,
                ActionConst.GenryoHinKbn,
                ActionConst.ShizaiHinKbn,
                ActionConst.JikaGenryoHinKbn,
                ActionConst.LKanzanKbn,
                criteria.utc
            ).AsEnumerable();

            return views;
        }

        /// <summary>
        /// 多言語対応した原料名を返却
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="item">検索結果</param>
        /// <returns>原料名</returns>
        private string getGenryoName(string lang, usp_GenshizaiShiyoryoKeisan_select_Result item)
        {
            // デフォルトはen
            string genryoName = item.nm_hinmei_en;
            if (Resources.LangJa.Equals(lang))
            {
                // ja：日本
                genryoName = item.nm_hinmei_ja;
            }
            else if (Resources.LangZh.Equals(lang))
            {
                // zh：中国
                genryoName = item.nm_hinmei_zh;
            }
            else if (Resources.LangVi.Equals(lang))
            {
                // zh：中国
                genryoName = item.nm_hinmei_vi;
            }
            return genryoName;
        }
    }
}