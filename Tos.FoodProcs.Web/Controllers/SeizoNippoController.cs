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
	public class SeizoNippoController : ApiController {

        // GET api/SeizoNippo
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_SeizoNippo_select_Result> Get([FromUri]SeizoNippoCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_SeizoNippo_select_Result> views;

            var result = new StoredProcedureResult<usp_SeizoNippo_select_Result>();

            views = context.usp_SeizoNippo_select(
                criteria.dt_seizo
                , criteria.cd_shokuba
                , criteria.cd_line
                , ActionConst.HinmeiMasterKbn
                , ActionConst.shiyoJissekiAnbunKubunSeizo
                , ActionConst.shiyoJissekiAnbunKubunZan
                , ActionConst.FlagFalse
                , short.Parse(criteria.skip.Value.ToString())
                , short.Parse(criteria.top.Value.ToString())
                , false
                ).ToList();

            result.d = views;
            return result;
        }

		// POST api/SeizoNippo
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		//public HttpResponseMessage Post([FromBody]ChangeSet<tr_keikaku_seihin> value) {
        public HttpResponseMessage Post([FromBody]ChangeSets<SeizoNippoCriteria, UchiwakeInfo> values)
        {
			string validationMessage = string.Empty;
            string validationUchiwakeKey = "uchiwakeZaiko";
			InvalidationSet<tr_keikaku_seihin> invalidations = new InvalidationSet<tr_keikaku_seihin>();

			// パラメータのチェックを行います。
            //if (value == null) {
            if (values == null || values.First == null || values.Second == null)
            {
				return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
			}

            // 親明細用
            ChangeSet<SeizoNippoCriteria> value = values.First;
            // 内訳明細用
            ChangeSet<UchiwakeInfo> uchiwake = values.Second;


			FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;

            // 内訳チェック処理
            bool isValid = isValidUchiwake(context, uchiwake);
            if (!isValid)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, validationUchiwakeKey);
            }

            // トランザクションを開始し、エンティティの変更をデータベースに反映します。
			// 更新処理に失敗した場合、例外が発生し、トランザクションは暗黙的にロールバックされます。
			// 個別でチェック処理を行いロールバックを行う場合には明示的に
			// IDbTransaction インタフェースの Rollback メソッドを呼び出します。
			using (IDbConnection connection = context.Connection) {
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
                                // 製品ロット番号の採番
                                string noLotSeihin = FoodProcsCommonUtility.executionSaiban(
                                    ActionConst.SeihinLotSaibanKbn, ActionConst.SeihinLotPrefixSaibanKbn, context);

                                // 追加用のストアドプロシージャを実行します。
                                context.usp_SeizoNippo_create(
                                    //ActionConst.SeihinLotSaibanKbn
                                    //, ActionConst.SeihinLotPrefixSaibanKbn
                                    noLotSeihin
                                    , created.dt_seizo
                                    , created.cd_shokuba
                                    , created.cd_line
                                    , created.cd_hinmei
                                    , created.su_seizo_yotei
                                    , created.su_seizo_jisseki
                                    , created.flg_jisseki
                                    , ActionConst.JissekiYojitsuFlag
                                    , ActionConst.ShiyoYojitsuSeqNoSaibanKbn
                                    , ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn
                                    , ActionConst.FlagFalse.ToString()
                                    , ActionConst.persentKanzan
                                    , created.su_batch_jisseki
                                    , created.dt_shomi
                                    , created.no_lot_hyoji
                                );

                                // 原価使用トランの更新
                                saveGenkaShiyo(context, created, noLotSeihin);


                                // 内訳登録(親明細が新規登録の場合)
                                List<UchiwakeInfo> uchiwakeList = (from u in uchiwake.Created
                                                                   where u.id_row_parent == created.id_row
                                                                   select u).ToList();
                                foreach (UchiwakeInfo li in uchiwakeList)
                                {
                                    // 親明細で登録する製品ロット番号を格納
                                    li.no_lot_seihin = noLotSeihin;
                                    AddUchiwakeData(context, li);

                                    // 重複登録しないようにchangeSetから削除。
                                    uchiwake.Created.Remove(li);
                                }
                            }
                        }

                        // 内訳登録(親明細が既存データの場合)
                        if (uchiwake.Created != null)
                        {
                            List<UchiwakeInfo> uchiwakeCreated = uchiwake.Created;
                            foreach (UchiwakeInfo li in uchiwakeCreated)
                            {
                                // 登録処理
                                AddUchiwakeData(context, li);
                            }
                        }

                        // 変更セットを元に更新対象のエンティティを更新します。
                        if (value.Updated != null)
                        {
                            short densoJotaiKbnMidenso = ActionConst.densoJotaiKbnMidenso;

                            foreach (var updated in value.Updated)
                            {
                                // 原料ロットトレース情報の削除処理
                                var oldFlgJisseki = context.tr_keikaku_seihin.Where(m => m.no_lot_seihin == updated.no_lot_seihin).FirstOrDefault().flg_jisseki;

                                // 確定チェックが外されていた場合だけを取ります
                                if (oldFlgJisseki.ToString() == Resources.FlagTrue && updated.flg_jisseki.ToString() == Resources.FlagFalse)
                                {
                                    var trLotTrace = context.tr_lot_trace.Where(m => m.no_niuke == updated.no_lot_seihin).OrderBy(m => m.no_seq).ToList();

                                    for (int tr = 0; tr < trLotTrace.Count(); tr++)
                                    {
                                        if (tr == 0)
                                        {
                                            tr_lot_trace current = trLotTrace[tr];

                                            current.no_niuke = null;
                                            current.cd_update = User.Identity.Name;
                                            current.dt_update = TimeZoneInfo.ConvertTimeToUtc(DateTime.Now);

                                            context.tr_lot_trace.ApplyOriginalValues(current);
                                            context.tr_lot_trace.ApplyCurrentValues(current);
                                        }
                                        else
                                        {
                                            context.tr_lot_trace.DeleteObject(trLotTrace[tr]);
                                        }
                                    }
                                }

                                // 更新用のストアドプロシージャを実行します。
                                updated.dt_update = DateTime.UtcNow;
                                context.usp_SeizoNippo_update(
                                    updated.no_lot_seihin
                                    , updated.dt_seizo
                                    , updated.cd_hinmei
                                    , updated.su_seizo_jisseki
                                    , updated.flg_jisseki
                                    , ActionConst.JissekiYojitsuFlag
                                    , ActionConst.ShiyoYojitsuSeqNoSaibanKbn
                                    , ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn
                                    , ActionConst.FlagFalse.ToString()
                                    , ActionConst.persentKanzan
                                    , updated.su_batch_jisseki
                                    , updated.dt_shomi
                                    , updated.no_lot_hyoji
                                    , updated.isCheckAnbun
                                    , densoJotaiKbnMidenso
                                );                                

                                // 原価使用トランの更新
                                saveGenkaShiyo(context, updated, null);                                

                                // 確定チェックを外した場合、関連する按分トランを削除
                                //if (ActionConst.FlagFalse.Equals(updated.flg_jisseki))
                                //{
                                //    context.usp_ShiyoYojitsuAnbunTran_delete(string.Empty, updated.no_lot_seihin);
                                //}
                            }
                        }

                        // 内訳更新
                        if (uchiwake.Updated != null)
                        {
                            List<UchiwakeInfo> uchiwakeUpdated = uchiwake.Updated;
                            foreach (UchiwakeInfo li in uchiwakeUpdated)
                            {
                                // 既存行取得
                                tr_shiyo_yojitsu shiyo = GetShiyoYojitsuCurrent(context, li);
                                tr_shiyo_shikakari_zan zan = GetShikakariZanCurrent(context, li);

                                shiyo.flg_yojitsu = ActionConst.JissekiYojitsuFlag;
                                shiyo.su_shiyo = li.su_shiyo;
                                zan.su_shiyo = li.su_shiyo;

                                // エンティティを更新します。
                                context.tr_shiyo_yojitsu.ApplyOriginalValues(shiyo);
                                context.tr_shiyo_yojitsu.ApplyCurrentValues(shiyo);
                                context.tr_shiyo_shikakari_zan.ApplyOriginalValues(zan);
                                context.tr_shiyo_shikakari_zan.ApplyCurrentValues(zan);
                            }
                        }

                        // 変更セットを元に削除対象のエンティティを削除します。
                        if (value.Deleted != null)
                        {
                            short densoJotaiKbnMisakusei = ActionConst.densoJotaiKbnMisakusei;
                            short shiyoJissekiAnbunKubunSeizo = short.Parse(ActionConst.shiyoJissekiAnbunKubunSeizo);
                            short shiyoJissekiAnbunKubunChosei = short.Parse(ActionConst.shiyoJissekiAnbunKubunChosei);

                            foreach (var deleted in value.Deleted)
                            {
                                // 削除用のストアドプロシージャを実行します。
                                context.usp_SeizoNippo_delete(
                                    short.Parse(Properties.Resources.FlagTrue)
                                    , deleted.dt_seizo
                                    , deleted.cd_hinmei
                                    , deleted.no_lot_seihin
                                    , short.Parse(Resources.JissekiYojitsuFlag)
                                );

                                // 原価使用トランの削除処理
                                context.usp_GenkaShiyo_delete(deleted.no_lot_seihin, null);

                                // 関連する按分トランを削除←廃止
                                //context.usp_ShiyoYojitsuAnbunTran_delete(string.Empty, deleted.no_lot_seihin);
                                // 関連する按分トランを更新と削除する
                                context.usp_ShiyoYojitsuAnbunTran_delete_02(
                                    deleted.no_lot_seihin
                                    , densoJotaiKbnMisakusei
                                    , shiyoJissekiAnbunKubunSeizo
                                    , shiyoJissekiAnbunKubunChosei
                                    );
                            }
                        }

                        // 内訳削除
                        if (uchiwake.Deleted != null)
                        {
                            List<UchiwakeInfo> uchiwakeDeleted = uchiwake.Deleted;
                            foreach (UchiwakeInfo li in uchiwakeDeleted)
                            {
                                // 既存行取得
                                tr_shiyo_yojitsu shiyo = GetShiyoYojitsuCurrent(context, li);
                                tr_shiyo_shikakari_zan zan = GetShikakariZanCurrent(context, li);

                                // エンティティを削除します。
                                if (shiyo != null)
                                {
                                    context.DeleteObject(shiyo);
                                }
                                if (zan != null)
                                {
                                    context.DeleteObject(zan);
                                }
                            }
                        }

                        // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
                        // エラー情報を返します；。
                        if (invalidations.Count > 0)
                        {
                            // エンティティの型に応じたInvalidationSetを返します。
                            return Request.CreateResponse<InvalidationSet<tr_keikaku_seihin>>(HttpStatusCode.BadRequest, invalidations);
                        }

                        context.SaveChanges();
                        transaction.Commit();
                    }
                    catch (OptimisticConcurrencyException oex)
                    {
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
        /// 原価使用トランの保存処理。
        /// 更新対象の製品情報よりレシピ展開処理を行い、取得した原料、自家原料の保存処理を行う。
        /// ※資材は使用予実トランの数量を使用するので対象外
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="value">明細一行分のデータ</param>
        /// <param name="newNoLotSeihin">採番された製品ロット番号</param>
        //private void saveGenkaShiyo(FoodProcsEntities context, tr_keikaku_seihin value, string newNoLotSeihin)
        private void saveGenkaShiyo(FoodProcsEntities context, SeizoNippoCriteria value, string newNoLotSeihin)
        {
            // 確定フラグにチェックがある場合のみ、処理を行う
            if (value.flg_jisseki == ActionConst.FlagTrue)
            {
                // レシピ展開処理の準備
                HendoHyoSimulationRecipeTenkaiDAO dao = new HendoHyoSimulationRecipeTenkaiDAO(context);
                Dictionary<ShikakariGassanKey, RecipeTenkaiObject> dic =
                    new Dictionary<ShikakariGassanKey, RecipeTenkaiObject>();
                List<RecipeTenkaiObject> recipeList = new List<RecipeTenkaiObject>();
                // 原料のサマリ用キーリスト
                List<dynamic> genryoKeys = new List<dynamic>();
                // 倍率オブジェクトは品名ごとに変わるのでこのタイミングで作成
                List<BairitsuObject> bairitsuList = new List<BairitsuObject>();
                // 製品ロット番号の設定
                String noLotSeihin = value.no_lot_seihin;
                if (string.IsNullOrEmpty(noLotSeihin))
                {
                    noLotSeihin = newNoLotSeihin;
                }
                else
                {
                    // 原価使用トランの削除処理
                    context.usp_GenkaShiyo_delete(noLotSeihin, null);
                }

                String haigoCode = null;
                int kaisoSu;

                IEnumerable<usp_RecipeTenkai_Result> hinmeiViews = null;
                hinmeiViews = context.usp_SeihinKeikaku_FromItem_select(
                    value.cd_hinmei, value.su_seizo_jisseki, value.cd_shokuba, value.cd_line, value.dt_seizo, ActionConst.FirstKaiso,
                    ActionConst.FlagFalse, ActionConst.FlagFalse, ActionConst.HaigoMasterKbn, ActionConst.FlagFalse);

                // hinmeiViewsは一件のみ
                RecipeTenkaiObject data;
                foreach (var recipe in hinmeiViews)
                {
                    // 品名情報より仕掛品トランのデータ作成
                    data = new RecipeTenkaiObject(recipe);

                    // 一階層目の計算
                    // 倍率オブジェクトも一緒に作成
                    FoodProcsCalculator.calcSeizoDataFirstRow(data, bairitsuList);

                    // 配合データをレシピ展開してListにadd
                    kaisoSu = (int)recipe.su_kaiso;
                    haigoCode = recipe.cd_haigo;
                    dao.selectHaigo(value.cd_hinmei, haigoCode, kaisoSu, value.dt_seizo, value.dt_seizo, value.cd_shokuba,
                        value.cd_line, recipeList, genryoKeys, bairitsuList, true);
                }

                // 原価使用トランへの保存
                foreach (var recipeData in recipeList)
                {
                    // 配合レシピの品名コードがNULLのものは品名マスタのデータのため除外
                    if (!String.IsNullOrEmpty(recipeData.recipeHinmeiCode))
                    {
                        // 原料と自家原料のみ保存処理を行う
                        if (recipeData.recipeHinKubun == ActionConst.GenryoHinKbn.ToString()
                            || recipeData.recipeHinKubun == ActionConst.JikaGenryoHinKbn.ToString())
                        {
                            // 保存処理
                            // 保存用データ作成
                            tr_shiyo_genka current = createSaveData(context, recipeData, noLotSeihin);
                            // エンティティを追加
                            context.AddTotr_shiyo_genka(current);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// 保存用の原価使用データを作成
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="data">展開した原料/自家原料データ</param>
        /// <param name="noLotSeihin">製品ロット番号</param>
        /// <returns>原価使用データ</returns>
        private tr_shiyo_genka createSaveData(FoodProcsEntities context, RecipeTenkaiObject data, string noLotSeihin) {
            tr_shiyo_genka result = new tr_shiyo_genka();
            string seq = FoodProcsCommonUtility.executionSaiban(
                ActionConst.GenkaShiyoSeqNoSaibanKbn, ActionConst.GenkaShiyoSeqNoPrefixSaibanKbn, context);

            result.no_seq = seq;
            result.cd_hinmei = data.recipeHinmeiCode;
            result.dt_shiyo = data.seizoDate;
            result.no_lot_seihin = noLotSeihin;
            result.su_shiyo = data.hitsuyoJuryo;

            return result;
        }

        /// <summary>
        /// 内訳保存用の使用予実トランデータを作成します。
        /// </summary>
        /// <param name="u">内訳データ</param>
        /// <returns>使用予実トランデータ</returns>
        private tr_shiyo_yojitsu CreateShiyoYojitsuData(UchiwakeInfo u)
        {
            tr_shiyo_yojitsu data = new tr_shiyo_yojitsu();
            data.no_seq = u.no_seq_shiyo_yojitsu;
            data.flg_yojitsu = ActionConst.JissekiYojitsuFlag;
            data.cd_hinmei = u.cd_hinmei;
            data.dt_shiyo = u.dt_seizo;
            data.no_lot_seihin = u.no_lot_seihin;
            data.no_lot_shikakari = null;
            data.su_shiyo = u.su_shiyo;
            return data;
        }

        /// <summary>
        /// 内訳保存用の仕掛残使用量トランデータを作成します。
        /// </summary>
        /// <param name="u">内訳データ</param>
        /// <returns>仕掛残使用量トラン</returns>
        private tr_shiyo_shikakari_zan CreateShikakariZanData(UchiwakeInfo u)
        {
            tr_shiyo_shikakari_zan data = new tr_shiyo_shikakari_zan();
            data.kbn_shiyo_jisseki_anbun = short.Parse(ActionConst.shiyoJissekiAnbunKubunSeizo);
            data.no_lot = u.no_lot_seihin;
            data.no_seq_shiyo_yojitsu_anbun = u.no_seq_shiyo_yojitsu_anbun;
            data.no_seq_shiyo_yojitsu = u.no_seq_shiyo_yojitsu;
            data.su_shiyo = u.su_shiyo;
            return data;
        }

        /// <summary>
        /// 任意の使用予実トランデータを取得します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="u">内訳データ</param>
        /// <returns>使用予実トラン既存データ/null</returns>
        private tr_shiyo_yojitsu GetShiyoYojitsuCurrent(FoodProcsEntities context, UchiwakeInfo u)
        {
            tr_shiyo_yojitsu current = context.tr_shiyo_yojitsu.FirstOrDefault(t => t.no_seq == u.no_seq_shiyo_yojitsu);
            return current;
        }

        /// <summary>
        /// 任意の仕掛残使用料トランデータを取得します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="u">内訳データ</param>
        /// <returns>仕掛残使用料トランデータを取得します。</returns>
        private tr_shiyo_shikakari_zan GetShikakariZanCurrent(FoodProcsEntities context, UchiwakeInfo u)
        {
            short shiyoJissekiAnbunKubunSeizo = short.Parse(ActionConst.shiyoJissekiAnbunKubunSeizo);
            tr_shiyo_shikakari_zan current = context.tr_shiyo_shikakari_zan.FirstOrDefault(
                                                t => t.kbn_shiyo_jisseki_anbun == shiyoJissekiAnbunKubunSeizo
                                                    && t.no_lot == u.no_lot_seihin
                                                    && t.no_seq_shiyo_yojitsu_anbun == u.no_seq_shiyo_yojitsu_anbun);
            return current;
        }

        /// <summary>
        /// 内訳のデータを新規登録します。
        /// </summary>
        /// <param name="context">エンティティ情報</param>
        /// <param name="uchiwakeInfo">内訳明細1行分のデータ</param>
        private void AddUchiwakeData(FoodProcsEntities context, UchiwakeInfo uchiwakeInfo)
        {
            // シーケンス番号を採番します。
            string noSeq = FoodProcsCommonUtility.executionSaiban(
                ActionConst.ShiyoYojitsuSeqNoSaibanKbn, ActionConst.ShiyoYojitsuSeqNoPrefixSaibanKbn, context);

            uchiwakeInfo.no_seq_shiyo_yojitsu = noSeq;
            tr_shiyo_yojitsu shiyo = CreateShiyoYojitsuData(uchiwakeInfo);
            tr_shiyo_shikakari_zan zan = CreateShikakariZanData(uchiwakeInfo);

            // エンティティを追加します。
            context.AddTotr_shiyo_yojitsu(shiyo);
            context.AddTotr_shiyo_shikakari_zan(zan);
        }

        /// <summary>
        /// 内訳の行数分エラーチェックを行います。
        /// </summary>
        /// <param name="context"></param>
        /// <param name="uchiwakeInfo"></param>
        /// <returns></returns>
        private bool isValidUchiwake(FoodProcsEntities context, ChangeSet<UchiwakeInfo> uchiwakeInfo)
        {
            // Created
            if (uchiwakeInfo.Created != null)
            {
                List<UchiwakeInfo> created = uchiwakeInfo.Created;
                foreach (UchiwakeInfo row in created)
                {
                    if (!isValidZaiko(context, uchiwakeInfo, row))
                    {
                        return false;
                    }
                }
            }

            // Updated
            if (uchiwakeInfo.Updated != null)
            {
                List<UchiwakeInfo> updated = uchiwakeInfo.Updated;
                foreach (UchiwakeInfo row in updated)
                {
                    if (!isValidZaiko(context, uchiwakeInfo, row))
                    {
                        return false;
                    }
                }
            }

            return true;
        }

        /// <summary>
        /// 仕掛残の在庫が0未満になる場合はエラーとします。
        /// </summary>
        /// <param name="context"></param>
        /// <param name="u"></param>
        /// <param name="row"></param>
        /// <returns></returns>
        private bool isValidZaiko(FoodProcsEntities context, ChangeSet<UchiwakeInfo> u, UchiwakeInfo row)
        {
            usp_SeizoNippoUchiwake_select_Result record = null;
            decimal zaikoVal = 0;

            // get db data
            List<usp_SeizoNippoUchiwake_select_Result> list = context.usp_SeizoNippoUchiwake_select(
                                                                row.cd_seihin,
                                                                row.no_lot_seihin,
                                                                ActionConst.shiyoJissekiAnbunKubunSeizo,
                                                                ActionConst.shiyoJissekiAnbunKubunZan,
                                                                ActionConst.FlagFalse).ToList();
            if (list != null)
            {
                record = list.FirstOrDefault(t => t.cd_hinmei == row.cd_hinmei
                                            && t.dt_seizo.Value == row.con_dt_seizo
                                            && t.no_lot_shikakari == row.no_lot_shikakari);
            }

            if (record != null)
            {
                zaikoVal = record.su_zaiko ?? 0;
            }

            var cre = (from t in u.Created
                       where t.cd_hinmei == row.cd_hinmei
                        && t.con_dt_seizo == row.con_dt_seizo
                        && t.no_lot_shikakari == row.no_lot_shikakari
                       select t).ToList();
            var upd = (from t in u.Updated
                       where t.cd_hinmei == row.cd_hinmei
                        && t.con_dt_seizo == row.con_dt_seizo
                        && t.no_lot_shikakari == row.no_lot_shikakari
                       select t).ToList();
            var del = (from t in u.Deleted
                       where t.cd_hinmei == row.cd_hinmei
                        && t.con_dt_seizo == row.con_dt_seizo
                        && t.no_lot_shikakari == row.no_lot_shikakari
                       select t).ToList();
            var con = cre.Concat(upd);

            foreach (var d in con)
            {
                zaikoVal = zaikoVal + d.con_su_shiyo;
                zaikoVal = zaikoVal - d.su_shiyo;
            }
            foreach (var d in del)
            {
                zaikoVal = zaikoVal + d.con_su_shiyo;
            }

            if (zaikoVal < 0)
            {
                return false;
            }

            return true;
        }
	}
}