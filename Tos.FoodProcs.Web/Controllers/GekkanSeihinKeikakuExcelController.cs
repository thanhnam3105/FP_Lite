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
    /// 月間製品計画ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GekkanSeihinKeikakuExcelController : ApiController
    {
        // HTTP:GET出力
        public HttpResponseMessage Get([FromUri]GekkanSeihinKeikakuCriteria criteria,
            string lang, int UTC, string userName, bool isAllLine, DateTime today)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();

                // 変数
                short isAllLineValue = isAllLine == true ? ActionConst.FlagTrue : ActionConst.FlagFalse;
                char[] alpha;
                
                // 検索実行
                IEnumerable<usp_GekkanSeihinKeikaku_select_Result> views;
                var count = new ObjectParameter("count", 0);
                views = context.usp_GekkanSeihinKeikaku_select(
                    criteria.cd_shokuba
                    , criteria.cd_line
                    , short.Parse(criteria.cd_riyu)
                    , ActionConst.FlagFalse
                    , criteria.dt_hiduke_from
                    , criteria.dt_hiduke_to
                    , isAllLineValue  // 全ライン出力
                    , ActionConst.FlagTrue  // エクセル出力かどうか
                    , ActionConst.FlagTrue
                    , ActionConst.FlagFalse
                    , criteria.skip
                    , criteria.top
                    , count
                ).ToList();

                //// ファイル名の指定
                string templateName;
                if (isAllLine == false)
                {
                    // 一ライン出力
                    templateName = "gekkanSeihinKeikakuTanLine";
                    alpha = "ABCDEFGHIJK".ToCharArray();
                }
                else
                {
                    // 全ライン出力
                    templateName = "gekkanSeihinKeikakuZenLine";
                    alpha = "ACDEFGHIJKLB".ToCharArray(); // Bにライン名を出力
                }

                string excelname = Resources.GekkanSeihinKeikakuExcelName; // 出力ファイル名
                
                // 検索に指定した日
                DateTime searchDate = criteria.dt_hiduke_from.AddHours(-(UTC));
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

                        // ===== 書式設定の追加
                        // カンマ区切り、小数点以下なし
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // カンマ区切り、小数点以下2桁
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        // 検索日
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", searchDate.ToString(Resources.YearMonth), 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", criteria.nm_shokuba, 0, true);
                        if (!isAllLine)
                        {
                            // ライン名
                            ExcelUtilities.UpdateValue(wbPart, ws, "B4", criteria.nm_line, 0, true);
                            setOutputDateAndUser(wbPart, ws, "B6", "B7", lang, today, userName);
                        }
                        else
                        {
                            // 全ライン出力の場合、検索条件にラインは表示しない
                            setOutputDateAndUser(wbPart, ws, "B5", "B6", lang, today, userName);
                        }
                        // 計算結果
                        decimal? seizoYoteiSu = 0;
                        decimal? seizoJissekiSu = 0;

                        // 明細行開始ポイント
                        int index = 9;
                        if (!isAllLine)
                        {
                            // 単ライン出力の場合は検索条件にラインが表示されるので+1
                            index++;
                        }
                        
                        // シートデータへ値をマッピング
                        foreach (usp_GekkanSeihinKeikaku_select_Result item in views)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します

                            // 休日理由
                            ExcelUtilities.UpdateValue(wbPart, ws, alpha[0].ToString() + index, item.nm_riyu, 0, true);
                            // 日と曜日
                            DateTime seizoDate = item.dt_seizo.AddHours(-(UTC));
                            ExcelUtilities.UpdateValue(wbPart, ws, alpha[1].ToString() + index, seizoDate.ToString("dd"), 0, true);
                            //ExcelUtilities.UpdateValue(wbPart, ws, alpha[2].ToString() + index, seizoDate.ToString(ActionConst.DatetimeFormatYobi), 0, true);
                            String yobiData = seizoDate.ToString(ActionConst.DatetimeFormatYobi);
                            if (lang == "zh") 
                            {
                                // 中国語の曜日は画面のフォーマットに合わせ『一,二,三,四,五,六,日』のみを表示します。
                                yobiData = yobiData.Replace("周", "");
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, alpha[2].ToString() + index, yobiData, 0, true);
                            // コード
                            ExcelUtilities.UpdateValue(wbPart, ws, alpha[3].ToString() + index, item.cd_hinmei, 0, true);
                            // 製品名：多言語対応を考慮する
                            string hinmei = GetName(lang, item.nm_hinmei_ja, item.nm_hinmei_en, item.nm_hinmei_zh, item.nm_hinmei_vi);
                            ExcelUtilities.UpdateValue(wbPart, ws, alpha[4].ToString() + index, hinmei, 0, true);
                            // 荷姿
                            ExcelUtilities.UpdateValue(wbPart, ws, alpha[5].ToString() + index, item.nm_nisugata_hyoji, 0, true);
                            // 製造数
                            //ExcelUtilities.UpdateValue(wbPart, ws, alpha[6].ToString() + index, item.su_seizo_yotei.ToString(), indexSpNoCom, false);
                            changeNullToBlank(wbPart, ws, alpha[6].ToString() + index, item.su_seizo_yotei, indexSpNoCom, lang);
                            // 実績数
                            //ExcelUtilities.UpdateValue(wbPart, ws, alpha[7].ToString() + index, item.su_seizo_jisseki.ToString(), indexSpNoCom, false);
                            changeNullToBlank(wbPart, ws, alpha[7].ToString() + index, item.su_seizo_jisseki, indexSpNoCom, lang);
                            // バッチ数
                            //ExcelUtilities.UpdateValue(wbPart, ws, alpha[8].ToString() + index, item.su_batch_keikaku.ToString(), indexSpNoCom, false);
                            changeNullToBlank(wbPart, ws, alpha[8].ToString() + index, item.su_batch_keikaku, indexSpNoCom, lang);
                            // 倍率
                            //ExcelUtilities.UpdateValue(wbPart, ws, alpha[9].ToString() + index, item.ritsu_kihon.ToString(), indexSpCom2, false);
                            changeNullToBlank(wbPart, ws, alpha[9].ToString() + index, item.ritsu_kihon, indexSpCom2, lang);
                            // 製品ロットNo
                            ExcelUtilities.UpdateValue(wbPart, ws, alpha[10].ToString() + index, item.no_lot_seihin, 0, true);
                            if (isAllLine == true)
                            {
                                // ライン名
                                ExcelUtilities.UpdateValue(wbPart, ws, alpha[11].ToString() + index, item.nm_line, 0, true);
                            }
                            // 合計を計算
                            seizoYoteiSu = seizoYoteiSu + (item.su_seizo_yotei == null ? 0 : item.su_seizo_yotei);
                            seizoJissekiSu = seizoJissekiSu + (item.su_seizo_jisseki == null ? 0 : item.su_seizo_jisseki);
                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        // 最終行に計算結果を表示
                        ExcelUtilities.UpdateValue(wbPart, ws, alpha[5].ToString() + index, Resources.GokeiText, 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, alpha[6].ToString() + index, seizoYoteiSu.ToString(), indexSpNoCom, false);
                        ExcelUtilities.UpdateValue(wbPart, ws, alpha[7].ToString() + index, seizoJissekiSu.ToString(), indexSpNoCom, false);
                        ws.Save();
                    }

                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.gekkanSeihinKeikakuCookie, Resources.CookieValue);
                }
            }
            //catch (HttpResponseException ex)
            //{
            //    throw ex;
            //}
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
        /// 出力日時と出力者を設定します
        /// </summary>
        /// <param name="wbPart">WorkbookPart</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="dateAlpha">出力日時のアドレスネーム</param>
        /// <param name="userAlpha">出力者のアドレスネーム</param>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="today">システム日付</param>
        /// <param name="userName">ユーザ名</param>
        private void setOutputDateAndUser(WorkbookPart wbPart, Worksheet ws
            ,string dateAlpha, string userAlpha, string lang, DateTime today, string userName)
        {
            // 出力日時
            string todayStr = today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
            ExcelUtilities.UpdateValue(wbPart, ws, dateAlpha, todayStr, 0, true);
            // 出力者
            ExcelUtilities.UpdateValue(wbPart, ws, userAlpha, userName, 0, true);
        }

        /// <summary>
        /// 多言語対応の名称を返却する
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="name_ja">名称_日本語</param>
        /// <param name="name_en">名称_英語</param>
        /// <param name="name_zh">名称_中国語</param>
        /// /// <param name="name_vi"></param>
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

        /// <summary>
        /// 取得結果がNULLだった場合、空白を設定します
        /// </summary>
        /// <param name="wbPart">WorkbookPart</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="address">アドレスネーム</param>
        /// <param name="value">取得結果</param>
        /// <param name="index">書式番号</param>
        private void changeNullToBlank(WorkbookPart wbPart, Worksheet ws, string address, decimal? value, UInt32 index, string lang)
        {
            if (value == null)
            {
                // NULLだった場合、空白を設定
                ExcelUtilities.UpdateValue(wbPart, ws, address, "", 0, true);
            }
            else
            {
                string val = value.ToString();
                switch (lang)
                {
                    case "vi":
                        {
                            val = val.Replace(',', '.');
                            break;
                        }
                    default: break;
                }
                ExcelUtilities.UpdateValue(wbPart, ws, address, val, index, false);
            }
        }
    }
}