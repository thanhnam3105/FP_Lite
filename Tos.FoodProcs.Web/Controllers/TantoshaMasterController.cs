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

namespace Tos.FoodProcs.Web.Controllers
{
	[Authorize]
	[LoggingExceptionFilter]
    public class TantoshaMasterController : ApiController
	{
        // POST api/CombinationMaster
		/// <summary>
		/// クライアントから送信された変更セットを基に一括更新を行います。
		/// </summary>
		/// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
		// [Authorize(Roles="")]
		public HttpResponseMessage Post([FromBody]ChangeSet<vw_ma_tanto_01> value)
		{
			string validationMessage = string.Empty;
            string[] rolesArray;
           
			// パラメータのチェックを行います。
			if (value == null)
			{
				return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
			}

            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;



            // TODO: 同時実行制御エラーの結果を格納するDuplicateSetを定義します。
            DuplicateSet<vw_ma_tanto_01> duplicates = new DuplicateSet<vw_ma_tanto_01>();
            // TODO: ここまで
            // TODO：整合性チェックエラーの結果を格納するInvalidationSetを定義します。
            InvalidationSet<vw_ma_tanto_01> invalidations = new InvalidationSet<vw_ma_tanto_01>();
            // TODO: ここまで

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
                        // 変更セットを元に追加対象のエンティティを追加します。
                        if (value.Created != null)
                        {
                            foreach (var created in value.Created)
                            {
                                // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                                validationMessage = ValidateNotExistKeys(context, created);
                                // TODO: ここまで

                                if (!String.IsNullOrEmpty(validationMessage))
                                {
                                    // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                                    invalidations.Add(new Invalidation<vw_ma_tanto_01>(validationMessage, created, Resources.NotExsists));
                                    // TODO: ここまで
                                    continue;
                                }

                                // TODO: エンティティを追加します。
                                // 担当者マスタ作成
                                context.usp_TantoshaMaster_create(created.cd_tanto
                                                                , created.nm_tanto
                                                                , " ", " ", " ", 0
                                                                , created.flg_kyosei_hoshin
                                                                , created.flg_mishiyo
                                                                , created.cd_create
                                                                ,created.cd_update
                                                                ," "
                                                                , created.kbn_ma_hinmei
                                                                , created.kbn_ma_haigo
                                                                , created.kbn_ma_konyusaki
                                                                , created.kbn_shikomi_chohyo);
                                // メンバーシップテーブル(Membership)、ユーザテーブル(Users)へ追加
                                Membership.CreateUser(created.cd_tanto, created.Password);
                                // ユーザ権限テーブル(UsersInRoles)へ追加
                                Roles.AddUserToRole(created.cd_tanto, created.RoleName);
                                // TODO: ここまで
                            }
                        }

                        // 変更セットを元に更新対象のエンティティを更新します。
                        if (value.Updated != null)
                        {
                            foreach (var updated in value.Updated)
                            {
                                /*
                                // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                                validationMessage = ValidateExistKeys(context, updated);
                                // TODO: ここまで

                                if (!String.IsNullOrEmpty(validationMessage))
                                {
                                    // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                                    invalidations.Add(new Invalidation<vw_ma_tanto_01>(validationMessage, updated, Resources.NotExsists));  
                                    // TODO: ここまで
                                    continue;
                                }
                                // TODO: ここまで
                                */
                                // TODO: 既存エンティティを取得します。
                                vw_ma_tanto_01 current = GetSingleEntity(context, updated.cd_tanto);
                                // TODO: ここまで

                                // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                                // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                                if (current == null || !CompareByteArray(current.ts, updated.ts))
                                {
                                    duplicates.Updated.Add(new Duplicate<vw_ma_tanto_01>(updated, current));
                                    continue;
                                }

                                // TODO: エンティティを更新します。
                                // 担当者マスタ更新
                                context.usp_TantoshaMaster_update(updated.cd_tanto
                                                                , updated.nm_tanto
                                                                , updated.cd_update
                                                                , updated.flg_mishiyo
                                                                , updated.flg_kyosei_hoshin
                                                                , updated.kbn_ma_hinmei
                                                                , updated.kbn_ma_haigo
                                                                , updated.kbn_ma_konyusaki
                                                                , updated.kbn_shikomi_chohyo);
                                /* 
                                // パスワードの更新
                                MembershipUser aspNetUser = Membership.GetUser(updated.cd_tanto);
                                Guid userId = (Guid)aspNetUser.ProviderUserKey;
                                // passwprdを比較
                                var view = (from vw in context.vw_ma_tanto_01
                                              where vw.UserId == userId
                                              select vw).FirstOrDefault();
                                if (!view.Password.Equals(updated.Password))
                                {
                                    // パスワードを更新
                                    string tempPassword = aspNetUser.ResetPassword();
                                    aspNetUser.ChangePassword(tempPassword, updated.Password);
                                }
                                // 現在のロールを取得
                                rolesArray = Roles.GetRolesForUser(updated.cd_tanto);
                                // 現在のロールを削除
                                Roles.RemoveUserFromRole(updated.cd_tanto, rolesArray[0]);
                                // 更新ロールを追加
                                Roles.AddUserToRole(updated.cd_tanto, updated.RoleName);
                                */
                                
                                // パスワードの更新
                                MembershipUser aspNetUser = Membership.GetUser(updated.cd_tanto);
                                
                                Guid userId = (Guid)aspNetUser.ProviderUserKey;
                                var view = (from vw in context.vw_ma_tanto_01
                                              where vw.UserId == userId
                                              select vw).FirstOrDefault();

                                if (aspNetUser == null)
                                {
                                    // 担当者マスタに存在するがユーザテーブルにデータがない場合
                                    // メンバーシップテーブル(Membership)、ユーザテーブル(Users)へ追加
                                    Membership.CreateUser(updated.cd_tanto, updated.Password);
                                }
                                // passwprdを比較
                                else  if (!view.Password.Equals(updated.Password))
                                {
                                    // 通常の更新時
                                    //Guid userId = (Guid)aspNetUser.ProviderUserKey;
                                    // パスワードを更新
                                    string tempPassword = aspNetUser.ResetPassword();
                                    aspNetUser.ChangePassword(tempPassword, updated.Password);
                                }
                                // ロールの更新
                                if (updated.RoleName != null)
                                {
                                    // 現在のロールを取得
                                    rolesArray = Roles.GetRolesForUser(updated.cd_tanto);
                                    if (rolesArray.Length != 0)
                                    {
                                        // 現在のロールを削除
                                        Roles.RemoveUserFromRole(updated.cd_tanto, rolesArray[0]);
                                    }
                                    // 更新ロールを追加
                                    Roles.AddUserToRole(updated.cd_tanto, updated.RoleName);
                                }
                                // TODO: ここまで
                            }
                        }

                        // 変更セットを元に削除対象のエンティティを削除します。
                        if (value.Deleted != null)
                        {
                            foreach (var deleted in value.Deleted)
                            {
                                // TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
                                validationMessage = ValidateBeforeDelete(context, deleted);
                                // TODO: ここまで

                                if (!String.IsNullOrEmpty(validationMessage))
                                {
                                    // TODO: バリデーションエラーの発生した列名を指定してInvalidationSetを追加します。
                                    invalidations.Add(new Invalidation<vw_ma_tanto_01>(validationMessage, deleted, Resources.UnDeletableRecord));
                                    // TODO: ここまで
                                    continue;
                                }

                                // TODO: 既存エンティティを取得します。
                                vw_ma_tanto_01 current = GetSingleEntity(context, deleted.cd_tanto);
                                // TODO: ここまで

                                // 既存行が無い、もしくはタイムスタンプの値が違う場合は、
                                // 他のユーザーに削除もしくは更新されたと判定し、競合データとして扱います。
                                if (current == null || !CompareByteArray(current.ts, deleted.ts))
                                {
                                    duplicates.Deleted.Add(new Duplicate<vw_ma_tanto_01>(deleted, current));
                                    continue;
                                }

                                // TODO:　エンティティを削除します。
                                // 担当者マスタ削除
                                context.usp_TantoshaMaster_delete(deleted.cd_tanto);
                                // メンバーシップテーブル(Membership)、ユーザテーブル(Users)削除、ユーザ権限テーブル(UsersInRoles)削除
                                Membership.DeleteUser(deleted.cd_tanto);
                                // TODO: ここまで
                            }
                        }

                        // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
                        // エラー情報を返します；。
                        if (invalidations.Count > 0)
                        {
                            // TODO: エンティティの型に応じたInvalidationSetを返します。
                            return Request.CreateResponse<InvalidationSet<vw_ma_tanto_01>>(HttpStatusCode.BadRequest, invalidations);
                            // TODO: ここまで
                        }

                        // 更新処理で競合が発生していた場合は、HttpStatus に 409 を設定し、
                        // コンテントに競合したデータを設定します。
                        if (duplicates.Created.Count > 0 || duplicates.Updated.Count > 0 || duplicates.Deleted.Count > 0)
                        {               
                            // TODO: エンティティの型に応じたDuplicateSetを返します。
                            return Request.CreateResponse<DuplicateSet<vw_ma_tanto_01>>(HttpStatusCode.BadRequest, duplicates);
                            // TODO: ここまで
                        }

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
                    catch (UpdateException uex)
                    {
                        
                        SqlException iex = uex.InnerException as SqlException;
                        if (iex != null)
                        {
                            if (iex.Number == Data.SqlErrorNumbers.ForeignKeyViolation)
                            {
                                Logger.App.Error(Properties.Resources.OptimisticConcurrencyError, uex);
                                // SQLServerエラーのレスポンスを生成します
                                return ResponseUtility.CreateFailResponse(HttpStatusCode.InternalServerError, Resources.ForeignKeyViolation);
                            }
                        }
                       
                    }
                }
            }

