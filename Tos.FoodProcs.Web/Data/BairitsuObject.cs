using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    public class BairitsuObject
    {

        //public BairitsuObject bObject;

        // 倍率取得用マップで使用するオブジェクト
        // 階層、品コード、配合コード、配合レシピに登録されている品コード、
        // 倍率（正規・端数）、バッチ数（正規・端数）、配合重量（正規・端数）を持ったオブジェクトを生成
        public int kaiso;
        public String hinCode;
        public String haigoCode;
        public String recipeHinmeiCode;
        public decimal keikakuHaigoJuryo;
        public decimal keikakuHaigoJuryoHasu;
        public decimal bairitsu;
        public decimal bairitsuHasu;
        public decimal batchSu;
        public decimal batchSuHasu;
        public decimal keikakuShikomiJuryo;

        /// <summary>
        /// デフォルトコンストラクタ
        /// </summary>
        public BairitsuObject()
        {
        }

        private BairitsuObject(RecipeTenkaiObject recipeObj)
        {
            kaiso = recipeObj.kaisoSu;
            hinCode = recipeObj.hinmeiCode;
            haigoCode = recipeObj.haigoCode;
            recipeHinmeiCode = recipeObj.haigoCode; // 配合コードと同値をセット
            keikakuHaigoJuryo = recipeObj.keikakuHaigoJuryo;
            keikakuHaigoJuryoHasu = recipeObj.keikakuHaigoJuryoHasu;
            bairitsu = recipeObj.keikakuBairitsu;
            bairitsuHasu = recipeObj.keikakuBairitsuHasu;
            batchSu = recipeObj.keikakuBatchSu;
            batchSuHasu = recipeObj.keikakuBatchSuHasu;
        }
        
        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="recipeObj"></param>
        /// <param name="recipeHinmeiCode"></param>
        public BairitsuObject(RecipeTenkaiObject recipeObj, String rHinmeiCode)
        {
            if (String.IsNullOrEmpty(rHinmeiCode)) 
            {
                // １階層目  
                //bObject = new BairitsuObject(recipeObj); //自分のコンストラクタってどう呼ぶの？
                kaiso = recipeObj.kaisoSu;
                hinCode = recipeObj.hinmeiCode;
                haigoCode = recipeObj.haigoCode;
                recipeHinmeiCode = recipeObj.haigoCode; // 配合コードと同値をセット
                keikakuHaigoJuryo = recipeObj.keikakuHaigoJuryo;
                keikakuHaigoJuryoHasu = recipeObj.keikakuHaigoJuryoHasu;
                bairitsu = recipeObj.keikakuBairitsu;
                bairitsuHasu = recipeObj.keikakuBairitsuHasu;
                batchSu = recipeObj.keikakuBatchSu;
                batchSuHasu = recipeObj.keikakuBatchSuHasu;
            }
            else
            {
                // ２階層目以降
                //bObject = new BairitsuObject(recipeObj);
                //bObject.recipeHinmeiCode = recipeHinmeiCode;
                kaiso = recipeObj.kaisoSu;
                hinCode = recipeObj.hinmeiCode;
                haigoCode = recipeObj.haigoCode;
                keikakuHaigoJuryo = recipeObj.keikakuHaigoJuryo;
                keikakuHaigoJuryoHasu = recipeObj.keikakuHaigoJuryoHasu;
                bairitsu = recipeObj.keikakuBairitsu;
                bairitsuHasu = recipeObj.keikakuBairitsuHasu;
                batchSu = recipeObj.keikakuBatchSu;
                batchSuHasu = recipeObj.keikakuBatchSuHasu;

                recipeHinmeiCode = rHinmeiCode;
            } 
        }

        /// <summary>
        /// 計算に使用できる倍率オブジェクトか判定する
        /// RecipeTenkaiObjectの配合コードとbairitsuObjectに登録されているrecipeHinmeiCode
        /// RecipeTenkaiObjectの階層数-1とbairitsuObjectの階層数をそれぞれ比較
        /// （一階層前の倍率を使用するため）
        /// </summary>
        /// <param name="recipe"></param>
        /// <returns></returns>
        public bool isBairitsuObj(RecipeTenkaiObject recipe)
        {
            if (this.recipeHinmeiCode.Equals(recipe.haigoCode)
                && this.kaiso == recipe.kaisoSu - 1)
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
/**
        public override bool Equals(object obj)
        {
            BairitsuObject bairitsu = (BairitsuObject)obj;
            return this.kaiso == bairitsu.kaiso &&
                this.hinCode.Equals(bairitsu.hinCode) &&
                this.haigoCode.Equals(bairitsu.haigoCode) &&
                this.bairitsu == bairitsu.bairitsu &&
                this.bairitsuHasu == bairitsu.bairitsuHasu &&
                this.batchSu == bairitsu.batchSu &&
                this.bacchiHasu == bairitsu.bacchiHasu;
        }
*/

    }
}