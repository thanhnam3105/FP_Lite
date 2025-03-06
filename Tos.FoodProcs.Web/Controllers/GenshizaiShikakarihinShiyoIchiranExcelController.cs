using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using Tos.FoodProcs.Web.Utilities;


namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 原資材・仕掛品使用一覧ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiShikakarihinShiyoIchiranExcelController : ApiController
    {
        // HTTP:GET
        public HttpResponseMessage Get([FromUri]GenshizaiShikakarihinShiyoIchiranCriteria criteria,
            string kbnName, string bunruiName, string userName, DateTime outputDate)
        {
            // ブラウザ言語
            string lang = criteria.lang;

            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                IEnumerable<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> results;
                results = GetSelectResult(criteria);

                // ファイル名の指定
                string templateName = "genshizaiShikakarihinShiyoIchiran"; // return形式 "_lang.xlsx"
                if (ActionConst.ShizaiHinKbn.Equals(criteria.kbn_hin))
                {
                    // 検索条件/品区分が「資材」の場合は専用のテンプレートを指定する
                    templateName = "genshizaiShikakarihinShiyoIchiran_shizai";
                }
                string excelname = Resources.GenshizaiShikakarihinShiyoIchiranExcel; // 出力ファイル名 拡張子は不要
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
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);
                        string fromDateStr = "";
                        if (criteria.dt_from != null)
                        {
                            fromDateStr = criteria.dt_from.Value.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        }

                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        // 検索条件
                        // 品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", kbnName, 0, true);
                        // 分類
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", bunruiName, 0, true);
                        // 名称
                        ExcelUtilities.UpdateValue(wbPart, ws, "B4", FoodProcsCommonUtility.changedNullToEmpty(criteria.hinmei), 0, true);
                        // 有効日付
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", fromDateStr, 0, true);

                        // 出力日時
                        ExcelUtilities.UpdateValue(wbPart, ws, "B7", outputDate.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B8", userName, 0, true);

                        // 明細行開始ポイント
                        int index = 11;

                        // シートデータへ値をマッピング
                        foreach (usp_GenshizaiShikakarihinShiyoIchiran_select_Result item in results)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します

                            // 区分
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.nm_kbn_hin, 0, true);
                            // コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_hinmei, 0, true);
                            // 名称：多言語対応する
                            string nm_hinmei = MultiLangHinName(lang, item.nm_hinmei_ja, item.nm_hinmei_en, item.nm_hinmei_zh, item.nm_hinmei_vi);
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, nm_hinmei, 0, true);
                            // 未使用（品）
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, ChangedMishiyoFlag(item.mishiyo_hin), 0, true);

                            ///// 検索条件/品区分が「資材」だった場合
                            if (ActionConst.ShizaiHinKbn.Equals(criteria.kbn_hin))
                            {

                                // 使用数
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, FoodProcsCommonUtility.changedNullToEmpty(item.su_shiyo.ToString()), 0, true);
                                
                                // 版
                                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, FoodProcsCommonUtility.changedNullToEmpty(item.no_han.ToString()), 0, true);
                                // 未使用（資材）
                                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, ChangedMishiyoFlag(item.mishiyo_shikakari), 0, true);
                                // 製品コード
                                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.cd_seihin, 0, true);
                                // 製品名：多言語対応する
                                string nm_seihin = MultiLangHinName(lang, item.nm_seihin_ja, item.nm_seihin_en, item.nm_seihin_zh, item.nm_seihin_vi);
                                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, nm_seihin, 0, true);
                                // 未使用（製品）
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, ChangedMishiyoFlag(item.mishiyo_seihin), 0, true);
                                // 最終製造予定日
                                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, ChangedNullToEmptyFormatDate(item.dt_saishu_seizo_yotei,lang), 0, true);
                                // 最終製造日
                                ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, ChangedNullToEmptyFormatDate(item.dt_saishu_seizo, lang), 0, true);
                            }
                            else
                            {
                                ///// 検索条件/品区分が資材以外の場合
                                // 仕掛品コード
                                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.cd_shikakari, 0, true);
                                // 仕掛品名：多言語対応する
                                string nm_shikakari = MultiLangHinName(lang, item.nm_haigo_ja, item.nm_haigo_en, item.nm_haigo_zh, item.nm_haigo_vi);
                                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, nm_shikakari, 0, true);

                                // 配合重量
                                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, FoodProcsCommonUtility.changedNullToEmpty(item.wt_haigo.ToString()), 0, true);
                                
                                // 版
                                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, FoodProcsCommonUtility.changedNullToEmpty(item.no_han.ToString()), 0, true);
                                // 未使用（仕掛）
                                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, ChangedMishiyoFlag(item.mishiyo_shikakari), 0, true);
                                // 製品コード
                                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.cd_seihin, 0, true);
                                // 製品名：多言語対応する
                                string nm_seihin = MultiLangHinName(lang, item.nm_seihin_ja, item.nm_seihin_en, item.nm_seihin_zh, item.nm_seihin_vi);
                                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, nm_seihin, 0, true);
                                // 未使用（製品）
                                ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, ChangedMishiyoFlag(item.mishiyo_seihin), 0, true);
                                // 最終仕込予定日
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, ChangedNullToEmptyFormatDate(item.dt_saishu_shikomi_yotei, lang), 0, true);
                                // 最終仕込日
                                ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, ChangedNullToEmptyFormatDate(item.dt_saishu_shikomi, lang), 0, true);
                                // 最終製造予定日
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, ChangedNullToEmptyFormatDate(item.dt_saishu_seizo_yotei, lang), 0, true);
                                // 最終製造日
                                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, ChangedNullToEmptyFormatDate(item.dt_saishu_seizo, lang), 0, true);
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
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.genshizaiShikakarihinShiyoIchiranCookie, Resources.CookieValue);
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
        /// 検索処理の実行。
        /// 検索条件/品区分によって実行するストアドを変更する。
        /// </summary>
        /// <param name="criteria">検索条件</param>
        private IEnumerable<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> GetSelectResult(
            GenshizaiShikakarihinShiyoIchiranCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
            // TODO：タイムアウト時間変更(0=無限)
            context.CommandTimeout = 0;

            IEnumerable<usp_GenshizaiShikakarihinShiyoIchiran_select_Result> views;

            ///// 検索処理の実行
            if (ActionConst.ShizaiHinKbn.Equals(criteria.kbn_hin))
            {
                // 検索条件/品区分が「資材」だった場合
                views = context.usp_GenshizaiShikakarihinShiyoIchiran_shizai_select(
                    criteria.kbn_hin,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.bunrui),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.hinmei),
                    criteria.dt_from,
                    criteria.lang,
                    ActionConst.SeihinHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    //criteria.today
                    criteria.shiyoMishiyoFlag
                    ).ToList();
            }
            else if (ActionConst.ShikakariHinKbn.Equals(criteria.kbn_hin))
            {
                // 検索条件/品区分が「仕掛品」だった場合
                views = context.usp_GenshizaiShikakarihinShiyoIchiran_shikakari_select(
                    criteria.kbn_hin,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.bunrui),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.hinmei),
                    criteria.dt_from,
                    criteria.lang,
                    ActionConst.SeihinHinKbn,
                    ActionConst.ShikakariHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    //criteria.today
                    criteria.shiyoMishiyoFlag
                    ).ToList();
            }
            else
            {
                // 上記以外（検索条件/品区分が「原料」または「自家原料」）
                views = context.usp_GenshizaiShikakarihinShiyoIchiran_select(
                    criteria.kbn_hin,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.bunrui),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.hinmei),
                    criteria.dt_from,
                    criteria.lang,
                    ActionConst.SeihinHinKbn,
                    ActionConst.ShikakariHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    //criteria.today
                    criteria.shiyoMishiyoFlag
                    ).ToList();
            }

            return views;
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
                DateTime valDate = (DateTime)targetDate;
                result = valDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
            }
            return result;
        }

        /// <summary>未使用フラグを表示用に返還します。</summary>
        /// <param name="sheet">未使用フラグ</param>
        /// <param name="fmtVal">設定したい書式</param>
        /// <returns>使用状態：使用　未使用状態：未使用</returns>
        private string ChangedMishiyoFlag(short? mishiyoFlg)
        {
            string mishiyo = "";
            if (mishiyoFlg != null)
            {
                if (ActionConst.FlagFalse == mishiyoFlg)
                {
                    mishiyo = Resources.Shiyo;
                }
                else
                {
                    mishiyo = Resources.Mishiyo;
                }
            }
            return mishiyo;
        }

        /// <summary>多言語対応可能な名称の変換処理</summary>
        /// <param name="sheet">ブラウザ言語</param>
        /// <param name="jaName">ja版の名称</param>
        /// <param name="enName">en版の名称</param>
        /// <param name="zhName">zh版の名称</param>
        /// <returns>ブラウザに対応した名称</returns>
        private string MultiLangHinName(string lang, string jaName, string enName, string zhName, string viName)
        {
            if (Resources.LangJa.Equals(lang))
            {
                return jaName;
            }
            else if (Resources.LangZh.Equals(lang))
            {
                return zhName;
            }
            else if (Resources.LangVi.Equals(lang))
            {
                return viName;
            }
            else
            {
                return enName;
            }
        }
    }
}