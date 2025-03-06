using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Resources;

namespace Tos.FoodProcs.Web.Data
{
    /// <summary>
    /// 仕掛品計画データのサマリ条件になるKEYのクラス
    /// </summary>
    public class ShikakariGassanKey
    {
        // 職場コード
        public String shokubaCode { set; get; }
        // ラインコード
        public String lineCode { set; get; }
        // 仕掛品コード（配合レシピマスタ）
        public String recipeHaigoCode { set; get; }
        // 製造日
        public DateTime seizoDate { set; get; }
        // シーケンスNo
        public int seqNo { set; get; }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="shokuba"></param>
        /// <param name="haigoCode"></param>
        /// <param name="d"></param>
        public ShikakariGassanKey(String shokuba, String line, String haigoCode, DateTime d)
        {
            shokubaCode = shokuba;
            lineCode = line;
            recipeHaigoCode = haigoCode;
            seizoDate = d;
            seqNo = 0;
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="shokuba"></param>
        /// <param name="haigoCode"></param>
        /// <param name="d"></param>
        public ShikakariGassanKey(String shokuba, String line, String haigoCode, DateTime d, int iSeqNo)
        {
            shokubaCode = shokuba;
            lineCode = line;
            recipeHaigoCode = haigoCode;
            seizoDate = d;
            seqNo = iSeqNo;
        }

        /// <summary>
        /// 比較処理
        /// </summary>
        /// <param name="key"></param>
        /// <returns></returns>
        public override bool Equals(object obj)
        {
            ShikakariGassanKey key = (ShikakariGassanKey)obj;
            if (shokubaCode.Equals(key.shokubaCode)
                && lineCode.Equals(key.lineCode)
                && recipeHaigoCode.Equals(key.recipeHaigoCode)
                && seizoDate == key.seizoDate
                && seqNo == key.seqNo)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public override int GetHashCode()
        {
            return shokubaCode.GetHashCode() ^ lineCode.GetHashCode() 
                ^ recipeHaigoCode.GetHashCode() ^ seizoDate.GetHashCode() ^ seqNo.GetHashCode();
        }

        public int getSeqNo(ShikakariGassanKey comp)
        {
            if (this.shokubaCode.Equals(comp.shokubaCode)
                && this.lineCode.Equals(comp.lineCode)
                && this.recipeHaigoCode.Equals(comp.recipeHaigoCode)
                && this.seizoDate == comp.seizoDate)
            {
                return this.seqNo;
            }
            //return Resources.ErrorCodeInt;
            return 999;
        }
    }
}