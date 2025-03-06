(function () {
    // visible が未設定の場合は表示
    // visible が "*" の場合は権限確認しない
    // visible が "*" 以外の場合は、一致する role だけに表示
    // visible が配列の場合は、一致する role が含まれている場合だけ表示
    // visible が関数の場合は、戻り値として true が返ってきた場合だけ表示
    App.ui.ddlmenu.settings("zh", "主菜单", [

        {
            display: "生产菜单",
            items: [
                { display: "月产品计划", url: "../Pages/GekkanSeihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "月半成品计划", url: "../Pages/GekkanShikakarihinKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
               // { display: "半成品采购计划", url: "../Pages/ShikakarihinShikomiKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "半成品投入计划", url: "../Pages/ShikakarihinShikomiKeikaku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "生产线未登录一览", url: "../Pages/LineMitorokuIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "出库委托", url: "../Pages/GenryoShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
            //{ display: "材料使用量计算", url: "../Pages/ShizaiShiyoryoKeisan.aspx", visible: ["Admin", "Manufacture", "Purchase"] }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Quality"]
        },
        {
            display: "原材料菜单",
            items: [
                { display: "原材料变动表", url: "../Pages/GenshizaiHendoHyo.aspx" },
                //{ display: "警告列表", url: "../Pages/KeikokuListSakusei.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
                { display: "警告列表", url: "../Pages/KeikokuListSakusei.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
            //SAP対応の為非表示
            //{ display: "原材料采购计划制定", url: "../Pages/GenshizaiNonyuKeikakuSakusei.aspx", visible: ["Admin", "Purchase"] },
                {display: "制作入库委托书", url: "../Pages/NonyuIraishoSakusei.aspx", visible: ["Admin", "Purchase"] },
                { display: "入库预定列表", url: "../Pages/NonyuYoteiListSakusei.aspx", visible: ["Admin", "Purchase"] },
                //{ display: "变动模拟", url: "../Pages/HendoHyoSimulation.aspx", visible: ["Admin", "Purchase"] },
                { display: "变动表模拟", url: "../Pages/HendoHyoSimulation.aspx", visible: ["Admin", "Purchase"] },
                { display: "原材料・半成品使用一览", url: "../Pages/GenshizaiShikakarihinShiyoIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                //{ display: "原材料批号追溯", url: "../Pages/GenshizaiLotTrace.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                //{ display: "原資材批号追溯一览", url: "../Pages/GenshizaiLotTraceIchiran.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] }
               // { display: "原材料出货一览", url: "../Pages/GenshizaiUkeharaiIchiran.aspx", visible: ["Admin", "Manufacture", "Quality", "Purchase", "Warehouse"] 
                { display: "原材料出入库一览", url: "../Pages/GenshizaiUkeharaiIchiran.aspx", visible: ["Admin", "Manufacture", "Quality", "Purchase", "Warehouse"] }
            ]
        },
        {
            display: "日报菜单",
            items: [
                { display: "生产日报", url: "../Pages/SeizoNippo.aspx", visible: ["Admin", "Manufacture", "Purchase"] },
                { display: "投放日报", url: "../Pages/ShikomiNippo.aspx", visible: ["Admin", "Manufacture", "Purchase"] },
              //  { display: "使用实际一次性传送", url: "../Pages/ShiyoJissekiIkkatsuDenso.aspx", visible: ["Admin", "Manufacture"] },
                { display: "使用实际统括传送", url: "../Pages/ShiyoJissekiIkkatsuDenso.aspx", visible: ["Admin", "Manufacture"] },
                { display: "原材料调整输入", url: "../Pages/GenshizaiChoseiNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] },
                { display: "原材料库存输入", url: "../Pages/GenshizaiZaikoNyuryoku.aspx", visible: ["Admin", "Manufacture", "Purchase", "Warehouse"] }
            //                { display: "ＭＲＰ起動", url: "" }
            ],
            visible: ["Admin", "Manufacture", "Purchase", "Warehouse"]
        },
        {
           // display: "单价计算菜单",
            display: "原价计算菜单",
            items: [
                { display: "原价一览", url: "../Pages/GenkaIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "原价单价作成", url: "../Pages/GenkaTankaSakusei.aspx", visible: ["Admin", "Purchase"] }
            ],
            visible: ["Admin", "Purchase"]
        },
        {
            display: "基本主表菜单",
            items: [
                { display: "品名主表", url: "../Pages/HinmeiMasterIchiran.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_hinmei != pageLangText.isRoleHinmei.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "配料主表", url: "../Pages/HaigoMasterIchiran.aspx", 
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality"]
                        if (App.ui.page.user.kbn_ma_haigo != pageLangText.isRoleHaigo.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                },
                { display: "生产可能生产线主表", url: "../Pages/SeizoLineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "材料使用主表", url: "../Pages/ShizaiShiyoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "厂商主表", url: "../Pages/TorihikisakiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "原材料购买商主表", url: "../Pages/GenshizaiKonyusakiMaster.aspx",
                    visible: function (role) {
                        //role ? ["Admin", "Purchase", "Quality", "Warehouse"] 
                        if (App.ui.page.user.kbn_ma_konyusaki != pageLangText.isRoleKonyusaki.number) {
                            return true;
                        } else {
                            return false;
                        }
                    } 
                },
                { display: "担当者主表", url: "../Pages/TantoshaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "年历主表", url: "../Pages/NenkanCalendarMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "公司主表", url: "../Pages/KaishaMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "工厂主表", url: "../Pages/KojoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "车间主表", url: "../Pages/ShokubaMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "生产线主表", url: "../Pages/LineMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality", "Warehouse"] },
                { display: "分类主表", url: "../Pages/BunruiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "单位设定主表", url: "../Pages/TaniSetteiMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "地点主表", url: "../Pages/LocationMaster.aspx",
                  visible: function (role) {
                        // role ? ["Admin", "Manufacture", "Purchase"]
                     if (App.ui.page.user.locationCode == pageLangText.locationKbn_ari.number) {
                            return true;
                        } else {
                            return false;
                        }
                    }
                }
            ]
        },
        {
            display: "选项菜单",
            items: [
                { display: "仓库地点主表", url: "../Pages/KurabashoMaster.aspx", visible: ["Admin", "Purchase", "Warehouse"] },
                {display: "入库地点主表", url: "../Pages/NiukeBashoMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "入库地点区分主表", url: "../Pages/NiukeBashoKubunMaster.aspx", visible: ["Admin", "Quality", "Purchase", "Warehouse"] },
                { display: "保管区分主表", url: "../Pages/HokanKubunMaster.aspx", visible: ["Admin", "Purchase", "Quality", "Warehouse"] },
                { display: "投放作业指示主表", url: "../Pages/ShikomiSagyoShijiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "包装主表", url: "../Pages/FutaiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "包装决定主表", url: "../Pages/FutaiKetteiMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "重量主表", url: "../Pages/JuryoMaster.aspx", visible: ["Admin", "Manufacture", "Purchase", "Quality"] },
                { display: "注意唤起主表", url: "../Pages/ChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
            	{ display: "原料注意喚起主表", url: "../Pages/GenryoChuiKankiMaster.aspx", visible: ["Admin", "Manufacture", "Quality", "Warehouse"] },
                { display: "理由主表", url: "../Pages/RiyuMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "原价中心主表", url: "../Pages/GenkaCenterMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "仓库主表", url: "../Pages/SokoMaster.aspx", visible: ["Admin", "Purchase"] },
                { display: "变更记录确认", url: "../Pages/HistoryChangeMaster.aspx" }
            ]
        }/*,
        {
            display: "传送记录菜单",
            items: [
                { display: "生产计划传送一览", url: "../Pages/SeizoKeikakuDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "生产实际传送一览", url: "../Pages/SeizoJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "入库预定传送一览", url: "../Pages/NonyuYoteiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "入库实际传送一览", url: "../Pages/NonyuJissekiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "库存调整传送一览", url: "../Pages/ZaikoChoseiDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "月末库存传送一览", url: "../Pages/GetsumatsuZaikoDensoIchiran.aspx", visible: ["Admin", "Purchase"] },
                { display: "配方主表传送一览", url: "../Pages/BomMasterDensoIchiran.aspx", visible: ["Admin", "Purchase"] }
            ],
            visible: ["Admin", "Purchase"]
        }*/
    /*
    {
    display: "追溯菜单",
    items: [
    { display: "称量实际追溯", url: "../Pages/KowakeTrace.aspx" },
    { display: "投入实际追溯", url: "../Pages/KowakeTrace.aspx" }
    //                { display: "设备主表", url: "../Pages/SetsubiMaster.aspx" }
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
