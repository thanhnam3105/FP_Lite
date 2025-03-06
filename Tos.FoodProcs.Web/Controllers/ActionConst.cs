using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DocumentFormat.OpenXml;

namespace Tos.FoodProcs.Web.Controllers
{
    public class ActionConst
    {
        //////////【フラグ】
        /// <summary>フラグ　false：0</summary>
        public static readonly short FlagFalse = 0;

        /// <summary>フラグ　true：1</summary>
        public static readonly short FlagTrue = 1;

        /// <summary>予実フラグ：予定：0</summary>
        public static readonly short YoteiYojitsuFlag = 0;

        /// <summary>予実フラグ：実績：1</summary>
        public static readonly short JissekiYojitsuFlag = 1;

        /// <summary>ラベル発行フラグ：ラベル出力なし：0 </summary>
        public static readonly short nashiLabelPrintFlg = 0;


        //////////【採番区分】
        /// <summary>採番ストアドが返却する項目名：no_saiban</summary>
        public static readonly String saibanNoContent = "no_saiban";
        
        /// <summary>採番区分：製品ロット：1</summary>
        public static readonly String SeihinLotSaibanKbn = "1";
        /// <summary>採番区分プリフィクス：製品ロット：P</summary>
        public static readonly String SeihinLotPrefixSaibanKbn = "P";

        /// <summary>採番区分：仕掛品ロット：2</summary>
        public static readonly String ShikakariLotSaibanKbn = "2";
        /// <summary>採番区分プリフィクス：仕掛品ロット：S</summary>
        public static readonly String ShikakariLotPrefixSaibanKbn = "S";

        /// <summary>採番区分：小分ロット：3</summary>
        public static readonly String KowakeLotSaibanKbn = "3";
        /// <summary>採番区分プリフィクス：小分ロット：K</summary>
        public static readonly String KowakeLotPrefixSaibanKbn = "K";

        /// <summary>採番区分：実績ロット：4</summary>
        public static readonly String JissekiLotSaibanKbn = "4";
        /// <summary>採番区分プリフィクス：実績ロット：J</summary>
        public static readonly String JissekiLotPrefixSaibanKbn = "J";

        /// <summary>採番区分：納入番号：8</summary>
        public static readonly String NonyuSaibanKbn = "8";
        /// <summary>採番区分プリフィクス：納入番号：N</summary>
        public static readonly String NonyuPrefixSaibanKbn = "N";

        /// <summary>採番区分：仕掛品計画：10</summary>
        public static readonly String ShikakarihinKeikakuSaibanKbn = "10";
        /// <summary>採番区分プリフィクス：仕掛品計画：Q</summary>
        public static readonly String ShikakarihinKeikakuPrefixSaibanKbn = "Q";

        /// <summary>採番区分：調整：11</summary>
        public static readonly String ChoseiSaibanKbn = "11";
        /// <summary>採番区分プリフィクス：調整：A</summary>
        public static readonly String ChoseiPrefixSaibanKbn = "A";

        /// <summary>採番区分：発注番号：12</summary>
        public static readonly String HachuSaibanKbn = "12";
        /// <summary>採番区分プリフィクス：発注番号：H</summary>
        public static readonly String HachuPrefixSaibanKbn = "H";
        
        /// <summary>採番区分：コメント：13</summary>
        public static readonly String CommentSaibanKbn = "13";
        /// <summary>採番区分プリフィクス：コメント：C</summary>
        public static readonly String CommentPrefixSaibanKbn = "C";
        
        /// <summary>採番区分：秤量範囲：15</summary>
        public static readonly String HakariSaibanKbn = "15";
        /// <summary>採番区分プリフィクス：秤量範囲：B</summary>
        public static readonly String HakariPrefixSaibanKbn = "B";
        
        /// <summary>採番区分：使用予実：16</summary>
        public static readonly String ShiyoYojitsuSeqNoSaibanKbn = "16";
        /// <summary>採番区分プリフィクス：使用予実：Y</summary>
        public static readonly String ShiyoYojitsuSeqNoPrefixSaibanKbn = "Y";
        