			return Request.CreateResponse(HttpStatusCode.OK);
		}

        // TODO：既存エンティティを取得します。
        private vw_ma_tanto_01 GetSingleEntity(FoodProcsEntities context, string _code)
        {
            var result = context.vw_ma_tanto_01.SingleOrDefault(ma => ma.cd_tanto == _code);

            return result;
        }
        //// TODO：ここまで

        //// TODO: エンティティに対する整合性チェック (マスタ存在チェックなど) を行います。
        private string ValidateExistKeys(FoodProcsEntities context, vw_ma_tanto_01 ma)
        {
            var master = (from c in context.ma_tanto
                          where c.cd_tanto == ma.cd_tanto
                          select c).FirstOrDefault();

            // 存在しない場合、メッセージを返します
            return master != null ? string.Empty :
                String.Format(Resources.ValidationDataNotFoundMessage, "cd_tanto", ma.cd_tanto);
        }
        //// TODO：ここまで

        //// TODO: エンティティに対する、マスタ非存在チェックを行います。
        private string ValidateNotExistKeys(FoodProcsEntities context, vw_ma_tanto_01 ma)
        {
            var master = (from c in context.ma_tanto
                          where c.cd_tanto == ma.cd_tanto
                          select c).FirstOrDefault();

            // 存在する場合、メッセージを返します
            return master == null ? string.Empty :
                String.Format(Resources.ValidationDataFoundMessage, "cd_tanto", ma.cd_tanto);
        }
        // TODO：ここまで

        //// TODO: エンティティに対する整合性チェック (マスタ存在チェック) を行います。
        private string ValidateBeforeDelete(FoodProcsEntities context, vw_ma_tanto_01 ma)
        {
            var errorMessage = string.Empty;
            // 配合名マスタ
            var haigoMei = (from cntx in context.ma_haigo_mei
                          where cntx.cd_tanto_seizo == ma.cd_tanto
                                || cntx.cd_tanto_hinkan == ma.cd_tanto
                          select cntx).FirstOrDefault();
            errorMessage = haigoMei == null ? string.Empty : Resources.StringSpace + Resources.HaigoMeiMaster;
            
            // 小分けトラン
            var kowake = (from cntx in context.tr_kowake
                             where cntx.cd_tanto_chikan == ma.cd_tanto
                                   || cntx.cd_tanto_kowake == ma.cd_tanto
                             select cntx).FirstOrDefault();
            errorMessage += kowake == null ? string.Empty : Resources.StringSpace + Resources.KowakeTran;
            
            // 投入実績トラン
            var tonyu = (from cntx in context.tr_tonyu
                               where cntx.cd_tanto == ma.cd_tanto
                               select cntx).FirstOrDefault();
            errorMessage += tonyu == null ? string.Empty : Resources.StringSpace + Resources.TonyuTran;
            
            // 投入状況トラン
            var tonyuJyokyo = (from cntx in context.tr_tonyu
                               where cntx.cd_tanto == ma.cd_tanto
                               select cntx).FirstOrDefault();
            errorMessage += tonyuJyokyo == null ? string.Empty : Resources.StringSpace + Resources.TonyuJyokyoTran;
            
            // 残実績トラン
            var zanJisseki = (from cntx in context.tr_zan_jiseki
                               where cntx.cd_tanto == ma.cd_tanto
                               select cntx).FirstOrDefault();
            errorMessage += zanJisseki == null ? string.Empty : Resources.StringSpace + Resources.ZanJissekiTran;

            // 存在しない場合、メッセージを返します
            return errorMessage == string.Empty ? string.Empty :
                String.Format(Resources.MS0001, errorMessage);
        }
        //// TODO：ここまで

        // タイムスタンプの値を比較します。
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