using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
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
	/// 製造日報ExcelFile作成コントローラを定義します。
	/// </summary>
	/// <remarks>
	/// </remarks>


	[Authorize]
	[LoggingExceptionFilter]
	public class SeizoNippoExcelController : ApiController
	{

        public int startGrid = 10;

		// HTTP:GET
		public HttpResponseMessage Get([FromUri]SeizoNippoCriteria criteria)
		{
            // 言語取得
            string lang = criteria.lang;

            try
			{
				// TODO:ダウンロードの準備
				// Entity取得
				FoodProcsEntities context = new FoodProcsEntities();

				// ファイル名の指定
				string templateName = "seizoNippo"; // return形式 "_lang.xlsx" 
				string excelname = Resources.SeizoNippoExcel;
                // 出力ファイル名 拡張子は不要
				// TODO:ここまで

				// pathの取得
				string serverpath = HttpContext.Current.Server.MapPath("..");
				string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, criteria.lang);

				/// テンプレートを読み込み、必要な情報をマッピングしてクライアントへ返却
				byte[] byteArray = File.ReadAllBytes(templateFile);
                string dt_seizo = criteria.dt_seizo.ToString();
                string cd_shokuba = criteria.cd_shokuba;
                string cd_line = criteria.cd_line;

				using (MemoryStream mem = new MemoryStream())
				{
					mem.Write(byteArray, 0, (int)byteArray.Length);
					using (SpreadsheetDocument spDoc = SpreadsheetDocument.Open(mem, true))
					{
						// 定義記述
						string NmSheet = "Sheet1";
						WorkbookPart wbPart = spDoc.WorkbookPart;
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet;
                        sheet.NumberingFormats = new NumberingFormats();

                        // 書式設定の追加
                        // カンマ区切り、小数点以下0桁
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);
                        // カンマ区切り、小数点以下2桁
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);
                        // カンマ区切り、小数点以下3桁
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                           sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        // 数値以外：下詰め、折り返し
                        UInt32 fmtString = FoodProcsCommonUtility.ExcelCellFormatAlign(sheet);

                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // Entityよりデータを取得
                        DateTime seizoDate = DateTime.Parse(dt_seizo);
                        short hinmeiMasterKbn = ActionConst.HinmeiMasterKbn;
						var query = from d in context.vw_tr_keikaku_seihin_01 orderby d.cd_hinmei select d;
						query = query.Where(v => v.dt_seizo.CompareTo(seizoDate) == 0
                                        && v.cd_shokuba == cd_shokuba
                                        && v.kbn_master == hinmeiMasterKbn
                                        && v.cd_line == (cd_line ?? v.cd_line)) as IOrderedQueryable<vw_tr_keikaku_seihin_01>;
						query = query.OrderBy(v => v.cd_hinmei) as IOrderedQueryable<vw_tr_keikaku_seihin_01>;
                        // 検索条件/ラインコードが指定されている場合、ラインコードで絞る
                        if (!string.IsNullOrEmpty(cd_line) && cd_line != "null" && cd_line != "undefined")
                        {
                            query = query.Where(v => v.cd_line.Contains(cd_line))
                                        as IOrderedQueryable<vw_tr_keikaku_seihin_01>;
                        }

						// 明細行開始ポイント
						int index = startGrid;
                        string nm_shokuba = "";
                        string nm_line = Resources.NoSelectConditionExcel;  // 初期値「未選択」

						// シートデータへ値をマッピング
                        foreach (vw_tr_keikaku_seihin_01 item in query.ToList())
						{
                            if (index == startGrid) {
                                nm_shokuba = item.nm_shokuba;
                                if (!string.IsNullOrEmpty(cd_line) && cd_line != "null" && cd_line != "undefined") {
                                    nm_line = item.nm_line;
                                }
                            }
                            // 出力用の確定を設定
                            string kakutei = "";
                            if (item.flg_jisseki.ToString() == Resources.FlagTrue) {
                                kakutei = Resources.Kakutei;
                            }
                            // 製品名を取得（多言語対応）
                            string nm_hinmei = "";
                            if (lang == Resources.LangJa) {
                                nm_hinmei = item.nm_hinmei_ja;
                            }
                            else if (lang == Resources.LangEn) {
                                nm_hinmei = item.nm_hinmei_en;
                            }
                            else if (lang == Resources.LangZh) {
                                nm_hinmei = item.nm_hinmei_zh;
                            }
                            else if (lang == Resources.LangVi)
                            {
                                nm_hinmei = item.nm_hinmei_vi;
                            }

                            // 賞味期限のNULLチェック
                            string shomiKigen = "";
                            if (item.dt_shomi != null) {
                                shomiKigen = item.dt_shomi.Value.ToLocalTime().ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                            }

                            // 製造日を言語ごとのフォーマットに変換
                            string item_seizoDate = item.dt_seizo.ToLocalTime().ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                            
                            //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
							ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, kakutei, fmtString, true); // 確定
							ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_hinmei, fmtString, true); // コード
							ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, nm_hinmei, fmtString, true); // 製品名
							ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.cd_line, fmtString, true); // ラインコード
							ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_line, fmtString, true); // ライン名
							ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, (item.su_seizo_yotei ?? 0).ToString(), indexSpNoCom, false); // 製造予定数
                            ExcelUtilities.changeNullToBlank(wbPart, ws, "G" + index, item.su_seizo_jisseki, indexSpCom3, lang); // 製造実績数※stringではない必須項目
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, shomiKigen, fmtString, true); // 賞味期限
							ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.no_lot_seihin, fmtString, true); // 製品ロット番号
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item_seizoDate, fmtString, true); // 製造日※stringではない必須項目
							ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.no_lot_hyoji, fmtString, true); // 表示ロットNo
                            changeNullToBlank(wbPart, ws, "L" + index, item.su_batch_jisseki, indexSpNoCom, lang);  // バッチ数
                            changeNullToBlank(wbPart, ws, "M" + index, item.ritsu_kihon, indexSpCom2, lang);  // 倍率

							// 行のポインタを一つカウントアップ
							index++;
						}

                        // ヘッダー行(検索条件)をセット
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", criteria.dt_seizo.ToLocalTime().ToString(FoodProcsCommonUtility.formatDateSelect(lang)), 0, true); // 製造日
                        ExcelUtilities.UpdateValue(wbPart, ws, "B3", nm_shokuba, 0, true); // 職場
                        ExcelUtilities.UpdateValue(wbPart, ws, "B4", nm_line, 0, true); // ライン
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", criteria.today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang)), 0, true); // 出力日時
                        ExcelUtilities.UpdateValue(wbPart, ws, "B7", criteria.userName, 0, true); // 出力者

						ws.Save();
					}

					// レポートの取得
					string reportname = excelname + ".xlsx";
                    // レスポンスを生成して返します
					//return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.SeizoNippoCookie, Resources.CookieValue);
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
        /// 取得結果がNULLだった場合、空白を設定します
        /// </summary>
        /// <param name="wbPart">WorkbookPart</param>
        /// <param name="ws">ワークシート</param>
        /// <param name="address">アドレスネーム</param>
        /// <param name="value">取得結果</param>
        /// <param name="index">書式番号</param>
        private void changeNullToBlank(WorkbookPart wbPart, Worksheet ws, string address, decimal? value, UInt32 index,string lang)
        {
            if (value == null)
            {
                // NULLだった場合、空白を設定
                ExcelUtilities.UpdateValue(wbPart, ws, address, "", 0, true);
            }
            else
            {
                string val = value.ToString();
                switch (lang)
                {
                    case "vi":
                        {
                            val = val.Replace(',', '.');
                            break;
                        }
                    default: break;
                }
                ExcelUtilities.UpdateValue(wbPart, ws, address, val, index, false);
            }
        }
    }
}