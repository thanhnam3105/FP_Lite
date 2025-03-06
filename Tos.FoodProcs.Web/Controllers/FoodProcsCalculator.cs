using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Properties;
using Newtonsoft.Json.Linq;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
    public static class FoodProcsCalculator
    {

        /// <summary>
        /// サマリのデータ計算
        /// <param name="data"> 材料が入って且つ計算結果を保持するクラス</param>
        /// <param name="bairitsuList"> </param>
        /// <param name="gKihonBairitsu"> </param>
        /// <param name="gGokeiHaigoJuryo"> </param>
        /// </summary>
        ////
        public static void calcSummaryData(RecipeTenkaiObject data, usp_RecipeTenkai_ma_haigo_mei_select_Result val)
        {
            // 必要な材料
            // 換算区分（配合名マスタ）
            //String kanzanKubunHaigo = data.haigoKanzanKubun.ToString();
            // 基本倍率（配合名マスタ）
            decimal kihonBairitsu = val.ritsu_kihon == null  ? ActionConst.CalcDefaultNumber : (Decimal)val.ritsu_kihon;
            // 合計配合重量
            decimal gokeiHaigoJuryo = val.wt_haigo_gokei == null ? ActionConst.CalcDefaultNumber : (Decimal)val.wt_haigo_gokei;

            // 結果
            // 製造予定量
            decimal hitsuyoJuryo = data.hitsuyoJuryo;
            // 計画倍率
            decimal keikakuBairitsu = ActionConst.CalcDefaultNumber;
            // 計画倍率端数
            decimal keikakuBairitsuHasu = ActionConst.CalcDefaultNumber;
            // 計画配合重量
            decimal keikakuHaigoJuryo = ActionConst.CalcDefaultNumber;
            // 計画配合重量端数
            decimal keikakuHaigoJuryoHasu = ActionConst.CalcDefaultNumber;
            // 計画バッチ数
            decimal keikakuBatchSu = ActionConst.CalcDefaultNumber;
            // 計画バッチ数端数
            decimal keikakuBatchSuHasu = ActionConst.CalcDefaultNumber;
            // 計画仕込重量
            decimal keikakuShikomiJuryo = ActionConst.CalcDefaultNumber;

            // 演算処理
            if (kihonBairitsu != ActionConst.CalcDefaultNumber && gokeiHaigoJuryo != ActionConst.CalcDefaultNumber)
            {
                keikakuBatchSu = Math.Truncate(hitsuyoJuryo / (gokeiHaigoJuryo * kihonBairitsu));
            }
            keikakuBairitsu = kihonBairitsu;
            keikakuHaigoJuryo = gokeiHaigoJuryo * kihonBairitsu * keikakuBatchSu;
            keikakuHaigoJuryoHasu = hitsuyoJuryo - keikakuHaigoJuryo;
            if (gokeiHaigoJuryo != ActionConst.CalcDefaultNumber)
            {
                //keikakuBairitsuHasu = Math.Ceiling(keikakuHaigoJuryoHasu / gokeiHaigoJuryo * 1000000m) / 1000000m;
                keikakuBairitsuHasu = Math.Ceiling(keikakuHaigoJuryoHasu / gokeiHaigoJuryo * 1000m) / 1000m;
            }
            // 端数があれば１。なければ０
            if (keikakuHaigoJuryoHasu != ActionConst.CalcDefaultNumber)
            {
                keikakuBatchSuHasu = ActionConst.BatchHasuAri;
            }
            else
            {
                keikakuBatchSuHasu = ActionConst.CalcDefaultNumber;
            }
            keikakuShikomiJuryo = gokeiHaigoJuryo * keikakuBairitsu * keikakuBatchSu +
                gokeiHaigoJuryo * keikakuBairitsuHasu * keikakuBatchSuHasu;

/**
            // 必要量はNULLの時のみセット
            if (data.hitsuyoJuryo == ActionConst.CalcDefaultNumber)
            {
                //data.hitsuyoJuryo = seizoYoteiRyo;
            }
*/

            // 倍率（端数）が倍率（正規）と等しくなった場合は、端数バッチを正規バッチにマージする。
            if (keikakuBairitsu == keikakuBairitsuHasu)
            {
                // 正規バッチ数は正規バッチ数と端数バッチ数の合計
                keikakuBatchSu = keikakuBatchSu + keikakuBatchSuHasu;
                // 端数バッチ数は0にする
                keikakuBatchSuHasu = ActionConst.CalcDefaultNumber;
                // 端数倍率は0にする。（正規倍率は変わらない）
                keikakuBairitsuHasu = ActionConst.CalcDefaultNumber;
                // 配合重量は必要重量全部になる。
                keikakuHaigoJuryo = hitsuyoJuryo;
                // 配合重量（端数）は0になる。
                keikakuHaigoJuryoHasu = ActionConst.CalcDefaultNumber;
            }

            data.keikakuBairitsu = keikakuBairitsu;
            data.keikakuBairitsuHasu = keikakuBairitsuHasu;
            data.keikakuHaigoJuryo = keikakuHaigoJuryo;
            data.keikakuHaigoJuryoHasu = keikakuHaigoJuryoHasu;
            data.keikakuBatchSu = keikakuBatchSu;
            data.keikakuBatchSuHasu = keikakuBatchSuHasu;
            data.keikakuShikomiJuryo = keikakuShikomiJuryo;
        }

        /// <summary>
        /// 仕掛計画トランと仕掛計画サマリの一行目の計算
        /// </summary>
        /// <param name="data">検索結果</param>
        /// <returns>計算結果</returns>
        public static void calcSeizoDataFirstRow(RecipeTenkaiObject data, List<BairitsuObject> bairitsuList)
        {
            // 入数（品名マスタ）
            decimal iriSu = String.IsNullOrEmpty(data.iriSu.ToString()) ? ActionConst.CalcDefaultNumber : Convert.ToDecimal(data.iriSu);
            // 個重量（品名マスタ）
            decimal koJuryo = String.IsNullOrEmpty(data.koJuryo.ToString()) ? ActionConst.CalcDefaultNumber : Convert.ToDecimal(data.koJuryo);
            // 歩留り(配合マスタ)はNULLの時は100%に設定
            decimal budomari = String.IsNullOrEmpty(data.haigoBudomari.ToString())
                                ? ActionConst.persentKanzan : Convert.ToDecimal(data.haigoBudomari);
            decimal hiju = String.IsNullOrEmpty(data.hiju.ToString())
                                ? ActionConst.CalcDefaultNumber : Convert.ToDecimal(data.hiju);
            if (data.hinmeiKanzanKubun.Equals(data.haigoKanzanKubun) || hiju == ActionConst.CalcDefaultNumber)
            {
                // 換算区分が一緒のときは比重を１にしておけばOK
                hiju = ActionConst.HijuDefaultConst;
            }
            // ↓計算↓
            // 必要量
            decimal hitsuyoJuryo = Convert.ToDecimal(data.suryo) * iriSu * koJuryo / hiju / budomari * ActionConst.persentKanzan;
            // 必要量を小数第4位を切り上げて、小数第3位までとする。
            hitsuyoJuryo = Math.Ceiling(hitsuyoJuryo * 1000m) / 1000m;
            data.hitsuyoJuryo = hitsuyoJuryo;
            data.keikakuShikomiJuryo = hitsuyoJuryo;
            // 合計配合重量
            decimal gokeiHaigoJuryo = String.IsNullOrEmpty(data.haigoGokeiJyuryo) 
                        ? ActionConst.CalcDefaultNumber : Convert.ToDecimal(data.haigoGokeiJyuryo);
            // 基本倍率（配合名マスタ）
            decimal kihonBairitsu = String.IsNullOrEmpty(data.kihonBairitsu) 
                        ? ActionConst.CalcDefaultNumber : Convert.ToDecimal(data.kihonBairitsu);

            // 倍率を計算
            BairitsuObject bObj = FoodProcsCalculator.makeBairitsuObject(data, gokeiHaigoJuryo, kihonBairitsu);
            bairitsuList.Add(bObj);
            // 計画仕込重量を計算
            //FoodProcsCalculator.calcKeikakuShikomiJuryo(data, gokeiHaigoJuryo);
        }
            
        /// <summary>
        /// 仕掛計画トラン明細行の予定生産重量を計算する
        /// 二階層目以降
        /// </summary>
        /// <param name="data">計算対象のオブジェクト</param>
        /// <param name="bairitsuList">倍率が入っているリスト</param>
        /// <param name="budomari">配合名マスタの歩留り</param>
        /// <returns>予定生産重量</returns>
        public static void calcKeikakuShikomiJuryo(RecipeTenkaiObject data, List<BairitsuObject> bairitsuList
                                            , decimal budomari, decimal gokeiHaigoJuryo, decimal kihonBairitsu)
        {
            decimal hitsuyoJuryo = FoodProcsCalculator.calcSuryo(data, bairitsuList, budomari);
            data.hitsuyoJuryo = hitsuyoJuryo;

            // 倍率を計算
            BairitsuObject bObj = FoodProcsCalculator.makeBairitsuObject(data, gokeiHaigoJuryo, kihonBairitsu);
            bairitsuList.Add(bObj);
            // 計画仕込重量を計算
            //FoodProcsCalculator.calcKeikakuShikomiJuryo(data, gokeiHaigoJuryo);
            data.keikakuShikomiJuryo = hitsuyoJuryo;
        }

        private static decimal calcSuryo(RecipeTenkaiObject data, List<BairitsuObject> bairitsuList, decimal budomari)
        {
            decimal maeKeikakuBairitsu = ActionConst.CalcDefaultNumber;
            decimal maeKeikakuBairitsuHasu = ActionConst.CalcDefaultNumber;
            decimal maeKeikakuBatchSu = ActionConst.CalcDefaultNumber;
            decimal maeKeikakuBatchSuHasu = ActionConst.CalcDefaultNumber;
            // 歩留りがNULLor０の場合は100をセット
            if (budomari == 0m)
            {
                budomari = ActionConst.persentKanzan;
            }
            decimal recipeBudomari = Convert.ToDecimal(data.recipeBudomari);
            if (recipeBudomari == 0m)
            {
                recipeBudomari = ActionConst.persentKanzan;
            }
            // 使用する倍率を取得(ひとつ前の階層の倍率を取得)
            if (bairitsuList != null && bairitsuList.Count > 0)
            {
                foreach (var bairitsu in bairitsuList)
                {
                    if (bairitsu.isBairitsuObj(data))
                    {
                        maeKeikakuBairitsu = bairitsu.bairitsu;
                        maeKeikakuBairitsuHasu = bairitsu.bairitsuHasu;
                        maeKeikakuBatchSu = bairitsu.batchSu;
                        maeKeikakuBatchSuHasu = bairitsu.batchSuHasu;
                    }
                }
            }

            // 仕掛計画トラン．製造予定量、使用予実トラン．使用予定数の計算
            decimal hitsuyoJuryo = (Convert.ToDecimal(data.shikomiJuryo) * maeKeikakuBatchSu * maeKeikakuBairitsu
                / recipeBudomari * ActionConst.persentKanzan
                + Convert.ToDecimal(data.shikomiJuryo) * maeKeikakuBatchSuHasu * maeKeikakuBairitsuHasu
                / recipeBudomari * ActionConst.persentKanzan);

            if (data.recipeHinKubun == ActionConst.ShikakariHinKbn.ToString())
            {
                // 仕掛品のみ、÷配合名マスタ．歩留×100
                hitsuyoJuryo = hitsuyoJuryo / budomari * ActionConst.persentKanzan;
            }

            // 必要重量を小数第4位を切り上げて小数第3位までにする。
            hitsuyoJuryo = Math.Ceiling(hitsuyoJuryo * 1000m) / 1000m;

            return hitsuyoJuryo;
        }

        /// <summary>
        /// 倍率データの作成
        /// ※dataの合計配合重量や基本倍率は配合レシピの情報の可能性がある
        /// </summary>
        /// <param name="data"></param>
        /// <param name="gokeiHaigoJuryo">配合名マスタの合計配合重量</param>
        /// <param name="kihonBairitsu">配合名マスタの基本倍率</param>
        public static BairitsuObject makeBairitsuObject(RecipeTenkaiObject data, decimal gokeiHaigoJuryo, decimal kihonBairitsu) {
            // 計画バッチ数
            // 最低バッチ数をセット
            decimal keikakuBatchSu = ActionConst.CalcDefaultNumber;
            //decimal calcKeikakuBatchSu = ActionConst.CalcDefaultNumber;
            decimal calcKeikakuBairitsu = kihonBairitsu;
            if (gokeiHaigoJuryo != ActionConst.CalcDefaultNumber && kihonBairitsu != ActionConst.CalcDefaultNumber) {
                keikakuBatchSu = data.hitsuyoJuryo / (gokeiHaigoJuryo * kihonBairitsu);
                // 整数部で切り捨て
                keikakuBatchSu = Math.Floor(keikakuBatchSu);

                // バッチ数が１より小さい。その場合正規バッチ数を１にして倍率を計算する
                if (keikakuBatchSu < 1m)
                {
                    keikakuBatchSu = ActionConst.BatchSuMinimum;
                    calcKeikakuBairitsu = Math.Ceiling(data.hitsuyoJuryo / (gokeiHaigoJuryo * keikakuBatchSu) * 100m) / 100m;
                }
            }
            else
            {
                //keikakuBatchSu = data.hitsuyoJuryo; // どう計算したらよいか不明
                // 除算する値が０になる場合（基本倍率が０）１
                keikakuBatchSu = ActionConst.BatchSuMinimum;
                calcKeikakuBairitsu = ActionConst.BatchSuMinimum;
            }
            data.keikakuBatchSu = keikakuBatchSu;
            data.keikakuBairitsu = calcKeikakuBairitsu;
/**
            // 計画倍率(配合名マスタの値or計算に使用したものをセット(バッチ数が1以下のとき))
            if (calcKeikakuBatchSu < 1m)
            {
                calcKeikakuBairitsu = Math.Ceiling(calcKeikakuBatchSu * 100m) / 100m;
            }
            else
            {
                calcKeikakuBairitsu = Convert.ToDecimal(data.kihonBairitsu);
            }
            data.keikakuBairitsu = calcKeikakuBairitsu;
*/
            // 計画配合重量
            //data.keikakuHaigoJuryo = gokeiHaigoJuryo * calcKeikakuBairitsu * keikakuBatchSu;
            data.keikakuHaigoJuryo = Math.Ceiling(gokeiHaigoJuryo * calcKeikakuBairitsu * keikakuBatchSu * 1000m) / 1000m; 

            // 必要重量と計画配合重量を比較して端数を算出
            if (data.hitsuyoJuryo <= data.keikakuHaigoJuryo)
            {
                // 計画配合重量端数
                data.keikakuHaigoJuryoHasu = ActionConst.CalcDefaultNumber;
                // 計画倍率端数
                data.keikakuBairitsuHasu = ActionConst.CalcDefaultNumber;
                // 計画倍率バッチ数端数
                data.keikakuBatchSuHasu = ActionConst.CalcDefaultNumber;
            }
            else
            {
                // 計画配合重量端数
                //data.keikakuHaigoJuryoHasu = data.hitsuyoJuryo - data.keikakuHaigoJuryo;
                data.keikakuHaigoJuryoHasu = Math.Ceiling((data.hitsuyoJuryo - data.keikakuHaigoJuryo) * 1000m) / 1000m;

                // 計画倍率端数
                if (gokeiHaigoJuryo == ActionConst.CalcDefaultNumber)
                {
                    data.keikakuBairitsuHasu = data.keikakuHaigoJuryoHasu; // どのように計算したらよいか不明・・・
                }
                else
                {
                    //data.keikakuBairitsuHasu = Math.Ceiling(data.keikakuHaigoJuryoHasu / gokeiHaigoJuryo * 1000000m) / 1000000m;
                    data.keikakuBairitsuHasu = Math.Ceiling(data.keikakuHaigoJuryoHasu / gokeiHaigoJuryo * 1000m) / 1000m;
                }
                // 計画倍率バッチ数端数
                if (data.keikakuHaigoJuryoHasu != ActionConst.CalcDefaultNumber)
                {
                    data.keikakuBatchSuHasu = ActionConst.BatchHasuAri;
                }
                else
                {
                    data.keikakuBatchSuHasu = ActionConst.CalcDefaultNumber;
                }
            }

            // 倍率（端数）が倍率（正規）と等しくなった場合は、端数バッチを正規バッチにマージする。
            if (data.keikakuBairitsu == data.keikakuBairitsuHasu)
            {
                // 正規バッチ数は正規バッチ数と端数バッチ数の合計
                data.keikakuBatchSu = data.keikakuBatchSu + data.keikakuBatchSuHasu;
                // 端数バッチ数は0にする
                data.keikakuBatchSuHasu = ActionConst.CalcDefaultNumber;
                // 端数倍率は0にする。（正規倍率は変わらない）
                data.keikakuBairitsuHasu = ActionConst.CalcDefaultNumber;
                // 配合重量は必要重量全部になる。
                data.keikakuHaigoJuryo = data.hitsuyoJuryo;
                // 配合重量（端数）は0になる。
                data.keikakuHaigoJuryoHasu = ActionConst.CalcDefaultNumber;
            }

            // 倍率オブジェクト作成
            BairitsuObject bObj = new BairitsuObject(data, data.recipeHinmeiCode);
            return bObj;
        }

        private static void calcKeikakuShikomiJuryo(RecipeTenkaiObject data, decimal gokeiHaigoJuryo)
        {
            // 計画仕込重量
            //data.keikakuShikomiJuryo = gokeiHaigoJuryo * data.keikakuBairitsu * data.keikakuBatchSu +
            //                    gokeiHaigoJuryo * data.keikakuBairitsuHasu * data.keikakuBatchSuHasu;
            data.keikakuShikomiJuryo = Math.Ceiling((gokeiHaigoJuryo * data.keikakuBairitsu * data.keikakuBatchSu +
                                gokeiHaigoJuryo * data.keikakuBairitsuHasu * data.keikakuBatchSuHasu) * 1000m) / 1000m;

        }

        /// <summary>
        /// 原料の計算
        /// </summary>
        /// <param name="data"></param>
        /// <param name="bairitsuList"></param>
        /// <param name="budomari"></param>
        public static void calcSuryoForGenryo(RecipeTenkaiObject data, List<BairitsuObject> bairitsuList, decimal budomari)
        {
            // 原料の場合は必要量＝仕込量とする
            data.hitsuyoJuryo = FoodProcsCalculator.calcSuryo(data, bairitsuList, budomari);
            data.keikakuShikomiJuryo = data.hitsuyoJuryo;
            
        }

        /// <summary>
        /// 資材の仕様予実トランデータを計算(乗法しただけ） 
        /// <param name="shizaiView">入力データより資材使用マスタのデータを抽出した一覧</param>
        /// </summary>
        public static void calcShiyoYozitsuForShizai(
            IEnumerable<usp_SeihinKeikaku_Shizai_select_Result> shizaiView, List<RecipeTenkaiObject> recipeList, String seihinSaibanNo)
        {
            foreach (var val in shizaiView)
            {
                if (!String.IsNullOrEmpty(val.cd_shizai)) {
                    RecipeTenkaiObject dao = new RecipeTenkaiObject();
                    // 資材の区分を無理やりセット
                    dao.recipeHinKubun = ActionConst.ShizaiHinKbn.ToString();
                    dao.hinmeiCode = val.cd_hinmei;
                    dao.shokubaCode = val.cd_shokuba;
                    dao.seizoDate = (DateTime)val.dt_seizo;
                    dao.suryo = val.su_suryo.ToString();
                    dao.shizaiCode = val.cd_shizai;
                    dao.shiyoSu = val.su_shiyo.ToString();

                    // 使用数の計算
                    Decimal keikakusu = (Decimal)val.su_suryo;
                    Decimal shiyosu = (Decimal)val.su_shiyo;
                    Decimal budomari = (Decimal)val.ritsu_budomari;
                    if (budomari == 0)
                    {
                        // 0除算考慮
                        // 歩留がは0の場合はデフォルトを設定する(nullの場合は0が返却されているので、0だけで判断してOK)
                        budomari = ActionConst.persentKanzan;
                    }

                    //dao.keikakuShikomiJuryo = keikakusu * shiyosu / budomari * ActionConst.persentKanzan;
                    dao.keikakuShikomiJuryo = Math.Ceiling((keikakusu * shiyosu / budomari * ActionConst.persentKanzan) * 1000m) / 1000m;

                    dao.seihinLotNo = seihinSaibanNo;
                    recipeList.Add(dao);
                }
            }
        }

        /// <summary>
        /// 合算される仕込み重量をaddする処理
        /// </summary>
        /// <param name="obj1"></param>
        /// <param name="obj2"></param>
        public static void addShikomiJuryo(RecipeTenkaiObject obj1, RecipeTenkaiObject obj2)
        {
            addShikomiJuryo(obj1, Convert.ToDecimal(obj2.hitsuyoJuryo), Convert.ToDecimal(obj2.keikakuShikomiJuryo));
        }

        public static void addShikomiJuryo(RecipeTenkaiObject obj1, decimal hitsuyoJuryo, decimal shikomiJuryo)
        {
            decimal baseHitsuyoJuryo = Convert.ToDecimal(obj1.hitsuyoJuryo);
            baseHitsuyoJuryo += hitsuyoJuryo;

            decimal baseShikomiJuryo = Convert.ToDecimal(obj1.keikakuShikomiJuryo);
            baseShikomiJuryo += shikomiJuryo;

            obj1.hitsuyoJuryo = baseHitsuyoJuryo;
            //obj1.seizoYoteiJuryo = baseYoteiJuryo;
            obj1.keikakuShikomiJuryo = baseShikomiJuryo;

        }


        /** 
         * <summary>
         *     指定した精度の数値に四捨五入します。</summary>
         * <param name="dValue">
         *     丸め対象の倍精度浮動小数点数。</param>
         * <param name="iDigits">
         *     戻り値の有効桁数の精度。</param>
         * <returns>
         *     iDigits に等しい精度の数値に四捨五入された数値。</returns>
        public static double ToHalfAdjust(double dValue, int iDigits)
        {
            double dCoef = System.Math.Pow(10, iDigits);

            return dValue > 0 ? System.Math.Floor((dValue * dCoef) + 0.5) / dCoef :
                               System.Math.Ceiling((dValue * dCoef) - 0.5) / dCoef;
        }
         */


        /// 総重量の取得
        public static decimal? calSoJyuryo(decimal? shikomiJuryo, decimal? bairitsu, string kbnShikakari, string kbnGenryo, decimal? budomari)
        {
            decimal? result = shikomiJuryo * bairitsu;
            // 換算区分が異なる場合は歩留まり加味
            if (kbnShikakari != null && kbnShikakari != kbnGenryo)
            {
                result = result / (budomari / ActionConst.persentKanzan);
            }
            return result;
        }

        /// 総重量の取得（重量の比率利用）
        public static decimal? calHiritsuSoJyuryo(decimal? shikomiJuryo, decimal? bairitsu, string kbnShikakari, string kbnGenryo, decimal? budomari, decimal? haigo_bairitsu)
        {
            // 重量×配合の割合
            decimal? result = shikomiJuryo * haigo_bairitsu;
            // 歩留まり加味
            return result = result / (budomari / ActionConst.persentKanzan);
        }

        /// <summary>
        ///  総重量の取得（ラベル印刷ダイアログ用）：歩留まり加味しない版
        /// </summary>
        /// <param name="shikomiJuryo">仕込重量</param>
        /// <param name="haigo_bairitsu">配合倍率</param>
        /// <returns>総重量</returns>
        public static decimal? calHiritsuSoJyuryoLabel(decimal? shikomiJuryo, decimal? haigo_bairitsu)
        {
            // 重量×配合の割合
            decimal? result = shikomiJuryo * haigo_bairitsu;
            return result;
        }

        /// <summary>
        /// 荷姿数計算(配合重量、荷姿重量が1バッチ分の時)
        /// </summary>
        /// <param name="haigoJyuryo">配合重量</param>
        /// <param name="nisugataJyuryo">荷姿重量</param>
        /// <returns>1バッチ分の荷姿数</returns>
        public static decimal calNisugataSu(decimal? haigoJyuryo, decimal? nisugataJyuryo)
        {
            // 荷姿登録がないか、荷姿が０の場合は０を返却
            Decimal res = ActionConst.CalcDefaultNumberInt;
            if (nisugataJyuryo != null && nisugataJyuryo > ActionConst.CalcDefaultNumberInt)
            {
                res = (Decimal)haigoJyuryo / (Decimal)nisugataJyuryo;
            }
            return res;
        }

        /// <summary>
        /// 荷姿数計算(配合重量、荷姿重量が複数バッチ分の時)
        /// </summary>
        /// <param name="haigoJyuryo">配合重量</param>
        /// <param name="nisugataJyuryo">荷姿重量</param>
        /// <param name="nisugataJyuryo">バッチ数</param>
        /// <returns>バッチ数分の荷姿数</returns>
        public static decimal calNisugataSu(decimal? haigoJyuryo, decimal? nisugataJyuryo, decimal? batch)
        {
            // 荷姿登録がないか、荷姿が０の場合は０を返却
            Decimal res = ActionConst.CalcDefaultNumberInt;
            if (nisugataJyuryo != null && nisugataJyuryo > ActionConst.CalcDefaultNumberInt)
            {
                // 1バッチ分の重量算出
                decimal? oneWeight = haigoJyuryo / batch;
                // 1バッチ分の荷姿数を算出
                decimal? oneNisugata = oneWeight / nisugataJyuryo;

                // バッチ数分の荷姿数を返却
                return (int)oneNisugata * (int)batch;
            }
            return res;
        }

        /// <summary>
        /// 荷姿数計算
        /// </summary>
        /// <param name="haigoJyuryo">配合重量</param>
        /// <param name="recipeJuryo">小分重量(レシピ)</param>
        /// <param name="sonotaJuryo">小分重量(重量マスタ　その他)</param>
        /// <param name="kbnJuryo">小分重量(重量マスタ　区分)</param>
        /// <returns>荷姿数</returns>
        public static decimal? calNisugataSu(decimal? haigoJyuryo, decimal? recipeJuryo, decimal? sonotaJuryo, decimal? kbnJuryo)
        {
            decimal? result = null;
            // レシピ重量を利用
            if (recipeJuryo != null && recipeJuryo > ActionConst.CalcDefaultNumberInt)
            {
                return haigoJyuryo / recipeJuryo;
            }
            // 重量マスタ　その他重量を利用
            if (sonotaJuryo != null && sonotaJuryo > ActionConst.CalcDefaultNumberInt)
            {
                return haigoJyuryo / sonotaJuryo;
            }
            // 重量マスタ　区分ごとの重量を利用
            if (kbnJuryo != null && kbnJuryo > ActionConst.CalcDefaultNumberInt)
            {
                return haigoJyuryo / kbnJuryo;
            }

            // 登録がないか、重量が０の場合は０を返却
            return result;
        }

        /// <summary>
        /// 小分重量１計算
        /// </summary>
        /// <param name="recipeJuryo">小分重量(レシピ)</param>
        /// <param name="sonotaJuryo">小分重量(重量マスタ　その他)</param>
        /// <param name="kbnJuryo">小分重量(重量マスタ　区分)</param>
        /// <returns>小分重量</returns>
        public static decimal? calKowake1Jyuryo(decimal? recipeJuryo, decimal? sonotaJuryo, decimal? kbnJuryo)
        {
            decimal? result = 1;
            // レシピ重量を利用
            if (recipeJuryo != null && recipeJuryo > ActionConst.CalcDefaultNumberInt)
            {
                return recipeJuryo;
            }
            // 重量マスタ　その他重量を利用
            if (sonotaJuryo != null && sonotaJuryo > ActionConst.CalcDefaultNumberInt)
            {
                return sonotaJuryo;
            }
            // 重量マスタ　区分ごとの重量を利用
            if (kbnJuryo != null && kbnJuryo > ActionConst.CalcDefaultNumberInt)
            {
                return kbnJuryo;
            }

            // 登録がないか、重量が０の場合は０を返却
            return result;
        }

        /// <summary>
        /// 小分け重量１計算
        /// </summary>
        /// <param name="kowakeJyuryo">小分重量</param>
        /// <returns>小分重量</returns>
        public static decimal? calKowake1Jyuryo(decimal? kowakeJyuryo)
        {
            // 重量マスタに登録がなければ１を返却
            return (kowakeJyuryo != null && kowakeJyuryo > ActionConst.CalcDefaultNumberInt) ? kowakeJyuryo : ActionConst.CalcNumberOne;
        }

        /// <summary>
        /// 小分け重量１の数を計算
        /// </summary>
        /// <param name="haigoJyuryo">配合重量</param>
        /// <param name="nisugataJyuryo">荷姿重量</param>
        /// <param name="nisugataSu">荷姿数</param>
        /// <param name="kowakeJyuryo">小分重量</param>
        /// <returns>小分重量１の数</returns>
        public static decimal calKowake1Su(decimal? haigoJyuryo, decimal? nisugataJyuryo, decimal? nisugataSu, decimal? kowakeJyuryo)
        {
            decimal? nisugataRyo = nisugataJyuryo * nisugataSu;
            // 荷姿が無い場合は、０とする
            nisugataRyo = (nisugataRyo > ActionConst.CalcDefaultNumberInt) ? nisugataRyo : ActionConst.CalcDefaultNumberInt;
            
            // (総重量-荷姿×荷姿数)/ 小分け重量
            return (decimal)((haigoJyuryo - nisugataRyo) / kowakeJyuryo);
        }

        public static decimal calKowake1SuPdf(decimal? haigoJyuryo, decimal? nisugataJyuryo, decimal? nisugataSu, decimal? kowakeJyuryo, decimal? batch)
        {
            decimal? nisugataRyo = nisugataJyuryo * nisugataSu;
            // 荷姿が無い場合は、０とする
            nisugataRyo = (nisugataRyo > ActionConst.CalcDefaultNumberInt) ? nisugataRyo : ActionConst.CalcDefaultNumberInt;

            //荷姿引いた分の総重量
            decimal? juryo = haigoJyuryo - nisugataRyo;
            //1バッチ分の重量算出
            decimal? oneWeight = juryo / batch;
            decimal? oneKowake = oneWeight / kowakeJyuryo;
            //decimal? oneKowake = juryo / kowakeJyuryo;
            
            // (総重量-荷姿×荷姿数)/ 小分け重量
            return (int)oneKowake * (int)batch;
            //return (int)oneKowake;
        }
        public static decimal calKowake1SuCheckPdf(decimal? haigoJyuryo, decimal? nisugataJyuryo, decimal? nisugataSu, decimal? kowakeJyuryo, decimal? batch)
        {
            decimal? nisugataRyo = nisugataJyuryo * nisugataSu;
            // 荷姿が無い場合は、０とする
            nisugataRyo = (nisugataRyo > ActionConst.CalcDefaultNumberInt) ? nisugataRyo : ActionConst.CalcDefaultNumberInt;

            //荷姿引いた分の総重量
            decimal? juryo = haigoJyuryo - nisugataRyo;
            //1バッチ分の重量算出
            //decimal? oneWeight = juryo / batch;
            decimal? oneKowake = ActionConst.CalcDefaultNumberInt;
            if (kowakeJyuryo != null && kowakeJyuryo > ActionConst.CalcDefaultNumberInt)
            {
                oneKowake = juryo / kowakeJyuryo;
            }

            // (総重量-荷姿×荷姿数)/ 小分け重量
            return (int)oneKowake;
        }

        /// <summary>
        /// 小分け重量２計算
        /// </summary>
        /// <param name="haigoJyuryo">配合重量</param>
        /// <param name="nisugataJyuryo">荷姿重量</param>
        /// <param name="nisugataSu">荷姿数</param>
        /// <param name="kowake1Jyuryo">小分重量１</param>
        /// <param name="kowake1Su">小分数１</param>
        /// <returns>小分重量２</returns>
        public static decimal? calKowake2Jyuryo(decimal? haigoJyuryo, decimal? nisugataJyuryo, decimal? nisugataSu, decimal? kowake1Jyuryo, decimal? kowake1Su)
        {
            decimal? nisugataRyo = nisugataJyuryo * nisugataSu;
            // 荷姿が無い場合は、０とする
            nisugataRyo = (nisugataRyo > ActionConst.CalcDefaultNumberInt) ? nisugataRyo : ActionConst.CalcDefaultNumber;

            // (総重量-荷姿×荷姿数-小分重量１×小分数１
            return haigoJyuryo - nisugataRyo - (kowake1Jyuryo * kowake1Su);
        }
        public static decimal? calKowake2JyuryoPdf(decimal? haigoJyuryo, decimal? nisugataJyuryo, decimal? nisugataSu, decimal? kowake1Jyuryo, decimal? kowake1Su, decimal? batch)
        {
            decimal? nisugataRyo = nisugataJyuryo * nisugataSu;
            // 荷姿が無い場合は、０とする
            nisugataRyo = (nisugataRyo > ActionConst.CalcDefaultNumberInt) ? nisugataRyo : ActionConst.CalcDefaultNumber;
            decimal? oneHasuWeight = (haigoJyuryo - nisugataRyo - (kowake1Jyuryo * kowake1Su)) / batch;
            //decimal? oneHasuWeight = (haigoJyuryo - nisugataRyo - (kowake1Jyuryo * kowake1Su * batch));
            // (総重量-荷姿×荷姿数-小分重量１×小分数１
            return oneHasuWeight;
        }
        public static decimal? calKowake2JyuryoCheckPdf(decimal? haigoJyuryo, decimal? nisugataJyuryo, decimal? nisugataSu, decimal? kowake1Jyuryo, decimal? kowake1Su, decimal? batch)
        {
            decimal? nisugataRyo = nisugataJyuryo * nisugataSu;
            // 荷姿が無い場合は、０とする
            nisugataRyo = (nisugataRyo > ActionConst.CalcDefaultNumberInt) ? nisugataRyo : ActionConst.CalcDefaultNumber;
            decimal? oneHasuWeight = (haigoJyuryo - nisugataRyo - (kowake1Jyuryo * kowake1Su));
            // (総重量-荷姿×荷姿数-小分重量１×小分数１
            return oneHasuWeight;
        }
        /// <summary>
        /// 小分け重量２の数を計算
        /// </summary>
        /// <param name="kowake2Jyuryo">小分重量２</param>
        /// <returns>小分数２</returns>
        public static decimal calKowake2Su(decimal? kowake2Jyuryo)
        {
            // 重量が０以上の場合は１を返却
            return (kowake2Jyuryo != null && kowake2Jyuryo > ActionConst.CalcNumberZero) ? ActionConst.CalcNumberOne : ActionConst.CalcNumberZero;
        }
        public static decimal calKowake2SuPdf(decimal? kowake2Jyuryo, decimal? batch)
        {
            // 重量が０以上の場合は１を返却
            return (kowake2Jyuryo != null && kowake2Jyuryo > ActionConst.CalcNumberZero) ? (decimal)batch : ActionConst.CalcNumberZero;
            //return (kowake2Jyuryo != null && kowake2Jyuryo > ActionConst.CalcNumberZero) ? ActionConst.CalcNumberOne : ActionConst.CalcNumberZero;
        }
        /// <summary>
        ///  仕掛品仕込画面の仕込量が変更されたときに呼び出されるメソッド
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static ShikomiJuryoContainer calcBairitsuForDisp(ShikomiJuryoContainer obj)
        {
            // 仕込量が変更されたパターン
            decimal shikomiJuryo = obj.shikomiJuryo;
            // バッチ数＝仕込重量/基本倍率(マスタ属性）整数部
            //decimal batchSu = Math.Truncate(shikomiJuryo / obj.gokeiHaigoJuryo * obj.kihonBairitsu);
            decimal batchSu = Math.Truncate(shikomiJuryo / (obj.gokeiHaigoJuryo * obj.kihonBairitsu));
            // 正規のバッチ数が１より大きいとき(ひと釜ぶん作れるとき)
            if (batchSu >= 1)
            {
                //decimal haigoJuryo = obj.gokeiHaigoJuryo * obj.kihonBairitsu * batchSu;
                decimal haigoJuryo = Math.Ceiling((obj.gokeiHaigoJuryo * obj.kihonBairitsu * batchSu) * 1000m) / 1000m;
                decimal haigoJuryoHasu = shikomiJuryo - haigoJuryo;

                // 正規倍率、端数倍率、端数バッチ数
                decimal bairitsu = obj.kihonBairitsu;
                decimal batchSuHasu = ActionConst.CalcDefaultNumber;
                decimal bairitsuHasu = ActionConst.CalcDefaultNumber;
                if (haigoJuryoHasu != 0m)
                {
                    batchSuHasu = 1m;
                    //bairitsuHasu = Math.Floor(haigoJuryoHasu / obj.gokeiHaigoJuryo * 1000000m) / 1000000m;
                    bairitsuHasu = Math.Floor(haigoJuryoHasu / obj.gokeiHaigoJuryo * 1000m) / 1000m;
                }
                obj.batchSu = batchSu;
                obj.batchSuHasu = batchSuHasu;
                obj.bairitsu = bairitsu;
                obj.bairitsuHasu = bairitsuHasu;
            }
            else
            {
                obj.batchSu = 0m;
                obj.bairitsu = 0m;
                //obj.bairitsuHasu = Math.Floor(shikomiJuryo / obj.gokeiHaigoJuryo * 1000000m) / 1000000m;
                obj.bairitsuHasu = Math.Floor(shikomiJuryo / obj.gokeiHaigoJuryo * 1000m) / 1000m;
                obj.batchSuHasu = 1m;
            }


            // 倍率（端数）が倍率（正規）と等しくなった場合は、端数バッチを正規バッチにマージする。
            if (obj.bairitsu == obj.bairitsuHasu)
            {
                // 正規バッチ数は正規バッチ数と端数バッチ数の合計
                obj.batchSu = obj.batchSu + obj.batchSuHasu;
                // 端数バッチ数は0にする
                obj.batchSuHasu = ActionConst.CalcDefaultNumber;
                // 端数倍率は0にする。（正規倍率は変わらない）
                obj.bairitsuHasu = ActionConst.CalcDefaultNumber;
            }
            return obj;
        }

        /// <summary>
        /// 仕込量を算出、取得する
        /// ※仕掛品仕込画面のバッチ数、倍率が変更されたときに呼び出されるメソッド
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static ShikomiJuryoContainer calcShikomiJuryoForDisp(ShikomiJuryoContainer obj)
        {
            // バッチ数、倍率が変更されたパターン
            //obj.shikomiJuryo = Math.Floor(((obj.gokeiHaigoJuryo * obj.bairitsu * obj.batchSu)
                                //+ (obj.gokeiHaigoJuryo * obj.bairitsuHasu * obj.batchSuHasu)) * 1000000m) / 1000000m;
            decimal calcShikomiJuryo = (obj.gokeiHaigoJuryo * obj.bairitsu * obj.batchSu) + (obj.gokeiHaigoJuryo * obj.bairitsuHasu * obj.batchSuHasu);
            obj.shikomiJuryo = Math.Ceiling(calcShikomiJuryo * 1000m) / 1000m;
            return obj;
        }

        /// <summary>
        /// 当日残を算出、取得する
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static decimal calcTojitsuZanForDisp(decimal shikomiJuryo, decimal zanShiyoryo, decimal hitsuyoryo)
        {
            //return Math.Floor((shikomiJuryo + zanShiyoryo - hitsuyoryo) * 1000000m) / 1000000m;
            return Math.Floor((shikomiJuryo + zanShiyoryo - hitsuyoryo) * 1000m) / 1000m;
        }

        /// <summary>
        /// 納入数を計算し、納入数と納入端数にする
        /// </summary>
        public static List<dynamic> calcNonyu(decimal su_ko, decimal su_iri, decimal su_nonyu, string cd_tani)
        {
            decimal cs;
            decimal hasu;
            decimal su_ko_iri = su_ko * su_iri;
            decimal nonyu = su_nonyu / su_ko_iri;
            cs = Math.Truncate(nonyu);

            // 【ビジネスルール：BIZ00008】
            if (cd_tani == ActionConst.KgKanzanKbn || cd_tani == ActionConst.LKanzanKbn)
            {
                // 納入単位(端数)＝((使用単位/(1個の量×入数))-納入単位(納入数))×1000
                //hasu = Math.Ceiling((su_nonyu / (su_ko * su_iri) - Math.Truncate(su_nonyu / (su_ko * su_iri))) * 1000) / 1000 * 1000;
                hasu = Math.Ceiling((nonyu - cs) * 1000) / 1000 * 1000;
            }
            else
            {
                // 納入単位(端数)＝((使用単位/(1個の量×入数))-納入単位(納入数))×入数
                //hasu = Math.Ceiling((su_nonyu / (su_ko * su_iri) - Math.Truncate(su_nonyu / (su_ko * su_iri))) * 1000) / 1000 * su_iri;
                //hasu = Math.Ceiling((nonyu - cs) * 1000) / 1000 * su_iri;
                hasu = Math.Floor(Math.Ceiling((nonyu - cs) * 1000) / 1000 * su_iri);
            }
            List<dynamic> nonyuData = new List<dynamic>();
            dynamic key = new JObject();
            key.nonyu =cs;
            key.nonyu_hasu = hasu;
            nonyuData.Add(key);
            return nonyuData;
        }
    }
}