        /// <summary>採番区分：原価用使用：17</summary>
        public static readonly String GenkaShiyoSeqNoSaibanKbn = "17";
        /// <summary>採番区分プリフィクス：原価用使用：D</summary>
        public static readonly String GenkaShiyoSeqNoPrefixSaibanKbn = "D";

        /// <summary>採番区分：使用予実按分：18</summary>
        public static readonly String ShiyoYojitsuAnbunSeqNoSaibanKbn = "18";
        /// <summary>採番区分プリフィクス：使用予実按分：W</summary>
        public static readonly String ShiyoYojitsuAnbunSeqNoPrefixSaibanKbn = "W";

        /// <summary>採番区分：按分調整：19</summary>
        public static readonly String AnbunChoseiSeqNoSaibanKbn = "19";
        /// <summary>採番区分プリフィクス：按分調整：U</summary>
        public static readonly String AnbunChoseiSeqNoPrefixSaibanKbn = "U";

        /// <summary>採番区分：原料ロット：22</summary>
        public static readonly String GenryoLotChoseiSeqNoSaibanKbn = "22";
        /// <summary>採番区分プリフィクス：：T</summary>
        public static readonly String GenryoLotChoseiSeqNoPrefixSaibanKbn = "T";

        //////////【区分コード】
        /// <summary>マスタ区分：品名マスタ：1</summary>
        public static readonly short HinmeiMasterKbn = 1;
        
        /// <summary>マスタ区分：配合マスタ：2</summary>
        public static readonly short HaigoMasterKbn = 2;
        
        /// <summary>品区分：製品：1</summary>
        public static readonly short SeihinHinKbn = 1;
        
        /// <summary>品区分：原料：2</summary>
        public static readonly short GenryoHinKbn = 2;
        
        /// <summary>品区分：資材：3</summary>
        public static readonly short ShizaiHinKbn = 3;
        
        /// <summary>品区分：仕掛：5</summary>
        public static readonly short ShikakariHinKbn = 5;

        /// <summary>品区分：前処理原料：6</summary>
        public static readonly short MaeshoriGenryoHinKbn = 6;

        /// <summary>品区分：自家原料：7</summary>
        public static readonly short JikaGenryoHinKbn = 7;

        /// <summary>品区分：作業指示：8</summary>
        public static readonly short SagyoShijiHinKbn = 8;

        /// <summary>品区分：その他：9</summary>
        public static readonly short SonotaHinKbn = 9;

        /// <summary>敬称区分：様：1</summary>
        public static readonly short SamaKeishoKbn = 1;
        
        /// <summary>敬称区分：御中：2</summary>
        public static readonly short OnchuKeishoKbn = 2;
        
        /// <summary>敬称区分：なし：3</summary>
        public static readonly short NashiKeishoKbn = 3;
        
        /// <summary>納入書形式区分：納入数量：1</summary>
        public static readonly short NonyuSuryoNonyushoKeishikiKbn = 1;
        
        /// <summary>納入書形式区分：使用数量：2</summary>
        public static readonly short ShiyoSuryoNonyushoKeishikiKbn = 2;

        /// <summary>仕上がり区分：自動換算：0</summary>
        public static readonly short autoKanzanKbn = 0;

        /// <summary>仕上がり区分：手入力：1</summary>
        public static readonly short manualKanzanKbn = 1;

        /// <summary>換算区分：Kg：4</summary>
        public static readonly String KgKanzanKbn = "4";

        /// <summary>換算区分：L：11</summary>
        public static readonly String LKanzanKbn = "11";

        /// <summary>状態区分：固体：1</summary>
        public static readonly short KotaiJotaiKbn = 1;

        /// <summary>状態区分：液体：2</summary>
        public static readonly short EkitaiJotaiKbn = 2;

        /// <summary>状態区分：仕掛品：3</summary>
        public static readonly short ShikakarihinJotaiKbn = 3;

