using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data {

    /// <summary>
    /// 原資材在庫入力伝送パラメータを定義します。
    /// </summary>
    public class GenshizaiZaikoNyuryokuZaikoRetrasmitCriteria
    {
        /// <summary>
        /// パラメータを定義するクラスのインスタンスを初期化します。
        /// </summary>
        public GenshizaiZaikoNyuryokuZaikoRetrasmitCriteria()
        {
        }

        /// <summary>
        /// 検索条件：在庫日付
        /// </summary>
        public DateTime con_dt_zaiko { get; set; }

        /// <summary>
        /// 作成区分
        /// </summary>
        public short kbnCreate { get; set; }

        /// <summary>
        /// 更新区分
        /// </summary>
        public short kbnUpdate { get; set; }

        /// <summary>
        /// 削除区分
        /// </summary>
        public short kbnDelete { get; set; }

        /// <summary>
        /// true
        /// </summary>
        public short flgTrue { get; set; }

        /// <summary>
        /// false
        /// </summary>
        public short flgFalse { get; set; }

        /// <summary>
        /// 原料区分
        /// </summary>
        public short kbnGenryo { get; set; }

        /// <summary>
        /// 資材区分
        /// </summary>
        public short kbnShizai { get; set; }

        /// <summary>
        /// 自家原区分
        /// </summary>
        public short kbnJikagen { get; set; }

        /// <summary>
        /// 在庫区分
        /// </summary>
        public short kbnZaiko { get; set; }
        
    }
}