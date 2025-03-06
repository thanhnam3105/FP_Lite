using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class NenkanCalendarMasterController : ApiController {

		// GET api/ma_calendar
		/// <summary>
		/// クライアントから送信された検索条件を基に検索処理を行います。
		/// </summary>
		/// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
		public StoredProcedureResult<NenkanCalendarMasterResult> Get([FromUri]NenkanCalendarCriteria criteria)
		{
            var yy_nendo = criteria.yy_nendo;
			FoodProcsEntities context = new FoodProcsEntities();
			IEnumerable<usp_NenkanCalendarMaster_select_Result> views = new List<usp_NenkanCalendarMaster_select_Result>();
			IEnumerable<NenkanCalendarMasterResult> returnViews = new List<NenkanCalendarMasterResult>();
            // 検索処理実行⇒結果：日付単位リスト（365日分）、ソート順：日付
			views = context.usp_NenkanCalendarMaster_select(
                            yy_nendo,
                            criteria.cd_kaisha,
                            criteria.cd_kojo,
                            criteria.dt_nendo_start,
                            criteria.cd_user,
                            criteria.lang,
                            Resources.LangJa,
                            Resources.LangEn,
                            Resources.LangZh,
                            Resources.LangVi,
                            criteria.add_hh
                        ).ToList();

            // 1年間分のリスト
			IEnumerable<List<usp_NenkanCalendarMaster_select_Result>> nenList = new List<List<usp_NenkanCalendarMaster_select_Result>>();
            // 画面へ渡す結果リスト（デフォルトサイズに1か月の日数を設定）
			List<NenkanCalendarMasterResult> resultList = new List<NenkanCalendarMasterResult>(Int32.Parse(Resources.MonthDayCount));

            // 日付単位リストを画面表示のために月単位のリストにコンバートする
            DateTime hizuke;
            int month = 0;
            int day = 0;
            int nendoStartMonth = criteria.dt_nendo_start;
            Int32[] months = null;
            int rowIndex = 0;
			NenkanCalendarMasterResult result;
            // 日付単位リストのソート順が日付であることを前提条件する
            foreach (var data in views.ToList<usp_NenkanCalendarMaster_select_Result>()) {
                // UTC日付をローカル日付へフォーマットする
                hizuke = data.dt_hizuke.ToLocalTime();
                month = hizuke.Month;
                day = hizuke.Day;
                rowIndex = day - 1;
                if (months == null) {
                    months = new Int32[Int32.Parse(Resources.MonthCount)];
                    months[0] = month;
                    months[1] = hizuke.AddMonths(1).Month;
                    months[2] = hizuke.AddMonths(2).Month;
                    months[3] = hizuke.AddMonths(3).Month;
                    months[4] = hizuke.AddMonths(4).Month;
                    months[5] = hizuke.AddMonths(5).Month;
                    months[6] = hizuke.AddMonths(6).Month;
                    months[7] = hizuke.AddMonths(7).Month;
                    months[8] = hizuke.AddMonths(8).Month;
                    months[9] = hizuke.AddMonths(9).Month;
                    months[10] = hizuke.AddMonths(10).Month;
                    months[11] = hizuke.AddMonths(11).Month;
                }
                // 検索結果リストの日付より、画面用リストの該当行を取得する
                result = resultList.ElementAtOrDefault(rowIndex);
                // 上記で取得した行の中身がＮＵＬＬの場合
                // データオブジェクトを作成しリストの指定位置に挿入する
                if (result == null) {
                    result = new NenkanCalendarMasterResult();
                    resultList.Insert(rowIndex, result);
                    result.no = day;
                    result.yy_nendo = yy_nendo;
                    result.cd_create = data.cd_create;
                    result.dt_create = data.dt_create;
                }
                if (nendoStartMonth == month) {
                    result.dt_1 = data.dt_hizuke;
                    result.kyujitsu_1 = data.flg_kyujitsu;
                    result.dt_yobi_1 = data.dt_yobi;
                    result.shukujitsu_1 = data.flg_shukujitsu;
                    result.ts_1 = data.ts;
                    result.dt_nendo_start = criteria.dt_nendo_start.ToString();
                }
                else if (months[1] == month) {
                    result.dt_2 = data.dt_hizuke;
                    result.kyujitsu_2 = data.flg_kyujitsu;
                    result.dt_yobi_2 = data.dt_yobi;
                    result.shukujitsu_2 = data.flg_shukujitsu;
                    result.ts_2 = data.ts;
                }
                else if (months[2] == month) {
                    result.dt_3 = data.dt_hizuke;
                    result.kyujitsu_3 = data.flg_kyujitsu;
                    result.dt_yobi_3 = data.dt_yobi;
                    result.shukujitsu_3 = data.flg_shukujitsu;
                    result.ts_3 = data.ts;
                }
                else if (months[3] == month) {
                    result.dt_4 = data.dt_hizuke;
                    result.kyujitsu_4 = data.flg_kyujitsu;
                    result.dt_yobi_4 = data.dt_yobi;
                    result.shukujitsu_4 = data.flg_shukujitsu;
                    result.ts_4 = data.ts;
                }
                else if (months[4] == month) {
                    result.dt_5 = data.dt_hizuke;
                    result.kyujitsu_5 = data.flg_kyujitsu;
                    result.dt_yobi_5 = data.dt_yobi;
                    result.shukujitsu_5 = data.flg_shukujitsu;
                    result.ts_5 = data.ts;
                }
                else if (months[5] == month) {
                    result.dt_6 = data.dt_hizuke;
                    result.kyujitsu_6 = data.flg_kyujitsu;
                    result.dt_yobi_6 = data.dt_yobi;
                    result.shukujitsu_6 = data.flg_shukujitsu;
                    result.ts_6 = data.ts;
                }
                else if (months[6] == month) {
                    result.dt_7 = data.dt_hizuke;
                    result.kyujitsu_7 = data.flg_kyujitsu;
                    result.dt_yobi_7 = data.dt_yobi;
                    result.shukujitsu_7 = data.flg_shukujitsu;
                    result.ts_7 = data.ts;
                }
                else if (months[7] == month) {
                    result.dt_8 = data.dt_hizuke;
                    result.kyujitsu_8 = data.flg_kyujitsu;
                    result.dt_yobi_8 = data.dt_yobi;
                    result.shukujitsu_8 = data.flg_shukujitsu;
                    result.ts_8 = data.ts;
                }
                else if (months[8] == month) {
                    result.dt_9 = data.dt_hizuke;
                    result.kyujitsu_9 = data.flg_kyujitsu;
                    result.dt_yobi_9 = data.dt_yobi;
                    result.shukujitsu_9 = data.flg_shukujitsu;
                    result.ts_9 = data.ts;
                }
                else if (months[9] == month) {
                    result.dt_10 = data.dt_hizuke;
                    result.kyujitsu_10 = data.flg_kyujitsu;
                    result.dt_yobi_10 = data.dt_yobi;
                    result.shukujitsu_10 = data.flg_shukujitsu;
                    result.ts_10 = data.ts;
                }
                else if (months[10] == month) {
                    result.dt_11 = data.dt_hizuke;
                    result.kyujitsu_11 = data.flg_kyujitsu;
                    result.dt_yobi_11 = data.dt_yobi;
                    result.shukujitsu_11 = data.flg_shukujitsu;
                    result.ts_11 = data.ts;
                }
                else if (months[11] == month) {
                    result.dt_12 = data.dt_hizuke;
                    result.kyujitsu_12 = data.flg_kyujitsu;
                    result.dt_yobi_12 = data.dt_yobi;
                    result.shukujitsu_12 = data.flg_shukujitsu;
                    result.ts_12 = data.ts;
                }
            }

            // 返却値へセット
			var resultViews = new StoredProcedureResult<NenkanCalendarMasterResult>();
			resultViews.d = resultList;
			return resultViews;
		}

		// POST api/ma_calendar
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_calendar> value) {
			// パラメータのチェックを行います。
			if (value == null) {
				return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
			}

			FoodProcsEntities context = new FoodProcsEntities();
			// バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
			context.ContextOptions.LazyLoadingEnabled = false;
		
			// TODO: 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
			DuplicateSet<ma_calendar> duplicates = new DuplicateSet<ma_calendar>();
			// TODO: ここまで
			// TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
			InvalidationSet<ma_calendar> invalidations = new InvalidationSet<ma_calendar>();
			// TODO: ここまで

			// 変更セットを元に更新対象のエンティティを更新します。
			if (value.Updated != null) {
				foreach (var updated in value.Updated) {
					// TODO: 既存エンティティを取得します。
					ma_calendar current = GetSingleEntity(context, updated.dt_hizuke);
					// TODO: ここまで

					// 既存行が無い、もしくはタイムスタンプの値が違う場合は、
					// 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
					if (current == null || !CompareByteArray(current.ts, updated.ts)) {
						duplicates.Updated.Add(new Duplicate<ma_calendar>(updated, current));
						continue;
					}

					// UTC日付をセットする
					updated.dt_update = DateTime.UtcNow;

					// TODO: エンティティを更新します。
					context.ma_calendar.ApplyOriginalValues(updated);
					context.ma_calendar.ApplyCurrentValues(updated);
					// TODO: ここまで
				}
			}

			// 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
			// エラー情報を返します；。
			if (invalidations.Count > 0) {
				// TODO: エンティティの型に応じたInvalidationSetを返します。
				return Request.CreateResponse<InvalidationSet<ma_calendar>>(HttpStatusCode.BadRequest, invalidations);
				// TODO: ここまで
			}

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0) {
				// TODO: エンティティの型に応じたDuplicateSetを返します。
				return Request.CreateResponse<DuplicateSet<ma_calendar>>(HttpStatusCode.Conflict, duplicates);
				// TODO: ここまで
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
					}
					catch (OptimisticConcurrencyException oex) {
						// 楽観排他制御 (データベース上の timestamp 列による他ユーザーの更新確認) で発生したエラーをハンドルします。
						// ここではエラーログを出力し、クライアントに対してエラー内容を書き込んだ HttpResponse を作成します。
						Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, oex);
						return Request.CreateErrorResponse(HttpStatusCode.Conflict, oex);
					}
				}
			}
			return Request.CreateResponse(HttpStatusCode.OK);
		}

		// TODO：既存エンティティを取得します。
		private ma_calendar GetSingleEntity(FoodProcsEntities context, DateTime dt_hizuke) {
			var result = context.ma_calendar.SingleOrDefault(ma => ma.dt_hizuke == dt_hizuke);
			return result;
		}
		// TODO：ここまで

		// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
		private string ValidateKey(FoodProcsEntities context, ma_calendar tani) {
			var master = (from m in context.ma_calendar
				  where m.dt_hizuke == tani.dt_hizuke
				  select m).FirstOrDefault();
			return master != null ? Resources.MS0027 : string.Empty;
		}
		// TODO：ここまで

		// タイムスタンプの値を比較します。
		private bool CompareByteArray(byte[] left, byte[] right) {
			if (left.Length != right.Length) {
				return false;
			}
			for (int i = 0; i < left.Length; i++) {
				if (left[i] != right[i]) {
					return false;
				}
			}
			return true;
		}

	}
}