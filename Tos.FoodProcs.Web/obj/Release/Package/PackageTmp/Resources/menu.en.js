(function () {
    // visible が未設定の場合は表示
    // visible が "*" の場合は権限確認しない
    // visible が "*" 以外の場合は、一致する role だけに表示
    // visible が配列の場合は、一致する role が含まれている場合だけ表示
    // visible が関数の場合は、戻り値として true が返ってきた場合だけ表示
    App.ui.ddlmenu.settings("en", "Menu", [

        {
            display: "Manufacture Menu",
            items: [
                { display: "Production Plan", url: "../Pages/GekkanSeihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Monthly Mixer Plan", url: "../Pages/GekkanShikakarihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Mixer Plan", url: "../Pages/ShikakarihinShikomiKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Manufacture Line Unregistered List", url: "../Pages/LineMitorokuIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Material Issue Order", url: "../Pages/GenryoShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
                //{ display: "Packing material usage quantity calculator", url: "../Pages/ShizaiShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Quality"]
        },
        {
            display: "Purchase Menu",
            items: [
                { display: "Material Inventory Table", url: "../Pages/GenshizaiHendoHyo.aspx" },
                { display: "Warning List", url: "../Pages/KeikokuListSakusei.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
            //SAP対応の為非表示
                //{ display: "Auto Make Delivery Plan", url: "../Pages/GenshizaiNonyuKeikakuSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "Make Delivery Request Sheet", url: "../Pages/NonyuIraishoSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "Purchase List", url: "../Pages/NonyuYoteiListSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "Material Inventory Simulation", url: "../Pages/HendoHyoSimulation.aspx", visible: ["Admin", "Purchase"] },
                { display: "Material And Semi-Finished Product Use List", url: "../Pages/GenshizaiShikakarihinShiyoIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Material Movement History", url: "../Pages/GenshizaiUkeharaiIchiran.aspx", visible: ["Admin", "Manufacture", "Quality", "Purchase", "Warehouse"] }
            ]
        },
        {
            display: "Daily Report Menu",
            items: [
                { display: "Daily Report Of Productions", url: "../Pages/SeizoNippo.aspx", visible: ["Admin", "Manufacture", "Purchase"] },
                { display: "Daily Report Of Mixer", url: "../Pages/ShikomiNippo.aspx", visible: ["Admin", "Manufacture", "Purchase"] },
                { display: "Actual Use Transmission (to SAP)", url: "../Pages/ShiyoJissekiIkkatsuDenso.aspx", visible: ["Admin", "Manufacture"] },
                { display: "Input Material Adjustment", url: "../Pages/GenshizaiChoseiNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] },
                { display: "Input Material Inventory", url: "../Pages/GenshizaiZaikoNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Warehouse"]
        },
        {
            display: "Cost Accounting Menu",
            items: [
                { display: "Cost List", url: "../Pages/GenkaIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Cost Unit Price Creation", url: "../Pages/GenkaTankaSakusei.aspx", visible: ["Admin", "Purchase"] }
            ],
            visible: ["Admin", "Purchase"]
        },
        {
        display: "Basic Master Menu",
        items: [
                { display: "Material Master", url: "../Pages/HinmeiMasterIchiran.aspx", 
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_hinmei != pageLangText.isRoleHinmei.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "Formula Master", url: "../Pages/HaigoMasterIchiran.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_haigo != pageLangText.isRoleHaigo.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "Manufacturable Line Master", url: "../Pages/SeizoLineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Packing Bom Master", url: "../Pages/ShizaiShiyoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Vendor Master", url: "../Pages/TorihikisakiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Source List", url: "../Pages/GenshizaiKonyusakiMaster.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality", "Warehouse"] 
                        if (App.ui.page.user.kbn_ma_konyusaki != pageLangText.isRoleKonyusaki.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "User Id", url: "../Pages/TantoshaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "Calendar Master", url: "../Pages/NenkanCalendarMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Company Master", url: "../Pages/KaishaMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Plant Master", url: "../Pages/KojoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Workplace Master", url: "../Pages/ShokubaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "Line Master", url: "../Pages/LineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "Group Master", url: "../Pages/BunruiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "UOM Master", url: "../Pages/TaniSetteiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Location Master", url: "../Pages/LocationMaster.aspx",
                    visible: function (role) {
                        // role ? ["Admin", "Manufacture", "Purchase"]
                        if (App.ui.page.user.locationCode == pageLangText.locationKbn_nasi.number) {
                            return false;
                        } else {
                            return true;
                        }
                    }
                },
                // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):メニューからのリンク削除
                { display: "Usable Inventory Master", url: "../Pages/ShikakarizanShiyoKanoMaster.aspx", visible: [/*"Admin", "Quality"*/] }
            ]
    },
        {
            display: "Option Menu",
            items: [
                { display: "Issued Location Master", url: "../Pages/KurabashoMaster.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
                { display: "Receipt Location Master", url: "../Pages/NiukeBashoMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Receipt Location Type Master", url: "../Pages/NiukeBashoKubunMaster.aspx", visible: ["Admin", "Quality", "Purchase", "Warehouse"] },
                { display: "Storage Type Master", url: "../Pages/HokanKubunMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "Operation Instruction Master", url: "../Pages/ShikomiSagyoShijiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Tare Master", url: "../Pages/FutaiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Tare Of Each Weight Master", url: "../Pages/FutaiKetteiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Basic Weighing Weight Master", url: "../Pages/JuryoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "Alert Master", url: "../Pages/ChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
            	{ display: "Material Alert Master", url: "../Pages/GenryoChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
                { display: "Reason Master", url: "../Pages/RiyuMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Cost Center Master", url: "../Pages/GenkaCenterMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Warehouse Master", url: "../Pages/SokoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "Change History List", url: "../Pages/HistoryChangeMaster.aspx" }
            ]
        }
        /*
        {
            display: "Transmission History Menu",
            items: [
                { display: "Manufacturing Planning Transmission List", url: "../Pages/SeizoKeikakuDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Manufacturing Results  Transmission List", url: "../Pages/SeizoJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Delivery Schedule Transmission List", url: "../Pages/NonyuYoteiDensoIchiran.aspx.aspx", visible: ["Admin", "Purchase"] },
                { display: "Delivery Record Transmission List", url: "../Pages/NonyuJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Stock Adjustment Transmission List", url: "../Pages/ZaikoChoseiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "Month-end Stocktaking Transmission List", url: "../Pages/GetsumatsuZaikoDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "BOM Master Transmission List", url: "../Pages/BomMasterDensoIchiran.aspx", visible: ["Admin", "Purchase"] }
            ],
            visible: ["Admin", "Purchase"]
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
