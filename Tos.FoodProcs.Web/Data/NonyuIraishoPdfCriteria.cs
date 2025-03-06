using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 納入依頼書PDF用データ検索情報/ヘッダー情報を定義します。
  /// </summary>
    public class NonyuIraishoPdfCriteria
    {
        /// <summary>
        /// 検索情報/ヘッダー情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public NonyuIraishoPdfCriteria()
        {
        }

        /// <summary>
        /// 「予定なしの品目も出力する」
        /// </summary>
        public bool yotei { get; set; }

        /// <summary>
        /// 「分類毎に改頁する」
        /// </summary>
        public bool bunrui { get; set; }

        /// <summary>
        /// 検索日付From
        /// </summary>
        public DateTime dateFrom { get; set; }

        /// <summary>
        /// 検索日付To
        /// </summary>
        public DateTime dateTo { get; set; }

        /// <summary>
        /// システム日付
        /// </summary>
        public DateTime sysdate { get; set; }

        /// <summary>
        /// 選択された品名コード
        /// </summary>
        public string hinCode { get; set; }

        /// <summary>
        /// 選択された取引コード
        /// </summary>
        public string torihikiCode { get; set; }

        /// <summary>
        /// 選択された納品先コード
        /// </summary>
        public string niukeCode { get; set; }

        /// <summary>
        /// ログイン情報：会社コード
        /// </summary>
        public string cdLoginKaisha { get; set; }

        /// <summary>
        /// ログイン情報：工場コード
        /// </summary>
        public string cdLoginKojo { get; set; }

        /// <summary>
        /// ヘッダー情報：発注番号
        /// </summary>
        public string hachuNo { get; set; }

        /// <summary>
        /// ヘッダー情報：連絡先
        /// </summary>
        public string renrakusaki { get; set; }

        /// <summary>
        /// ヘッダー情報：連絡先TEL
        /// </summary>
        public string renTel { get; set; }

        /// <summary>
        /// ヘッダー情報：連絡先FAX
        /// </summary>
        public string renFax { get; set; }

        /// <summary>
        /// ヘッダー情報：納品先工場名
        /// </summary>
        public string nohinsaki { get; set; }

        /// <summary>
        /// ヘッダー情報：納品先住所
        /// </summary>
        public string nohinsakiAdd { get; set; }

        /// <summary>
        /// ヘッダー情報：取引先名
        /// </summary>
        public string torihikisaki { get; set; }

        /// <summary>
        /// ヘッダー情報：納入書形式区分
        /// </summary>
        public string kbnKeishiki { get; set; }

        /// <summary>
        /// ヘッダー情報：コメント
        /// </summary>
        public string comment { get; set; }

        /// <summary>
        /// ヘッダー情報：会社名
        /// </summary>
        public string kaishaName { get; set; }

        /// <summary>
        /// 言語設定
        /// <summary>
        public string lang { get; set; }

        /// <summary>
        /// 言語設定(国)
        /// <summary>
        public string langCountry { get; set; }

        /// <summary>
        /// 現地の当日日時
        /// <summary>
        public DateTime local_today { get; set; }
    }
}