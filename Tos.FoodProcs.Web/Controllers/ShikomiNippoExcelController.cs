using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using System.IO;
using Tos.FoodProcs.Web.Utilities;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Logging;

using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using Tos.FoodProcs.Web.Properties;
using System.Globalization;


namespace Tos.FoodProcs.Web.Controllers
{
	/// <summary>
	/// 仕込日報画面ExcelFile作成コントローラを定義します。
	/// </summary>
	/// <remarks>
	/// </remarks>


	[Authorize]
	[LoggingExceptionFilter]
	public class ShikomiNippoExcelController : ApiController
	{
        //public int startGrid = 13;
        public int startGrid = 18;

		// HTTP:GET
		public HttpResponseMessage Get([FromUri]ShikomiNippoCriteria criteria)
		{
            // 言語取得
            string lang = criteria.lang;

            try
			{
				// Entity取得
                FoodProcsEntities context = new FoodProcsEntities();
                List<usp_ShikomiNippo_select_Result> views;
                views = context.usp_ShikomiNippo_select(
                            criteria.dt_seizo_st
                            , criteria.dt_seizo_en
                            , criteria.cd_shokuba
                            , criteria.cd_line
                            , criteria.chk_mi_sakusei
                            , criteria.chk_mi_denso
                            , criteria.chk_denso_machi
                            , criteria.chk_denso_zumi
                            , criteria.chk_mi_toroku
                            , criteria.chk_ichibu_mi_toroku
                            , criteria.chk_toroku_sumi
                            , short.Parse(Resources.FlagFalse)
                            , ActionConst.HinmeiMasterKbn
                            , short.Parse(Resources.GenryoHinKbn)
                            , short.Parse(Resources.JikaGenryoHinKbn)
                            , criteria.skip, criteria.top
                            , ActionConst.FlagTrue
                            ).ToList();

				// ファイル名の指定
                string templateName = (criteria.dt_seizo_en.Subtract(criteria.dt_seizo_st).TotalDays == 0) ? "shikomiNippo" : "shikomiNippoSeizobiAri"; // return形式 "_lang.xlsx" 
				string excelname = Resources.ShikomiNippoExcel;
                // 出力ファイル名 拡張子は不要

                // pathの取得
				string serverpath = HttpContext.Current.Server.MapPath("..");
				string templateFile = ExcelUtilities.getTemplateFile(templateName, serverpath, criteria.lang);

				/// テンプレートを読み込み、必要な情報をマッピングしてクライアントへ返却
				byte[] byteArray = File.ReadAllBytes(templateFile);
                string cd_shokuba = criteria.cd_shokuba;
                string cd_line = criteria.cd_line;

                //職場コードから職場ネーム取得
                string nm_shokuba = context.ma_shokuba.First(v => v.cd_shokuba.CompareTo(cd_shokuba) == 0).nm_shokuba;

				using (MemoryStream mem = new MemoryStream())
				{
					mem.Write(byteArray, 0, (int)byteArray.Length);
					using (SpreadsheetDocument spDoc = SpreadsheetDocument.Open(mem, true))
					{
						// 定義記述
						string NmSheet = "Sheet1";
						WorkbookPart wbPart = spDoc.WorkbookPart;
						Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);
                        // フォーマット作成とシートへのセット
                        Stylesheet sheet = wbPart.WorkbookStylesPart.Stylesheet; ;
                        sheet.NumberingFormats = new NumberingFormats();

                        // 書式設定の追加
                        UInt32 indexSpCom2 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma2, ActionConst.idSplitComma2);
                        UInt32 indexSpCom3 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitComma3, ActionConst.idSplitComma3);
                        //UInt32 indexSpCom6 = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                        //    sheet, ActionConst.fmtSplitComma6, ActionConst.idSplitComma6);
                        UInt32 indexSpNoCom = FoodProcsCommonUtility.ExcelCellFormatSplitComma(
                            sheet, ActionConst.fmtSplitNoComma, ActionConst.idSplitNoComma);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }
						// 明細行開始ポイント
                        TimeZoneInfo tzi = TimeZoneInfo.Local;
						int index = startGrid;				

                        // ヘッダー行をセット
                        // 検索条件/荷受日
                        string seizoStDay = criteria.dt_seizo_st.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        string seizoEdDay = criteria.dt_seizo_en.ToString(FoodProcsCommonUtility.formatDateSelect(lang));
                        ExcelUtilities.UpdateValue(wbPart, ws, "C2", seizoStDay + " ～ " + seizoEdDay, 0, true);
                        // 検索条件/職場
                        //ExcelUtilities.UpdateValue(wbPart, ws, "C3", criteria.nm_shokuba, 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, "C3", nm_shokuba, 0, true);
                        // 検索条件/ライン
                        ExcelUtilities.UpdateValue(wbPart, ws, "C4", criteria.nm_line, 0, true);
                  
