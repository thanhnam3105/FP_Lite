using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 仕込日報検索条件を定義します。
  /// </summary>
    public class ShikomiNippoCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public ShikomiNippoCriteria()
        {
        }

        /// <summary>
        /// 製造日（開始）
        /// </summary>
        public DateTime dt_seizo_st { get; set; }

        /// <summary>
        /// 製造日（終了）
        /// </summary>
        public DateTime dt_seizo_en { get; set; }

        /// <summary>
        /// 職場コード
        /// </summary>
        public string cd_shokuba { get; set; }

        /// <summary>
        /// 職場名
        /// </summary>
        public string nm_shokuba { get; set; }

        /// <summary>
        /// ラインコード
        /// </summary>
        public string cd_line { get; set; }

        /// <summary>
        /// ライン名
        /// </summary>
        public string nm_line { get; set; }

        /// <summary>
        /// 伝送状況チェックボックス【未作成チェック】
        /// </summary>
        public Int16 chk_mi_sakusei { get; set; }

        /// <summary>
        /// 伝送状況チェックボックス【未伝送チェック】
        /// </summary>
        public Int16 chk_mi_denso { get; set; }

        /// <summary>
        /// 伝送状況チェックボックス【伝送待チェック】
        /// </summary>
        public Int16 chk_denso_machi { get; set; }

        /// <summary>
        /// 伝送状況チェックボックス【伝送済チェック】
        /// </summary>
        public Int16 chk_denso_zumi { get; set; }

        /// <summary>
        /// 伝送状況チェックボックスラベル【未作成チェック】
        /// </summary>
        public string lbl_mi_sakusei { get; set; }

        /// <summary>
        /// 伝送状況チェックボックスラベル【未伝送チェック】
        /// </summary>
        public string lbl_mi_denso { get; set; }

        /// <summary>
        /// 伝送状況チェックボックスラベル【伝送待チェック】
        /// </summary>
        public string lbl_denso_machi { get; set; }

        /// <summary>
        /// 伝送状況チェックボックスラベル【伝送済チェック】
        /// </summary>
        public string lbl_denso_zumi { get; set; }

        /// <summary>
        /// 登録状況チェックボックス【未登録チェック】
        /// </summary>
        public Int16 chk_mi_toroku { get; set; }

        /// <summary>
        /// 登録状況チェックボックス【一部未登録チェック】
        /// </summary>
        public Int16 chk_ichibu_mi_toroku { get; set; }

        /// <summary>
        /// 登録状況チェックボックス【登録済チェック】
        /// </summary>
        public Int16 chk_toroku_sumi { get; set; }

        /// <summary>
        /// 未登録
        /// </summary>
        public string lbl_mi_toroku { get; set; }

        /// <summary>
        /// 一部未登録
        /// </summary>
        public string lbl_ichibu_mi_toroku { get; set; }

        /// <summary>
        /// 登録済
        /// </summary>
        public string lbl_toroku_sumi { get; set; }

        /// <summary>
        /// スキップ件数
        /// </summary>
        public int? skip { get; set; }

        /// <summary>
        /// 取得件数
        /// </summary>
        public int? top { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// 現地の当日日付
        /// </summary>
        public DateTime today { get; set; }

        /// <summary>
        /// ログインユーザー名
        /// </summary>
        public string userName { get; set; }
    }
}