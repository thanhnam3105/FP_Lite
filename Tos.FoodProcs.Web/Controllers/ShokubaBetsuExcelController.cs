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
    [Authorize]
    [LoggingExceptionFilter]
    public class ShokubaBetsuExcelController : ApiController
    {
        // 定数設定
        /// <summary>出庫委託数計算関数</summary>
        private const string KANSU_SU_SYUKKO_ITAKU = "=IF(ROUNDUP(I{0},0)<0,0,ROUNDUP(I{0}/(M{0}*N{0}),0))";
        /// <summary>必要量計算関数</summary>
        private const string KANSU_SU_HITSUYO_RYO = "=G{0}-H{0}";

        public HttpResponseMessage Get([FromUri]GenshizaiShiyoryoKeisanCriteria criteria, String lang, DateTime outputDate)
        {
            // 変数定義
            string templateName;                                                    // テンプレートファイル名
            string nmSheet;                                                         // テンプレートシート名
            string reportname;                                                      // 出力ファイル名
            HttpResponseMessage ExcelFile;                                          // Excelファイル

            byte[] byteArray;                                                       // テンプレート情報格納配列
            
            string[] cdShokubaArray;                                                // 職場コード格納配列
            string[] nmShokubaArray;                                                // 職場名格納配列
            string cdShokuba;                                                       // 職場コード
            string nmShokuba;                                                       // 職場名
            int shokubaCnt;                                                         // 選択職場数

            char[] alpha;                                                           // Excelの列文字格納配列（A～Z）

            MemoryStream mem;                                                       // メモリーストリーム
            SpreadsheetDocument spDoc;                                              // スプレッドドキュメント(テンプレート)
            WorkbookPart wbPart;                                                    // ワークブックパート(テンプレート)
            Worksheet copyWs;

            // ファイル名の指定
            templateName = "kuradashiIraiShokuba";
            // シート名の指定
            nmSheet = "Sheet1";

            // 職場コードと職場名を配列に格納
            cdShokubaArray = criteria.con_shokuba.Split(',');
            nmShokubaArray = criteria.shokubaName.Split(',');

            // 選択職場数の設定
            shokubaCnt = cdShokubaArray.Length;

            // Excelの列アルファベットの取得
            alpha = Resources.ExcelLineName.ToCharArray();

            try
            {
                /// テンプレートを読み込む
                byteArray = GetTemplate(templateName, lang);

                // メモリーストリームの生成
                mem = new MemoryStream();
                
                // 読み込んだテンプレートをメモリーストリームに書き込む
                mem.Write(byteArray, 0, byteArray.Length);

                // メモリーストリームからスプレッドシートドキュメントを開く
                spDoc = SpreadsheetDocument.Open(mem, true);
                
                // テンプレートのワークブックを取得
                wbPart = spDoc.WorkbookPart;

                // 書式設定格納用
                Dictionary<string, UInt32> format = new Dictionary<string, UInt32>();

                // ワークブックの書式、字体、自動計算の設定を行う
                wbSetting(wbPart, format);

                // 選択職場分処理を行う
                for (int i = 0; i < shokubaCnt; i++)
                {
                    cdShokuba = cdShokubaArray[i].Trim();
                    nmShokuba = nmShokubaArray[i].Trim();

                    // テンプレートのワークシートをコピーする
                    copyWs = CopyWorkSheet(wbPart, nmSheet, nmShokuba);

                    // Excelヘッダー作成
                    CreateHeder(criteria, wbPart, copyWs, alpha, nmShokuba, lang, outputDate);

                    // Excel明細作成
                    CreateIndex(criteria, wbPart, copyWs, format, alpha, cdShokuba, lang);

                    // シートフォーカスの削除
                    CleanView(wbPart, nmSheet);
                }

                // テンプレートシートの削除
                DeleteSheet(wbPart, nmSheet);

                // スプレッドシートを閉じる
                spDoc.Close();

                ///// レポートの取得
                reportname = Resources.GenryoShiyoryoKeisanExcel +".xlsx";
                //ExcelFile = FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                ExcelFile = FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.shokubaDialogCookie, Resources.CookieValue);

                // メモリーストリームを開放する
                mem.Dispose();

                // Excelを返却
                return ExcelFile;
            }
            catch (Exception e)
            {
                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
                try
                {
                    // ファイル名の指定
                    templateName = "Error";

                    /// テンプレートを読み込む
                    byteArray = GetTemplate(templateName, lang);

                    // メモリーストリームの生成
                    mem = new MemoryStream();

                    // 読み込んだテンプレートをメモリーストリームに書き込む
                    mem.Write(byteArray, 0, byteArray.Length);

                    reportname = "Error.xlsx";

                    ExcelFile = FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);

                    // レスポンスを生成して返します
                    return ExcelFile;
                }
                catch (Exception)
                {
                    ///// エラー用のEXCELテンプレートが無い場合など
                    mem = new MemoryStream();

                    reportname = "error.xlsx";

                    ExcelFile = FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);

                    // 空っぽのデータでレスポンスを生成して返却
                    return ExcelFile;
                }
            }
        }

        /// <summary>
        /// テンプレートを読み込む
        /// </summary>
        /// <param name="templateName">テンプレートのブック名</param>
        /// <param name="lang">ブラウザ言語</param>
        private byte[] GetTemplate(string templateName, string lang)
        {
            // 変数定義
            string serverpath;
            string templateFile;
            byte[] result;

            // pathの取得
            serverpath = HttpContext.Current.Server.MapPath("..");

            // テンプレートファイルを取得する
            templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, lang);

            /// テンプレートを読み込む
            result = File.ReadAllBytes(templateFile);

            return result;
        }

        /// <summary>
        /// テンプレートのワークシートパートを取得する
        /// </summary>
        /// <param name="workbookPart">ワークブックパート</param>
        /// <param name="sheetName">シート名</param>
        private WorksheetPart GetWorkSheetPart(WorkbookPart workbookPart, string sheetName)
        {
            // 変数定義
            WorksheetPart wsPart;
            IEnumerable<Sheet> sheets;
            Sheet sheet;

            sheets = workbookPart.Workbook.Descendants<Sheet>();
            sheets.Where(s => s.Name.Value.Equals(sheetName));

            sheet = sheets.First();

            // 取得したワークシートのIDからワークシート取得
            wsPart = (WorksheetPart)workbookPart.GetPartById(sheet.Id);

            return wsPart;

        }

        /// <summary>
        /// 書式設定
        /// </summary>
        /// <param name="wbPart">ワークブックパート</param>
        /// <param name="format">書式設定</param>
        private Dictionary<string, UInt32> FormatSetting(WorkbookPart wbPart, Dictionary<string, UInt32> format)
        {
            UInt32 indexSpCom3;
            UInt32 indexSpNoCom;
            UInt32 fmtString;

            // スタイルシートの取得
            Stylesheet styleSheet = wbPart.WorkbookStylesPart.Stylesheet;

            styleSheet.NumberingFormats = new NumberingFormats();

            // カンマ区切り、小数点以下3桁
            indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(styleSheet, ActionConst.fmtSplitComma3,
                                                                                                ActionConst.idSplitComma3);
            format.Add("index_sp_com3", indexSpCom3);

            // カンマ区切り、小数点なし
            indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(styleSheet, ActionConst.fmtSplitNoComma,
                                                                                                ActionConst.idSplitNoComma);
            format.Add("index_sp_no_com", indexSpNoCom);

            // 数値以外：下詰め、折り返し
            fmtString = FoodProcsCommonUtility.ExcelCellFormatAlign(styleSheet);

            format.Add("fmt_string", fmtString);

            return format;
        }

        /// <summary>
        /// フォント設定
        /// </summary>
        /// <param name="wbPart">ワークブックパート</param>
        private void FontSetting(WorkbookPart wbPart)
        {
            // スタイルシートの取得
            Stylesheet styleSheet = wbPart.WorkbookStylesPart.Stylesheet;

            // 追加スタイルのフォントを設定します。
            foreach (Font f in styleSheet.Fonts)
            {
                f.FontName = new FontName() { Val = Resources.DefaultFontName };
            }
        }

        /// <summary>
        /// 自動計算をExcelに設定する
        /// </summary>
        /// <param name="workbookPart">ワークブックパート</param>
        private void AutoCalcSetting(WorkbookPart wbPart)
        {
            // 変数定義
            CalculationProperties cp;     // 計算プロパティ

            // 計算プロパティの取得
            cp = wbPart.Workbook.CalculationProperties;

            // 計算プロパティがない場合
            // 計算プロパティを作成する
            if (cp == null)
            {
                cp = new CalculationProperties();
                wbPart.Workbook.CalculationProperties = cp;
            }

            // 自動計算にする
            cp.CalculationMode = new EnumValue<CalculateModeValues>(CalculateModeValues.Auto);
            // ファイル表示の際に再計算する
            cp.FullCalculationOnLoad = true;
        }

        /// <summary>
        /// Excelヘッダーを作成
        /// </summary>
        /// <param name="criteria">画面情報</param>
        /// <param name="wbPart">ワークブックパート</param> 
        /// <param name="ws">ワークシート</param> 
        /// <param name="alpha">Excelの列アルファベット</param>
        /// <param name="nmShokuba">職場名</param> 
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="outputDate">出力日</param>
        private void CreateHeder(GenshizaiShiyoryoKeisanCriteria criteria, WorkbookPart wbPart, Worksheet ws, char[] alpha,
                                                                            string nmShokuba, String lang, DateTime outputDate)
        {
            int i = 1;
            int k = 2;

            // 検索条件日付
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i] + k.ToString(),
                criteria.con_hizuke.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true);
            k++;
            // 品区分
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i] + k.ToString(), criteria.hinKubunName, 0, true);
            k++;
            // 分類
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i] + k.ToString(), criteria.bunruiName, 0, true);
            k++;
            // 職場
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i] + k.ToString(), nmShokuba, 0, true);
            k = k + 2;
            // 出力日
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i] + k.ToString(),
                outputDate.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true);
            k++;
            // 出力者
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i] + k.ToString(), criteria.userName, 0, true);
        }

        /// <summary>
        /// Excel明細を作成
        /// </summary>
        /// <param name="criteria">画面情報</param>
        /// <param name="wbPart">ワークブックパート</param> 
        /// <param name="ws">ワークシート</param>
        /// <param name="format">書式設定</param>
        /// <param name="alpha">Excelの列アルファベット</param>
        /// <param name="cdShokuba">職場コード</param> 
        /// <param name="lang">ブラウザ言語</param>
        private void CreateIndex(GenshizaiShiyoryoKeisanCriteria criteria, WorkbookPart wbPart, Worksheet ws,
                                            Dictionary<string, UInt32> format, char[] alpha, string cdShokuba, String lang)
        {
            IEnumerable<usp_GenshizaiShiyoryoKeisan_SYUKEI_Result> syukeiData;      // 集計データ
            IEnumerable<usp_GenshizaiShiyoryoKeisan_MEISAI_Result> meisaiData;      // 明細データ

            int index;                                                              // 明細データ開始位置

            // 集計情報の取得
            syukeiData = GetEntitySyukei(criteria, cdShokuba);
            // 明細データの取得
            meisaiData = GetEntityMeisai(criteria, cdShokuba);

            // 明細行開始ポイント
            index = 11;

            // 集計データの形成と設定を行う
            foreach (usp_GenshizaiShiyoryoKeisan_SYUKEI_Result item_syukei in syukeiData)
            {
                UpdateSyukeiData(item_syukei, wbPart, ws, format, alpha, index, lang);

                // 行のポインタを一つカウントアップ
                index++;

                // 明細データの形成と設定を行う
                foreach (usp_GenshizaiShiyoryoKeisan_MEISAI_Result item_meisai in meisaiData)
                {
                    if (item_syukei.cd_hinmei == item_meisai.cd_hinmei)
                    {
                        UpdateMeisaiData(item_meisai, wbPart, ws, format, alpha, index, lang);

                        // 行のポインタを一つカウントアップ
                        index++;
                    }
                }
            }
        }

        /// <summary>
        /// 集計データを取得します。
        /// </summary>
        /// <param name="con_hizuke">検索条件/日付</param>
        /// <param name="con_bunrui">検索条件/分類</param>
        /// <param name="hinKubun">品区分</param>
        /// <param name="cdShokuba">職場コード</param>
        /// <param name="flgYojitsu">予実フラグ</param>
        /// <returns>取得した検索結果</returns>
        private IEnumerable<usp_GenshizaiShiyoryoKeisan_SYUKEI_Result> GetEntitySyukei(
            GenshizaiShiyoryoKeisanCriteria criteria, string cdShokuba)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiShiyoryoKeisan_SYUKEI_Result> views;
            views = context.usp_GenshizaiShiyoryoKeisan_SYUKEI(
                criteria.con_hizuke,
                FoodProcsCommonUtility.changedNullToEmpty(criteria.con_bunrui),
                criteria.hinKubun,
                FoodProcsCommonUtility.changedNullToEmpty(cdShokuba),
                criteria.flg_yojitsu,
                ActionConst.FlagFalse,
                ActionConst.GenryoHinKbn,
                ActionConst.ShizaiHinKbn,
                ActionConst.JikaGenryoHinKbn,
                ActionConst.LKanzanKbn,
                criteria.utc
            ).ToList();

            return views;
        }

        /// <summary>
        /// 明細データを取得します。
        /// </summary>
        /// <param name="con_hizuke">検索条件/日付</param>
        /// <param name="cdShokuba">職場コード</param>
        /// <param name="flgYojitsu">予実フラグ</param> 
        /// <returns>取得した検索結果</returns>
        private IEnumerable<usp_GenshizaiShiyoryoKeisan_MEISAI_Result> GetEntityMeisai(
            GenshizaiShiyoryoKeisanCriteria criteria, string cdShokuba)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiShiyoryoKeisan_MEISAI_Result> views;
            views = context.usp_GenshizaiShiyoryoKeisan_MEISAI(
                criteria.con_hizuke,
                FoodProcsCommonUtility.changedNullToEmpty(cdShokuba),
                criteria.flg_yojitsu
            ).ToList();

            return views;
        }

        /// <summary>
        /// 多言語対応した原料名を返却（集計）
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="item">検索結果</param>
        /// <returns>原料名</returns>
        private string getGenryoName(string lang, usp_GenshizaiShiyoryoKeisan_SYUKEI_Result item)
        {
            // デフォルトはen
            string genryoName = item.nm_hinmei_en;

            if (Resources.LangJa.Equals(lang))
            {
                // ja：日本
                genryoName = item.nm_hinmei_ja;
            }
            else if (Resources.LangZh.Equals(lang))
            {
                // zh：中国
                genryoName = item.nm_hinmei_zh;
            }
            else if (Resources.LangVi.Equals(lang))
            {
                // vi：
                genryoName = item.nm_hinmei_vi;
            }

            // nullの場合はブランクにする
            genryoName = FoodProcsCommonUtility.changedNullToEmpty(genryoName);

            return genryoName;
        }

        /// <summary>
        /// 多言語対応した配合名を返却（明細）
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="item">検索結果</param>
        /// <returns>原料名</returns>
        private string getHaigoOrShizaiName(string lang, usp_GenshizaiShiyoryoKeisan_MEISAI_Result item)
        {
            // デフォルトはen
            string HaigoOrShizaiName = item.nm_hinmei_en;

            if (Resources.LangJa.Equals(lang))
            {
                // ja：日本
                HaigoOrShizaiName = item.nm_hinmei_ja;
            }
            else if (Resources.LangZh.Equals(lang))
            {
                // zh：中国
                HaigoOrShizaiName = item.nm_hinmei_zh;
            }
            else if (Resources.LangVi.Equals(lang))
            {
                // vi:
                HaigoOrShizaiName = item.nm_hinmei_vi;
            }

            // nullの場合はブランクにする
            HaigoOrShizaiName = FoodProcsCommonUtility.changedNullToEmpty(HaigoOrShizaiName);

            return HaigoOrShizaiName;
        }

        /// <summary>
        /// 集計データをExcelに設定
        /// </summary>
        /// <param name="item">集計データ</param>
        /// <param name="wbPart">ワークブックパート</param> 
        /// <param name="ws">ワークシート</param> 
        /// <param name="alpha">Excelの列アルファベット</param>
        /// <param name="index">開始行</param> 
        /// <param name="lang">ブラウザ言語</param>
        private void UpdateSyukeiData(usp_GenshizaiShiyoryoKeisan_SYUKEI_Result item, WorkbookPart wbPart, Worksheet ws, 
                                                    Dictionary<string, UInt32> format, char[] alpha, int index, string lang)
        {
            // 変数定義
            DateTime shukkoDate;                                                    // 出庫日
            decimal shiyo_yoteiryo_syukei;                                          // 使用予定量(集計データ)
            decimal zenjitsu_zan;                                                   // 前日残
            int i = 0;

            // 型変換
            shukkoDate = (DateTime)item.dt_shukko;

            // 設定値の桁数調整
            shiyo_yoteiryo_syukei = FoodProcsCommonUtility.decimalTruncate((decimal)item.su_shiyo_sum, 3);
            zenjitsu_zan = FoodProcsCommonUtility.decimalTruncate((decimal)item.wt_shiyo_zan, 3);

            ///// 最後の項目(isString)は文字列でTrue, 数値でfalse を渡します

            // 出庫日
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index,
                shukkoDate.ToString(FoodProcsCommonUtility.formatDateSelect(lang)), format["fmt_string"], true);
            i++;
            // 集計区分
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, Resources.nm_shukeiKbn, format["fmt_string"], true);
            i++;
            // 品名コード
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, item.cd_hinmei, format["fmt_string"], true);
            i++;
            // 品名
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, getGenryoName(lang, item), format["fmt_string"], true);
            i++;
            // 荷姿
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, item.nm_nisugata_hyoji, format["fmt_string"], true);
            i++;
            // 使用単位
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, item.nm_tani, format["fmt_string"], true);
            i++;
            // 使用予定量集計
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, shiyo_yoteiryo_syukei.ToString(), format["index_sp_com3"], false);
            i++;
            // 前日残
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, zenjitsu_zan.ToString(), format["index_sp_com3"], false);
            i++;
            // 必要量(関数のみ)
            ExcelUtilities.UpdateFormula(ws, alpha[i].ToString() + index, String.Format(KANSU_SU_HITSUYO_RYO, index), format["index_sp_com3"]);
            i++;
            // 庫出単位
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, item.nm_tani_kuradashi, format["fmt_string"], true);
            i++;
            // 庫出依頼数(関数のみ)
            ExcelUtilities.UpdateFormula(ws, alpha[i].ToString() + index, String.Format(KANSU_SU_SYUKKO_ITAKU, index), format["index_sp_no_com"]);
            i++;
            // 庫出依頼端数
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, "0", format["index_sp_no_com"], false);
            i++;
            // 入数
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, item.su_iri.ToString(), format["fmt_string"], false);
            i++;
            // 個重量
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, item.wt_ko.ToString(), format["fmt_string"], false);
        }

        /// <summary>
        /// 明細データをExcelに設定
        /// </summary>
        /// <param name="item">集計データ</param>
        /// <param name="wbPart">ワークブックパート</param> 
        /// <param name="ws">ワークシート</param> 
        /// <param name="alpha">Excelの列アルファベット</param>
        /// <param name="index">開始行</param> 
        /// <param name="lang">ブラウザ言語</param>
        private void UpdateMeisaiData(usp_GenshizaiShiyoryoKeisan_MEISAI_Result item, WorkbookPart wbPart, Worksheet ws, 
                                                    Dictionary<string, UInt32> format, char[] alpha, int index, string lang)
        {
            // 変数定義
            decimal shiyo_yoteiryo_meisai;
            int i = 1;

            // 設定値の桁数調整
            shiyo_yoteiryo_meisai = FoodProcsCommonUtility.decimalTruncate((decimal)item.SUM_su_shiyo, 3);

            // 集計区分
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, Resources.nm_meisai, format["fmt_string"], true);
            i++;
            // 品名コード
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, item.code, format["fmt_string"], true);
            i++;
            // 品名
            ExcelUtilities.UpdateValue(wbPart, ws, alpha[i].ToString() + index, getHaigoOrShizaiName(lang, item).ToString(), format["fmt_string"], true);
            i = i + 3;
            // 使用予定量
            ExcelUtilities.changeNullToBlank(wbPart, ws, alpha[i].ToString() + index, shiyo_yoteiryo_meisai, format["index_sp_com3"], lang);
        }

        /// <summary>
        /// シートフォーカスの削除
        /// </summary>
        /// <param name="wsPart">ワークシートパート</param> 
        private void CleanView(WorkbookPart wbPart, string nmSheet)
        {
            WorksheetPart wsPart;

            wsPart = GetWorkSheetPart(wbPart, nmSheet);

            // シートビューの取得
            SheetViews views = wsPart.Worksheet.GetFirstChild<SheetViews>();

            // シートビューがある場合はシートビューを削除する
            if (views != null)
            {
                views.Remove();
            }
        }

        /// <summary>
        /// シート削除
        /// </summary>
        /// <param name="wbPart">ワークブックパート</param>
        /// <param name="nmSheet">削除するシート名</param>
        private void DeleteSheet(WorkbookPart wbPart, string nmSheet)
        {
            // 変数定義
            WorksheetPart wsPart;
            Sheets sheets;
            IEnumerable<Sheet> sheet;
            Sheet deleteSheet;
            
            wsPart = GetWorkSheetPart(wbPart, nmSheet);

            // シートテーブルの取得
            sheets = wbPart.Workbook.Sheets;

            // 削除するシートを取得
            sheet = sheets.ChildElements.OfType<Sheet>();
            deleteSheet = sheet.First(s => s.Name == nmSheet);
                
            // シートテーブルからシートを削除
            sheets.RemoveChild(deleteSheet);

            // 削除したシートに紐づくワークシートパートを削除
            wbPart.DeletePart(wsPart);
        }

        /// <summary>
        /// ワークシートコピー
        /// </summary>
        /// <param name="wbPart">ワークブックパート</param>
        /// <param name="nmSheet">コピーシート名</param>
        /// <param name="nmShokuba">職場名</param>
        private Worksheet CopyWorkSheet(WorkbookPart wbPart, string nmSheet, string nmShokuba)
        {
            // 変数定義
            WorksheetPart wsPart;                   // ワークシートパート
            Worksheet copyWs;                       // コピーワークシート

            wsPart = GetWorkSheetPart(wbPart, nmSheet);

            // シートコピー
            ExcelUtilities.CreateCopySheet(wbPart, wsPart, nmShokuba);

            // 保存したワークシートを取得し下記設定処理を行う
            copyWs = ExcelUtilities.FindWorkSheet(wbPart, nmShokuba);

            return copyWs;
        }

        /// <summary>
        /// ワークブック設定
        /// </summary>
        /// <param name="wbPart">ワークブックパート</param>
        /// <param name="format">書式設定</param>
        private void wbSetting(WorkbookPart wbPart, Dictionary<string, UInt32> format)
        {
            // 書式設定
            FormatSetting(wbPart, format);

            // フォント設定
            FontSetting(wbPart);

            // 自動計算設定
            AutoCalcSetting(wbPart);
        }
    }
}