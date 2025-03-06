using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tos.FoodProcs.Web.Data
{
    /// <summary>
    /// ユーザー情報を定義します。
    /// </summary>
    public class UserInfo
    {
        /// <summary>
        /// ユーザー情報を定義するクラスのインスタンスを初期化します。
        /// </summary>
        public UserInfo()
        {
            this.Organization = string.Empty;
            this.Branch = string.Empty;
            this.BranchCode = string.Empty;
            this.Code = string.Empty;
            this.Name = string.Empty;
            this.Roles = new List<string>();
            this.KaishaCode = string.Empty;
            this.locationCode = (int)0;
            this.kbn_tani = string.Empty;
            this.kbn_hinmei_kirikae = (int)0;
            this.kbn_ma_hinmei = (int)0;
            this.kbn_ma_haigo = (int)0;
            this.kbn_ma_konyusaki = (int)0;
            this.kbn_shikomi_chohyo = (int)0;
        }

        /// <summary>
        /// 現在ログインしているユーザーの組織
        /// </summary>
        public string Organization { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーの所属
        /// </summary>
        public string Branch { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーの所属コード
        /// </summary>
        public string BranchCode { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーコード
        /// </summary>
        public string Code { get; set; }

        /// <summary>
        /// 現在ログインしているユーザー名
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーが付与されているロール（権限）
        /// </summary>
        public List<string> Roles { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーの会社コード
        /// </summary>
        public string KaishaCode { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーのロケーション区分
        /// </summary>
        public int locationCode { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーの単位区分
        /// </summary>
        public string kbn_tani { get; set; }

        /// <summary>
        /// 現在ログインしているユーザーの品名表示切替区分
        /// </summary>
        public int kbn_hinmei_kirikae { get; set; }
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Update new column from [vw_user_info]
        //------------------------START----------------------------
        /// <summary>
        /// kbn_ma_hinmei
        /// </summary>
        public short? kbn_ma_hinmei { get; set; }

        /// <summary>
        /// kbn_ma_haigo
        /// </summary>
        public short? kbn_ma_haigo { get; set; }

        /// <summary>
        /// kbn_ma_konyusaki
        /// </summary>
        public short? kbn_ma_konyusaki { get; set; }

        /// <summary>
        /// kbn_shikomi_chohyo
        /// </summary>
        public short? kbn_shikomi_chohyo { get; set; }
        //-------------------------END-----------------------------

    }
}