using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 製造日報検索条件データオブジェクトを定義します。
  /// </summary>
  public class SeizoNippoCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public SeizoNippoCriteria()
        {
        }

        /// <summary>
        /// 製造日
        /// </summary>
        public DateTime dt_seizo { get; set; }

        /// <summary>
        /// 職場コード
        /// </summary>
        public string cd_shokuba { get; set; }

        /// <summary>
        /// ラインコード
        /// </summary>
        public string cd_line { get; set; }

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
        /// 時差
        /// </summary>
        public int UTC { get; set; }
       
        /// <summary>
        /// ログインユーザー名
        /// </summary>
        public string userName { get; set; }

        /// <summary>
        /// ローカルシステム日付
        /// </summary>
        public DateTime today { get; set; }



        ////////// 以下保存処理用

        /// <summary>
        /// 製品ロット番号
        /// </summary>
        public string no_lot_seihin { get; set; }

        /// <summary>
        /// 製造日
        /// </summary>
        //public DateTime dt_seizo { get; set; }

        /// <summary>
        /// 職場コード
        /// </summary>
        //public string cd_shokuba { get; set; }

        /// <summary>
        /// ラインコード
        /// </summary>
        //public string cd_line { get; set; }

        /// <summary>
        /// 品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 製造予定数
        /// </summary>
        public decimal su_seizo_yotei { get; set; }

        /// <summary>
        /// 製造実績数
        /// </summary>
        public decimal su_seizo_jisseki { get; set; }

        /// <summary>
        /// 実績フラグ
        /// </summary>
        public short flg_jisseki { get; set; }

        /// <summary>
        /// 伝送区分
        /// </summary>
        public short kbn_denso { get; set; }

        /// <summary>
        /// 伝送フラグ
        /// </summary>
        public short flg_denso { get; set; }

        /// <summary>
        /// 更新日
        /// </summary>
        public DateTime dt_update { get; set; }

        /// <summary>
        /// 計画バッチ数
        /// </summary>
        public decimal su_batch_keikaku { get; set; }

        /// <summary>
        /// 実績バッチ数
        /// </summary>
        public decimal su_batch_jisseki { get; set; }

        /// <summary>
        /// 賞味期限
        /// </summary>
        public DateTime dt_shomi { get; set; }

        /// <summary>
        /// 表示用ロット番号
        /// </summary>
        public string no_lot_hyoji { get; set; }

        /// <summary>
        /// 按分チェックフラグ
        /// １の場合はSAP実績按分トランの更新を行う
        /// </summary>
        public short? isCheckAnbun { get; set; }

        /// <summary>
        /// 行ID
        /// 内訳との結びつきに使用
        /// 親行：内訳行 = 単：多
        /// </summary>
        public string id_row { get; set; }
  }
}