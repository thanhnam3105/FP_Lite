using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Tos.FoodProcs.Web.Data;
using System.Data;
using Tos.FoodProcs.Web.Logging;
using Tos.FoodProcs.Web.Properties;
using System.Data.Objects;
using System;
using System.Data.Objects.DataClasses;
using System.Runtime.Serialization;

namespace Tos.FoodProcs.Web.Controllers
{
    [Authorize]
    [LoggingExceptionFilter]
    public class ShikomiNippoController : ApiController
    {

        // GET api/ShikomiNippo
        /// <summary>
        /// クライアントから送信された検索条件を基に検索処理を行います。
        /// </summary>
        /// <param name="criteria">GET された HTTP リクエストの クエリ に設定された値</param>
        public StoredProcedureResult<usp_ShikomiNippo_select_Result> Get([FromUri]ShikomiNippoCriteria criteria)
        {
            FoodProcsEntities context = new FoodProcsEntities();
            List<usp_ShikomiNippo_select_Result> views;
            var count = new ObjectParameter("count", 0);
            views = context.usp_ShikomiNippo_select(
                 criteria.dt_seizo_st
                , criteria.dt_seizo_en
                , criteria.cd_shokuba
                , criteria.cd_line
                , criteria.chk_mi_sakusei
                , criteria.chk_mi_denso
                , criteria.chk_denso_machi
                , criteria.chk_denso_zumi
                , criteria.chk_mi_toroku
                , criteria.chk_ichibu_mi_toroku
                , criteria.chk_toroku_sumi
                , short.Parse(Resources.FlagFalse)
                , ActionConst.HaigoMasterKbn
                , short.Parse(Resources.GenryoHinKbn)
                , short.Parse(Resources.JikaGenryoHinKbn)
                , criteria.skip
                , criteria.top
                , ActionConst.FlagFalse
            ).ToList();

            var result = new StoredProcedureResult<usp_ShikomiNippo_select_Result>();

            result.d = views;
            if (views.Count == 0)
            {
                result.__count = 0;
            }
            else
            {
                result.__count = (int)views.ElementAt(0).cnt;
            }

            return result;
        }

        /// <summary>
        /// クライアントから送信された変更セットを基に一括更新を行います。
        /// </summary>
        /// <param name="value">POST された HTTP リクエストの BODY に設定された変更セット</param>
        // [Authorize(Roles="")]
        public HttpResponseMessage Post([FromBody]ChangeSet<su_keikaku_shikakari_extend> value)
        {
            string validationMessage = string.Empty;
            InvalidationSet<su_keikaku_shikakari> invalidations = new InvalidationSet<su_keikaku_shikakari>();

            // パラメータのチェックを行います。
            if (value == null)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, Resources.NotNullAllow);
            }

            FoodProcsEntities context = new FoodProcsEntities();
            // バリデーションエラーおよび競合エラー時にクライアントに返却するオブジェクトの遅延読み込み防止
            context.ContextOptions.LazyLoadingEnabled = false;


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
                                // 追加用のストアドプロシージャを実行します。
                                context.usp_ShikomiNippo_create(
                                    Resources.ShikakarihinKeikakuSaibanKbn
                                    , Resources.ShikakarihinKeikakuPrefixSaibanKbn
                                    , Resources.ShikakariLotSaibanKbn
                                    , Resources.ShikakariLotPrefixSaibanKbn
                                    , created.dt_seizo
                                    , created.cd_shikakari_hin
                                    , created.cd_shokuba
                                    , created.cd_line
                                    , created.wt_shikomi_jisseki
                                    , created.wt_zaiko_jisseki
                                    , created.wt_shikomi_zan
                                    , created.su_batch_jisseki
                                    , created.su_batch_jisseki_hasu
                                    , created.ritsu_jisseki
                                    , created.ritsu_jisseki_hasu
                                    , created.flg_jisseki
                                    , ActionConst.GenryoHinKbn
                                    , ActionConst.JikaGenryoHinKbn
                                    , ActionConst.JissekiYojitsuFlag
                                    , ActionConst.HaigoMasterKbn
                                    , ActionConst.FlagFalse
                                    , Resources.ShiyoYojitsuSeqNoSaibanKbn
                                    , Resources.ShiyoYojitsuSeqNoPrefixSaibanKbn
                                );

