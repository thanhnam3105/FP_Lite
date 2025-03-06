using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    /// <summary>
    /// 一連のバリデーションエラーとなったデータおよびメッセージを定義します。
    /// </summary>
    /// <typeparam name="T1, T2, T3">対象となるエンティティ</typeparam>
    public class InvalidationSets<T1, T2, T3>
    {
        public InvalidationSets()
        {
            this.First = new List<Invalidation<T1>>();
            this.Second = new List<Invalidation<T2>>();
            this.Third = new List<Invalidation<T3>>();
        }
        public List<Invalidation<T1>> First { get; set; }
        public List<Invalidation<T2>> Second { get; set; }
        public List<Invalidation<T3>> Third { get; set; }
    }

    /// <summary>
    /// 一連のバリデーションエラーとなったデータおよびメッセージを定義します。
    /// </summary>
    /// <typeparam name="T1, T2">対象となるエンティティ</typeparam>
    public class InvalidationSets<T1, T2>
    {
        public InvalidationSets()
        {
            this.First = new List<Invalidation<T1>>();
            this.Second = new List<Invalidation<T2>>();
        }
        public List<Invalidation<T1>> First { get; set; }
        public List<Invalidation<T2>> Second { get; set; }
    }

	/// <summary>
	/// 一連のバリデーションエラーとなったデータおよびメッセージを定義します。
	/// </summary>
	/// <typeparam name="T">対象となるエンティティ</typeparam>
	public class InvalidationSet<T> : List<Invalidation<T>>
	{
	}

	/// <summary>
	/// バリデーションエラーとなったデータおよびメッセージを定義します。
	/// </summary>
	/// <typeparam name="T">対象となるエンティティ</typeparam>
	public class Invalidation<T>
	{
                
		/// <summary>
		/// インスタンスを初期化します。
		/// </summary>
		/// <param name="message">バリデーションエラーメッセージ</param>
		/// <param name="data">バリデーションエラーとなったデータ</param>
        /// /// <param name="invalidationName">バリデーションエラー名</param>
		public Invalidation(string message, T data, string invalidationName)
		{
			this.Message = message;
			this.Data = data;
            this.InvalidationName = invalidationName;
		}

		/// <summary>
		/// バリデーションエラーメッセージを取得または設定します。
		/// </summary>
		public string Message { get; set; }

		/// <summary>
		/// バリデーションエラーとなったデータを取得または設定します。
		/// </summary>
		public T Data { get; set; }

        /// <summary>
        /// バリデーションエラー名を取得または設定します。
        /// </summary>
        public string InvalidationName { get; set; }

	}
}