                        // 検索条件/伝送状態【未作成】　　　
                        ExcelUtilities.UpdateValue(wbPart, ws, "C6", criteria.lbl_mi_sakusei.ToString(), 0, true);
                        // 検索条件/伝送状態【未伝送】　　　
                        ExcelUtilities.UpdateValue(wbPart, ws, "C7", criteria.lbl_mi_denso.ToString(), 0, true);
                        // 検索条件/伝送状態【伝送待】
                        ExcelUtilities.UpdateValue(wbPart, ws, "C8", criteria.lbl_denso_machi.ToString(), 0, true);
                        // 検索条件/伝送状態【伝送済】
                        ExcelUtilities.UpdateValue(wbPart, ws, "C9", criteria.lbl_denso_zumi.ToString(), 0, true);

                        // 検索条件/未登録　　　
                        //ExcelUtilities.UpdateValue(wbPart, ws, "C6", criteria.lbl_mi_toroku.ToString(), 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, "C11", criteria.lbl_mi_toroku.ToString(), 0, true);
                        // 検索条件/一部未登録
                        //ExcelUtilities.UpdateValue(wbPart, ws, "C7", criteria.lbl_ichibu_mi_toroku.ToString(), 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, "C12", criteria.lbl_ichibu_mi_toroku.ToString(), 0, true);
                        // 検索条件/登録済
                        //ExcelUtilities.UpdateValue(wbPart, ws, "C8", criteria.lbl_toroku_sumi.ToString(), 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, "C13", criteria.lbl_toroku_sumi.ToString(), 0, true);
                        // 出力日時
                        string outputDate = criteria.today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
                        //ExcelUtilities.UpdateValue(wbPart, ws, "C9", outputDate, 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, "C14", outputDate, 0, true);
                        // 出力者
                        //ExcelUtilities.UpdateValue(wbPart, ws, "C10", criteria.userName, 0, true);
                        ExcelUtilities.UpdateValue(wbPart, ws, "C15", criteria.userName, 0, true);

                        if (criteria.dt_seizo_en.Subtract(criteria.dt_seizo_st).TotalDays == 0)
                            //printType1(index, wbPart, ws, tzi, indexSpCom6, cd_line, lang, views);
                            printType1(index, wbPart, ws, tzi, indexSpCom2, indexSpCom3, indexSpNoCom, cd_line, lang, views);
                        else
                            //printType2(index, wbPart, ws, tzi, indexSpCom6, cd_line, lang, views);
                            printType2(index, wbPart, ws, tzi, indexSpCom2, indexSpCom3, indexSpNoCom, cd_line, lang, views);
						ws.Save();
					}

					///// レポートの取得
					string reportname = excelname + ".xlsx";
					//return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);
                    return FileDownloadUtility.CreateCookieAddResponse(mem.ToArray(), reportname, Resources.shikomiNippoCookie, Resources.CookieValue);
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

