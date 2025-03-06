using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    /// <summary>
    /// 競合データのセットを定義します。
    /// </summary>
    /// <typeparam name="T">対象となるエンティティ</typeparam>
    public class DuplicateSets<T1, T2, T3> : ChangeSets<Duplicate<T1>, Duplicate<T2>, Duplicate<T3>>
    {

    }
    
    /// <summary>
    /// 競合データのセットを定義します。
    /// </summary>
    /// <typeparam name="T">対象となるエンティティ</typeparam>
    public class DuplicateSets<T1, T2> : ChangeSets<Duplicate<T1>, Duplicate<T2>>
    {

    }

	/// <summary>
	/// 競合データのセットを定義します。
	/// </summary>
	/// <typeparam name="T">対象となるエンティティ</typeparam>
	public class DuplicateSet<T>: ChangeSet<Duplicate<T>>
	{
		
	}

	/// <summary>
	/// 競合データを定義します。
	/// </summary>
	/// <typeparam name="T">対象となるエンティティ</typeparam>
	public class Duplicate<T>
	{
		/// <summary>
		/// インスタンスを初期化します。
		/// </summary>
		/// <param name="requested">競合が発生したデータ</param>
		/// <param name="current">ストレージに格納されている最新のデータ</param>
		public Duplicate(T requested, T current)
		{
			this.Requested = requested;
			this.Current = current;
		}
		/// <summary>
		/// 競合が発生したデータを取得または設定します。
		/// </summary>
		public T Requested { get; set; }
		/// <summary>
		/// ストレージに格納されている最新のデータを取得または設定します。
		/// </summary>
		public T Current { get; set; }

	}
}