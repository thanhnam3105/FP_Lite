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
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{

    /// <summary>明細計算用情報：セッター・ゲッタークラス</summary>
    class MeisaiInfo
    {
        public decimal nonyu_yotei { get; set; }
        public decimal nonyu_jitsu { get; set; }
        public decimal shiyo_yotei { get; set; }
        public decimal shiyo_jitsu { get; set; }
        public decimal chosei { get; set; }
        public DateTime dt_hizuke { get; set; }
    }
    
    /// <summary>
    /// 原資材変動表：ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenshizaiHendoHyoExcelController : ApiController
    {
        // 定数設定
        /// <summary>セル番地（検索日付）：B2</summary>
        private const string ADDR_KENSAKU_DATE = "B2";
        /// <summary>セル番地（原資材コード）：B3</summary>
        private const string ADDR_GENSHIZAI_CODE = "B3";
        /// <summary>セル番地（原資材名）：B4</summary>
        private const string ADDR_GENSHIZAI_NAME = "B4";
        /// <summary>セル番地（備考）：B5</summary>
        private const string ADDR_BIKO_TEXT = "B5";
        /// <summary>セル番地（購入先名）：E4</summary>
        private const string ADDR_KONYUSAKI_NAME = "E4";
        /// <summary>セル番地（使用単位）：G4</summary>
        private const string ADDR_SHIYO_TANI = "G4";
        /// <summary>セル番地（出力日時）：I2</summary>
        private const string ADDR_SHUTSURYOKU_DATE = "I2";
        /// <summary>セル番地（出力者）：I3</summary>
        private const string ADDR_SHUTSURYOKU_NAME = "I3";
        /// <summary>セル番地（繰越在庫）：D6</summary>
        // private const string ADDR_KURIKOSHI_ZAIKO = "D6";
        /// <summary>セル番地（繰越在庫）：D7</summary>
        private const string ADDR_KURIKOSHI_ZAIKO = "D7";
        /// <summary>セル番地（繰越残）：I43</summary>
        private const string ADDR_KURIKOSHI_ZAN = "I43";

        /// <summary>セル番地（製造予定数）：C8</summary>
        private const string JIKAGEN_YOTEI = "C8";
        /// <summary>セル番地（製造実績数）：D8</summary>
        private const string JIKAGEN_JISSEKI = "D8";

        /// <summary>列（月日）：A</summary>
        private const string COL_DATE = "A";
        /// <summary>列（曜日）：B</summary>
        private const string COL_WEEKDAY = "B";
        /// <summary>列（納入予定）：C</summary>
        private const string COL_NONYU_YOTEI = "C";
        /// <summary>列（納入実績）：D</summary>
        private const string COL_NONYU_JISSEKI = "D";
        /// <summary>列（使用予定）：E</summary>
        private const string COL_SHIYO_YOTEI = "E";
        /// <summary>列（使用実績）：F</summary>
        private const string COL_SHIYO_JISSEKI = "F";
        /// <summary>列（調整）：G</summary>
        private const string COL_CHOSEI = "G";
        /// <summary>列（計算在庫）：H</summary>
        private const string COL_KEISANZAIKO = "H";
        /// <summary>列（実在庫）：I</summary>
        private const string COL_JITSUZAIKO = "I";

        /// <summary>明細開始行10</summary>
        // private const int INDEX_LIST_START = 9;
        private const int INDEX_LIST_START = 10;

        // HTTP:GET 選択言語がjaの場合の出力
        public HttpResponseMessage Get([FromUri]GenshizaiHendoHyoCriteria criteria, 
        //  string genshizaiName, string konyusakiName, string shiyoTani, short hinKbn, int utc, DateTime outputDate)
             string genshizaiName, string konyusakiName, string shiyoTani, short hinKbn,string bikoText, int utc, DateTime outputDate)
        {
            string lang = criteria.lang;

            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                IEnumerable<usp_GenshizaiHendoHyo_select_Result> results = GetEntity(criteria);

                // ファイル名の指定
                string templateName = "genshizaiHendohyo"; // return形式 "_lang.xlsx" 
                string excelname = Resources.GenshizaiHendoHyoExcel; // 出力ファイル名 拡張子は不要
                // TODO:ここまで

                // pathの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, lang);

                // ユーザー情報の取得
                UserController controller = new UserController();
                Tos.FoodProcs.Web.Data.UserInfo userInfo = controller.Get();

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
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        UInt32 indexSpCom6 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma6, ActionConst.idSplitComma6);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);
                        DateTime dtHizuke = criteria.dt_hizuke.AddHours(-(utc));
                        DateTime dt_Hizuke_to = criteria.dt_hizuke_to.AddHours(-(utc));

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        // ヘッダー行をセット
                        ////// 検索条件
                        // 検索日付
                        string dtFrom = dtHizuke.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        string dtTo = dt_Hizuke_to.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        string hizuke = dtFrom + ActionConst.StringSpace + ActionConst.WaveDash + ActionConst.StringSpace + dtTo;
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_KENSAKU_DATE, hizuke, 0, true);
                        // 原資材コード
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_GENSHIZAI_CODE, criteria.cd_hinmei, 0, true);
                        // 原資材名
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_GENSHIZAI_NAME, genshizaiName, 0, true);
                        // 備考
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_BIKO_TEXT, bikoText, 0, true);
                        // 購入先名称
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_KONYUSAKI_NAME, konyusakiName, 0, true);
                        // 使用単位
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_SHIYO_TANI, shiyoTani, 0, true);

                        // 出力日時
                        string opDate = outputDate.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_SHUTSURYOKU_DATE, opDate, 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, ADDR_SHUTSURYOKU_NAME, userInfo.Name, 0, true);

                        if (hinKbn == ActionConst.JikaGenryoHinKbn)
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, JIKAGEN_YOTEI, Resources.SeizoYotei, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, JIKAGEN_JISSEKI, Resources.SeizoJisseki, 0, true);
                        }
                        // 明細行開始ポイント
                        int index = INDEX_LIST_START;

                        // 合計
                        decimal totalNonyuYotei = 0;
                        decimal totalNonyuJisseki = 0;
                        decimal totalShiyoYotei = 0;
                        decimal totalShiyoJisseki = 0;
                        decimal totalChosei = 0;

                        decimal kurikoshiZan = 0;
                        decimal kurikoshiZaiko = 0;

                        decimal zenjitsuZaiko = 0;

                        TimeZoneInfo tzi = TimeZoneInfo.Local;


                        // シートデータへ値をマッピング
                        foreach (usp_GenshizaiHendoHyo_select_Result item in results)
                        {
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            DateTime localDate = TimeZoneInfo.ConvertTimeFromUtc(item.dt_hizuke, tzi);
                            if (lang == Resources.LangJa || lang == Resources.LangZh || CultureInfo.CurrentUICulture.Name == "en-US")
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, COL_DATE + index, String.Format("{0:MM/dd}", localDate), 0, true);
                            }
                            else {
                                ExcelUtilities.UpdateValue(wbPart, ws, COL_DATE + index, String.Format("{0:dd/MM}", localDate), 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, COL_WEEKDAY + index, localDate.ToString("ddd"), 0, true);

                            //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_YOTEI + index, item.su_nonyu_yotei.ToString(), indexSpCom2, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_JISSEKI + index, item.su_nonyu_jisseki.ToString(), indexSpCom2, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_YOTEI + index, item.su_shiyo_yotei.ToString(), indexSpCom6, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_JISSEKI + index, item.su_shiyo_jisseki.ToString(), indexSpCom6, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, COL_CHOSEI + index, item.su_chosei.ToString(), indexSpCom6, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, COL_KEISANZAIKO + index, item.su_keisanzaiko.ToString(), 0, false);

                            // 実在庫：存在する場合だけマッピングする
                            if (item.su_jitsuzaiko != null)
                            {
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_JITSUZAIKO + index, item.su_jitsuzaiko.ToString(), indexSpCom6, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_JITSUZAIKO + index, item.su_jitsuzaiko.ToString(), indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, COL_JITSUZAIKO + index, item.su_jitsuzaiko, indexSpCom3, lang);
                            }

                            ///// 値が存在する、かつ0以上の場合だけマッピングする
                            MeisaiInfo meisaiInfo = GetMeisaiInfo();
                            meisaiInfo.dt_hizuke = item.dt_hizuke;
                            // 納入予定/製造予定
                            if (item.su_nonyu_yotei != null && item.su_nonyu_yotei > 0)
                            {
                                //decimal nonyuYotei = Math.Truncate((decimal)item.su_nonyu_yotei * 100) / 100;
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_YOTEI + index, nonyuYotei.ToString(), indexSpCom2, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_YOTEI + index, item.su_nonyu_yotei.ToString(), indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, COL_NONYU_YOTEI + index, item.su_nonyu_yotei, indexSpCom3, lang);
                                totalNonyuYotei = totalNonyuYotei + (decimal)item.su_nonyu_yotei;
                                meisaiInfo.nonyu_yotei = (decimal)item.su_nonyu_yotei;
                            }
                            // 納入実績/製造実績
                            if (item.su_nonyu_jisseki != null && item.su_nonyu_jisseki > 0)
                            {
                                //decimal nonyuJitsu = Math.Truncate((decimal)item.su_nonyu_jisseki * 100) / 100;
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_JISSEKI + index, nonyuJitsu.ToString(), indexSpCom2, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_JISSEKI + index, item.su_nonyu_jisseki.ToString(), indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, COL_NONYU_JISSEKI + index, item.su_nonyu_jisseki, indexSpCom3, lang);
                                totalNonyuJisseki = totalNonyuJisseki + (decimal)item.su_nonyu_jisseki;
                                meisaiInfo.nonyu_jitsu = (decimal)item.su_nonyu_jisseki;
                            }
                            // 使用予定
                            if (item.su_shiyo_yotei != null && item.su_shiyo_yotei > 0)
                            {
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_YOTEI + index, item.su_shiyo_yotei.ToString(), indexSpCom6, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_YOTEI + index, item.su_shiyo_yotei.ToString(), indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, COL_SHIYO_YOTEI + index, item.su_shiyo_yotei, indexSpCom3, lang);
                                totalShiyoYotei = totalShiyoYotei + (decimal)item.su_shiyo_yotei;
                                meisaiInfo.shiyo_yotei = (decimal)item.su_shiyo_yotei;
                            }
                            // 使用実績
                            if (item.su_shiyo_jisseki != null && item.su_shiyo_jisseki > 0)
                            {
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_JISSEKI + index, item.su_shiyo_jisseki.ToString(), indexSpCom6, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_JISSEKI + index, item.su_shiyo_jisseki.ToString(), indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, COL_SHIYO_JISSEKI + index, item.su_shiyo_jisseki, indexSpCom3, lang);
                                totalShiyoJisseki = totalShiyoJisseki + (decimal)item.su_shiyo_jisseki;
                                meisaiInfo.shiyo_jitsu = (decimal)item.su_shiyo_jisseki;
                            }
                            // 調整数：マイナスがあるので、0以外
                            if (item.su_chosei != null && item.su_chosei != 0)
                            {
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_CHOSEI + index, item.su_chosei.ToString(), indexSpCom6, false);
                                //ExcelUtilities.UpdateValue(wbPart, ws, COL_CHOSEI + index, item.su_chosei.ToString(), indexSpCom3, false);
                                ExcelUtilities.changeNullToBlank(wbPart, ws, COL_CHOSEI + index, item.su_chosei, indexSpCom3, lang);
                                totalChosei = totalChosei + (decimal)item.su_chosei;
                                meisaiInfo.chosei = (decimal)item.su_chosei;
                            }

                            if (index == INDEX_LIST_START)
                            {
                                kurikoshiZaiko = item.su_kurikoshi_zan != null ? (decimal)item.su_kurikoshi_zan : 0;
                                zenjitsuZaiko = kurikoshiZaiko;
                                //zenjitsuZaiko = Math.Truncate(zenjitsuZaiko * 100) / 100;
                                
                                //if (zenjitsuZaiko < 0)
                                //{
                                //    //zenjitsuZaiko = Math.Floor(zenjitsuZaiko * 100) / 100;
                                //}
                                //else
                                //{
                                //    //zenjitsuZaiko = Math.Ceiling(zenjitsuZaiko * 100) / 100;
                                //}
                            }

                            // 計算在庫
                            kurikoshiZan = CalculatKeisanZaiko(meisaiInfo, zenjitsuZaiko, criteria.today);
                            //ExcelUtilities.UpdateValue(wbPart, ws, COL_KEISANZAIKO + index, kurikoshiZan.ToString(), indexSpCom3, false);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, COL_KEISANZAIKO + index, kurikoshiZan, indexSpCom3, lang);
                            //実在庫があれば、繰越残に反映
                            if (item.su_jitsuzaiko != null)
                            {
                                kurikoshiZan = (decimal)item.su_jitsuzaiko;
                            }
                            zenjitsuZaiko = kurikoshiZan;
                            // 行のポインタを一つカウントアップ
                            index++;
                        }

                        //kurikoshiZaiko = Math.Truncate(kurikoshiZaiko * 100) / 100;
                        
                        //if (kurikoshiZaiko < 0)
                        //{
                        //    //kurikoshiZaiko = Math.Floor(kurikoshiZaiko * 100) / 100;
                        //}
                        //else 
                        //{
                        //    //kurikoshiZaiko = Math.Ceiling(kurikoshiZaiko * 100) / 100;
                        //}

                        // 繰越在庫の設定
                        //ExcelUtilities.UpdateValue(wbPart, ws, ADDR_KURIKOSHI_ZAIKO, kurikoshiZaiko.ToString(), indexSpCom2, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, ADDR_KURIKOSHI_ZAIKO, kurikoshiZaiko.ToString(), indexSpCom3, false);
                        ExcelUtilities.changeNullToBlank(wbPart, ws, ADDR_KURIKOSHI_ZAIKO, kurikoshiZaiko, indexSpCom3, lang);
                        // 合計行の設定
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_WEEKDAY + index, Resources.GokeiText, 0, true);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_YOTEI + index, totalNonyuYotei.ToString(), indexSpCom2, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_JISSEKI + index, totalNonyuJisseki.ToString(), indexSpCom2, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_YOTEI + index, totalShiyoYotei.ToString(), indexSpCom6, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_JISSEKI + index, totalShiyoJisseki.ToString(), indexSpCom6, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_CHOSEI + index, totalChosei.ToString(), indexSpCom6, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_KEISANZAIKO + index, Resources.KurikoshiZan, 0, true);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_JITSUZAIKO + index, kurikoshiZan.ToString(), indexSpCom2, false);
                        
                        ExcelUtilities.UpdateValue(wbPart, ws, COL_WEEKDAY + index, Resources.GokeiText, 0, true);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_YOTEI + index, totalNonyuYotei.ToString(), indexSpCom3, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_NONYU_JISSEKI + index, totalNonyuJisseki.ToString(), indexSpCom3, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_YOTEI + index, totalShiyoYotei.ToString(), indexSpCom3, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_SHIYO_JISSEKI + index, totalShiyoJisseki.ToString(), indexSpCom3, false);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_CHOSEI + index, totalChosei.ToString(), indexSpCom3, false);
                        ExcelUtilities.UpdateValue(wbPart, ws, COL_KEISANZAIKO + index, Resources.KurikoshiZan, 0, true);
                        //ExcelUtilities.UpdateValue(wbPart, ws, COL_JITSUZAIKO + index, kurikoshiZan.ToString(), indexSpCom3, false);

                        ExcelUtilities.changeNullToBlank(wbPart, ws, COL_NONYU_YOTEI + index, totalNonyuYotei, indexSpCom3, lang);
                        ExcelUtilities.changeNullToBlank(wbPart, ws, COL_NONYU_JISSEKI + index, totalNonyuJisseki, indexSpCom3, lang);
                        ExcelUtilities.changeNullToBlank(wbPart, ws, COL_SHIYO_YOTEI + index, totalShiyoYotei, indexSpCom3, lang);
                        ExcelUtilities.changeNullToBlank(wbPart, ws, COL_SHIYO_JISSEKI + index, totalShiyoJisseki, indexSpCom3, lang);
                        ExcelUtilities.changeNullToBlank(wbPart, ws, COL_CHOSEI + index, totalChosei, indexSpCom3, lang);
                        ExcelUtilities.changeNullToBlank(wbPart, ws, COL_JITSUZAIKO + index, kurikoshiZan, indexSpCom3, lang);
                        ws.Save();
                        // TODO:ここまで
                    }

                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.GenshizaiHendoHyoCookie, Resources.CookieValue);
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
        /// <param name="cd_hinmei">検索条件：品名コード</param>
        /// <param name="dt_hizuke">検索条件：日付</param>
        /// <returns>明細データ</returns>
        private IEnumerable<usp_GenshizaiHendoHyo_select_Result> GetEntity(GenshizaiHendoHyoCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiHendoHyo_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_GenshizaiHendoHyo_select(
                criteria.cd_hinmei
                , criteria.dt_hizuke
                , ActionConst.JissekiYojitsuFlag
                , ActionConst.YoteiYojitsuFlag
                , ActionConst.FlagFalse
                , ActionConst.KgKanzanKbn
                , ActionConst.LKanzanKbn
                , criteria.dt_hizuke_to
                , criteria.today
                , ActionConst.kbn_zaiko_ryohin
                , count).AsEnumerable();

            return views;
        }

        /// <summary>
        /// 計算在庫を計算し、その結果を返します。
        /// </summary>
        /// <param name="item">計算対象の明細行データ</param>
        /// <param name="zenZaiko">前日の在庫数</param>
        /// <param name="nowDate">システム日付</param>
        /// <returns>計算在庫数</returns>
        private decimal CalculatKeisanZaiko(MeisaiInfo item, decimal zenZaiko, DateTime nowDate)
        {
            decimal keisanZaiko = 0;
            // 年月がシステム日付より過去の場合：実績で計算
            //20190115 echigo start 【杭州不具合対応】画面と同じ使用に変更　⇒当日の場合、荷受は実績を優先。使用は予定から計算（実績があっても予定から計算）
            //if (nowDate > item.dt_hizuke)
            //{
            //    keisanZaiko = zenZaiko + item.nonyu_jitsu - item.shiyo_jitsu - item.chosei;
            //}
            //// 年月がシステム日付以降(未来)の場合：予定で計算
            //else
            //{
            //    keisanZaiko = zenZaiko + item.nonyu_yotei - item.shiyo_yotei - item.chosei;
            //}
            // 年月がシステム日付より過去の場合：実績で計算
            if (nowDate > item.dt_hizuke)
            {
                keisanZaiko = zenZaiko + item.nonyu_jitsu - item.shiyo_jitsu - item.chosei;
            }
            // 年月がシステム日付(当日)の場合：納入は実績があれば実績で計算（使用は予定で計算）
            else if (nowDate == item.dt_hizuke && item.nonyu_jitsu != 0)
            {
                keisanZaiko = zenZaiko + item.nonyu_jitsu - item.shiyo_yotei - item.chosei;
            }
            // 年月がシステム日付以降(未来)の場合：予定で計算
            else
            {
                keisanZaiko = zenZaiko + item.nonyu_yotei - item.shiyo_yotei - item.chosei;
            }
            //20190115 echigo end
            return keisanZaiko;
        }

        /// <summary>
        /// 明細計算用情報を初期化します。
        /// </summary>
        /// <returns>明細計算用情報</returns>
        private MeisaiInfo GetMeisaiInfo()
        {
            MeisaiInfo model = new MeisaiInfo();
            model.nonyu_yotei = 0;
            model.nonyu_jitsu = 0;
            model.shiyo_yotei = 0;
            model.shiyo_jitsu = 0;
            model.chosei = 0;

            return model;
        }
    }
}