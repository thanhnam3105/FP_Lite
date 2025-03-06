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
using System.Data.Objects;
using Newtonsoft.Json.Linq;

namespace Tos.FoodProcs.Web.Controllers {

	[Authorize]
	[LoggingExceptionFilter]
	public class GenshizaiHendoHyoController : ApiController {

		// GET api/GenshizaiHendoHyo
		/// <summary>
		/// クライアントから送信された検索条件を基に検索処理を行います。
		/// </summary>
		/// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_GenshizaiHendoHyo_select_Result> Get([FromUri]GenshizaiHendoHyoCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
			// タイムアウト時間変更(0=無限)
			context.CommandTimeout = 0;
			IEnumerable<usp_GenshizaiHendoHyo_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_GenshizaiHendoHyo_select(
                criteria.cd_hinmei
                , criteria.dt_hizuke
                , ActionConst.JissekiYojitsuFlag
                , ActionConst.YoteiYojitsuFlag
                , ActionConst.FlagFalse
                , ActionConst.KgKanzanKbn
                , ActionConst.LKanzanKbn
                , criteria.dt_hizuke_to
                , criteria.today
                , ActionConst.kbn_zaiko_ryohin
                , count).ToList();

            var result = new StoredProcedureResult<usp_GenshizaiHendoHyo_select_Result>();

            result.d = views;
            result.__count = (int)count.Value;

            return result;
        }

		// GET api/GenshizaiHendoHyo
		/// <summary>
		/// クライアントから送信された検索条件を基に品名マスタ情報を取得します。
		/// </summary>
		/// <param name="con_hinmeiCode">検索条件/品名コード</param>
        public IEnumerable<usp_GenshizaiHendoHyo_select_hinmei_Result> Get(string con_hinmeiCode)
        {
            DateTime sysdate = new DateTime(DateTime.Now.Year, DateTime.Now.Month, DateTime.Now.Day);
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_GenshizaiHendoHyo_select_hinmei_Result> result;
            result = context.usp_GenshizaiHendoHyo_select_hinmei(
                con_hinmeiCode
                , ActionConst.FlagFalse
                , ActionConst.GenryoHinKbn
                , ActionConst.ShizaiHinKbn
                , ActionConst.JikaGenryoHinKbn
                , ActionConst.TaniCodeCase
                , sysdate
            ).AsEnumerable();

            return result;
        }

