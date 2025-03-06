using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

  /// <summary>
  /// 仕込日報検索条件を定義します。
  /// </summary>
  public class ShikakarihinShiyoIchiranCriteria {
	/// <summary>
    /// 検索情報を定義するクラスのインスタンスを初期化します。
    /// </summary>
	public ShikakarihinShiyoIchiranCriteria() {
    }

    /// <summary>
    /// 仕込日
    /// </summary>
    public DateTime dt_shikomi_search { get; set; }

    /// <summary>
    /// 仕掛品コード
    /// </summary>
    public string shikakariCode { get; set; }

    /// <summary>
    /// 仕掛品名
    /// </summary>
    public string shikakariName { get; set; }

    /// <summary>
    /// 版番号
    /// </summary>
    public short? no_han { get; set; }

    /// <summary>
    /// スキップ件数
    /// </summary>
    public int? skip { get; set; }

    /// <summary>
    /// 取得件数
    /// </summary>
    public int? top { get; set; }

  }
}