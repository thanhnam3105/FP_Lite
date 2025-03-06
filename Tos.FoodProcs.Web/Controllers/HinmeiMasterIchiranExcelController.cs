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
using Tos.FoodProcs.Web.Properties;

using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;


namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 品名マスタ一覧画面のExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class HinmeiMasterIchiranExcelController : ApiController
    {
        
        // HTTP:GET
        /// <summary>ExcelFile作成処理</summary>
        /// <param name="criteria">検索条件</param>
        /// <param name="hinKbn">ヘッダー/品区分</param>
        /// <param name="bunrui">ヘッダー/分類</param>
        /// <param name="hokan">ヘッダー/保管区分</param>
        /// <param name="userName">ヘッダー/ユーザー名</param>
        /// <returns>ExcelFile</returns>
        public HttpResponseMessage Get([FromUri]HinmeiMasterIchiranCriteria criteria,
            String hinKbn, String bunrui, String hokan, String userName)
        {
            // ブラウザ言語
            String lang = criteria.lang;
            FoodProcsEntities context = new FoodProcsEntities();

            try
            {
                // ファイル名の指定
                short cdKbnHin = criteria.con_kbn_hin;
                String templateName = GetFileName(cdKbnHin);

                // 出力ファイル名 拡張子は不要
                String excelname = Resources.HinmeiMasterIchiranExcel;

                // pathの取得
                String serverpath = HttpContext.Current.Server.MapPath("..");
                String templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, lang);

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
                        UInt32 indexSpCom4 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma4, ActionConst.idSplitComma4);
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);
                        UInt32 indexSpCom6 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma6, ActionConst.idSplitComma6);
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // 数値以外：下詰め、折り返し
                        UInt32 fmtString = FoodProcsCommonUtility.ExcelCellFormatAlign(sheet);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);
                        //int addHours = 9;   // UTC用9h+

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

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

                        // ヘッダー行をセット
                        // 検索条件
                        // 品区分
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", hinKbn, 0, true);
                        // 分類
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", bunrui, 0, true);
                        // 保管区分
                        ExcelUtilities.UpdateValue(wbPart, ws, "B4", hokan, 0, true);
                        // 品名
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei), 0, true);
                        // 未使用表示
                        String mishiyoHyoji = Resources.Nashi;
                        if (Resources.FlagTrue.Equals(criteria.mishiyo_hyoji.ToString()))
                        {
                            mishiyoHyoji = Resources.Ari;
                        }
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", mishiyoHyoji, 0, true);

                        // 出力日時
                        ExcelUtilities.UpdateValue(wbPart, ws, "B8", criteria.local_today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
                        // 出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B9", userName, 0, true);

                        // 明細行開始ポイント
                        int index = 12;

                        // Entity取得
                        IEnumerable<usp_HinmeiMasterIchiran_select_Result> results;
                        results = GetEntity(context, criteria);

                        // シートデータへ値をマッピング
                        foreach (usp_HinmeiMasterIchiran_select_Result item in results)
                        {
                            // UpdateValue最後の項目(isString)は文字列でTrue, 数値でfalse を渡します

                            // ■======= 共通項目
                            // 品名コード
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.cd_hinmei, fmtString, true);
                            // 品名：多言語対応
                            string hinmei = GetName(lang, item.nm_hinmei_ja, item.nm_hinmei_en, item.nm_hinmei_zh, item.nm_hinmei_vi);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, hinmei, fmtString, true);
                            // 荷姿表示用
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_nisugata_hyoji, fmtString, true);
                            // 品名略
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_hinmei_ryaku, fmtString, true);
                            // 品区分
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_kbn_hin, fmtString, true);
                            // 荷姿内容量
                            SetNumberValue(wbPart, ws, "F" + index, item.wt_nisugata_naiyo.ToString(), indexSpCom6, lang);
                            // 入数
                            SetNumberValue(wbPart, ws, "G" + index, item.su_iri.ToString(), indexSpNoCom, lang);
                            // 一個の量
                            SetNumberValue(wbPart, ws, "H" + index, item.wt_ko.ToString(), indexSpCom6, lang);

                            // 一個の量の単位
                            //ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.nm_kbn_kanzan, fmtString, true);
                            string nmKbnKanzan = kanzan_kg;  // デフォルト：Kg
                            if (ActionConst.LKanzanKbn.Equals(item.kbn_kanzan))
                            {
                                // 換算区分が「11：L」の場合
                                nmKbnKanzan = kanzan_Li;
                            }
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, nmKbnKanzan, fmtString, true);

                            // 納入単位
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.tani_nonyu, fmtString, true);
                            // 使用単位
                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.tani_shiyo, fmtString, true);
                            // 比重
                            SetNumberValue(wbPart, ws, "L" + index, item.ritsu_hiju.ToString(), indexSpCom4, lang);
                            // 単価
                            SetNumberValue(wbPart, ws, "M" + index, item.tan_ko.ToString(), indexSpCom4, lang);
                            // 分類
                            ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.nm_bunrui, fmtString, true);
                            // 賞味期間
                            SetNumberValue(wbPart, ws, "O" + index, item.dd_shomi.ToString(), fmtString, lang);
                            // 賞味期間単位：「日」固定
                            //ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, Resources.Day, fmtString, true);
                            // 開封後賞味期間
                            SetNumberValue(wbPart, ws, "P" + index, item.dd_kaifugo_shomi.ToString(), fmtString, lang);
                            // 開封後賞味期間単位：「日」固定
                            //ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, Resources.Day, fmtString, true);
                            // 解凍後賞味期間
                            SetNumberValue(wbPart, ws, "Q" + index, item.dd_kaitogo_shomi.ToString(), fmtString, lang);
                            // 保管区分
                            //ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, item.nm_hokan, fmtString, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, item.nm_hokan, fmtString, true);
                            // 開封後保管区分
                            //ExcelUtilities.UpdateValue(wbPart, ws, "R" + index, item.nm_kaifugo_hokan, fmtString, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "S" + index, item.nm_kaifugo_hokan, fmtString, true);
                            // 解凍後保管区分
                            ExcelUtilities.UpdateValue(wbPart, ws, "T" + index, item.nm_kaitogo_hokan, fmtString, true);
                            // 状態区分
                            //ExcelUtilities.UpdateValue(wbPart, ws, "S" + index, item.nm_kbn_jotai, fmtString, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "U" + index, item.nm_kbn_jotai, fmtString, true);
                            // 税区分
                            //ExcelUtilities.UpdateValue(wbPart, ws, "T" + index, item.nm_zei, fmtString, true);
                            // 歩留
                            //SetNumberValue(wbPart, ws, "T" + index, item.ritsu_budomari.ToString(), indexSpCom2);
                            SetNumberValue(wbPart, ws, "V" + index, item.ritsu_budomari.ToString(), indexSpCom2, lang);
                            // 最低在庫
                            //SetNumberValue(wbPart, ws, "U" + index, item.su_zaiko_min.ToString(), indexSpCom6);
                            SetNumberValue(wbPart, ws, "W" + index, item.su_zaiko_min.ToString(), indexSpCom6, lang);
                            // 最大在庫
                            //SetNumberValue(wbPart, ws, "V" + index, item.su_zaiko_max.ToString(), indexSpCom6);
                            SetNumberValue(wbPart, ws, "X" + index, item.su_zaiko_max.ToString(), indexSpCom6, lang);
                            // 荷受場所
                            //ExcelUtilities.UpdateValue(wbPart, ws, "W" + index, item.nm_niuke, fmtString, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "Y" + index, item.nm_niuke, fmtString, true);

                            // 納入リードタイム
                            //SetNumberValue(wbPart, ws, "X" + index, item.dd_leadtime.ToString(), fmtString);
                            SetNumberValue(wbPart, ws, "Z" + index, item.dd_leadtime.ToString(), fmtString, lang);
                            // 備考
                            //ExcelUtilities.UpdateValue(wbPart, ws, "Y" + index, item.biko, fmtString, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "AA" + index, item.biko, fmtString, true);
                            // 未使用フラグ
                            if (short.Parse(Resources.FlagFalse) == item.flg_mishiyo)
                            {
                                //ExcelUtilities.UpdateValue(wbPart, ws, "Z" + index, Resources.Shiyo, fmtString, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, Resources.Shiyo, fmtString, true);
                            }
                            else
                            {
                                //ExcelUtilities.UpdateValue(wbPart, ws, "Z" + index, Resources.Mishiyo, fmtString, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, Resources.Mishiyo, fmtString, true);
                            }

                            // ■======= 品区分：製品、自家原料の場合に出力する項目
                            if (ActionConst.SeihinHinKbn.Equals(cdKbnHin) || ActionConst.JikaGenryoHinKbn.Equals(cdKbnHin))
                            {
                                // 販売先１
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AA" + index, item.nm_torihiki1, fmtString, true);
                                // 販売先２
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, item.nm_torihiki2, fmtString, true);
                                // 配合コード
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AA" + index, item.cd_haigo, fmtString, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "AC" + index, item.cd_haigo, fmtString, true);
                                // 配合名：多言語対応
                                string haigoName = GetName(lang, item.nm_haigo_ja, item.nm_haigo_en, item.nm_haigo_zh, item.nm_haigo_vi);
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, hinmei, fmtString, true);
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, haigoName, fmtString, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "AD" + index, haigoName, fmtString, true);
                                // JANコード１
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AF" + index, item.cd_jan, fmtString, true);
                                // バッチ出来高
                                //SetNumberValue(wbPart, ws, "AC" + index, item.su_batch_dekidaka.ToString(), indexSpCom2);
                                SetNumberValue(wbPart, ws, "AE" + index, item.su_batch_dekidaka.ToString(), indexSpCom2, lang);
                                // バッチ乗数
                                //SetNumberValue(wbPart, ws, "AD" + index, item.su_palette.ToString(), indexSpNoCom);
                                // 標準労務費
                                //SetNumberValue(wbPart, ws, "AD" + index, item.kin_romu.ToString(), indexSpCom4);
                                SetNumberValue(wbPart, ws, "AF" + index, item.kin_romu.ToString(), indexSpCom4, lang);
                                // 1C/S経費
                                //SetNumberValue(wbPart, ws, "AE" + index, item.kin_keihi_cs.ToString(), indexSpCom4);
                                SetNumberValue(wbPart, ws, "AG" + index, item.kin_keihi_cs.ToString(), indexSpCom4, lang);
                                // 庫入区分
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AK" + index, item.nm_kbn_kuraire, fmtString, true);
                                // 納入単価
                                //SetNumberValue(wbPart, ws, "AF" + index, item.tan_nonyu.ToString(), indexSpCom4);
                                SetNumberValue(wbPart, ws, "AH" + index, item.tan_nonyu.ToString(), indexSpCom4, lang);
                                // 展開フラグ
                                //if (short.Parse(Resources.FlagTrue) == item.flg_tenkai)
                                //{
                                //    ExcelUtilities.UpdateValue(wbPart, ws, "AM" + index, Resources.Suru, fmtString, true);
                                //}
                                //else
                                //{
                                //    ExcelUtilities.UpdateValue(wbPart, ws, "AM" + index, Resources.Shinai, fmtString, true);
                                //}
                            }

                            // ■======= 品区分：原料、資材の場合に出力する項目
                            else if (ActionConst.GenryoHinKbn.Equals(cdKbnHin) || ActionConst.ShizaiHinKbn.Equals(cdKbnHin))
                            {
                                // 製造元コード
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, item.cd_seizo, fmtString, true);
                                // 製造元名
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AC" + index, item.nm_seizo, fmtString, true);
                                // メーカー品コード
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AD" + index, item.cd_maker_hin, fmtString, true);
                                // 発注ロットサイズ
                                //SetNumberValue(wbPart, ws, "AA" + index, item.su_hachu_lot_size.ToString(), indexSpCom2);
                                SetNumberValue(wbPart, ws, "AC" + index, item.su_hachu_lot_size.ToString(), indexSpCom2, lang);
                                // 庫場所名
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, item.nm_kura, fmtString, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "AD" + index, item.nm_kura, fmtString, true);
                                // ロケーション名
                                //ExcelUtilities.UpdateValue(wbPart, ws, "AB" + index, item.nm_kura, fmtString, true);
                                ExcelUtilities.UpdateValue(wbPart, ws, "AE" + index, item.nm_location, fmtString, true);
                            }

                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        ws.Save();
                        // TODO: ここまで
                    }

                    // 画面側へ返却します
                    HttpResponseMessage result = new HttpResponseMessage();
                    result.StatusCode = HttpStatusCode.OK;

                    ///// レポートの取得
                    string reportname = excelname + ".xlsx";
                    // レスポンスを生成して返します
                    //return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.hinmeiMasterCookie, Resources.CookieValue);
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

        /// <summary>品区分から指定のEXCELのファイル名を取得します。</summary>
        /// <param name="hinKbn">品区分</param>
        /// <returns>ファイル名</returns>
        private string GetFileName(short hinKbn)
        {
            string templateName = "hinmeiMasterIchiran";
            string pattern = "";
            string templateFileName = "";

            if (ActionConst.SeihinHinKbn.Equals(hinKbn) || ActionConst.JikaGenryoHinKbn.Equals(hinKbn))
            {
                // 品区分が「製品」または「自家原料」の場合
                pattern = "pattern3";
            }
            else if (ActionConst.GenryoHinKbn.Equals(hinKbn) || ActionConst.ShizaiHinKbn.Equals(hinKbn))
            {
                // 品区分が「原料」または「資材」の場合
                pattern = "pattern7";
            }

            // テンプレートファイル名の作成
            templateFileName = templateName + "_" + pattern;

            return templateFileName;
        }

        /// <summary>明細データを取得します。</summary>
        /// <param name="context">エンティティ</param>
        /// <param name="criteria">検索条件</param>
        /// <returns>取得した明細データ</returns>
        private IEnumerable<usp_HinmeiMasterIchiran_select_Result> GetEntity(
            FoodProcsEntities context, HinmeiMasterIchiranCriteria criteria)
        {
            //FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HinmeiMasterIchiran_select_Result> views;
            views = context.usp_HinmeiMasterIchiran_select(
                criteria.con_kbn_hin,
                criteria.con_bunrui,
                criteria.con_kbn_hokan,
                FoodProcsCommonUtility.changedNullToEmpty(criteria.con_hinmei),
                criteria.mishiyo_hyoji,
                criteria.lang,
                criteria.kbnUriagesaki,
                criteria.kbnSeizomoto,
                criteria.flgShiyo,
                criteria.hanNo
                ).AsEnumerable();

            return views;
        }

        /// <summary>数値系項目のマッピング処理。nullの場合は空白を設定します。</summary>
        /// <param name="wbPart">ワークブック</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="cellNo">設定するセル番号</param>
        /// <param name="item">設定する値</param>
        /// <param name="fmt">書式番号</param>
        private void SetNumberValue(WorkbookPart wbPart, Worksheet ws, String cellNo, String item, UInt32 fmt, string lang)
        {
            String value = item;
            bool isStr = false;
            if (String.IsNullOrEmpty(value))
            {
                value = "";
                isStr = true;
                fmt = 0;
            }
            else { 
                if(lang == Resources.LangVi){
                    value = value.Replace(',', '.');
                }
            }
            ExcelUtilities.UpdateValue(wbPart, ws, cellNo, value, fmt, isStr);
        }

        /// <summary>
        /// 多言語対応の名称を返却する
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="name_ja">名称_日本語</param>
        /// <param name="name_en">名称_英語</param>
        /// <param name="name_zh">名称_中国語</param>
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
    }
}