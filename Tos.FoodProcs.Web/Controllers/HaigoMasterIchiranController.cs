using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.OData;
using System.Web.Http.OData.Query;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using System.Net.Http.Formatting;
using System.Data.Objects;

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
	public class HaigoMasterIchiranController : ApiController
	{
        // GET api/HaigoMasterIchiran
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public IEnumerable<usp_HaigoMasterIchiran_select_Result> Get([FromUri]HaigoMasterIchiranCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HaigoMasterIchiran_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_HaigoMasterIchiran_select(
                criteria.kbn_hin,
                criteria.kbn_master,
                criteria.dt_shokichi,
                criteria.flg_mishiyo,
                criteria.cd_bunrui,
                FoodProcsCommonUtility.changedNullToEmpty(criteria.nm_haigo),
                criteria.lang,
                //ActionConst.HanNoShokichi
                //criteria.sysDate
                criteria.dt_from
                , ActionConst.FlagTrue
                , ActionConst.FlagFalse
                ).ToList();
            var result = new StoredProcedureResult<usp_HaigoMasterIchiran_select_Result>();
            return views;
        }

		// POST api/HaigoMasterIchiran
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_haigo_mei> value)
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

			// 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
			DuplicateSet<ma_haigo_mei> duplicates = new DuplicateSet<ma_haigo_mei>();
            // 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<ma_haigo_mei> invalidations = new InvalidationSet<ma_haigo_mei>();

			// 変更セットを元に削除対象のエンティティを削除します。
			if (value.Deleted != null)
			{
				foreach (var deleted in value.Deleted)
				{
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    //validationMessage = ValidateKey(context, deleted);
                    validationMessage = ValidateMasterTable(context, deleted);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_haigo_mei>(validationMessage, deleted, Resources.NotExsists));
                        continue;
                    }

                    // 既存エンティティを取得します。
                    ma_haigo_mei current = GetSingleEntity(context, deleted);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_haigo_mei>(deleted, current));
                        continue;
                    }

                    // 削除用のストアドプロシージャを実行します。
                    context.usp_HaigoMaster_delete(deleted.cd_haigo);
                    context.usp_HaigoRecipeMaster_delete(deleted.cd_haigo);
                    context.usp_SeizoLineMaster_delete(deleted.cd_haigo, ActionConst.HaigoMasterKbn);
                }
			}

            // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
            // エラー情報を返します；。
            if (invalidations.Count > 0)
            {
                // エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSet<ma_haigo_mei>>(HttpStatusCode.BadRequest, invalidations);
            }

			// 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
			// コンテントに競合したデータを設定します。
			if (duplicates.Deleted.Count > 0)
			{
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_haigo_mei>>(HttpStatusCode.Conflict, duplicates);
			}

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
				}
			}

			return Request.CreateResponse(HttpStatusCode.OK);
		}

        /// <summary>
        /// エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        /// </summary>
        /// <param name="context">エンティティ</param>
        /// <param name="haigo_mei">検索条件</param>
        /// <returns>チェック結果</returns>
        private string ValidateKey(FoodProcsEntities context, ma_haigo_mei haigo_mei)
        {
            // 戻り値を定義
            var status = new ObjectParameter("status", 0);
            var table = new ObjectParameter("table", 0);
            // ストアド実行
            var result = context.usp_Haigo_delete_chk(haigo_mei.cd_haigo, status, table);
            // 戻り値からメッセージを判断
            return (int)status.Value == 0 ? string.Empty : String.Format(Resources.MS0001, table.Value);
        }

		/// <summary>
		/// 既存エンティティを取得します。
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="haigo_mei">検索条件</param>
		/// <returns>既存エンティティ</returns>
		private ma_haigo_mei GetSingleEntity(FoodProcsEntities context, ma_haigo_mei haigo_mei)
		{
            var result = context.ma_haigo_mei.SingleOrDefault(ma => (ma.cd_haigo == haigo_mei.cd_haigo
                                                                && ma.no_han == haigo_mei.no_han
                                                                ));
			return result;
        }

		/// <summary>
        /// 整合性チェック：対象のテーブルに存在する場合は削除不可
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="ma">対象のエンティティ</param>
		/// <returns>チェック結果</returns>
        private String ValidateMasterTable(FoodProcsEntities context, ma_haigo_mei ma)
        {
            string condition = ma.cd_haigo;

            /////// 風袋決定マスタ(ma_futai_kettei) ///////
            var maFutaiKettei = (from m in context.ma_futai_kettei
                                 where m.cd_hinmei == condition
                                 select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maFutaiKettei != null)
            {
                return getValidateErrorMassage(Resources.FutaiKetteiMaster, condition);
            }

            /////// 品名マスタ(ma_hinmei) ///////
            var maHinmei = (from m in context.ma_hinmei
                                 where m.cd_haigo == condition
                                 select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maHinmei != null)
            {
                return getValidateErrorMassage(Resources.HinmeiMaster, condition);
            }

            /////// 重量マスタ(ma_juryo) ///////
            var maJuryo = (from m in context.ma_juryo
                           where m.cd_hinmei == condition
                           select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maJuryo != null)
            {
                return getValidateErrorMassage(Resources.JuryoMaster, condition);
            }

            // エラーなし：空文字を返却
            return string.Empty;
        }

        /// <summary>
        /// 整合性チェックのエラーメッセージを返却します。
        /// フォーマット・・・MS0001 + スペース + コード： + 該当のコード
        /// </summary>
        /// <param name="tableName">対象のテーブル名</param>
        /// <param name="code">該当データのコード</param>
        /// <returns>エラーメッセージ</returns>
        private string getValidateErrorMassage(string tableName, string code)
        {
            return String.Format(Resources.MS0001, tableName)
                + ActionConst.StringSpace + ActionConst.StringSpace
                + Resources.Code + ActionConst.Colon + code;
        }

        /// <summary>
        /// タイムスタンプの値を比較します。
        /// </summary>
        /// <param name="left">値1</param>
        /// <param name="right">値2</param>
        /// <returns>チェック結果</returns>
		private bool CompareByteArray(byte[] left, byte[] right)
		{
			if (left.Length != right.Length)
			{
				return false;
			}
			for (int i = 0; i < left.Length; i++)
			{
				if (left[i] != right[i])
				{
					return false;
				}
			}
			return true;
		}
	}
}