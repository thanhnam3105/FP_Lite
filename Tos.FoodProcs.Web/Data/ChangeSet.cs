using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{

    public class ChangeSets<T1, T2>
    {
        /// <summary>
        /// 変更セットを定義する <see cref="ChangeSets"/> クラスのインスタンスを初期化します。
        /// </summary>
        public ChangeSets()
        {
            this.First = new ChangeSet<T1>();
            this.Second = new ChangeSet<T2>();
        }
        public ChangeSet<T1> First { get; set; }
        public ChangeSet<T2> Second { get; set; }
    }

    public class ChangeSets<T1, T2, T3>
    {
        /// <summary>
        /// 変更セットを定義する <see cref="ChangeSets"/> クラスのインスタンスを初期化します。
        /// </summary>
        public ChangeSets()
        {
            this.First = new ChangeSet<T1>();
            this.Second = new ChangeSet<T2>();
            this.Third = new ChangeSet<T3>();
        }
        public ChangeSet<T1> First { get; set; }
        public ChangeSet<T2> Second { get; set; }
        public ChangeSet<T3> Third { get; set; }
    }

    /// <summary>
    /// エンティティの変更セットを定義します。
    /// </summary>
    /// <typeparam name="T">変更セットの対象となるエンティティを定義します。</typeparam>
    public class ChangeSet<T>
    {

        /// <summary>
        /// 変更セットを定義する <see cref="ChangeSet"/> クラスのインスタンスを初期化します。
        /// </summary>
        public ChangeSet()
        {
            this.Created = new List<T>();
            this.Updated = new List<T>();
            this.Deleted = new List<T>();
        }

        /// <summary>
        /// 追加されたエンティティのリストを取得、または設定します。
        /// </summary>
		public List<T> Created { get; set; }

        /// <summary>
        /// 変更されたエンティティのリストを取得、または設定します。
        /// </summary>
		public List<T> Updated { get; set; }

        /// <summary>
        /// 削除されたエンティティのリストを取得、または設定します。
        /// </summary>
		public List<T> Deleted { get; set; }
    }
}