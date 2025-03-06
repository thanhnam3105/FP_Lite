(function () {
    // visible が未設定の場合は表示
    // visible が "*" の場合は権限確認しない
    // visible が "*" 以外の場合は、一致する role だけに表示
    // visible が配列の場合は、一致する role が含まれている場合だけ表示
    // visible が関数の場合は、戻り値として true が返ってきた場合だけ表示
    App.ui.ddlmenu.settings("ja", "メニュー", [

        {
            display: "製造メニュー",
            items: [
                { display: "月間製品計画", url: "../Pages/GekkanSeihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "月間仕掛品計画", url: "../Pages/GekkanShikakarihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "仕掛品仕込計画", url: "../Pages/ShikakarihinShikomiKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "製造ライン未登録一覧", url: "../Pages/LineMitorokuIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "庫出依頼", url: "../Pages/GenryoShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
            //{ display: "資材使用量計算", url: "../Pages/ShizaiShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Quality"]
        },
        {
            display: "原資材メニュー",
            items: [
                { display: "原資材変動表", url: "../Pages/GenshizaiHendoHyo.aspx" },
                { display: "警告リスト作成", url: "../Pages/KeikokuListSakusei.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
            //SAP対応の為非表示
            //{ display: "原資材納入計画作成", url: "../Pages/GenshizaiNonyuKeikakuSakusei.aspx", visible: ["Admin", "Purchase"] },
                {display: "納入依頼書作成", url: "../Pages/NonyuIraishoSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "納入予定リスト作成", url: "../Pages/NonyuYoteiListSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "変動表シミュレーション", url: "../Pages/HendoHyoSimulation.aspx", visible: ["Admin", "Purchase"] },
                { display: "原資材・仕掛品使用一覧", url: "../Pages/GenshizaiShikakarihinShiyoIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
            //{ display: "原資材ロットトレース(仮)", url: "../Pages/GenshizaiLotTrace.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
            //{ display: "原資材ロットトレース一覧(仮)", url: "../Pages/GenshizaiLotTraceIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] }
                {display: "原資材受払一覧", url: "../Pages/GenshizaiUkeharaiIchiran.aspx", visible: ["Admin", "Manufacture", "Quality", "Purchase", "Warehouse"] }
            ]
        },
        {
            display: "日報メニュー",
            items: [
                { display: "製造日報", url: "../Pages/SeizoNippo.aspx", visible: ["Admin", "Manufacture", "Purchase"] },
                { display: "仕込日報", url: "../Pages/ShikomiNippo.aspx", visible: ["Admin", "Manufacture", "Purchase"] },
                { display: "使用実績一括伝送", url: "../Pages/ShiyoJissekiIkkatsuDenso.aspx", visible: ["Admin", "Manufacture"] },
                { display: "原資材調整入力", url: "../Pages/GenshizaiChoseiNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] },
                { display: "原資材在庫入力", url: "../Pages/GenshizaiZaikoNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] }
            //                { display: "ＭＲＰ起動", url: "" }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Warehouse"]
        },
        {
            display: "原価計算メニュー",
            items: [
                { display: "原価一覧", url: "../Pages/GenkaIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "原価単価作成", url: "../Pages/GenkaTankaSakusei.aspx", visible: ["Admin", "Purchase"] }
            ],
            visible: ["Admin", "Purchase"]
        },
        {
            display: "基本マスタメニュー",
            items: [
                { display: "品名マスタ", url: "../Pages/HinmeiMasterIchiran.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_hinmei != pageLangText.isRoleHinmei.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "配合マスタ", url: "../Pages/HaigoMasterIchiran.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_haigo != pageLangText.isRoleHaigo.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "製造可能ラインマスタ", url: "../Pages/SeizoLineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "資材使用マスタ", url: "../Pages/ShizaiShiyoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "取引先マスタ", url: "../Pages/TorihikisakiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },

                { display: "原資材購入先マスタ", url: "../Pages/GenshizaiKonyusakiMaster.aspx",
                   visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality", "Warehouse"] 
                       if (App.ui.page.user.kbn_ma_konyusaki != pageLangText.isRoleKonyusaki.number) {
                            return true;
                        } else {
                            return false;
                        }
                    } 
                },
                { display: "担当者マスタ", url: "../Pages/TantoshaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "年間カレンダーマスタ", url: "../Pages/NenkanCalendarMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "会社マスタ", url: "../Pages/KaishaMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "工場マスタ", url: "../Pages/KojoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "職場マスタ", url: "../Pages/ShokubaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "ラインマスタ", url: "../Pages/LineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "分類マスタ", url: "../Pages/BunruiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "単位設定マスタ", url: "../Pages/TaniSetteiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "ロケーションマスタ", url: "../Pages/LocationMaster.aspx",
                    visible: function (role) {
                        // role ? ["Admin", "Manufacture", "Purchase"]
                        if (App.ui.page.user.locationCode == pageLangText.locationKbn_ari.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
            // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):メニューからのリンク削除
                {display: "仕掛残使用可能マスタ", url: "../Pages/ShikakarizanShiyoKanoMaster.aspx", visible: [/*"Admin", "Quality"*/] }
            ]
        },
        {
            display: "オプションメニュー",
            items: [
                { display: "庫場所マスタ", url: "../Pages/KurabashoMaster.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
                { display: "荷受場所マスタ", url: "../Pages/NiukeBashoMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "荷受場所区分マスタ", url: "../Pages/NiukeBashoKubunMaster.aspx", visible: ["Admin", "Quality", "Purchase", "Warehouse"] },
                { display: "保管区分マスタ", url: "../Pages/HokanKubunMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "仕込作業指示マスタ", url: "../Pages/ShikomiSagyoShijiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "風袋マスタ", url: "../Pages/FutaiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "風袋決定マスタ", url: "../Pages/FutaiKetteiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "重量マスタ", url: "../Pages/JuryoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "注意喚起マスタ", url: "../Pages/ChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
            	{ display: "原料注意喚起マスタ", url: "../Pages/GenryoChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
                { display: "理由マスタ", url: "../Pages/RiyuMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "原価センターマスタ", url: "../Pages/GenkaCenterMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "倉庫マスタ", url: "../Pages/SokoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "変更履歴確認", url: "../Pages/HistoryChangeMaster.aspx" }
            ]
        }/*,
        {
            display: "伝送履歴メニュー",
            items: [
                { display: "製造計画伝送一覧", url: "../Pages/SeizoKeikakuDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "製造実績伝送一覧", url: "../Pages/SeizoJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "納入予定伝送一覧", url: "../Pages/NonyuYoteiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "納入実績伝送一覧", url: "../Pages/NonyuJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "在庫調整伝送一覧", url: "../Pages/ZaikoChoseiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "月末在庫伝送一覧", url: "../Pages/GetsumatsuZaikoDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "BOMマスタ伝送一覧", url: "../Pages/BomMasterDensoIchiran.aspx", visible: ["Admin", "Purchase"] }
            ],
            visible: ["Admin", "Purchase"]
        }*/
    /*
    {
    display: "トレースメニュー",
    items: [
    { display: "小分実績トレース", url: "../Pages/KowakeTrace.aspx" },
    { display: "投入実績トレース", url: "../Pages/KowakeTrace.aspx" }
    //                { display: "設備マスタ", url: "../Pages/SetsubiMaster.aspx" }
    ]
    }
    */

    /*
    {
    display: "システムロール専用メニュー",
    visible: function (role) {
    return !!/^sys.*$/i.test(role);
    },
    url: "http://www.google.com"
    }
    */
    ]);

})(App);
