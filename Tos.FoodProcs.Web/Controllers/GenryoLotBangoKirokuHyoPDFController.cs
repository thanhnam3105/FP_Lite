using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Objects;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Web;
using System.Web.Http;
using System.Web.Http.OData.Query;
using System.Xml.Linq;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using Tos.FoodProcs.Web.Services;
using Tos.FoodProcs.Web.Utilities;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 原料ロット番号記録表(秤量記録表)：PDFFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class GenryoLotBangoKirokuHyoPDFController : ApiController
    {
        // 定数：XMLノード名
        /// <summary>定数：XMLノード名：root</summary>
        private static string ROOT = "root";
        /// <summary>定数：XMLノード名：pageBreak</summary>
        private static string PAGE_BREAK = "pagebreak";
        /// <summary>定数：XMLノード名：nodes</summary>
        private static string NODES = "nodes";
        /// <summary>定数：数値フォーマット用文字列</summary>
        private static string FORMAT_NUMERIC = "";
        /// <summary>定数：配合重量フォーマット用文字列</summary>
        private static string FORMAT_HAIGO_JURYO = "";
        /// <summary>均等小分け判別用</summary>
        private static short? kbn_kowake_futai = ActionConst.kbnKowakeFutaiSaidai;
        /// <summary>小数桁数</summary>
        private static int shosu_keta = 3;

        /// <summary>マーク判別用</summary>
        private static bool markShiji;

        /// <summary>定数：26バイト(全角13文字)</summary>
        //private static int BYTE_VAL = 26;
        
        // Entity取得
        private FoodProcsEntities context = new FoodProcsEntities();

        // HTTP:GET
        /// <summary>
        /// 原料ロット番号記録表(秤量記録表)のXML作成処理
        /// </summary>
        /// <param name="lang">ブラウザ言語</param>
        /// <param name="UTC">ブラウザ時間とUTCとの差分</param>
        /// <param name="uuid">uuid</param>
        /// <param name="lotNo">仕掛品ロット番号</param>
        /// <param name="jyotaiSonota">状態(その他)</param>
        /// <param name="shiyoFlg">未使用フラグ：使用</param>
        /// <param name="today">ブラウザのシステム日付</param>
        /// <returns>処理結果</returns>
        public HttpResponseMessage Get(string lang, int UTC, string uuid, string lotNo, short jyotaiSonota ,short shiyoFlg, DateTime today)
        {
            System.Globalization.CultureInfo customCulture = (System.Globalization.CultureInfo)System.Threading.Thread.CurrentThread.CurrentCulture.Clone();
            customCulture.NumberFormat.NumberDecimalSeparator = ".";
            customCulture.NumberFormat.NumberGroupSeparator = ",";
            System.Threading.Thread.CurrentThread.CurrentCulture = customCulture;

            try
            {
                // 少数の桁数を工場マスタから取得
                //GetShosuKeta(context);

                // 工場マスタから小分計算区分と小数桁数を取得する。
                GetKojoInfo(context);
                // 小数桁数を元にフォーマットを作成する。
                FORMAT_NUMERIC = FoodProcsCommonUtility.CreateSyosuFormat(shosu_keta);

                // URLの指定
                //Request #480 TOsVN(nt.toan) START
                //var jasperService = new JasperService(PDFUtilities.getJasperURL());
                // アクセス権の譲渡
                //var credentials = new NetworkCredential(PDFUtilities.getJasperUser(), PDFUtilities.getJasperpass());
                //jasperService.Credentials = credentials;
                //Request #480 TOsVN(nt.toan) END

                // 表示する項目を取得し、jrxmlのデータソースとなるXML生成を行います
                // TODO:entityにアクセスします
                IEnumerable<usp_GenryoLotBangoKirokuHyoPDF_select_Result> views;
                views = context.usp_GenryoLotBangoKirokuHyoPDF_select(
                    lotNo
                    , jyotaiSonota // 状態区分：その他
                    , shiyoFlg // 未使用フラグ
                    , ActionConst.ShikakariHinKbn   // 品区分：仕掛品
                    , ActionConst.KgKanzanKbn
                    , ActionConst.Hyphen
                    , short.Parse(Resources.ShikakarihinJotaiKbn)
                    , Resources.PdfSeihinInfoComment
                    , Resources.PdfMishiyoComment
                ).ToList();

                // TODO:ここまで
                UserController user = new UserController();
                UserInfo userInfo = user.Get();
                // TODO:データソースxmlを作成します
                string reportname = "genryoLotBangoKirokuHyo";
                string xmlname = reportname + "_" + uuid;
                // xmlnameと並列にノードを作る場合、var nodes で作成する
                XElement root = new XElement(ROOT);
                XElement pagebreakSeiki;
                XElement pagebreakHasu;
                string writeLotNo;
                string wroteLotNo = string.Empty;
                bool hasHasu = false;
                decimal? bairitsu;
                decimal? soJuryo;
                int suNisugata;
                decimal? kowakeJyuryo1;
                int suKowake1;
                decimal? kowakeJyuryo2;
                int suKowake2;
                decimal? budomari;
                int batch;
                int batchHasu;
                pagebreakSeiki = new XElement(PAGE_BREAK);
                pagebreakHasu = new XElement(PAGE_BREAK);
                string outputDay = today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
                //bool flg_g_seiki = false;   // 正規のグラムフラグ
                //bool flg_g = false;         // 端数のグラムフラグ

                // 均等小分で使用
                decimal? shikomiJuryo = 0;                  // 仕込重量
                decimal nisugataJuryo = 0;                  // 荷姿重量
                decimal? kowakeJuryo = 0;                   // 小分重量(マスタ)
                string nmTani = String.Empty;               // 単位

                KowakeCalcCriteria kowakeCalcSeikiResult;  // 計算結果(正規)格納用
                KowakeCalcCriteria kowakeCalcHasuResult;   // 計算結果(端数)格納用　

                // 機能選択から情報を取得する
                short kino = (from tr in context.cn_kino_sentaku
                              where tr.kbn_kino == ActionConst.kbn_seihin_info_hyoji
                              select tr.kbn_kino_naiyo).FirstOrDefault();

                // 機能内容が1の場合
                if (kino == ActionConst.seihin_hyoji_true)
                {
                    // 出力するxmlファイルのパスを変更する
                    reportname = reportname + "_seihin";
                    xmlname = reportname + "_" + uuid;
                }

                // 取得したデータを基に作成
                foreach (usp_GenryoLotBangoKirokuHyoPDF_select_Result list in views)
                {
                    //flg_g = false;
                    //flg_g_seiki = false;
                    writeLotNo = list.no_lot_shikakari; // lot番号を取得
                    batch = (int)list.su_batch_keikaku;
                    batchHasu = (int)list.su_batch_keikaku_hasu;
                    markShiji = false;
                    //マークが、撹拌・表示・RI値・作業指示の場合
                    if (list.cd_mark == ActionConst.MarkCodeKakuhan || list.cd_mark == ActionConst.MarkCodeHyoji
                        || list.cd_mark == ActionConst.MarkCodeRI || list.cd_mark == ActionConst.MarkCodeShiji)
                    {
                        markShiji = true;
                    }

                    if (writeLotNo != wroteLotNo)
                    {
                        hasHasu = false;
                        //if (batch > 0)
                        if (list.ritsu_keikaku > ActionConst.CalcNumberZero && batch > ActionConst.CalcNumberZero)
                        {
                            // ヘッダー情報を作成
                            pagebreakSeiki = createDataHeader(
                                list.nm_shokuba
                                , list.nm_line
                                , list.dt_seizo.AddHours(-(UTC))
                                , list.cd_haigo
                                , getMultiLanguageHaigoName(list.nm_haigo_ja, list.nm_haigo_zh, list.nm_haigo_en, list.nm_haigo_vi, lang, list.nm_hinmei)
                                , Resources.SeikiText // 正規
                                , list.nm_kbn_hin // 仕掛品分類
                                , list.wt_haigo_keikaku //配合重量（正規）
                                , list.ritsu_keikaku//倍率
                                , list.su_batch_keikaku //配合重量（B数）
                                , list.no_lot_shikakari
                                , outputDay
                                , lang
                                , list.cd_seihin
                                , getMultiLanguageSeihinName(list.nm_seihin_hinmei_ja, list.nm_seihin_hinmei_zh, list.nm_seihin_hinmei_en, list.nm_seihin_hinmei_vi, lang)
                            );
                        }
                        // 端数の計画がある場合は、作成
                        //if (list.su_batch_keikaku_hasu > 0)
                        if (list.ritsu_keikaku_hasu > ActionConst.CalcNumberZero && batchHasu > ActionConst.CalcNumberZero)
                        {
                            hasHasu = true;
                            // 端数のヘッダー情報を作成
                            pagebreakHasu = createDataHeader(
                                list.nm_shokuba
                                , list.nm_line
                                , list.dt_seizo.AddHours(-(UTC))
                                , list.cd_haigo
                                , getMultiLanguageHaigoName(list.nm_haigo_ja, list.nm_haigo_zh, list.nm_haigo_en, list.nm_haigo_vi, lang, list.nm_hinmei)
                                , Resources.HasuText // 端数
                                , list.nm_kbn_hin // 仕掛品分類
                                , list.wt_haigo_keikaku_hasu //配合重量（正規）
                                , list.ritsu_keikaku_hasu//倍率
                                , list.su_batch_keikaku_hasu //配合重量（B数）
                                , list.no_lot_shikakari
                                , outputDay
                                , lang
                                , list.cd_seihin
                                , getMultiLanguageSeihinName(list.nm_seihin_hinmei_ja, list.nm_seihin_hinmei_zh, list.nm_seihin_hinmei_en, list.nm_seihin_hinmei_vi, lang)
                            );
                        }
                    }

                    // マーク種別が作業・流量計の場合は、記録票に記載しない
                    //if (list.kbn_shubetsu != null && !ActionConst.MarkShubetsuH.Equals(list.kbn_shubetsu))
                    if (list.kbn_shubetsu != null && (!ActionConst.MarkShubetsuH.Equals(list.kbn_shubetsu)
                                                   && !ActionConst.MarkShubetsuL.Equals(list.kbn_shubetsu)))
                    {
                        decimal wt_nisugata = list.wt_nisugata == null ? 0 : (decimal)list.wt_nisugata;
                        // 多言語対応した配合名の取得
                        string haigoName = getMultiLanguageHaigoName(
                            list.nm_hinmei_ja, list.nm_hinmei_zh, list.nm_hinmei_en, list.nm_hinmei_vi, lang, list.nm_hinmei);
                        // 必要数を計算
                        bairitsu = list.ritsu_keikaku;
                        budomari = list.ritsu_budomari_recipe;
                        // 歩留まりが設定されていなかったらデフォルトで100を設定
                        budomari = (budomari == null || budomari == ActionConst.CalcDefaultNumberInt)
                            ? budomari = ActionConst.persentKanzan : budomari;

                        // 最大小分
                        if (kbn_kowake_futai == ActionConst.kbnKowakeFutaiSaidai)
                        {
                            string tani = changedNullToSpace(list.nm_tani);
                            string tani_hasu = changedNullToSpace(list.nm_tani);

                            //液体原料の場合、比重から重量換算
                            if (tani == Resources.TaniCodeL)
                            {
                                list.wt_shikomi = list.wt_shikomi * list.ritsu_hiju_recipe;
                                tani = Resources.TaniCodeKg;
                                tani_hasu = Resources.TaniCodeKg;
                            }

                            // マークの設定：スパイスの場合はｇ(グラム)
                            if (ActionConst.MarkShubetsuP.Equals(list.mark))
                            {
                                tani = Resources.TaniGram; //"g";
                                tani_hasu = Resources.TaniGram;
                            }

                            ///// バッチ数が1以上の場合、正規のXMLノードを作成する
                            //if (batch > 0)
                            if (list.ritsu_keikaku > ActionConst.CalcNumberZero && batch > ActionConst.CalcNumberZero)
                            {
                                // 重量の計算　個々のレシピ重量×(配合重量/レシピ合計)×歩留
                                //soJuryo = FoodProcsCalculator.calHiritsuSoJyuryo(list.wt_shikomi, bairitsu, list.kbn_kanzan_haigo, list.kbn_kanzan_hinmei, budomari, list.haigo_bairitsu);
                                soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, list.haigo_bairitsu);
                                ///// 各重量の数値を計算
                                // 荷姿数
                                //suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wt_nisugata));
                                //suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wt_nisugata, list.haigo_bairitsu));
                                suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wt_nisugata, list.su_batch_keikaku));
                                // 小分重量１
                                kowakeJyuryo1 = FoodProcsCalculator.calKowake1Jyuryo(
                                    list.wt_kowake_recipe, list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);
                                // 小分数１
                                suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1SuPdf(
                                    soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1, list.su_batch_keikaku));
                                // 小分重量２
                                kowakeJyuryo2 = FoodProcsCalculator.calKowake2JyuryoPdf(
                                    soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1, list.su_batch_keikaku);
                                // 小分数２
                                suKowake2 = (int)FoodProcsCalculator.calKowake2SuPdf(kowakeJyuryo2, list.su_batch_keikaku);

                                //// 荷姿数
                                //suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(list.wt_shikomi, wt_nisugata));
                                //// 小分重量１
                                //kowakeJyuryo1 = FoodProcsCalculator.calKowake1Jyuryo(
                                //    list.wt_kowake_recipe, list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);
                                //// 小分数１
                                //suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1SuPdf(
                                //    list.wt_shikomi, wt_nisugata, suNisugata, kowakeJyuryo1, 1));
                                //// 小分重量２
                                //kowakeJyuryo2 = FoodProcsCalculator.calKowake2JyuryoPdf(
                                //    list.wt_shikomi, wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1, 1);
                                //// 小分数２
                                //suKowake2 = (int)FoodProcsCalculator.calKowake2SuPdf(kowakeJyuryo2, 1);

                                //１回あたりの荷姿・小分計算後にバッチ回数分乗算
                                //suNisugata = suNisugata * (int)list.su_batch_keikaku;
                                //suKowake1 = suKowake1 * (int)list.su_batch_keikaku;
                                //suKowake2 = suKowake2 * (int)list.su_batch_keikaku;

                                //soJuryo = soJuryo * (int)list.su_batch_keikaku;

                                // 単位区分が「LB・GAL」のときの換算チェック
                                if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
                                {
                                    // マークがスパイス(cd_mark = 10)以外の場合
                                    if (list.cd_mark != ActionConst.MarkCodeSpice)
                                    {
                                        // マークがスパイス以外のとき、
                                        // 総重量、荷姿重量、小分重量１、小分重量２のいずれかがが1以下の場合、すべての重量をグラムに換算する
                                        //if (CheckJuryo(soJuryo) || CheckJuryo(wt_nisugata) || CheckJuryo(kowakeJyuryo1) || CheckJuryo(kowakeJyuryo2))
                                        //{

                                        // 荷姿重量 = 0かつ小分回数１ = 0かつ総重量が0より大きく1未満の場合
                                        // 荷姿重量 = 0かつ小分回数１ = 0かつ小分重量2が0より大きく1未満の場合
                                        if (wt_nisugata == 0 && suKowake1 == 0 && (CheckJuryo(soJuryo) || CheckJuryo(kowakeJyuryo2)))
                                        {
                                            tani = Resources.TaniGram; //"g";
                                            soJuryo = soJuryo * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                            wt_nisugata = wt_nisugata * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                            kowakeJyuryo1 = kowakeJyuryo1 * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                            kowakeJyuryo2 = FoodProcsCalculator.calKowake2JyuryoPdf(soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1, list.su_batch_keikaku);
                                        }
                                    }
                                }

                                // 荷姿重量が0で変換処理後の小分重量2がブランクでなく
                                // 荷姿重量と配合重量2が等しいなら小分数を荷姿数にマージする
                                if (wt_nisugata != 0 && CaculatorG(Convert.ToDecimal(kowakeJyuryo2), list.cd_mark) != " "
                                    && CaculatorG(Convert.ToDecimal(wt_nisugata), list.cd_mark) != " ")
                                {
                                    if (CaculatorG(Convert.ToDecimal(wt_nisugata), list.cd_mark)
                                        == CaculatorG(Convert.ToDecimal(kowakeJyuryo2), list.cd_mark))
                                    {
                                        suNisugata += suKowake2;
                                        kowakeJyuryo2 = 0;
                                        suKowake2 = 0;
                                    }
                                }

                                // ノードに値をセットし、XMLに追加する
                                var nodeSeiki = createDataLine(list.cd_hinmei, haigoName, list.nm_torihiki, wt_nisugata, soJuryo,
                                                    suNisugata, kowakeJyuryo1, suKowake1, kowakeJyuryo2, suKowake2, list.mark, list.cd_mark, tani);
                                pagebreakSeiki.Add(nodeSeiki);
                            }

                            ///// 端数がある場合は、端数の計算も実施
                            if (hasHasu)
                            {
                                // マークの設定：スパイスの場合はｇ(グラム)
                                //string tani_hasu = changedNullToSpace(list.nm_tani);
                                //if (ActionConst.MarkShubetsuP.Equals(list.mark))
                                //{
                                    //tani_hasu = Resources.TaniGram; //"g";
                                //}

                                // 必要数を計算
                                bairitsu = list.ritsu_keikaku_hasu;
                                //soJuryo = FoodProcsCalculator.calHiritsuSoJyuryo(list.wt_shikomi, bairitsu, list.kbn_kanzan_haigo, list.kbn_kanzan_hinmei, budomari, list.haigo_bairitsu_hasu);
                                soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, list.haigo_bairitsu_hasu);
                                ///// 各重量の数値を計算
                                // 荷姿数
                                //suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wt_nisugata, list.haigo_bairitsu_hasu));
                                suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wt_nisugata, list.su_batch_keikaku_hasu));
                                // 小分重量１
                                kowakeJyuryo1 = FoodProcsCalculator.calKowake1Jyuryo(
                                    list.wt_kowake_recipe, list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);
                                // 小分数１
                                //suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1Su(
                                //    soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1));
                                suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1SuPdf(
                                    soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1, list.su_batch_keikaku_hasu));
                                // 小分重量２
                                //kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(
                                //    soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1);
                                kowakeJyuryo2 = FoodProcsCalculator.calKowake2JyuryoPdf(
                                    soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1, list.su_batch_keikaku_hasu);
                                // 小分数２
                                //suKowake2 = (int)FoodProcsCalculator.calKowake2Su(kowakeJyuryo2);
                                suKowake2 = (int)FoodProcsCalculator.calKowake2SuPdf(kowakeJyuryo2, list.su_batch_keikaku_hasu);

                                //１回あたりの荷姿・小分計算後にバッチ回数分乗算
                                //suNisugata = suNisugata * (int)list.su_batch_keikaku_hasu;
                                //suKowake1 = suKowake1 * (int)list.su_batch_keikaku_hasu;
                                //suKowake2 = suKowake2 * (int)list.su_batch_keikaku_hasu;

                                //soJuryo = soJuryo * (int)list.su_batch_keikaku_hasu;

                                // 単位区分が「LB・GAL」のときの換算チェック
                                if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
                                {
                                    if (list.cd_mark != ActionConst.MarkCodeSpice)
                                    {
                                        // マークがスパイス以外のとき、
                                        // 総重量、荷姿重量、小分重量１、小分重量２のいずれかがが1以下の場合、すべての重量をグラムに換算する
                                        //if (CheckJuryo(soJuryo) || CheckJuryo(wt_nisugata) || CheckJuryo(kowakeJyuryo1) || CheckJuryo(kowakeJyuryo2))
                                        //{

                                        // 荷姿重量 = 0かつ小分重量 = 0かつ総重量が0より大きく1未満の場合
                                        // 荷姿重量 = 0かつ小分重量 = 0かつ小分重量2が0より大きく1未満の場合
                                        if (wt_nisugata == 0 && suKowake1 == 0 && (CheckJuryo(soJuryo) || CheckJuryo(kowakeJyuryo2)))
                                        {
                                            tani_hasu = Resources.TaniGram; //"g";
                                            soJuryo = soJuryo * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                            wt_nisugata = wt_nisugata * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                            kowakeJyuryo1 = kowakeJyuryo1 * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                            kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(soJuryo, wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1);
                                        }
                                    }
                                }

                                // 荷姿重量が0で変換処理後の小分重量2がブランクでなく
                                // 荷姿重量と配合重量2が等しいなら小分数を荷姿数にマージする
                                if (wt_nisugata != 0 && CaculatorG(Convert.ToDecimal(kowakeJyuryo2), list.cd_mark) != " "
                                    && CaculatorG(Convert.ToDecimal(wt_nisugata), list.cd_mark) != " ")
                                {
                                    if (CaculatorG(Convert.ToDecimal(wt_nisugata), list.cd_mark)
                                        == CaculatorG(Convert.ToDecimal(kowakeJyuryo2), list.cd_mark))
                                    {
                                        suNisugata += suKowake2;
                                        kowakeJyuryo2 = 0;
                                        suKowake2 = 0;
                                    }
                                }

                                // ノードに値をセットし、XMLに追加する
                                var nodeHasu = createDataLine(list.cd_hinmei, haigoName, list.nm_torihiki, wt_nisugata, soJuryo,
                                                    suNisugata, kowakeJyuryo1, suKowake1, kowakeJyuryo2, suKowake2, list.mark, list.cd_mark, tani_hasu);
                                pagebreakHasu.Add(nodeHasu);
                            }
                        }
                        // 均等小分
                        else
                        {
                            // 単位設定
                            nmTani = list.nm_tani;

                            // 仕込重量
                            shikomiJuryo = list.wt_shikomi;

                            //液体原料の場合、比重から重量換算
                            if (list.nm_tani == Resources.TaniCodeL)
                            {
                                // 単位をKgにする
                                nmTani = Resources.TaniCodeKg;

                                // 仕込重量をKg換算する
                                shikomiJuryo = shikomiJuryo * list.ritsu_hiju_recipe;
                            }

                            // 荷姿重量
                            nisugataJuryo = wt_nisugata;

                            // マスタに設定されている小分重量を下記優先順位で取得する
                            // 配合レシピマスタ > 重量マスタ(その他) > 重量マスタ(区分)
                            kowakeJuryo = FoodProcsCalculator.calKowake1Jyuryo(list.wt_kowake_recipe,
                                                                    list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);

                            // マークPの場合
                            if (list.cd_mark == ActionConst.MarkCodeSpice)
                            {
                                // 単位をgにする
                                nmTani = Resources.TaniCodeG;

                                // 使用単位がLB・GALの場合
                                if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
                                {
                                    shikomiJuryo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(shikomiJuryo));
                                    nisugataJuryo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(nisugataJuryo));
                                    kowakeJuryo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJuryo));
                                }
                                // 使用単位がkg・Lの場合
                                else
                                {
                                    shikomiJuryo = ConvertTo_g_From_Kg_L(Convert.ToDecimal(shikomiJuryo));
                                    nisugataJuryo = ConvertTo_g_From_Kg_L(Convert.ToDecimal(nisugataJuryo));
                                    kowakeJuryo = ConvertTo_g_From_Kg_L(Convert.ToDecimal(kowakeJuryo));
                                }
                            }

                            // 正規計算
                            if (list.haigo_bairitsu > ActionConst.CalcNumberZero)
                            {
                                // 計算結果格納オブジェクト
                                kowakeCalcSeikiResult = new KowakeCalcCriteria(shikomiJuryo, nisugataJuryo, kowakeJuryo, nmTani);

                                // 均等小分
                                CaculatorKinto(kowakeCalcSeikiResult, list.ritsu_keikaku);

                                // 補足計算
                                SupplementaryCalculation(kowakeCalcSeikiResult, list.cd_mark, userInfo.kbn_tani);

                                // ノードに値をセットし、XMLに追加する
                                var nodeSeiki = createDetailLine(list.cd_hinmei, haigoName, list.nm_torihiki, kowakeCalcSeikiResult, list.mark, list.cd_mark);
                                pagebreakSeiki.Add(nodeSeiki);

                            }

                            // 端数計算
                            if (list.haigo_bairitsu_hasu > ActionConst.CalcNumberZero)
                            {
                                // 計算結果格納オブジェクト
                                kowakeCalcHasuResult = new KowakeCalcCriteria(shikomiJuryo, nisugataJuryo, kowakeJuryo, nmTani);

                                // 均等小分
                                CaculatorKinto(kowakeCalcHasuResult, list.ritsu_keikaku_hasu);

                                // 補足計算
                                SupplementaryCalculation(kowakeCalcHasuResult, list.cd_mark, userInfo.kbn_tani);

                                // ノードに値をセットし、XMLに追加する
                                var nodeHasu = createDetailLine(list.cd_hinmei, haigoName, list.nm_torihiki, kowakeCalcHasuResult, list.mark, list.cd_mark);
                                pagebreakHasu.Add(nodeHasu);
                            }
                        }
                    }
                    /// メインへの書き込み
                    if (wroteLotNo == string.Empty || writeLotNo != wroteLotNo)
                    {
                        // ループ一回目以降、ロットNoが変わった時点で実施
                        if (batch > 0) {
                            root.Add(pagebreakSeiki); // rootに追加
                        }
                        if (hasHasu)
                        {
                            // 端数があれば追加
                            root.Add(pagebreakHasu);
                            if (writeLotNo != list.no_lot_shikakari)
                            {
                                hasHasu = false;
                            }
                        }
                    }

                    wroteLotNo = writeLotNo;
                }
                // TODO: ここまで

                /// save xml
                xmlname = xmlname + ".xml";
                string savepath = PDFUtilities.createSaveXMLPath(xmlname);
                root.Save(savepath);

                /// 出力要求用のXML作成
                //Request #480 TOsVN(nt.toan) START
                //string requestXML = PDFUtilities.createRequestXML(reportname, xmlname, lang);
                string linkAPIDownloadPDF = PDFUtilities.GetLinkAPI(reportname, xmlname, lang);
                //Request #480 TOsVN(nt.toan) END

                /// Jasper Server への POST(SOAP)
                //Request #480 TOsVN(nt.toan) START
                //jasperService.runReport(requestXML);
                //var attachment = jasperService.ResponseSoapContext.Attachments;
                //Request #480 TOsVN(nt.toan) END

                /// JasperServerからのRESPONSE				
                /// PDFファイルが返却されるので、Streamに入れる
                MemoryStream responseStream = new MemoryStream();
                //Request #480 TOsVN(nt.toan) START
                responseStream = PDFUtilities.GetStreamFromUrl(linkAPIDownloadPDF);
                //var attach = attachment[0];
                //var attachStream = attach.Stream;
                //attachStream.CopyTo(responseStream);
                //Request #480 TOsVN(nt.toan) END
                responseStream.Position = 0;

                /// レポートの取得
                // レスポンスを生成して返します
                return FileDownloadUtility.CreatePDFFileResponse(responseStream, Resources.GenryoLotBangoKirokuHyoPDFName +".pdf");
            }
            catch (Exception e)
            {
                // 例外用PDFを返却
                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, e);
                MemoryStream responseStream = new MemoryStream();
                // pathの取得
                string serverpath = HttpContext.Current.Server.MapPath("..");
                using (FileStream fs = File.OpenRead(PDFUtilities.getErrorFile(serverpath, lang)))
                {
                    fs.CopyTo(responseStream);
                }
                var errorReportname = "ServerError.pdf";
                // レスポンスを生成して返します
                return FileDownloadUtility.CreateErrorFileResponse(responseStream.ToArray(), errorReportname);
            }
        }

        /// <summary>
        /// 多言語対応した名称を返却
        /// </summary>
        /// <param name="name_ja">日本語名</param>
        /// <param name="name_zh">中国名</param>
        /// <param name="name_en">英名</param>
        /// <param name="lang">言語</param>
        /// <param name="name_recipe">配合レシピに登録されている品名</param>
        /// <returns>名称</returns>
        private string getMultiLanguageHaigoName(string name_ja, string name_zh, string name_en, string name_vi, string lang, string name_recipe)
        {
            // 日本、中国、英のいずれもnullの場合は配合レシピに登録されている品名を設定する
            if (String.IsNullOrEmpty(name_ja) && String.IsNullOrEmpty(name_zh) && String.IsNullOrEmpty(name_en) && String.IsNullOrEmpty(name_vi))
            {
                return name_recipe;
            }

            if(lang == Resources.LangJa)
            {
                return name_ja;
            }
            else if(lang == Resources.LangZh)
            {
                return name_zh;
            }
            else if (lang == Resources.LangVi)
            {
                return name_vi;
            }
            return name_en;
        }

        /// <summary>
        /// 多言語対応した名称を返却
        /// </summary>
        /// <param name="seihin_name_ja">日本語名</param>
        /// <param name="seihin_name_zh">中国名</param>
        /// <param name="seihin_name_en">英名</param>
        /// <param name="lang">言語</param>
        /// <returns>名称</returns>
        private string getMultiLanguageSeihinName(string seihin_name_ja, string seihin_name_zh, string seihin_name_en, string seihin_name_vi, string lang)
        {

            if (lang == Resources.LangJa)
            {
                return seihin_name_ja;
            }
            else if (lang == Resources.LangZh)
            {
                return seihin_name_zh;
            }
            else if (lang == Resources.LangVi)
            {
                return seihin_name_vi;
            }
            return seihin_name_en;
    
        }

        /// <summary>
        /// データのヘッダーを作成します
        /// </summary>
        private static XElement createDataHeader(string nm_shokuba, string nm_line, DateTime dt_seizo, string cd_haigo, string nm_haigo
                                                , string status, string nm_kbn_hin, decimal? wt_haigo_keikaku, decimal? ritsu_keikaku, decimal? su_batch_keikaku
                                                , string no_lot_shikakari, string outputDay, string lang, string cd_seihin, string nm_seihin)
        {
            decimal wt_haigo = (decimal)wt_haigo_keikaku;
            decimal ritsu = (decimal)ritsu_keikaku;
            return new XElement(PAGE_BREAK,
                new XElement("shokubaName", nm_shokuba),
                new XElement("lineName", nm_line),
                new XElement("seizoDate", dt_seizo.ToString(FoodProcsCommonUtility.formatDateSelect(lang))),
                new XElement("haigoCode", cd_haigo),
                new XElement("haigoName", nm_haigo),
                new XElement("seikiHasu", status),// 正規化か端数か
                new XElement("shikakariBunruiName", nm_kbn_hin),// 仕掛品分類
                new XElement("haigoJyuryo", wt_haigo.ToString("0.000")),//配合重量
                new XElement("ritsuKeikaku", ritsu.ToString("0.00")),//倍率
                new XElement("batchSu", (int)su_batch_keikaku),//配合重量（B数）
                new XElement("lotNumber", no_lot_shikakari),
                new XElement("output_day", outputDay),
                new XElement("seihinCode", cd_seihin),
                new XElement("seihinName", nm_seihin)
            );
        }

        /// <summary>
        /// データの明細部一行を作成します
        /// </summary>
        /// 
        private static XElement createDataLine(string genryoCode, string genryoName, string torihikisakiName, decimal? nisugataJuryo
                                              , decimal? soJuryo, decimal? suNisugata, decimal? kowakeJyuryo1, decimal? suKowake1
                                              , decimal? kowakeJyuryo2, decimal? suKowake2, string mark, string cd_mark, string tani)
        {
            return 
                new XElement(NODES,
                    new XElement("itemCode", genryoCode),
                    new XElement("genryoName", markShiji == true ? genryoName : genryoCode + System.Environment.NewLine + genryoName),
                    new XElement("mark", (string.IsNullOrEmpty(mark) ? " " : mark)),
                    new XElement("nm_tani", markShiji == true ? " " : tani),
                    new XElement("torihikisakiName", torihikisakiName),
                    new XElement("soJyuryo", Caculator_soJyuryo(
                        Convert.ToDecimal(soJuryo), cd_mark, nisugataJuryo, suNisugata, kowakeJyuryo1, suKowake1, kowakeJyuryo2, suKowake2)),
                    new XElement("nisugataJyuryo", suNisugata == 0 ? " " : markShiji == true ? " " : CaculatorG(Convert.ToDecimal(nisugataJuryo), cd_mark)),
                    new XElement("suNisugata", suNisugata == 0 ? " " : markShiji == true ? " " : Convert.ToString(suNisugata)),
                    new XElement("kowakeJyuryo1", suKowake1 == 0 ? " " : markShiji == true ? " " : CaculatorG(Convert.ToDecimal(kowakeJyuryo1), cd_mark)),
                    new XElement("suKowake1", suKowake1 == 0 ? " " : markShiji == true ? " " : Convert.ToString(suKowake1)),
                    new XElement("kowakeJyuryo2", suKowake2 == 0 ? " " : markShiji == true ? " " : CaculatorG(Convert.ToDecimal(kowakeJyuryo2), cd_mark)),
                    new XElement("suKowake2", suKowake2 == 0 ? " " : markShiji == true ? " " : Convert.ToString(suKowake2))
            );
        }

        /// <summary>
        /// 均等小分データの明細部一行を作成します
        /// </summary>
        /// 
        private static XElement createDetailLine(string genryoCode, string genryoName, string torihikisakiName
                                                            , KowakeCalcCriteria kowakeCalcResult, string mark, string cd_mark)
        {
            return
                new XElement(NODES,
                    new XElement("itemCode", genryoCode),
                    new XElement("genryoName", markShiji == true ? genryoName : genryoCode + System.Environment.NewLine + genryoName),
                    new XElement("mark", (string.IsNullOrEmpty(mark) ? " " : mark)),
                    new XElement("nm_tani", markShiji == true ? " " : kowakeCalcResult.nmtani),
                    new XElement("torihikisakiName", torihikisakiName),
                    new XElement("soJyuryo", markShiji == true ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.soJuryo)),
                    new XElement("nisugataJyuryo", kowakeCalcResult.nisugataSu == 0 ? " " : markShiji == true ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.nisugataJuryo)),
                    new XElement("suNisugata", kowakeCalcResult.nisugataSu == 0 ? " " : markShiji == true ? " " : Convert.ToString(kowakeCalcResult.nisugataSu)),
                    new XElement("kowakeJyuryo1", kowakeCalcResult.kowakeSu1 == 0 ? " " : markShiji == true ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.kowakeJuryo1)),
                    new XElement("suKowake1", kowakeCalcResult.kowakeSu1 == 0 ? " " : markShiji == true ? " " : Convert.ToString(kowakeCalcResult.kowakeSu1)),
                    new XElement("kowakeJyuryo2", kowakeCalcResult.kowakeSu2 == 0 ? " " : markShiji == true ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.kowakeJuryo2)),
                    new XElement("suKowake2", kowakeCalcResult.kowakeSu2 == 0 ? " " : markShiji == true ? " " : Convert.ToString(kowakeCalcResult.kowakeSu2))
            );
        }

        /// <summary>3桁カンマ区切り＋小数点以下を指定の桁数で固定した値を返却します。</summary>
        /// <param name="value">カンマ区切りにする値</param>
        /// <param name="cnt">小数点以下の桁数</param>
        /// <returns>変換後の値</returns>
        private static String SetCommmaSplit(object value, int cnt)
        {
            string result = " ";
            if (value != null)
            {
                decimal target = (decimal)value;

                // 小数点以下の桁数は画面の仕様によって増やしていく
                switch (cnt)
                {
                    case 6:
                        // 3桁カンマ区切り＋小数点以下は工場マスタから
                        //result = String.Format("{0:#,0.000}", target);
                        result = String.Format(FORMAT_NUMERIC, target);
                        break;
                    default:
                        // 3桁カンマ区切り＋小数点以下0桁
                        result = String.Format("{0:#,0}", target);
                        break;
                }
            }

            return result;
        }

        /// <summary>
        /// caculator G
        /// </summary>
        /// <param name="soJuryo"></param>
        /// <param name="cd_mark"></param>
        /// <returns></returns>
        private static String CaculatorG(decimal value, string cd_mark)
        {
            string results = " ";
            UserController user = new UserController();
            UserInfo userInfo = user.Get();
            if (markShiji == true)
            {
                results = " ";
            }
            else if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
            {
                if (cd_mark == ActionConst.MarkCodeSpice)
                {
                    decimal value_LB_GAL = Decimal.Round(ConvertTo_g_From_LB_GAL(value), ActionConst.decimalFormat_LB_GAL);
                    //results = String.Format("{0:#,0.000}", value_LB_GAL);
                    results = String.Format(FORMAT_NUMERIC, value_LB_GAL);
                }
                else
                {
                    results = SetCommmaSplit(value, ActionConst.DecimalFormat);
                }
            }
            else
            {
                if (userInfo.kbn_tani == ActionConst.kbn_tani_Kg_L || (userInfo.kbn_tani == "" || userInfo.kbn_tani == string.Empty))
                {
                    if (cd_mark == ActionConst.MarkCodeSpice)
                    {
                        decimal value_Kg_L = Decimal.Round(ConvertTo_g_From_Kg_L(value), ActionConst.decimalFormat_LB_GAL);
                        //results = String.Format("{0:#,0.000}", value_Kg_L);
                        results = String.Format(FORMAT_NUMERIC, value_Kg_L);
                    }
                    else
                    {
                        results = SetCommmaSplit(value, ActionConst.DecimalFormat);
                    }
                }
            }
            return results;
        }

        /// <summary>
        /// caculator
        /// </summary>
        /// <param name="soJuryo"></param>
        /// <param name="cd_mark"></param>
        /// <returns></returns>
        private static String Caculator_soJyuryo(decimal value, string cd_mark, decimal? nisugataJuryo, decimal? suNisugata
                                                       ,decimal? kowakeJyuryo1, decimal? suKowake1 , decimal? kowakeJyuryo2, decimal? suKowake2)
        {
            string results = " ";
            UserController user = new UserController();
            UserInfo userInfo = user.Get();
            if (markShiji == true)
            {
                results = " ";
            }
            else if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
            {
                if (cd_mark == ActionConst.MarkCodeSpice)
                {
                    decimal value_LB_GAL_nisugataJuryo = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(nisugataJuryo)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_LB_GAL_kowakeJyuryo1 = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJyuryo1)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_LB_GAL_kowakeJyuryo2 = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJyuryo2)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_LB_GAL_soJyuryo = Decimal.Round((value_LB_GAL_nisugataJuryo * Convert.ToDecimal(suNisugata)) + (value_LB_GAL_kowakeJyuryo1 * Convert.ToDecimal(suKowake1)) + (value_LB_GAL_kowakeJyuryo2 * Convert.ToDecimal(suKowake2)), ActionConst.decimalFormat_LB_GAL);
                    //results = String.Format("{0:#,0.000}", value_LB_GAL_soJyuryo);
                    results = String.Format(FORMAT_NUMERIC, value_LB_GAL_soJyuryo);
                }
                else
                {
                    results = SetCommmaSplit(value, ActionConst.DecimalFormat);
                }
            }
            else
            {
                if (userInfo.kbn_tani == ActionConst.kbn_tani_Kg_L || (userInfo.kbn_tani == "" || userInfo.kbn_tani == string.Empty))
                {
                    if (cd_mark == ActionConst.MarkCodeSpice)
                    {
                        decimal value_Kg_L_nisugataJuryo = Decimal.Round(ConvertTo_g_From_Kg_L(Convert.ToDecimal(nisugataJuryo)), ActionConst.decimalFormat_LB_GAL);
                        decimal value_Kg_L_kowakeJyuryo1 = Decimal.Round(ConvertTo_g_From_Kg_L(Convert.ToDecimal(kowakeJyuryo1)), ActionConst.decimalFormat_LB_GAL);
                        decimal value_Kg_L_kowakeJyuryo2 = Decimal.Round(ConvertTo_g_From_Kg_L(Convert.ToDecimal(kowakeJyuryo2)), ActionConst.decimalFormat_LB_GAL);
                        decimal value_Kg_L_soJyuryo = Decimal.Round((value_Kg_L_nisugataJuryo * Convert.ToDecimal(suNisugata)) + (value_Kg_L_kowakeJyuryo1 * Convert.ToDecimal(suKowake1)) + (value_Kg_L_kowakeJyuryo2 * Convert.ToDecimal(suKowake2)), ActionConst.decimalFormat_LB_GAL);
                        //results = String.Format("{0:#,0.000}", value_Kg_L_soJyuryo);
                        results = String.Format(FORMAT_NUMERIC, value_Kg_L_soJyuryo);
                    }
                    else
                    {
                        results = SetCommmaSplit(value, ActionConst.DecimalFormat);
                    }
                }
            }
            return results;
        }

        /// <summary>
        /// Convert soJuryo from KB to gram
        /// </summary>
        /// <param name="soJuryo"></param>
        /// <returns></returns>
        private static decimal ConvertTo_g_From_LB_GAL(decimal value)
        {
            //1LB　= 454.55g	  
            return value * Convert.ToDecimal(ActionConst.unit_LB_GAL);
        }

        private static decimal ConvertTo_g_From_Kg_L(decimal value)
        {
            //1kg = 1000g; 
            return value * Convert.ToDecimal(ActionConst.unit_Kg_L);
        }

        /// <summary>空文字の場合、半角空白に変更します。</summary>
        /// <param name="value">判定する値</param>
        /// <returns>判定後の値</returns>
        private String changedNullToSpace(String value)
        {
            if (String.IsNullOrEmpty(value))
            {
                value = " ";
            }
            return value;
        }

        /// <summary>
        /// 重量のグラム換算用のチェック：値が0以上1以下の場合、true
        /// </summary>
        /// <param name="juryo">値</param>
        /// <returns></returns>
        private bool CheckJuryo(decimal? juryo)
        {
            bool ret = false;
            decimal val = juryo == null ? 0 : (decimal)juryo;
            if (val < 1 && val > 0)
            {
                ret = true;
            }
            return ret;
        }

        /// <summary>
        /// 工場マスタから少数の桁数を取得し文字列を作成
        /// </summary>
        private void GetShosuKeta(FoodProcsEntities context)
        {
            UserInfo userInfo = new UserController().Get();
            ma_kojo kojoInfo = (from k in context.ma_kojo
                                where k.cd_kaisha == userInfo.KaishaCode
                                    && k.cd_kojo == userInfo.BranchCode
                                select k).FirstOrDefault();

            if (kojoInfo != null)
            {
                string shosubuFormat = string.Empty;
                short? shosuKeta = kojoInfo.su_keta_shosuten;

                for (int i = 0; i < shosuKeta; i++)
                {
                    shosubuFormat = shosubuFormat + "0";
                }

                FORMAT_NUMERIC = "{0:#,0." + shosubuFormat + "}";
                FORMAT_HAIGO_JURYO = "0." + shosubuFormat;
            }
            else
            {
                // 取得できない場合は小数部3ケタ
                FORMAT_NUMERIC = "{0:#,0.000}";
                FORMAT_HAIGO_JURYO = "0.000";
            }
        }

        /// <summary>
        /// 工場マスタから情報を取得して下記をグローバル変数に設定
        /// ① 小分計算区分
        /// ② 小数桁数
        /// </summary>
        private void GetKojoInfo(FoodProcsEntities context)
        {
            // ユーザー情報の取得
            UserInfo userInfo = new UserController().Get();

            // ユーザー情報から工場マスタの情報を取得する
            ma_kojo kojoInfo = (from k in context.ma_kojo
                                where k.cd_kaisha == userInfo.KaishaCode && k.cd_kojo == userInfo.BranchCode
                                select k).FirstOrDefault();

            // 工場マスタから情報が取得できた場合
            if (kojoInfo != null)
            {
                // 小分計算区分
                short? kbnKowakeFutai = kojoInfo.kbn_kowake_futai;
                // 小数桁数
                short? shosuKeta = kojoInfo.su_keta_shosuten;
                // フォーマット
                string shosubuFormat = string.Empty;

                // 小分計算区分が正しい値の場合
                if (kbnKowakeFutai != null && kbnKowakeFutai != 0)
                {
                    // グローバル変数に小分計算区分を設定
                    kbn_kowake_futai = kojoInfo.kbn_kowake_futai;
                }

                // 小数桁数が取得できた場合
                if (shosuKeta != null)
                {
                    // グローバル変数に小数桁数を設定する
                    shosu_keta = (int)shosuKeta;
                }
            }
        }

        /// <summary>
        /// 均等小分計算を行います。
        /// </summary>
        /// <param name="kowakeCalcResult"></param>
        /// <param name="bairitsu"></param>
        private void CaculatorKinto(KowakeCalcCriteria kowakeCalcResult, decimal? bairitsu)
        {
            // 変数定義
            decimal? zanJuryo;                  // 残重量(総重量-荷姿重量×荷姿数)
            decimal? totalKowakeLabelSu;        // 全ラベル数
            decimal? amari;                     // 余り
            decimal  ketaChosei;                // 小数桁　　　

            // 初期化
            zanJuryo = 0;
            totalKowakeLabelSu = 0;
            amari = 0;
            ketaChosei = Convert.ToDecimal(Math.Pow(10, shosu_keta));

            // 桁数調整する
            // 総重量
            kowakeCalcResult.soJuryo = Math.Ceiling(Convert.ToDecimal(kowakeCalcResult.shikomiJuryo * bairitsu * ketaChosei)) / ketaChosei;
            // 荷姿重量
            kowakeCalcResult.nisugataJuryo = Math.Ceiling(kowakeCalcResult.nisugataJuryo * ketaChosei) / ketaChosei;
            // 小分重量
            kowakeCalcResult.kowakeJuryo = Math.Ceiling(Convert.ToDecimal(kowakeCalcResult.kowakeJuryo * ketaChosei)) / ketaChosei;

            // 荷姿数
            kowakeCalcResult.nisugataSu = Math.Floor(FoodProcsCalculator.calNisugataSu(kowakeCalcResult.soJuryo, kowakeCalcResult.nisugataJuryo));

            // 総重量から荷姿重量を引いた重量を求める
            zanJuryo = kowakeCalcResult.soJuryo - (kowakeCalcResult.nisugataJuryo * kowakeCalcResult.nisugataSu);

            // 荷姿ラベルのみでない場合
            if (zanJuryo != 0)
            {
                // 合計ラベル数を求める
                totalKowakeLabelSu = Math.Ceiling(Convert.ToDecimal(zanJuryo / kowakeCalcResult.kowakeJuryo));

                // 余りを求める
                amari = ((zanJuryo * ketaChosei) % totalKowakeLabelSu) / ketaChosei;

                // 余りがある場合
                if (amari > 0)
                {
                    // 小分数2
                    kowakeCalcResult.kowakeSu2 = 1;
                }

                // 小分数1
                kowakeCalcResult.kowakeSu1 = totalKowakeLabelSu - kowakeCalcResult.kowakeSu2;

                // 小分重量1
                kowakeCalcResult.kowakeJuryo1 = (zanJuryo - amari) / totalKowakeLabelSu;

                // 小分重量2
                kowakeCalcResult.kowakeJuryo2 = zanJuryo - (kowakeCalcResult.kowakeJuryo1 * kowakeCalcResult.kowakeSu1);
            }
        }

        /// <summary>
        /// 補足計算を行います。
        /// </summary>
        /// <param name="kowakeCalcResult"></param>
        /// <param name="cdMark"></param>
        /// <param name="kbnTani"></param>
        private void SupplementaryCalculation(KowakeCalcCriteria kowakeCalcResult, string cdMark, string kbnTani)
        {
            decimal? ketaChosei;                // 小数桁

            // 工場がQ&B以外の場合またはマークPの場合は処理しない
            if (kbnTani != ActionConst.kbn_tani_LB_GAL || cdMark == ActionConst.MarkCodeSpice)
            {
                return;
            }

            ketaChosei = Convert.ToDecimal(Math.Pow(10, shosu_keta));

            // 使用単位がLB かつ
            // 0LB < 総重量 < 1LB かつ
            // 荷姿重量 = 0 かつ 小分数1 = 0 の場合
            if (kowakeCalcResult.nisugataJuryo == 0
                && (CheckJuryo(kowakeCalcResult.kowakeJuryo1) || CheckJuryo(kowakeCalcResult.kowakeJuryo2))
                )
            {
                // 単位をgにして総重量と小分重量2をg換算する
                kowakeCalcResult.nmtani = Resources.TaniCodeG;
                kowakeCalcResult.soJuryo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeCalcResult.soJuryo));
                kowakeCalcResult.kowakeJuryo1 = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeCalcResult.kowakeJuryo1));
                kowakeCalcResult.kowakeJuryo2 = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeCalcResult.kowakeJuryo2));

                // 換算値を桁数調整する
                kowakeCalcResult.soJuryo = Math.Ceiling(Convert.ToDecimal(kowakeCalcResult.soJuryo * ketaChosei)) / ketaChosei;
                kowakeCalcResult.kowakeJuryo1 = Math.Ceiling(Convert.ToDecimal(kowakeCalcResult.kowakeJuryo1 * ketaChosei)) / ketaChosei;
                kowakeCalcResult.kowakeJuryo2 = Math.Ceiling(Convert.ToDecimal(kowakeCalcResult.kowakeJuryo2 * ketaChosei)) / ketaChosei;

            }
        }
    }
}