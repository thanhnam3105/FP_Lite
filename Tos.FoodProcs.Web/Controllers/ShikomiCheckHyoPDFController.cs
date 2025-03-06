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
using System.Collections;

namespace Tos.FoodProcs.Web.Controllers
{
    /// <summary>
    /// 配合チェック表：PDFFile作成コントローラを定義します。
    /// </summary>
    /// <remarks>
    /// </remarks>

    [Authorize]
    [LoggingExceptionFilter]
    public class ShikomiCheckHyoPDFController : ApiController
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
        /// <summary>均等小分け判別用</summary>
        private static short? kbn_kowake_futai = ActionConst.kbnKowakeFutaiSaidai;
        /// <summary>小数桁数</summary>
        private static int shosu_keta = 3;

        /// <summary>定数：24バイト(全角12文字)</summary>
        //private static int BYTE_VAL = 24;

        /// <summary>マーク判別用</summary>
        private static bool markShiji;
        
        // Entity取得
        private FoodProcsEntities context = new FoodProcsEntities();

        // HTTP:GET
        public HttpResponseMessage Get(string lang, int UTC, string uuid, string lotNo, short shiyoFlg, DateTime today)
        {
            System.Globalization.CultureInfo customCulture = (System.Globalization.CultureInfo)System.Threading.Thread.CurrentThread.CurrentCulture.Clone();
            customCulture.NumberFormat.NumberDecimalSeparator = ".";
            customCulture.NumberFormat.NumberGroupSeparator = ",";
            System.Threading.Thread.CurrentThread.CurrentCulture = customCulture;

            try
            {
                // 少数の桁数を工場マスタから取得
                FoodProcsEntities context = new FoodProcsEntities();
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
                //FoodProcsEntities context = new FoodProcsEntities();
                IEnumerable<usp_CheckHyoPDF_select_Result> views;
                var count = new ObjectParameter("count", 0);
                views = context.usp_CheckHyoPDF_select(
                    lotNo
                    , shiyoFlg // 未使用フラグ
                    , ActionConst.ShikakariHinKbn   // 品区分：仕掛品
                    , count
                    , ActionConst.KgKanzanKbn       // 単位コード：Kg
                    , ActionConst.Hyphen
                    , short.Parse(Resources.ShikakarihinJotaiKbn)
                    , short.Parse(Resources.SonotaJotaiKbn)
                    , Resources.PdfSeihinInfoComment
                    , Resources.PdfMishiyoComment
                ).ToList();

                ////////// データソースxmlを作成します

                UserController user = new UserController();
                UserInfo userInfo = user.Get();
                string reportname = "shikomiCheckHyo";
                string xmlname = reportname + "_" + uuid;
                // xmlnameと並列にノードを作る場合、var nodes で作成する
                XElement root = new XElement(ROOT);
                XElement pagebreakSeiki;
                XElement pagebreakHasu;
                string writeLotNo;
                string wroteLotNo = string.Empty;
                bool hasHasu = false;
                int batch;
                int batchHasu;
                pagebreakSeiki = new XElement(PAGE_BREAK);
                pagebreakHasu = new XElement(PAGE_BREAK);
                ArrayList kaipage = new ArrayList();
                ArrayList kaipageHasu = new ArrayList();
                string outputDay = today.ToString(FoodProcsCommonUtility.formatDateTimeSelect(lang));
                decimal? nowkotei = 1;
                int countSix = 3; //明細/回数の最大値
                int multiple = 1; //7の倍数用変数（明細が6回目までしかないため、7回目で改ページ）
                int addOne = 0;
                // 計算用
                decimal? bairitsu;
                decimal? soJuryo;
                decimal? budomari;
                decimal? suNisugata;
                decimal? wtNisugata;
                decimal? suKowake;
                decimal? wtKowake;
                decimal? suKowakeHasu;
                decimal? wtKowakeHasu;
                bool flg_g_seiki = false;
                bool flg_g = false;

                // 均等小分で使用
                decimal? shikomiJuryo = 0;                               // 仕込重量
                decimal nisugataJuryo = 0;                               // 荷姿重量
                decimal? kowakeJuryo = 0;                                // 小分重量(マスタ)
                string nmTani = String.Empty;                            // 単位

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
                foreach (usp_CheckHyoPDF_select_Result list in views)
                {
                    writeLotNo = list.no_lot_shikakari; // lot番号を取得
                    wtNisugata = list.wt_nisugata == null ? 0 : (decimal)list.wt_nisugata;
                    flg_g = false;
                    flg_g_seiki = false;
                    markShiji = false;

                    //マークが、撹拌・表示・RI値・作業指示・流量計の場合
                    if (list.cd_mark == ActionConst.MarkCodeKakuhan || list.cd_mark == ActionConst.MarkCodeHyoji
                        || list.cd_mark == ActionConst.MarkCodeRI || list.cd_mark == ActionConst.MarkCodeShiji
                        || list.cd_mark == ActionConst.MarkCodeLiquid)
                    {
                        markShiji = true;
                    }
                    // ロット番号または、工程が違う場合はヘッダー情報を変更して改ページ
                    if (writeLotNo != wroteLotNo || nowkotei != list.no_kotei)
                    {
                        if (writeLotNo != wroteLotNo)
                        {
                            // ロット番号が変更になった場合は端数フラグを一度リセット
                            hasHasu = false;
                        }
                        
                        addOne = 0;
                        multiple = 0;
                        kaipage = new ArrayList();
                        kaipageHasu = new ArrayList();
                        batch = (int)list.su_batch_keikaku;
                        batchHasu = (int)list.su_batch_keikaku_hasu;
                        int[] kaisuCount = new int[batch + countSix]; // 余分な回数を考慮

                        if (list.ritsu_keikaku > ActionConst.CalcNumberZero && batch > ActionConst.CalcNumberZero)
                        {
                            for (int x = 0; x < batch; x++)
                            {
                                kaisuCount[x] = x + 1;
                                if (x < countSix)
                                {
                                    pagebreakSeiki = createDataHeader(
                                        list.nm_shokuba
                                        , list.nm_line
                                        , list.dt_seizo.AddHours(-(UTC))
                                        , list.cd_haigo // 配合コード
                                        , getMultiLanguageName(list.nm_haigo_ja, list.nm_haigo_zh, list.nm_haigo_en, list.nm_haigo_vi, lang)
                                        , Resources.SeikiText // 正規
                                        , list.nm_kbn_hin // 仕掛品分類
                                        , list.wt_haigo_gokei * list.ritsu_keikaku
                                        , list.ritsu_keikaku //倍率
                                        , batch //配合重量（B数）
                                        , list.no_kotei // 工程番号
                                        , list.no_lot_shikakari
                                        , kaisuCount[0]
                                        , kaisuCount[1]
                                        , kaisuCount[2]
                                        , outputDay
                                        , lang
                                        , list.cd_seihin
                                        , getMultiLanguageSeihinName(list.nm_seihin_hinmei_ja, list.nm_seihin_hinmei_zh, list.nm_seihin_hinmei_en, list.nm_seihin_hinmei_vi, lang)
                                    );
                                }
                                else if ((x + 1 + addOne) % 4 == 0)
                                {
                                    multiple = multiple + countSix;
                                    kaipage.Add(pagebreakSeiki);
                                    pagebreakSeiki = createDataHeader(
                                        list.nm_shokuba
                                        , list.nm_line
                                        , list.dt_seizo.AddHours(-(UTC))
                                        , list.cd_haigo // 配合コード
                                        , getMultiLanguageName(list.nm_haigo_ja, list.nm_haigo_zh, list.nm_haigo_en, list.nm_haigo_vi, lang)
                                        , Resources.SeikiText // 正規
                                        , list.nm_kbn_hin // 仕掛品分類
                                        , list.wt_haigo_gokei * list.ritsu_keikaku
                                        , list.ritsu_keikaku //倍率
                                        , batch //配合重量（B数）
                                        , list.no_kotei // 工程番号
                                        , list.no_lot_shikakari
                                        , kaisuCount[x]
                                        , kaisuCount[x + 1]
                                        , kaisuCount[x + 2]
                                        , outputDay
                                        , lang
                                        , list.cd_seihin
                                        , getMultiLanguageSeihinName(list.nm_seihin_hinmei_ja, list.nm_seihin_hinmei_zh, list.nm_seihin_hinmei_en, list.nm_seihin_hinmei_vi, lang)

                                    );
                                    addOne = addOne + 1;
                                }
                                else
                                {
                                    pagebreakSeiki = createDataHeader(
                                        list.nm_shokuba
                                        , list.nm_line
                                        , list.dt_seizo.AddHours(-(UTC))
                                        , list.cd_haigo // 配合コード
                                        , getMultiLanguageName(list.nm_haigo_ja, list.nm_haigo_zh, list.nm_haigo_en, list.nm_haigo_vi, lang)
                                        , Resources.SeikiText // 正規
                                        , list.nm_kbn_hin // 仕掛品分類
                                        , list.wt_haigo_gokei * list.ritsu_keikaku
                                        , list.ritsu_keikaku //倍率
                                        , batch //配合重量（B数）
                                        , list.no_kotei // 工程番号
                                        , list.no_lot_shikakari
                                        , kaisuCount[multiple]
                                        , kaisuCount[multiple + 1]
                                        , kaisuCount[multiple + 2]
                                        , outputDay
                                        , lang
                                        , list.cd_seihin
                                        , getMultiLanguageSeihinName(list.nm_seihin_hinmei_ja, list.nm_seihin_hinmei_zh, list.nm_seihin_hinmei_en, list.nm_seihin_hinmei_vi, lang)

                                    );
                                }
                            }
                            kaipage.Add(pagebreakSeiki);
                        }
                        //if (batch > 0)
                        //{
                            //kaipage.Add(pagebreakSeiki);
                        //}

                        // 端数の計画がある場合は、作成
                        //if (list.su_batch_keikaku_hasu > ActionConst.CalcNumberZero)
                        if (list.ritsu_keikaku_hasu != ActionConst.CalcNumberZero && batchHasu > ActionConst.CalcNumberZero)
                        {
                            hasHasu = true;
                            batchHasu = (int)list.su_batch_keikaku_hasu;
                            // 端数のヘッダー情報を作成
                            pagebreakHasu = createDataHeader(
                                list.nm_shokuba
                                , list.nm_line
                                , list.dt_seizo.AddHours(-(UTC))
                                , list.cd_haigo // 配合コード
                                , getMultiLanguageName(list.nm_haigo_ja, list.nm_haigo_zh, list.nm_haigo_en, list.nm_haigo_vi, lang)
                                , Resources.HasuText // 端数
                                , list.nm_kbn_hin // 仕掛品分類
                                , list.wt_haigo_keikaku_hasu //配合重量（正規）
                                , list.ritsu_keikaku_hasu //倍率
                                , batchHasu //配合重量（B数）
                                , list.no_kotei // 工程番号
                                , list.no_lot_shikakari
                                //, kaisuCount[0]
                                , ActionConst.CalcNumberOne
                                , 0
                                , 0
                                , outputDay
                                , lang
                                , list.cd_seihin
                                , getMultiLanguageSeihinName(list.nm_seihin_hinmei_ja, list.nm_seihin_hinmei_zh, list.nm_seihin_hinmei_en, list.nm_seihin_hinmei_vi, lang)
                                
                            );
                            kaipageHasu.Add(pagebreakHasu);
                        }
                        //kaipageHasu.Add(pagebreakHasu);
                    }

                    // 必要量を計算
                    //bairitsu = list.ritsu_keikaku;
                    budomari = list.ritsu_budomari_recipe;
                    // 歩留まりが設定されていなかったらデフォルトで100を設定
                    budomari = (budomari == null || budomari == ActionConst.CalcDefaultNumberInt) ? budomari = ActionConst.persentKanzan : budomari;

                    // 最大小分
                    if (kbn_kowake_futai == ActionConst.kbnKowakeFutaiSaidai)
                    {
                        // 必要量を計算
                        bairitsu = list.ritsu_keikaku;
                        //budomari = list.ritsu_budomari_recipe;
                        // 歩留まりが設定されていなかったらデフォルトで100を設定
                        //budomari = (budomari == null || budomari == ActionConst.CalcDefaultNumberInt) ? budomari = ActionConst.persentKanzan : budomari;

                        // 重量の計算　個々のレシピ重量×(配合重量/レシピ合計)×歩留
                        //soJuryo = FoodProcsCalculator.calHiritsuSoJyuryo(list.wt_shikomi, bairitsu, list.kbn_kanzan_haigo, list.kbn_kanzan_hinmei, budomari, list.haigo_bairitsu);
                        //soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, bairitsu, list.kbn_kanzan_haigo, list.kbn_kanzan_hinmei, budomari, list.haigo_bairitsu) / (int)list.su_batch_keikaku;
                        soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, list.haigo_bairitsu);

                        int su_batch = (int)list.su_batch_keikaku;
                        if (su_batch > 0)
                        {
                            // 正規バッチ数が1以上であれば、バッチ数で総重量を割る
                            soJuryo = soJuryo / su_batch;
                        }

                        ///// 各重量の数値を計算
                        // 荷姿数
                        suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wtNisugata));
                        // 小分重量１
                        //wtKowake = list.wt_kowake;
                        wtKowake = FoodProcsCalculator.calKowake1Jyuryo(list.wt_kowake, list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);
                        // 小分数１
                        suKowake = (int)Math.Floor(FoodProcsCalculator.calKowake1SuCheckPdf
                            (soJuryo, wtNisugata, suNisugata, wtKowake, list.su_batch_keikaku));
                        // 小分重量２
                        wtKowakeHasu = FoodProcsCalculator.calKowake2JyuryoCheckPdf(
                            soJuryo, wtNisugata, suNisugata, wtKowake, suKowake, list.su_batch_keikaku);
                        // 小分数２
                        suKowakeHasu = (int)FoodProcsCalculator.calKowake2SuPdf(wtKowakeHasu, 1);

                        // 単位区分が「LB・GAL」のときの換算チェック
                        if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
                        {
                            // マークがスパイス(cd_mark = 10)以外の場合
                            if (list.cd_mark != ActionConst.MarkCodeSpice)
                            {
                                // マークがスパイス以外のとき、
                                // 総重量、荷姿重量、小分重量１、小分重量２のいずれかがが1以下の場合、すべての重量をグラムに換算する
                                //if (CheckJuryo(soJuryo) || CheckJuryo(wtNisugata) || CheckJuryo(wtKowake) || CheckJuryo(wtKowakeHasu))
                                //{

                                // 荷姿重量 = 0かつ小分回数１ = 0かつ総重量が0より大きく1未満の場合
                                // 荷姿重量 = 0かつ小分回数１ = 0かつ小分重量2が0より大きく1未満の場合
                                if (wtNisugata == 0 && suKowake == 0 && (CheckJuryo(soJuryo) || CheckJuryo(wtKowakeHasu)))
                                {
                                    flg_g_seiki = true;
                                    soJuryo = soJuryo * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                    wtNisugata = wtNisugata * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                    wtKowake = wtKowake * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                    wtKowakeHasu = FoodProcsCalculator.calKowake2JyuryoCheckPdf(
                                        soJuryo, wtNisugata, suNisugata, wtKowake, suKowake, list.su_batch_keikaku);
                                }
                            }
                        }

                        // 荷姿重量が0で変換処理後の小分重量2がブランクでなく
                        // 荷姿重量と配合重量2が等しいなら小分数を荷姿数にマージする
                        if (wtNisugata != 0 && CaculatorG(Convert.ToDecimal(wtKowakeHasu), list.cd_mark) != " "
                            && CaculatorG(Convert.ToDecimal(wtNisugata), list.cd_mark) != " ")
                        {
                            if (CaculatorG(Convert.ToDecimal(wtNisugata), list.cd_mark)
                                == CaculatorG(Convert.ToDecimal(wtKowakeHasu), list.cd_mark))
                            {
                                suNisugata += suKowakeHasu;
                                wtKowakeHasu = 0;
                                suKowakeHasu = 0;
                            }
                        }

                        // ノードに値をセットし、XMLに追加する
                        var nodeSeiki = createDataLine(
                            list.cd_hinmei, list.nm_hinmei, Resources.SeikiTextShort, getTaniName(list.nm_tani, list.cd_mark, flg_g_seiki),
                            soJuryo, wtNisugata, suNisugata, wtKowake, suKowake, wtKowakeHasu, suKowakeHasu, list.mark, list.cd_mark);
                        for (int y = 1; y <= kaipage.Count; ++y)
                        {
                            pagebreakSeiki = (XElement)kaipage[y-1];
                            pagebreakSeiki.Add(nodeSeiki);
                            kaipage[y-1]= pagebreakSeiki;
                        }

                        // 端数がある場合は、端数の計算も実施
                        if (hasHasu)
                        {
                            // 必要数を計算
                            bairitsu = list.ritsu_keikaku_hasu;
                            //soJuryo = FoodProcsCalculator.calHiritsuSoJyuryo(list.wt_shikomi, bairitsu, list.kbn_kanzan_haigo, list.kbn_kanzan_hinmei, budomari, list.haigo_bairitsu_hasu);
                            soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, list.haigo_bairitsu_hasu);

                            ///// 各重量の数値を計算
                            // 荷姿数
                            suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wtNisugata));
                            // 小分重量１
                            //wtKowake = list.wt_kowake;
                            wtKowake = FoodProcsCalculator.calKowake1Jyuryo(list.wt_kowake, list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);
                            // 小分数１
                            suKowake = (int)Math.Floor(FoodProcsCalculator.calKowake1SuCheckPdf(
                                soJuryo, wtNisugata, suNisugata, wtKowake, list.su_batch_keikaku_hasu));
                            // 小分重量２
                            wtKowakeHasu = FoodProcsCalculator.calKowake2JyuryoCheckPdf(
                                soJuryo, wtNisugata, suNisugata, wtKowake, suKowake, list.su_batch_keikaku_hasu);
                            // 小分数２
                            suKowakeHasu = (int)FoodProcsCalculator.calKowake2SuPdf(wtKowakeHasu, 1);

                            // 単位区分が「LB・GAL」のときの換算チェック
                            if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
                            {
                                // マークがスパイス(cd_mark = 10)の場合
                                if (list.cd_mark != ActionConst.MarkCodeSpice)
                                {
                                    // マークがスパイス以外のとき、
                                    // 総重量、荷姿重量、小分重量１、小分重量２のいずれかがが1以下の場合、すべての重量をグラムに換算する
                                    //if (CheckJuryo(soJuryo) || CheckJuryo(wtNisugata) || CheckJuryo(wtKowake) || CheckJuryo(wtKowakeHasu))
                                    //if (soJuryo < 1)
                                    //{

                                    // 荷姿重量 = 0かつ小分回数１ = 0かつ総重量が0より大きく1未満の場合
                                    // 荷姿重量 = 0かつ小分回数１ = 0かつ小分重量2が0より大きく1未満の場合
                                    if (wtNisugata == 0 && suKowake == 0 && (CheckJuryo(soJuryo) || CheckJuryo(wtKowakeHasu)))
                                    {
                                        flg_g = true;
                                        soJuryo = soJuryo * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                        wtNisugata = wtNisugata * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                        wtKowake = wtKowake * Convert.ToDecimal(ActionConst.unit_LB_GAL);
                                        wtKowakeHasu = FoodProcsCalculator.calKowake2JyuryoCheckPdf(
                                            soJuryo, wtNisugata, suNisugata, wtKowake, suKowake, list.su_batch_keikaku_hasu);
                                    }
                                }
                            }

                            // 荷姿重量が0で変換処理後の小分重量2がブランクでなく
                            // 荷姿重量と配合重量2が等しいなら小分数を荷姿数にマージする
                            if (wtNisugata != 0 && CaculatorG(Convert.ToDecimal(wtKowakeHasu), list.cd_mark) != " "
                                && CaculatorG(Convert.ToDecimal(wtNisugata), list.cd_mark) != " ")
                            {
                                if (CaculatorG(Convert.ToDecimal(wtNisugata), list.cd_mark)
                                    == CaculatorG(Convert.ToDecimal(wtKowakeHasu), list.cd_mark))
                                {
                                    suNisugata += suKowakeHasu;
                                    wtKowakeHasu = 0;
                                    suKowakeHasu = 0;
                                }
                            }

                            // ノードに値をセットし、XMLに追加する
                            var nodeHasu = createDataLine(
                                list.cd_hinmei, list.nm_hinmei, Resources.HasuTextShort, getTaniName(list.nm_tani, list.cd_mark, flg_g),
                                soJuryo, wtNisugata, suNisugata, wtKowake, suKowake, wtKowakeHasu, suKowakeHasu, list.mark,list.cd_mark);
                            for (int m = 1; m <= kaipageHasu.Count; ++m)
                            {
                                pagebreakHasu = (XElement)kaipageHasu[m - 1];
                                pagebreakHasu.Add(nodeHasu);
                                kaipageHasu[m - 1] = pagebreakHasu;
                            }
                        }
                    }
                    // 均等小分
                    else
                    {
                        // 単位設定
                        nmTani = list.nm_tani;

                        // 仕込重量
                        shikomiJuryo = list.wt_shikomi;

                        // 荷姿重量
                        nisugataJuryo = Convert.ToDecimal(wtNisugata);

                        // マスタに設定されている小分重量を下記優先順位で取得する
                        // 配合レシピマスタ > 重量マスタ(その他) > 重量マスタ(区分)
                        kowakeJuryo = FoodProcsCalculator.calKowake1Jyuryo(list.wt_kowake,
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
                            var nodeSeiki = createDetailLine(list.cd_hinmei, list.nm_hinmei, Resources.SeikiTextShort,
                                                                            kowakeCalcSeikiResult, list.mark, list.cd_mark);

                            for (int y = 1; y <= kaipage.Count; ++y)
                            {
                                pagebreakSeiki = (XElement)kaipage[y-1];
                                pagebreakSeiki.Add(nodeSeiki);
                                kaipage[y-1]= pagebreakSeiki;
                            }
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
                            var nodeHasu = createDetailLine(list.cd_hinmei, list.nm_hinmei, Resources.HasuTextShort
                                                                            , kowakeCalcHasuResult, list.mark, list.cd_mark);

                            for (int m = 1; m <= kaipageHasu.Count; ++m)
                            {
                                pagebreakHasu = (XElement)kaipageHasu[m - 1];
                                pagebreakHasu.Add(nodeHasu);
                                kaipageHasu[m - 1] = pagebreakHasu;
                            }
                        }
                    }

                    ///// メインへの書き込み
                    if (wroteLotNo == string.Empty || writeLotNo != wroteLotNo || nowkotei != list.no_kotei)
                    {
                        for (int y = 1; y <= kaipage.Count; ++y)
                        {
                            pagebreakSeiki = (XElement)kaipage[y - 1];
                            root.Add(pagebreakSeiki); // rootに追加
                        }
                        if (hasHasu)
                        {
                            for (int l = 1; l <= kaipageHasu.Count; ++l)
                            {
                                pagebreakHasu = (XElement)kaipageHasu[l - 1];
                                root.Add(pagebreakHasu); // rootに追加
                            }
                            //if (writeLotNo != list.no_lot_shikakari)
                            //{
                            //    hasHasu = false;
                            //}
                        }
                    }
                    
                    nowkotei = list.no_kotei;
                    wroteLotNo = writeLotNo;
                }
                
                ////////// データソースxmlを作成: ここまで

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
                return FileDownloadUtility.CreatePDFFileResponse(responseStream, Resources.ShikomiCheckHyoPDFName + ".pdf");
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
        private string getMultiLanguageName(string name_ja, string name_zh, string name_en, string name_vi, string lang)
        {
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
                                                , string status, string nm_kbn_hin, decimal? wt_haigo_gokei, decimal? ritsu_keikaku, int? su_batch_keikaku
                                                , decimal? su_kotei_keikaku, string no_lot_shikakari, int? kai1, int? kai2, int? kai3, string outputDay
                                                , string lang, string cd_seihin, string nm_seihin)
        {
            string sukai1 = (kai1 != 0) ? kai1.ToString() + Resources.Kaisu: "";
            string sukai2 = (kai2 != 0) ? kai2.ToString() + Resources.Kaisu : "";
            string sukai3 = (kai3 != 0) ? kai3.ToString() + Resources.Kaisu : "";
            decimal ritsu = (decimal)ritsu_keikaku;

            return new XElement(PAGE_BREAK,
                new XElement("shokubaName", nm_shokuba),
                new XElement("lineName", nm_line),
                new XElement("seizoDate", dt_seizo.ToString(FoodProcsCommonUtility.formatDateSelect(lang))),
                new XElement("haigoCode", cd_haigo),
                new XElement("haigoName", nm_haigo),
                new XElement("seikiHasu", status),// 正規化か端数か
                new XElement("shikakariBunruiName", nm_kbn_hin),// 仕掛品分類
                new XElement("haigoJyuryo", CaculatorG((decimal)wt_haigo_gokei, "")),//配合重量（正規）
                new XElement("batchSu", su_batch_keikaku),//配合重量（B数）
                new XElement("ritsuKeikaku", ritsu.ToString("0.00")),//倍率
                new XElement("koteiSu", su_kotei_keikaku),// バッチ工程数
                new XElement("lotNumber", no_lot_shikakari),
                new XElement("kaisu1", sukai1),// バッチ工程数
                new XElement("kaisu2", sukai2),// バッチ工程数
                new XElement("kaisu3", sukai3),// バッチ工程数
                new XElement("output_day", outputDay),
                new XElement("seihinCode", cd_seihin),
                new XElement("seihinName", nm_seihin)
            );
        }

        /// <summary>
        /// データの明細部一行を作成します
        /// </summary>
        /// 
        private static XElement createDataLine(string genryoCode, string genryoName, string seikihasuBunrui, string taniName
                                              , decimal? soJuryo, decimal? wtNisugata, decimal? suNisugata, decimal? wtKowake, decimal? suKowake
                                              , decimal? wtKowakeHasu, decimal? suKowakeHasu , string mark , string cd_mark
                                              )
        {
            return 
                new XElement(NODES,
                    new XElement("genryoCode", genryoCode),
                    //new XElement("genryoName", markShiji == true ? genryoName : genryoCode + System.Environment.NewLine + genryoName),
                    new XElement("genryoName", markShiji == true && cd_mark != ActionConst.MarkCodeLiquid ? genryoName : genryoCode + System.Environment.NewLine + genryoName),
                    new XElement("seikihasuBunrui", seikihasuBunrui),
                    new XElement("mark", (string.IsNullOrEmpty(mark) ? " " : mark)),
                    new XElement("taniName", taniName),
                    new XElement("soJyuryo", (soJuryo == 0 ? " " :CaculatorSoJuryo(Decimal.Round((decimal)soJuryo, ActionConst.DecimalFormat), cd_mark, wtNisugata, suNisugata, wtKowake, suKowake, wtKowakeHasu, suKowakeHasu))),
                    new XElement("wtNisugata", (suNisugata == 0 ? " " : CaculatorG(Convert.ToDecimal(wtNisugata), cd_mark))),
                    new XElement("suNisugata", (suNisugata == 0 ? " " : markShiji == true ? " " : String.Format("{0:#,0}", suNisugata))),
                    new XElement("wtKowake", (suKowake == 0 ? " " : CaculatorG(Convert.ToDecimal(wtKowake), cd_mark))),
                    new XElement("suKowake", (suKowake == 0 ? " " : markShiji == true ? " " : String.Format("{0:#,0}", suKowake))),
                    new XElement("wtKowakeHasu", (suKowakeHasu == 0 ? " " : CaculatorG(Convert.ToDecimal(wtKowakeHasu), cd_mark))),
                    new XElement("suKowakeHasu", (suKowakeHasu == 0 ? " " : markShiji == true ? " " : String.Format("{0:#,0}", suKowakeHasu)))
            );
        }

        /// <summary>
        /// 均等小分データの明細部一行を作成します
        /// </summary>
        /// 
        private static XElement createDetailLine(string genryoCode, string genryoName, string seikihasuBunrui
                                                            , KowakeCalcCriteria kowakeCalcResult, string mark, string cd_mark)
        {
            return
                new XElement(NODES,
                    new XElement("genryoCode", genryoCode),
                    new XElement("genryoName", markShiji == true && cd_mark != ActionConst.MarkCodeLiquid ? genryoName : genryoCode + System.Environment.NewLine + genryoName),
                    new XElement("seikihasuBunrui", seikihasuBunrui),
                    new XElement("mark", (string.IsNullOrEmpty(mark) ? " " : mark)),
                    new XElement("taniName", kowakeCalcResult.nmtani),
                    new XElement("soJyuryo", (kowakeCalcResult.soJuryo == 0 ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.soJuryo))),
                    new XElement("wtNisugata", (kowakeCalcResult.nisugataSu == 0 ? " " : markShiji == true ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.nisugataJuryo))),
                    new XElement("suNisugata", (kowakeCalcResult.nisugataSu == 0 ? " " : markShiji == true ? " " : Convert.ToString(kowakeCalcResult.nisugataSu))),
                    new XElement("wtKowake", (kowakeCalcResult.kowakeSu1 == 0 ? " " : markShiji == true ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.kowakeJuryo1))),
                    new XElement("suKowake", (kowakeCalcResult.kowakeSu1 == 0 ? " " : markShiji == true ? " " : Convert.ToString(kowakeCalcResult.kowakeSu1))),
                    new XElement("wtKowakeHasu", (kowakeCalcResult.kowakeSu2 == 0 ? " " : markShiji == true ? " " : String.Format(FORMAT_NUMERIC, kowakeCalcResult.kowakeJuryo2))),
                    new XElement("suKowakeHasu", (kowakeCalcResult.kowakeSu2 == 0 ? " " : markShiji == true ? " " : Convert.ToString(kowakeCalcResult.kowakeSu2)))
            );
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
            if (markShiji == true && cd_mark != "")
            {
                results = " ";
            }
            else if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
            {
                if (cd_mark == ActionConst.MarkCodeSpice)
                {
                    decimal value_LB_GAL = Decimal.Round(ConvertTo_g_From_LB_GAL(value), ActionConst.decimalFormat_LB_GAL);
                    //results = String.Format("{0:#,0.00}", value_LB_GAL);
                    results = String.Format(FORMAT_NUMERIC, value_LB_GAL);
                }
                else
                {
                    //results = String.Format("{0:#,0.00}",value);
                    results = String.Format(FORMAT_NUMERIC, value);
                }
            }
            else
            {
                if (userInfo.kbn_tani == ActionConst.kbn_tani_Kg_L || (userInfo.kbn_tani == "" || userInfo.kbn_tani == string.Empty))
                {
                    if (cd_mark == ActionConst.MarkCodeSpice)
                    {
                        decimal value_Kg_L = Decimal.Round(ConvertTo_g_From_Kg_L(value), ActionConst.decimalFormat_LB_GAL);
                        //results = String.Format("{0:#,0.00}", value_Kg_L);
                        results = String.Format(FORMAT_NUMERIC, value_Kg_L);
                    }
                    else
                    {
                        //results = String.Format("{0:#,0.00}", value);
                        results = String.Format(FORMAT_NUMERIC, value);
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

        /// <summary>
        /// caculator G
        /// </summary>
        /// <param name="soJuryo"></param>
        /// <param name="cd_mark"></param>
        /// <returns></returns>
        private static String CaculatorSoJuryo(decimal value, string cd_mark, decimal? wtNisugata, decimal? suNisugata
                                                       , decimal? wtKowake, decimal? suKowake, decimal? wtKowakeHasu, decimal? suKowakeHasu)
        {
            string results = " ";
            UserController user = new UserController();
            UserInfo userInfo = user.Get();
            //if (markShiji == true){
            if (markShiji == true && cd_mark != ActionConst.MarkCodeLiquid)
            {
                results = " ";
            }
            else if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
            {
                if (cd_mark == ActionConst.MarkCodeSpice)
                {
                    decimal value_LB_GAL_wtNisugata = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(wtNisugata)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_LB_GAL_wtKowake = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(wtKowake)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_LB_GAL_wtKowakeHasu = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(wtKowakeHasu)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_LB_GAL_soJyuryo = Decimal.Round((value_LB_GAL_wtNisugata * Convert.ToDecimal(suNisugata)) + (value_LB_GAL_wtKowake * Convert.ToDecimal(suKowake)) + (value_LB_GAL_wtKowakeHasu * Convert.ToDecimal(suKowakeHasu)), ActionConst.decimalFormat_LB_GAL);
                    //results = String.Format("{0:#,0.00}", value_LB_GAL_soJyuryo);
                    results = String.Format(FORMAT_NUMERIC, value_LB_GAL_soJyuryo);
                }
                else
                {
                    //results = String.Format("{0:#,0.00}", value);
                    results = String.Format(FORMAT_NUMERIC, value);
                }
            }
            else
            {
                if (userInfo.kbn_tani == ActionConst.kbn_tani_Kg_L || (userInfo.kbn_tani == "" || userInfo.kbn_tani == string.Empty))
                {
                    if (cd_mark == ActionConst.MarkCodeSpice)
                    {
                        decimal value_Kg_L_wtNisugata = Decimal.Round(ConvertTo_g_From_Kg_L(Convert.ToDecimal(wtNisugata)), ActionConst.decimalFormat_LB_GAL);
                        decimal value_Kg_L_wtKowake = Decimal.Round(ConvertTo_g_From_Kg_L(Convert.ToDecimal(wtKowake)), ActionConst.decimalFormat_LB_GAL);
                        decimal value_Kg_L_wtKowakeHasu = Decimal.Round(ConvertTo_g_From_Kg_L(Convert.ToDecimal(wtKowakeHasu)), ActionConst.decimalFormat_LB_GAL);
                        decimal value_Kg_L_soJyuryo = Decimal.Round((value_Kg_L_wtNisugata * Convert.ToDecimal(suNisugata)) + (value_Kg_L_wtKowake * Convert.ToDecimal(suKowake)) + (value_Kg_L_wtKowakeHasu * Convert.ToDecimal(suKowakeHasu)), ActionConst.decimalFormat_LB_GAL);
                        //results = String.Format("{0:#,0.00}", value_Kg_L_soJyuryo);
                        results = String.Format(FORMAT_NUMERIC, value_Kg_L_soJyuryo);
                    }
                    else
                    {
                        //results = String.Format("{0:#,0.00}", value);
                        results = String.Format(FORMAT_NUMERIC, value);
                    }
                }
            }
            return results;
        }

        /// <summary>
        /// 単位名の設定処理。
        /// マークPの場合は「ｇ」を、それ以外は検索処理で取得した単位名を設定する。
        /// </summary>
        /// <param name="taniName">検索処理で取得した単位名</param>
        /// <param name="markCode">マークコード</param>
        /// <returns>単位名</returns>
        private string getTaniName(string taniName, string markCode, bool flg_g)
        {
            string ret = taniName;
            if (ActionConst.MarkCodeSpice.Equals(markCode))
            {
                ret = Resources.TaniGram;
            }
            //if (markShiji == true)
            if (markShiji == true && markCode != ActionConst.MarkCodeLiquid)
            {
                ret = " ";
            }
            else {
                if (flg_g == true)
                {
                    ret = Resources.TaniGram;
                }
            }

            return ret;
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

                // 小数桁数の取得
                shosu_keta = (int)shosuKeta;

                // 小分計算区分の設定
                kbn_kowake_futai = kojoInfo.kbn_kowake_futai;

                for (int i = 0; i < shosuKeta; i++)
                {
                    shosubuFormat = shosubuFormat + "0";
                }

                FORMAT_NUMERIC = "{0:#,0." + shosubuFormat + "}";
            }
            else
            {
                // 取得できない場合は小数部3ケタ
                FORMAT_NUMERIC = "{0:#,0.000}";
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