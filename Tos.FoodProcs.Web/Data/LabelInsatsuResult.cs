using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 検索結果を定義します。
  /// </summary>
  public class LabelInsatsuResult
  {
	/// <summary>
    /// 検索結果を定義するクラスのインスタンスを初期化します。
    /// </summary>
    public LabelInsatsuResult() { }

    /// <summary>
    /// 仕掛品ロット番号
    /// </summary>
    public string no_lot_shikakari { get; set; }

    /// <summary>
    /// 製造日
    /// </summary>
    public DateTime dt_seizo { get; set; }

    /// <summary>
    /// 配合コード
    /// </summary>
    public string cd_haigo { get; set; }

    /// <summary>
    /// 品名
    /// </summary>
    public string nm_hinmei { get; set; }

    /// <summary>
    /// 配合名ja
    /// </summary>
    public string nm_haigo_ja { get; set; }

    /// <summary>
    /// 配合名en
    /// </summary>
    public string nm_haigo_en { get; set; }

    /// <summary>
    /// 配合名zh
    /// </summary>
    public string nm_haigo_zh { get; set; }

    /// <summary>
    /// 配合名vi
    /// </summary>
    public string nm_haigo_vi { get; set; }

    /// <summary>
    /// 品コード
    /// </summary>
    public string cd_hinmei { get; set; }

    /// <summary>
    /// 品名ja
    /// </summary>
    public string nm_hinmei_ja { get; set; }

    /// <summary>
    /// 品名en
    /// </summary>
    public string nm_hinmei_en { get; set; }

    /// <summary>
    /// 品名zh
    /// </summary>
    public string nm_hinmei_zh { get; set; }

    /// <summary>
    /// 品名vi
    /// </summary>
    public string nm_hinmei_vi { get; set; }

    /// <summary>
    /// 品名略
    /// </summary>
    public string nm_hinmei_ryaku { get; set; }

    /// <summary>
    /// 工程番号
    /// </summary>
    public decimal? no_kotei { get; set; }

    /// <summary>
    /// 投入番号
    /// </summary>
    public decimal? no_tonyu { get; set; }

    /// <summary>
    /// チームコード
    /// </summary>
    public string cd_team { get; set; }

    /// <summary>
    /// 職場コード
    /// </summary>
    public string cd_shokbua { get; set; }

    /// <summary>
    /// ラインコード
    /// </summary>
    public string cd_line { get; set; }

    /// <summary>
    /// マークコード
    /// </summary>
    public string cd_mark { get; set; }

    /// <summary>
    /// マーク名
    /// </summary>
    public string nm_mark { get; set; }

    /// <summary>
    /// 基本重量
    /// </summary>
    public decimal? wt_kihon { get; set; }

    /// <summary>
    /// 単位名
    /// </summary>
    public string nm_tani { get; set; }

    /// <summary>
    /// 単位名
    /// </summary>
    public string nm_tani_hasu { get; set; }

    /// <summary>
    /// 配合重量
    /// </summary>
    public decimal? wt_haigo { get; set; }

    /// <summary>
    /// 配合重量　端数
    /// </summary>
    public decimal? wt_haigo_hasu { get; set; }

    /// <summary>
    /// 使用単位
    /// </summary>
    public string cd_tani_shiyo { get; set; }

    /// <summary>
    /// 品区分
    /// </summary>
    public short? kbn_hin { get; set; }

    /// <summary>
    /// 荷姿重量 正規　
    /// </summary>
    public decimal? wt_nisugata { get; set; }

    /// <summary>
    /// 荷姿重量 端数
    /// </summary>
    public decimal? wt_nisugata_hasu { get; set; }

    /// <summary>
    /// 荷姿重量 小分け数　正規
    /// </summary>
    public decimal? su_nisugata_kowake_seiki { get; set; }

    /// <summary>
    /// 荷姿重量 小分け数　端数
    /// </summary>
    public decimal? su_nisugata_kowake_hasu { get; set; }

    /// <summary>
    /// 小分け重量１
    /// </summary>
    public decimal? wt_kowake1_seiki { get; set; }

    /// <summary>
    /// 小分け重量１ 小分け数
    /// </summary>
    public decimal? su_kowake1_kowake_seiki { get; set; }

    /// <summary>
    /// 小分け重量２
    /// </summary>
    public decimal? wt_kowake2_seiki { get; set; }

    /// <summary>
    /// 小分け重量２ 小分け数
    /// </summary>
    public decimal? su_kowake2_kowake_seiki { get; set; }

    /// <summary>
    /// 小分け重量１ 端数
    /// </summary>
    public decimal? wt_kowake1_hasu { get; set; }

    /// <summary>
    /// 小分け重量１ 小分け数　端数
    /// </summary>
    public decimal? su_kowake1_kowake_hasu { get; set; }

    /// <summary>
    /// 小分け重量２　端数
    /// </summary>
    public decimal? wt_kowake2_hasu { get; set; }

    /// <summary>
    /// 小分け重量２ 小分け数　端数
    /// </summary>
    public decimal? su_kowake2_kowake_hasu { get; set; }

    /// <summary>
    /// 小分け重量（重量マスタより取得）
    /// </summary>
    public decimal? wt_kowake { get; set; }

    /// <summary>
    /// 風袋コード1 正規
    /// </summary>
    public string cd_futai1_seiki { get; set; }

    /// <summary>
    /// 風袋名1　正規
    /// </summary>
    public string nm_futai1_seiki { get; set; }
    
      /// <summary>
    /// 風袋コード2 正規
    /// </summary>
    public string cd_futai2_seiki { get; set; }

    /// <summary>
    /// 風袋名2　正規
    /// </summary>
    public string nm_futai2_seiki { get; set; }

    /// <summary>
    /// 風袋コード1 端数
    /// </summary>
    public string cd_futai1_hasu { get; set; }

    /// <summary>
    /// 風袋名1　端数
    /// </summary>
    public string nm_futai1_hasu { get; set; }

    /// <summary>
    /// 風袋コード2 端数
    /// </summary>
    public string cd_futai2_hasu { get; set; }

    /// <summary>
    /// 風袋名2　端数
    /// </summary>
    public string nm_futai2_hasu { get; set; }

    /// <summary>
    /// 正規バッチ数
    /// </summary>
    public decimal? su_batch_keikaku { get; set; }

    /// <summary>
    /// 端数バッチ数
    /// </summary>
    public decimal? su_batch_keikaku_hasu { get; set; }

    /// <summary>
    /// 正規倍率
    /// </summary>
    public decimal? ritsu_keikaku { get; set; }

    /// <summary>
    /// 端数倍率
    /// </summary>
    public decimal? ritsu_keikaku_hasu { get; set; }

    /// <summary>
    /// 版番号
    /// </summary>
    public decimal? no_han { get; set; }

    /// <summary>
    /// 風袋名2　端数
    /// </summary>
    public string kbnAllergy { get; set; }

    /// <summary>
    /// 風袋名2　端数
    /// </summary>
    public string nm_Allergy { get; set; }

    /// <summary>
    /// 風袋名2　端数
    /// </summary>
    public string kbnOther { get; set; }

    /// <summary>
    /// 風袋名2　端数
    /// </summary>
    public string nm_Other { get; set; }

  }
}