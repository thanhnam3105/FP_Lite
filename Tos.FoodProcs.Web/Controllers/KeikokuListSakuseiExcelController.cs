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
using System.Data;
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
    /// <summary>帳票用明細：セッター・ゲッタークラス</summary>
    class CriteriaInfo
    {
        public DateTime from { get; set; }
        public DateTime to { get; set; }
    }

    /// <summary>
    /// 警告リスト作成：ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>
    [Authorize]
    [LoggingExceptionFilter]
    public class KeikokuListSakuseiExcelController : ApiController
    {
        // 定数設定
        /// <summary>検索条件のセル横位置：C</summary>
        private const string SEARCH_CON_CELL = "C";

        // HTTP:GET [FromUri]
        public HttpResponseMessage Get([FromUri]KeikokuListSakuseiCriteria criteria, DateTime outputDate, int UTC)
        {
            try
            {
                // TODO:ダウンロードの準備
                // 終了日が1970/1/1以下の場合、nullとする
                DateTime minDate = DateTime.Parse("1970/01/01");
                DateTime? endDate = criteria.con_dt_end;
                if (endDate < minDate)
                {
                    endDate = null;
                }
                // Entity取得
                IEnumerable<usp_KeikokuListSakusei_select_Result> results = GetEntity(criteria, endDate);

                // ファイル名の指定
                string templateName = "keikokuList"; // return形式 "_lang.xlsx" 
                string excelname = Resources.KeikokuListExcel; // 出力ファイル名 拡張子は不要

                // TODO:ここまで

                // pathの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, criteria.lang);

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
                        if (criteria.lang != Properties.Resources.LangVi) {
                            sheet.NumberingFormats = new NumberingFormats();
                        }

                        // 書式設定の追加
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);
                        int addHours = UTC;   // 時差

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }
                  
                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        // 検索条件
                        // 検索条件日付
                        string searchDate = GetSerchDate(criteria.con_hizuke, endDate, addHours, criteria.lang);
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "2", searchDate, 0, true);
                        // 品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "3", criteria.hinKubunName, 0, true);
                        // 品分類
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "4", criteria.hinBunruiName, 0, true);
                        // 庫場所
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "5", criteria.kurabashoName, 0, true);
                        // 品名
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "6", FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei), 0, true);
                        // 警告リスト
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "7", criteria.keikokuList, 0, true);
                        // 前日在庫－当日使用
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "8", criteria.zenjitsuZaiko, 0, true);
                        // 最大在庫も警告
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "9", criteria.keikokuMax, 0, true);
                        // 全ての原資材を表示
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "10", criteria.allGenshizaiDisp, 0, true);
                        // 納入リードタイムを加味する
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "11", criteria.leadtimeKami, 0, true);

                        // 出力日
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "13", outputDate.ToString(FoodProcsCommonUtility.formatDateTimeSelect(criteria.lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, SEARCH_CON_CELL + "14", criteria.userName, 0, true);

                        // 明細行開始ポイント
                        int index = 17;

                        // シートデータへ値をマッピング
                        foreach (usp_KeikokuListSakusei_select_Result item in results)
                        {                            
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            if (criteria.lang == Resources.LangJa || criteria.lang == Resources.LangZh || CultureInfo.CurrentUICulture.Name == "en-US")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, String.Format("{0:MM/dd}", item.dt_hizuke), 0, true);
                            }
                            else {
                                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, String.Format("{0:dd/MM}", item.dt_hizuke), 0, true);
                            }
                            //ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, String.Format("{0:MM/dd}", item.dt_hizuke.AddHours(addHours)), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_hinmei, 0, true);

                            // 多言語対応を考慮する
                            if (Resources.LangJa.Equals(criteria.lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_ja), 0, true);
                            }
                            else if (Resources.LangZh.Equals(criteria.lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_zh), 0, true);
                            }
                            else if (Resources.LangVi.Equals(criteria.lang))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_vi), 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_hinmei_en), 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_nisugata_hyoji), 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, FoodProcsCommonUtility.changedNullToEmpty(item.tani_shiyo), 0, true);
                            decimal zaiko = (decimal)item.su_zaiko;
                            if (zaiko < 0)
                            {
                                // 値がマイナスの場合
                                // マイナスの四捨五入は最も近い整数＝マイナスの方に切り上げてしまうため、正の数で処理する
                                zaiko = -(zaiko);
                                zaiko = FoodProcsCommonUtility.decimalCeiling(zaiko, 3);

                                // 負の数に戻す
                                zaiko = -(zaiko);
                            }
                            else
                            {
                                //zaiko = FoodProcsCommonUtility.mathRound(zaiko, 3);
                                zaiko = FoodProcsCommonUtility.decimalTruncate(zaiko, 3);
                            }
                            //ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, zaiko.ToString(), indexSpCom3, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "F" + index, zaiko, indexSpCom3, criteria.lang);
                            decimal zaiko_min = FoodProcsCommonUtility.decimalTruncate((decimal)item.su_zaiko_min, 3);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, zaiko_min.ToString(), indexSpCom3, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "G" + index, zaiko_min, indexSpCom3, criteria.lang);
                            decimal zaiko_max = FoodProcsCommonUtility.decimalTruncate((decimal)item.su_zaiko_max, 3);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, zaiko_max.ToString(), indexSpCom3, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "H" + index, zaiko_max, indexSpCom3, criteria.lang);
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, FoodProcsCommonUtility.changedNullToEmpty(item.nm_torihiki), 0, true);

                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        // TODO:ここまで
                    }

                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                   // return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.keikokuListSakuseiCookie, Resources.CookieValue);
                }
            }
            catch (Exception e)
            {
                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
                try
                {
                    // エラー用EXCELファイルの取得
                    string serverpath = HttpContext.Current.Server.MapPath("..");
                    string templateFile = ExcelUtilities.getTemplateFile("Error", serverpath, criteria.lang);
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

        /// <summary>明細データを取得します。</summary>
        /// <param name="criteria">検索情報</param>
        /// <param name="endDate">検索条件/終了日</param>
        /// <returns>取得した明細データ</returns>
        private IEnumerable<usp_KeikokuListSakusei_select_Result> GetEntity(KeikokuListSakuseiCriteria criteria, DateTime? endDate)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            // TODO：タイムアウト時間変更(0=無限)
            context.CommandTimeout = 0;

            
            ///// 納入リードタイムを加味する場合
            // 納入リードタイムを加味した計算在庫ワークを作成してから、警告リストを作成する
            if (ActionConst.FlagTrue == criteria.flg_leadtime)
            {
                List<CriteriaInfo> list = GetDateSplitObject(
                    criteria.con_hizuke, criteria.con_dt_end, criteria.splitDays);

                foreach (var item in list)
                {
                    // 計算在庫の再計算
                    CreateNonyuLeadZaiko(criteria, item.from, item.to);
                }
            }

            ///// 警告リスト作成処理
            IEnumerable<usp_KeikokuListSakusei_select_Result> views;
            views = context.usp_KeikokuListSakusei_select(
                    criteria.con_hizuke,
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kubun),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kurabasho),
                    FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei),
                    criteria.con_keikoku_list,
                    criteria.con_zaiko_max_flg,
                    criteria.lang,
                    criteria.today,
                    ActionConst.FlagFalse,
                    ActionConst.YoteiYojitsuFlag,
                    ActionConst.JissekiYojitsuFlag,
                    ActionConst.GenryoHinKbn,
                    ActionConst.ShizaiHinKbn,
                    ActionConst.JikaGenryoHinKbn,
                    endDate,
                    criteria.all_genshizai,
                    criteria.flg_leadtime,
                    ActionConst.KgKanzanKbn,
                    ActionConst.LKanzanKbn
                ).AsEnumerable();
 
            return views;
        }

        /// <summary>
        /// 指定した日付範囲を一定期間で分割したオブジェクトを作成します
        /// </summary>
        /// <param name="fr">開始日</param>
        /// <param name="to">終了日</param>
        /// <param name="sp">区切り範囲</param>
        /// <returns>区切り範囲で区切った日付オブジェクト</returns>
        private List<CriteriaInfo> GetDateSplitObject(DateTime fr, DateTime to, int sp)
        {
            List<CriteriaInfo> list = new List<CriteriaInfo>();
            var start = fr; //deepcopy
            var end = to; //deepcopy
            DateTime stloop;
            DateTime edloop;
            // 比較して範囲内であれば、オブジェクトに格納
            // 目的：指定された期間ごとに、From-Toのオブジェクトセットを作る
            for (var d = fr; d <= to; d = d.AddDays(sp))
            {
                CriteriaInfo obj = new CriteriaInfo();
                stloop = d;
                start = d; //deepcopy
                edloop = start.AddDays(sp - 1);
                if (end < edloop)
                {
                    edloop = end;
                }
                obj.from = stloop;
                obj.to = edloop;
                list.Add(obj);
            }

            return list;
        }

        /// <summary>
        /// 納入リードタイムを加味した計算在庫の計算処理を行う。
        /// </summary>
        /// <param name="criteria">検索情報</param>
        /// <param name="fromDate">検索開始日</param>
        /// <param name="toDate">検索終了日</param>
        private void CreateNonyuLeadZaiko(KeikokuListSakuseiCriteria criteria, DateTime fromDate, DateTime toDate)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;
            context.CommandTimeout = 0; //タイムアウト時間変更(0=無限)

            // ユーザー情報の取得
            UserController controller = new UserController();
            Tos.FoodProcs.Web.Data.UserInfo userInfo = controller.Get();

            using (IDbConnection connection = context.Connection)
            {
                context.Connection.Open();
                using (IDbTransaction transaction = context.Connection.BeginTransaction())
                {
                    try
                    {
                        short flg_shiyo = ActionConst.FlagFalse;    // 未使用フラグ：使用

                        context.usp_KeikokuList_NonyuLeadZaiko(
                            fromDate
                            , toDate
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kubun)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_kurabasho)
                            , FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei)
                            , criteria.lang
                            , userInfo.Code
                            , flg_shiyo
                            , ActionConst.YoteiYojitsuFlag
                            , ActionConst.JissekiYojitsuFlag
                            , ActionConst.GenryoHinKbn
                            , ActionConst.ShizaiHinKbn
                            , ActionConst.JikaGenryoHinKbn
                            , ActionConst.KgKanzanKbn
                            , ActionConst.LKanzanKbn
                            , criteria.today
                            , ActionConst.kbn_zaiko_ryohin
                        );

                        transaction.Commit();
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                    }
                }
            }
        }

        /// <summary>検索条件日付を取得します。
        /// 終了日に入力があれば「～」で開始日と終了日を繋ぎ、終了日が空の場合は開始日のみ返却。</summary>
        /// <param name="startDate">開始日</param>
        /// <param name="endDate">終了日</param>
        /// <param name="addHours">UTC日付用に足す時間</param>
        /// <returns>検索条件日付</returns>
        private String GetSerchDate(DateTime startDate, DateTime? endDate, int addHours, string lang)
        {
            DateTime searchDate = startDate.AddHours(-(addHours));
            string result = searchDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
            if (endDate != null)
            {
                DateTime tmpDate = (DateTime)endDate;
                // 開始日 ～ 終了日
                result = result + ActionConst.StringSpace + ActionConst.WaveDash + ActionConst.StringSpace
                    + tmpDate.AddHours(-(addHours)).ToString(FoodProcsCommonUtility.formatDateSelect(lang));
            }
            return result;
        }
    }
}