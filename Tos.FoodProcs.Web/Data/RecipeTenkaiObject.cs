using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
   /**
    * 計算ロジック＆更新時に必要なものを全部持ったインナークラス
    */
    public class RecipeTenkaiObject
    {
        public RecipeTenkaiObject()
        {
        }
        public RecipeTenkaiObject(usp_RecipeTenkai_Result data)
        {
            // 品名コード（画面情報）
            hinmeiCode = data.cd_hinmei;
            // 職場コード（画面情報）
            shokubaCode = data.cd_shokuba;
            // ラインコード（画面情報）
            lineCode = data.cd_line;
            // 製造日（画面情報）
            seizoDate = Convert.ToDateTime(data.dt_seizo);
            // 数量（画面情報）
            suryo = data.su_suryo.ToString();
            
            // 歩留（品名マスタ）
            hinmeiBudomari = data.hinmei_budomari.ToString();
            // 展開フラグ（品名マスタ）
            hinmeiTenkaiFlag = data.hinmei_flg_tenkai.ToString();
            // 比重（品名マスタ）
            hiju = data.ritsu_hiju.ToString();
            // 入数（品名マスタ）
            iriSu = data.su_iri.ToString();
            // 個重量（品名マスタ）
            koJuryo = data.wt_ko.ToString();
            // 換算区分（品名マスタ）
            hinmeiKanzanKubun = data.hinmei_kbn_kanzan;

            // 配合コード（配合名マスタ）
            haigoCode = data.cd_haigo;
            // 配合名　日本語（配合名マスタ） 
            haigoName = data.nm_haigo_ja;
            // 歩留（配合名マスタ）
            haigoBudomari = data.haigo_budomari.ToString();
            // 基本重量（配合名マスタ）
            haigoKihonJuryo = data.haigo_wt_kihon.ToString();
            // 仕込合算フラグ（配合名マスタ）
            gassanShikomiFlag = data.flg_gassan_shikomi.ToString();
            // 配合重量（配合名マスタ）
            haigoJuryo = data.haigo_wt_haigo.ToString();
            // 展開フラグ（配合名マスタ）
            haigoTenkaiFlag = data.haigo_flg_tenkai.ToString();
            // 換算区分（配合名マスタ）
            haigoKanzanKubun = data.haigo_kbn_kanzan;
            // 合計配合重量（配合名マスタ）
            haigoGokeiJyuryo = data.wt_haigo_gokei.ToString();
            // 基本倍率（配合名マスタ）
            kihonBairitsu = data.ritsu_kihon.ToString();

            // 配合コード（配合レシピマスタ） 仕掛品サマリの「仕掛品コード」となる
            recipeHaigoCode = data.cd_haigo;
            // 配合名（配合レシピマスタ）
            recipeHaigoName = data.nm_haigo_ja;
            // 版番号（配合レシピマスタ）
            hanNo = data.no_han.ToString();
            // 配合重量（配合レシピマスタ）
            recipeHaigoJuryo = data.recipe_wt_haigo.ToString();
            // 工程番号（配合レシピマスタ）
            koteiNo = data.no_kotei.ToString();
            // 投入番号（配合レシピマスタ）
            tonyuNo = data.no_tonyu.ToString();
            // 品区分（配合レシピマスタ）
            recipeHinKubun = data.recipe_kbn_hin.ToString();
            // 品名コード（配合レシピマスタ）
            recipeHinmeiCode = data.recipe_cd_hinmei;
            // 品名（配合レシピマスタ）
            recipeHinmeiName = data.recipe_nm_hinmei;
            // 仕込重量（配合レシピマスタ）
            shikomiJuryo = data.wt_shikomi.ToString();
            // 歩留（配合レシピマスタ）
            recipeBudomari = data.recipe_budomari.ToString();

            // 階層
            //kaisoSu = int.Parse(data.su_kaiso);
            kaisoSu = (int)data.su_kaiso;
            // ロット番号
            oyaShikakariLotNo = data.no_lot_shikakari_oya;
        }
        public String hinmeiCode { get; set; }
        public String shokubaCode { get; set; }
        public DateTime seizoDate { get; set; }
        public String suryo { get; set; }

        public String haigoCode { get; set; }
        public String haigoName { get; set; }
        public String hinmeiBudomari { get; set; }
        public String hinmeiTenkaiFlag { get; set; }
        public String hinmeiKanzanKubun { get; set; }
        public String hiju { get; set; }
        public String iriSu { get; set; }
        public String koJuryo { get; set; }
        public String haigoBudomari { get; set; }
        public String haigoKihonJuryo { get; set; }
        public String gassanShikomiFlag { get; set; }
        public String haigoJuryo { get; set; }
        public String haigoTenkaiFlag { get; set; }
        public String haigoKanzanKubun { get; set; }
        public String hanNo { get; set; }
        public String recipeHaigoJuryo { get; set; }
        public String koteiNo { get; set; }
        public String tonyuNo { get; set; }
        public String haigoGokeiJyuryo {get;set;}
        public String kihonBairitsu {get;set;}
        public String recipeHaigoCode { get; set; }
        public String recipeHaigoName { get; set; }
        public String recipeHinKubun { get; set; }
        public String recipeHinmeiCode { get; set; }
        public String recipeHinmeiName { get; set; }
        public String recipeShikomiJuryo { get; set; }
        public String shikomiJuryo { get; set; }
        public String recipeBudomari { get; set; }
        public String shizaiCode { get; set; }
        public String shiyoSu { get; set; }
        public int kaisoSu { get; set; }

        // ↓計算される項目↓

        // 計画仕込重量
        //public decimal seizoYoteiJuryo { get; set; }
        // 必要重量
        public decimal hitsuyoJuryo { get; set; }
        // 計画バッチ数
        public decimal keikakuBatchSu { get; set; }
        // 計画バッチ端数
        public decimal keikakuBatchSuHasu { get; set; }
        // 計画倍率
        public decimal keikakuBairitsu { get; set; }
        // 計画倍率端数
        public decimal keikakuBairitsuHasu { get; set; }
        // 計画配合重量
        public decimal keikakuHaigoJuryo { get; set; }
        // 計画配合重量端数
        public decimal keikakuHaigoJuryoHasu { get; set; }
        // 計画仕込重量
        public decimal keikakuShikomiJuryo { get; set; }

        // 不足していて仕掛品計画トランの項目
        // データ用キー番号
        public String dataKey { get; set; }
        // 必要日
        public DateTime hitsuyoDate { get; set; }
        // 製品ロット番号
        public String seihinLotNo { get; set; }
        // 仕掛品ロット番号
        public String shikakariLotNo { get; set; }
        // 親仕掛品ロット番号
        public String oyaShikakariLotNo { get; set; }
        // ラインコード
        public String lineCode { get; set; }
        // 親データ用キー番号
        public String oyaDataKey { get; set; }

        // 不足している仕掛品計画サマリの項目
        // 計画在庫重量
        public String keikakuZaikoJuryo { get; set; }
        // 残仕込重量
        public String zanShikomiJuryo { get; set; }
        // 実績仕込重量
        public String jissekiShikomiJuryo { get; set; }
        // 実績在庫重量
        public String jissekiZaikoJuryo { get; set; }
        // 実績配合重量
        public String jissekiHaigoJuryo { get; set; }
        // 実績配合重量端数
        public String jissekiHaigoJuryoHasu { get; set; }
        // 実績バッチ数
        public String jissekiBatchSu { get; set; }
        // 実績バッチ数端数
        public String jissekiBatchSuHasu { get; set;}
        // 実績倍率
        public String jissekiBairitsu { get; set; }
        // 実績倍率端数
        public String jissekiBairitsuHasu { get; set; }
        // 印刷済ラベル数
        public String insatsuZumiLabelSu { get; set; }
        // ラベル発行フラグ
        public String labelHakkoFlag { get; set; }
        // 印刷済ラベル端数
        public String insatssuZUmiLabelHasu { get; set; }
        // ラベル発行フラグ（端数）
        public String labelHakkoHasuFlag { get; set; }
        // 計画確定フラグ
        public String keikakuKakuteiFlag { get; set; }
        // 実績確定フラグ
        public String jissekiKakuteiFlag { get; set; }
        // 修正フラグ　
        public String shuseiFlag { get; set; }
        // 仕込フラグ
        public String shikomiFlag { get; set; }

        // 

       /// <summary>
       ///  サマリデータ作成のためのキー取得
       /// </summary>
       /// <returns></returns>
        public ShikakariGassanKey getGassanKey()
        {
            return new ShikakariGassanKey(shokubaCode, lineCode, recipeHinmeiCode, seizoDate);
        }

        public void setRecipeTenkaiContents(RecipeTenkaiObject obj)
        {
            this.hinmeiCode = obj.hinmeiCode;
            this.shokubaCode = obj.shokubaCode;
            this.seizoDate = obj.seizoDate;
            this.suryo = obj.suryo;
            this.haigoCode = obj.haigoCode;
            this.haigoName = obj.haigoName;
            this.hinmeiBudomari = obj.hinmeiBudomari;
            this.hinmeiTenkaiFlag = obj.hinmeiTenkaiFlag;
            this.hinmeiKanzanKubun = obj.hinmeiKanzanKubun;
            this.hiju = obj.hiju;
            this.iriSu = obj.iriSu;
            this.koJuryo = obj.koJuryo;
            this.haigoBudomari = obj.haigoBudomari;
            this.haigoKihonJuryo = obj.haigoKihonJuryo;
            this.gassanShikomiFlag = obj.gassanShikomiFlag;
            this.haigoJuryo = obj.haigoJuryo;
            this.haigoTenkaiFlag = obj.haigoTenkaiFlag;
            this.haigoKanzanKubun = obj.haigoKanzanKubun;
            this.hanNo = obj.hanNo;
            this.recipeHaigoJuryo = obj.recipeHaigoJuryo;
            this.koteiNo = obj.koteiNo;
            this.tonyuNo = obj.tonyuNo;
            this.haigoGokeiJyuryo = obj.haigoGokeiJyuryo;
            this.kihonBairitsu = obj.kihonBairitsu;
            this.recipeHaigoCode = obj.recipeHaigoCode;
            this.recipeHaigoName = obj.recipeHaigoName;
            this.recipeHinKubun = obj.recipeHinKubun;
            this.recipeHinmeiCode = obj.recipeHinmeiCode;
            this.recipeHinmeiName = obj.recipeHinmeiName;
            this.shikomiJuryo = obj.shikomiJuryo;
            this.recipeBudomari = obj.recipeBudomari;
            this.shizaiCode = obj.shizaiCode;
            this.shiyoSu = obj.shiyoSu;
            this.kaisoSu = obj.kaisoSu;
            this.hitsuyoJuryo = obj.hitsuyoJuryo;
            this.keikakuBatchSu = obj.keikakuBatchSu;
            this.keikakuBatchSuHasu = obj.keikakuBatchSuHasu;
            this.keikakuBairitsu = obj.keikakuBairitsu;
            this.keikakuBairitsuHasu = obj.keikakuBairitsuHasu;
            this.keikakuHaigoJuryo = obj.keikakuHaigoJuryo;
            this.keikakuHaigoJuryoHasu = obj.keikakuHaigoJuryoHasu;
            this.keikakuShikomiJuryo = obj.keikakuShikomiJuryo;
            this.dataKey = obj.dataKey;
            this.hitsuyoDate = obj.hitsuyoDate;
            this.seihinLotNo = obj.seihinLotNo;
            this.shikakariLotNo = obj.shikakariLotNo;
            this.oyaShikakariLotNo = obj.oyaShikakariLotNo;
            this.lineCode = obj.lineCode;
            this.keikakuZaikoJuryo = obj.keikakuZaikoJuryo;
            this.zanShikomiJuryo = obj.zanShikomiJuryo;
            this.jissekiShikomiJuryo = obj.jissekiShikomiJuryo;
            this.jissekiZaikoJuryo = obj.jissekiZaikoJuryo;
            this.jissekiHaigoJuryo = obj.jissekiHaigoJuryo;
            this.jissekiHaigoJuryoHasu = obj.jissekiHaigoJuryoHasu;
            this.jissekiBatchSu = obj.jissekiBatchSu;
            this.jissekiBatchSuHasu = obj.jissekiBatchSuHasu;
            this.jissekiBairitsu = obj.jissekiBairitsu;
            this.jissekiBairitsuHasu = obj.jissekiBairitsuHasu;
            this.insatsuZumiLabelSu = obj.insatsuZumiLabelSu;
            this.labelHakkoFlag = obj.labelHakkoFlag;
            this.insatssuZUmiLabelHasu = obj.insatssuZUmiLabelHasu;
            this.labelHakkoHasuFlag = obj.labelHakkoHasuFlag;
            this.keikakuKakuteiFlag = obj.keikakuKakuteiFlag;
            this.jissekiKakuteiFlag = obj.jissekiKakuteiFlag;
            this.shuseiFlag = obj.shuseiFlag;
            this.shikomiFlag = obj.shikomiFlag;

        }
    }
}