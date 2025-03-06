(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        //_pageTitle: { text: "原料批量登录" },
        _pageTitle: { text: "原料批号登录" },

        // 検索条件
        dt_hiduke_search: { text: "日期" },
        //no_lot_search: { text: "批量编号" },
        no_lot_search: { text: "批号" },
        cd_hinmei_search: { text: "品名编号" },

        // 結果一覧
        //genryoLotSentakuButton: { text: "原料批量选择" },
        genryoLotSentakuButton: { text: "原料批号选择" },
        //genryoLotTorikeshiButton: { text: "原料批量取消" },
        genryoLotTorikeshiButton: { text: "原料批号取消" },

        //cd_hinmei: { text: "原料批量", number: 120 },
        cd_hinmei: { text: "原料批号", number: 120 },
        nm_hinmei_ryaku: { text: "原料名", number: 250 },
        nm_nisugata_hyoji: { text: "包装形式", number: 185 },
        nm_tani_shiyo: { text: "使用单位", number: 80 },
        //no_lot: { text: "原料批量编号", number: 225 },
        no_lot: { text: "原料批号", number: 225 },
        flg_henko: { text: "变更", number: 30 },
        no_kotei: { text: "工位", number: 40 },
        no_tonyu: { text: "投入顺", number: 50 },
        biko: { text: "备注", number: 200 },
        blank: { text: "", number: 0 },
        contentConfirm: { text: MS0784 }
    });

    App.ui.pagedata.validation("zh", {
        cd_hinmei: {
            rules: {
                maxlength: 14,
            },
            params: {
            },
            messages: {
                maxlength: MS0012,
                custom: MS0786
            }
        },
        no_lot: {
            rules: {
            },
            params:{
            },
            messages:{
                custom: MS0785
            }
        },
        biko: {
            rules: {
                maxbytelength: 100
            },
            params: {
            },
            messages: {
                maxbytelength: MS0012
            }
        }
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("zh", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },        
        colchange: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        genryoLotSentaku: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        genryoLotTorikeshi:{
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        save: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });
})();
