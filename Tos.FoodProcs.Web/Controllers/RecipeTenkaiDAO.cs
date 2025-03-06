using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tos.FoodProcs.Web.Properties;
using Tos.FoodProcs.Web.Data;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
    public class RecipeTenkaiDAO
    {
        /**
         * レシピ展開の検索処理を行う
         */
        public RecipeTenkaiDAO(FoodProcsEntities val)
        {
            context = val;
        }

        FoodProcsEntities context;

        /// <summary>
        /// 配合コードを取得して再帰的にレシピ展開を行う
        /// </summary>
        /// <param name="hinmeiCode">品名コード</param>
        /// <param name="haigoCode">配合コード</param>
        /// <param name="kaisoSu">階層数</param>
        /// <param name="seizoDate">製造日</param>
        /// <param name="hitsuyoDate">必要日</param>
        /// <param name="shokubaCode">職場コード</param>
        /// <param name="lineCode">ラインコード</param>
        /// <param name="seihinLotNo">製品ロット番号</param>
        /// <param name="shikakariLotNo">前の階層の仕掛品ロット番号</param>
        /// <param name="list">レシピ展開されたデータ</param>
        /// <param name="dic">合算用キーリスト</param>
        /// <param name="bairitsuList">倍率リスト</param>
        /// <param name="shikakariDataKey">仕掛品計画トランのデータキー</param>
        public void selectHaigo(String hinmeiCode, String haigoCode, int kaisoSu,
                DateTime seizoDate, DateTime hitsuyoDate, String shokubaCode, String lineCode,
                String seihinLotNo, String shikakariLotNo, List<RecipeTenkaiObject> list,
                Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic, List<BairitsuObject> bairitsuList, String shikakariDataKey)
        {

            // 階層はプラス１して検索
            kaisoSu++;
            IEnumerable<usp_RecipeTenkai_Result> recipeViews =
                    context.usp_RecipeTenkai_FromHaigo_select(hinmeiCode, haigoCode, shokubaCode, lineCode,
                        seizoDate, (short)kaisoSu, shikakariLotNo, ActionConst.FlagFalse, ActionConst.HaigoMasterKbn, ActionConst.FlagFalse,
                        ActionConst.HinmeiMasterKbn, ActionConst.ShikakariHinKbn, ActionConst.JikaGenryoHinKbn);
            String recipeKbnHin;
            RecipeTenkaiObject data;
            // レシピ展開データは「仕掛品」or「自家原」、「原料」
            foreach (var val in recipeViews)
            {
                if (string.IsNullOrEmpty(val.cd_line) || string.IsNullOrEmpty(val.cd_shokuba))
                {
                    // 展開した仕掛品のラインコードまたは職場コードが存在しなかった場合、エラーとする
                    DateTime dtSeizo = (DateTime)val.dt_seizo;
                    dtSeizo = dtSeizo.AddHours(9);
                    string errorMsg = String.Format(
                        Resources.MS0707, dtSeizo.ToString(ActionConst.DateFormat), val.cd_hinmei);
                    InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                    ioe.Data.Add("key", "MS0707");
                    //throw new Exception(errorMsg);
                    throw ioe;
                }

                // 引数の仕掛品ロット番号をそのまま使用すると、レシピの展開途中に仕掛品がある場合に
                // 前階層の仕掛品ロット番号が変わってしまうため、変数に代入して使用する
                string tmp_shikakariLot = shikakariLotNo;

                data = new RecipeTenkaiObject(val);
                data.hitsuyoDate = (DateTime)hitsuyoDate;
                data.seihinLotNo = seihinLotNo;
                data.dataKey = shikakariDataKey;
                data.oyaDataKey = shikakariDataKey;
                //FoodProcsCalculator.calcTrnShikakari(data, bairitsuList);
                haigoCode = val.recipe_cd_hinmei;
                recipeKbnHin = val.recipe_kbn_hin.ToString();
                // 仕掛品、自家原料ｏｒ原料
                // 自家原の登録についてはビジネスルール参照
                if (recipeKbnHin == ActionConst.ShikakariHinKbn.ToString())
                {
                    // 展開フラグ参照
                    //if (val.haigo_flg_tenkai == ActionConst.FlagTrue)
                    if (val.hinmei_flg_tenkai == ActionConst.FlagTrue)
                    {
                        IEnumerable<usp_RecipeTenkai_ma_haigo_mei_select_Result> haigoMasterViews =
                            context.usp_RecipeTenkai_ma_haigo_mei_select(val.recipe_cd_hinmei, data.seizoDate, ActionConst.FlagFalse);

                        // データキー
                        string dataKey = null;

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
                            FoodProcsCalculator.calcKeikakuShikomiJuryo(data, bairitsuList, budomari, wt_haigo_gokei, ritsu_kihon);

                            // 既存計画を取得
                            tr_keikaku_shikakari shikakari = (from tr in context.tr_keikaku_shikakari
                                                              where tr.data_key_oya == data.oyaDataKey
                                                              select tr).AsEnumerable().FirstOrDefault();

                            if (shikakari == null)
                            {
                                // サマリのデータ作成(サマリのデータが存在した場合はその仕掛ロット№を返す。
                                // 仕掛ロット番号がなかった場合も付番した仕掛ロット№を返す。次の検索の親仕掛品ロットNoになるため)
                                //shikakariLotNo = makeSummaryData(dic, data, haigoMei.flg_gassan_shikomi);
                                tmp_shikakariLot = makeSummaryData(dic, data, haigoMei.flg_gassan_shikomi, null);
                            }
                            else
                            {
                                // 仕掛品計画が取得できた場合はその仕掛品ロット番号を引き継ぐ
                                tmp_shikakariLot = shikakari.no_lot_shikakari;
                                // サマリ用辞書だけ作成する。
                                this.makeSummaryOfHikitsugi(dic, data);

                                // データキー設定
                                dataKey = shikakari.data_key;
                            }

                        }

                        if (String.IsNullOrEmpty(tmp_shikakariLot))
                        {
                            // 仕掛品ロット番号を付与
                            tmp_shikakariLot = FoodProcsCommonUtility.executionSaiban(
                                ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
                        }
                        data.shikakariLotNo = tmp_shikakariLot;
                        data.seihinLotNo = seihinLotNo;
                        // 配合データ
                        //data.shikakariLotNo = data.oyaShikakariLotNo;

                        if (dataKey == null)
                        {
                            // 仕掛品計画トランのデータキーを取得
                            //string dataKey = FoodProcsCommonUtility.executionSaiban(
                            dataKey = FoodProcsCommonUtility.executionSaiban(
                                    ActionConst.ShikakarihinKeikakuSaibanKbn, ActionConst.ShikakarihinKeikakuPrefixSaibanKbn, context);
                        }
                        
                        data.dataKey = dataKey;
                        list.Add(data);

                        if (kaisoSu < 10)   // 展開は10階層まで
                        {
                            //selectHaigo(hinmeiCode, haigoCode, kaisoSu, seizoDate, hitsuyoDate, shokubaCode, lineCode, seihinLotNo, shikakariLotNo, list, dic, bairitsuList);
                            selectHaigo(hinmeiCode, haigoCode, kaisoSu, seizoDate, hitsuyoDate, shokubaCode, lineCode
                                , seihinLotNo, tmp_shikakariLot, list, dic, bairitsuList, dataKey);
                        }
                    }
                }
                else if (recipeKbnHin == ActionConst.JikaGenryoHinKbn.ToString())
                {
                    ///// 自家原料の場合：原料として扱う

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
                    data.shikakariLotNo = tmp_shikakariLot; // shikakariLotNo;
                    data.seihinLotNo = seihinLotNo;
                    list.Add(data);
                }
                else if (recipeKbnHin == ActionConst.GenryoHinKbn.ToString())
                {
                    // 原料データ
                    //decimal budomari = ActionConst.persentKanzan;
                    decimal budomari = decimal.Parse(data.recipeBudomari);
                    FoodProcsCalculator.calcSuryoForGenryo(data, bairitsuList, budomari);
                    data.shikakariLotNo = tmp_shikakariLot; // shikakariLotNo;
                    data.seihinLotNo = seihinLotNo;
                    list.Add(data);
                }
            }
        }

        /// <summary>
        /// 仕掛サマリデータを作成する
        /// </summary>
        /// <param name="dic">サマリデータのキーの部分</param>
        /// <param name="val">サマリデータとなる部分</param>
        /// <return name="gassanFlag">合算フラグ</param>
        /// <return name="noLotShikakari">月間仕掛品計画からの修正の場合、修正対象行の仕掛品ロット番号を受け取る。それ以外はnull</param>
        public String makeSummaryData(
            Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic, RecipeTenkaiObject val, int gassanFlag, string noLotShikakari)
        {
            //String shikakariLotNo = null;
            String shikakariLotNo = noLotShikakari;
            ShikakariGassanKey key = val.getGassanKey();
            RecipeTenkaiObject obj;
            // 合算区分がTRUEでDictionaryにKEYが存在する場合
            if (dic.ContainsKey(key))
            {
                // 合算仕込フラグに処理分岐
                if (ActionConst.FlagTrue == gassanFlag)
                {
                    dic.TryGetValue(key, out obj);
                    shikakariLotNo = obj.shikakariLotNo;
                    // サマリーデータのキーリストだけを作成するので、コメントアウト
                    //FoodProcsCalculator.addShikomiJuryo(obj, val);
                }
                else
                {
                    // 合算フラグがfalseの時はロット番号を取得してキーもシーケンスNoを加算してadd
                    shikakariLotNo = getShikakariLotForGassanFlagFalse(dic, val);
                }
            }
            else
            {
                // 合算仕込フラグに処理分岐
                if (ActionConst.FlagTrue == gassanFlag)
                {
                    // 既に仕掛トランにデータがあるものはそっちもSUMする
                    // ただし製品ロットが同じものは除く（同一行のため）
                    // また、製造実績、仕込実績、仕込計画確定がされているものも除く。
                    IEnumerable<usp_RecipeTenkai_Shikakari_select_Result> views = context.usp_RecipeTenkai_Shikakari_select(
                        key.seizoDate, key.shokubaCode, key.lineCode, key.recipeHaigoCode, val.seihinLotNo, val.dataKey);
                    RecipeTenkaiObject sumObj = new RecipeTenkaiObject();
                    sumObj.setRecipeTenkaiContents(val);
                    foreach (var shikakari in views)
                    {
                        obj = makeRecipeTenkaiObjectForShikakari(shikakari);
                        if (String.IsNullOrEmpty(shikakariLotNo))
                        {
                            shikakariLotNo = obj.shikakariLotNo;
                        }
                        // 仕掛ロット番号があった場合は小さいほうを採用。違うロットになってるはずないけど・・・。
                        //if (double.Parse(shikakariLotNo.Substring(2)) > double.Parse(obj.shikakariLotNo.Substring(2)))
                        //{
                        //    shikakariLotNo = obj.shikakariLotNo;
                        //}
                        // サマリーデータのキーリストだけを作成するので、コメントアウト
                        //FoodProcsCalculator.addShikomiJuryo(
                        //    sumObj, Convert.ToDecimal(obj.hitsuyoJuryo), Convert.ToDecimal(obj.keikakuShikomiJuryo));

                        // 異なる仕掛品ロット番号があった場合（実績・計画確定のない仕掛品サマリが２件以上あった場合は
                        // 無条件で新規採番する。
                        if (shikakariLotNo != obj.shikakariLotNo) 
                        {
                            // 仕掛品番号を設定されていない状態にする。
                            shikakariLotNo = null;
                            break;
                        }
                    }
                    // この時点で仕掛ロット番号がついていなかったらつける
                    if (String.IsNullOrEmpty(shikakariLotNo))
                    {
                        // 仕掛品ロット番号を付与
                        shikakariLotNo = FoodProcsCommonUtility.executionSaiban(
                            ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
                    }
                    sumObj.shikakariLotNo = shikakariLotNo;
                    // DictionaryにAdd(falseの時も同様の処理になるが別メソットにしたためここでAdd)
                    dic.Add(key, sumObj);
                }
                else
                {
                    // この時点で仕掛ロット番号がついていなかったらつける
                    if (String.IsNullOrEmpty(shikakariLotNo))
                    {
                        shikakariLotNo = getShikakariLotForGassanFlagFalse(dic, val);
                    }
                }
            }
            return shikakariLotNo;
        }
        /// <summary>
        /// 仕込合算フラグがfalseの時の処理
        /// 仕掛品ロット番号を返すが同時にDictionaryも作成
        /// </summary>
        /// <param name="dic">サマリデータの入ったDic</param>
        /// <param name="val">今回のValue</param>
        /// <returns>付番された仕掛ロット番号</returns>
        private String getShikakariLotForGassanFlagFalse(Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic, RecipeTenkaiObject val)
        {

            RecipeTenkaiObject sumObj = new RecipeTenkaiObject();
            sumObj.setRecipeTenkaiContents(val);
            if (String.IsNullOrEmpty(sumObj.shikakariLotNo))
            {
                String shikakariLotNo = "";
                if (!String.IsNullOrEmpty(val.oyaShikakariLotNo))
                {
                    // 親仕掛ロット番号を持っている場合、その子がDBにいるか検索
                    var tr_shikakari = (from tr in context.tr_keikaku_shikakari
                                        where tr.no_lot_shikakari_oya == val.oyaShikakariLotNo
                                            && tr.cd_shikakari_hin == val.recipeHinmeiCode
                                            && tr.no_lot_seihin == val.seihinLotNo
                                        select tr).FirstOrDefault();

                    if (tr_shikakari != null)
                    {
                        shikakariLotNo = tr_shikakari.no_lot_shikakari;
                    }
                }

                // 親仕掛ロット番号がない、または親仕掛ロットを持つ子が仕掛品計画トランに存在しなかった場合
                if (String.IsNullOrEmpty(val.oyaShikakariLotNo) || String.IsNullOrEmpty(shikakariLotNo))
                {
                    // 仕掛品ロット番号を付与
                    shikakariLotNo = FoodProcsCommonUtility.executionSaiban(
                        ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
                }
                sumObj.shikakariLotNo = shikakariLotNo;
            }
            // 合算区分がFALSEの場合はkeyクラスのシーケンス番号を加算してセット
            ShikakariGassanKey key = new ShikakariGassanKey(sumObj.shokubaCode, sumObj.lineCode, sumObj.recipeHinmeiCode, sumObj.seizoDate);
            int noKeySeqNo = 0;
            foreach (ShikakariGassanKey sKey in dic.Keys)
            {
                // シーケンス№を除いた他の項目が同じときのseqNoを返す
                int sSeqNo = sKey.getSeqNo(key);
                // シーケンス№を除いた項目が一緒でない時はエラーコードを返す
                // 処理は0じゃなかったからカウントアップしておく
                if (sSeqNo != Convert.ToInt16(Resources.ErrorCodeInt)
                    && sSeqNo >= noKeySeqNo)
                {
                    noKeySeqNo = ++sSeqNo;
                }
            }
            key.seqNo = noKeySeqNo;
            dic.Add(key, sumObj);
            //return shikakariLotNo;
            return sumObj.shikakariLotNo;
        }

        /// <summary>
        ///  仕掛計画トランを検索時に作成するオブジェクト
        /// </summary>
        /// <param name="shikakari"></param>
        /// <returns></returns>
        private RecipeTenkaiObject makeRecipeTenkaiObjectForShikakari(usp_RecipeTenkai_Shikakari_select_Result shikakari)
        {
            RecipeTenkaiObject obj = new RecipeTenkaiObject();
            obj.dataKey = shikakari.data_key;
            obj.seizoDate = shikakari.dt_seizo;
            obj.hitsuyoDate = Convert.ToDateTime(shikakari.dt_hitsuyo);
            obj.seihinLotNo = shikakari.no_lot_seihin;
            obj.shikakariLotNo = shikakari.no_lot_shikakari;
            obj.oyaShikakariLotNo = shikakari.no_lot_shikakari_oya;
            obj.shokubaCode = shikakari.cd_shokuba;
            obj.lineCode = shikakari.cd_line;
            obj.recipeHinmeiCode = shikakari.cd_shikakari_hin;
            obj.keikakuShikomiJuryo = Convert.ToDecimal(shikakari.wt_shikomi_keikaku);
            obj.jissekiShikomiJuryo = shikakari.wt_shikomi_jisseki.ToString();
            //obj.kaisoSu = Convert.ToInt16(shikakari.su_kaiso_shikomi);
            obj.keikakuHaigoJuryo = Convert.ToDecimal(shikakari.wt_haigo_keikaku);
            obj.jissekiHaigoJuryo = shikakari.wt_haigo_jisseki.ToString();
            obj.keikakuBatchSu = Convert.ToDecimal(shikakari.su_batch_yotei);
            obj.jissekiBatchSu = shikakari.su_batch_jisseki.ToString();
            obj.keikakuBairitsu = Convert.ToDecimal(shikakari.ritsu_bai);
            obj.hinmeiCode = shikakari.cd_hinmei;
            obj.hitsuyoJuryo = Convert.ToDecimal(shikakari.wt_hitsuyo);

            return obj;
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

        /// <summary>
        /// 仕掛品ロット番号引継ぎ用合算データ作成
        /// 仕掛品ロット番号を引き継ぐ場合に、合算データ辞書のみ追加します。
        /// </summary>
        /// <param name="dic">合算データ辞書</param>
        /// <param name="data">レシピ展開オブジェクト</param>
        public void makeSummaryOfHikitsugi(Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic, RecipeTenkaiObject data)
        {
            ShikakariGassanKey key = data.getGassanKey();
            int noKeySeqNo = 0;
            RecipeTenkaiObject obj = null;

            foreach (ShikakariGassanKey sKey in dic.Keys)
            {
                // シーケンス№を除いた他の項目が同じときのseqNoを返す
                int sSeqNo = sKey.getSeqNo(key);
                // シーケンス№を除いた項目が一緒でない時はエラーコードを返す
                // 処理は0じゃなかったからカウントアップしておく
                if (sSeqNo != Convert.ToInt16(Resources.ErrorCodeInt)
                    && sSeqNo >= noKeySeqNo)
                {
                    dic.TryGetValue(sKey, out obj);
                    
                    // 同じ仕掛品ロット番号がある場合
                    if (obj.shikakariLotNo == data.shikakariLotNo)
                    {
                        noKeySeqNo = sSeqNo;
                        break;
                    }

                    noKeySeqNo = ++sSeqNo;
                }
            }

            key.seqNo = noKeySeqNo;

            // 合算辞書に追加する。
            if (!dic.ContainsKey(key))
            {
                dic.Add(key, data);
            }
        }
    }
}