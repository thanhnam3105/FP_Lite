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
    /// 納入予定リスト作成ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class NonyuYoteiListSakuseiExcelController : ApiController
    {
        // HTTP:GET 選択言語がjaの場合の出力
        public HttpResponseMessage Get(
            [FromUri]NonyuYoteiListSakuseiCriteria criteria,
            String lang,
            String nmKbnHin,
            String nmCdBunrui,
            String nmKbnHokan,
            String nmFlgTorihiki,
            String nmCdTorihiki,
            String nmNmTorihiki,
            String userName,
            DateTime today)
        {
            try
            {
                FoodProcsEntities context = new FoodProcsEntities();
                IEnumerable<usp_NonyuYoteiListSakusei_select_Result> selectResult;
                selectResult = context.usp_NonyuYoteiListSakusei_select(
                    criteria.con_dt_nonyu,
                    criteria.con_kbn_hin,
                    criteria.con_cd_bunrui,
                    criteria.con_kbn_hokan,
                    criteria.con_cd_torihiki,
                    criteria.flg_yojitsu_yo,
                    criteria.flg_yojitsu_ji,
                    criteria.flg_mishiyo,
                    ActionConst.KgKanzanKbn,
                    ActionConst.LKanzanKbn,
                    ActionConst.kbn_zaiko_ryohin
                ).AsEnumerable();

                // 機能選択コントロールより入庫区分入力区分を取得
                var cn_nyuko = (from ma in context.cn_kino_sentaku
                            where ma.kbn_kino == ActionConst.kbn_nyuko_nyuryoku
                            select ma).FirstOrDefault();
                short nyuko = ActionConst.FlagFalse;
                if (cn_nyuko != null)
                {
                    nyuko = cn_nyuko.kbn_kino_naiyo;
                }

                // テンプレートファイル名：return形式 "_lang.xlsx"
                string templateName = "nonyuYoteiListSakusei";
                if (ActionConst.FlagTrue.Equals(nyuko))
                {
                    // 入庫区分入力区分が「あり」の場合
                    templateName = "nonyuYoteiListSakusei_kbn_nyuko";
                }

                // 出力ファイル名：拡張子不要
                string excelName = Resources.NonyuYoteiListSakuseiExcel;
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

                        // フォーマット作成とシートへのセット
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet;
                        if (lang != Properties.Resources.LangVi) {
                            sheet.NumberingFormats = new NumberingFormats();
                        }

                        // ===== 書式設定の追加
                        // カンマ区切り、小数点以下なし
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // カンマ区切り、小数点以下3桁
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        // カンマ区切り、小数点以下2桁
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // ヘッダー行出力
                        string headCol = "C";
                        // 検索条件/納入日
                        DateTime dtNonyu = criteria.con_dt_nonyu;
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "2", dtNonyu.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                        // 検索条件/品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "3", nmKbnHin, 0, true);
                        // 検索条件/品分類
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "4", nmCdBunrui, 0, true);
                        // 検索条件/品位状態
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "5", nmKbnHokan, 0, true);
                        // 検索条件/取引先１(物流)
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "6", nmFlgTorihiki, 0, true);
                        // 検索条件/取引先コード
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "7", nmCdTorihiki, 0, true);
                        // 検索条件/取引先名
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "8", nmNmTorihiki, 0, true);
                        // 出力日時
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "10", today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, headCol + "11", userName, 0, true);

                        // 明細出力行インデックス(初期値に開始行数を設定)
                        int index = 14;
                        //string dtNonyuJi_Col = "Q"; // 納入実績日のcol番号

                        // 明細行出力
                        foreach (usp_NonyuYoteiListSakusei_select_Result item in selectResult)
                        {
                            // 明細/確定
                            if (item.flg_kakutei.ToString() == Resources.FlagTrue)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, Resources.Kakutei, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, "", 0, true);
                            }
                            // 明細/納入番号
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.no_nonyu, 0, true);
                            // 明細/納入書番号
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.no_nonyusho, 0, true);
                            // 明細/品分類
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_bunrui, 0, true);
                            // 明細/原資材コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.cd_hinmei, 0, true);
                            // 明細/原資材名(多言語対応)
                            if (lang == Resources.LangJa)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_hinmei_ja, 0, true);
                            }
                            else if (lang == Resources.LangEn)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_hinmei_en, 0, true);
                            }
                            else if (lang == Resources.LangVi)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_hinmei_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_hinmei_zh, 0, true);
                            }
                            // 明細/荷姿
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_nisugata_hyoji, 0, true);
                            // 明細/納入単位
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.nm_tani, 0, true);
                            // 明細/納入単位(端数)
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.nm_tani_hasu, 0, true);
                            // 明細/納入予定日
                            if (item.dt_nonyu_yotei != null)
                            {
                                DateTime nonyuYoteiDate = (DateTime)item.dt_nonyu_yotei;
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, nonyuYoteiDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                            }
                            // 明細/納入予定
                            //SetNumberValue(wbPart, ws, "K" + index, item.su_nonyu_yo.ToString(), indexSpNoCom);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "K" + index, item.su_nonyu_yo, indexSpNoCom, lang);
                            // 明細/予定端数
                            //SetNumberValue(wbPart, ws, "L" + index, item.su_nonyu_yo_hasu.ToString(), indexSpNoCom);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "L" + index, item.su_nonyu_yo_hasu, indexSpNoCom, lang);
                            // 明細/納入実績日
                            if (item.dt_nonyu != null)
                            {
                                DateTime nonyuDate = (DateTime)item.dt_nonyu;
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, nonyuDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                            }
                            // 明細/納入実績
                            //SetNumberValue(wbPart, ws, "N" + index, item.su_nonyu_ji.ToString(), indexSpNoCom);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "N" + index, item.su_nonyu_ji, indexSpNoCom, lang);
                            // 明細/実績端数
                            //SetNumberValue(wbPart, ws, "O" + index, item.su_nonyu_hasu.ToString(), indexSpNoCom);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "O" + index, item.su_nonyu_hasu, indexSpNoCom, lang);
                            // 明細/納入単価
                            //SetNumberValue(wbPart, ws, "P" + index, item.tan_nonyu.ToString(), indexSpCom3);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "P" + index, item.tan_nonyu, indexSpCom3, lang);
                            // 明細/金額
                            //SetNumberValue(wbPart, ws, "Q" + index, item.kin_kingaku.ToString(), indexSpNoCom);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "Q" + index, item.kin_kingaku, indexSpNoCom, lang);
                            // 明細/税区分
                            ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, item.nm_zei, 0, true);
                            // 明細/取引先１(物流)
                            ExcelUtilities.UpdateValue(wbPart, ws, "S" + index, item.nm_torihiki, 0, true);
                            // 明細/取引先２(商流)
                            ExcelUtilities.UpdateValue(wbPart, ws, "T" + index, item.nm_torihiki2, 0, true);

                            if (ActionConst.FlagTrue.Equals(nyuko))
                            {
                                // 入庫区分入力区分が「あり」の場合
                                string kbn_nyuko = Resources.kbnNyukoYusho;
                                //if (ActionConst.kbn_nyuko_musho.Equals(nyuko))
                                if (item.kbn_nyuko != null && ActionConst.kbn_nyuko_musho.Equals(item.kbn_nyuko))
                                {
                                    kbn_nyuko = Resources.kbnNyukoMusho;
                                }
                                ExcelUtilities.UpdateValue(wbPart, ws, "U" + index, kbn_nyuko, 0, true);
                                //dtNonyuJi_Col = "R";
                            }

                            //// 明細/納入実績日
                            //if (item.dt_nonyu != null)
                            //{
                            //    DateTime nonyuDate = (DateTime)item.dt_nonyu;
                            //    ExcelUtilities.UpdateValue(wbPart, ws, dtNonyuJi_Col + index, nonyuDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
                            //}

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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.nonyuYoteiListSakuseiCookie, Resources.CookieValue);
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

        /// <summary>数値系項目のマッピング処理。nullの場合は設定しない。</summary>
        /// <param name="wbPart">ワークブック</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="cellNo">設定するセル番号</param>
        /// <param name="value">設定する値</param>
        /// <param name="fmt">書式番号</param>
        private void SetNumberValue(WorkbookPart wbPart, Worksheet ws, String cellNo, String value, UInt32 fmt)
        {
            if (!String.IsNullOrEmpty(value))
            {
                ExcelUtilities.UpdateValue(wbPart, ws, cellNo, value, fmt, false);
            }
        }
    }
}