        /// <summary>状態区分：その他：9</summary>
        public static readonly short SonotaJotaiKbn = 9;

        /// <summary>取引先区分：仕入先：1</summary>
        public static readonly short ShiiresakiTorihikisakiKbn = 1;

        /// <summary>取引先区分：売上元：2</summary>
        public static readonly short UriagemotoTorihikisakiKbn = 2;

        /// <summary>取引先区分：製造元：3</summary>
        public static readonly short SeizomotoTorihikisakiKbn = 3;

        /// <summary>単価区分：棚卸単価：1</summary>
        public static readonly short TanaoroshiTankaKbn = 1;

        /// <summary>単価区分：納入単価：2</summary>
        public static readonly short NonyuTankaKbn = 2;

        /// <summary>単価区分：労務費：3</summary>
        public static readonly short RomuhiTankaKbn = 3;

        /// <summary>単価区分：経費：4</summary>
        public static readonly short KeihiTankaKbn = 4;

        /// <summary>単価区分：CS単価：5</summary>
        public static readonly short CsTankaTankaKbn = 5;

        /// <summary>受払区分：納入予定：0</summary>
        public static readonly short ukeharaiNounyuYoteiKbn = 0;

        /// <summary>受払区分：納入実績：1</summary>
        public static readonly short ukeharaiNounyuJissekiKbn = 1;

        /// <summary>受払区分：使用予定：2</summary>
        public static readonly short ukeharaiShiyoYoteiKbn = 2;

        /// <summary>受払区分：使用実績：3</summary>
        public static readonly short ukeharaiShiyoJissekiKbn = 3;

        /// <summary>受払区分：調整数：4</summary>
        public static readonly short ukeharaiChoseiKbn = 4;

        /// <summary>受払区分：製造予定：5</summary>
        public static readonly short ukeharaiSeizoYoteiKbn = 5;

        /// <summary>受払区分：製造実績：6</summary>
        public static readonly short ukeharaiSeizoJissekiKbn = 6;

        /// <summary>在庫区分：良品：1</summary>
        public static readonly short kbn_zaiko_ryohin = 1;

        /// <summary>在庫区分：保留品：2</summary>
        public static readonly short kbn_zaiko_horyu = 2;

        /// <summary>入庫区分：有償：1</summary>
        public static readonly short kbn_nyuko_yusho = 1;

        /// <summary>入庫区分：無償：7</summary>
        public static readonly short kbn_nyuko_musho = 7;

        /// <summary>入出庫区分：仕入：1</summary>
        public static readonly short kbn_nyushuko_shiire = 1;

        /// <summary>入出庫区分：外移入：2</summary>
        public static readonly short kbn_nyushuko_inyu = 2;

        /// <summary>入出庫区分：出庫：3</summary>
        public static readonly short kbn_nyushuko_shuko = 3;

        /// <summary>入出庫区分：加工残：4</summary>
        public static readonly short kbn_nyushuko_kakozan = 4;

        /// <summary>入出庫区分：区分変更　保留：5</summary>
        public static readonly short kbn_nyushuko_henko_horyu = 5;

        /// <summary>入出庫区分：区分変更　良品：6</summary>
        public static readonly short kbn_nyushuko_henko_ryohin = 6;

        /// <summary>入出庫区分：入：7</summary>
        public static readonly short kbn_nyushuko_ire = 7;

        /// <summary>伝送状態区分：未作成：0</summary>
        public static readonly short densoJotaiKbnMisakusei = 0;

        /// <summary>伝送状態区分：未伝送：0</summary>
        public static readonly short densoJotaiKbnMidenso = 1;

        /// <summary>伝送状態区分：伝送待：0</summary>
        public static readonly short densoJotaiKbnDensomachi = 2;

        /// <summary>伝送状態区分：伝送中：0</summary>
        public static readonly short densoJotaiKbnDensochu = 3;