        /// <summary>製造日がないExcelを印刷します。</summary>
        //private void printType1(int index, WorkbookPart wbPart, Worksheet ws, TimeZoneInfo tzi, UInt32 indexSpCom6, string cd_line, String lang, IEnumerable<usp_ShikomiNippo_select_Result> views)
        public void printType1(int index, WorkbookPart wbPart, Worksheet ws, TimeZoneInfo tzi, UInt32 indexSpCom2, UInt32 indexSpCom3, UInt32 indexSpNoCom, string cd_line, String lang, IEnumerable<usp_ShikomiNippo_select_Result> views)
        {
            string nm_shokuba = "";
            string nm_line = "";

            // 明細行出力
            foreach (usp_ShikomiNippo_select_Result item in views)
            {
                if (index == startGrid)
                {
                    nm_shokuba = item.nm_shokuba;
                    if (!string.IsNullOrEmpty(cd_line) && cd_line != "null" && cd_line != "undefined")
                    {
                        nm_line = item.nm_line;
                    }
                }
                // 出力用の「確定」を設定
                string kakutei = "";
                if (item.flg_jisseki.ToString() == Resources.FlagTrue)
                {
                    kakutei = Resources.Kakutei;
                }
                // 「製品名」を取得（多言語対応）
                string nm_haigo = "";
                if (lang == Resources.LangJa)
                {
                    nm_haigo = item.nm_haigo_ja;
                }
                else if (lang == Resources.LangEn)
                {
                    nm_haigo = item.nm_haigo_en;
                }
                else if (lang == Resources.LangZh)
                {
                    nm_haigo = item.nm_haigo_zh;
                }
                else if (lang == Resources.LangVi)
                {
                    nm_haigo = item.nm_haigo_vi;
                }

                //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                //詳細/確定
                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, kakutei, 0, true);
                //詳細/コード
                ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.cd_shikakari_hin, 0, true);               
                //詳細/仕掛品名
                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, nm_haigo, 0, true);
                //詳細/ラインコード
                ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.cd_line, 0, true);
                //詳細/ライン名
                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_line, 0, true);
                //詳細/使用単位
                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_tani, 0, true);
                //詳細/倍率
                //ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.ritsu_jisseki.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.ritsu_jisseki.ToString(), indexSpCom2, false);
                //詳細/倍率(端数)
                //ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.ritsu_jisseki_hasu.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.ritsu_jisseki_hasu.ToString(), indexSpCom2, false);
                //詳細/Ｂ数
                //ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.su_batch_jisseki.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.su_batch_jisseki.ToString(), indexSpNoCom, false);
                //詳細/Ｂ数(端数)
                //ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.su_batch_jisseki_hasu.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.su_batch_jisseki_hasu.ToString(), indexSpNoCom, false);
                //詳細/残使用量
                //ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.wt_zaiko_jisseki.ToString(), indexSpCom6, false);
                //詳細/仕込量(予定)
                //ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.wt_shikomi_keikaku.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.wt_shikomi_keikaku.ToString(), indexSpCom3, false);
                //詳細/仕込量
                //ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.wt_shikomi_jisseki.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.wt_shikomi_jisseki.ToString(), indexSpCom3, false);
                //詳細/必要量
                //ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.wt_hitsuyo.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.wt_hitsuyo.ToString(), indexSpCom3, false);
                //詳細/当日残
                //ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.wt_shikomi_zan.ToString(), indexSpCom6, false);
                //詳細/ロット番号
                ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.no_lot_shikakari, 0, true);
                //詳細/伝送状況
                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, getDensoJotai(item.kbn_jotai_denso), 0, true);
                //詳細/登録状態
                //ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, getTorokuJotai(item.kbn_toroku_jotai), 0, true);
                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, getTorokuJotai(item.kbn_toroku_jotai), 0, true);

                // 行のポインタを一つカウントアップ
                index++;
            }
        }

        /// <summary>製造日があるExcelを印刷します。</summary>
        //private void printType2(int index, WorkbookPart wbPart, Worksheet ws, TimeZoneInfo tzi, UInt32 indexSpCom6, string cd_line, String lang, IEnumerable<usp_ShikomiNippo_select_Result> views)
        private void printType2(int index, WorkbookPart wbPart, Worksheet ws, TimeZoneInfo tzi, UInt32 indexSpCom2, UInt32 indexSpCom3, UInt32 indexSpNoCom, string cd_line, String lang, IEnumerable<usp_ShikomiNippo_select_Result> views)
        {
            string nm_shokuba = "";
            string nm_line = "";

            // 明細行出力
            foreach (usp_ShikomiNippo_select_Result item in views)
            {
                if (index == startGrid)
                {
                    nm_shokuba = item.nm_shokuba;
                    if (!string.IsNullOrEmpty(cd_line) && cd_line != "null" && cd_line != "undefined")
                    {
                        nm_line = item.nm_line;
                    }
                }
                // 出力用の「確定」を設定
                string kakutei = "";
                if (item.flg_jisseki.ToString() == Resources.FlagTrue)
                {
                    kakutei = Resources.Kakutei;
                }
                // 「製品名」を取得（多言語対応）
                string nm_haigo = "";
                if (lang == Resources.LangJa)
                {
                    nm_haigo = item.nm_haigo_ja;
                }
                else if (lang == Resources.LangEn)
                {
                    nm_haigo = item.nm_haigo_en;
                }
                else if (lang == Resources.LangZh)
                {
                    nm_haigo = item.nm_haigo_zh;
                }
                else if (lang == Resources.LangVi)
                {
                    nm_haigo = item.nm_haigo_vi;
                }

                //最後の項目(isString)は文字列でTrue, 数値でfalse を渡します
                //詳細/確定
                ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, kakutei, 0, true);                
                //詳細/製造日
                if (item.dt_seizo == null)
                {
                    ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, string.Empty, 0, true);
                }
                else
                {
                    if (lang == Resources.LangJa || lang == Resources.LangZh || CultureInfo.CurrentUICulture.Name == "en-US")
                    {
                        ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, TimeZoneInfo.ConvertTimeFromUtc(item.dt_seizo, tzi).ToString(Resources.DateSlash), 0, true);
                    }
                    else
                    {
                        ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, TimeZoneInfo.ConvertTimeFromUtc(item.dt_seizo, tzi).ToString(Resources.DateSlashEn), 0, true);
                    }
                    //ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, TimeZoneInfo.ConvertTimeFromUtc(item.dt_kigen.Value, tzi).ToShortDateString(), 0, true);
                }
                //詳細/コード
                ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.cd_shikakari_hin, 0, true);
                //詳細/仕掛品名
                ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, nm_haigo, 0, true);
                //詳細/ラインコード
                ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.cd_line, 0, true);
                //詳細/ライン名
                ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_line, 0, true);
                //詳細/使用単位
                ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_tani, 0, true);
                //詳細/倍率
                //ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.ritsu_jisseki.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.ritsu_jisseki.ToString(), indexSpCom2, false);
                //詳細/倍率(端数)
                //ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.ritsu_jisseki_hasu.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.ritsu_jisseki_hasu.ToString(), indexSpCom2, false);
                //詳細/Ｂ数
                //ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.su_batch_jisseki.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.su_batch_jisseki.ToString(), indexSpNoCom, false);
                //詳細/Ｂ数(端数)
                //ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.su_batch_jisseki_hasu.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.su_batch_jisseki_hasu.ToString(), indexSpNoCom, false);
                //詳細/残使用量
                //ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.wt_zaiko_jisseki.ToString(), indexSpCom6, false);
                //詳細/仕込量(予定)
                //ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.wt_shikomi_keikaku.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.wt_shikomi_keikaku.ToString(), indexSpCom3, false);
                //詳細/仕込量
                //ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.wt_shikomi_jisseki.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.wt_shikomi_jisseki.ToString(), indexSpCom3, false);
                //詳細/必要量
                //ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.wt_hitsuyo.ToString(), indexSpCom6, false);
                ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.wt_hitsuyo.ToString(), indexSpCom3, false);
                //詳細/当日残
                //ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, item.wt_shikomi_zan.ToString(), indexSpCom6, false);
                //詳細/ロット番号
                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, item.no_lot_shikakari, 0, true);
                //詳細/伝送状況
                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, getDensoJotai(item.kbn_jotai_denso), 0, true);
                //詳細/登録状態
                //ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, getTorokuJotai(item.kbn_toroku_jotai), 0, true);
                ExcelUtilities.UpdateValue(wbPart, ws, "Q" + index, getTorokuJotai(item.kbn_toroku_jotai), 0, true);

                // 行のポインタを一つカウントアップ
                index++;
            }
        }

        /// <summary>
        /// 確定列の値を取得する
        /// </summary>
        /// <param name="flg_jisseki"></param>
        /// <returns></returns>
        private String getKakuteiName(short flg_jisseki) {
            if (short.Parse(Resources.FlagTrue) == flg_jisseki) {
                return Resources.FlagTrue;
            }
            return Resources.Empty;
        }

        /// <summary>
        /// 伝送状況を取得する
        /// </summary>
        /// <param name="flg_denso">伝送区分</param>
        /// <returns>伝送状況</returns>
        private String getDensoJotai(short? flg_denso)
        {
            if (flg_denso.HasValue)
            {
                switch (flg_denso)
                {
                    case 0:
                        return Resources.DensoKbnMiSakusei;
                    case 1:
                        return Resources.DensoKbnMiDenso;
                    case 2:
                        return Resources.DensoKbnDensoMachi;
                    case 4:
                        return Resources.DensoKbnDensoZumi;
                    default:
                        return Resources.Empty;
                }
            }

            //伝送区分がNULLの場合、「未作成」でセットする
            return Resources.DensoKbnMiSakusei;
        }

        /// <summary>
        /// 登録状態を取得する
        /// </summary>
        /// <param name="flg_toroku"></param>
        /// <returns></returns>
        private String getTorokuJotai(short? flg_toroku)
        {
            if (flg_toroku.HasValue)
            {
                switch (flg_toroku)
                {
                    case 0:
                        return Resources.TorokuKbnMiToroku;
                    case 1:
                        return Resources.TorokuKbnIchibuMiToroku;
                    case 2:
                        return Resources.TorokuKbnTorokuSumi;
                }
            }

            return Resources.Empty;
        }
	}
}