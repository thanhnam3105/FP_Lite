using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Properties;
using Newtonsoft.Json.Linq;
using System.Data.Objects;
using System.Globalization;

using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// FoodProcs Lite：共通ユーティリティ
    /// </summary>
    /// <Author>tsujita.s</Author>
    /// Create Date：2014.08.07
    public static class FoodProcsCommonUtility
    {
        /// <summary>採番処理</summary>
        /// <param name="saibanKbn">採番区分</param>
        /// <param name="prefix">プリフィックス</param>
        /// <param name="context">エンティティ</param>
        /// <returns>採番された番号</returns>
        public static string executionSaiban(string saibanKbn, string prefix, FoodProcsEntities context)
        {
            ObjectParameter no_saiban_param = new ObjectParameter(ActionConst.saibanNoContent, 0);

            // 採番処理の実行
            string result =
                context.usp_cm_Saiban(saibanKbn, prefix, no_saiban_param).FirstOrDefault<String>();
            
            return result;
        }

        /// <summary>日付フォーマット指定処理(年月日)</summary>
        /// <param name="lang">言語</param>
        /// <returns>指定された言語フォーマット</returns>
        public static string formatDateSelect(string lang)
        {
            if (lang == Resources.LangJa || lang == Resources.LangZh || CultureInfo.CurrentUICulture.Name == "en-US")
            {
                return ActionConst.DateFormat;
            }
            else {
                return ActionConst.DateFormatEn;
            }
        }
        /// <summary>日付フォーマット指定処理(年月日時刻)</summary>
        /// <param name="lang">言語</param>
        /// <returns>指定された言語フォーマット</returns>
        public static string formatDateTimeSelect(string lang)
        {
            if (lang == Resources.LangJa || lang == Resources.LangZh || CultureInfo.CurrentUICulture.Name == "en-US")
            {
                return ActionConst.DateTime;
            }
            else
            {
                return ActionConst.DateTimeEn;
            }
        }

        /// <summary>日付フォーマット指定処理(年月日時刻)</summary>
        /// <param name="lang">言語</param>
        /// <returns>指定された言語フォーマット</returns>
        public static string formatDateTimeShortSelect(string lang)
        {
            if (lang == Resources.LangJa || lang == Resources.LangZh || CultureInfo.CurrentUICulture.Name == "en-US")
            {
                return ActionConst.DateTimeShort;
            }
            else
            {
                return ActionConst.DateTimeEnShort;
            }
        }

        /// <summary>EXCELフォーマット：カンマ区切り、小数点以下n桁</summary>
        /// <param name="sheet">スタイルシート</param>
        /// <param name="strFormat">フォーマット文字列</param>
        /// <param name="idFormat">フォーマットID</param>
        /// <returns>書式番号</returns>
        public static UInt32 ExcelCellFormatSplitComma(Stylesheet sheet, String strFormat, UInt32Value idFormat)
        {
            NumberingFormat fmtVal = new NumberingFormat();
            fmtVal.NumberFormatId = idFormat;
            fmtVal.FormatCode = strFormat;
            sheet.NumberingFormats.AppendChild<NumberingFormat>(fmtVal);

            CellFormat fmt = new CellFormat();
            fmt.NumberFormatId = fmtVal.NumberFormatId;
            fmt.Alignment = fmtExcelCellAlign();
            int fmtIndex = sheet.CellFormats.Count();
            sheet.CellFormats.InsertAt<CellFormat>(fmt, fmtIndex);
            
            return (UInt32)fmtIndex;
        }

        /// <summary>EXCELフォーマット：文字列用</summary>
        /// <param name="sheet">スタイルシート</param>
        /// <returns>書式番号</returns>
        public static UInt32 ExcelCellFormatAlign(Stylesheet sheet)
        {
            CellFormat fmt = new CellFormat();
            fmt.Alignment = fmtExcelCellAlign();
            int fmtIndex = sheet.CellFormats.Count();
            sheet.CellFormats.InsertAt<CellFormat>(fmt, fmtIndex);
            
            return (UInt32)fmtIndex;
        }

        /// <summary>
        /// EXCELフォーマット：下詰め、折り返して全体を表示する
        /// </summary>
        /// <returns>Alignment情報</returns>
        public static Alignment fmtExcelCellAlign()
        {
            Alignment alignment = new Alignment();
            alignment.Vertical = VerticalAlignmentValues.Bottom;
            //alignment.WrapText = true;
            return alignment;
        }

        /// <summary>nullの場合、空文字に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        public static String changedNullToEmpty(String value)
        {
            if (String.IsNullOrEmpty(value) || value == "null")
            {
                value = "";
            }
            return value;
        }

        /// <summary>nullまたは空文字の場合、半角スペースに変換します。
        /// また、指定バイト数を超える場合には改行コードを入れます。
        /// ＃iReport側で、数字や英字が並んでいる場合は予期せぬ改行が入ってしまう為</summary>
        /// <param name="value">判定したい値</param>
        /// <param name="checkByteVal">指定バイト数</param>
        /// <returns>判定結果</returns>
        public static String ChangedNullToEnSpaceAndCheckByte(object value, int checkByteVal)
        {
            // nullまたは空文字の場合、半角スペースに変換する
            if (value == null || value.ToString() == "")
            {
                return " ";
            }

            // 指定バイト数を超える場合には改行コードを入れる
            string target = value.ToString();
            string value1 = "";
            int checkByte = checkByteVal;
            int byteCount = 0;
            for (int i = 0; i < target.Length; i++)
            {
                // 全半角混合なので、一文字ずつチェックしていく
                char checkChar = target[i];
                int charByte = System.Text.Encoding.GetEncoding("Shift_JIS").GetByteCount(checkChar.ToString());
                byteCount += charByte;

                if (byteCount > checkByte)
                {
                    string value2 = target.Substring(i);    // 後半部分

                    // 改行コードを入れる
                    target = value1 + System.Environment.NewLine + value2;
                    break;
                }
                else
                {
                    value1 += checkChar.ToString();
                }
            }
            
            return target;
        }

        /// <summary>
        /// 換算用の数値を取得します。
        /// </summary>
        /// <param name="digit">指定の桁数</param>
        /// <returns>換算値</returns>
        public static int getKanzan(double digit)
        {
            int kanzanVal = (Int32)Math.Pow(10, digit);
            return kanzanVal;
        }

        /// <summary>
        /// After the decimal point : Truncate
        /// 切り捨て処理。値の小数点以下を指定の桁数にする。
        /// 指定の桁数に0が指定された場合は何もしません。
        /// </summary>
        /// <param name="value">値</param>
        /// <param name="digit">指定の桁数</param>
        /// <returns>切り捨て後の値</returns>
        public static decimal decimalTruncate(decimal value, double digit)
        {
            decimal val = value;
            if (digit > 0)
            {
                var kanzan = getKanzan(digit);
                val = Math.Truncate(value * kanzan) / kanzan;
            }
            return val;
        }

        /// <summary>
        /// After the decimal point : Ceiling
        /// 切り上げ処理。値の小数点以下を指定の桁数にする。
        /// 指定の桁数に0が指定された場合は何もしません。
        /// </summary>
        /// <param name="value">値</param>
        /// <param name="digit">指定の桁数</param>
        /// <returns>切り捨て後の値</returns>
        public static decimal decimalCeiling(decimal value, double digit)
        {
            decimal val = value;
            if (digit > 0)
            {
                var kanzan = getKanzan(digit);
                val = Math.Ceiling(value * kanzan) / kanzan;
            }
            return val;
        }

        /// <summary>
        /// 四捨五入。
        /// 指定の桁数に0が指定された場合は何もしません。
        /// </summary>
        /// <param name="value">値</param>
        /// <param name="digit">指定の桁数</param>
        /// <returns>四捨五入後の値</returns>
        public static decimal mathRound(decimal value, double digit)
        {
            decimal val = value;
            if (digit > 0)
            {
                var kanzan = getKanzan(digit);
                val = Math.Round((value * kanzan), MidpointRounding.AwayFromZero) / kanzan;
            }
            return val;
        }
        /// <summary>
        /// After the decimal point : Round
        /// 四捨五入。値の小数点以下を指定の桁にする。
        /// 画面の四捨五入に合わせた処理を行う。
        /// </summary>
        /// <param name="digit">指定の桁数</param>
        /// <returns>四捨五入後の値</returns>
        public static decimal decimalRound(decimal value, double digit)
        {
            decimal val = value;
            if (val < 0)
            {
                // 値がマイナスの場合
                // マイナスの四捨五入は最も近い整数＝マイナスの方に切り上げてしまうため、正の数で処理する
                val = -(val);
                val = mathRound(val, digit);

                // 負の数に戻す
                val = -(val);
            }
            else
            {
                val = mathRound(val, digit);
            }
            return val;
        }

        /// <summary>
        /// 計画画面の実績チェック。製品トランまたは仕掛品サマリの実績フラグが立っているものが存在すればエラーをthrowする。
        /// 製品ロット番号に値があればそれを基に検索。
        /// 製品ロット番号に値がなく、仕掛品ロット番号に値があればそれを基に検索。
        /// どちらにも値がなければ実績フラグ0のレコードが返却され、エラーなし(チェックOK)とする。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="seihinLot">製品ロット番号</param>
        /// <param name="shikakariLot">仕掛品ロット番号</param>
        /// <param name="dataKey">データ用キー番号</param>
        /// <param name="seizoDate">製造日</param>
        /// <param name="words">文言</param>
        //public static void checkKeikakuJissekiFlag(FoodProcsEntities context,
            //string seihinLot, string shikakariLot, string dataKey, DateTime seizoDate)
        public static void checkKeikakuJissekiFlag(FoodProcsEntities context,
            string seihinLot, string shikakariLot, string dataKey, DateTime seizoDate, string words)
        {
            IEnumerable<usp_KeikakuCheckJissekiFlag_select_Result> results;
            results = context.usp_KeikakuCheckJissekiFlag_select(
                seihinLot, shikakariLot, seizoDate, ActionConst.FlagFalse, dataKey);
            foreach (var data in results)
            {
                string errLot = ""; // エラーロット番号
                if (ActionConst.FlagTrue.Equals(data.flg_jisseki_seizo))
                {
                    // 製品トランの実績フラグがtrueの場合
                    errLot = data.no_lot_seihin;
                }
                else if (ActionConst.FlagTrue.Equals(data.flg_jisseki_shikomi))
                {
                    // 仕掛品サマリの実績フラグがtrueの場合
                    errLot = data.no_lot_shikakari;
                }

                // エラーロット番号に値がある場合はエラーとする(throw)
                if (!String.IsNullOrEmpty(errLot))
                {
                    string errorMsg = String.Format(
                        Resources.MS0743, words, errLot);
                    InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                    ioe.Data.Add("key", "MS0743");
                    throw ioe;
                }
            }
        }

        /// <summary>換算区分名を返します。単位区分によって表示を変更する。0：Kg・L　1：LB・GAL</summary>
        /// <param name="context">エンティティ</param>
        /// <param name="kbn">換算区分</param>
        /// <returns>換算区分名</returns>
        public static String GetKanzanKubunName(FoodProcsEntities context, string kbn)
        {
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

            string ret = kanzan_kg;  // デフォルト：Kg
            if (ActionConst.LKanzanKbn.Equals(kbn))
            {
                // 換算区分が「11：L」の場合
                ret = kanzan_Li;
            }

            return ret;
        }

        /// <summary>
        /// 小数桁数を元にフォーマットを作成する
        /// </summary>
        public static string CreateSyosuFormat(int shosuKeta)
        {
            // フォーマット
            string shosubuFormat = string.Empty;

            // フォーマット作成する
            for (int i = 0; i < shosuKeta; i++)
            {
                shosubuFormat = shosubuFormat + "0";
            }

            shosubuFormat = "{0:#,0." + shosubuFormat + "}";

            return shosubuFormat;
        }
    }
}