        /// <summary>伝送状態区分：伝送済：0</summary>
        public static readonly short densoJotaiKbnDensosumi = 4;

        /// <summary>使用実績按分区分：製造：1</summary>
        public static readonly string shiyoJissekiAnbunKubunSeizo = "1";

        /// <summary>使用実績按分区分：調整：2</summary>
        public static readonly string shiyoJissekiAnbunKubunChosei = "2";

        /// <summary>使用実績按分区分：残：3</summary>
        public static readonly string shiyoJissekiAnbunKubunZan = "3";

        /// <summary>小分計算区分 : 均等小分 : 1</summary>
        public static readonly short? kbnKowakeFutaiKinto = 1;

        /// <summary>小分計算区分 : 最大小分 : 2</summary>
        public static readonly short? kbnKowakeFutaiSaidai = 2;

        //////////【機能選択コントロール：機能区分】
        /// <summary>機能区分：単位区分：2</summary>
        public static readonly short kbn_kino_kbn_tani = 2;
        /// <summary>単位区分：LB・GAL : 1</summary>
        public static readonly string kbn_tani_LB_GAL = "1";
        /// <summary>単位区分：KG・L : 0</summary>
        public static readonly string kbn_tani_Kg_L = "0";

        /// <summary>機能区分：固定日区分：6</summary>
        public static readonly short kbn_dt_kotei = 4;

        /// <summary>機能区分：ロケーション区分：5</summary>
        public static readonly short kbn_location = 5;

        /// <summary>機能区分：納入単位（端数）区分：6</summary>
        public static readonly short kbn_tani_nonyu_hasu = 6;
        /// <summary>納入単位（端数）区分：使用する：1</summary>
        public static readonly short tani_nonyu_hasu_shiyo = 1;

        /// <summary>機能区分：原価発生部署使用区分：12</summary>
        public static readonly short kbn_genka_hassei_busho = 12;

        /// <summary>機能区分：倉庫使用区分：13</summary>
        public static readonly short kbn_soko = 13;
        /// <summary>倉庫使用区分：使用する：1</summary>
        public static readonly short soko_shiyo = 1;

        /// <summary>機能区分：品名表示切替区分：14</summary>
        public static readonly short kbn_hinmei_kirikae = 14;

        /// <summary>機能区分：入庫区分入力区分：16</summary>
        public static readonly short kbn_nyuko_nyuryoku = 16;

        /// <summary>機能区分：製品情報表示区分：22</summary>
        public static readonly short kbn_seihin_info_hyoji = 22;
        /// <summary>製品情報表示区分：表示しない：0</summary>
        public static readonly short seihin_hyoji_false = 0;
        /// <summary>製品情報表示区分：表示する：1</summary>
        public static readonly short seihin_hyoji_true = 1;

        /// <summary>機能区分：運転登録表示切替区分：24</summary>
        public static readonly short kbn_plc_hyoji = 24;
        /// <summary>運転登録表示区分：表示しない：0</summary>
        public static readonly short plc_hyoji_false = 0;
        /// <summary>運転登録表示区分：表示する：1</summary>
        public static readonly short plc_hyoji_true = 1;

        //////////【定数】
        /// <summary>バッチ数で端数ありの時の値</summary>
        public static readonly decimal BatchHasuAri = 1m;
        
        /// <summary>正規バッチ数の最低数</summary>
        public static readonly decimal BatchSuMinimum = 1m;
        
        /// <summary>計算時のNULL値の初期値</summary>
        public static readonly decimal CalcDefaultNumber = 0m;
        
        /// <summary>計算時のNULL値の初期値</summary>
        public static readonly Int32 CalcDefaultNumberInt = 0;
        
        /// <summary>計算時のNULL値の初期値</summary>
        public static readonly Int16 CalcDefaultNumberShort = 0;
        
        /// <summary>計算時の固定値０</summary>
        public static readonly Int32 CalcNumberZero = 0;
        
        /// <summary>計算時の固定値１</summary>
        public static readonly Int32 CalcNumberOne = 1;