                                // 登録チェックが付いている明細行についてのみ行う
                                if (created.flg_toroku.ToString() == Resources.FlagTrue)
                                {
                                    string cd_user = User.Identity.Name;
                                    DateTime current = TimeZoneInfo.ConvertTimeToUtc(DateTime.Now);

                                    su_keikaku_shikakari item = context.su_keikaku_shikakari.Where(m => m.dt_seizo == created.dt_seizo && m.cd_shikakari_hin == created.cd_shikakari_hin).FirstOrDefault();

                                    context.usp_LotTrace_delete(created.no_lot_shikakari);
                                    context.usp_LotTrace_insert(
                                        ActionConst.GenryoLotChoseiSeqNoSaibanKbn
                                        , ActionConst.GenryoLotChoseiSeqNoPrefixSaibanKbn
                                        , created.dt_seizo
                                        , created.cd_shikakari_hin
                                        , item.no_lot_shikakari
                                        , short.Parse(Resources.ShikakariHinKbn)
                                        , short.Parse(Resources.GenryoHinKbn)
                                        , short.Parse(Resources.JikaGenryoHinKbn)
                                        , short.Parse(Resources.ShukkoKbn)
                                        , cd_user
                                        , current
                                        , cd_user
                                        , current
                                    );
                                }
                            }
                        }

                        // 変更セットを元に更新対象のエンティティを更新します。
                        if (value.Updated != null)
                        {
                            foreach (var updated in value.Updated)
                            {
                                // 確定チェックが外されていた場合だけを取ります
                                var oldFlgJisseki = context.su_keikaku_shikakari.Where(m => m.no_lot_shikakari == updated.no_lot_shikakari).FirstOrDefault().flg_jisseki;
                                if (oldFlgJisseki.ToString() == Resources.FlagTrue && updated.flg_jisseki.ToString() == Resources.FlagFalse)
                                {
                                    context.usp_LotTrace_delete(updated.no_lot_shikakari);
                                }

                                // 登録チェックが付いている明細行についてのみ行う
                                if (updated.flg_toroku == Resources.FlagTrue)
                                {
                                    string cd_user = User.Identity.Name;
                                    DateTime current = TimeZoneInfo.ConvertTimeToUtc(DateTime.Now);

                                    context.usp_LotTrace_delete(updated.no_lot_shikakari);
                                    context.usp_LotTrace_insert(
                                            ActionConst.GenryoLotChoseiSeqNoSaibanKbn
                                            , ActionConst.GenryoLotChoseiSeqNoPrefixSaibanKbn
                                            , updated.dt_seizo
                                            , updated.cd_shikakari_hin
                                            , updated.no_lot_shikakari
                                            , short.Parse(Resources.ShikakariHinKbn)
                                            , short.Parse(Resources.GenryoHinKbn)
                                            , short.Parse(Resources.JikaGenryoHinKbn)
                                            , short.Parse(Resources.ShukkoKbn)
                                            , cd_user
                                            , current
                                            , cd_user
                                            , current
                                        );
                                }

                                // 更新用のストアドプロシージャを実行します。
                                context.usp_ShikomiNippo_update(
                                    updated.dt_seizo
                                    , updated.cd_shikakari_hin
                                    , updated.wt_shikomi_jisseki
                                    , updated.wt_zaiko_jisseki
                                    , updated.wt_shikomi_zan
                                    , updated.su_batch_jisseki
                                    , updated.su_batch_jisseki_hasu
                                    , updated.ritsu_jisseki
                                    , updated.ritsu_jisseki_hasu
                                    , updated.flg_jisseki
                                    , ActionConst.GenryoHinKbn
                                    , ActionConst.JikaGenryoHinKbn
                                    , ActionConst.JissekiYojitsuFlag
                                    , updated.no_lot_shikakari
                                    , Resources.ShiyoYojitsuSeqNoSaibanKbn
                                    , Resources.ShiyoYojitsuSeqNoPrefixSaibanKbn
                                    , ActionConst.FlagFalse
                                );

                                // 関連する按分トランを削除
                                context.usp_ShiyoYojitsuAnbunTran_delete(updated.no_lot_shikakari, string.Empty);                                                                
                            }
                        }

                        // 変更セットを元に削除対象のエンティティを削除します。
                        if (value.Deleted != null)
                        {
                            foreach (var deleted in value.Deleted)
                            {
                                // 削除用のストアドプロシージャを実行します。
                                context.usp_ShikomiNippo_delete(
                                    ActionConst.FlagTrue
                                    , deleted.dt_seizo
                                    , deleted.cd_shikakari_hin
                                    , deleted.no_lot_shikakari
                                    , ActionConst.JissekiYojitsuFlag
                                    , ActionConst.GenryoHinKbn
                                );

                                // 関連する按分トランを削除
                                context.usp_ShiyoYojitsuAnbunTran_delete(deleted.no_lot_shikakari, string.Empty);

                                // 関連する原料ロットトラン_を削除
                                context.usp_LotTrace_delete(deleted.no_lot_shikakari);
                            }
                        }

                        // 整合性チェックエラーがある場合は、 HttpStatus に 400 を設定し、
                        // エラー情報を返します；。
                        if (invalidations.Count > 0)
                        {
                            // エンティティの型に応じたInvalidationSetを返します。
                            return Request.CreateResponse<InvalidationSet<su_keikaku_shikakari>>(HttpStatusCode.BadRequest, invalidations);
                        }

                        //context.SaveChanges();
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
    }

    public partial class su_keikaku_shikakari_extend : su_keikaku_shikakari
    {
        /// <summary>
        /// No Metadata Documentation available.
        /// </summary>
        [EdmScalarPropertyAttribute(EntityKeyProperty = false, IsNullable = false)]
        [DataMemberAttribute()]
        public global::System.String flg_toroku
        {
            get
            {
                return _flg_toroku;
            }
            set
            {
                Onflg_torokuChanging(value);
                ReportPropertyChanging("flg_toroku");
                _flg_toroku = StructuralObject.SetValidValue(value, false);
                ReportPropertyChanged("flg_toroku");
                Onflg_torokuChanged();
            }
        }
        private global::System.String _flg_toroku;
        partial void Onflg_torokuChanging(global::System.String value);
        partial void Onflg_torokuChanged();
    }
}