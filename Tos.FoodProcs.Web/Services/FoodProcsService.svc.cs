using System;
using System.Collections.Generic;
using System.Data.Services;
using System.Data.Services.Common;
using System.Linq;
using System.ServiceModel.Web;
using System.Web;
using Tos.FoodProcs.Web.Data;
using System.Data;
using System.Net;

namespace Tos.FoodProcs.Web.Services
{

    /// <summary>
    /// WCF Data Services によって Web ページに対して REST サービスを公開します。
    /// エンティティセット 単位でのパーシャルクラスでの拡張を行うために partial キーワードを付与します。
    /// </summary>
    public partial class FoodProcsService : DataService<FoodProcsEntities>
    {
        // このメソッドは、サービス全体のポリシーを初期化するために、1 度だけ呼び出されます。
        public static void InitializeService(DataServiceConfiguration config)
        {
            // TODO: 表示や更新などが可能なエンティティ セットおよびサービス操作を示す規則を設定してください
            // 例:
            // config.SetEntitySetAccessRule("MyEntityset", EntitySetRights.AllRead);
           
            config.SetEntitySetAccessRule("ma_futai", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_futai_kettei", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_shokuba", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_niuke", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kojo", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_haigo_mei", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_haigo_recipe", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_bunrui", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_hinmei", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_seizo_line", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_line", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_tani", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_sagyo", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_hakari", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_fundo", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_hin", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_hokan", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kaisha", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_konyu", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_calendar", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_zei", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kura", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_torihiki", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_keikaku_seihin", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_juryo", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_genshizai_keikaku", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_keikaku_shikakari", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_tonyu_jokyo", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_zan", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_torihiki", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_mark", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_chosei", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_riyu", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_jotai", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_zaiko", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_zaiko_keisan", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("su_keikaku_shikakari", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_comment", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("wk_nonyu", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_haigo_keisan_hoho", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_tanto", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_baurate", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_kuraire", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_parity", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_databit", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_stopbit", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_handshake", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_label_read", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_range", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_shiyo_h", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_shiyo_b", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("wk_zaiko_keisan", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_kuraire", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_chui_kanki", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_chui_kanki", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_chui_kanki_genryo", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_shiyo_genka", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_genka_tanka", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("cn_kino_sentaku", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_kuradashi", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_location", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_soko", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_genka_center", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_nonyu", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_niuke", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_sap_shiyo_yojitsu_anbun", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_shikakari_zan_shiyo", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_shiyo_shikakari_zan", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_lot_trace", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("tr_sap_getsumatsu_zaiko_denso_taisho_zen", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_plc", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_kbn_niuke", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            config.SetEntitySetAccessRule("ma_batch_control", EntitySetRights.AllRead | EntitySetRights.AllWrite);
            // Viewの利用
            config.SetEntitySetAccessRule("vw_ma_haigo_mei_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_haigo_mei_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_futai_kettei_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_futai_kettei_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_seizo_line_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_seizo_line_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hakari_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_tanto_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_juryo_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_haigo_recipe_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_haigo_recipe_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_keikaku_seihin_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_keikaku_seihin_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_torihiki_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_zan_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_sagyo_mark_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_chosei_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_04", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_03", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_05", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_06", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_07", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_zaiko_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_mark", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_nonyu_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_nonyu_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_tani_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_09", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_kojo_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_konyu_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_genshizai_keikaku_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_shiyo_yojitsu_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hakari_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_shiyo_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_10", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_chui_kanki_genryo", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_genka_tanka_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_genka_center_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_sap_bom_denso_pool", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_sap_shiyo_yojitsu_anbun_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_sap_shiyo_yojitsu_anbun_02", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_shikakari_zan_shiyo_01", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_keikaku_seihin_exists", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_11", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_hinmei_12", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_ma_niuke_kbn_niuke", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_soko_info", EntitySetRights.AllRead);
            config.SetEntitySetAccessRule("vw_tr_niuke_lot_sentaku", EntitySetRights.AllRead);
            // TODO: ここまで

            config.DataServiceBehavior.MaxProtocolVersion = DataServiceProtocolVersion.V2;
        }

        /// <summary>
        /// Data Services で発生した例外をハンドルします。
        /// ここではサーバーのエラーログにエラー情報を記録し、例外の詳細な情報をクライアントに通知するよう設定しています。
        /// </summary>
        /// <param name="args">発生した例外の詳細と、関連する HTTP 応答の詳細を格納した引数。</param>
        protected override void HandleException(HandleExceptionArgs args)
        {
            Logging.Logger.App.Error(args.Exception.Message, args.Exception);

            args.UseVerboseErrors = true;

            //同時実行エラーをハンドルして呼び出し元に返します。
            if (args.Exception != null && args.Exception is OptimisticConcurrencyException || args.Exception.InnerException is OptimisticConcurrencyException)
            {
                throw new DataServiceException((int)HttpStatusCode.Conflict, Properties.Resources.OptimisticConcurrencyError);
            }

            //TODO: ここに個別でデータベースで発生した例外のハンドルを追加します。
            System.Data.UpdateException updateException = args.Exception as System.Data.UpdateException;
            if (updateException != null)
            {
                System.Data.SqlClient.SqlException ex = updateException.InnerException as System.Data.SqlClient.SqlException;
                if (ex != null)
                {
                    if (ex.Number == Data.SqlErrorNumbers.PrimaryKeyViolation)
                    {
                        throw new DataServiceException((int)HttpStatusCode.InternalServerError, Properties.Resources.PrimaryKeyViolation);
                    }

                    if (ex.Number == Data.SqlErrorNumbers.NotNullAllow)
                    {
                        throw new DataServiceException((int)HttpStatusCode.InternalServerError, Properties.Resources.NotNullAllow);
                    }
                }
            }
        }
    }
}
