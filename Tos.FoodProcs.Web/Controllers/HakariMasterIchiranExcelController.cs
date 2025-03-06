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
    /// <画面名>ExcelFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class HakariMasterIchiranExcelController : ApiController
    {
        
        // HTTP:GET
        public HttpResponseMessage Get(String nm_hakari, String flg_mishiyo_kensaku, String lang, String userName)
        {
            try
            {
                // TODO:ダウンロードの準備
                // Entity取得
                FoodProcsEntities context = new FoodProcsEntities();

                // ファイル名の指定
                string templateName = "hakariMasterIchiran"; // return形式 "_lang.xlsx" 
                string excelname = Resources.HakariMasterIchiranExcel; // 出力ファイル名 拡張子は不要
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

                        // カンマ区切り、小数点なし
                        NumberingFormat splitNoComma = new NumberingFormat();
                        splitNoComma.NumberFormatId = UInt32Value.FromUInt32(3);
                        splitNoComma.FormatCode = StringValue.FromString("#,##0");
                        sheet.NumberingFormats.AppendChild<NumberingFormat>(splitNoComma);
                        // 小数点以下6桁
                        NumberingFormat splitComma6 = new NumberingFormat();
                        splitComma6.NumberFormatId = UInt32Value.FromUInt32(5);
                        splitComma6.FormatCode = StringValue.FromString("0.000000");
                        sheet.NumberingFormats.AppendChild<NumberingFormat>(splitComma6);
                        // ======= 数値フォーマット作成：ここまで =======

                        // 書式設定の追加
                        UInt32 indexSpNoCom = (UInt32)SetCellFormats(sheet, splitNoComma);
                        UInt32 indexSpCom6 = (UInt32)SetCellFormats(sheet, splitComma6);
                        
                        Worksheet ws = ExcelUtilities.FindWorkSheet(wbPart, NmSheet);

                        // 追加スタイルのフォントを設定します。
                        foreach (Font f in sheet.Fonts)
                        {
                            f.FontName = new FontName() { Val = Resources.DefaultFontName };
                        }

                        // TODO:Entityよりデータを取得しフォーマットに値をセットします
                        IQueryable<vw_ma_hakari_01> query;
                        String katashiki = nm_hakari;
                        if (String.IsNullOrEmpty(nm_hakari))
                        {
                            katashiki = "";
                        }
                        if (flg_mishiyo_kensaku == "0")
                        {
                            query = from d in context.vw_ma_hakari_01
                                    orderby d.cd_hakari
                                    where d.flg_mishiyo == 0 && d.mf_flg_mishiyo == 0 && d.mt_flg_mishiyo == 0
                                        && (katashiki.Length == 0 || d.nm_hakari.Contains(katashiki) || d.cd_hakari.Contains(katashiki))
                                    select d;
                        }
                        else
                        {
                            query = from d in context.vw_ma_hakari_01
                                    orderby d.cd_hakari
                                    where d.mf_flg_mishiyo == 0 && d.mt_flg_mishiyo == 0
                                        && (katashiki.Length == 0 || d.nm_hakari.Contains(katashiki) || d.cd_hakari.Contains(katashiki))
                                    select d;
                        }

                        //// ヘッダー行をセット
                        // 型式
                        ExcelUtilities.UpdateValue(wbPart, ws, "B2", katashiki, 0, true);
                        // 未使用表示…フラグ0：なし、フラグ1：あり、それ以外(ラジオボタンなのでありえないが)：未選択
                        if (Resources.FlagFalse.Equals(flg_mishiyo_kensaku))
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B3", Resources.Nashi, 0, true);
                        }
                        else if (Resources.FlagTrue.Equals(flg_mishiyo_kensaku))
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B3", Resources.Ari, 0, true);
                        }
                        else
                        {
                            ExcelUtilities.UpdateValue(wbPart, ws, "B3", Resources.NoSelectConditionExcel, 0, true);
                        }
                        //出力日時
                        ExcelUtilities.UpdateValue(wbPart, ws, "B5", DateTime.Now.ToString(ActionConst.DateFormat), 0, true);
                        //出力者
                        ExcelUtilities.UpdateValue(wbPart, ws, "B6", userName, 0, true);

                        // 明細行開始ポイント
                        int index = 9;
                
                        // シートデータへ値をマッピング
                        foreach (var item in query.ToList())
                        {
                            // 最後の項目(isString)は文字列の場合true, 数値の場合false を渡します
                            ExcelUtilities.UpdateValue(wbPart, ws, "A" + index, item.cd_hakari, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "B" + index, item.nm_hakari, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "C" + index, item.nm_tani, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "D" + index, item.nm_kbn_baurate, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "E" + index, item.nm_kbn_parity, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "F" + index, item.nm_kbn_databit, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "G" + index, item.nm_kbn_stopbit, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "H" + index, item.nm_kbn_handshake, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "I" + index, item.nm_antei, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "J" + index, item.nm_fuantei, 0, true);
                            ExcelUtilities.UpdateValue(wbPart, ws, "K" + index, item.no_ichi_juryo.ToString(), indexSpNoCom, false);
                            ExcelUtilities.UpdateValue(wbPart, ws, "L" + index, item.su_keta.ToString(), indexSpNoCom, false);
                            ExcelUtilities.UpdateValue(wbPart, ws, "M" + index, item.su_ichi_fugo.ToString(), indexSpNoCom, false);
                            ExcelUtilities.UpdateValue(wbPart, ws, "N" + index, item.wt_fundo.ToString(), indexSpCom6, false);
                            if (item.flg_fugo == short.Parse(Resources.FugoFlagAri))
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, Resources.FugoShutsuryokuAri, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "O" + index, "", 0, true);
                            }
                            if (item.flg_mishiyo == 1)
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, Resources.Mishiyo, 0, true);
                            }
                            else
                            {
                                ExcelUtilities.UpdateValue(wbPart, ws, "P" + index, "", 0, true);
                            }
                            // 計算式が入っているセルは再セット
                            ExcelUtilities.RemoveCellValue(wbPart, ws, "Q" + index);
                            
                            // 行のポインタを一つカウントアップ
                            index++;
                        }
                        ws.Save();
                        // TODO:ここまで
                    }
                    
                    //// レポートの取得
                    string reportname = excelname + ".xlsx";
                    // レスポンスを生成して返します
                    return FileDownloadUtility.CreateExcelFileResponse(mem.ToArray(), reportname);                
                }
                
            }
            catch (HttpResponseException ex)
            {
                throw ex;
            }
            catch (Exception)
            {
                throw new HttpResponseException(HttpStatusCode.InternalServerError);
            }
        }

        /// <summary>書式設定を追加します。</summary>
        /// <param name="sheet">スタイルシート</param>
        /// <param name="fmtVal">設定したい書式</param>
        private int SetCellFormats(Stylesheet sheet, NumberingFormat fmtVal)
        {
            CellFormat fmt = new CellFormat();
            fmt.NumberFormatId = fmtVal.NumberFormatId;
            int fmtIndex = sheet.CellFormats.Count();
            sheet.CellFormats.InsertAt<CellFormat>(fmt, fmtIndex);
            return fmtIndex;
        }
    }
}