        /// <summary>decimalフォーマット値</summary>
        public static readonly Int16 DecimalFormat = 6;

        /// <summary>最初の階層値</summary>
        public static readonly Int16 FirstKaiso = 1;
        
        /// <summary>比重100%の値</summary>
        public const decimal HijuDefaultConst = 1m;
        
        /// <summary>パーセント換算率</summary>
        public static readonly decimal persentKanzan = 100;

        /// <summary>日付フォーマット</summary>
        public static readonly String DateTime = "G";

        /// <summary>日付フォーマット英語</summary>
        public static readonly String DateTimeEn = "dd/MM/yyyy hh:mm:ss tt";

        /// <summary>日付フォーマット</summary>
        public static readonly String DateTimeShort = "g";

        /// <summary>日付フォーマット英語</summary>
        public static readonly String DateTimeEnShort = "dd/MM/yyyy hh:mm";

        /// <summary>日付フォーマット</summary>
        public static readonly String DateFormat = "d";

        /// <summary>日付フォーマット英語</summary>
        public static readonly String DateFormatEn = "dd/MM/yyyy";

        /// <summary>曜日フォーマット</summary>
        public static readonly String DatetimeFormatYobi = "ddd";

        /// <summary>初期版No</summary>
        public static readonly decimal HanNoShokichi = 1;

        /// <summary>単位コード：C/S</summary>
        public static readonly String TaniCodeCase = "1";

        /// <summary>1LB　= 454.55g</summary>
        public static readonly double unit_LB_GAL = 454.55;

        /// <summary>1Kg = 1000g</summary>
        public static readonly double unit_Kg_L = 1000;

        /// <summary>SAP連携用：西暦の頭2文字</summary>
        public static readonly String sapPutOnChar = "20";

        /// <summary>換算区分名：Kg</summary>
        public static readonly String KanzanNameKg = "Kg";

        /// <summary>換算区分名：L</summary>
        public static readonly String KanzanNameLi = "L";

        /// <summary>換算区分名：LB</summary>
        public static readonly String KanzanNameLb = "LB";

        /// <summary>換算区分名：GAL</summary>
        public static readonly String KanzanNameGal = "GAL";

        //////////【その他】
        /// <summary>半角スペース</summary>
        public static readonly String StringSpace = " ";

        /// <summary>ハイフン</summary>
        public static readonly String Hyphen = "-";

        /// <summary>コロン</summary>
        public static readonly String Colon = "：";

        /// <summary>カンマ</summary>
        public static readonly String Comma = ",";

        /// <summary>丸括弧</summary>
        public static readonly String NonyuIraishoPdfBracketStart = "（";

        /// <summary>丸括弧閉じ</summary>
        public static readonly String NonyuIraishoPdfBracketEnd = "）";

        /// <summary>波線</summary>
        public static readonly String WaveDash = "～";

        /// <summary>PDF出力用：休日フラグ：○</summary>
        public static readonly String FlgKyujitsuPdf = "○";

        /// <summary>納入依頼書の印刷種別：全件印刷：1</summary>
        public static readonly String NonyuIraishoPrintTypeAllPrint = "1";

        /// <summary>納入依頼書の印刷種別：全印刷：2</summary>
        public static readonly String NonyuIraishoPrintTypeSelectAllPrint = "2";

        /// <summary>マーク種別：H（作業系）</summary>
        public static readonly String MarkShubetsuH = "H";

        /// <summary>マーク種別：A（撹拌）</summary>
        public static readonly String MarkShubetsuA = "A";

        /// <summary>マーク種別：L（液体）</summary>
        public static readonly String MarkShubetsuL = "L";

        /// <summary>マーク種別：P（スパイス）</summary>
        public static readonly String MarkShubetsuP = "P";

        /// <summary>マークコードP：10（スパイス）</summary>
        public static readonly String MarkCodeSpice = "10";

        /// <summary>マークコードN：11（荷姿投入原料）</summary>
        public static readonly String MarkCodeNisugata = "11";

