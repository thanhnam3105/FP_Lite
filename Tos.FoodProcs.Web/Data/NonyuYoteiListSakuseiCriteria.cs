using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 納入予定リスト作成検索情報を定義します。
    /// </summary>
    public class NonyuYoteiListSakuseiCriteria {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public NonyuYoteiListSakuseiCriteria() {
        }

        /// <summary>
        /// 日付
        /// </summary>
        public DateTime con_dt_nonyu {
            get;
            set;
        }

        /// <summary>
        /// 品区分
        /// </summary>
        public string con_kbn_hin {
            get;
            set;
        }

        /// <summary>
        /// 品分類
        /// </summary>
        public string con_cd_bunrui {
            get;
            set;
        }

        /// <summary>
        /// 品位状態
        /// </summary>
        public string con_kbn_hokan {
            get;
            set;
        }

        /// <summary>
        /// 取引先コード
        /// </summary>
        public string con_cd_torihiki {
            get;
            set;
        }

        /// <summary>
        /// 予実フラグ：予定
        /// </summary>
        public short flg_yojitsu_yo {
            get;
            set;
        }

        /// <summary>
        /// 予実フラグ：実績
        /// </summary>
        public short flg_yojitsu_ji {
            get;
            set;
        }

        /// <summary>
        /// 未使用フラグ
        /// </summary>
        public short flg_mishiyo {
            get;
            set;
        }


        // 保存ChangeSet用：tr_nonyuの値はカラム名と合わせる

        /// <summary>
        /// 予実フラグ
        /// </summary>
        public short flg_yojitsu { get; set; }

        /// <summary>
        /// 納入番号
        /// </summary>
        public string no_nonyu { get; set; }

        /// <summary>
        /// 納入実績日
        /// <summary>
        public DateTime dt_nonyu { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 納入数
        /// </summary>
        public decimal su_nonyu { get; set; }

        /// <summary>
        /// 納入端数
        /// </summary>
        public decimal su_nonyu_hasu { get; set; }

        /// <summary>
        /// 取引先コード
        /// </summary>
        public string cd_torihiki { get; set; }

        /// <summary>
        /// 取引先コード2
        /// </summary>
        public string cd_torihiki2 { get; set; }

        /// <summary>
        /// 納入単価
        /// </summary>
        public decimal tan_nonyu { get; set; }

        /// <summary>
        /// 金額
        /// </summary>
        public decimal kin_kingaku { get; set; }

        /// <summary>
        /// 納入書番号
        /// </summary>
        public string no_nonyusho { get; set; }

        /// <summary>
        /// 税区分
        /// </summary>
        public short kbn_zei { get; set; }

        /// <summary>
        /// 伝送区分
        /// </summary>
        public short kbn_denso { get; set; }

        /// <summary>
        /// 確定フラグ
        /// </summary>
        public short flg_kakutei { get; set; }
 
        /// <summary>
        /// 製造日
        /// <summary>
        public DateTime dt_seizo { get; set; }

        /// <summary>
        /// 入庫区分
        /// </summary>
        public short kbn_nyuko { get; set; }

        /// <summary>
        /// 入庫区分の編集フラグ
        /// </summary>
        public short flg_edit_kbn_nyuko { get; set; }

        /// <summary>
        /// 入庫区分以外の編集フラグ
        /// </summary>
        public short flg_edit_meisai { get; set; }
 
        /// <summary>
        /// 納入予定日
        /// <summary>
        public DateTime dt_nonyu_yotei { get; set; }

        /// <summary>
        /// 納入予定数
        /// </summary>
        public decimal su_nonyu_yo { get; set; }

        /// <summary>
        /// 納入予定番号
        /// </summary>
        public string no_nonyu_yotei { get; set; }

        /// <summary>
        /// 納入予定端数
        /// </summary>
        public decimal su_nonyu_yo_hasu { get; set; }
   }
}