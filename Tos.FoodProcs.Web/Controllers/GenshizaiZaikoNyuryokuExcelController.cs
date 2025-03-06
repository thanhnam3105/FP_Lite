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
    /// 在庫入力ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiZaikoNyuryokuExcelController : ApiController
    {
        /// <summary>
        ///  HTTP:GET
        /// </summary>
        /// <param name="criteria">EXCEL出力処理用の情報</param>
        /// <returns>ExcelFileResponse</returns>
        public HttpResponseMessage Get([FromUri]GenshizaiZaikoNyuryokuCriteria criteria)
        {
            string lang = criteria.lang;
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                //IEnumerable<usp_GenshizaiZaikoNyuryoku_select_Result> results;
                //results = GetEntity(options, lang, zaikoDate, hinKubun, hinBunrui, kurabasho, conHinmei, flgShiyobun, flgZaiko);
                FoodProcsEntities context = new FoodProcsEntities();
                short kbnSoko = ActionConst.kbn_soko;
                var Soko = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == kbnSoko
                            select ma).FirstOrDefault();
                string templateName = "genshizaiZaikoNyuryoku";
                int h_Num = 2;
                string h_Alpha = "B";
                int index = 16; // 明細行開始ポイント
                if (Soko.kbn_kino_naiyo == ActionConst.soko_shiyo)
                {
                    // 機能選択マスタの倉庫区分がありの場合
                    templateName = "genshizaiZaikoNyuryoku_sokoAri";
                    index = 17;
                }

                // ファイル名の指定
                //string templateName = "genshizaiZaikoNyuryoku"; // return形式 "_lang.xlsx" 
                string excelname = Resources.GenshizaiZaikoNyuryokuExcel; // 出力ファイル名 拡張子は不要

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
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        UInt32 indexSpCom1 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma1, ActionConst.idSplitComma1);
                        UInt32 indexSpCom6 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma6, ActionConst.idSplitComma6);
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        //int addHours = 9;   // UTC用9h+

                        /// ヘッダー行をセット
                        // 在庫日付
                        //DateTime searchDate = zaikoDate.AddHours(addHours);
                        string searchDate = criteria.con_dt_zaiko.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, searchDate, 0, true);
                        h_Num++;
                        // 品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.hinKubunName, 0, true);
                        h_Num++;
                        // 品分類
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.hinBunruiName, 0, true);
                        h_Num++;
                        // 庫場所
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.kurabashoName, 0, true);
                        h_Num++;
                        if (Soko.kbn_kino_naiyo == ActionConst.soko_shiyo)
                        {
                            // 倉庫
                            ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.sokoName, 0, true);
                            h_Num++;
                        }
                        // 品名
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei), 0, true);
                        h_Num++;
                        // 使用分
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.shiyoubun, 0, true);
                        h_Num++;
                        // 未使用分
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.mishiyoubun, 0, true);
                        h_Num++;
                        // 計算在庫／実在庫ありのみ
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.ariNomi, 0, true);
                        h_Num++;
                        // 在庫区分
                        if (criteria.kbn_zaiko == ActionConst.kbn_zaiko_ryohin)
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, Resources.kbnRyohin, 0, true);
                        }
                        else {
                            ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, Resources.kbnHoryu, 0, true);
                        }
                        h_Num += 2;

                        // 出力日
                        string outputDate = criteria.today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, outputDate, 0, true);
                        h_Num++;
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, h_Alpha + h_Num, criteria.userName, 0, true);

                        // 金額の合計
                        decimal totalKingaku = 0;

                        // Entity取得
                        IEnumerable<usp_GenshizaiZaikoNyuryoku_select_Result> results;
                        results = GetEntity(lang, criteria);
                        // シートデータへ値をマッピング
                        foreach (usp_GenshizaiZaikoNyuryoku_select_Result item in results)
                        {                            
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.nm_bunrui, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_hinmei, 0, true);

                            // 多言語対応を考慮する
                            if (lang == "ja")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_hinmei_ja, 0, true);
                            }
                            else if (lang == "zh")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_hinmei_zh, 0, true);
                            }
                            else if (lang == Properties.Resources.LangVi)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_hinmei_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_hinmei_en, 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_nisugata_hyoji, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.tani_nonyu, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.tani_shiyo, 0, true);

                            // 計算在庫と納入単位の実在庫と端数は小数第四位で切り上げ
                            decimal keisan_zaiko = Math.Ceiling((decimal)item.su_keisan_zaiko * 1000) / 1000;
                            decimal jitsuzaiko_nonyu = Math.Floor((decimal)item.jitsuzaiko_nonyu);
                            decimal jitsuzaiko_hasu = Math.Ceiling((decimal)item.jitsuzaiko_hasu * 10) / 10;
                            //ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, keisan_zaiko.ToString(), indexSpCom3, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, jitsuzaiko_nonyu.ToString(), indexSpCom1, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, jitsuzaiko_hasu.ToString(), indexSpCom1, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "G" + index, keisan_zaiko, indexSpCom3, lang);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "H" + index, jitsuzaiko_nonyu, indexSpCom1, lang);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "I" + index, jitsuzaiko_hasu, indexSpCom1, lang);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.su_zaiko.ToString(), indexSpCom6, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.su_zaiko.ToString(), indexSpCom3, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "J" + index, item.su_zaiko, indexSpCom3, lang);

                            ///// 機能選択マスタによる分岐
                            if (Soko.kbn_kino_naiyo != ActionConst.soko_shiyo)
                            {
                                // 倉庫区分が表示ありの場合
                                if (item.dt_jisseki_zaiko != null)
                                {
                                    DateTime zaikoKakuteiDate = (DateTime)item.dt_jisseki_zaiko;
                                    string str_date = zaikoKakuteiDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                                    ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, str_date, 0, true);
                                }
                                else
                                {

                                    ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, "", 0, true);
                                }
                                // 未使用フラグ：使用の場合は空白、未使用の場合は「未」
                                if (item.flg_mishiyo.ToString() == Resources.FlagFalse)
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, "", 0, true);
                                }
                                else
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, Resources.Mishiyo, 0, true);
                                }

                                //ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.tan_tana.ToString(), indexSpNoCom, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "M" + index, item.tan_tana, indexSpNoCom, lang);

                                // 金額の計算
                                decimal kingaku = Math.Floor((decimal)item.kingaku);
                                //ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, kingaku.ToString(), indexSpNoCom, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "N" + index, kingaku, indexSpNoCom, lang);
                            }
                            else {
                                // 倉庫区分が表示なしの場合
                                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.nm_soko, 0, true);
                                if (item.dt_jisseki_zaiko != null)
                                {
                                    DateTime zaikoKakuteiDate = (DateTime)item.dt_jisseki_zaiko;
                                    string str_date = zaikoKakuteiDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                                    ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, str_date, 0, true);
                                }
                                else
                                {

                                    ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, "", 0, true);
                                }
                                // 未使用フラグ：使用の場合は空白、未使用の場合は「未」
                                if (item.flg_mishiyo.ToString() == Resources.FlagFalse)
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, "", 0, true);
                                }
                                else
                                {
                                    ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, Resources.Mishiyo, 0, true);
                                }

                                //ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.tan_tana.ToString(), indexSpNoCom, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "N" + index, item.tan_tana, indexSpNoCom, lang);

                                // 金額の計算
                                decimal kingaku = Math.Floor((decimal)item.kingaku);
                                //ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, kingaku.ToString(), indexSpNoCom, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "O" + index, kingaku, indexSpNoCom, lang);
                            }
                            // 合計金額の計算
                            totalKingaku = Decimal.ToInt64(totalKingaku) + (Decimal)item.kingaku;

                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        ///// 機能選択マスタによる分岐
                        if (Soko.kbn_kino_naiyo != ActionConst.soko_shiyo)
                        {
                            // 合計金額の表示
                            ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, Resources.TotalAmount, 0, true);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, totalKingaku.ToString(), indexSpNoCom, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "N" + index, totalKingaku, indexSpNoCom, lang);
                        }
                        else {
                            // 合計金額の表示
                            ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, Resources.TotalAmount, 0, true);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, totalKingaku.ToString(), indexSpNoCom, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "O" + index, totalKingaku, indexSpNoCom, lang);  
                        }
                        // 合計金額の背景セルを塗る　★★保留中★★
                        //IEnumerable<Sheet> sheets = spDoc.WorkbookPart.Workbook.Descendants<Sheet>().Where(s => s.Name == ws);
                        //WorksheetPart wsPart = (WorksheetPart)spDoc.WorkbookPart.GetPartById(sheets.First().Id);
                        //wsPart.Worksheet.Style.Fill.BackgroundColor = XLColor.LightGray;
                        //wsPart.AddEmbeddedObjectPart("M" + index);
                        ws.Save();
                    }

                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.genshizaiZaikoNyuryokuCookie, Resources.CookieValue);
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
        /// 明細データを取得します。
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="criteria">検索条件</param>
        /// <returns>明細データ</returns>
        private IEnumerable<usp_GenshizaiZaikoNyuryoku_select_Result> GetEntity(
            String lang, GenshizaiZaikoNyuryokuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiZaikoNyuryoku_select_Result> views;
            views = context.usp_GenshizaiZaikoNyuryoku_select(
                    criteria.con_dt_zaiko,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kbn_hin),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hin_bunrui),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kurabasho),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei),
                    criteria.flg_shiyobun,
                    criteria.flg_zaiko,
                    criteria.hasu_floor_decimal,    //100,
                    criteria.hasu_ceil_decimal, //10,
                    lang,
                    ActionConst.FlagFalse,
                    ActionConst.FlagTrue,
                    ActionConst.KgKanzanKbn,
                    ActionConst.LKanzanKbn,
                    ActionConst.GenryoHinKbn.ToString(),
                    ActionConst.ShizaiHinKbn.ToString(),
                    ActionConst.JikaGenryoHinKbn.ToString(),
                    criteria.kbn_zaiko,
                    criteria.cd_soko,
                    ActionConst.kbn_zaiko_horyu
                ).AsEnumerable();

            return views;
        }
    }
}