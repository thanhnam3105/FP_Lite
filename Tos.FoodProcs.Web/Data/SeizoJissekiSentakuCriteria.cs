using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 製造実績選択画面の検索情報を定義します。
    /// </summary>
    public class SeizoJissekiSentakuCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public SeizoJissekiSentakuCriteria()
        {
        }

        /// <summary>
        /// 検索条件：仕込日
        /// </summary>
        public DateTime dt_shikomi { get; set; }

        /// <summary>
        /// 検索条件：配合コード
        /// </summary>
        public string cd_haigo { get; set; }

        /// <summary>
        /// 検索条件：仕込量
        /// </summary>
        public decimal su_shikomi { get; set; }

        /// <summary>
        /// 伝送状態区分：初期値
        /// </summary>
        public short kbn_jotai_denso { get; set; }

        /// <summary>
        /// 按分区分：初期値
        /// </summary>
        public string kbn_anbun_seizo { get; set; }

        /// <summary>
        /// 検索上限数
        /// </summary>
        public int top { get; set; }

        /// <summary>
        /// ログインユーザーコード
        /// </summary>
        public string user { get; set; }

        /// <summary>
        /// UTCシステム日付
        /// </summary>
        public DateTime today { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// 明細データ：シーケンス番号
        /// </summary>
        public string no_seq { get; set; }

        /// <summary>
        /// 明細データ：仕掛品ロット番号
        /// </summary>
        public string no_lot_shikakari { get; set; }

        /// <summary>
        /// 明細データ：使用実績按分区分
        /// </summary>
        public string kbn_shiyo_jisseki_anbun { get; set; }

        /// <summary>
        /// 明細データ：製品ロット番号
        /// </summary>
        public string no_lot_seihin { get; set; }

        /// <summary>
        /// 明細データ：仕掛品使用日
        /// </summary>
        public DateTime dt_shiyo_shikakari { get; set; }

        /// <summary>
        /// 明細データ：仕掛品使用量
        /// </summary>
        public Decimal su_shiyo_shikakari { get; set; }

        /// <summary>
        /// 明細データ：理由コード
        /// </summary>
        public string cd_riyu{ get; set; }

        /// <summary>
        /// 明細データ：原価センターコード
        /// </summary>
        public string cd_genka_center { get; set; }

        /// <summary>
        /// 明細データ：倉庫ーコード
        /// </summary>
        public string cd_soko { get; set; }

        /// <summary>
        /// 明細データ：タイムスタンプ
        /// </summary>
        public byte[] ts { get; set; }

        /// <summary>
        /// チェック用：初期表示時の按分トランのレコード数
        /// </summary>
        public int recordCount { get; set; }

        /// <summary>
        /// 明細データ：賞味期間
        /// </summary>
        public decimal dd_shomi { get; set; }

        /// <summary>
        /// 明細データ：品名コード
        /// </summary>
        public string cd_hinmei { get; set; }

        /// <summary>
        /// 明細データ：製品ロット番号（使用実績按分区分変更前）
        /// </summary>
        public string con_no_lot_seihin { get; set; }
    }
}