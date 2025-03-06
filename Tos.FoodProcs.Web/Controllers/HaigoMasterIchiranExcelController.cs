using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Web;
using System.Web.Http;
using System.Web.Http.OData;
using System.Web.Http.OData.Query;
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
using System.Data.Objects;
using Tos.FoodProcs.Web.Properties;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 配合マスタ一覧：ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class HaigoMasterIchiranExcelController : ApiController
    {
        // HTTP:GET
        //public HttpResponseMessage Get(ODataQueryOptions<usp_HaigoMasterIchiran_select_Result> options, String lang, short kbn_hin,
        //    short kbn_master, String dt_shokichi, short flg_mishiyo, String cd_bunrui, String bunruiName, String haigoName,
        public HttpResponseMessage Get(ODataQueryOptions<usp_HaigoMasterIchiran_select_Result> options, String lang, short kbn_hin,
            short kbn_master, DateTime dt_shokichi, short flg_mishiyo, String cd_bunrui, String bunruiName, String haigoName,
            int UTC, DateTime today /*DateTime sysDate*/ , DateTime dt_from)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();
                //IQueryable results = options.ApplyTo(context.vw_ma_haigo_mei_01.AsQueryable());
                IEnumerable<usp_HaigoMasterIchiran_select_Result> results =
                    //GetEntity(kbn_hin, kbn_master, dt_shokichi, flg_mishiyo, cd_bunrui, haigoName, lang);
                    //GetEntity(kbn_hin, kbn_master, dt_shokichi, flg_mishiyo, cd_bunrui, haigoName, lang, sysDate);
                    GetEntity(kbn_hin, kbn_master, dt_shokichi, flg_mishiyo, cd_bunrui, haigoName, lang, dt_from);

                UserController controller = new UserController();
                Tos.FoodProcs.Web.Data.UserInfo userInfo = controller.Get();

                // ファイル名の指定
                string templateName = "haigoMasterIchiran"; // return形式 "_lang.xlsx" 
                string excelname = Resources.HaigoMasterIchiranExcel; // 出力ファイル名 拡張子は不要
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

                        // ======= 数値フォーマット作成 =======
                        sheet.NumberingFormats = new NumberingFormats();

                        // カンマ区切りなし、小数点以下2桁
                        UInt32 indexDecimalBelow2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, "0.00", UInt32Value.FromUInt32(8));
                        // カンマ区切り、小数点以下6桁
                        UInt32 indexSpCom6 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma6, ActionConst.idSplitComma6);
                        // カンマ区切り、小数点以下なし
                        UInt32 indexSpCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // ======= 数値フォーマット作成：ここまで =======
                        
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        //int addHours = UTC;   // UTC用

                        // 機能選択：単位区分を取得
                        string kbnTani = ActionConst.kbn_tani_Kg_L;
                        var cn_kbnTani = (from ma in context.cn_kino_sentaku
                                          where ma.kbn_kino == ActionConst.kbn_kino_kbn_tani
                                          select ma).FirstOrDefault();
                        if (cn_kbnTani != null)
                        {
                            kbnTani = cn_kbnTani.kbn_kino_naiyo.ToString();
                        }

                        string kanzan_kg = ActionConst.KanzanNameKg;
                        string kanzan_Li = ActionConst.KanzanNameLi;
                        // 単位区分が「LB・GAL」の場合
                        if (ActionConst.kbn_tani_LB_GAL.Equals(kbnTani))
                        {
                            kanzan_kg = ActionConst.KanzanNameLb;
                            kanzan_Li = ActionConst.KanzanNameGal;
                        }
                        
                        String mishiyoName;
                        if (flg_mishiyo == 0)
                        {
                            mishiyoName = Resources.Nashi;
                        }
                        else
                        {
                            mishiyoName = Resources.Ari;
                        }

                        // ヘッダー行をセット
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", bunruiName , 0, true);　//仕掛品分類
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", haigoName, 0, true);　//配合名
                        ExcelUtilities.UpdateValue(wbPart, ws, "B4", mishiyoName, 0, true);　//未使用表示
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", dt_from.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);　//有効日付
                        ExcelUtilities.UpdateValue(wbPart, ws, "B7", today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);　//出力日時
                        ExcelUtilities.UpdateValue(wbPart, ws, "B8", userInfo.Name, 0, true);　//出力者

                        // 明細行開始ポイント
                        //int index = 10;
                        int index = 11;
                
                        // シートデータへ値をマッピング
                        foreach (usp_HaigoMasterIchiran_select_Result item in results)
                        {
                            // 配合名を取得
                            String nameHaigo = item.nm_haigo_en ?? "";
                            if (Resources.LangJa.Equals(lang))
                            {
                                nameHaigo = item.nm_haigo_ja ?? "";
                            }
                            else if (Resources.LangZh.Equals(lang))
                            {
                                nameHaigo = item.nm_haigo_zh ?? "";
                            }
                            else if (Resources.LangVi.Equals(lang))
                            {
                                nameHaigo = item.nm_haigo_vi ?? "";
                            }
                            // nullチェック
                            item.nm_haigo_ryaku = item.nm_haigo_ryaku ?? "";
                            item.ritsu_budomari = item.ritsu_budomari ?? 0;
                            item.nm_tani = item.nm_tani ?? "";
                            item.ritsu_kihon = item.ritsu_kihon ?? 0;
                            item.wt_saidai_shikomi = item.wt_saidai_shikomi ?? 0;
                            item.wt_haigo_gokei = item.wt_haigo_gokei ?? 0;
                            item.biko = item.biko ?? "";
                            item.no_seiho = item.no_seiho ?? "";
                            item.ritsu_hiju = item.ritsu_hiju ?? 0;
                            item.cd_bunrui = item.cd_bunrui ?? "";
                            item.wt_kowake = item.wt_kowake ?? 0;
                            item.su_kowake = item.su_kowake ?? 0;
                            item.cd_line = item.cd_line ?? "";
                            item.nm_line = item.nm_line ?? "";
                            item.nm_create = item.nm_create ?? "";
                            item.nm_update = item.nm_update ?? "";
                            //string dt_from_str = item.dt_from.Value.ToLocalTime().ToString(FoodProcsCommonUtility.formatDateSelect(lang)) ?? "";

                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.cd_haigo, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, nameHaigo, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_haigo_ryaku, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_bunrui, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.no_han.ToString(), 0, false);
                            //ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, dt_from_str, 0, true);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "F" + index, item.ritsu_budomari, indexDecimalBelow2, lang);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "G" + index, item.wt_kihon, indexSpCom, lang);
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "H" + index, item.ritsu_kihon, indexDecimalBelow2, lang);

                            // 換算区分：単位区分によって表示が変わる
                            //ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.nm_tani, 0, true);
                            string nmKbnKanzan = kanzan_kg;  // デフォルト：Kg
                            if (ActionConst.LKanzanKbn.Equals(item.kbn_kanzan))
                            {
                                // 換算区分が「11：L」の場合
                                nmKbnKanzan = kanzan_Li;
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, nmKbnKanzan, 0, true);

                            ExcelUtilities.changeNullToBlank(wbPart, ws, "J" + index, item.ritsu_hiju, indexDecimalBelow2, lang);
                            // 仕込み合算フラグ：なしの場合は空白、合算の場合は「合算」
                            if (item.flg_gassan_shikomi == ActionConst.FlagFalse)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, "", 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, Resources.Gassan, 0, true);
                            }
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "L" + index, item.wt_saidai_shikomi, indexSpCom6, lang);
                            // 処理品フラグ：なしの場合は空白、処理品の場合は「処理品」
                            if (item.flg_shorihin == ActionConst.FlagFalse)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, "", 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, Resources.Shorihin, 0, true);
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.cd_line, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, item.nm_line, 0, true);
                            if (item.no_juni_yusen != null)
                            {
                                ExcelUtilities.changeNullToBlank(wbPart, ws, "P" + index, item.no_juni_yusen, 0, lang);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, "", 0, true);
                            }
                            // 展開フラグ：「する」or「しない」
                            if (item.flg_tenkai == ActionConst.FlagTrue)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, Resources.Suru, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, Resources.Shinai, 0, true);
                            }
                            // 未使用フラグ：使用の場合は空白、未使用の場合は「未使用」
                            if (item.flg_mishiyo == ActionConst.FlagFalse)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, "", 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, Resources.Mishiyo, 0, true);
                            }

                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        ws.Save();
                        // TODO:ここまで
                    }
                    
                    /// レポートの取得
                    string reportname = excelname + ".xlsx";
                    // レスポンスを生成して返します
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);    
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.haigoMasterIchiranCookie, Resources.CookieValue);
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
        /// <param name="kbn_hin">品区分</param>
        /// <param name="kbn_master">マスタ区分</param>
        /// <param name="dt_shokichi">日付の初期値</param>
        /// <param name="flg_mishiyo">未使用フラグ：使用</param>
        /// <param name="cd_bunrui">分類コード</param>
        /// <param name="haigoName">配合名</param>
        /// <param name="lang">ブラウザ言語</param>
        /// <returns>明細データ</returns>
        private IEnumerable<usp_HaigoMasterIchiran_select_Result> GetEntity(
            //short kbn_hin, short kbn_master, String dt_shokichi, short flg_mishiyo, String cd_bunrui, String haigoName, String lang)
            //short kbn_hin, short kbn_master, DateTime dt_shokichi, short flg_mishiyo, String cd_bunrui, String haigoName, String lang, DateTime sysDate)
            short kbn_hin, short kbn_master, DateTime dt_shokichi, short flg_mishiyo, String cd_bunrui, String haigoName, String lang, DateTime dt_from)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HaigoMasterIchiran_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_HaigoMasterIchiran_select(
                    kbn_hin,
                    kbn_master,
                    dt_shokichi,
                    flg_mishiyo,
                    cd_bunrui,
                    haigoName,
                    lang,
                    //ActionConst.HanNoShokichi
                    //sysDate
                    dt_from
                    , ActionConst.FlagTrue
                    , ActionConst.FlagFalse
                ).AsEnumerable();

            return views;
        }
    }
}