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

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class HinmeiMasterController : ApiController
	{
        // GET api/ma_hinmei
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_HinmeiMasterIchiran_select_Result> Get([FromUri]HinmeiMasterIchiranCriteria criteria) {
            FoodProcsEntities context = new FoodProcsEntities();
            IEnumerable<usp_HinmeiMasterIchiran_select_Result> views;
            views = context.usp_HinmeiMasterIchiran_select(
                criteria.con_kbn_hin,
                criteria.con_bunrui,
                criteria.con_kbn_hokan,
                ChangedNullToEmpty(criteria.con_hinmei),
                criteria.mishiyo_hyoji,
                criteria.lang,
                criteria.kbnUriagesaki,
                criteria.kbnSeizomoto,
                criteria.flgShiyo,
                criteria.hanNo
                ).AsEnumerable();

            // 「クエリの結果を複数回列挙できません」対策
            List<usp_HinmeiMasterIchiran_select_Result> list
                = views.ToList<usp_HinmeiMasterIchiran_select_Result>();
            var result = new StoredProcedureResult<usp_HinmeiMasterIchiran_select_Result>();

            int maxCount = (int)criteria.top;
            int resultCount = list.Count();
            result.__count = resultCount;
            
            if (resultCount > maxCount)
            {
                // 上限数を超えていた場合
                int deleteCount = resultCount - (maxCount + 1); // 削除数
                list.RemoveRange(maxCount + 1, deleteCount);
                result.d = list.AsEnumerable();
            }
            else
            {
                result.d = list.AsEnumerable();
            }

            return result;
        }
       
        // POST api/ma_hinmei
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<ma_hinmei> value)
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
            DuplicateSet<ma_hinmei> duplicates = new DuplicateSet<ma_hinmei>();

            // 整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<ma_hinmei> invalidations = new InvalidationSet<ma_hinmei>();

            // 変更セットを元に追加対象のエンティティを追加します。
            if (value.Created != null)
            {
                foreach (var created in value.Created)
                {
                    // エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                    validationMessage = ValidateNotExistKeys(context, created);

                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        // バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                        invalidations.Add(new Invalidation<ma_hinmei>(validationMessage, created, Resources.NotExsists));
                        continue;
                    }
                    // UTC日付をセットする
                    created.dt_create = DateTime.UtcNow;
                    created.dt_update = DateTime.UtcNow;

                    // エンティティを追加します。
                    context.AddToma_hinmei(created);
                }
            }

            // 変更セットを元に更新対象のエンティティを更新します。
            if (value.Updated != null)
            {
                foreach (var updated in value.Updated)
                {
                    // 既存エンティティを取得します。
                    ma_hinmei current = GetSingleEntity(context, updated.cd_hinmei);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, updated.ts))
                    {                    
                        duplicates.Updated.Add(new Duplicate<ma_hinmei>(updated, current));
                        continue;
                    }

                    // UTC日付をセットする
                    updated.dt_update = DateTime.UtcNow;
                    // 作成日、作成者は既存データから取得
                    updated.dt_create = current.dt_create;
                    updated.cd_create = current.cd_create;

                    // エンティティを更新します。
                    context.ma_hinmei.ApplyOriginalValues(updated);
                    context.ma_hinmei.ApplyCurrentValues(updated);
                }
            }

            // 変更セットを元に削除対象のエンティティを削除します。
            if (value.Deleted != null)
            {
                foreach (var deleted in value.Deleted)
                {
                    // 整合性チェック：削除時、対象テーブルに該当データが存在する場合はエラー
                    validationMessage = ValidateMasterTable(context, deleted);
                    if (!String.IsNullOrEmpty(validationMessage))
                    {
                        invalidations.Add(new Invalidation<ma_hinmei>(validationMessage, deleted, Resources.UnDeletableRecord));
                        continue;
                    }

                    // 既存エンティティを取得します。
                    ma_hinmei current = GetSingleEntity(context, deleted.cd_hinmei);

                    // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                    // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                    if (current == null || !CompareByteArray(current.ts, deleted.ts))
                    {
                        duplicates.Deleted.Add(new Duplicate<ma_hinmei>(deleted, current));
                        continue;
                    }

                    // エンティティを削除します。
                    context.DeleteObject(current);
                }
            }

            // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
            // エラー情報を返します；。
            if (invalidations.Count > 0)
            {
                // エンティティの型に応じたInvalidationSetを返します。
                return Request.CreateResponse<InvalidationSet<ma_hinmei>>(HttpStatusCode.BadRequest, invalidations);
            }

            // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
            // コンテントに競合したデータを設定します。
            if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
            {
                // エンティティの型に応じたDuplicateSetを返します。
                return Request.CreateResponse<DuplicateSet<ma_hinmei>>(HttpStatusCode.Conflict, duplicates);
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
        /// 既存エンティティを取得します。
        /// </summary>
        /// <param name="context">エンティティの変更セット</param>
        /// <param name="cd_hinmei">品名コード</param>
        /// <returns>取得した既存エンティティ果</returns>
        private ma_hinmei GetSingleEntity(FoodProcsEntities context, string cd_hinmei)
        {
            var result = context.ma_hinmei.SingleOrDefault(ma => ma.cd_hinmei == cd_hinmei);
            return result;
        }

        /// <summary>
        /// エンティティに対する、マスタ非存在チェックを行います。
        /// </summary>
        /// <param name="context">エンティティの変更セット</param>
        /// <param name="hinmei">品名マスタエンティティ</param>
        /// <returns>チェック結果：エラーの場合メッセージを返却</returns>
        private string ValidateNotExistKeys(FoodProcsEntities context, ma_hinmei hinmei)
        {
            var master = (from c in context.ma_hinmei
                          where c.cd_hinmei == hinmei.cd_hinmei
                          select c).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return master != null ? Resources.MS0027 : string.Empty;
        }

		/// <summary>
        /// 整合性チェック：対象のテーブルに存在する場合は削除不可
		/// </summary>
		/// <param name="context">エンティティ</param>
		/// <param name="ma">対象のエンティティ</param>
		/// <returns>チェック結果</returns>
        private String ValidateMasterTable(FoodProcsEntities context, ma_hinmei ma)
        {
            /////// 風袋決定マスタ(ma_futai_kettei) ///////
            var maFutaiKettei = (from m in context.ma_futai_kettei
                                 where m.cd_hinmei == ma.cd_hinmei
                                 select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maFutaiKettei != null)
            {
                return getValidateErrorMassage(Resources.FutaiKetteiMaster, ma.cd_hinmei);
            }

            /////// 配合レシピマスタ(ma_haigo_recipe) ///////
            var maHaigoRecipe = (from m in context.ma_haigo_recipe
                                 where m.cd_hinmei == ma.cd_hinmei
                                 select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maHaigoRecipe != null)
            {
                return getValidateErrorMassage(Resources.HaigoRecipeMaster, ma.cd_hinmei);
            }

            /////// 重量マスタ(ma_juryo) ///////
            var maJuryo = (from m in context.ma_juryo
                           where m.cd_hinmei == ma.cd_hinmei
                           select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maJuryo != null)
            {
                return getValidateErrorMassage(Resources.JuryoMaster, ma.cd_hinmei);
            }

            /////// 原資材購入先マスタ(ma_konyu) ///////
            var maKonyu = (from m in context.ma_konyu
                           where m.cd_hinmei == ma.cd_hinmei
                           select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maKonyu != null)
            {
                return getValidateErrorMassage(Resources.GenshizaiKonyusakiMaster, ma.cd_hinmei);
            }

            /////// 製造ラインマスタ(ma_seizo_line) ///////
            var maSeizoLine = (from m in context.ma_seizo_line
                           where m.cd_haigo == ma.cd_hinmei
                           select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maSeizoLine != null)
            {
                return getValidateErrorMassage(Resources.SeizoLineMaster, ma.cd_hinmei);
            }

            /////// 資材使用マスタボディ(ma_shiyo_b) ///////
            var maShiyoBody = (from m in context.ma_shiyo_b
                               where m.cd_shizai == ma.cd_hinmei
                               || m.cd_hinmei == ma.cd_hinmei
                               select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maShiyoBody != null)
            {
                return getValidateErrorMassage(Resources.ShizaiShiyoMasterBody, ma.cd_hinmei);
            }

            /////// 資材使用マスタヘッダ(ma_shiyo_h) ///////
            var maShiyoHead = (from m in context.ma_shiyo_h
                               where m.cd_hinmei == ma.cd_hinmei
                               select m).FirstOrDefault();
            // 存在する場合、メッセージを返却
            if (maShiyoHead != null)
            {
                return getValidateErrorMassage(Resources.ShizaiShiyoMasterHeader, ma.cd_hinmei);
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

        /// <summary>「null」が文字列で入っていた場合、空文字に変更します。</summary>
        /// <param name="value">判定したい文字列</param>
        /// <returns>判定後の文字列</returns>
        private String ChangedNullToEmpty(String value)
        {
            if (value == "null")
            {
                value = "";
            }
            return value;
        }
	}
}