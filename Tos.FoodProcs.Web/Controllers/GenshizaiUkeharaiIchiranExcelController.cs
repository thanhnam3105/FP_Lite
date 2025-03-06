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
    /// 原資材・仕掛品使用一覧ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiUkeharaiIchiranExcelController : ApiController
    {
        // HTTP:GET
        public HttpResponseMessage Get([FromUri]GenshizaiUkeharaiIchiranCriteria criteria)
       
        {
            // ブラウザ言語
            string lang = criteria.lang;

            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();
                IEnumerable<usp_GenshizaiUkeharaiIchiran_select_Result> list;
                //var count = new ObjectParameter("count", 0);
                list = context.usp_GenshizaiUkeharaiIchiran_select(
                    criteria.kbn_hin,
                    criteria.cd_bunrui,
                    criteria.dt_hiduke_from,
                    criteria.dt_hiduke_to,
                    criteria.cd_genshizai,
                    criteria.flg_mishiyobun,
                    criteria.flg_shiyo,
                    criteria.flg_zaiko,
                    criteria.flg_today_jisseki,
                    criteria.dt_today,
                    criteria.cd_kg,
                    criteria.cd_li,
                    criteria.flg_yojitsu_yotei,
                    criteria.flg_yojitsu_jisseki,
                    criteria.flg_jisseki_kakutei,
                    criteria.kbn_genryo,
                    criteria.kbn_shizai,
                    criteria.kbn_jikagenryo,
                    criteria.NounyuYoteiKbn,
                    criteria.NounyuJissekiKbn,
                    criteria.ShiyoYoteiKbn,
                    criteria.ShiyoJissekiKbn,
                    criteria.ChoseiKbn,
                    criteria.seizoYoteiKbn,
                    criteria.seizoJissekiKbn,
                    criteria.choseiRiyuKbn,
                    criteria.ukeharaiKbn
                    ).ToList();

                // ファイル名の指定
                string templateName = "genshizaiUkeharaiIchiran"; // return形式 "_lang.xlsx"
                string excelname = Resources.GenshizaiUkeharaiIchiranExcel; // 出力ファイル名 拡張子は不要
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
                        // フォーマット作成とシートへのセット
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet; ;
                        sheet.NumberingFormats = new NumberingFormats();

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

                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        // 検索条件
                        // 日付
                        string dtFrom = ChangedNullToEmptyFormatDate(criteria.dt_hiduke_from, lang);
                        string dtTo = ChangedNullToEmptyFormatDate(criteria.dt_hiduke_to, lang);
                        string hiduke = dtFrom + ActionConst.StringSpace + ActionConst.WaveDash + ActionConst.StringSpace + dtTo;
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", hiduke, 0, true);

                        // 品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", criteria.hinKubunName, 0, true);
                        // 分類
                        ExcelUtilities.UpdateValue(wbPart, ws, "B4", criteria.hinBunruiName, 0, true);
                        // 品名
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", ChangedNullToEmpty(criteria.hinName), 0, true);
                        // 未使用分含む
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", criteria.mishiyoubun, 0, true);
                        // 計算在庫／実在庫ありのみ
                        ExcelUtilities.UpdateValue(wbPart, ws, "B7", criteria.ariNomi, 0, true);

                        //受払区分:
                        ExcelUtilities.UpdateValue(wbPart, ws, "B8", criteria.ukeharaiName, 0, true);

                        // 出力日
                        string outputDate = criteria.today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
                        ExcelUtilities.UpdateValue(wbPart, ws, "B9", outputDate, 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B10", criteria.userName, 0, true);

                        // 明細行開始ポイント
                        int index = 13;

                        // シートデータへ値をマッピング
                        foreach (usp_GenshizaiUkeharaiIchiran_select_Result item in list)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します

                            // 原資材コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.cd_genshizai, 0, true);
                            // 原資材名
                            // 多言語対応を考慮する
                            if (Resources.LangJa.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_genshizai_ja, 0, true);
                            }
                            else if (Resources.LangZh.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_genshizai_zh, 0, true);
                            }
                            else if (Resources.LangVi.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_genshizai_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_genshizai_en, 0, true);
                            }

                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, ChangedNullToEmptyFormatDate(item.dt_hiduke, lang), 0, true);

                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, ChangedUkeharaiKbn(item.kbn_ukeharai), 0, true);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.su_nyusyukko.ToString(), indexSpCom2, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.su_nyusyukko.ToString(), indexSpCom3, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "E" + index, item.su_nyusyukko, indexSpCom3, lang);
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_shokuba, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_line, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, ChangedNullToEmpty(item.no_lot), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.cd_seihin, 0, true);

                            // 多言語対応を考慮する
                            if (Resources.LangJa.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.nm_seihin_ja, 0, true);
                            }
                            else if (Resources.LangZh.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.nm_seihin_zh, 0, true);
                            }
                            else if (Resources.LangVi.Equals(lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.nm_seihin_vi, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.nm_seihin_en, 0, true);
                            }

                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.nm_memo, 0, true);

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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.genshizaiUkeharaiIchiranCookie, Resources.CookieValue);
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

      
        /// <summary>nullの場合、空文字に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        private String ChangedNullToEmpty(String value)
        {
            if (String.IsNullOrEmpty(value) || value == "null")
            {
                value = "";
            }
            return value;
        }

        /// <summary>日付を取得します。
        /// nullの場合は空文字を設定します。
        /// 値がある場合はyyyy/MM/ddにフォーマットします。</summary>
        /// <param name="targetDate">日付値</param>
        /// <returns>変換後の日付</returns>
        private String ChangedNullToEmptyFormatDate(DateTime? targetDate, string lang)
        {
            String result = "";
            if (targetDate != null)
            {
                int addHours = 9;   // UTC用9h+
                DateTime valDate = (DateTime)targetDate;
                result = valDate.AddHours(addHours).ToString(FoodProcsCommonUtility.formatDateSelect(lang));
            }
            return result;
        }

        /// <summary>受払区分を表示用に返還します。</summary>
        /// <param name="sheet">受払区分</param>
        /// <param name="fmtVal">設定したい書式</param>
        /// <returns>0: 納入予定　1:納入予定 2: 使用予定　3: 使用実績 4: 調整数</returns>
        private string ChangedUkeharaiKbn(short? UkeharaiKbn)
        {
            string ukeharai = "";
            if (UkeharaiKbn != null)
            {
                if (ActionConst.ukeharaiNounyuYoteiKbn == UkeharaiKbn)
                {
                    ukeharai = Resources.UkeharaiKbnNonyuYotei;
                }
                else if (ActionConst.ukeharaiNounyuJissekiKbn == UkeharaiKbn)
                {
                    ukeharai = Resources.UkeharaiKbnNonyuJisseki;
                }
                else if (ActionConst.ukeharaiShiyoYoteiKbn == UkeharaiKbn)
                {
                    ukeharai = Resources.UkeharaiKbnShiyoYotei;
                }
                else if (ActionConst.ukeharaiShiyoJissekiKbn == UkeharaiKbn)
                {
                    ukeharai = Resources.UkeharaiKbnShiyoJisseki;
                }
                else if (ActionConst.ukeharaiChoseiKbn == UkeharaiKbn)
                {
                    ukeharai = Resources.UkeharaiKbnChoseiSu;
                }
                else if (ActionConst.ukeharaiSeizoYoteiKbn == UkeharaiKbn)
                {
                    ukeharai = Resources.UkeharaiKbnSeizoYotei;
                }
                else if (ActionConst.ukeharaiSeizoJissekiKbn == UkeharaiKbn)
                {
                    ukeharai = Resources.UkeharaiKbnSeizoJisseki;
                }
            }
            return ukeharai;
        }

        /// <summary>書式設定を追加します。</summary>
        /// <param name="sheet">シート情報</param>
        /// <param name="fmtVal">設定したい書式ID</param>
        /// <returns>書式番号</returns>
        private int SetCellFormats(Stylesheet sheet, NumberingFormat fmtVal)
        {
            CellFormat fmt = new CellFormat();
            fmt.NumberFormatId = fmtVal.NumberFormatId;
            int fmtIndex = sheet.CellFormats.Count();
            sheet.CellFormats.InsertAt<CellFormat>(fmt, fmtIndex);
            return fmtIndex;
        }

        /// <summary>多言語対応可能な名称の変換処理</summary>
        /// <param name="sheet">ブラウザ言語</param>
        /// <param name="jaName">ja版の名称</param>
        /// <param name="enName">en版の名称</param>
        /// <param name="zhName">zh版の名称</param>
        /// <returns>ブラウザに対応した名称</returns>
        private string MultiLangHinName(string lang, string jaName, string enName, string zhName)
        {
            if (Resources.LangJa.Equals(lang))
            {
                return jaName;
            }
            else if (Resources.LangZh.Equals(lang))
            {
                return zhName;
            }
            else
            {
                return enName;
            }
        }
    }
}