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

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class HendoHyoSimulationController : ApiController {
        // GET api/HendoHyoSimulation
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_HendoHyoSimulation_select_Result> Get([FromUri]HendoHyoSimulationCriteria criteria) {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HendoHyoSimulation_select_Result> selectResult;
            // 検索用ストアドプロシージャの実行
            selectResult = context.usp_HendoHyoSimulation_select(
                criteria.con_cd_hinmei,
                criteria.con_dt_hizuke,
                criteria.flg_one_day,
                criteria.flg_yojitsu_yo,
                criteria.flg_yojitsu_ji,
                ActionConst.KgKanzanKbn,
                ActionConst.LKanzanKbn,
                ActionConst.FlagFalse,
                ActionConst.kbn_zaiko_ryohin,
                criteria.today
            ).AsEnumerable();
            return selectResult;
        }

        // GET api/HendoHyoSimulation
        /// <summary>
        /// クライアントから送信された検索条件を基に、職場コードとラインコードを取得します。
        /// </summary>
        /// <param name="hinCode">品名コード</param>
        /// <param name="shiyoFlag">未使用フラグ：使用</param>
        /// <returns>計画作成用の情報</returns>
        public IEnumerable<usp_HendoHyoSimulationKeikaku_select_Result> Get(string hinCode, short shiyoFlag) {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HendoHyoSimulationKeikaku_select_Result> selectResult;

            // 検索用ストアドプロシージャの実行
            selectResult = context.usp_HendoHyoSimulationKeikaku_select(
                hinCode,
                shiyoFlag,
                ActionConst.HinmeiMasterKbn
            ).AsEnumerable();

            return selectResult;
        }

        // GET api/HendoHyoSimulation
        /// <summary>
        /// クライアントから送信された検索条件を基に、明細資材の情報を取得します。
        /// </summary>
        /// <param name="seiziDate">製造日</param>
        /// <param name="hinCode">品名コード</param>
        /// <param name="shiyoFlag">未使用フラグ：使用</param>
        /// <returns>明細資材の情報</returns>
        public IEnumerable<usp_HendoHyoSimulationShizai_select_Result> Get(DateTime seiziDate, string hinCode, short shiyoFlag) {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HendoHyoSimulationShizai_select_Result> shizaiResult;

            // 検索用ストアドプロシージャの実行
            shizaiResult = context.usp_HendoHyoSimulationShizai_select(
                seiziDate,
                hinCode,
                shiyoFlag
            ).AsEnumerable();

            return shizaiResult;
        }

        // GET api/HendoHyoSimulation
        /// <summary>
        /// クライアントから送信された検索条件を基に明細原料の情報を取得します。
        /// </summary>
        /// <param name="hinmeiCode">品名コード</param>
        /// <param name="su_seizo_yotei">製造数</param>
        /// <param name="dt_seizo">製造日</param>
        /// <param name="shiyoFlag">未使用フラグ：使用</param>
        /// <returns>明細原料の情報</returns>
        public IEnumerable<RecipeTenkaiObject> Get(string hinmeiCode, decimal su_seizo_yotei, DateTime dt_seizo, short shiyoFlag)
        {
            //// 変数宣言
            FoodProcsEntities context = new FoodProcsEntities();
            HendoHyoSimulationRecipeTenkaiDAO dao = new HendoHyoSimulationRecipeTenkaiDAO(context);
            Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic = new Dictionary<ShikakariGassanKey, RecipeTenkaiObject>();
            // 原料のサマリ用キーリスト
            List<dynamic> genryoKeys = new List<dynamic>();

            //　レシピ展開 method start
            List<RecipeTenkaiObject> recipeList = new List<RecipeTenkaiObject>();
            // 倍率オブジェクトは品名ごとに変わるのでこのタイミングで作成
            List<BairitsuObject> bairitsuList = new List<BairitsuObject>();

            // 画面．品名コードを元に、職場コードとラインコードを取得
            // →変動シミュレーションでは職場コードとラインコードは不要
            //IEnumerable<usp_HendoHyoSimulationKeikaku_select_Result> codeInfo = Get(hinmeiCode, shiyoFlag);
            //foreach (var line in codeInfo)
            //{
                IEnumerable<usp_RecipeTenkai_Result> hinmeiViews = null;
                //String hinmeiCode = line.cd_hinmei;
                String haigoCode = null;
                int kaisoSu;

                // 画面の品名コードより品名マスタ、配合名マスタ、資材使用マスタ検索
                hinmeiViews = context.usp_SeihinKeikaku_FromItem_select(
                    hinmeiCode, su_seizo_yotei, null, null, dt_seizo, ActionConst.FirstKaiso, ActionConst.FlagFalse, ActionConst.FlagFalse,
                    ActionConst.HaigoMasterKbn, ActionConst.FlagFalse);

                // サマリデータ作成
                //String noShikakariLot = dao.makeSummaryData(dic, data, Convert.ToInt16(data.gassanShikomiFlag));

                RecipeTenkaiObject data;
                foreach (var recipe in hinmeiViews)
                {
                    // 一階層目の仕掛品の展開フラグ(自動立案フラグ)が立っていれば展開処理を行う。
                    // 展開フラグ(自動立案フラグ)が立っていない場合は処理を終了する。
                    if (recipe.haigo_flg_tenkai == ActionConst.FlagTrue)
                    {
                        data = new RecipeTenkaiObject(recipe);

                        // 一階層目の計算
                        // 倍率オブジェクトも一緒に作成
                        FoodProcsCalculator.calcSeizoDataFirstRow(data, bairitsuList);
                        //recipeList.Add(data);

                        // 配合データをレシピ展開してListにadd(addはdao内で実施)
                        kaisoSu = (int)recipe.su_kaiso;
                        haigoCode = recipe.cd_haigo;
                        dao.selectHaigo(recipe.cd_hinmei, haigoCode, kaisoSu, dt_seizo, DateTime.Today,
                            null, null, recipeList, genryoKeys, bairitsuList, false);
                    }
                }
            //}

            // 使用量(必要重量)の小数点以下第四位を切り上げる
            for (int i = 0; i < recipeList.Count; i++)
            {
                recipeList[i].hitsuyoJuryo = FoodProcsCommonUtility.decimalCeiling(recipeList[i].hitsuyoJuryo, 3);
            }

            return recipeList;
        }

        // POST api/HendoHyoSimulation
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<HendoHyoSimulationData> value)
        {
            // パラメータチェック
            if (value == null) {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            FoodProcsEntities context = new FoodProcsEntities();

            // 同時実行制御エラーの結果を格納するDuplicateSetを定義
            DuplicateSet<HendoHyoSimulationData> duplicates = new DuplicateSet<HendoHyoSimulationData>();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;

            // 変更セットを元に削除対象のデータを削除
            if (value.Deleted != null) {
                foreach (var deleted in value.Deleted) {
                    // 予実フラグ、納入日、品名コードをキーに既存データを取得
                    tr_nonyu current = GetExistsData(context, deleted);

                    if (current == null) {
                        // 削除対象データが存在しない場合

                        // 対象データが削除されたと判定し、競合データとして処理する
                        duplicates.Deleted.Add(new Duplicate<HendoHyoSimulationData>(deleted, null));
                        continue;
                    }

                    // 削除用のストアドプロシージャを実行
                    context.usp_HendoHyoSimulation_delete(deleted.flg_yojitsu, deleted.dt_nonyu, deleted.cd_hinmei);
                }
            }

            // 変更セットを元に追加対象のデータを追加
            if (value.Created != null) {
                foreach (var created in value.Created) {
                    // 納入単位に換算
                    decimal su_ko = (decimal)created.su_ko;
                    decimal su_iri = (decimal)created.su_iri;
                    decimal su_nonyu = (decimal)created.su_nonyu;
                    var data = FoodProcsCalculator.calcNonyu(su_ko, su_iri, su_nonyu, created.cd_tani);
                    created.su_nonyu = data[0].nonyu;
                    created.su_nonyu_hasu = data[0].nonyu_hasu;

                    // 予実フラグ、納入日、品名コードをキーに既存データを取得
                    tr_nonyu current = GetExistsData(context, created);

                    if (current != null) {
                        // 既存データが存在した場合

                        // 削除用のストアドプロシージャを実行
                        context.usp_HendoHyoSimulation_delete(created.flg_yojitsu, created.dt_nonyu, created.cd_hinmei);
                    }

                    // 追加用のストアドプロシージャを実行
                    context.usp_HendoHyoSimulation_create(
                        ActionConst.NonyuSaibanKbn,
                        ActionConst.NonyuPrefixSaibanKbn,
                        created.flg_yojitsu,
                        created.no_nonyu,
                        created.dt_nonyu,
                        created.cd_hinmei,
                        created.su_nonyu,
                        created.su_nonyu_hasu,
                        created.cd_torihiki,
                        created.cd_torihiki2,
                        created.tan_nonyu,
                        created.kin_kingaku,
                        created.no_nonyusho,
                        created.kbn_zei,
                        created.kbn_denso,
                        created.flg_kakutei,
                        created.dt_seizo,
                        ActionConst.kbn_nyuko_yusho
                    );
                }
            }

            // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
            // コンテントに競合したデータを設定します。
            if (duplicates.Created.Count > 0
                || duplicates.Deleted.Count > 0) {

                // エンティティの型に応じたDuplicateSetを返却
                    return Request.CreateResponse<DuplicateSet<HendoHyoSimulationData>>(HttpStatusCode.Conflict, duplicates);
            }

            // トランザクションを開始し、エンティティの変更をデータベースに反映します。
            // 更新処理に失敗した場合、例外が発生し、トランザクションは暗黙的にロールバックされます。
            // 個別でチェック処理を行いロールバックを行う場合には明示的に
            // IDbTransaction インタフェースの Rollback メソッドを呼び出します。
            using (IDbConnection connection = context.Connection) {
                context.Connection.Open();
                using (IDbTransaction transaction = context.Connection.BeginTransaction()) {
                    try {
                        context.SaveChanges();
                        transaction.Commit();
                    } catch (OptimisticConcurrencyException oex) {
                        // 楽観排他制御 (データベース上の timestamp 列による多ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                        return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                    }
                }
            }
            return Request.CreateResponse(HttpStatusCode.OK);
        }

        /// <summary>
        ///  既存データ取得(キー：予実フラグ、納入日、品名コード)
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="nonyu">画面データ</param>
        /// <returns>1件の既存データ</returns>
        private tr_nonyu GetExistsData(FoodProcsEntities context, HendoHyoSimulationData nonyu)
        {
            var result = (from t in context.tr_nonyu
						  where t.flg_yojitsu == nonyu.flg_yojitsu
                             && t.dt_nonyu == nonyu.dt_nonyu
                             && t.cd_hinmei == nonyu.cd_hinmei
						  select t).FirstOrDefault();
            return result;
        }
    }
}