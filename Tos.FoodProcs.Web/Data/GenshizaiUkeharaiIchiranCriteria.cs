using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 原資材受払一覧の検索情報を定義します。
  /// </summary>
  public class GenshizaiUkeharaiIchiranCriteria
  {
	/// <summary>
        /// 検索情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
      public GenshizaiUkeharaiIchiranCriteria() { }

        /// <summary>
        /// 品区分
        /// </summary>
        public short kbn_hin { get; set; }

        /// <summary>
        /// 分類
        /// </summary>
        public string cd_bunrui { get; set; }

        /// <summary>
        /// 開始日付
        /// </summary>
        public DateTime dt_hiduke_from { get; set; }

        /// <summary>
        /// 終了日付
        /// </summary>
        public DateTime dt_hiduke_to { get; set; }
  
        /// <summary>
        /// 原資材コード
        /// </summary>
        public string cd_genshizai { get; set; }

        /// <summary>
        /// 未使用分含むフラグ
        /// </summary>
        public short flg_mishiyobun { get; set; }

        /// <summary>
        /// 使用フラグ
        /// </summary>
        public short flg_shiyo { get; set; }

        /// <summary>
        /// 計算在庫/実在庫ありフラグ
        /// </summary>
        public short flg_zaiko { get; set; }

        /// <summary>
        /// 当日は予定のデータを出す場合：0
        /// 当日は実績のデータを出す場合：1
        /// </summary>
        public short flg_today_jisseki { get; set; }

        /// <summary>
        /// システムUTC日付
        /// </summary>
        public DateTime dt_today { get; set; }

        /// <summary>
        /// 単位コード：Kg
        /// </summary>
        public string cd_kg { get; set; }

        /// <summary>
        /// 単位コード：L
        /// </summary>
        public string cd_li { get; set; }

        /// <summary>
        /// 予実フラグ（予定）
        /// </summary>
        public short flg_yojitsu_yotei { get; set; }

        /// <summary>
        /// 予実フラグ（実績）
        /// </summary>
        public short flg_yojitsu_jisseki { get; set; }

        /// <summary>
        /// 実績確定フラグ（確定）
        /// </summary>
        public short flg_jisseki_kakutei { get; set; }

        /// <summary>
        /// 品区分（原料）
        /// </summary>
        public short kbn_genryo { get; set; }

        /// <summary>
        /// 品区分（資材）
        /// </summary>
        public short kbn_shizai { get; set; }

        /// <summary>
        /// 品区分（自家原料）
        /// </summary>
        public short kbn_jikagenryo { get; set; }

        /// <summary>
        /// 受払区分（納入予定）
        /// </summary>
        public short NounyuYoteiKbn { get; set; }

        /// <summary>
        /// 受払区分（納入実績）
        /// </summary>
        public short NounyuJissekiKbn { get; set; }

        /// <summary>
        /// 受払区分（使用予定）
        /// </summary>
        public short ShiyoYoteiKbn { get; set; }

        /// <summary>
        /// 受払区分（使用実績）
        /// </short>
        public short ShiyoJissekiKbn { get; set; }

        /// <summary>
        /// 受払区分（調整数）
        /// </summary>
        public short ChoseiKbn { get; set; }

        /// <summary>
        /// 受払区分（製造予定）
        /// </summary>
        public short seizoYoteiKbn { get; set; }

        /// <summary>
        /// 受払区分（製造実績）
        /// </summary>
        public short seizoJissekiKbn { get; set; }

        /// <summary>
        /// 理由区分(調整理由)
        /// </summary>
        public short choseiRiyuKbn { get; set; }

        /// <summary>
        /// 理由区分(調整理由)
        /// </summary>
        public short? ukeharaiKbn { get; set; }

        /// <summary>
        /// 受払区分名
        /// </summary>
        public string ukeharaiName { get; set; }

        /// <summary>
        /// 検索最大件数
        /// </summary>
        public int? maxCount { get; set; }

        /// <summary>
        /// EXCEL用：ブラウザ言語
        /// </summary>
        public string lang { get; set; }

        /// <summary>
        /// EXCEL用：品区分
        /// </summary>
        public string hinKubunName { get; set; }
      
        /// <summary>
        /// EXCEL用：品分類
        /// </summary>
        public string hinBunruiName { get; set; }

        /// <summary>
        /// EXCEL用：品名
        /// </summary>
        public string hinName { get; set; }

        /// <summary>
        /// EXCEL用：未使用分含む
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