		// POST api/GenshizaiHendoHyo
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<GenshizaiHendoHyoData> value) {
			string validationMessage = string.Empty;
		
			// パラメータのチェックを行います。
			if (value == null) {
				return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
			}

			FoodProcsEntities context = new FoodProcsEntities();
            UserController user = new UserController();
            UserInfo userInfo = user.Get();

            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;

			// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
			DuplicateSet<GenshizaiHendoHyoData> duplicates = new DuplicateSet<GenshizaiHendoHyoData>();
			// 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<GenshizaiHendoHyoData> invalidations = new InvalidationSet<GenshizaiHendoHyoData>();

            short mishiyo = ActionConst.FlagFalse;
            //var soko = (from ma in context.ma_soko
                        //where ma.flg_mishiyo == mishiyo
                         //select ma).FirstOrDefault();

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
			            // 【更新】変更セットを元に更新対象のエンティティを更新します。
			            if (value.Updated != null) {
				            foreach (var updated in value.Updated) {
                                ///// エンティティを更新します。
                                decimal su_ko = (decimal)updated.su_ko;
                                decimal su_iri = (decimal)updated.su_iri;
                                decimal su_nonyu;
                                if (updated.su_nonyu_yotei == null)
                                {
                                    su_nonyu = (decimal)0;
                                }
                                else {
                                    su_nonyu = (decimal)updated.su_nonyu_yotei;
                                }
                                decimal cs;
                                decimal hasu;
                                var data = FoodProcsCalculator.calcNonyu(su_ko, su_iri, su_nonyu, updated.cd_tani);
                                cs = data[0].nonyu;
                                hasu = data[0].nonyu_hasu;

                                // ★在庫トラン用工場マスタデータ取得
                                var master_kojo = context.ma_kojo.SingleOrDefault(ma => ma.cd_kaisha == userInfo.KaishaCode && ma.cd_kojo == userInfo.BranchCode);
                                string cd_riyu = master_kojo.cd_riyu;                    //理由コード
                                string cd_genka_center = master_kojo.cd_genka_center;    //原価センターコード
                                //string cd_soko = master_kojo.cd_soko;                    //倉庫コード

                                var cdSoko = (from sokoInfo in context.vw_soko_info
                                              where sokoInfo.cd_hinmei == updated.cd_hinmei
                                              select sokoInfo.cd_soko).FirstOrDefault();

					            // 各トラン更新制御
                                if (updated.su_nonyu_yotei == null || updated.su_nonyu_yotei == 0)
                                {
                                    updated.flg_delete_tr_nonyu = short.Parse(Resources.FlagTrue);
                                    updated.flg_update_tr_nonyu = short.Parse(Resources.FlagFalse);
                                }
                                else
                                {
                                    updated.flg_delete_tr_nonyu = short.Parse(Resources.FlagTrue);
                                    updated.flg_update_tr_nonyu = short.Parse(Resources.FlagTrue);
                                }

                                if (updated.su_chosei == null || updated.su_chosei == 0)
                                {
                                    updated.flg_delete_tr_chosei = short.Parse(Resources.FlagTrue);
                                    updated.flg_update_tr_chosei = short.Parse(Resources.FlagFalse);
                                }
                                else
                                {
                                    updated.flg_delete_tr_chosei = short.Parse(Resources.FlagTrue);
                                    updated.flg_update_tr_chosei = short.Parse(Resources.FlagTrue);
                                }

					            updated.flg_delete_tr_zaiko_keisan = short.Parse(Resources.FlagTrue);
					            updated.flg_update_tr_zaiko_keisan = short.Parse(Resources.FlagTrue);

                                if (updated.su_jitsuzaiko == null)
                                {
                                    updated.flg_delete_tr_zaiko = short.Parse(Resources.FlagTrue);
                                    updated.flg_update_tr_zaiko = short.Parse(Resources.FlagFalse);
                                }
                                else
                                {
                                    updated.flg_delete_tr_zaiko = short.Parse(Resources.FlagTrue);
                                    updated.flg_update_tr_zaiko = short.Parse(Resources.FlagTrue);
                                }

                                // 予定数更新時、実績に紐づく予定が編集可能になっていた場合は更新を止め、メッセージを表示します。
                                if (GetKoshin(context, updated.cd_hinmei, updated.dt_hizuke,updated.su_nonyu_yotei) == true)
                                {
                                    if (GetNoNonyu(context, updated.cd_hinmei, updated.dt_hizuke) == true)
                                    {
                                        return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.MS0823);
                                    }
                                }

					            // 追加用のストアドプロシージャを実行
                                context.usp_GenshizaiHendoHyo_update(
                                    Resources.ChoseiSaibanKbn,
                                    Resources.ChoseiPrefixSaibanKbn,
                                    Resources.NonyuSaibanKbn,
                                    Resources.NonyuPrefixSaibanKbn,
                                    updated.cd_hinmei,
                                    updated.dt_hizuke,
                                    updated.su_nonyu_yotei,
                                    updated.su_chosei,
                                    updated.su_keisanzaiko,
                                    updated.su_jitsuzaiko,
                                    updated.cd_update,
                                    short.Parse(Resources.YoteiYojitsuFlag),
                                    short.Parse(Resources.ChoseiRiyuKbn),
                                    updated.flg_update_tr_chosei,
                                    updated.flg_delete_tr_chosei,
                                    updated.flg_update_tr_nonyu,
                                    updated.flg_delete_tr_nonyu,
                                    updated.flg_update_tr_zaiko_keisan,
                                    updated.flg_delete_tr_zaiko_keisan,
                                    updated.flg_update_tr_zaiko,
                                    updated.flg_delete_tr_zaiko, 
                                    ActionConst.KgKanzanKbn, 
                                    ActionConst.LKanzanKbn,
                                    cs,
                                    hasu,
                                    ActionConst.kbn_zaiko_ryohin,
                                    //cd_soko,
                                    //updated.cd_niuke_basho,
                                    cdSoko,
                                    ActionConst.kbn_nyuko_yusho,
                                    cd_genka_center,
                                    cd_riyu
					            );
				            }
			            }

			            // 【削除】セットを元に削除対象のエンティティを削除します。
			            //if (value.Deleted != null) {
			            //}

			            // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			            // エラー情報を返します；。
			            if (invalidations.Count > 0)
			            {
				            // エンティティの型に応じたInvalidationSetを返します。
				            return Request.CreateResponse<InvalidationSet<GenshizaiHendoHyoData>>(HttpStatusCode.BadRequest, invalidations);
			            }

			            // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			            // コンテントに競合したデータを設定します。
			            if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
			            {
				            // エンティティの型に応じたDuplicateSetを返します。
                            return Request.CreateResponse<DuplicateSet<GenshizaiHendoHyoData>>(HttpStatusCode.BadRequest, duplicates);
			            }

                        // コミット
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

        // 日付ごとの予定数の更新の有無を返します。
        private bool GetKoshin(FoodProcsEntities context, String cd_hinmei, DateTime dt_nonyu,decimal? yotei)
        {
            var result = false;
            decimal? su = 0;
            decimal? hasu = 0;
            decimal? yoteisu = yotei * 1000;
            var NoNonyu = context.tr_nonyu.Where(tr => tr.cd_hinmei == cd_hinmei && tr.dt_nonyu == dt_nonyu && tr.flg_yojitsu == ActionConst.YoteiYojitsuFlag);
            foreach (var n in NoNonyu)
            {
               su += n.su_nonyu * 1000;
               hasu += n.su_nonyu_hasu;
            }
            if(yoteisu != (su + hasu))
            {
                result = true;
            }
            return result;
        }

        // 更新対象日付に存在する予定の納入番号を取得し、紐づく実績の有無を返します。
        private bool GetNoNonyu(FoodProcsEntities context, String cd_hinmei, DateTime dt_nonyu)
        {
            var result = false;
            var NoNonyu = context.tr_nonyu.Where(tr => tr.cd_hinmei == cd_hinmei && tr.dt_nonyu == dt_nonyu && tr.flg_yojitsu == ActionConst.YoteiYojitsuFlag);
            foreach (var n in NoNonyu)
            {
                // 実績が1つでもあればtrueを返します。
                if (GetFlgYojitsu(context, n.no_nonyu) > 0)
                {
                    result = true;
                    break;
                }
            }
            return result;
        }

        // 予定に紐づく実績の数を返します。
        private long GetFlgYojitsu(FoodProcsEntities context, String no_nonyu)
        {
            var count = context.tr_nonyu.LongCount(tr => tr.no_nonyu == no_nonyu && tr.flg_yojitsu == ActionConst.JissekiYojitsuFlag);
            return count;
        }
	}
}