        /// <summary>マークコードA：12（撹拌）</summary>
        public static readonly String MarkCodeKakuhan = "12";

        /// <summary>マークコードH：13（表示）</summary>
        public static readonly String MarkCodeHyoji = "13";

        /// <summary>マークコードR：14（RI値）</summary>
        public static readonly String MarkCodeRI = "14";

        /// <summary>マークコードS：15（作業指示）</summary>
        public static readonly String MarkCodeShiji = "15";

        /// <summary>マークコードL：16（流量計）</summary>
        public static readonly String MarkCodeLiquid = "16";

        /// <summary>月間仕掛品計画：検索条件ロット：なし：0</summary>
        public static readonly String LotNashi = "0";

        /// <summary>月間仕掛品計画：検索条件ロット：製品：0</summary>
        public static readonly String LotSeihin = "1";

        /// <summary>月間仕掛品計画：検索条件ロット：親仕掛品：0</summary>
        public static readonly String LotOyaShikakari = "2";

        /// <summary>月間仕掛品計画：検索条件ロット：仕掛品：0</summary>
        public static readonly String LotShikakari = "3";

        /// <summary>format decimal convert LB to gram</summary>
        public static readonly Int16 decimalFormat_LB_GAL = 3;

        //////////【EXCEL：セル書式フォーマット】
        /// <summary>カンマ区切り、小数点以下1桁：フォーマット</summary>
        public static readonly String fmtSplitComma1 = "#,##0.0";
        /// <summary>カンマ区切り、小数点以下1桁：ID</summary>
        public static readonly UInt32Value idSplitComma1 = UInt32Value.FromUInt32(1);

        /// <summary>カンマ区切り、小数点以下2桁：フォーマット</summary>
        public static readonly String fmtSplitComma2 = "#,##0.00";
        /// <summary>カンマ区切り、小数点以下2桁：ID</summary>
        public static readonly UInt32Value idSplitComma2 = UInt32Value.FromUInt32(2);

        /// <summary>カンマ区切り、小数点以下3桁：フォーマット</summary>
        public static readonly String fmtSplitComma3 = "#,##0.000";
        /// <summary>カンマ区切り、小数点以下3桁：ID</summary>
        public static readonly UInt32Value idSplitComma3 = UInt32Value.FromUInt32(3);

        /// <summary>カンマ区切り、小数点以下4桁：フォーマット</summary>
        public static readonly String fmtSplitComma4 = "#,##0.0000";
        /// <summary>カンマ区切り、小数点以下4桁：ID</summary>
        public static readonly UInt32Value idSplitComma4 = UInt32Value.FromUInt32(4);

        /// <summary>カンマ区切り、小数点以下5桁：フォーマット</summary>
        public static readonly String fmtSplitComma5 = "#,##0.00000";
        /// <summary>カンマ区切り、小数点以下5桁：ID</summary>
        public static readonly UInt32Value idSplitComma5 = UInt32Value.FromUInt32(5);

        /// <summary>カンマ区切り、小数点以下6桁：フォーマット</summary>
        public static readonly String fmtSplitComma6 = "#,##0.000000";
        /// <summary>カンマ区切り、小数点以下6桁：ID</summary>
        public static readonly UInt32Value idSplitComma6 = UInt32Value.FromUInt32(6);

        /// <summary>カンマ区切り、小数点なし(金額など)：フォーマット</summary>
        public static readonly String fmtSplitNoComma = "#,##0";
        /// <summary>カンマ区切り、小数点なし(金額など)：ID</summary>
        public static readonly UInt32Value idSplitNoComma = UInt32Value.FromUInt32(7);
        
        //////////【バッチ起動返却値コード】
        /// <summary>バッチ起動返却値：成功：0</summary>
        public static readonly short batchStartResultComplete = 0;
        /// <summary>バッチ起動返却値：失敗：1</summary>
        public static readonly short batchStartResultError = 1;

    }
}