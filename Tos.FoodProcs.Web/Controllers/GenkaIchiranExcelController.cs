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
    /// 原価一覧ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenkaIchiranExcelController : ApiController
    {
        // HTTP:GET
        public HttpResponseMessage Get([FromUri]GenkaKeisanCriteria criteria)
        {
            // ブラウザ言語
            string lang = criteria.lang;

            try
            {
                // ファイル名の指定
                string templateName = "genkaIchiran"; // return形式 "_lang.xlsx" 
                string excelname = Resources.GenkaIchiranExcel; // 出力ファイル名 拡張子は不要

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
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        UInt32 indexStr = FoodProcsCommonUtility.ExcelCellFormatAlign(sheet);
                        
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        //int addHours = 9;   // UTC用9h+

                        ///// Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        // 検索条件
                        // 年月
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", criteria.nengetsu, 0, true);
                        // 職場
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", criteria.shokubaName, 0, true);
                        // ライン
                        ExcelUtilities.UpdateValue(wbPart, ws, "B4", criteria.lineName, 0, true);
                        // 分類
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", criteria.bunrui, 0, true);
                        // 製品コード
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", criteria.cd_hinmei, 0, true);
                        // 製品名
                        ExcelUtilities.UpdateValue(wbPart, ws, "B7", criteria.hinmei, 0, true);
                        // 単価設定
                        ExcelUtilities.UpdateValue(wbPart, ws, "B8", criteria.tankaSettei, 0, true);
                        // マスタ単価使用
                        ExcelUtilities.UpdateValue(wbPart, ws, "B9", criteria.masterTanka, 0, true);

                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, "B11", criteria.today.ToString(
                            FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B12", criteria.userName, 0, true);

                        // 明細行開始ポイント
                        int index = 15;

                        // Entity取得
                        IEnumerable<usp_GenkaIchiran_select_Result> results;
                        results = GetEntity(criteria);
                        // シートデータへ値をマッピング
                        foreach (usp_GenkaIchiran_select_Result item in results)
                        {                            
                            ///// 最後の項目(isString)は文字列でTrue, 数値でfalse を渡します

                            // ----- 明細の計算処理
                            // 製造数
                            decimal su_seizo = (decimal)item.su_seizo_jisseki;
                            // 原料
                            decimal genryo = (decimal)item.kin_genryo;
                            // 資材
                            decimal shizai = (decimal)item.kin_shizai;
                            // 原価単価_CS
                            decimal genka_cs = (decimal)item.tan_genka_cs;
                            // 原価単価_労務
                            decimal genka_romu = (decimal)item.tan_genka_romu;
                            // 原価単価_経費
                            decimal genka_keihi = (decimal)item.tan_genka_keihi;
                            // 金額：製造数ｘ原価単価_CS
                            decimal kingaku = su_seizo * genka_cs;
                            // 材料費計：原料＋資材
                            decimal zairyo = genryo + shizai;
                            // 労務費：製造数ｘ原価単価_労務
                            decimal romu = su_seizo * genka_romu;
                            // 経費：製造数ｘ原価単価_経費
                            decimal keihi = su_seizo * genka_keihi;
                            // 経費計：労務費＋経費
                            decimal keihiTotal = romu + keihi;
                            // 原価：材料費計＋経費計
                            decimal genka = zairyo + keihiTotal;
                            // 粗利：金額－原価
                            decimal arari = kingaku - genka;


                            // 製品コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.cd_hinmei, indexStr, true);
                            // 製品名
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, GetSeihinName(item, lang), indexStr, true);
                            // 荷姿
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_nisugata_hyoji, indexStr, true);
                            // 製品数
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "D" + index, su_seizo, indexSpNoCom, lang);
                            // C/S単価
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "E" + index, genka_cs, indexSpNoCom, lang);
                            // 金額
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "F" + index, kingaku, indexSpNoCom, lang);
                            // 原料費
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "G" + index, genryo, indexSpNoCom, lang);
                            // 資材費
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "H" + index, shizai, indexSpNoCom, lang);
                            // 材料費計
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "I" + index, zairyo, indexSpNoCom, lang);
                            // 労務費
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "J" + index, romu, indexSpNoCom, lang);
                            // 経費
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "K" + index, keihi, indexSpNoCom, lang);
                            // 経費計
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "L" + index, keihiTotal, indexSpNoCom, lang);
                            // 原価
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "M" + index, genka, indexSpNoCom, lang);
                            // 粗利
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "N" + index, arari, indexSpNoCom, lang);

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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.genkaIchiranCookie, Resources.CookieValue);
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
        /// <param name="criteria">検索条件</param>
        /// <returns>明細データ</returns>
        private IEnumerable<usp_GenkaIchiran_select_Result> GetEntity(GenkaKeisanCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenkaIchiran_select_Result> views;
            views = context.usp_GenkaIchiran_select(
                    criteria.dt_from
                    , criteria.dt_to
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_shokuba)
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_line)
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_bunrui)
                    , FoodProcsCommonUtility.changedNullToEmpty(criteria.cd_hinmei)
                    , criteria.tanka_settei
                    , criteria.master_tanka
                    , ActionConst.YoteiYojitsuFlag
                    , ActionConst.JissekiYojitsuFlag
                    , ActionConst.FlagTrue
                    , ActionConst.FlagFalse
                    , ActionConst.TanaoroshiTankaKbn
                    , ActionConst.NonyuTankaKbn
                    , ActionConst.RomuhiTankaKbn
                    , ActionConst.KeihiTankaKbn
                    , ActionConst.CsTankaTankaKbn
                    , ActionConst.GenryoHinKbn
                    , ActionConst.ShizaiHinKbn
                ).AsEnumerable();

            return views;
        }

        /// <summary>
        /// 製品名を返却します：多言語対応を考慮
        /// </summary>
        /// <param name="item">明細データ</param>
        /// <param name="lang">ブラウザ言語</param>
        /// <returns>製品名</returns>
        private string GetSeihinName(usp_GenkaIchiran_select_Result item, string lang)
        {
            string nmSeihin = item.nm_hinmei_en;
            if (Resources.LangJa.Equals(lang))
            {
                nmSeihin = item.nm_hinmei_ja;
            }
            else if (Resources.LangZh.Equals(lang))
            {
                nmSeihin = item.nm_hinmei_zh;
            }
            else if (Resources.LangVi.Equals(lang))
            {
                nmSeihin = item.nm_hinmei_vi;
            }
            return nmSeihin;
        }
    }
}