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
    public class ShikakarihinShikomiKeikakuController : ApiController
    {
        // GET api/ShikakarihinShikomiKeikaku
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_ShikakarihinShikomiKeikaku_select_Result> Get([FromUri]ShikakarihinShikomiKeikakuCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();

            // ストアド用に値を判定
            IEnumerable<usp_ShikakarihinShikomiKeikaku_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_ShikakarihinShikomiKeikaku_select(
                criteria.cd_shokuba
                , criteria.cd_line
                , criteria.dt_hiduke
                , short.Parse(criteria.flg_kakutei)
                , short.Parse(criteria.flg_mikakutei)
                , criteria.skip, criteria.top
                , ActionConst.FlagTrue
                , ActionConst.FlagFalse
                , count).ToList();

            var result = new StoredProcedureResult<usp_ShikakarihinShikomiKeikaku_select_Result>();
            result.d = views;

            int _cnt = ((List<usp_ShikakarihinShikomiKeikaku_select_Result>)views).Count;
            // 取得件数が0件以上の場合
            if (_cnt > 0)
            {
                result.__count = (int)views.ElementAt<usp_ShikakarihinShikomiKeikaku_select_Result>(0).cnt;
            }
            // 取得件数が0件の場合
            else
            {
                result.__count = ((List<usp_ShikakarihinShikomiKeikaku_select_Result>)views).Count;
            }

            return result;
        }

        // POST api/ShikakarihinShikomiKeikaku
        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<su_keikaku_shikakari> value)
        {
            // パラメータのチェックを行います。
            if (value == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;

            // 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            //InvalidationSet<su_keikaku_shikakari> invalidations = new InvalidationSet<su_keikaku_shikakari>();
            //string validationMessage = string.Empty;

            // 画面から取得したUpdated内の変更データに対して下記実施
            // ①サマリ削除
            // ②サマリ作成
            // ③予実トラン削除
            // ④予実トラン作成
            // 合算考慮はしなくてよい
            // ※※ 確定フラグを変更したのみの場合は、仕掛品ロット番号を採番しなおさない ※※

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
                        // 変更セットを元に更新対象のエンティティを更新します。
                        if (value.Updated != null)
                        {
                            foreach (var updated in value.Updated)
                            {
                                String newShikakariLotNumber = updated.no_lot_shikakari;
                            
                                // 対象の仕掛品の変更前データを取得する。
                                su_keikaku_shikakari suShikakari = (from tr in context.su_keikaku_shikakari
                                                                    where tr.no_lot_shikakari == updated.no_lot_shikakari
                                                                    select tr).AsEnumerable().FirstOrDefault();
                                // 変更内容のチェック処理を行う。
                                bool isChange = checkUpdated(updated, suShikakari);

                                // 実績チェック
                                // チェックエラー時はInvalidOperationExceptionがthrowされる
                                //FoodProcsCommonUtility.checkKeikakuJissekiFlag(context, "", newShikakariLotNumber, "", updated.dt_seizo);

                                // 確定フラグ以外に変更があった場合、
                                if (isChange)
                                {
                                    // 実績が確定されている場合、エラーを表示する。
                                    if (suShikakari.flg_jisseki == 1)
                                    {
                                        string errorMsg = String.Format(
                                        Resources.MS0743, Resources.NonyuIraishoPdfChange, updated.no_lot_shikakari);
                                        InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                                        ioe.Data.Add("key", "MS0743");
                                        throw ioe;
                                    }
                                }

                                // 確定フラグ以外に変更があった場合、仕掛品ロット番号を採番しなおす
                                //bool isChange = checkUpdated(updated, context);
                                //if (isChange)
                                //{
                                //    newShikakariLotNumber = FoodProcsCommonUtility.executionSaiban(
                                //    ActionConst.ShikakariLotSaibanKbn, ActionConst.ShikakariLotPrefixSaibanKbn, context);
                                //}

                                // ①、②：サマリ削除→作成 （画面で入力できる項目を更新）
                                context.usp_ShikakariKeikakuSummary_update(
                                    updated.dt_seizo
                                    , updated.cd_shikakari_hin
                                    , updated.cd_shokuba
                                    , updated.cd_line
                                    , updated.no_lot_shikakari
                                    , updated.flg_shikomi
                                    , updated.wt_shikomi_keikaku
                                    , updated.ritsu_keikaku
                                    , updated.ritsu_keikaku_hasu
                                    , updated.su_batch_keikaku
                                    , updated.su_batch_keikaku_hasu
                                    , ActionConst.FlagTrue
                                    , updated.wt_haigo_keikaku
                                    , updated.wt_haigo_keikaku_hasu
                                    //, updated.FlagTrue
                                    , suShikakari.flg_jisseki
                                    , newShikakariLotNumber
                                    , isChange
                                    , ActionConst.nashiLabelPrintFlg
                                );

                                // 確定フラグ以外に変更があった場合は、使用予実を更新(DELETE→INSERT)
                                if (isChange)
                                {
                                    // ③：予実トラン削除
                                    // 先にロット番号でDELETEし、後からまとめてINSERTする。
                                    // １件ずつDEL→INSするとロット番号が変わらないかつ同品コードがあった場合に、先に追加したレコードが削除されてしまう為。
                                    context.usp_ShikakarihinShikomi_ShiyoYojitsu_delete(
                                        ActionConst.YoteiYojitsuFlag
                                        , updated.dt_seizo
                                        , null
                                        , updated.no_lot_shikakari
                                    );

                                    // 原料を取得
                                    List<RecipeTenkaiObject> recipeList = GetRecipeList(updated, context);

                                    foreach (var val in recipeList)
                                    {
                                        // ④：予実トラン作成
                                        tr_shiyo_yojitsu created = new tr_shiyo_yojitsu();
                                        var shiyo_seq = FoodProcsCommonUtility.executionSaiban(
                                            ActionConst.ShiyoYojitsuSeqNoSaibanKbn, ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn, context);
                                        created.no_seq = shiyo_seq;
                                        created.flg_yojitsu = ActionConst.YoteiYojitsuFlag;
                                        created.cd_hinmei = val.recipeHinmeiCode;
                                        created.dt_shiyo = val.seizoDate;
                                        created.no_lot_shikakari = newShikakariLotNumber;
                                        created.su_shiyo = val.keikakuShikomiJuryo;
                                        // エンティティを追加します。
                                        context.AddTotr_shiyo_yojitsu(created);
                                        
                                        //context.usp_ShiyoYojitsu_delete_insert(
                                        //    ActionConst.YoteiYojitsuFlag
                                        //    , val.recipeHinmeiCode
                                        //    , val.seizoDate
                                        //    , null
                                        //    , updated.no_lot_shikakari
                                        //    , null
                                        //    , newShikakariLotNumber
                                        //    , val.keikakuShikomiJuryo
                                        //    , ActionConst.ShiyoYojitsuSeqNoSaibanKbn
                                        //    , ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn
                                        //);
                                    }
                                }
                            }
                        }

                        // トランザクションコミット
                        context.SaveChanges();
                        transaction.Commit();
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
                        // 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
                        // ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
                        Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
                        return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
                    }
                    catch (InvalidOperationException ioe)
                    {
                        var errCode = ioe.Data["key"];
                        if (errCode != null)
                        {
                            //if (errCode == "MS0707")  // コードで処理を分岐する場合、コメントアウトを外す
                            //{
                            // 展開途中の仕掛品に製造可能ラインがなかった場合のエラー
                            return Request.CreateResponse(HttpStatusCode.BadRequest, ioe);
                            //}
                        }
                        throw ioe;
                    }
                    catch (Exception ex)
                    {
                        Exception serviceError = new Exception(Resources.ServiceErrorForClient, ex);
                        return Request.CreateResponse(HttpStatusCode.BadRequest, serviceError);
                    }
                }
            }

            return Request.CreateResponse(HttpStatusCode.OK);
        }

        /// <summary>
        /// 画面のバッチ数と倍率を元に、倍率オブジェクトリストを作成する
        /// </summary>
        /// <param name="data">画面データ</param>
        /// <returns>倍率オブジェクトリスト</returns>
        private List<BairitsuObject> GetBairotsuObjList(su_keikaku_shikakari data)
        {
            List<BairitsuObject> bairitsuList = new List<BairitsuObject>();
            RecipeTenkaiObject recipeObj = new RecipeTenkaiObject();
            recipeObj.keikakuBatchSu = (decimal)data.su_batch_keikaku;
            recipeObj.keikakuBatchSuHasu = (decimal)data.su_batch_keikaku_hasu;
            recipeObj.keikakuBairitsu = (decimal)data.ritsu_keikaku;
            recipeObj.keikakuBairitsuHasu = (decimal)data.ritsu_keikaku_hasu;
            recipeObj.haigoCode = data.cd_shikakari_hin;
            BairitsuObject bObj = new BairitsuObject(recipeObj, null);
            bairitsuList.Add(bObj);

            return bairitsuList;
        }

        /// <summary>
        /// 自分の原料を取得。自家原料は「展開あり」でも原料として扱う。
        /// 仕掛品の展開処理は行わない。
        /// </summary>
        /// <param name="data">画面データ</param>
        /// <param name="context">エンティティ</param>
        /// <returns>原料リスト</returns>
        private List<RecipeTenkaiObject> GetRecipeList(su_keikaku_shikakari data, FoodProcsEntities context)
        {
            List<RecipeTenkaiObject> recipeList = new List<RecipeTenkaiObject>();
            IEnumerable<usp_RecipeTenkai_Result> recipeViews =
                    context.usp_RecipeTenkai_FromHaigo_select(
                    null
                    , data.cd_shikakari_hin
                    , data.cd_shokuba
                    , data.cd_line
                    , data.dt_seizo
                    , ActionConst.FirstKaiso
                    , data.no_lot_shikakari
                    , ActionConst.FlagFalse
                    , ActionConst.HaigoMasterKbn
                    , ActionConst.FlagFalse
                    , ActionConst.HinmeiMasterKbn
                    , ActionConst.ShikakariHinKbn
                    , ActionConst.JikaGenryoHinKbn
            );
            String recipeKbnHin;
            RecipeTenkaiObject recipeObj;

            // 倍率オブジェクトの作成
            List<BairitsuObject> bairitsuList = GetBairotsuObjList(data);

            foreach (var val in recipeViews)
            {
                if (string.IsNullOrEmpty(val.cd_line) || string.IsNullOrEmpty(val.cd_shokuba))
                {
                    // 展開した仕掛品のラインコードまたは職場コードが存在しなかった場合、エラーとする
                    DateTime dtSeizo = (DateTime)val.dt_seizo;
                    dtSeizo = dtSeizo.AddHours(9);
                    string errorMsg = String.Format(
                        Resources.MS0707, dtSeizo.ToString(ActionConst.DateFormat), val.cd_haigo);
                    InvalidOperationException ioe = new InvalidOperationException(errorMsg);
                    ioe.Data.Add("key", "MS0707");
                    //throw new Exception(errorMsg);
                    throw ioe;
                }
                recipeObj = new RecipeTenkaiObject(val);
                recipeObj.hitsuyoDate = data.dt_seizo;
                recipeKbnHin = val.recipe_kbn_hin.ToString();
                recipeObj.recipeHinKubun = recipeKbnHin;

                // 原料または自家原料のデータをリストに設定していく
                if (recipeKbnHin == ActionConst.GenryoHinKbn.ToString()
                    || recipeKbnHin == ActionConst.JikaGenryoHinKbn.ToString())
                {
                    decimal budomari = Decimal.Parse(recipeObj.recipeBudomari);
                    if (budomari == 0)
                    {
                        budomari = ActionConst.persentKanzan;
                    }
                    FoodProcsCalculator.calcSuryoForGenryo(recipeObj, bairitsuList, budomari);
                    recipeList.Add(recipeObj);
                }
            }

            return recipeList;
        }

        /// <summary>
        /// 変更内容のチェック。
        /// 確定フラグ以外にも変更があった場合はtrueを、確定フラグのみの変更だった場合はfalseを返却する。
        /// </summary>
        /// <param name="updated">変更セット</param>
     //   /// <param name="context">エンティティ</param>
        /// <param name="suShikakari">仕掛品サマリ</param>
        /// <returns>true/false</returns>
        //private Boolean checkUpdated(su_keikaku_shikakari updated, su_keikaku_shikakari context)
        private Boolean checkUpdated(su_keikaku_shikakari updated, su_keikaku_shikakari suShikakari)
        {
            // チェック結果
            var checkResult = false;

            // 既存データを取得
            //var current = context.su_keikaku_shikakari.SingleOrDefault(
                //su => (su.no_lot_shikakari == updated.no_lot_shikakari));

            //if (current != null)
            if(suShikakari != null)
            {
                //if (current.flg_shikomi != updated.flg_shikomi)
                //{
                    ///// 確定フラグに変更があった場合

                // 小数点以下の桁数を画面に合わせる
                //decimal cur_ritsu = (decimal)suShikakari.ritsu_keikaku;
                //cur_ritsu = (Math.Floor(cur_ritsu * 100)) / 100;
                //decimal cur_ritsu_hasu = (decimal)suShikakari.ritsu_keikaku_hasu;
                //cur_ritsu_hasu = (Math.Floor(cur_ritsu_hasu * 100)) / 100;

                // 仕込量、倍率、倍率端数、バッチ数、バッチ数の端数の値がnullの場合は０を設定する。
                decimal cur_wt_shikomi_keikaku = 0m;
                decimal cur_ritsu = 0m;
                decimal cur_ritsu_hasu = 0m;
                decimal cur_batch_keikaku  = 0m;
                decimal cur_batch_keikaku_hasu = 0m;
                    
                if (suShikakari.wt_shikomi_keikaku != null)
                {
                    cur_wt_shikomi_keikaku = (decimal)suShikakari.wt_shikomi_keikaku;
                }

                if (suShikakari.ritsu_keikaku != null)
                {
                    cur_ritsu = (decimal)suShikakari.ritsu_keikaku;
                    cur_ritsu = (Math.Floor(cur_ritsu * 100)) / 100;
                }

                if (suShikakari.ritsu_keikaku_hasu != null)
                {
                    cur_ritsu_hasu = (decimal)suShikakari.ritsu_keikaku_hasu;
                    cur_ritsu_hasu = (Math.Floor(cur_ritsu_hasu * 100)) / 100;
                }

                if (suShikakari.su_batch_keikaku != null)
                {
                    cur_batch_keikaku = (decimal)suShikakari.su_batch_keikaku;
                }

                if (suShikakari.su_batch_keikaku_hasu != null)
                {
                    cur_batch_keikaku_hasu = (decimal)suShikakari.su_batch_keikaku_hasu;
                }

                    // 確定フラグ以外にも変更があった場合はtrueを返却する
                    //if (current.wt_shikomi_keikaku != updated.wt_shikomi_keikaku
                    if(suShikakari.wt_shikomi_keikaku != updated.wt_shikomi_keikaku
                        || cur_ritsu != updated.ritsu_keikaku
                        || cur_ritsu_hasu != updated.ritsu_keikaku_hasu
                        //|| suShikakari.su_batch_keikaku != updated.su_batch_keikaku
                        //|| suShikakari.su_batch_keikaku_hasu != updated.su_batch_keikaku_hasu)
                        || cur_batch_keikaku != updated.su_batch_keikaku
                        || cur_batch_keikaku_hasu != updated.su_batch_keikaku_hasu)

                    {
                        checkResult = true;
                    }
                //}
                //else
                //{
                //    // 確定フラグに変更がない＝確定フラグ以外に変更がある
                //    checkResult = true;
                //}
            }

            return checkResult;
        }
    }
}