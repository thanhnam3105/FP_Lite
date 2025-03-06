using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Properties;
using Tos.FoodProcs.Web.Data;
using System.Data.Objects;
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers
{
    public class HendoHyoSimulationRecipeTenkaiDAO
    {
        /// <summary>
        /// レシピ展開の検索処理を行う
        /// </summary>
        /// <param name="val">エンティティ</param>
        public HendoHyoSimulationRecipeTenkaiDAO(FoodProcsEntities val) 
        {
            context = val;
        }

        FoodProcsEntities context;

        /// <summary>
        /// 配合コードを取得して再帰的にレシピ展開を行う
        /// </summary>
        /// <param name="hinmeiCode">サマリデータのキーの部分</param>
        /// <param name="haigoCode">配合コード</param>
        /// <param name="kaisoSu">階層数</param>
        /// <param name="seizoDate">製造日</param>
        /// <param name="hitsuyoDate">必要日</param>
        /// <param name="shokubaCode">職場コード</param>
        /// <param name="lineCode">ラインコード</param>
        /// <param name="list">レシピ展開されたデータ</param>
        /// <param name="genryoKeys">サマリ用キーリスト</param>
        /// <param name="bairitsuList">倍率データ</param>
        /// <param name="isAllTenkai">展開フラグに関係なくすべて展開するかどうか</param>
        public void selectHaigo(String hinmeiCode, String haigoCode, int kaisoSu, 
                DateTime seizoDate, DateTime? hitsuyoDate, String shokubaCode, String lineCode,
                //String seihinLotNo, String shikakariLotNo,
                List<RecipeTenkaiObject> list, 
                //Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic, List<BairitsuObject> bairitsuList) {
                List<dynamic> genryoKeys, List<BairitsuObject> bairitsuList, bool isAllTenkai) {

            //FoodProcsEntities context = new FoodProcsEntities();
            // 階層はプラス１して検索
            kaisoSu++;
            // 仕掛ロット番号：シミュレーション画面では使用しないので、ダミー値を設定
            string shikakariLotNo = "0000";

            // レシピ展開処理
            IEnumerable<usp_RecipeTenkai_Result> recipeViews = 
                    context.usp_RecipeTenkai_FromHaigo_select(
                        hinmeiCode, haigoCode, shokubaCode, lineCode, seizoDate, (short)kaisoSu, shikakariLotNo,
                        ActionConst.FlagFalse, ActionConst.HaigoMasterKbn, ActionConst.FlagFalse,
                        ActionConst.HinmeiMasterKbn, ActionConst.ShikakariHinKbn, ActionConst.JikaGenryoHinKbn);

            String recipeKbnHin;
            RecipeTenkaiObject data;
            // レシピ展開データは「仕掛品」or「自家原」、「原料」
            foreach (var val in recipeViews)
            {
                data = new RecipeTenkaiObject(val);
                data.hitsuyoDate = (DateTime)hitsuyoDate;

                //FoodProcsCalculator.calcTrnShikakari(data, bairitsuList);
                haigoCode = val.recipe_cd_hinmei;   // 原資材コード

                // 原資材コードがnullだった場合、次のレコードへ
                if (string.IsNullOrEmpty(haigoCode))
                {
                    continue;
                }

                recipeKbnHin = val.recipe_kbn_hin.ToString();
                // 仕掛品、自家原料ｏｒ原料
                // 自家原の登録についてはビジネスルール参照
                if (recipeKbnHin == ActionConst.ShikakariHinKbn.ToString())
                {
                    // 展開フラグ参照
                    //if (val.haigo_flg_tenkai == ActionConst.FlagTrue)
                    if (isAllTenkai || (!isAllTenkai && val.hinmei_flg_tenkai == ActionConst.FlagTrue))
                    {
                        IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> haigoMasterViews =
                            context.usp_RecipeTenkai_ma_haigo_mei_select(val.recipe_cd_hinmei, data.seizoDate, ActionConst.FlagFalse);
                        // 一件のみ取得(有効版の配合名マスタ情報取得)
                        foreach (var haigoMei in haigoMasterViews)
                        {
                            // null対策
                            Decimal budomari = checkNullToInitValue(haigoMei.ritsu_budomari_mei, ActionConst.persentKanzan);
                            Decimal wt_haigo_gokei = checkNullToInitValue(haigoMei.wt_haigo_gokei, Decimal.Zero);
                            Decimal ritsu_kihon = checkNullToInitValue(haigoMei.ritsu_kihon, Decimal.One);

                            // 生産予定重量にセット
                            //FoodProcsCalculator.calcKeikakuShikomiJuryo(
                            //        data, bairitsuList, (Decimal)haigoMei.ritsu_budomari_mei, (Decimal)haigoMei.wt_haigo_gokei, (Decimal)haigoMei.ritsu_kihon);
                            FoodProcsCalculator.calcKeikakuShikomiJuryo(data, bairitsuList, budomari, wt_haigo_gokei,ritsu_kihon);
                        }
                        // 仕掛品は展開のみで、画面に表示しない
                        //list.Add(data);

                        if (kaisoSu < 10)   // 展開は10階層まで
                        {
                            selectHaigo(
                                hinmeiCode, haigoCode, kaisoSu, seizoDate, hitsuyoDate,
                                shokubaCode, lineCode, list, genryoKeys, bairitsuList, isAllTenkai);
                        }
                    }
                }
                else if (recipeKbnHin == ActionConst.JikaGenryoHinKbn.ToString())
                {
                    //// 自家原料データ：原料として扱う

                    IEnumerable<usp_RecipeTenkai_ma_hinmei_genryo_select_Result> genryoViews =
                            context.usp_RecipeTenkai_ma_hinmei_genryo_select(data.recipeHinmeiCode, ActionConst.FlagFalse);
                    decimal budomari = ActionConst.persentKanzan;
                    foreach (var genryo in genryoViews)
                    {
                        if (genryo.ritsu_budomari != null)
                        {
                            budomari = Convert.ToDecimal(genryo.ritsu_budomari);
                        }
                    }
                    FoodProcsCalculator.calcSuryoForGenryo(data, bairitsuList, budomari);
                    //data.shikakariLotNo = shikakariLotNo;
                    //data.seihinLotNo = seihinLotNo;
                    //list.Add(data);
                    // 同一の自家原料があればサマリする
                    if (!checkRecipeHinmeiCode(genryoKeys, data, list))
                    {
                        // 同一の自家原料がなければレシピ展開されたデータに追加する
                        list.Add(data);
                    }
                }
                else if (recipeKbnHin == ActionConst.GenryoHinKbn.ToString())
                {
                    //// 原料データ

                    decimal budomari = ActionConst.persentKanzan;
                    FoodProcsCalculator.calcSuryoForGenryo(data, bairitsuList, budomari);
                    //data.shikakariLotNo = shikakariLotNo;
                    //data.seihinLotNo = seihinLotNo;

                    // 同一の原料があればサマリする
                    if (!checkRecipeHinmeiCode(genryoKeys, data, list))
                    {
                        // 同一の原料がなければレシピ展開されたデータに追加する
                        list.Add(data);
                    }
                }
            }
        }

        /// <summary>
        /// サマリ用キーリストに原料の品名コードを追加する。
        /// 同一のコードがあればサマリする。
        /// </summary>
        /// <param name="keys">サマリ用キーリスト</param>
        /// <param name="val">サマリデータとなる部分</param>
        /// <param name="list">レシピ展開されたデータ</param>
        /// <returns>同一コードが存在した場合true</returns>
        public bool checkRecipeHinmeiCode(List<dynamic> keys, RecipeTenkaiObject val, List<RecipeTenkaiObject> list)
        {
            // 原料コードの存在チェック
            if (keys.Find(k => k.recipeHinmeiCode == val.recipeHinmeiCode) != null)
            {
                // 一致する原料コードがあればサマリ
                var data = list.Find(li => li.recipeHinmeiCode == val.recipeHinmeiCode);
                data.hitsuyoJuryo = data.hitsuyoJuryo + val.hitsuyoJuryo;
                return true;
            }
            else
            {
                // 一致しなければサマリ用キーリストに追加
                dynamic key = new JObject();
                key.recipeHinmeiCode = val.recipeHinmeiCode;
                key.hitsuyoJuryo = val.hitsuyoJuryo;    // 処理には使用しないがデバッグ用に。
                keys.Add(key);
                return false;
            }
        }

        /// <summary>
        /// 取得した値がnullだった場合、初期値を返却する。
        /// </summary>
        /// <param name="value">取得した値</param>
        /// <param name="iniValue">初期値</param>
        /// <returns>結果</returns>
        private decimal checkNullToInitValue(decimal? value, decimal iniValue)
        {
            decimal retValue = iniValue;
            // null以外かつ0以上の場合、取得結果を返す
            if (value != null && value > 0)
            {
                retValue = (decimal)value;
            }
            return retValue;
        }
    }
}