using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using System.Net.Http.Formatting;
using System.Data.SqlClient;
using System.Web.Security;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class LabelInsatsuController : ApiController
	{
        /// <summary>定数：数値フォーマット用文字列</summary>
        private static string FORMAT_NUMERIC = "";
        /// <summary>均等小分け判別用</summary>
        private static short? kbn_kowake_futai = ActionConst.kbnKowakeFutaiSaidai;
        /// <summary>小数桁数</summary>
        private static int shosu_keta = 3;
        
        // GET api/LabelInsatsuController
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<LabelInsatsuResult> Get([FromUri]LabelInsatsuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            //GetShosuKeta(context);
            // 工場マスタから小分計算区分と小数桁数を取得する。
            GetKojoInfo(context);
            // 小数桁数を元にフォーマットを作成する。
            FORMAT_NUMERIC = FoodProcsCommonUtility.CreateSyosuFormat(shosu_keta);
            IEnumerable<usp_LabelInsatsu_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_LabelInsatsu_select(
                    criteria.no_lot_shikakari
                    , short.Parse(criteria.kbn_jotai)
                    , short.Parse(criteria.flg_mishiyo)
                    , ActionConst.Hyphen
                    , ActionConst.KgKanzanKbn
                    , count
                    , short.Parse(Resources.ShikakarihinJotaiKbn)
                    , ActionConst.ShikakariHinKbn   // 品区分：仕掛品
            ).ToList();

            var queryResult = new StoredProcedureResult<LabelInsatsuResult>();
            // 値を計算し、変換
            queryResult.d = createReturnData(views, context);
            queryResult.__count = ((List<usp_LabelInsatsu_select_Result>)views).Count;
            return queryResult;
        }

        // POST 
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<LabelInsatsuCriteria> value)
        {
            string validationMessage = string.Empty;

            // パラメータのチェックを行います。
            if (value == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;

            // トランザクションを開始し、エンティティの変更をデータベースに反映します。
            // 更新処理に失敗した場合、例外が発生し、トランザクションは暗黙的にロールバックされます。
            // 個別でチェック処理を行いロールバックを行う場合には明示的に
            // IDbTransaction インタフェースの Rollback メソッドを呼び出します。
            using (IDbConnection connection = context.Connection)
            {
                context.Connection.Open();
                using (IDbTransaction transaction = context.Connection.BeginTransaction())
                {
                    try
                    {
                        // 変更セットを元に追加対象のエンティティを追加します。
                        if (value.Created != null)
                        {
                            foreach (var created in value.Created)
                            {
                                context.usp_ShikakariKeikakuSummaryLabel_update(created.no_lot_shikakari, ActionConst.FlagTrue, ActionConst.FlagFalse);
                            }
                        }

                        transaction.Commit();
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
                        // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                        return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                    }
                }
            }

            return Request.CreateResponse(HttpStatusCode.OK);
        }

        /// <summary>
        /// 画面への返却値を作成
        /// </summary>
        /// <param name="views">検索結果</param>
        /// <param name="context">エンティティ</param>
        /// <returns>画面に返却するラベル印刷情報</returns>
        private IEnumerable<LabelInsatsuResult> createReturnData(
            IEnumerable<usp_LabelInsatsu_select_Result>views, FoodProcsEntities context)
        {
            // モデルを変換(SP結果⇒Result)
            List<LabelInsatsuResult> res = new List<LabelInsatsuResult>();


            // 変数宣言
            LabelInsatsuResult data;
            int index = ActionConst.CalcNumberZero;
            int lineNo = ActionConst.CalcNumberZero;

            // 計算に利用
            decimal? bairitsu;
            decimal? soJuryo;
            int suNisugata;
            decimal? kowakeJyuryo1;
            int suKowake1;
            decimal? kowakeJyuryo2;
            int suKowake2;
            decimal? budomari;
            decimal? wtNisugata;

            int kbn_tani;

            // 均等小分で使用
            decimal? shikomiJuryo = 0;              // 仕込重量
            decimal nisugataJuryo = 0;              // 荷姿重量
            decimal? kowakeJuryo = 0;               // 小分重量(マスタ)
            string nmTani = String.Empty;           // 単位

            KowakeCalcCriteria kowakeCalcSeikiResult;  // 計算結果(正規)格納用
            KowakeCalcCriteria kowakeCalcHasuResult;   // 計算結果(端数)格納用　

            // 単位区分の取得
            FoodProcsEntities Tani_Context = new FoodProcsEntities();
            var tani = (from ma in Tani_Context.cn_kino_sentaku
                        where ma.kbn_kino == ActionConst.kbn_kino_kbn_tani 
                        select ma).FirstOrDefault();
            if (tani == null)
            {
                kbn_tani = 0;
            }
            else
            {
                kbn_tani = tani.kbn_kino_naiyo;
            }
            
            foreach (var list in views.ToList<usp_LabelInsatsu_select_Result>())
            {

                // マークが『作業、の場合はラベル不要
                if (list.kbn_shubetsu != null && !ActionConst.MarkShubetsuH.Equals(list.kbn_shubetsu) //作業系
                                              && !ActionConst.MarkShubetsuA.Equals(list.kbn_shubetsu) //撹拌
                                              && !ActionConst.MarkShubetsuL.Equals(list.kbn_shubetsu) //液体 　
                        )
                {

                    wtNisugata = list.wt_nisugata == null ? 0 : (decimal)list.wt_nisugata;

                    // 返却用のリストへ格納
                    data = new LabelInsatsuResult();

                    // 画面返却用のデータを格納
                    // ラベル内に反映されるコード
                    data.cd_haigo = list.cd_shikakari_hin;
                    data.kbn_hin = list.kbn_hin;
                    data.cd_team = string.Empty; // チームコード
                    data.cd_shokbua = list.cd_shokuba;
                    data.cd_line = list.cd_line;
                    data.no_lot_shikakari = list.no_lot_shikakari;
                    data.cd_hinmei = list.cd_hinmei;
                    data.nm_hinmei = list.nm_hinmei;
                    data.nm_hinmei_ja = list.nm_hinmei;
                    data.nm_hinmei_en = list.nm_hinmei;
                    data.nm_hinmei_zh = list.nm_hinmei;
                    data.nm_hinmei_vi = list.nm_hinmei;
                    data.nm_hinmei_ryaku = list.nm_hinmei_ryaku;
                    data.no_kotei = list.no_kotei;
                    data.cd_mark = list.cd_mark;
                    data.nm_mark = list.nm_mark;

                    //下に移動
//                    if (list.cd_mark == "10")
//                    {
//                        data.nm_tani = "g";
//                    }
//                    else {
//                        data.nm_tani = list.nm_tani;
//                    }

                    //data.nm_tani = list.nm_tani;
                    data.wt_kihon = list.wt_kihon;
                    data.no_tonyu = list.no_tonyu;
                    //data.wt_nisugata = CaculatorG(Convert.ToDecimal(list.wt_nisugata), data.cd_mark);
                    data.wt_nisugata = Convert.ToDecimal(list.wt_nisugata);
                    data.wt_nisugata_hasu = Convert.ToDecimal(list.wt_nisugata);
                    data.dt_seizo = list.dt_seizo;
                    data.no_han = list.no_han;
                    data.kbnAllergy = list.kbnAllergy;
                    data.nm_Allergy = list.nm_Allergy;
                    data.kbnOther = list.kbnOther;
                    data.nm_Other = list.nm_Other;
                    budomari = list.ritsu_budomari_recipe;
                    // 歩留まりが設定されていなかったらデフォルトで100を設定
                    budomari = (budomari == null || budomari == ActionConst.CalcDefaultNumberInt) ? budomari = Convert.ToInt32(Resources.persentKanzan) : budomari;

                    // 最大小分
                    if (kbn_kowake_futai == ActionConst.kbnKowakeFutaiSaidai)
                    {
                        //液体原料の場合、比重から重量換算
                        if (list.nm_tani == Resources.TaniCodeL)
                        {
                            list.wt_shikomi = list.wt_shikomi * list.ritsu_hiju_recipe;
                        }
                    
                        //// 正規計算 ////
                        // 正規の計画をセット
                        data.su_batch_keikaku = list.su_batch_keikaku;
                        data.ritsu_keikaku = list.ritsu_keikaku;
                        if (list.su_batch_keikaku > ActionConst.CalcNumberZero)
                        {
                            bairitsu = list.ritsu_keikaku;
                            // 重量の計算　個々のレシピ重量×(配合重量/レシピ合計)
                            //soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, bairitsu);
                            soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, list.haigo_bairitsu);
                            soJuryo = soJuryo / list.su_batch_keikaku;
                            //data.wt_haigo = CaculatorG(Convert.ToDecimal(soJuryo), data.cd_mark); // 総重量(正規）
                            data.wt_haigo = Convert.ToDecimal(soJuryo); // 総重量(正規）
                            //suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, list.wt_nisugata));
                            suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wtNisugata));
                            kowakeJyuryo1 = FoodProcsCalculator.calKowake1Jyuryo(list.wt_kowake_recipe, list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);
                            //suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1Su(soJuryo, list.wt_nisugata, suNisugata, kowakeJyuryo1));
                            suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1Su(soJuryo, wtNisugata, suNisugata, kowakeJyuryo1));
                            //kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(soJuryo, list.wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1);
                            kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(soJuryo, wtNisugata, suNisugata, kowakeJyuryo1, suKowake1);
                            suKowake2 = (int)FoodProcsCalculator.calKowake2Su(kowakeJyuryo2);

                            // 小分数1が0ならば小分重量1を0にする
                            if (suKowake1 == 0)
                            {
                                kowakeJyuryo1 = 0;
                            }

                            ////表記はkg・gに統一
                            //if (list.cd_mark == Resources.MarkCodeSpice)
                            //{
                            //    data.nm_tani = Resources.TaniCodeG;
                            //}
                            //else
                            //{
                            //    data.nm_tani = Resources.TaniCodeKg;
                            //}

                            //表記はLB・kg・gに統一
                            //data.nm_tani =  ConvertTani(data.cd_mark, kbn_tani.ToString());

                            //単位チェック
                            //data.nm_tani = ConvertTani(kbn_tani.ToString(), data.cd_mark, soJuryo, list.wt_nisugata, kowakeJyuryo1, kowakeJyuryo2);
                            //data.nm_tani = ConvertTani(kbn_tani.ToString(), data.cd_mark, soJuryo, wtNisugata, kowakeJyuryo1, kowakeJyuryo2);
                            data.nm_tani = ConvertTani(kbn_tani.ToString(), data.cd_mark, soJuryo, wtNisugata, kowakeJyuryo1, suKowake1, kowakeJyuryo2);

                            //単位がgの場合
                            if (data.nm_tani == Resources.TaniCodeG)
                            {
                                //マークPの場合
                                if (data.cd_mark == ActionConst.MarkCodeSpice)
                                {
                                    //秤量記録表、配合チェック表の処理に合わせて総重量を別で計算する。
                                    data.wt_haigo = Caculator_soJyuryo(
                                    Convert.ToDecimal(soJuryo), wtNisugata, suNisugata, kowakeJyuryo1, suKowake1, kowakeJyuryo2, suKowake2);
                                    data.wt_nisugata = CaculatorG(Convert.ToDecimal(wtNisugata), data.nm_tani);
                                    kowakeJyuryo1 = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.nm_tani);
                                    kowakeJyuryo2 = CaculatorG(Convert.ToDecimal(kowakeJyuryo2), data.nm_tani);
                                }
                                else
                                {
                                    //配合重量、荷姿重量をg変換して小分重量２を計算する
                                    //data.wt_haigo = CaculatorG(Convert.ToDecimal(soJuryo), data.nm_tani);
                                    data.wt_haigo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(soJuryo));
                                    //data.wt_nisugata = CaculatorG(Convert.ToDecimal(wtNisugata), data.nm_tani);
                                    data.wt_nisugata = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(wtNisugata));
                                    //kowakeJyuryo1 = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.nm_tani);
                                    kowakeJyuryo1 = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJyuryo1));
                                    kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(
                                        data.wt_haigo, data.wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1);
                                }
                            }

                            // 荷姿重量が0ではなく荷姿重量と配合重量2が等しいなら小分数を荷姿数にマージする
                            if (data.wt_nisugata != 0 && String.Format(FORMAT_NUMERIC, data.wt_nisugata)
                                == String.Format(FORMAT_NUMERIC, kowakeJyuryo2))
                            {
                                suNisugata += suKowake2;
                                kowakeJyuryo2 = 0;
                                suKowake2 = 0;
                            }

                            // 計算項目(正規分）を格納
                            data.su_nisugata_kowake_seiki = suNisugata;
                            //data.wt_kowake1_seiki = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.cd_mark);
                            //data.wt_kowake1_seiki = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.nm_tani);
                            data.wt_kowake1_seiki = kowakeJyuryo1;
                            data.su_kowake1_kowake_seiki = suKowake1;
                            //data.wt_kowake2_seiki = CaculatorG(Convert.ToDecimal(kowakeJyuryo2), data.cd_mark);
                            data.wt_kowake2_seiki = kowakeJyuryo2;
                            data.su_kowake2_kowake_seiki = suKowake2;

                            // 空をセット
                            data.cd_futai1_seiki = string.Empty;
                            data.nm_futai1_seiki = string.Empty;
                            data.cd_futai2_seiki = string.Empty;
                            data.nm_futai2_seiki = string.Empty;

                            // 風袋があった場合、適切な風袋を選択
                            if (list.nm_futai != null)
                            {
                                // レシピに登録されている風袋を採用
                                data.cd_futai1_seiki = list.cd_futai;
                                data.nm_futai1_seiki = list.nm_futai;
                                data.cd_futai2_seiki = list.cd_futai;
                                data.nm_futai2_seiki = list.nm_futai;
                            }
                            else if (list.futaiCnt > ActionConst.CalcNumberZero)
                            {
                                // 風袋決定の登録があれば一件選択
                                // 小分け重量１
                                vw_ma_futai_kettei_01 futai = getAppropriateFutai(context, list.cd_hinmei, list.cd_tani_shiyo, kowakeJyuryo1);
                                // 風袋名をセット
                                if (futai != null)
                                {
                                    data.cd_futai1_seiki = futai.cd_futai;
                                    data.nm_futai1_seiki = futai.nm_futai;
                                }

                                // 小分け重量２
                                futai = getAppropriateFutai(context, list.cd_hinmei, list.cd_tani_shiyo, kowakeJyuryo2);
                                if (futai != null)
                                {
                                    data.cd_futai2_seiki = futai.cd_futai;
                                    data.nm_futai2_seiki = futai.nm_futai;
                                }
                            }
                        }

                        // 端数の計画をセット
                        data.su_batch_keikaku_hasu = list.su_batch_keikaku_hasu;
                        data.ritsu_keikaku_hasu = list.ritsu_keikaku_hasu;
                        if (list.su_batch_keikaku_hasu > ActionConst.CalcNumberZero)
                        {
                            // 必要な情報を計算
                            bairitsu = list.su_batch_keikaku_hasu;
                            soJuryo = FoodProcsCalculator.calHiritsuSoJyuryoLabel(list.wt_shikomi, list.haigo_bairitsu_hasu);
                            //data.wt_haigo_hasu = CaculatorG(Convert.ToDecimal(soJuryo), data.cd_mark);// 総重量（端数）
                            data.wt_haigo_hasu = soJuryo;// 総重量（端数）
                            //suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, list.wt_nisugata));
                            suNisugata = (int)Math.Floor(FoodProcsCalculator.calNisugataSu(soJuryo, wtNisugata));
                            kowakeJyuryo1 = FoodProcsCalculator.calKowake1Jyuryo(list.wt_kowake_recipe, list.wt_kowake_juryo_hin, list.wt_kowake_juryo_jyotai);
                            //suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1Su(soJuryo, list.wt_nisugata, suNisugata, kowakeJyuryo1));
                            suKowake1 = (int)Math.Floor(FoodProcsCalculator.calKowake1Su(soJuryo, wtNisugata, suNisugata, kowakeJyuryo1));
                            //kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(soJuryo, list.wt_nisugata, suNisugata, kowakeJyuryo1, suKowake1);
                            kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(soJuryo, wtNisugata, suNisugata, kowakeJyuryo1, suKowake1);
                            suKowake2 = (int)Math.Floor(FoodProcsCalculator.calKowake2Su(kowakeJyuryo2));

                            // 小分数1が0ならば小分重量1を0にする
                            if (suKowake1 == 0)
                            {
                                kowakeJyuryo1 = 0;
                            }

                            // 空をセット
                            data.cd_futai1_hasu = string.Empty;
                            data.nm_futai1_hasu = string.Empty;
                            data.cd_futai2_hasu = string.Empty;
                            data.nm_futai2_hasu = string.Empty;
                            // 風袋があった場合、適切な風袋を選択
                            if (list.nm_futai != null)
                            {
                                // レシピに登録されている風袋を採用
                                data.cd_futai1_hasu = list.cd_futai;
                                data.nm_futai1_hasu = list.nm_futai;
                                data.cd_futai2_hasu = list.cd_futai;
                                data.nm_futai2_hasu = list.nm_futai;
                            }
                            else if (list.futaiCnt > ActionConst.CalcNumberZero)
                            {
                                // 風袋決定の登録があれば一件選択
                                vw_ma_futai_kettei_01 futai = getAppropriateFutai(context, list.cd_hinmei, list.cd_tani_shiyo, kowakeJyuryo2);
                                // 風袋名をセット
                                if (futai != null)
                                {
                                    data.cd_futai1_hasu = futai.cd_futai;
                                    data.nm_futai1_hasu = futai.nm_futai;
                                }

                                // 小分け重量２
                                futai = getAppropriateFutai(context, list.cd_hinmei, list.cd_tani_shiyo, kowakeJyuryo2);
                                if (futai != null)
                                {
                                    data.cd_futai2_hasu = futai.cd_futai;
                                    data.nm_futai2_hasu = futai.nm_futai;
                                }
                            }

                            //単位（端数）チェック
                            //data.nm_tani_hasu = ConvertTani(kbn_tani.ToString(), data.cd_mark, soJuryo, list.wt_nisugata, kowakeJyuryo1, kowakeJyuryo2);
                            //data.nm_tani_hasu = ConvertTani(kbn_tani.ToString(), data.cd_mark, soJuryo, wtNisugata, kowakeJyuryo1, kowakeJyuryo2);
                            data.nm_tani_hasu = ConvertTani(kbn_tani.ToString(), data.cd_mark, soJuryo, wtNisugata, kowakeJyuryo1, suKowake1, kowakeJyuryo2);

                            //単位（端数）がgの場合
                            if (data.nm_tani_hasu == Resources.TaniCodeG)
                            {
                                //マークPの場合
                                if (data.cd_mark == ActionConst.MarkCodeSpice)
                                {
                                    //秤量記録表、配合チェック表の処理に合わせて総重量を別で計算する。
                                    data.wt_haigo_hasu = Caculator_soJyuryo(
                                    Convert.ToDecimal(soJuryo), wtNisugata, suNisugata, kowakeJyuryo1, suKowake1, kowakeJyuryo2, suKowake2);
                                    data.wt_nisugata_hasu = CaculatorG(Convert.ToDecimal(wtNisugata), data.nm_tani_hasu);
                                    kowakeJyuryo1 = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.nm_tani_hasu);
                                    kowakeJyuryo2 = CaculatorG(Convert.ToDecimal(kowakeJyuryo2), data.nm_tani_hasu);
                                }
                                else
                                {
                                    //配合重量、荷姿重量をg変換して小分重量２を計算する
                                    //data.wt_haigo_hasu = CaculatorG(Convert.ToDecimal(soJuryo), data.nm_tani_hasu);
                                    data.wt_haigo_hasu = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(soJuryo));
                                    //data.wt_nisugata_hasu = CaculatorG(Convert.ToDecimal(wtNisugata), data.nm_tani_hasu);
                                    data.wt_nisugata_hasu = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(wtNisugata));
                                    //kowakeJyuryo1 = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.nm_tani);
                                    kowakeJyuryo1 = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJyuryo1));
                                    kowakeJyuryo2 = FoodProcsCalculator.calKowake2Jyuryo(
                                        data.wt_haigo_hasu, data.wt_nisugata_hasu, suNisugata, kowakeJyuryo1, suKowake1);
                                }
                            }

                            // 荷姿重量が0ではなく荷姿重量と配合重量2が等しいなら小分数を荷姿数にマージする
                            if (data.wt_nisugata_hasu != 0 && String.Format(FORMAT_NUMERIC, data.wt_nisugata_hasu) == String.Format(FORMAT_NUMERIC, kowakeJyuryo2))
                            {
                                suNisugata += suKowake2;
                                kowakeJyuryo2 = 0;
                                suKowake2 = 0;
                            }

                            // 計算項目（端数分）を格納
                            data.su_nisugata_kowake_hasu = suNisugata;
                            //data.wt_kowake1_hasu = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.cd_mark);
                            //data.wt_kowake1_hasu = CaculatorG(Convert.ToDecimal(kowakeJyuryo1), data.nm_tani_hasu);
                            data.wt_kowake1_hasu = kowakeJyuryo1;
                            data.su_kowake1_kowake_hasu = suKowake1;
                            //data.wt_kowake2_hasu = CaculatorG(Convert.ToDecimal(kowakeJyuryo2), data.cd_mark);
                            data.wt_kowake2_hasu = kowakeJyuryo2;
                            data.su_kowake2_kowake_hasu = suKowake2;
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
                        if (nmTani == Resources.TaniCodeL)
                        {
                            // 単位をKgにする
                            nmTani = Resources.TaniCodeKg;

                            // 仕込重量をKg換算する
                            shikomiJuryo = shikomiJuryo * list.ritsu_hiju_recipe;

                        }

                        // 荷姿重量
                        nisugataJuryo = Convert.ToDecimal(wtNisugata);

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
                            if (kbn_tani.ToString() == ActionConst.kbn_tani_LB_GAL)
                            {
                                shikomiJuryo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(shikomiJuryo));
                                nisugataJuryo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(nisugataJuryo));
                                kowakeJuryo = ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJuryo));
                            }
                            // 使用単位がkg・Lの場合
                            else
                            {
                                shikomiJuryo = ConvertTo_gFrom_Kg_L(Convert.ToDecimal(shikomiJuryo));
                                nisugataJuryo = ConvertTo_gFrom_Kg_L(Convert.ToDecimal(nisugataJuryo));
                                kowakeJuryo = ConvertTo_gFrom_Kg_L(Convert.ToDecimal(kowakeJuryo));
                            }
                        }

                        // 正規計算
                        if (list.haigo_bairitsu > ActionConst.CalcNumberZero)
                        {
                            // 計算結果格納オブジェクト
                            kowakeCalcSeikiResult = new KowakeCalcCriteria(shikomiJuryo, nisugataJuryo ,kowakeJuryo, nmTani);

                            // 均等小分
                            CaculatorKinto(kowakeCalcSeikiResult, list.ritsu_keikaku);

                            // 補足計算
                            SupplementaryCalculation(kowakeCalcSeikiResult, list.cd_mark, kbn_tani.ToString());

                            // 風袋設定
                            SetFutai(context, list, kowakeCalcSeikiResult);

                            // 計算項目(正規分）を格納
                            data.nm_tani = kowakeCalcSeikiResult.nmtani;
                            data.su_batch_keikaku = list.su_batch_keikaku;
                            data.ritsu_keikaku = list.ritsu_keikaku;
                            data.wt_haigo = kowakeCalcSeikiResult.soJuryo;
                            data.wt_nisugata = kowakeCalcSeikiResult.nisugataJuryo;
                            data.su_nisugata_kowake_seiki = kowakeCalcSeikiResult.nisugataSu;
                            data.wt_kowake1_seiki = kowakeCalcSeikiResult.kowakeJuryo1;
                            data.su_kowake1_kowake_seiki = kowakeCalcSeikiResult.kowakeSu1;
                            data.wt_kowake2_seiki = kowakeCalcSeikiResult.kowakeJuryo2;
                            data.su_kowake2_kowake_seiki = kowakeCalcSeikiResult.kowakeSu2;
                            data.cd_futai1_seiki = kowakeCalcSeikiResult.cdFutai1;
                            data.nm_futai1_seiki = kowakeCalcSeikiResult.nmFutai1;
                            data.cd_futai2_seiki = kowakeCalcSeikiResult.cdFutai2;
                            data.nm_futai2_seiki = kowakeCalcSeikiResult.nmFutai2;
                        }

                        // 端数計算
                        if (list.haigo_bairitsu_hasu > ActionConst.CalcNumberZero)
                        {
                            // 計算結果格納オブジェクト
                            kowakeCalcHasuResult = new KowakeCalcCriteria(shikomiJuryo, nisugataJuryo ,kowakeJuryo, nmTani);

                            // 均等小分
                            CaculatorKinto(kowakeCalcHasuResult, list.ritsu_keikaku_hasu);

                            // 補足計算
                            SupplementaryCalculation(kowakeCalcHasuResult, list.cd_mark, kbn_tani.ToString());

                            // 風袋設定
                            SetFutai(context, list, kowakeCalcHasuResult);

                            // 計算項目(端数分）を格納
                            data.nm_tani_hasu = kowakeCalcHasuResult.nmtani;
                            data.su_batch_keikaku_hasu = list.su_batch_keikaku_hasu;
                            data.ritsu_keikaku_hasu = list.ritsu_keikaku_hasu;
                            data.wt_haigo_hasu = kowakeCalcHasuResult.soJuryo;
                            data.wt_nisugata_hasu = kowakeCalcHasuResult.nisugataJuryo;
                            data.su_nisugata_kowake_hasu = kowakeCalcHasuResult.nisugataSu;
                            data.wt_kowake1_hasu = kowakeCalcHasuResult.kowakeJuryo1;
                            data.su_kowake1_kowake_hasu = kowakeCalcHasuResult.kowakeSu1;
                            data.wt_kowake2_hasu = kowakeCalcHasuResult.kowakeJuryo2;
                            data.su_kowake2_kowake_hasu = kowakeCalcHasuResult.kowakeSu2;
                            data.cd_futai1_hasu = kowakeCalcHasuResult.cdFutai1;
                            data.nm_futai1_hasu = kowakeCalcHasuResult.nmFutai1;
                            data.cd_futai2_hasu = kowakeCalcHasuResult.cdFutai2;
                            data.nm_futai2_hasu = kowakeCalcHasuResult.nmFutai2;
                        }
                    }
                    // 返却リストに格納
                    res.Insert(lineNo, data);
                    lineNo++;
                } // マーク判定
                index++;
            }

            return res;
        }

        /// <summary>
        /// 風袋マスタチェック
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="cd_hinmei">品名コード</param>
        /// <param name="tani">単位コード</param>
        /// <param name="jyuryo">小分け重量</param>
        /// <returns>利用最低な風袋</returns>
        private vw_ma_futai_kettei_01 getAppropriateFutai(FoodProcsEntities context, string cd_hinmei, string tani, decimal? jyuryo)
        {
            // 利用最低な風袋を選択
            return (from cntx in context.vw_ma_futai_kettei_01
                    orderby cntx.wt_kowake
                    where cntx.cd_hinmei == cd_hinmei
                       && cntx.cd_tani == tani
                       && cntx.flg_mishiyo == ActionConst.FlagFalse
                       && cntx.wt_kowake >= jyuryo
                    select cntx
                    ).FirstOrDefault();
        }

        /// <summary>
        /// caculator G
        /// </summary>
        /// <param name="value"></param>
        /// <param name="nm_tani"></param>
        ///// <param name="soJuryo"></param>
        ///// <param name="cd_mark"></param>
        /// <returns></returns>
        //private static decimal CaculatorG(decimal value, string cd_mark)
        private decimal CaculatorG(decimal value, string nm_tani)
        {
            decimal results = 0;
            UserController user = new UserController();
            UserInfo userInfo = user.Get();

            // 単位区分が「LB・GAL」のとき(Q&Bのとき)の換算チェック
            if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
            {
                //if (cd_mark == ActionConst.MarkCodeSpice)

                // 単位がgの場合
                if (nm_tani == Resources.TaniCodeG)
                {
                    //「LB・GAL」の値をgの値に変換する
                    results = Decimal.Round(ConvertTo_g_From_LB_GAL(value), ActionConst.decimalFormat_LB_GAL);
                }
                else
                {
                    // 変換せずに値を返す
                    results = value;
                }
            }
            //単位区分が「kg・L」のとき(KPMのとき)の換算チェック
            else
            {
                if (userInfo.kbn_tani == ActionConst.kbn_tani_Kg_L || (userInfo.kbn_tani == "" || userInfo.kbn_tani == string.Empty))
                {
                    // 単位がgの場合
                    if (nm_tani == Resources.TaniCodeG)
                    {
                        //if (cd_mark == ActionConst.MarkCodeSpice)
                        //{
                        //    results = Decimal.Round(ConvertTo_gFrom_Kg_L(value), ActionConst.decimalFormat_LB_GAL);
                        //}
                        //else
                        //{
                        //    results = value;
                        //}

                        //「kg・L」の値をgの値に変換する
                        results = Decimal.Round(ConvertTo_gFrom_Kg_L(value), ActionConst.decimalFormat_LB_GAL);
                    }
                    else
                    {
                        // 変換せずに値を返す
                        results = value;
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

        private static decimal ConvertTo_gFrom_Kg_L(decimal value)
        {
            //1kg = 1000g; 
            return value * Convert.ToDecimal(ActionConst.unit_Kg_L);
        }

        /// <summary>
        /// Convert unit  to LB,kg,g 
        /// </summary>
        /// <param name="kbn_tani"></param>
        /// <param name="cd_mark"></param>
        /// <param name="soJuryo"></param>
        /// <param name="wt_nisugata"></param>
        /// <param name="kowakeJyuryo1"></param>
        /// <param name="suKowake1"></param>
        /// <param name="kowakeJyuryo2"></param>
        /// <returns></returns>
        //private static string ConvertTani(string cd_mark, string kbn_tani)
        //private string ConvertTani(string kbn_tani, string cd_mark, decimal? soJuryo, decimal? wt_nisugata
                       //, decimal? kowakeJyuryo1, decimal? kowakeJyuryo2)
        private string ConvertTani(string kbn_tani, string cd_mark, decimal? soJuryo, decimal? wt_nisugata,
                                    decimal? kowakeJyuryo1, int suKowake1, decimal? kowakeJyuryo2)
        {
            string results = "";

            if (kbn_tani == ActionConst.kbn_tani_LB_GAL)
            {
                //if (cd_mark == ActionConst.MarkCodeSpice)

                // マークがスパイス(cd_mark = 10)で、
                // 総重量、荷姿重量、小分重量１、小分重量２のいずれかが0より大きく1未満の場合、単位をグラムにする
                //if (cd_mark == ActionConst.MarkCodeSpice
                //    || CheckJuryo(soJuryo)
                //    || CheckJuryo(wt_nisugata)
                //    || CheckJuryo(kowakeJyuryo1)
                //    || CheckJuryo(kowakeJyuryo2))
                //{
                //    results = Resources.TaniCodeG;

                //}

                // マークがスパイス(cd_mark = 10)の場合
                // 荷姿重量 = 0かつ小分回数1 = 0かつ総重量が0より大きく1未満の場合
                // 荷姿重量 = 0かつ小分回数1 = 0かつ小分重量2が0より大きく1未満の場合
                if ((cd_mark == ActionConst.MarkCodeSpice)
                    || (wt_nisugata == 0 && suKowake1 == 0 && (CheckJuryo(soJuryo) || CheckJuryo(kowakeJyuryo2))))
                {
                    // 単位をグラムにする
                    results = Resources.TaniCodeG;
                }

                // 重量をLBにする
                else
                {
                    results = Resources.TaniCodeLB;
                }
            }
            //単位区分が「kg・L」のとき(KPMのとき)の換算チェック
            else
            {
                // マークがスパイス(cd_mark = 10)の場合
                if (cd_mark == ActionConst.MarkCodeSpice)

                // マークがスパイス(cd_mark = 10)で、
                // 総重量、荷姿重量、小分重量１、小分重量２のいずれかが0より大きく1未満の場合、重量をgにする
                //if (cd_mark == ActionConst.MarkCodeSpice
                    //|| CheckJuryo(soJuryo)
                    //|| CheckJuryo(wt_nisugata)
                    //|| CheckJuryo(kowakeJyuryo1)
                    //|| CheckJuryo(kowakeJyuryo2)
                    //)
                {
                    results = Resources.TaniCodeG;
                }
                // マークがスパイス(cd_mark = 10)以外の場合
                else
                {
                    results = Resources.TaniCodeKg;
                }
            }
            return results;
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
        /// Caculator_soJyuryo
        /// </summary>
        /// <param name="soJuryo"></param>
        /// <param name="cd_mark"></param>
        /// <returns></returns>
        private static decimal Caculator_soJyuryo(decimal value, decimal? nisugataJuryo, decimal? suNisugata, decimal? kowakeJyuryo1
                                                , decimal? suKowake1, decimal? kowakeJyuryo2, decimal? suKowake2)
        {
            decimal results = 0;
            UserController user = new UserController();
            UserInfo userInfo = user.Get();
            if (userInfo.kbn_tani == ActionConst.kbn_tani_LB_GAL)
            {
                decimal value_LB_GAL_nisugataJuryo = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(nisugataJuryo)), ActionConst.decimalFormat_LB_GAL);
                decimal value_LB_GAL_kowakeJyuryo1 = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJyuryo1)), ActionConst.decimalFormat_LB_GAL);
                decimal value_LB_GAL_kowakeJyuryo2 = Decimal.Round(ConvertTo_g_From_LB_GAL(Convert.ToDecimal(kowakeJyuryo2)), ActionConst.decimalFormat_LB_GAL);
                decimal value_LB_GAL_soJyuryo = Decimal.Round((value_LB_GAL_nisugataJuryo * Convert.ToDecimal(suNisugata)) + (value_LB_GAL_kowakeJyuryo1 * Convert.ToDecimal(suKowake1)) + (value_LB_GAL_kowakeJyuryo2 * Convert.ToDecimal(suKowake2)), ActionConst.decimalFormat_LB_GAL);

                results = value_LB_GAL_soJyuryo;
            }
            else
            {
                if (userInfo.kbn_tani == ActionConst.kbn_tani_Kg_L || (userInfo.kbn_tani == "" || userInfo.kbn_tani == string.Empty))
                {
                 
                    decimal value_Kg_L_nisugataJuryo = Decimal.Round(ConvertTo_gFrom_Kg_L(Convert.ToDecimal(nisugataJuryo)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_Kg_L_kowakeJyuryo1 = Decimal.Round(ConvertTo_gFrom_Kg_L(Convert.ToDecimal(kowakeJyuryo1)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_Kg_L_kowakeJyuryo2 = Decimal.Round(ConvertTo_gFrom_Kg_L(Convert.ToDecimal(kowakeJyuryo2)), ActionConst.decimalFormat_LB_GAL);
                    decimal value_Kg_L_soJyuryo = Decimal.Round((value_Kg_L_nisugataJuryo * Convert.ToDecimal(suNisugata)) + (value_Kg_L_kowakeJyuryo1 * Convert.ToDecimal(suKowake1)) + (value_Kg_L_kowakeJyuryo2 * Convert.ToDecimal(suKowake2)), ActionConst.decimalFormat_LB_GAL);
                        
                    results = value_Kg_L_soJyuryo;
                }
            }
            return results;
        }

        /// <summary>
        /// 均等小分計算を行います。
        /// </summary>
        /// <param name="kowakeCalcResult"></param>
        /// <param name="bairitsu"></param>
        private void CaculatorKinto(KowakeCalcCriteria kowakeCalcResult,　decimal? bairitsu)
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
                // 単位をgにして総重量、小分重量1、小分重量2をg換算する
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

        /// <summary>
        /// 風袋設定を行います。
        /// </summary>
        /// <param name="context"></param>
        /// <param name="list"></param>
        /// <param name="kowakeCalcResult"></param>
        private void SetFutai(FoodProcsEntities context, usp_LabelInsatsu_select_Result list, KowakeCalcCriteria kowakeCalcResult)
        {
            // レシピに風袋が設定してあった場合
            if (list.nm_futai != null)
            {
                // レシピに登録されている風袋を採用
                kowakeCalcResult.cdFutai1 = list.cd_futai;
                kowakeCalcResult.nmFutai1 = list.nm_futai;
                kowakeCalcResult.cdFutai2 = list.cd_futai;
                kowakeCalcResult.nmFutai2 = list.nm_futai;
            }
            // 風袋決定マスタに対象原料の風袋が登録されている場合
            else if (list.futaiCnt > ActionConst.CalcNumberZero)
            {
                // 風袋決定の登録があれば一件選択
                // 小分け重量１
                vw_ma_futai_kettei_01 futai1 = getAppropriateFutai(context, list.cd_hinmei, list.cd_tani_shiyo, kowakeCalcResult.kowakeJuryo1);
                // 風袋名をセット
                if (futai1 != null)
                {
                    kowakeCalcResult.cdFutai1 = futai1.cd_futai;
                    kowakeCalcResult.nmFutai1 = futai1.nm_futai;
                }

                // 小分け重量２
                vw_ma_futai_kettei_01 futai2 = getAppropriateFutai(context, list.cd_hinmei, list.cd_tani_shiyo, kowakeCalcResult.kowakeJuryo2);
                if (futai2 != null)
                {
                    kowakeCalcResult.cdFutai2 = futai2.cd_futai;
                    kowakeCalcResult.nmFutai2 = futai2.nm_futai;
                }
            }
        }
    }
}