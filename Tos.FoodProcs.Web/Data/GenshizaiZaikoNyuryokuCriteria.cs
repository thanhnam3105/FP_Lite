using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 原資材在庫入力検索情報を定義します。
    /// </summary>
    public class GenshizaiZaikoNyuryokuCriteria
    {
        /// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GenshizaiZaikoNyuryokuCriteria()
        {
        }

        /// <summary>
        /// 検索条件：在庫日付
        /// </summary>
        public DateTime con_dt_zaiko { get; set; }

        /// <summary>
        /// 検索条件：品区分
        /// </summary>
        public string con_kbn_hin { get; set; }

        /// <summary>
        /// 検索条件：品分類
        /// </summary>
        public string con_hin_bunrui { get; set; }

        /// <summary>
        /// 検索条件：庫場所
        /// </summary>
        public string con_kurabasho { get; set; }

        /// <summary>
        /// 検索条件：品名
        /// </summary>
        public string con_hinmei { get; set; }

        /// <summary>
        /// 検索条件：使用分/未使用分
        /// </summary>
        public short flg_shiyobun { get; set; }

        /// <summary>
        /// 検索条件：計算在庫/実在庫ありのみ
        /// </summary>
        public short flg_zaiko { get; set; }

        /// <summary>
        /// 実在庫端数(納入単位)：切捨て用小数
        /// </summary>
        public int hasu_floor_decimal { get; set; }

        /// <summary>
        /// 実在庫端数(納入単位)：切上げ用小数
        /// </summary>
        public int hasu_ceil_decimal { get; set; }

        /// <summary>
        /// ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// 定数：未使用フラグ：使用
        /// </summary>
        public short shiyo_flag { get; set; }

        /// <summary>
        /// 定数：未使用フラグ：未使用
        /// </summary>
        public short mishiyo_flag { get; set; }

        /// <summary>
        /// 定数：納入単位：Kg
        /// </summary>
        public string tani_kg { get; set; }

        /// <summary>
        /// 定数：納入単位：L
        /// </summary>
        public string tani_L { get; set; }

        /// <summary>
        /// 定数：品区分：原料
        /// </summary>
        public string genryo { get; set; }

        /// <summary>
        /// 定数：品区分：資材
        /// </summary>
        public string shizai { get; set; }

        /// <summary>
        /// 定数：品区分：自家原料
        /// </summary>
        public string jikagenryo { get; set; }

        /// <summary>
        /// 検索条件：計算在庫/実在庫ありのみ
        /// </summary>
        public short kbn_zaiko { get; set; }

        /// <summary>
        /// 検索条件：倉庫
        /// </summary>
        public string cd_soko { get; set; }

        /// <summary>
        /// EXCEL用：品区分
        /// </summary>
        public string hinKubunName { get; set; }

        /// <summary>
        /// EXCEL用：分類
        /// </summary>
        public string hinBunruiName { get; set; }

        /// <summary>
        /// EXCEL用：庫場所
        /// </summary>
        public string kurabashoName { get; set; }

        /// <summary>
        /// EXCEL用：倉庫
        /// </summary>
        public string sokoName { get; set; }

        /// <summary>
        /// EXCEL用：使用分
        /// </summary>
        public string shiyoubun { get; set; }

        /// <summary>
        /// EXCEL用：未使用分
        /// </summary>
        public string mishiyoubun { get; set; }

        /// <summary>
        /// EXCEL用：ありのみ
        /// </summary>
        public string ariNomi { get; set; }

        /// <summary>
        /// EXCEL用：ユーザー名
        /// </summary>
        public string userName { get; set; }

        /// <summary>
        /// EXCEL用：出力日
        /// </summary>
        public DateTime today { get; set; }
    }
}